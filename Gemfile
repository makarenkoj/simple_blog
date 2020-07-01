source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.4'

gem 'bootsnap', '>= 1.4.2', require: false
gem 'devise'
gem 'devise-i18n'
gem 'jbuilder', '~> 2.7'
gem 'puma', '~> 4.1'
gem 'rails', '~> 6.0.3', '>= 6.0.3.1'
gem 'rails_admin'

gem 'sass-rails', '>= 6'
gem 'twitter-bootstrap-rails', '~> 3.2', '>= 3.2.2'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'listen', '~> 3.2'
  gem 'rubocop', '~> 0.86.0', require: false
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'sqlite3', '~> 1.4'
  gem 'web-console', '>= 3.3.0'
end

group :production do
  gem 'pg'
  gem 'rails_12factor'
end
