class V1::FollowsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :logged_in_user

  def create
    @user = User.find_by(id: params[:followee_id])

    if @user
      if current_user.following?(@user)
        render json: {success: false,
                      message: I18n.t("follows.create.already_followed")},
               status: :unprocessable_entity
      elsif current_user.follow(@user)
        render json: {success: true, message: I18n.t("follows.create.success"),
                      user: UserSerializer.new(@user)}, status: :created
      else
        render json: {success: false, message: I18n.t("follows.create.fail")},
               status: :unprocessable_entity
      end
    else
      render json: {success: false,
                    message: I18n.t("follows.create.user_not_found")},
             status: :not_found
    end
  end

  def destroy
    follow = Follow.find_by(id: params[:id])
    if follow && current_user.unfollow(follow.followee)
      render json: {success: true, message: I18n.t("follows.destroy.success"),
                    user: UserSerializer.new(follow.followee)}, status: :ok
    else
      render json: {success: false, message: I18n.t("follows.destroy.fail")},
             status: :unprocessable_entity
    end
  end
end
