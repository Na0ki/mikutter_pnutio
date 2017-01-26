# -*- coding: utf-8 -*-

module Plugin::MikutterPnutio
    class Post < Retriever::Model
        include Retriever::Model::MessageMixin

        register :pnutio_post, name: "pnut.io Post", timeline: true

        field.time :created
        field.string :id
        field.string :text
        field.string :source
        field.has :user, Plugin::MikutterPnutio::User, required:true
        field.int :bookmarksCount
        field.int :repostsCount
        field.int :repliesCount
        field.int :threadsCount
        field.bool :youBookmarked
        field.bool :youReposted

        def to_show
            text
        end

        def uri
            URI.parse("pnutio://users/"+id)
        end
    end
end