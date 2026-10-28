require 'rails_helper'

RSpec.describe 'Categories', type: :request do
  include_context 'base'

  describe 'GET /categories (Index)' do
    let!(:categories) do
      create_list(:category, 3).each do |category|
        category.cover_image.attach(io: file_fixture('valid_image.jpg').open, filename: 'cover.jpg', content_type: 'image/jpeg')
        # Pretend the variant is already processed so the spec doesn't need libvips
        variation = category.cover_image.variant(resize_to_fill: [400, 300], format: :webp).variation
        category.cover_image.blob.variant_records.create!(variation_digest: variation.digest)
      end
    end

    before do
      current_user.preferred_categories << categories.first
      sign_in current_user
    end

    it 'does not run per-category queries for variants or follow state' do
      sql = queries_during { get categories_path }

      expect(response).to have_http_status(:success)
      expect(sql.grep(/FROM "active_storage_variant_records" WHERE/).size).to eq(1)
      expect(sql.grep(/INNER JOIN "category_preferences"/)).to be_empty
    end

    it 'shows the followed state for each category' do
      get categories_path

      expect(response.body.scan('name="_method" value="delete"').size).to eq(1)
    end
  end

  describe 'GET /categories/:id (Show)' do
    let(:category) { create(:category, name: 'productivity') }

    before do
      create_list(:user, 3, :creator).each do |creator|
        creator.avatar.attach(io: file_fixture('valid_image.jpg').open, filename: 'avatar.jpg', content_type: 'image/jpeg')
        variation = creator.avatar.variant(resize_to_fill: [80, 80], format: :webp).variation
        creator.avatar.blob.variant_records.create!(variation_digest: variation.digest)
      end
    end

    it 'does not run per-creator queries for avatar variants' do
      sql = queries_during { get category_path(category) }

      expect(response).to have_http_status(:success)
      expect(sql.grep(/FROM "active_storage_variant_records" WHERE/).size).to eq(1)
    end
  end

  describe 'category URLs' do
    let!(:multi_word) { create(:category, name: 'Web Development') }
    let!(:cyrillic) { create(:category, name: 'Подорожі') }

    it 'builds readable slugs from the name' do
      expect(category_path(multi_word)).to eq('/categories/web-development')
      expect(category_path(cyrillic)).to eq('/categories/podorozhi')
    end

    it 'opens categories with multi-word and cyrillic names' do
      [multi_word, cyrillic].each do |category|
        get category_path(category)

        expect(response).to have_http_status(:success)
      end
    end

    it 'redirects back for an unknown category' do
      get category_path('missing')

      expect(response).to redirect_to(posts_path)
    end

    it 'lets a user follow a multi-word category' do
      sign_in current_user

      expect { post category_preference_path(multi_word) }
        .to change { current_user.preferred_categories.reload.include?(multi_word) }.from(false).to(true)
    end
  end

  def queries_during(&)
    sql = []
    callback = ->(*, payload) { sql << payload[:sql] unless payload[:name] == 'SCHEMA' }
    ActiveSupport::Notifications.subscribed(callback, 'sql.active_record', &)
    sql
  end
end
