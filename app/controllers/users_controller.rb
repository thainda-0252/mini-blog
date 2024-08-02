class UsersController < ApplicationController
  before_action :logged_in_user, only: %i(index show)

  def new
    @user = User.new
  end

  def index
    @users = User.all
  end

  def create
    @user = User.new(user_params)
    @user.profile_picture.attach(params[:user][:profile_picture])
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
    @posts = @user.posts.newest
    @pagy, @post_items = pagy(@posts, limit: Settings.posts.per_page)
    return if @user

    flash[:danger] = t "users.not_found"
    redirect_to root_path
  end
  private

  def user_params
    params.require(:user).permit(User::UPDATABLE_ATTRS)
  end
end
