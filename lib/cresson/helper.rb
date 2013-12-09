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
  end
end
