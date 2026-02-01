class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[show edit update destroy]
  before_action :set_current_user, only: %i[show edit update destroy]

  def show
    @user = User.find(params[:id])
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
    @user = User.find(params[:id])
    if @user == current_user
      @user.avatar.purge
      redirect_back fallback_location: user_path(@user), notice: t('flash.avatar_removed', default: 'Avatar was successfully removed.')
    else
      redirect_back fallback_location: user_path(@user), alert: t('flash.not_authorized', default: 'You are not authorized to perform this action.')
    end
  end

  private

  def set_current_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :avatar, preferred_category_ids: [])
  end
end
