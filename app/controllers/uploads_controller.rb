# Images inserted into a post body by the editor. Only web images are stored: the
# type is read from the file's content (the client's claim is not trusted) and the
# size is capped like a cover image's.
class UploadsController < ApplicationController
  ALLOWED_TYPES = %w[image/png image/jpeg image/gif image/webp].freeze
  MAX_SIZE = 5.megabytes

  before_action :authenticate_user!

  def create
    image = params[:image]
    error = rejection_for(image)
    return render(json: { error: error }, status: :unprocessable_entity) if error

    blob = ActiveStorage::Blob.create_and_upload!(io: image.tempfile, filename: image.original_filename,
                                                  content_type: content_type_of(image))
    render json: { url: url_for(blob) }
  end

  private

  def rejection_for(image)
    return t('attachments.editor_image.type') unless image.respond_to?(:tempfile)
    return t('attachments.editor_image.type') unless ALLOWED_TYPES.include?(content_type_of(image))

    t('attachments.editor_image.large') if image.size > MAX_SIZE
  end

  def content_type_of(image)
    @content_type_of ||= Marcel::MimeType.for(image.tempfile, name: image.original_filename)
  end
end
