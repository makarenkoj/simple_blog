shared_context 'base' do
  let!(:current_user) { create(:user, email: 'makarenkoj53@gmail.com', username: 'makarenkoj', first_name: 'Yura', last_name: 'Makarenko', password: 'Password123!') }
  let(:valid_body_html) do
    <<~HTML
      <h2>Тестування TipTap Editor</h2>
      <p>Це базовий абзац, у якому ми перевіряємо <strong>жирний текст</strong>, <em>курсив</em>, <u>підкреслення</u> та <s>закреслений текст</s>.</p>

      <h3>Списки та вирівнювання</h3>
      <p style="text-align: center">Цей текст вирівняно по центру.</p>
      <p><a href="https://tiptap.dev" target="_blank" class="text-emerald-600 underline hover:text-emerald-800 transition-colors cursor-pointer">Це посилання на документацію TipTap</a>.</p>
      <p>А ось так виглядає <span style="color: #10b981">кольоровий текст (emerald)</span>.</p>

      <p>unicorn</p>
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
  end

  def data
    return {} if response&.body.blank?

    JSON.parse(response.body)
  end
end
