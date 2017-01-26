module Plugin::mikutter_pnutio
    class Post < Retriever::Model
        include Retriever::Model::MessageMixin

        register :pnutio_post, "pnut.io Post", timeline: true

        field.string :id
        field.string :text
        field.string :source
        field.time :created
        field.bool :isMuted
        field.bool :isRepost
        field.bool :isSelf
        field.bool :isStarred
        field.bool :isThread
        field.int :numReplies
        field.int :numReposts
        field.int :numStars
        field.has :user, Plugin::mikutter_pnutio::User, required:true

        def to_show
            text
        end

        def uri
            URI.parse("pnutio://users/"+id)
        end
    end
end