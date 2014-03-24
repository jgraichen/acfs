module Acfs::Collections
  module Paginatable
    extend ActiveSupport::Concern

    included do
      def self.operation(action, opts = {}, &block)
        opts[:url]
      end
    end

    def total_pages
      @total_pages
    end

    def current_page
      @current_page
    end

    def process_response(response)
      setup_params response.request.params if response.request
      setup_headers response.headers
    end

    def next_page
      page 'next'
    end

    def prev_page
      page 'prev'
    end

    def first_page
      page 'first'
    end

    def last_page
      page 'last'
    end

    def page(rel)
      if relations[rel]
        @resource_class.all nil, url: relations[rel]
      else
        raise ArgumentError.new "No relative page `#{rel}'."
      end
    end

    private
    def relations
      @relations ||= {}
    end

    def setup_headers(headers)
      @total_pages  = Integer(headers['X-Total-Pages']) if headers['X-Total-Pages']

      setup_links headers['Link'] if headers['Link']
    end

    def setup_links(links)
      links.split(/,\s+/).each do |link|
        if link =~ /^\s*<([^>]+)>.*\s+rel="([\w_-]+)".*$/
          relations[$2] = $1
        end
      end
    end

    def setup_params(params)
      @current_page = Integer(params.fetch(:page, 1)) rescue params[:page]
    end
  end
end
