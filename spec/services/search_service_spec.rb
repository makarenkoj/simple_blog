require 'rails_helper'

RSpec.describe SearchService do
  include_context 'base'

  let!(:other_user) { create(:user, first_name: 'Jane', last_name: 'Smith') }
  let!(:ruby_category) { create(:category, name: 'Ruby on Rails') }
  let!(:react_category) { create(:category, name: 'React Development') }
  let!(:published_post) { create(:post, status: :published, title: 'The Ultimate Ruby Guide', user: other_user) }
  let!(:my_draft) { create(:post, status: :draft, title: 'My Secret Guide', user: current_user) }
  let!(:other_draft) { create(:post, status: :draft, title: 'Top Secret Guide by Jane', user: other_user) }

  describe '#call' do
    context 'when the request is empty or too short' do
      it 'returns empty results for an empty query' do
        service = described_class.new(query: '')
        results = service.call

        expect(results[:total_count]).to eq(0)
        expect(results[:posts]).to be_empty
        expect(results[:users]).to be_empty
        expect(results[:categories]).to be_empty
      end

      it 'returns empty results for a query with 1 character' do
        service = described_class.new(query: 'a')
        expect(service.call[:total_count]).to eq(0)
      end
    end

    context 'Search posts and check privacy' do
      it 'Guest (without current_user) sees ONLY published posts' do
        service = described_class.new(query: 'Guide', current_user: nil)
        results = service.call

        expect(results[:posts]).to include(published_post)
        expect(results[:posts]).not_to include(my_draft)
        expect(results[:posts]).not_to include(other_draft)
      end

      it 'Authorized user sees published posts AND their own drafts, but NOT others\' drafts' do
        service = described_class.new(query: 'Guide', current_user: current_user)
        results = service.call

        expect(results[:posts]).to include(published_post)
        expect(results[:posts]).to include(my_draft)
        expect(results[:posts]).not_to include(other_draft)
      end

      it 'finds posts by text in the body (ActionText)' do
        post_with_body = create(:post, status: :published, title: 'Regular title', body: 'This is a magical unicorn post')

        service = described_class.new(query: 'unicorn', current_user: nil)
        expect(service.call[:posts]).to include(post_with_body)
      end
    end

    context 'Search users' do
      it 'finds users by name, last name, username or email' do
        aggregate_failures do
          expect(described_class.new(query: 'Yura').call[:users]).to include(current_user)
          expect(described_class.new(query: 'makarenkoj').call[:users]).to include(current_user)
          expect(described_class.new(query: 'Makarenko').call[:users]).to include(current_user)
          expect(described_class.new(query: 'makarenkoj53@gmail.com').call[:users]).to include(current_user)
          expect(described_class.new(query: 'Jane').call[:users]).to include(other_user)
        end
      end
    end

    context 'Search categories' do
      it 'finds categories by name' do
        service = described_class.new(query: 'Ruby')
        results = service.call

        expect(results[:categories]).to include(ruby_category)
        expect(results[:categories]).not_to include(react_category)
      end
    end

    context 'Using scope' do
      it 'finds only posts if scope: :posts' do
        service = described_class.new(query: 'Guide', scope: :posts, current_user: current_user)
        results = service.call

        expect(results[:posts]).to be_present
        expect(results[:users]).to be_empty
        expect(results[:categories]).to be_empty
      end

      it 'finds only users if scope: :users' do
        service = described_class.new(query: 'Yura', scope: :users)
        results = service.call

        expect(results[:users]).to include(current_user)
        expect(results[:posts]).to be_empty
      end
    end

    context 'Using limits' do
      before do
        create_list(:post, 3, status: :published, title: 'Ruby Limit Test')
      end

      it 'returns no more posts than specified in the limit' do
        service = described_class.new(query: 'Limit', limit: 2)
        results = service.call

        expect(results[:posts].size).to eq(2)
      end
    end
  end
end
