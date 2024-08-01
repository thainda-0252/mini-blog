# app/serializers/post_serializer.rb
class PostSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :caption, :content_url, :status, :user_id

  def content_url
    return unless object.content_url.attached?

    rails_blob_url(object.content_url,
                   only_path: true)
  end
end
