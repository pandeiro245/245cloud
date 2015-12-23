gulp       = require 'gulp'
coffee     = require 'gulp-coffee'
concat     = require 'gulp-concat'
plumber    = require 'gulp-plumber'
sass       = require 'gulp-sass'
#sourcemaps = require 'gulp-sourcemaps'

files =
  coffee: [
    './app/assets/javascripts/lib/config.coffee'
    './app/**/*.coffee'
  ]
  all: [
    './kintone/js/jquery.js'
    './kintone/js/jquery_ujs.js'
    './kintone/js/bootstrap.min.js'
    'tmp/kintone/app_without_vendors.js'
  ]

gulp.task 'js', ->
  gulp.src files.coffee
    .pipe plumber()
    #.pipe sourcemaps.init
    #    loadMaps: true
    .pipe coffee
        bare: true
    .pipe concat 'app_without_vendors.js'
    #.pipe sourcemaps.write '.',
    #    addComment: true
    #    sourceRoot: '/src'
    .pipe gulp.dest './tmp/kintone'

gulp.task 'all', ->
  gulp.src files.all
    .pipe plumber()
    .pipe concat 'app.js'
    .pipe gulp.dest './tmp/kintone'

gulp.task 'watch', ['build'], ->
  gulp.watch files.coffee, ['js', 'all']

gulp.task 'build', ['js', 'all']
gulp.task 'default', ['build']
