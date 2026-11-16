require 'rails_helper'

RSpec.describe UploadedBlobsAudit do
  include_context 'base'

  def upload(fixture, content_type)
    ActiveStorage::Blob.create_and_upload!(io: file_fixture(fixture).open, filename: fixture,
                                           content_type: content_type)
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

  it 'reports an orphan that nothing uses' do
    upload('image.svg', 'image/svg+xml')

    expect(findings.sole).to have_attributes(attachments: [], posts: [])
  end
end
