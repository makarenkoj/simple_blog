require 'rails_helper'

# Production, 2026-11-10: an SVG built to make an image processor read local files was
# registered through Active Storage direct uploads declared as image/png, then offered as
# an avatar by its signed id. The declared type passed validation. Files must come in as
# uploads, so the server judges their type from the bytes.
RSpec.describe 'Blob injection', type: :request do
  include_context 'base'

  # A blob registered the direct-upload way: the client declares the type, the server never reads the bytes.
  let(:disguised_svg) do
    io = file_fixture('image.svg').open
    ActiveStorage::Blob.create_before_direct_upload!(
      filename: 'avatar.png', byte_size: io.size, content_type: 'image/png',
      checksum: OpenSSL::Digest::MD5.file(io.path).base64digest
    ).tap { |blob| blob.upload_without_unfurling(io) }
  end

  before { sign_in current_user }

  it 'does not offer direct uploads' do
    post '/rails/active_storage/direct_uploads',
         params: { blob: { filename: 'avatar.png', byte_size: 230, checksum: 'x', content_type: 'image/png' } },
         as: :json

    expect(response).to have_http_status(:not_found)
    expect(ActiveStorage::Blob.count).to eq(0)
  end

  it 'ignores a signed blob id submitted as the avatar' do
    put user_registration_path, params: { user: { avatar: disguised_svg.signed_id, first_name: 'Yura' } }

    expect(current_user.reload.avatar).not_to be_attached
  end

  it 'ignores a signed blob id submitted as a post cover' do
    post_record = create(:post, user: current_user)
    patch post_path(post_record), params: { post: { cover_image: disguised_svg.signed_id } }

    expect(post_record.reload.cover_image).not_to be_attached
  end

  it "cannot take over another user's avatar file by its signed id" do
    other = create(:user, avatar: fixture_file_upload('valid_image.png', 'image/png'))
    put user_registration_path, params: { user: { avatar: other.avatar.blob.signed_id } }

    expect(current_user.reload.avatar).not_to be_attached
    expect(other.reload.avatar).to be_attached
  end
end
