# coding: utf-8

module Cresson
  class App < Sinatra::Base
    def jekyll_site
      if not @site
        config = Jekyll.configuration({'source' => settings.repo_src})
        @site = Jekyll::Site.new(config)
	@site.read
      end

      @site
    end

    def jekyll_post(post_file)
      Jekyll::Post.new(jekyll_site, jekyll_site.source, '', post_file)
    end

    def post_exists?(post_file)
      File.exists? post_path(post_file)
    end

    def post_path(post_file)
      File.join(jekyll_site.source, *%w[_posts], post_file)
    end
  end
end
