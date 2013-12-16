# coding: utf-8

require 'sinatra'
require 'jekyll'
require 'json'

require 'cresson/helper'

module Cresson
  class App < Sinatra::Base
    not_found do
      'Error: Bad path.'
    end

    get '/' do
      'Hello'
    end

    get '/api/v1/get_posts' do
      posts = []
      jekyll_site.posts.each do |row|
        posts.push({
	  :title => row.title,
	  :filename => row.name,
	  :date => row.date
	})
      end

      content_type :json
      posts.to_json
    end

    get '/api/v1/get_post/*' do
      filename = params[:splat].first

      if not post_exists?(filename)
        return 404
      end

      post = jekyll_post(filename)

      content_type :json
      post.to_json
    end

  end
end
