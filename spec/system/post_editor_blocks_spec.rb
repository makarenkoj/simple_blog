require 'rails_helper'

# Tables, YouTube embeds and highlighted code, end to end: edited in Tiptap, saved as
# body_html, rendered through PostBodySanitizer on the post page.
RSpec.describe 'Post editor blocks', type: :system do
  include_context 'base'

  let(:table_html) do
    '<table><tbody><tr><th>Lang</th><th>Type</th></tr><tr><td>Ruby</td><td>Dynamic</td></tr></tbody></table>'
  end

  before do
    driven_by(:selenium_chrome_headless)
    sign_in current_user
  end

  def save_post
    click_button I18n.t('activerecord.attributes.posts.save')
    expect(page).to have_no_css('.ProseMirror')
  end

  it 'manages table rows and columns from the table toolbar' do
    post_record = create(:post, user: current_user, status: :published, body_html: "<p>Intro text here</p>#{table_html}")
    visit edit_post_path(post_record)

    expect(page).to have_no_button(I18n.t('post.editor.toolbar.add_row'))
    find('.ProseMirror td', text: 'Ruby').click
    click_button I18n.t('post.editor.toolbar.add_row')
    click_button I18n.t('post.editor.toolbar.add_column')
    save_post

    table = Nokogiri::HTML5.fragment(post_record.reload.body_html).at_css('table')
    expect(table.css('tr').size).to eq(3)
    expect(table.css('tr').first.css('th, td').size).to eq(3)
    expect(page).to have_css('table tr', count: 3)
  end

  it 'embeds a YouTube video and shows it on the post page' do
    visit new_post_path
    fill_in 'post[title]', with: 'Video post'
    find('.ProseMirror').click
    find('.ProseMirror').send_keys('A post with a video inside')
    accept_prompt(with: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ') do
      click_button title: I18n.t('post.editor.toolbar.youtube')
    end
    select I18n.t('activerecord.attributes.posts.statuses.published'), from: 'post[status]'
    save_post

    expect(Post.last.body_html).to include('youtube-nocookie.com/embed/dQw4w9WgXcQ')
    expect(page).to have_css('iframe[src^="https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ"]')
  end

  it 'refuses a link that is not a YouTube video' do
    visit new_post_path
    find('.ProseMirror').click

    alert = accept_alert do
      accept_prompt(with: 'https://example.com/video') { click_button title: I18n.t('post.editor.toolbar.youtube') }
    end

    expect(alert).to eq(I18n.t('post.editor.youtube_invalid'))
    expect(page).to have_no_css('.ProseMirror iframe')
  end

  describe 'images in the post body' do
    def attach_body_image(fixture)
      find('input[data-tiptap-target="imageInput"]', visible: :all)
        .attach_file(Rails.root.join("spec/fixtures/files/#{fixture}"), make_visible: true)
    end

    it 'uploads an image into the post body and shows it on the post page' do
      visit new_post_path
      fill_in 'post[title]', with: 'Post with a picture'
      find('.ProseMirror').click
      find('.ProseMirror').send_keys('A paragraph above the picture')
      attach_body_image('valid_image.png')

      expect(page).to have_css('.ProseMirror img[src*="/rails/active_storage/"]')
      select I18n.t('activerecord.attributes.posts.statuses.published'), from: 'post[status]'
      save_post

      expect(Post.last.body_html).to match(%r{<img[^>]+src="[^"]*/rails/active_storage/})
      expect(page).to have_css('.medium-prose img[src*="/rails/active_storage/"]')
    end

    it 'refuses a file that is not a web image, with the server reason' do
      visit new_post_path
      find('.ProseMirror').click

      message = accept_alert { attach_body_image('image.svg') }

      expect(message).to eq(I18n.t('attachments.editor_image.type'))
      expect(page).to have_no_css('.ProseMirror img')
    end
  end

  it 'imports a Markdown file into the editor and saves it as the post body' do
    visit new_post_path
    fill_in 'post[title]', with: 'Imported from Markdown'
    find('.ProseMirror').click
    find('input[data-tiptap-target="markdownInput"]', visible: :all)
      .attach_file(Rails.root.join('spec/fixtures/files/post.md'), make_visible: true)

    expect(page).to have_css('.ProseMirror h2', text: 'Imported heading')
    expect(page).to have_css('.ProseMirror table td', text: 'Ruby')
    select I18n.t('activerecord.attributes.posts.statuses.published'), from: 'post[status]'
    save_post

    body = Post.last.body_html
    expect(body).to include('Imported heading', '<table', 'language-ruby')
    expect(page).to have_css('pre code.hljs .hljs-built_in, pre code.hljs .hljs-string')
  end

  it 'highlights code blocks on the post page' do
    post_record = create(:post, user: current_user, status: :published,
                                body_html: '<p>Some code below</p><pre><code class="language-ruby">def hello = puts(1)</code></pre>')
    visit post_path(post_record)

    expect(page).to have_css('pre code.hljs .hljs-keyword', text: 'def')
  end
end
