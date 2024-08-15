class V1::UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :logged_in_user, only: :index

  def index
    @q = User.ransack(search_params)
    @users = @q.result(distinct: true)
    @pagy, @user_items = pagy(@users, limit: Settings.users.per_page)

    render_users(@user_items, @pagy)
  rescue Pagy::OverflowError
    render json: {error: I18n.t("user.search.out_of_range")},
           status: :bad_request
  end

  private

  def search_params
    {
      username_cont: params[:username],
      email_cont: params[:email],
      created_at_gteq: params[:created_after],
      created_at_lteq: params[:created_before]
    }.compact
  end

  def render_users user_items, pagy
    render json: {
      users: user_items.map{|user| UserSerializer.new(user)},
      pagination: {
        count: pagy.count,
        page: pagy.page,
        pages: pagy.pages,
        next: pagy.next,
        prev: pagy.prev
      }
    }
  end
end
