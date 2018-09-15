source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.5'
# gem 'sqlite3'
gem 'mysql2', '0.3.21'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'therubyracer', platforms: :ruby
gem 'coffee-rails', '~> 4.2'
gem 'jbuilder', '~> 2.5'
# gem 'bcrypt', '~> 3.1.7'

group :development, :test do
  gem 'byebug'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-rbenv'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano3-unicorn'
  gem 'capistrano-sidekiq'
  gem 'chatwork'
  gem 'capistrano-pending', require: false
  gem 'gem_reloader'
  gem 'web-console', '>= 3.3.0'
end

group 'test' do
  gem 'rspec-rails'
  gem 'capybara-webkit'
  gem 'launchy'
  gem 'factory_girl_rails'
  gem 'poltergeist'
  gem 'database_rewinder'
end
gem 'haml'
gem 'dotenv-rails'
gem 'settingslogic'
gem 'font-awesome-sass'

gem 'omniauth-facebook'
gem 'omniauth-timecrowd', github: 'pandeiro245/omniauth-timecrowd', branch: 'issue-1'
gem 'omniauth-twitter'
gem 'twitter'

gem 'rb-readline'
gem 'awesome_print'
gem 'togglv8'

gem 'devise'
gem 'activerecord-import'
gem 'nico_search_snapshot'

gem 'draper'

gem 'jquery-rails'
gem 'jquery-ui-rails'
