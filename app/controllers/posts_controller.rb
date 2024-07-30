class PostsController < ApplicationController
  before_action :logged_in_user, only: :create

  def new
    @post = Post.new
  end

  def index
    @post_items = Post.newest
    @pagy, @post_items = pagy(@post_items, limit: Settings.posts.per_page)
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      flash[:success] = t("posts.success")
      redirect_to posts_path
    else
      flash[:danger] = t("posts.fail")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(Post::UPDATABLE_ATTRS)
  end
end
