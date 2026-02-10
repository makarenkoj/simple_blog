class FollowsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_follower

  def create
    if current_user.follow(@follower)
      success_create
    else
      failed_create
    end
  end

  def destroy
    if current_user.unfollow(@follower)
      success_destroy
    else
      failed_destoy
    end
  end

  private

  def set_follower
    @follower = User.friendly.find(params[:id])
    redirect_to root_path, alert: t('follows.user_not_found') unless @follower
  end

  def success_create
    flash.now[:notice] = t('follows.created', username: @follower.username)
    respond_to do |format|
      format.html { redirect_to @follower, notice: t('follows.created', username: @follower.username) }
      format.turbo_stream
    end
  end

  def failed_create
    respond_to do |format|
      format.html { redirect_to @follower, alert: t('follows.error') }
      format.turbo_stream do
        flash.now[:alert] = t('follows.error')
        render turbo_stream: turbo_stream.prepend('flash_messages', partial: 'partials/flash_message', locals: { type: :alert, message: flash.now[:alert] })
      end
    end
  end

  def success_destroy
    respond_to do |format|
      format.html { redirect_to @follower, notice: t('follows.destroyed', username: @follower.username) }
      flash.now[:notice] = t('follows.destroyed', username: @follower.username)
      format.turbo_stream
    end
  end

  def failed_destoy
    respond_to do |format|
      format.html { redirect_to @follower, alert: t('follows.error') }
      format.turbo_stream do
        flash.now[:alert] = t('follows.unfollow_error')
        render turbo_stream: turbo_stream.prepend('flash_messages', partial: 'partials/flash_message', locals: { type: :alert, message: flash.now[:alert] })
      end
    end
  end
end
