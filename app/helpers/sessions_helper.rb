module SessionsHelper
  def log_in user
    session[:user_id] = user.id
  end

  def current_user
    return unless (user_id = session[:user_id])

    @current_user ||= User.find_by(id: user_id)
  end

  def logged_in?
    !current_user.nil?
  end

  def log_out
    reset_session
    @current_user = nil
  end

  def current_user? user
    user && user == current_user
  end

  private
  def logged_in_user
    return if logged_in?

    flash[:danger] = t("login.please")
    redirect_to login_url, status: :see_other
  end
end
