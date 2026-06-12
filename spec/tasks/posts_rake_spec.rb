require 'rails_helper'
require 'rake'

RSpec.describe 'posts:migrate_to_tiptap', type: :task do
  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task['posts:migrate_to_tiptap'].reenable
    allow($stdout).to receive(:puts)
  end

  describe 'migrate_to_tiptap' do
    it 'successfully migrates ActionText content to body_html' do
      post_with_body = create(:post, body: '<strong>Bold Text</strong> and <em>Italic</em>')
      post_with_body.update_column(:body_html, nil) # rubocop:disable Rails/SkipsModelValidations

      Rake::Task['posts:migrate_to_tiptap'].invoke

      post_with_body.reload
      expect(post_with_body.body_html).to include('<strong>Bold Text</strong> and <em>Italic</em>')
    end

    it 'skips posts that do not have an ActionText body' do
      post_without_body = create(:post)
      post_without_body.update(body: nil)
      post_without_body.update_column(:body_html, nil) # rubocop:disable Rails/SkipsModelValidations

      Rake::Task['posts:migrate_to_tiptap'].invoke

      post_without_body.reload
      expect(post_without_body.body_html).to be_nil
    end

    it 'outputs the migrated post IDs to stdout' do
      post = create(:post, body: '<p>Content</p>')

      expect($stdout).to receive(:puts).with("Migrated post ID: #{post.id}")

      Rake::Task['posts:migrate_to_tiptap'].invoke
    end
  end
end
