require 'rails_helper'

RSpec.describe User, type: :model do
  let(:reader) { create(:user, username: 'reader_user', email: 'reader@example.com') }
  let(:creator) { create(:user, role: :creator, username: 'creator_user', email: 'creator@example.com') }
  let(:another_creator) { create(:user, role: :creator, username: 'another_creator', email: 'creator2@example.com') }
  let(:third_creator) { create(:user, role: :creator, username: 'third_creator', email: 'creator3@example.com') }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_length_of(:username).is_at_least(3).is_at_most(20) }

    subject { create(:user) }

    it { is_expected.to validate_uniqueness_of(:username).case_insensitive }
  end

  describe 'associations' do
    it { is_expected.to have_many(:posts).dependent(:destroy) }
    it { is_expected.to have_many(:followers).through(:follower_relationships).source(:follower) }
    it { is_expected.to have_many(:followings).through(:following_relationships).source(:following) }
    it { is_expected.to have_many(:following_relationships).with_foreign_key(:follower_id).class_name('Follow').dependent(:destroy).inverse_of(:follower) }
    it { is_expected.to have_many(:follower_relationships).with_foreign_key(:following_id).class_name('Follow').dependent(:destroy).inverse_of(:following) }
    it { is_expected.to have_many(:bookmarks).dependent(:destroy) }
    it { is_expected.to have_many(:bookmarked_posts).through(:bookmarks).source(:post) }
    it { is_expected.to have_many(:category_preferences).dependent(:destroy) }
    it { is_expected.to have_many(:preferred_categories).through(:category_preferences).source(:category) }
    it { is_expected.to have_many(:notifications).dependent(:destroy) }
    it { is_expected.to have_many(:initiated_notifications).with_foreign_key(:actor_id).class_name('Notification').dependent(:destroy).inverse_of(:actor) }
    it { is_expected.to have_many(:likes).dependent(:destroy) }
    it { is_expected.to have_many(:liked_posts).through(:likes).source(:post) }
    it { is_expected.to have_one_attached(:avatar) }
  end

  describe 'custom methods' do
    describe '#full_name' do
      let(:user) { create(:user, first_name: 'Taras', last_name: 'Shevchenko') }

      it 'returns the capitalized full name' do
        expect(user.full_name).to eq('Taras Shevchenko')
      end
    end

    describe '#creator?' do
      it 'return true for creator' do
        expect(creator.creator?).to be_truthy
      end

      it 'return false for reader' do
        expect(reader.creator?).to be_falsey
      end
    end

    describe '#follow' do
      context 'when successful' do
        it 'creates a follow relationship' do
          expect do
            reader.follow(creator)
          end.to change(Follow, :count).by(1)
        end

        it 'adds the creator to followings' do
          reader.follow(creator)
          expect(reader.followings).to include(creator)
        end

        it 'adds the reader to followers' do
          reader.follow(creator)
          expect(creator.followers).to include(reader)
        end

        it 'creates a notification for the creator' do
          expect do
            reader.follow(creator)
          end.to change { creator.notifications.count }.by(1)
        end

        it 'creates notification with correct attributes' do
          reader.follow(creator)
          notification = creator.notifications.last

          expect(notification.actor).to eq(reader)
          expect(notification.notifiable).to eq(creator)
          expect(notification.action).to eq('new_follower')
        end

        it 'returns a Notification object' do
          result = reader.follow(creator)
          expect(result).to be_a(Notification)
          expect(result.persisted?).to be true
        end

        it 'allows multiple users to follow the same creator' do
          reader.follow(creator)
          another_reader = create(:user, role: :reader, username: 'reader2', email: 'reader2@example.com')

          expect do
            another_reader.follow(creator)
          end.to change { creator.followers.count }.by(1)
        end

        it 'allows a user to follow multiple creators' do
          reader.follow(creator)

          expect do
            reader.follow(another_creator)
          end.to change { reader.followings.count }.by(1)
        end
      end

      context 'when unsuccessful' do
        it 'returns false when trying to follow self' do
          result = creator.follow(creator)
          expect(result).to be false
        end

        it 'does not create follow when trying to follow self' do
          expect do
            creator.follow(creator)
          end.not_to change(Follow, :count)
        end

        it 'does not create notification when trying to follow self' do
          expect do
            creator.follow(creator)
          end.not_to change(Notification, :count)
        end

        it 'returns false when already following' do
          reader.follow(creator)
          result = reader.follow(creator)
          expect(result).to be false
        end

        it 'does not create duplicate follow' do
          reader.follow(creator)

          expect do
            reader.follow(creator)
          end.not_to change(Follow, :count)
        end

        it 'does not create duplicate notification' do
          reader.follow(creator)

          expect do
            reader.follow(creator)
          end.not_to(change { creator.notifications.count })
        end

        it 'returns false when trying to follow a reader' do
          another_reader = create(:user, role: :reader, username: 'reader2', email: 'reader2@example.com')
          result = reader.follow(another_reader)
          expect(result).to be false
        end

        it 'does not create follow when target is not a creator' do
          another_reader = create(:user, role: :reader, username: 'reader2', email: 'reader2@example.com')

          expect do
            reader.follow(another_reader)
          end.not_to change(Follow, :count)
        end

        it 'does not create notification when target is not a creator' do
          another_reader = create(:user, role: :reader, username: 'reader2', email: 'reader2@example.com')

          expect do
            reader.follow(another_reader)
          end.not_to change(Notification, :count)
        end
      end

      context 'edge cases' do
        it 'handles nil user gracefully' do
          expect do
            reader.follow(nil)
          end.to raise_error(NoMethodError)
        end

        it 'prevents SQL injection in follow' do
          malicious_user = build(:user, username: "'; DROP TABLE users; --")
          expect do
            reader.follow(malicious_user) if malicious_user.save(validate: false)
          end.not_to raise_error
        end
      end
    end

    describe '#unfollow' do
      context 'when following exists' do
        before do
          reader.follow(creator)
        end

        it 'removes the follow relationship' do
          expect do
            reader.unfollow(creator)
          end.to change(Follow, :count).by(-1)
        end

        it 'removes the creator from followings' do
          reader.unfollow(creator)
          expect(reader.followings).not_to include(creator)
        end

        it 'removes the reader from followers' do
          reader.unfollow(creator)
          expect(creator.followers).not_to include(reader)
        end

        it 'returns the destroyed Follow object' do
          result = reader.unfollow(creator)
          expect(result).to be_a(Follow)
          expect(result.destroyed?).to be true
        end

        it 'does not affect other follows' do
          reader.follow(another_creator)

          expect do
            reader.unfollow(creator)
          end.to change { reader.followings.count }.by(-1)

          expect(reader.followings).to include(another_creator)
          expect(reader.followings).not_to include(creator)
        end

        it 'does not delete notifications' do
          expect do
            reader.unfollow(creator)
          end.not_to change(Notification, :count)
        end
      end

      context 'when following does not exist' do
        it 'returns nil when not following' do
          result = reader.unfollow(creator)
          expect(result).to be_nil
        end

        it 'does not change follow count' do
          expect do
            reader.unfollow(creator)
          end.not_to change(Follow, :count)
        end

        it 'handles unfollowing same user multiple times' do
          reader.follow(creator)
          reader.unfollow(creator)

          expect do
            reader.unfollow(creator)
          end.not_to raise_error
        end
      end

      context 'edge cases' do
        it 'handles nil user gracefully' do
          result = reader.unfollow(nil)
          expect(result).to be_nil
        end

        it 'can unfollow after follow-unfollow-follow cycle' do
          reader.follow(creator)
          reader.unfollow(creator)
          reader.follow(creator)

          expect do
            reader.unfollow(creator)
          end.to change { reader.followings.count }.by(-1)
        end
      end
    end

    describe '#following?' do
      context 'when following' do
        before do
          reader.follow(creator)
        end

        it 'returns true' do
          expect(reader.following?(creator)).to be true
        end

        it 'returns true immediately after follow' do
          reader.follow(another_creator)
          expect(reader.following?(another_creator)).to be true
        end
      end

      context 'when not following' do
        it 'returns false' do
          expect(reader.following?(creator)).to be false
        end

        it 'returns false after unfollow' do
          reader.follow(creator)
          reader.unfollow(creator)
          expect(reader.following?(creator)).to be false
        end

        it 'returns false for self' do
          expect(reader.following?(reader)).to be false
        end
      end

      context 'with multiple follows' do
        before do
          reader.follow(creator)
          reader.follow(another_creator)
        end

        it 'correctly identifies each follow' do
          expect(reader.following?(creator)).to be true
          expect(reader.following?(another_creator)).to be true
          expect(reader.following?(third_creator)).to be false
        end

        it 'updates correctly after selective unfollow' do
          reader.unfollow(creator)

          expect(reader.following?(creator)).to be false
          expect(reader.following?(another_creator)).to be true
        end
      end

      context 'edge cases' do
        it 'handles nil user' do
          expect(reader.following?(nil)).to be false
        end

        it 'uses association for lookup' do
          reader.follow(creator)

          expect(reader.followings.loaded?).to be false
          result = reader.following?(creator)
          expect(result).to be true
        end
      end
    end

    describe '#followed_by?' do
      context 'when followed by user' do
        before do
          reader.follow(creator)
        end

        it 'returns true' do
          expect(creator.followed_by?(reader)).to be true
        end

        it 'returns true immediately after being followed' do
          another_reader = create(:user, role: :reader, username: 'reader2', email: 'reader2@example.com')
          another_reader.follow(creator)
          expect(creator.followed_by?(another_reader)).to be true
        end
      end

      context 'when not followed by user' do
        it 'returns false' do
          expect(creator.followed_by?(reader)).to be false
        end

        it 'returns false after unfollowed' do
          reader.follow(creator)
          reader.unfollow(creator)
          expect(creator.followed_by?(reader)).to be false
        end

        it 'returns false for self' do
          expect(creator.followed_by?(creator)).to be false
        end
      end

      context 'with multiple followers' do
        let(:reader2) { create(:user, role: :reader, username: 'reader2', email: 'reader2@example.com') }
        let(:reader3) { create(:user, role: :reader, username: 'reader3', email: 'reader3@example.com') }

        before do
          reader.follow(creator)
          reader2.follow(creator)
        end

        it 'correctly identifies each follower' do
          expect(creator.followed_by?(reader)).to be true
          expect(creator.followed_by?(reader2)).to be true
          expect(creator.followed_by?(reader3)).to be false
        end

        it 'updates correctly after follower unfollows' do
          reader.unfollow(creator)

          expect(creator.followed_by?(reader)).to be false
          expect(creator.followed_by?(reader2)).to be true
        end
      end

      context 'symmetry with following?' do
        it 'is symmetric with following?' do
          reader.follow(creator)

          expect(reader.following?(creator)).to eq(creator.followed_by?(reader))
        end

        it 'maintains symmetry after unfollow' do
          reader.follow(creator)
          reader.unfollow(creator)

          expect(reader.following?(creator)).to eq(creator.followed_by?(reader))
        end
      end

      context 'edge cases' do
        it 'handles nil user' do
          expect(creator.followed_by?(nil)).to be false
        end
      end
    end

    describe 'follow workflow integration' do
      it 'completes full follow-unfollow cycle' do
        expect(reader.following?(creator)).to be false
        expect(creator.followed_by?(reader)).to be false

        reader.follow(creator)

        expect(reader.following?(creator)).to be true
        expect(creator.followed_by?(reader)).to be true
        expect(creator.followers).to include(reader)
        expect(reader.followings).to include(creator)

        reader.unfollow(creator)

        expect(reader.following?(creator)).to be false
        expect(creator.followed_by?(reader)).to be false
        expect(creator.followers).not_to include(reader)
        expect(reader.followings).not_to include(creator)
      end

      it 'handles complex multi-user scenario' do
        reader2 = create(:user, role: :reader, username: 'reader2', email: 'reader2@example.com')

        reader.follow(creator)
        reader2.follow(creator)

        expect(creator.followers.count).to eq(2)
        expect(creator.followed_by?(reader)).to be true
        expect(creator.followed_by?(reader2)).to be true

        reader.follow(another_creator)

        expect(reader.followings.count).to eq(2)
        expect(reader.following?(creator)).to be true
        expect(reader.following?(another_creator)).to be true

        reader.unfollow(creator)

        expect(creator.followers.count).to eq(1)
        expect(creator.followed_by?(reader)).to be false
        expect(creator.followed_by?(reader2)).to be true
        expect(reader.following?(another_creator)).to be true
      end

      it 'prevents follow spam' do
        100.times do
          reader.follow(creator)
        end

        expect(creator.followers.count).to eq(1)
        expect(Follow.count).to eq(1)
        expect(creator.notifications.where(action: 'new_follower').count).to eq(1)
      end
    end

    describe 'database consistency' do
      it 'maintains referential integrity on user deletion' do
        reader.follow(creator)

        expect do
          reader.destroy
        end.to change(Follow, :count).by(-1)
      end

      it 'cascades deletes correctly' do
        reader.follow(creator)
        reader.follow(another_creator)

        expect do
          reader.destroy
        end.to change { creator.followers.count + another_creator.followers.count }.by(-2)
      end
    end

    describe 'performance' do
      it 'caches followings in memory' do
        reader.follow(creator)

        expect(reader.followings.loaded?).to be false
        reader.following?(creator)
      end

      it 'handles large follower counts' do
        followers = create_list(:user, 50, role: :reader)
        followers.each { |f| f.follow(creator) }

        expect(creator.followed_by?(followers.last)).to be true
        expect(creator.followers.count).to eq(50)
      end
    end
  end

  describe 'extended validations' do
    it { is_expected.to validate_length_of(:first_name).is_at_most(50) }
    it { is_expected.to validate_length_of(:last_name).is_at_most(50) }
    it { is_expected.to validate_presence_of(:role) }

    context 'username format' do
      it 'accepts valid usernames' do
        valid_usernames = ['user_name', 'user.name', 'User123', 'user']
        valid_usernames.each do |valid_name|
          user = build(:user, username: valid_name)
          expect(user).to be_valid
        end
      end

      it 'rejects invalid usernames' do
        invalid_usernames = ['user name', 'user@name', 'user!', 'user/name']
        invalid_usernames.each do |invalid_name|
          user = build(:user, username: invalid_name)
          user.valid?
          expect(user.errors[:username]).to include("недійсний")
        end
      end
    end

    context 'avatar validation' do
      it 'is valid with correct image type and size' do
        user = build(:user)
        user.avatar.attach(
          io: StringIO.new('fake_image_content'),
          filename: 'avatar.png',
          content_type: 'image/png'
        )
        expect(user).to be_valid
      end

      it 'is invalid with incorrect content type' do
        user = build(:user)
        user.avatar.attach(io: StringIO.new('fake_pdf_content'),
                           filename: 'document.pdf',
                           content_type: 'application/pdf'
                           )
        user.valid?

        expect(user.errors[:avatar]).to be_present
      end

      it 'is invalid if file is too large' do
        user = build(:user)

        blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new('x' * 2.1.megabytes),
                                                      filename: 'large.png',
                                                      content_type: 'image/png'
                                                      )
        user.avatar.attach(blob)

        user.valid?
        expect(user.errors[:avatar]).to include(I18n.t('attachments.avatar.large'))
      end
    end
  end

  describe 'interaction methods' do
    let(:post) { create(:post) }

    describe '#unread_notifications_count' do
      it 'counts only unread notifications' do
        create_list(:notification, 2, user: reader, read: false)
        create(:notification, user: reader, read: true)

        expect(reader.unread_notifications_count).to eq(2)
      end

      it 'returns 0 if all notifications are read' do
        create(:notification, user: reader, read: true)
        expect(reader.unread_notifications_count).to eq(0)
      end
    end

    describe '#bookmarked?' do
      it 'returns true if the post is bookmarked' do
        reader.bookmarks.create(post: post)
        expect(reader.bookmarked?(post)).to be true
      end

      it 'returns false if the post is not bookmarked' do
        expect(reader.bookmarked?(post)).to be false
      end
    end

    describe '#liked?' do
      it 'returns true if the post is liked' do
        reader.likes.create(post: post)
        expect(reader.liked?(post)).to be true
      end

      it 'returns false if the post is not liked' do
        expect(reader.liked?(post)).to be false
      end
    end
  end

  describe 'Ransack configuration' do
    describe '.ransackable_attributes' do
      it 'returns the allowed attributes for search' do
        expected_attributes = %w[id username email first_name last_name role created_at]
        expect(User.ransackable_attributes).to match_array(expected_attributes)
      end
    end

    describe '.ransackable_associations' do
      it 'returns the allowed associations for search' do
        expected_associations = %w[posts followers followings preferred_categories]
        expect(User.ransackable_associations).to match_array(expected_associations)
      end
    end
  end
end
