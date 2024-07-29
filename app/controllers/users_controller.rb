class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def index
    @users = User.all
  end

  def create
    @user = User.new(user_params)
    if @user.save
      reset_session
      log_in @user
      flash[:success] = t "users.create.success"
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "users.not_found"
    redirect_to root_path
  end

  private

  def user_params
    params.require(:user).permit(User::UPDATABLE_ATTRS)
  end
end
