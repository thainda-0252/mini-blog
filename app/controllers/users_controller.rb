class UsersController < ApplicationController
  before_action :logged_in_user, only: %i(index show)
  before_action :set_user, only: %i(show liked_posts)
  def new
    @user = User.new
  end

  def index
    @q = User.ransack(params[:q])
    @users = @q.result(distinct: true)
    @pagy, @user_items = pagy(@users, limit: Settings.users.per_page)
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
    @posts = @user.posts.newest
    @pagy, @post_items = pagy @posts, limit: Settings.posts.per_page
    return if @user

    flash[:danger] = t "users.not_found"
    redirect_to root_path
  end

  def liked_posts
    @post_items = @user.liked_posts.newest
    @pagy, @post_items = pagy(@post_items, limit: Settings.posts.per_page)
    render turbo_stream: turbo_stream.replace("posts", partial: "posts_list",
                                              locals: {post_items: @post_items})
  end
  private

  def user_params
    params.require(:user).permit(User::UPDATABLE_ATTRS)
  end

  def set_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "user.not_found"
    redirect_to root_path
  end
end
