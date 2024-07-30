class PostsController < ApplicationController
  before_action :logged_in_user, only: :create
  before_action :find_post_by_id, only: %i(edit update destroy)

  def new
    @post = Post.new
  end

  def edit; end

  def index
    @post_items = Post.newest
    @pagy, @post_items = pagy @post_items, limit: Settings.posts.per_page
  end

  def update
    if @post.update post_params
      flash[:success] = t "posts.edit.success"
      redirect_to posts_path
    else
      flash[:danger] = t "posts.edit.fail"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @post.destroy
      flash[:success] = t "posts.destroy.success"
    else
      flash[:danger] = t "posts.destroy.success"
    end
    redirect_to posts_path, status: :see_other
  end

  def create
    @post = current_user.posts.build(post_params)
    @post.content_url.attach(params[:post][:content_url])
    if @post.save
      flash[:success] = t "posts.success"
      redirect_to posts_path
    else
      flash[:danger] = t "posts.fail"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(Post::UPDATABLE_ATTRS)
  end

  def find_post_by_id
    @post = Post.find_by id: params[:id]

    return if @post

    flash[:warning] = t "posts.find_fail"
    render :edit, status: :unprocessable_entity
  end
end
