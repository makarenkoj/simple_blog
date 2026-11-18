class SearchController < ApplicationController
  # Per IP and minute. Live search sends one turbo-frame request per 300 ms pause in typing,
  # so a person stays far below FRAME_LIMIT. The full results page loads 25 results instead
  # of 5 and is submitted deliberately, so it gets the smaller budget.
  FRAME_LIMIT = 120
  PAGE_LIMIT = 30
  # Counters live in Rails.cache; tests set a real store (their cache is a null store).
  RATE_LIMIT_STORE = Rails.configuration.x.rate_limit_store || Rails.cache

  rate_limit to: FRAME_LIMIT, within: 1.minute, name: 'live', store: RATE_LIMIT_STORE,
             with: -> { render_rate_limited }, only: :index, if: -> { turbo_frame_request? }
  rate_limit to: PAGE_LIMIT, within: 1.minute, name: 'page', store: RATE_LIMIT_STORE,
             with: -> { render_rate_limited }, only: :index, unless: -> { turbo_frame_request? }

  def index
    @query = params[:query].to_s.strip

    if @query.present?
      limit = turbo_frame_request? ? 5 : 25
      results = SearchService.new(query: @query, limit: limit, current_user: current_user).call

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

  private

  def render_rate_limited
    message = t('search.rate_limited')
    body = turbo_frame_request? ? helpers.tag.turbo_frame(message, id: 'search_results') : message
    render html: body, status: :too_many_requests
  end
end
