class FollowsController < ApplicationController
  before_action :logged_in_user

  def create
    @user = User.find(params[:followee_id])
    @posts = @user.posts.newest
    @pagy, @post_items = pagy @posts, limit: Settings.posts.per_page
    current_user.follow(@user)
    respond_to do |format|
      format.html{redirect_to @user}
      format.turbo_stream
    end
  end

  def destroy
    @user = Follow.find(params[:id]).followee
    current_user.unfollow(@user)
    respond_to do |format|
      format.html{redirect_to @user, status: :see_other}
      format.turbo_stream
    end
  end
end
