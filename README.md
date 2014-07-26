# for coffeescript

```
$ npm install gulp
$ npm install gulp-coffee
$ gulp watch
```

# mac

```
$ mv .env.sample .env
$ vim .env
```
see also http://qiita.com/ogawatti/items/e1e612b793a3d51978cc

# Heroku

```
$ heroku config:set TWITTERKEY=****
$ heroku config:set TWITTERSECRET=****
$ heroku config:set SESSIONSECRET=****
```
see also http://qiita.com/tomomomo1217/items/77c9b64266daf6315abe

# main functions

## initStart
`#start`のボタンが押された時のonClickイベントを定義

## initLogs
初回アクセス時に表示される「DONE」一覧

## initDoing
初回アクセス時に表示される「DOING」一覧

## start
Twitterログインしてかつ`#start`が押された時の処理。
soundcloud_idの指定がなければランダムで決めうちして次のplayを実行

## play
`#play`にsoundcloudを埋め込んで自動再生させる

## complete
動いているworkloadのis_doneをtrueにしてサーバに送る
その時間を'nishko_end'というkeyでlocalStorageに保存しておく

## window.finish
localStorageから'nishiko_end'というkeyを消す

## window.comment
complete状態においてコメントを追加する
