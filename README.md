# Install

```
$ cp config/database.yml.example config/database.yml
  # Edit your mysql connect config
$ $EDITOR config/database.yml
$ bundle install
$ bundle exec rake db:create
$ bundle exec rake db:migrate

$ cp .env.example .env
  # Edit facebook key
$ $EDITOR .env

$ bundle exec rails s
```

# see also
https://ruffnote.com/pandeiro245/245cloud
