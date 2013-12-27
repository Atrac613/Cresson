# coding: utf-8

require 'sinatra'
require 'jekyll'
require 'json'
require 'yaml'
require 'stringex'

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

      data = {
        :title => post.title,
        :content => post.content,
        :filename => post.name,
        :date => post.date
      }

      content_type :json
      data.to_json
    end

    post '/api/v1/create_post' do
      post = create_new_post(params)
      data = { :filename => post }

      content_type :json
      data.to_json
    end

    post '/api/v1/update_post/*' do
      filename = params[:splat].first

      if not post_exists?(filename)
        return 404
      end

      post = update_post(filename, params)

      data = { :filename => post }

      content_type :json
      data.to_json
    end

    get '/api/v1/delete_post/*' do
      filename = params[:splat].first

      if not post_exists?(filename)
        return 404
      end

      file_path = post_path(filename)

      if File.exists? file_path
        File.delete(file_path)
      end

      content_type :json
      { :message => 'successed.' }.to_json
    end

    def create_new_post(params)
      post_title = params[:post][:title]
      post_date = (Time.now).strftime("%Y-%m-%d")

      content = yaml_data(post_title).to_yaml + "---\n" + params[:post][:content]
      post_file = (post_date + " " + post_title).to_url + '.markdown'
      file = File.join(jekyll_site.source, *%w[_posts], post_file)
      File.open(file, 'w') { |file| file.write(content) }

      post_file
    end

    def write_post_contents(content, yaml, post_file)
      writeable_content = yaml.to_yaml + "---\n" + content
      file_path = post_path(post_file)

      if File.exists? file_path
        File.open(file_path, 'w') { |file| file.write(writeable_content)}
      end
    end

    def update_post(filename, params)
      post = jekyll_post(filename)
      yaml_config = merge_config(post.data, params)
      write_post_contents(params[:post][:content], yaml_config, filename)

      filename
    end

    def merge_config(yaml, params)
      if params['post'].has_key? 'yaml'
        params['post']['yaml'].each do |key, value|
          if value == 'true'
            yaml[key] = true
          elsif value == 'false'
            yaml[key] = false
          else
            yaml[key] = value
          end
        end
      end

      yaml
    end

    def yaml_data(post_title)
      defaults = { 'title' => post_title,
        'layout' => 'post',
        'published' => false }

      defaults = defaults.merge(default_yaml())

      defaults
    end

  end
end
