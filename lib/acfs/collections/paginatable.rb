module Acfs::Collections
  module Paginatable
    def total_pages
      @total_pages
    end

    def current_page
      @current_page
    end

    def setup_pagination(params, header)
      @current_page = Integer(params.fetch(:page, 1)) rescue params[:page]
      @total_pages  = Integer(header['X-Total-Pages']) if header['X-Total-Pages']
    end
  end
end
