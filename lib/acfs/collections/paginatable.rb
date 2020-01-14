# frozen_string_literal: true

module Acfs::Collections
  module Paginatable
    extend ActiveSupport::Concern

    included do
      def self.operation(_action, opts = {}, &_block)
        opts[:url]
      end

      attr_reader :total_pages, :current_page, :total_count
    end

    def process_response(response)
      setup_params response.request.params if response.request
      setup_headers response.headers
    end

    def next_page(&block)
      page 'next', &block
    end

    def prev_page(&block)
      page 'prev', &block
    end

    def first_page(&block)
      page 'first', &block
    end

    def last_page(&block)
      page 'last', &block
    end

    def page(rel, &block)
      return unless relations[rel]

      @resource_class.all nil, url: relations[rel], &block
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
