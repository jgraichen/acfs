# frozen_string_literal: true

module Acfs::Collections
  module Paginatable
    extend ActiveSupport::Concern

    included do
      def self.operation(_action, **opts, &)
        opts[:url]
      end

      attr_reader :total_pages, :current_page, :total_count
    end

    def process_response(response)
      setup_params response.request.params if response.request
      setup_headers response.headers
    end

    def next_page(&)
      page('next', &)
    end

    def prev_page(&)
      page('prev', &)
    end

    def first_page(&)
      page('first', &)
    end

    def last_page(&)
      page('last', &)
    end

    def page(rel, &)
      return unless relations[rel]

      @resource_class.all(nil, url: relations[rel], &)
    end

    private

    def relations
      @relations ||= {}
    end

    def setup_headers(headers)
      if headers['X-Total-Pages']
        @total_pages = Integer(headers['X-Total-Pages'])
      end

      if headers['X-Total-Count']
        @total_count = Integer(headers['X-Total-Count'])
      end

      setup_links headers['Link'] if headers['Link']
    end

    def setup_links(links)
      links.split(/,\s+/).each do |link|
        if link =~ /^\s*<([^>]+)>.*\s+rel="([\w_-]+)".*$/
          relations[Regexp.last_match[2]] = Regexp.last_match[1]
        end
      end
    end

    def setup_params(params)
      @current_page = begin
        Integer params.fetch(:page, 1)
      rescue ArgumentError
        params[:page]
      end
    end
  end
end
