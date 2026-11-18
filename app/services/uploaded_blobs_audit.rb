# Read-only report of stored files that today's upload rules would refuse:
# anything that is not a web image, or is larger than the upload limit.
# Until the editor endpoint was restricted it stored any file, unattached, and
# the only trace of where it is used is its URL inside a post's HTML.
#
# A blob's stored type is only trustworthy when the server identified it from the
# bytes (metadata "identified"). Blobs registered through direct uploads carry the
# client's claim, so their content is read and judged instead (SAM1-23).
class UploadedBlobsAudit
  Finding = Data.define(:blob, :reasons, :attachments, :posts)

  def call
    ActiveStorage::Blob.includes(:attachments).order(:id).filter_map do |blob|
      reasons = reasons_for(blob)
      next if reasons.empty?

      Finding.new(blob: blob, reasons: reasons, attachments: blob.attachments.to_a, posts: posts_embedding(blob))
    end
  end

  private

  def reasons_for(blob)
    reasons = []
    reasons << :type unless web_image?(blob.content_type)
    reasons.concat(content_reasons(blob)) if reasons.empty? && !blob.metadata['identified']
    reasons << :size if blob.byte_size > UploadsController::MAX_SIZE
    reasons
  end

  def content_reasons(blob)
    web_image?(Marcel::MimeType.for(StringIO.new(blob.download))) ? [] : [:disguised]
  rescue ActiveStorage::FileNotFoundError
    [:missing_file]
  end

  def web_image?(content_type)
    UploadsController::ALLOWED_TYPES.include?(content_type)
  end

  # Editor URLs carry the blob's signed id (redirect and proxy routes alike).
  def posts_embedding(blob)
    pattern = "%#{ActiveRecord::Base.sanitize_sql_like(blob.signed_id)}%"
    Post.where('body_html LIKE :p', p: pattern).includes(:user).order(:id).to_a
  end
end
