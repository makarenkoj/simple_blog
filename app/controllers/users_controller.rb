class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[show edit update destroy]
  before_action :set_current_user, only: %i[show edit update destroy]

  def show
    @user = User.find(params[:id])
    render Users::ShowView.new(view_context: view_context, user: @user)
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

  private

  def set_current_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
