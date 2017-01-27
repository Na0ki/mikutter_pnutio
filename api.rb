# -*- coding: utf-8 -*-

## い つ も の
require 'net/https'
require 'json'
require 'uri'
module Plugin::Pnutio
    module API
        def get(endpoint)
            res = Net::HTTP.get URI.parse('https://api.pnut.io/v0/'+endpoint)
            JSON.parse(res)
        end
        def get_with_auth(endpoint)
            uri = URI.parse('https://api.pnut.io/v0/'+endpoint)
            https = Net::HTTP.new uri.host, uri.port
            https.use_ssl = true
            req = Net::HTTP::Get.new uri.request_uri
            req["Authorization"]="Bearer "+UserConfig[:pnutio_access_token]
            res = https.request(req)
            JSON.parse(res.body)
        end
        def post(endpoint, params)
            res = Net::HTTP.post_form URI.parse('https://api.pnut.io/v0/'+endpoint), params
            JSON.parse(res.body)
        end
        def post_with_auth(endpoint,params)
            uri = URI.parse('https://api.pnut.io/v0/'+endpoint)
            https = Net::HTTP.new uri.host, uri.port
            https.use_ssl = true
            req = Net::HTTP::Post.new uri.request_uri
            req.set_form_data(params)
            req["Authorization"]="Bearer "+UserConfig[:pnutio_access_token]
            res = https.request(req)
            JSON.parse(res.body)
        end
        def put_with_auth(endpoint,params={})
            uri = URI.parse('https://api.pnut.io/v0/'+endpoint)
            https = Net::HTTP.new uri.host, uri.port
            https.use_ssl = true
            req = Net::HTTP::Put.new uri.request_uri
            req.set_form_data(params)
            req["Authorization"]="Bearer "+UserConfig[:pnutio_access_token]
            res = https.request(req)
            JSON.parse(res.body)
        end
        def delete_with_auth(endpoint,params={})
            uri = URI.parse('https://api.pnut.io/v0/'+endpoint)
            https = Net::HTTP.new uri.host, uri.port
            https.use_ssl = true
            req = Net::HTTP::Delete.new uri.request_uri
            # req.set_form_data(params)
            req["Authorization"]="Bearer "+UserConfig[:pnutio_access_token]
            res = https.request(req)
            JSON.parse(res.body)
        end

        module_function :get,:get_with_auth,:post, :post_with_auth, :put_with_auth, :delete_with_auth
    end
end