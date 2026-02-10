class SearchController < ApplicationController
  def index
    @query = params[:query].to_s.strip

    if @query.present?
      limit = turbo_frame_request? ? 5 : 25
      results = SearchService.new(query: @query, limit: limit).call

      @posts = results[:posts]
      @users = results[:users]
      @categories = results[:categories]
      @total_count = results[:total_count]
    else
      @posts = []
      @users = []
      @categories = []
      @total_count = 0
    end

    if turbo_frame_request?
      render partial: 'results',
             locals: { posts: @posts,
                       users: @users,
                       categories: @categories,
                       query: @query }
    else
      respond_to do |format|
        format.html
      end
    end
  end
end
