class ImportPostsService
  attr_reader :error_message

  def initialize file, current_user
    @file = file
    @current_user = current_user
  end

  def import
    if valid_file?

      result = extract_post_params
      post_params_list = result[:post_params_list]
      errors = result[:errors]
      if post_params_list.empty?
        return {success: false, errors: I18n.t("posts.import.no_data")}
      end

      Post.insert_all(post_params_list)
      post_params_list.each do |params|
        download_and_attach_image(params) if params[:content_url].present?
      end
      {errors:}
    else
      false
    end
  end

  private

  def valid_file?
    type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    valid_extension = ".xlsx"

    if @file.content_type == type ||
       @file.original_filename.ends_with?(valid_extension)
      true
    else
      @error_message = I18n.t("posts.import.invalid_file_type")
      false
    end
  end

  def extract_post_params
    spreadsheet = Roo::Spreadsheet.open(@file.path)
    spreadsheet.row(1) # Assuming this is the header row

    post_params_list = []
    errors = []

    (2..spreadsheet.last_row).each do |i|
      row = spreadsheet.row(i)
      caption = row[2]

      if caption.blank?
        errors << I18n.t("posts.import.missing_caption", row_number: i)
        next
      end

      post_params = {
        user_id: @current_user.id,
        caption:,
        content_url: row[3],
        status: row[4],
        created_at: row[5]
      }

      post_params_list << post_params
    end

    {post_params_list:, errors:}
  end

  def download_and_attach_image params
    post = find_post(params)
    return unless post

    file = download_image(params[:content_url])
    return unless file

    attach_file_to_post(post, file, params[:content_url])
  end

  def find_post params
    Post.find_by(user_id: params[:user_id], created_at: params[:created_at])
  end

  def download_image content_url
    return if content_url.blank?

    URI.parse(content_url).open
  rescue OpenURI::HTTPError => e
    log_error("posts.errors.download_image_failed", content_url, e)
    nil
  rescue StandardError => e
    log_error("posts.errors.general_error", nil, e)
    nil
  end

  def attach_file_to_post post, file, content_url
    filename = File.basename(URI.parse(content_url).path)
    post.content_url.attach(io: file, filename:)
  end

  def log_error key, url, error
    message = I18n.t(key, url:, message: error.message)
    Rails.logger.error(message)
  end
end
