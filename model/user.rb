module Plugin::mikutter_pnutio
    class User < Retriever::Model
        include Retriever::Model::MessageMixin

        register :pnutio_user, "pnut.io User"

        field.string :id
        field.string :name
        field.string :idname
        field.string :profile_image_url

        def uri
            URI.parse("pnutio://users/"+id)
        end
    end
end