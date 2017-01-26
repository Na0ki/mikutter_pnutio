module Plugin::MikutterPnutio
    class User < Retriever::Model
        include Retriever::Model::MessageMixin

        register :pnutio_user, name: "pnut.io User"

        field.string :id
        field.time :created
        field.string :locale
        field.string :timezone
        field.string :type
        field.string :username
        field.string :name
        field.string :profile_text
        field.string :avatar_image_link
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

        def uri
            URI.parse("pnutio://users/"+id)
        end

        def idname
            username
        end
        def profile_image_url
            avatar_image_link
        end
    end
end