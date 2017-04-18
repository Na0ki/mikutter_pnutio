# -*- coding: utf-8 -*-

require 'tzinfo'

module Plugin::Pnutio
  class User < Retriever::Model
    include Retriever::Model::UserMixin

    field.string :id, required: true
    field.time :created
    field.string :locale
    field.string :timezone
    field.string :type
    field.string :username, required: true
    field.string :idname, required: true
    field.string :name
    field.string :profile_text
    field.string :avatar_image_link, required: true
    field.int :avatar_image_height
    field.int :avatar_image_width
    field.bool :avatar_image_is_default
    field.string :cover_image_link
    field.int :cover_image_height
    field.int :cover_image_width
    field.bool :cover_image_is_default
    field.int :bookmarksCount
    field.int :clientsCount
    field.int :followersCount
    field.int :followingCount
    field.int :postsCount
    field.int :usersCount
    field.string :verifiedDomain
    field.string :verifiedLink
    field.bool :follows_you
    field.bool :you_blocked
    field.bool :you_follow
    field.bool :you_muted
    field.bool :you_can_follow

    def perma_link
      Retriever::URI("https://pnut.io/@#{user.username}")
    end

    # TODO: mikutterがidnameをfieldじゃないと表示してくれない不具合が直ったら消す
    #def idname
    #  p username
    #  username
    #end

    def profile_image_url
      avatar_image_link
    end

    def timezone_offset
      TZInfo::Timezone.get(timezone).current_period.utc_offset
    end

    def self.for_dict(dict)
      User.new(
        id: dict["id"],
        created: dict["created_at"],
        locale: dict["locale"],
        timezone: dict["timezone"],
        type: dict["type"],
        username: dict["username"],
        # TODO: mikutterがidnameをfieldじゃないと表示してくれない不具合が直ったら消す
        idname: dict["username"],
        name: dict["name"],
        profile_text: dict["content"]["text"],
        avatar_image_link: dict["content"]["avatar_image"]["link"],
        avatar_image_height: dict["content"]["avatar_image"]["height"],
        avatar_image_width: dict["content"]["avatar_image"]["width"],
        avatar_image_is_default: dict["content"]["avatar_image"]["is_default"],
        cover_image_link: dict["content"]["cover_image"]["link"],
        cover_image_height: dict["content"]["cover_image"]["height"],
        cover_image_width: dict["content"]["cover_image"]["width"],
        cover_image_is_default: dict["content"]["cover_image"]["is_default"],
        bookmarksCount: dict["counts"]["bookmarks"],
        clientsCount: dict["counts"]["clients"],
        followersCount: dict["counts"]["followers"],
        followingCount: dict["counts"]["following"],
        postsCount: dict["counts"]["posts"],
        usersCount: dict["counts"]["users"],
        follows_you: dict["follows_you"],
        you_blocked: dict["you_blocked"],
        you_follow: dict["you_follow"],
        you_muted: dict["you_muted"],
        you_can_follow: dict["you_can_follow"]
      )
    end
  end
end