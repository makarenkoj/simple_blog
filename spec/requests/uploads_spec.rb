require 'rails_helper'

RSpec.describe 'Editor image uploads', type: :request do
  include_context 'base'

  before { sign_in current_user }

  it 'stores a web image and returns its URL' do
    expect do
      post uploads_path, params: { image: fixture_file_upload('valid_image.png', 'image/png') }
    end.to change(ActiveStorage::Blob, :count).by(1)

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)['url']).to be_present
    expect(ActiveStorage::Blob.last.byte_size).to eq(file_fixture('valid_image.png').size)
  end

  # Sentry: SVGs reached image processing ("svgload: operation is blocked",
  # "can't transform blob ... image/svg+xml"); the editor endpoint took any file.
  it 'rejects an SVG' do
    expect do
      post uploads_path, params: { image: fixture_file_upload('image.svg', 'image/svg+xml') }
    end.not_to change(ActiveStorage::Blob, :count)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(JSON.parse(response.body)['error']).to be_present
  end

  it 'judges the type by content, not by the type the client declares' do
    expect do
      post uploads_path, params: { image: fixture_file_upload('image.svg', 'image/png') }
    end.not_to change(ActiveStorage::Blob, :count)

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'rejects an image over the size limit' do
    stub_const('UploadsController::MAX_SIZE', 10.bytes)

    post uploads_path, params: { image: fixture_file_upload('valid_image.png', 'image/png') }

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'answers 422 when no file is sent' do
    post uploads_path

    expect(response).to have_http_status(:unprocessable_entity)
  end
end
