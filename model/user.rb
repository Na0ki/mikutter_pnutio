# -*- coding: utf-8 -*-

module Plugin::MikutterPnutio
    class User < Retriever::Model
        include Retriever::Model::UserMixin

        field.string :id, required:true
        field.time :created
        field.string :locale
        field.string :timezone
        field.string :type
        field.string :username, required:true
        field.string :name
        field.string :profile_text
        field.string :avatar_image_link, required:true
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
            Retriever::URI("https://api.pnut.io/users/"+id)
        end

        def idname
            p username
            username
        end

        def profile_image_url
            avatar_image_link
        end
    end
end