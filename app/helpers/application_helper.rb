module ApplicationHelper
  include Pagy::Frontend

  def show_errors object, field_name
    return unless object.errors.any? &&
                  object.errors.messages[field_name].present?

    object.errors.messages[field_name].join(", ")
  end
end
