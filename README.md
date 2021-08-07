# Install

```
$ cp config/database.yml.sample config/database.yml
$ vim config/database.yml
$ bundle install
$ bundle exec rake db:setup
$ bundle exec rails s -p 3001
```

## Facebook app id を開発用に取得

https://developers.facebook.com/

- FACEBOOK_KEY: app id
- FACEBOOK_SECRET: app secret

## powで動かす場合

`.env`に
```
FACEBOOK_KEY='1234567890'
FACEBOOK_SECRET='1234567890ABCDEF12345'
```
と書いて http://245cloud.dev/ で動かせばOK

## webrickで動かす場合

起動前に環境変数に設定

```
export FACEBOOK_KEY='1234567890'
export FACEBOOK_SECRET='1234567890ABCDEF12345'
```

## 開発モード

pomo時間, chat時間を変更する

- localstrage
  - dev_pomo : 0.1 (6秒くらい)
  - dev_chat : 0.1 (6秒くらい)


# see also  
https://ruffnote.com/pandeiro245/245cloud
