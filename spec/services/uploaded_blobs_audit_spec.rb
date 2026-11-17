require 'rails_helper'

RSpec.describe UploadedBlobsAudit do
  include_context 'base'

  def upload(fixture, content_type)
    ActiveStorage::Blob.create_and_upload!(io: file_fixture(fixture).open, filename: fixture,
                                           content_type: content_type)
  end

  # The direct-upload path: the record is created from the client's claims, then the bytes
  # are stored without the server ever reading them.
  def direct_upload(fixture, filename:, content_type:)
    io = file_fixture(fixture).open
    blob = ActiveStorage::Blob.create_before_direct_upload!(
      filename: filename, byte_size: io.size, content_type: content_type,
      checksum: OpenSSL::Digest::MD5.file(io.path).base64digest
    )
    blob.upload_without_unfurling(io)
    blob
  end

  def upload_oversized(fixture, content_type)
    padded = file_fixture(fixture).binread + ('0' * UploadsController::MAX_SIZE)
    ActiveStorage::Blob.create_and_upload!(io: StringIO.new(padded), filename: fixture, content_type: content_type)
  end

  def embed_in_post(blob, user:)
    url = Rails.application.routes.url_helpers.rails_blob_path(blob, only_path: true)
    create(:post, user: user, body_html: %(<p>Look</p><img src="#{url}">))
  end

  let(:findings) { described_class.new.call }

  it 'ignores web images within the size limit' do
    upload('valid_image.png', 'image/png')

    expect(findings).to be_empty
  end

  it 'reports a non-image file with the post that embeds it and that post author' do
    svg = upload('image.svg', 'image/svg+xml')
    post = embed_in_post(svg, user: current_user)

    finding = findings.sole
    aggregate_failures do
      expect(finding.blob).to eq(svg)
      expect(finding.reasons).to eq([:type])
      expect(finding.posts).to eq([post])
      expect(finding.posts.map(&:user)).to eq([current_user])
      expect(finding.attachments).to be_empty
    end
  end

  it 'reports a web image over 5 MB' do
    big = upload_oversized('valid_image.png', 'image/png')

    expect(findings.sole).to have_attributes(blob: big, reasons: [:size])
  end

  it 'reports a file that is neither a web image nor small, with both reasons' do
    upload_oversized('image.svg', 'image/svg+xml')

    expect(findings.sole.reasons).to eq(%i[type size])
  end

  it 'reports an attached blob with the record it is attached to' do
    svg = upload('image.svg', 'image/svg+xml')
    attachment = ActiveStorage::Attachment.create!(name: 'avatar', record: current_user, blob: svg)

    expect(findings.sole).to have_attributes(attachments: [attachment], posts: [])
  end

  # Production: SVGs registered through direct uploads as image/png. The server never read
  # them, so their stored type is only the client's claim.
  it 'reports a file whose declared web-image type is contradicted by its content' do
    disguised = direct_upload('image.svg', filename: 'avatar.png', content_type: 'image/png')

    expect(findings.sole).to have_attributes(blob: disguised, reasons: [:disguised])
  end

  it 'reports a blob whose file is missing from storage' do
    blob = ActiveStorage::Blob.create_before_direct_upload!(filename: 'avatar.png', byte_size: 230,
                                                            checksum: 'x', content_type: 'image/png')

    expect(findings.sole).to have_attributes(blob: blob, reasons: [:missing_file])
  end

  it 'trusts an unchecked blob whose content really is a web image' do
    direct_upload('valid_image.png', filename: 'ok.png', content_type: 'image/png')

    expect(findings).to be_empty
  end

  it 'reports an orphan that nothing uses' do
    upload('image.svg', 'image/svg+xml')

    expect(findings.sole).to have_attributes(attachments: [], posts: [])
  end
end
