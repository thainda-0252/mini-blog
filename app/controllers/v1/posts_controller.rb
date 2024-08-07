class V1::PostsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :logged_in_user, only: %i(create feed)
  before_action :find_post_by_id, only: :update

  def create
    @post = current_user.posts.build(post_params)
    @post.content_url.attach(params[:post][:content_url])
    if @post.save
      render json: {success: true, message: I18n.t("posts.success"),
                    post: PostSerializer.new(@post)}, status: :created
    else
      render json: {success: false, message: I18n.t("posts.fail"),
                    errors: @post.errors.full_messages},
             status: :unprocessable_entity
    end
  end

  def feed
    post_items, pagy = fetch_feed_posts
    render json: build_feed_response(post_items, pagy), status: :ok
  end

  def update
    if @post.update(post_params)
      render json: {success: true, message: I18n.t("posts.edit.success"),
                    post: PostSerializer.new(@post)}, status: :ok
    else
      render json: {success: false, message: I18n.t("posts.edit.fail"),
                    errors: @post.errors.full_messages},
             status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(Post::UPDATABLE_ATTRS)
  end

  def find_post_by_id
    @post = current_user.posts.find_by(id: params[:id])
    return if @post

    render json: {success: false, message: I18n.t("posts.find_fail")},
           status: :not_found
  end

  def fetch_feed_posts
    following_ids = current_user.following.pluck(:id)
    post_items = Post.feed(following_ids + [current_user.id]).newest
    pagy, post_items = pagy(post_items, limit: Settings.posts.per_page)
    [post_items, pagy]
  end

  def build_feed_response post_items, pagy
    {
      posts: post_items.map{|post| PostSerializer.new(post)},
      pagination: {
        total_posts: pagy.count,
        current_page: pagy.page,
        total_pages: pagy.pages,
        prev: pagy.prev,
        next: pagy.next,
        last: pagy.last
      }
    }
  end
end
