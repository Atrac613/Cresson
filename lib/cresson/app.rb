# coding: utf-8

require 'sinatra'
require 'jekyll'
require 'json'

require 'cresson/helper'

module Cresson
  class App < Sinatra::Base
    get '/' do
      'Hello'
    end

    get '/api/v1/get_posts' do
      posts = []
      jekyll_site.posts.each do |row|
        posts.push({
	  :title => row.title,
	  :path => row.path,
	  :date => row.date
	})
      end

      content_type :json
      posts.to_json
    end
  end
end
