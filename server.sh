git pull origin develop; bundle install; bin/rails assets:precompile; RAILS_ENV=production bundle exec puma -C config/puma.rb
