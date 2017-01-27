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

        # ふぁぼ実装

        def favorite(_fav=true)
            Deferred.new {
                if _fav then
                    res = API::put_with_auth("posts/"+id+"/bookmark")["meta"]["code"] < 400
                else
                    res = API::delete_with_auth("posts/"+id+"/bookmark")["meta"]["code"] < 400
                end
                if res then
                    youBookmarked=_fav
                end
                res
            }
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