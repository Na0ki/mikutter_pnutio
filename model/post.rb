# -*- coding: utf-8 -*-

module Plugin::Pnutio
  class Post < Retriever::Model
    include Retriever::Model::MessageMixin

    register :pnutio_post, name: "pnut.io Post", timeline: true

    field.time :created, required:true
    field.string :id, required:true
    field.string :text, required:true
    field.string :source
    field.has :user, Plugin::Pnutio::User, required:true
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
      Retriever::URI("https://pnut.io/@"+user.username+"/"+id)
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

    def favorite(_fav=true)
      Deferred.new {
        if _fav == true
          res = API::put_with_auth("posts/"+id+"/bookmark")
        else
          res = API::delete_with_auth("posts/"+id+"/bookmark")
        end
        result = res["meta"]["code"] < 400
        # エラーでももうやってあるっぽい場合はやったことにする
        if result == false
          if _fav == false && res["meta"]["error_message"] == "Post not bookmarked."
            result = true
          elsif _fav == true and res["meta"]["error_message"] == "Bookmark already exists."
            result=true
          end
        end
        if result
          my_user = User.for_dict(UserConfig[:pnutio_user_object])
          if _fav
            Plugin.call :favorite, Service.primary, my_user, self
          else
            Plugin.call :unfavorite, Service.primary, my_user, self
          end
          self.youBookmarked=_fav
        else
          p res["meta"]
          Deferred.fail(res["meta"]["error_message"])
        end
        result
      }
    end

    def unfavorite
      favorite(_fav:false)
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
    
    def introducer(me=Service.primary!)
      self
    end
  end
end