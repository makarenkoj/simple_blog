
```markdown
# 🚀 HelpBooost / Simple Blog

Це сучасний блог-платформа, розроблена на **Ruby on Rails 8**.
Проєкт підтримує багатомовність (UK, EN, IT), SEO-оптимізацію, Rich Text редагування та хмарне зберігання файлів.

## 🛠 Технічний стек

* **Backend:** Ruby 3.4, Rails 8.0
* **Database:** PostgreSQL
* **Frontend:** Tailwind CSS, Hotwire (Turbo & Stimulus)
* **Editor:** ActionText (Trix)
* **Storage:** ActiveStorage + Cloudflare R2 (AWS SDK)
* **SEO:** FriendlyId, MetaTags, SitemapGenerator
* **Testing:** RSpec, FactoryBot, Faker

---

## ⚡ Шпаргалка команд (Cheatsheet)

### 🟢 Запуск та Розробка

**Запустити сервер (Rails + CSS watcher):**
```bash
bin/dev

```

**Зайти в консоль (Rails Console):**

```bash
rails c
# або
rails console

```

**Перевірити маршрути (Routes):**

```bash
rails routes | grep posts

```

### 🗄️ База Даних

**Запустити міграції (після створення нових):**

```bash
rails db:migrate

```

**Відкотити останню міграцію (якщо помилився):**

```bash
rails db:rollback

```

**Заповнити базу тестовими даними (з `db/seeds.rb`):**

```bash
rails db:seed

```

**Повне перезавантаження бази (видалити все і створити наново):**

```bash
rails db:reset

```

### 🧪 Тестування (RSpec)

**Запустити всі тести:**

```bash
bundle exec rspec

```

**Запустити тест для конкретного файлу:**

```bash
bundle exec rspec spec/models/user_spec.rb

```

**Запустити тести, що впали минулого разу:**

```bash
bundle exec rspec --only-failures

```

---

## 🔍 SEO та Карта сайту (Sitemap)

**Генерувати карту сайту (Локально, без відправки в Google):**

```bash
bundle exec rails sitemap:refresh:no_ping

```

**Генерувати карту сайту (На сервері/Production):**

```bash
bundle exec rails sitemap:refresh

```

*Карта збережеться в `public/sitemap.xml.gz*`

### 🔗 Робота з FriendlyId (Слаги)

Якщо треба **перегенерувати слаги** для старих записів (наприклад, після зміни логіки), виконай цей скрипт у `rails c`:

```ruby
# Для постів (безпечний метод, не ламає картинки)
Post.find_each do |p|
  next if p.title.blank?
  p.slug = nil
  p.send(:set_slug) # Примусова генерація
  p.update_column(:slug, p.slug) if p.slug.present?
  print "."
end

# Для юзерів
User.find_each do |u|
  next if u.username.blank?
  u.slug = nil
  u.send(:set_slug)
  u.update_column(:slug, u.slug) if u.slug.present?
  print "."
end

```

---

## ☁️ Cloudflare R2 / ActiveStorage

Якщо виникає помилка `Aws::S3::Errors::InvalidRequest` (checksum conflict), перевір `config/storage.yml`. Для Cloudflare R2 там мають бути ці рядки:

```yaml
cloudflare:
  service: S3
  # ... ключі ...
  upload:
    checksum_algorithm: "md5" # Важливо для старих SDK
  # АБО для нових Rails 8 + AWS SDK v3:
  request_checksum_calculation: "when_required"
  response_checksum_validation: "when_required"

```

---

## 🚀 Деплой (Checklist)

Перед тим як заливати на продакшн:

1. **Environment Variables:** Переконався, що на сервері прописані:
* `DATABASE_URL`
* `RAILS_MASTER_KEY`
* `R2_ACCESS_KEY_ID`
* `R2_SECRET_ACCESS_KEY`
* `R2_BUCKET_NAME`
* `R2_ENDPOINT`


2. **Sitemap config:** У `config/sitemap.rb` має стояти реальний домен:
```ruby
SitemapGenerator::Sitemap.default_host = "[https://helpbooost.com](https://helpbooost.com)"

```


3. **Robots.txt:** Перевір, що в `public/robots.txt` є посилання на sitemap і закриті адмінські шляхи.
4. **Після деплою:**
* Запустити міграції: `rails db:migrate`
* Згенерувати карту: `rails sitemap:refresh`



---

## 📝 Корисні методи Faker (для seeds.rb)

* `Faker::Internet.username` — юзернейм (латиницею)
* `Faker::Internet.email` — пошта
* `Faker::Lorem.paragraph(sentence_count: 5)` — текст для поста
* `Faker::Internet.slug` — слаг


## Connect to server

* using ssh: `ssh deploy@206.189.107.151`

* kamal app exec -i 'bin/rails console'

* set -a; source .env; set +a; kamal app exec -i 'bin/rails c'

* bundle exec dotenv kamal app exec -i 'bin/rails c'

* KAMAL_REGISTRY_PASSWORD="ваш_токен_від_github" kamal app exec -i 'bin/rails c'
