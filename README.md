# Install

```
$ cp config/database.yml.sample config/database.yml
$ vim config/database.yml
$ bundle install
$ bundle exec rake db:setup
$ bundle exec rails s -p 3001
```

## powで動かす場合

`.env`に
```
FACEBOOK_KEY='363848477150475'
FACEBOOK_SECRET='27430a3ade3e794bca483467c9f9c09e'
```
と書いて http://245cloud.dev/ で動かせばOK

## webrickで動かす場合

（後で書くつもりだけPR Welcome）

# see also  
https://ruffnote.com/pandeiro245/245cloud
