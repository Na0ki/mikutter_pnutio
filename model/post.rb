# -*- coding: utf-8 -*-

module Plugin::Pnutio
  class Post < Retriever::Model
    include Retriever::Model::MessageMixin

    register :pnutio_post, name: "pnut.io Post", timeline: true

    field.time :created, required: true
    field.string :id, required: true
    field.string :text, required: true
    field.string :source
    field.has :user, Plugin::Pnutio::User, required: true
    field.int :bookmarksCount
    field.int :repostsCount
    field.int :repliesCount
    field.int :threadsCount
    field.bool :youBookmarked
    field.bool :youReposted

    def to_show
      @to_show ||= self[:text]
    end

    def perma_link
      Retriever::URI("https://pnut.io/@#{user.username}/#{id}")
    end

    # dictからpostを作る

    def self.for_dict(dict)
      post = Post.new(
        created: Time.iso8601(dict["created_at"]),
        id: dict["id"],
        text: dict["content"]["text"] || "",
        source: dict["source"]["name"]+"(with pnut.io)",
        user: User.for_dict(dict["user"]),
        bookmarksCount: dict["counts"]["bookmarks"],
        repostsCount: dict["counts"]["reposts"],
        repliesCount: dict["counts"]["replies"],
        threadsCount: dict["counts"]["threads"],
        youBookmarked: dict["you_bookmarked"],
        youReposted: dict["you_reposted"]
      )
      post.created.localtime post.user.timezone_offset
      post
    end

    # ふぁぼ実装

    def favorite(fav = true)
      Deferred.new do
        if fav
          Plugin::Pnutio::API.put_with_auth("posts/#{id}/bookmark").next { |res|
            handle_favourite(res)
          }
        else
          Plugin::Pnutio::API.delete_with_auth("posts/#{id}/bookmark").next { |res|
            handle_favourite(res)
          }
        end
      end
    end

    private def handle_favourite(res)
      result = res['meta']['code'] < 400
      err_msg = res['meta']['error_message']
      # エラーでももうやってあるっぽい場合はやったことにする
      result = true if !result && ((!fav && err_msg == 'Post not bookmarked.') || (fav && err_msg == 'Bookmark already exists.'))

      Deferred.fail(err_msg) unless result

      my_user = User.for_dict(UserConfig[:pnutio_user_object])
      status = fav ? :favorite : :unfavorite
      Plugin.call(status, Service.primary, my_user, self)
      self.youBookmarked = fav
      result
    end

    def unfavorite
      favorite(_fav: false)
    end

    def favorite?
      youBookmarked
    end

    def favorited_by
      []
    end

    def favoritable?
      true
    end

    def favorited_by_me?(me)
      favorite?
    end

    def introducer(me = Service.primary!)
      self
    end
  end
end