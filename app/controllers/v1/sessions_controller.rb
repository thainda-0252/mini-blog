class V1::SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    user = User.find_by(email: params.dig(:login, :email)&.downcase)
    if user&.authenticate(params.dig(:login, :password))
      reset_session
      log_in user
      render json: {success: true, message: I18n.t("login.success"),
                    user: ActiveModelSerializers::SerializableResource
                      .new(user, serializer: UserSerializer)}, status: :ok
    else
      render json: {success: false, message: I18n.t("login.failed")},
             status: :unauthorized
    end
  end
end
