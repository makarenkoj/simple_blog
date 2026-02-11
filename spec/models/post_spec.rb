require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { create(:user, :creator) }
  let(:post) { create(:post, user: user) }

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:categorizations).dependent(:destroy) }
    it { should have_many(:categories).through(:categorizations) }
    it { should have_many(:bookmarks).dependent(:destroy) }
    it { should have_many(:likes).dependent(:destroy) }
    it { should have_many(:liking_users).through(:likes).source(:user) }
    it { should have_rich_text(:body) }
    it { should have_one_attached(:cover_image) }
  end

  describe 'validations' do
    context 'title' do
      it { should validate_presence_of(:title) }
      it { should validate_length_of(:title).is_at_least(3) }
      it { should validate_length_of(:title).is_at_most(100) }

      it 'is valid with a title of 3 characters' do
        post = build(:post, title: 'ABC')

        expect(post).to be_valid
      end

      it 'is valid with a title of 100 characters' do
        post = build(:post, title: 'A' * 100)

        expect(post).to be_valid
      end

      it 'is invalid with a title of 2 characters' do
        post = build(:post, title: 'AB')

        expect(post).not_to be_valid
        expect(post.errors[:title].first).to include("занадто короткий (мінімум 3 знаку)")
      end

      it 'is invalid with a title of 101 characters' do
        post = build(:post, title: 'A' * 101)

        expect(post).not_to be_valid
        expect(post.errors[:title].first).to include("занадто довгий (максимум 100 знаку)")
      end

      it 'is invalid without a title' do
        post = build(:post, title: nil)

        expect(post).not_to be_valid
        expect(post.errors[:title].join).to include("не може бути пустимзанадто короткий (мінімум 3 знаку)")
      end

      it 'is invalid with an empty title' do
        post = build(:post, title: '')

        expect(post).not_to be_valid
      end

      it 'is invalid with a whitespace-only title' do
        post = build(:post, title: '   ')

        expect(post).not_to be_valid
      end
    end

    context 'body' do
      it 'is valid with a body of 10 characters' do
        post = build(:post, body: 'A' * 10)

        expect(post).to be_valid
      end

      it 'is invalid with a body of 9 characters' do
        post = build(:post, body: 'A' * 9)

        expect(post).not_to be_valid
        expect(post.errors[:body]).to include(I18n.t('activerecord.errors.messages.post.title.short'))
      end

      it 'is invalid without a body' do
        post = build(:post, body: nil)

        expect(post).not_to be_valid
        expect(post.errors[:body]).to include(I18n.t('activerecord.errors.messages.post.title.blank'))
      end

      it 'accepts rich text content' do
        post = build(:post)
        post.body = '<p>Rich text content</p>'

        expect(post).to be_valid
      end
    end

    context 'cover_image' do
      it 'is valid with a PNG image' do
        post = build(:post)
        post.cover_image.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'valid_image.png')),
                                filename: 'valid_image.png',
                                content_type: 'image/png'
                                )

        expect(post).to be_valid
      end

      it 'is valid with a JPEG image' do
        post = build(:post)
        post.cover_image.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'valid_image.jpg')),
                                filename: 'image.jpg',
                                content_type: 'image/jpeg'
                                )
        expect(post).to be_valid
      end

      it 'is valid with a GIF image' do
        post = build(:post)
        post.cover_image.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'valid_image.gif')),
                                filename: 'image.gif',
                                content_type: 'image/gif'
                                )

        expect(post).to be_valid
      end

      it 'is valid with a WEBP image' do
        post = build(:post)
        post.cover_image.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'valid_image.webp')),
                                filename: 'image.webp',
                                content_type: 'image/webp'
                              )

        expect(post).to be_valid
      end

      it 'is invalid with incorrect content type' do
        post = build(:post)
        post.cover_image.attach(io: StringIO.new('fake_pdf_content'),
                                filename: 'document.pdf',
                                content_type: 'application/pdf'
                                )

        expect(post).not_to be_valid
        expect(post.errors[:cover_image]).to be_present
      end

      it 'is invalid with a file larger than 5MB' do
        post = build(:post)
        large_file = StringIO.new('A' * 6.megabytes)
        post.cover_image.attach(io: large_file,
                                filename: 'large_image.jpg',
                                content_type: 'image/jpeg'
                                )

        expect(post).not_to be_valid
        expect(post.errors[:cover_image]).to be_present
      end

      it 'is valid with a file of exactly 5MB' do
        post = build(:post)
        minimal_png = Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==")
        padding_size = 5.megabytes - minimal_png.size
        file_content = minimal_png + ('A' * padding_size)

        post.cover_image.attach(io: StringIO.new(file_content),
                                filename: 'image.png',
                                content_type: 'image/png'
                                )

        expect(post).to be_valid
      end

      it 'is valid without a cover image' do
        post = build(:post)

        expect(post).to be_valid
      end
    end
  end

  describe 'friendly_id' do
    it 'generates a slug from the title' do
      post = create(:post, title: 'My Awesome Post')

      expect(post.slug).to eq('my-awesome-post')
    end

    it 'generates a unique slug for duplicate titles' do
      create(:post, title: 'Duplicate Title')
      post2 = create(:post, title: 'Duplicate Title')

      expect(post2.slug).to match(/duplicate-title-\w+/)
      expect(post2.slug).not_to eq('duplicate-title')
    end

    it 'can find post by slug' do
      post = create(:post, title: 'Findable Post')
      found = Post.friendly.find(post.slug)

      expect(found).to eq(post)
    end

    it 'can find post by id' do
      post = create(:post)
      found = Post.friendly.find(post.id)

      expect(found).to eq(post)
    end

    it 'transliterates Ukrainian characters' do
      post = create(:post, title: 'Привіт Світ')

      expect(post.slug).to match(/pryvit-svit/)
    end

    it 'updates slug when title changes' do
      post = create(:post, title: 'Original Title')
      original_slug = post.slug
      post.update(title: 'Updated Title')

      expect(post.slug).not_to eq(original_slug)
      expect(post.slug).to eq('updated-title')
    end

    it 'keeps history of old slugs' do
      post = create(:post, title: 'Original Title')
      old_slug = post.slug
      post.update(title: 'New Title')

      expect(Post.friendly.find(old_slug)).to eq(post)
    end

    it 'handles special characters in title' do
      post = create(:post, title: 'Hello @#$% World!')

      expect(post.slug).to eq('hello-world')
    end

    it 'handles very long titles' do
      long_title = 'A' * 100
      post = create(:post, title: long_title)

      expect(post.slug.length).to be <= 255
    end
  end

  describe '#should_generate_new_friendly_id?' do
    it 'returns true when title changes' do
      post = create(:post, title: 'Original')
      post.title = 'Changed'

      expect(post.should_generate_new_friendly_id?).to be true
    end

    it 'returns false when title does not change' do
      post = create(:post)
      post.body = 'New body content that is long enough'

      expect(post.should_generate_new_friendly_id?).to be false
    end
  end

  describe '#normalize_friendly_id' do
    it 'transliterates Ukrainian text' do
      post = Post.new

      expect(post.normalize_friendly_id('Київ')).to match(/kyiv/i)
    end

    it 'handles mixed language text' do
      post = Post.new
      result = post.normalize_friendly_id('Hello Привіт')

      expect(result).to be_a(String)
    end
  end

  describe 'callbacks' do
    describe '#notify_followers' do
      let(:creator) { create(:user, :creator) }
      let(:follower1) { create(:user, :reader) }
      let(:follower2) { create(:user, :reader) }

      before do
        follower1.follow(creator)
        follower2.follow(creator)
      end

      it 'creates notifications for all followers after create' do
        expect { create(:post, user: creator) }.to change(Notification, :count).by(2)
      end

      it 'creates notifications with correct attributes' do
        post = create(:post, user: creator)
        notification = Notification.where(user: follower1,
                                          actor: creator,
                                          notifiable: post,
                                          action: 'new_post'
                                          ).first

        expect(notification).to be_present
      end

      it 'does not create notifications if user has no followers' do
        lonely_creator = create(:user, :creator)

        expect { create(:post, user: lonely_creator) }.not_to change(Notification, :count)
      end

      it 'handles large number of followers efficiently' do
        100.times do
          follower = create(:user, :reader)
          follower.follow(creator)
        end

        expect { create(:post, user: creator) }.to change(Notification, :count).by(102)
      end
    end
  end

  describe 'ransackable attributes' do
    it 'allows searching by id' do
      expect(Post.ransackable_attributes).to include('id')
    end

    it 'allows searching by title' do
      expect(Post.ransackable_attributes).to include('title')
    end

    it 'allows searching by created_at' do
      expect(Post.ransackable_attributes).to include('created_at')
    end

    it 'allows searching by updated_at' do
      expect(Post.ransackable_attributes).to include('updated_at')
    end

    it 'does not expose sensitive attributes' do
      expect(Post.ransackable_attributes).not_to include('user_id')
    end
  end

  describe 'ransackable associations' do
    it 'allows searching through user' do
      expect(Post.ransackable_associations).to include('user')
    end

    it 'allows searching through categories' do
      expect(Post.ransackable_associations).to include('categories')
    end

    it 'allows searching through rich_text_body' do
      expect(Post.ransackable_associations).to include('rich_text_body')
    end
  end

  describe 'post lifecycle' do
    it 'can create a complete post with all attributes' do
      category = create(:category)

      post = Post.create(user: user,
                         title: 'Complete Post',
                         body: 'This is a complete post with all attributes filled in properly.',
                         categories: [category]
                         )

      expect(post).to be_persisted
      expect(post.user).to eq(user)
      expect(post.categories).to include(category)
      expect(post.slug).to be_present
    end

    it 'can be liked by users' do
      another_user = create(:user)

      expect { post.likes.create(user: another_user) }.to change(post.liking_users, :count).by(1)
      expect(post.liking_users).to include(another_user)
    end

    it 'can be bookmarked by users' do
      another_user = create(:user)

      expect { post.bookmarks.create(user: another_user) }.to change(post.bookmarks, :count).by(1)
    end

    it 'deletes associated records on destroy' do
      category = create(:category)
      post = create(:post, categories: [category])
      another_user = create(:user)
      post.likes.create(user: another_user)
      post.bookmarks.create(user: another_user)

      expect { post.destroy }.to change(Like, :count).by(-1)
                             .and change(Bookmark, :count).by(-1)
                             .and change(Categorization, :count).by(-1)
    end
  end

  describe 'edge cases' do
    it 'handles posts with no categories' do
      post = create(:post)

      expect(post.categories).to be_empty
    end

    it 'handles posts with multiple categories' do
      cat1 = create(:category, name: 'Tech')
      cat2 = create(:category, name: 'Science')
      cat3 = create(:category, name: 'Math')
      post = create(:post, categories: [cat1, cat2, cat3])

      expect(post.categories.count).to eq(3)
    end

    it 'handles very short valid body' do
      post = build(:post, body: 'A' * 10)

      expect(post).to be_valid
    end

    it 'handles very long body' do
      post = build(:post, body: 'A' * 100_000)

      expect(post).to be_valid
    end

    it 'handles emoji in title' do
      post = create(:post, title: '🚀 Awesome Post 🎉')

      expect(post).to be_valid
      expect(post.slug).to be_present
    end

    it 'handles HTML in title' do
      post = build(:post, title: '<script>alert("xss")</script>')

      expect(post).to be_valid
    end

    it 'handles nil user gracefully in callbacks' do
      post = build(:post, user: nil)

      expect(post).not_to be_valid
    end
  end

  describe 'performance' do
    it 'notifies many followers efficiently' do
      creator = create(:user, :creator)
      50.times { create(:user, :reader).follow(creator) }

      time = Benchmark.realtime do
        create(:post, user: creator)
      end

      expect(time).to be < 1.0
    end
  end
end
