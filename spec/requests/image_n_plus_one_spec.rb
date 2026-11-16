require 'rails_helper'

# Sentry "N+1 Query: SELECT active_storage_variant_records ..." (~300 events/week) on
# the post feeds. Every `variant(...).processed` looks up its variant record; unless
# the records are preloaded that is one query per image. Prosopite (spec/support)
# raises on the repeat, so these examples fail while a feed is N+1.
RSpec.describe 'Image variants on feeds', type: :request do
  let(:category) { create(:category) }
  let!(:posts) do
    create_list(:user, 3, :creator).map do |author|
      author.avatar.attach(io: file_fixture('valid_image.png').open, filename: 'avatar.png', content_type: 'image/png')
      create(:post, :with_image, user: author, status: :published, categories: [category])
    end
  end

  it 'renders the post feed without a variant lookup per image' do
    get posts_path

    expect(response).to have_http_status(:success)
  end

  it 'renders a category feed without a variant lookup per image' do
    get category_path(category)

    expect(response).to have_http_status(:success)
  end

  it 'renders a post page and its "more from the author" cards without a lookup per card' do
    more = create_list(:post, 3, :with_image, user: posts.first.user, status: :published)

    get post_path(posts.first)

    expect(response).to have_http_status(:success)
    expect(response.body).to include(*more.map { |post| ERB::Util.html_escape(post.title) })
  end
end
