require 'rails_helper'

RSpec.describe 'Post Show Page', type: :system do
  include_context 'base'

  let(:author) { create(:user, username: 'super_author') }
  let(:reader) { create(:user, username: 'just_reader') }
  let(:category) { create(:category, name: 'Technology') }
  let!(:main_post) do
    create(:post,
           user: author,
           title: 'Main test article',
           body_html: 'This is a very interesting content of our article.',
           status: :published)
  end

  before do
    driven_by(:selenium_chrome_headless)

    main_post.categories << category
    main_post.cover_image.attach(io: File.open(Rails.root.join('spec/fixtures/files/valid_test_image.png')), filename: 'test.png', content_type: 'image/png')

    create_list(:post, 3, user: author, status: :published)
  end

  describe 'Viewing as a Guest (Unauthenticated)' do
    before { visit post_path(main_post) }

    it 'displays all post content correctly' do
      expect(page).not_to have_text(/translation missing/i)
      expect(page).to have_selector('h1', text: 'Main test article')
      expect(page).to have_text('This is a very interesting content of our article.')
      expect(page).to have_text(/Technology/i)
      expect(page).to have_text('super_author')
      expect(page).to have_css("img[alt='Main test article']")
      expect(page).to have_text(I18n.t('activerecord.attributes.posts.more_from_author', author: author.username))
    end

    it 'does NOT show admin controls or status dropdown' do
      expect(page).not_to have_text(I18n.t('activerecord.attributes.posts.admin_mode'))
      expect(page).not_to have_button(I18n.t('activerecord.attributes.posts.change_status_title'))
    end
  end

  describe 'Viewing as another Authenticated User (Reader)' do
    before do
      sign_in reader
      visit post_path(main_post)
    end

    it 'does NOT show admin controls or status dropdown for other users posts' do
      expect(page).not_to have_text(I18n.t('activerecord.attributes.posts.admin_mode'))
      expect(page).not_to have_button(I18n.t('activerecord.attributes.posts.change_status_title'))
    end
  end

  describe 'Viewing as the Author' do
    before do
      sign_in author
      visit post_path(main_post)
    end

    it 'shows admin controls and edit/destroy links' do
      expect(page).to have_text(I18n.t('activerecord.attributes.posts.admin_mode'))
      expect(page).to have_link(I18n.t('activerecord.attributes.posts.edit'))
      expect(page).to have_link(I18n.t('activerecord.attributes.posts.destroy'))
    end

    it 'successfully changes the post status using the dropdown menu' do
      published_text = I18n.t('activerecord.attributes.posts.status_badge.published')
      expect(page).to have_button(text: /#{published_text}/i)

      find("button[title='#{I18n.t('activerecord.attributes.posts.change_status_title')}']").click

      draft_option_text = I18n.t('activerecord.attributes.posts.statuses.draft')
      click_button draft_option_text

      draft_badge_text = I18n.t('activerecord.attributes.posts.status_badge.draft')

      expect(page).to have_button(text: /#{draft_badge_text}/i)
      expect(main_post.reload.draft?).to be true
    end
  end

  describe 'Viewing a Post with all correct body content' do
    let(:rich_content_post) do
      create(:post,
             user: author,
             title: 'Rich Content Post',
             status: :published,
             body_html: <<~HTML
               <h2>Тестування TipTap Editor</h2>
               <p>Це базовий абзац, у якому ми перевіряємо <strong>жирний текст</strong>, <em>курсив</em>, <u>підкреслення</u> та <s>закреслений текст</s>.</p>

               <h3>Списки та вирівнювання</h3>
               <p style="text-align: center">Цей текст вирівняно по центру.</p>
               <p><a href="https://tiptap.dev" target="_blank" class="text-emerald-600 underline hover:text-emerald-800 transition-colors cursor-pointer">Це посилання на документацію TipTap</a>.</p>
               <p>А ось так виглядає <span style="color: #10b981">кольоровий текст (emerald)</span>.</p>

               <ul class="list-disc ml-6 space-y-1 my-4">
                 <li class="pl-1">Перший елемент маркованого списку</li>
                 <li class="pl-1">Другий елемент
                   <ul class="list-disc ml-6 space-y-1 my-4">
                     <li class="pl-1">Вкладений елемент списку</li>
                   </ul>
                 </li>
               </ul>

               <ol class="list-decimal ml-6 space-y-1 my-4">
                 <li class="pl-1">Перший крок нумерованого списку</li>
                 <li class="pl-1">Другий крок</li>
               </ol>

               <h3>Блок коду</h3>
               <pre><code>def hello_world
                 puts "TipTap працює ідеально!"
               end</code></pre>

               <h3>Таблиця</h3>
               <table class="min-w-full border-collapse border border-slate-300 my-4">
                 <thead>
                   <tr>
                     <th class="border border-slate-300 bg-slate-100 p-2 font-bold">Технологія</th>
                     <th class="border border-slate-300 bg-slate-100 p-2 font-bold">Тип</th>
                     <th class="border border-slate-300 bg-slate-100 p-2 font-bold">Статус</th>
                   </tr>
                 </thead>
                 <tbody>
                   <tr>
                     <td class="border border-slate-300 p-2">Ruby on Rails</td>
                     <td class="border border-slate-300 p-2">Backend</td>
                     <td class="border border-slate-300 p-2">Активно</td>
                   </tr>
                   <tr>
                     <td class="border border-slate-300 p-2">TipTap</td>
                     <td class="border border-slate-300 p-2">Frontend Editor</td>
                     <td class="border border-slate-300 p-2">Інтегровано</td>
                   </tr>
                 </tbody>
               </table>

               <h3>Зображення</h3>
               <img src="https://placehold.co/600x300/e2e8f0/1e293b?text=Test+Image" class="max-w-full h-auto rounded-lg my-4" alt="Test placeholder">
             HTML
            )
    end

    before do
      sign_in author
      visit post_path(rich_content_post)
    end

    it 'displays all rich text formatting correctly' do
      expect(page).to have_css('strong', text: 'жирний текст')
      expect(page).to have_css('em', text: 'курсив')
      expect(page).to have_css('u', text: 'підкреслення')
      expect(page).to have_css('s', text: 'закреслений текст')
      expect(page).to have_css('ul.list-disc')
      expect(page).to have_css('ol.list-decimal')
      expect(page).to have_text('Вкладений елемент списку')
      expect(page).to have_link('Це посилання на документацію TipTap', href: 'https://tiptap.dev')
      expect(page).to have_css('span', text: 'кольоровий текст (emerald)')
      expect(page).to have_css('pre code', text: /TipTap працює ідеально/)
      expect(page).to have_css('table.border-collapse')
      expect(page).to have_css('th', text: 'Технологія')
      expect(page).to have_css('td', text: 'Ruby on Rails')
      expect(page).to have_css("img[src*='placehold.co']")
    end
  end
end
