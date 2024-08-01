class UserSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :username, :profile_picture, :email

  def profile_picture
    return unless object.profile_picture.attached?

    rails_blob_url(object.profile_picture,
                   only_path: true)
  end
end
