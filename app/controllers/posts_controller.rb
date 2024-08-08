class PostsController < ApplicationController
  before_action :logged_in_user, only: %i(create index feed)
  before_action :find_post_by_id, only: %i(edit update destroy)

  def new
    @post = Post.new
  end

  def edit; end

  def show
    @post = Post.find_by id: params[:id]
    return if @post

    flash[:danger] = t "posts.not_found"
    redirect_to root_path
  end

  def index
    @post_items = Post.newest.viewable_by(current_user)
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
      flash[:danger] = t "posts.destroy.fail"
    end
    redirect_to posts_path, status: :see_other
  end

  def create
    @post = current_user.posts.build(post_params)
    @post.content_url.attach(params[:post][:content_url])
    if @post.save
      flash[:success] = t "posts.success"
      redirect_to root_path
    else
      flash[:danger] = t "posts.fail"
      render :new, status: :unprocessable_entity
    end
  end

  def feed
    following_ids = current_user.following.pluck(:id)
    @post_items = Post.feed(following_ids + [current_user.id]).newest
    @pagy, @post_items = pagy(@post_items, limit: Settings.posts.per_page)
  end

  def export
    @posts = Post.newest

    respond_to do |format|
      format.html
      format.xlsx do
        response.headers["Content-Disposition"] =
          "attachment; filename=posts.xlsx"
      end
    end
  end

  def import
    if params[:file].present?
      handle_file_import
    else
      flash[:danger] = t("posts.import.fail")
    end

    redirect_to root_path
  end

  private

  def post_params
    params.require(:post).permit(Post::UPDATABLE_ATTRS)
  end

  def check_file file
    type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    valid_extension = ".xlsx"

    if file.content_type == type ||
       file.original_filename.ends_with?(valid_extension)
      import_posts_from_file(file)
      flash[:success] = t("posts.import.success")
    else
      flash[:danger] = t("posts.import.invalid_file_type")
    end
  end

  def find_post_by_id
    @post = Post.find_by id: params[:id]

    return if @post

    flash[:warning] = t "posts.find_fail"
    render :edit, status: :unprocessable_entity
  end

  def handle_file_import
    service = ImportPostsService.new(params[:file], current_user)
    result = service.import
    if result
      handle_import_success(result)
    else
      handle_import_failure(service)
    end
  end

  def handle_import_success result
    flash[:success] = t("posts.import.success")
    flash[:warning] = result[:errors]
  end

  def handle_import_failure service
    flash[:danger] = service.error_message
  end
end
