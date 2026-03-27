class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[show edit update destroy current_profile]
  before_action :set_current_user, only: %i[show edit update destroy delete_avatar]
  skip_before_action :verify_authenticity_token, only: [:update_fcm_token]

  def show
    @user = User.friendly.find(params[:id])
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: I18n.t('controllers.users.updated')
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to posts_url, notice: I18n.t('controllers.users.destroyed')
  end

  def delete_avatar
    if @user == current_user
      @user.avatar.purge
      redirect_back fallback_location: user_path(@user), notice: t('flash.avatar_removed', default: 'Avatar was successfully removed.')
    else
      redirect_back fallback_location: user_path(@user), alert: t('flash.not_authorized', default: 'You are not authorized to perform this action.')
    end
  end

  def current_profile
    redirect_to user_path(current_user)
  end

  def update_fcm_token
    if current_user
      save_fcm_token(params[:token])

      render json: { status: 'ok', message: 'Token saved' }
    else
      render json: { error: 'Not logged in' }, status: :unauthorized
    end
  end

  private

  def set_current_user
    @user = User.friendly.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :avatar, preferred_category_ids: [])
  end

  def save_fcm_token(token)
    return if token.blank?
    return if current_user.fcm_token == token

    User.transaction do
      User.where(fcm_token: token).where.not(id: current_user.id).each { |user| user.update(fcm_token: nil) }
      current_user.update(fcm_token: token)
    end
  end
end
