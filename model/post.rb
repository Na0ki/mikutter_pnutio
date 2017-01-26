# -*- coding: utf-8 -*-

module Plugin::MikutterPnutio
    class Post < Retriever::Model
        include Retriever::Model::MessageMixin

        register :pnutio_post, name: "pnut.io Post", timeline: true

        field.time :created, required:true
        field.string :id, required:true
        field.string :text, required:true
        field.string :source
        field.has :user, Plugin::MikutterPnutio::User, required:true
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
            Retriever::URI("https://api.pnut.io/users/"+id)
        end
    end
end