class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params.dig(:session, :email)&.downcase
    check_save user
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url, status: :see_other
  end

  private
  def check_save user
    if user&.authenticate(params[:session][:password])
      reset_session
      log_in user
      flash[:success] = t "login.success"
      redirect_to root_path
    else
      flash.now[:danger] = t "login.failed"
      render :new, status: :unprocessable_entity
    end
  end
end
