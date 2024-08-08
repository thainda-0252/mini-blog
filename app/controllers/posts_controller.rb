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
    file = params[:file]
    if file.present?
      check_file file
    else
      flash[:danger] = t "posts.import.fail"
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

  def import_posts_from_file file
    spreadsheet = Roo::Spreadsheet.open(file.path)
    spreadsheet.row(1)
    post_params_list = []

    (2..spreadsheet.last_row).each do |i|
      row = spreadsheet.row(i)
      post_params = {
        user_id: current_user.id,
        caption: row[2],
        content_url: row[3],
        status: row[4],
        created_at: row[5]
      }
      post_params_list << post_params
    end

    Post.insert_all(post_params_list)
    post_params_list.each do |params|
      download_and_attach_image(params) if params[:content_url].present?
    end
  end

  def download_and_attach_image params
    post = find_post(params)
    return unless post

    file = download_image(params[:content_url])
    return unless file

    attach_file_to_post(post, file, params[:content_url])
  end

  def find_post params
    Post.find_by(user_id: params[:user_id], created_at: params[:created_at])
  end

  def download_image content_url
    return if content_url.blank?

    URI.parse(content_url).open
  rescue OpenURI::HTTPError => e
    log_error("posts.errors.download_image_failed", content_url, e)
    nil
  rescue StandardError => e
    log_error("posts.errors.general_error", nil, e)
    nil
  end

  def attach_file_to_post post, file, content_url
    filename = File.basename(URI.parse(content_url).path)
    post.content_url.attach(io: file, filename:)
  end

  def log_error key, url, error
    message = I18n.t(key, url:, message: error.message)
    Rails.logger.error(message)
  end
end
