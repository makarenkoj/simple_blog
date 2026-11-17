# Read-only report of stored files that today's upload rules would refuse:
# anything that is not a web image, or is larger than the upload limit.
# Until the editor endpoint was restricted it stored any file, unattached, and
# the only trace of where it is used is its URL inside a post's HTML.
class UploadedBlobsAudit
  Finding = Data.define(:blob, :reasons, :attachments, :posts)

  def call
    suspicious_blobs.map do |blob|
      Finding.new(blob: blob, reasons: reasons_for(blob),
                  attachments: blob.attachments.to_a, posts: posts_embedding(blob))
    end
  end

  private

  def suspicious_blobs
    ActiveStorage::Blob.where.not(content_type: UploadsController::ALLOWED_TYPES)
                       .or(ActiveStorage::Blob.where(content_type: nil))
                       .or(ActiveStorage::Blob.where(byte_size: (UploadsController::MAX_SIZE + 1)..))
                       .includes(:attachments)
                       .order(:id)
  end

  def reasons_for(blob)
    reasons = []
    reasons << :type unless UploadsController::ALLOWED_TYPES.include?(blob.content_type)
    reasons << :size if blob.byte_size > UploadsController::MAX_SIZE
    reasons
  end

  # Editor URLs carry the blob's signed id (redirect and proxy routes alike).
  def posts_embedding(blob)
    pattern = "%#{ActiveRecord::Base.sanitize_sql_like(blob.signed_id)}%"
    Post.where('body_html LIKE :p OR body LIKE :p', p: pattern).includes(:user).order(:id).to_a
  end
end
