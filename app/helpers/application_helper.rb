module ApplicationHelper
  include Pagy::Frontend

  def show_errors object, field_name
    return unless object.errors.any? &&
                  object.errors.messages[field_name].present?

    object.errors.messages[field_name].map do |msg|
      I18n.t("errors.format", attribute: field_name.to_s.humanize, message: msg)
    end.join(", ")
  end

  def image_with_fallback record, attachment_name, default_url, css_class
    if record.send(attachment_name).attached?
      image_tag url_for(record.send(attachment_name)), class: css_class
    else
      image_tag default_url, class: css_class
    end
  end

  def user_owns_post? current_user, post
    current_user.posts.find_by(id: post.id)
  end
end
