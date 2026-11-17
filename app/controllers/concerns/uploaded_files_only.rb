# Attachments are accepted only as uploaded files, whose type the server reads from the
# bytes. Any other value would be resolved as a signed blob id: a blob the client may have
# registered with a self-declared content type, or another user's file (which would then be
# purged when this record replaces it). See SAM1-23.
module UploadedFilesOnly
  extend ActiveSupport::Concern

  private

  def uploaded_files_only(attributes, *keys)
    keys.each do |key|
      next unless attributes.key?(key)

      attributes.delete(key) unless attributes[key].is_a?(ActionDispatch::Http::UploadedFile)
    end
    attributes
  end
end
