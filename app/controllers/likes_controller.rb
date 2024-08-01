class LikesController < ApplicationController
  before_action :logged_in_user

  def create
    @post = Post.find_by id: params[:post_id]
    if @post
      current_user.like @post
      respond_to do |format|
        format.html{redirect_to @post}
        format.turbo_stream
      end
    else
      flash[:danger] = t "like.like_fail"
    end
  end

  def destroy
    @like = current_user.likes.find_by id: params[:id]
    if @like
      @post = @like.post
      current_user.unlike @post
      respond_to do |format|
        format.html{redirect_to @post}
        format.turbo_stream
      end
    else
      flash[:danger] = t "like.unlike_fail"
    end
  end
end
