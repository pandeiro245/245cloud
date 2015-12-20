gulp       = require 'gulp'
coffee     = require 'gulp-coffee'
concat     = require 'gulp-concat'
plumber    = require 'gulp-plumber'
sass       = require 'gulp-sass'
sourcemaps = require 'gulp-sourcemaps'


files =
    coffee: './app/**/*.coffee'
    scss  : './assets/css/**/*.scss'


gulp.task 'js', ->
    gulp.src files.coffee
        .pipe plumber()
        .pipe sourcemaps.init
            loadMaps: true
        .pipe coffee
            bare: true
        .pipe concat 'app.js'
        .pipe sourcemaps.write '.',
            addComment: true
            sourceRoot: '/src'
        .pipe gulp.dest './app'


gulp.task 'css', ->
    gulp.src files.scss
        .pipe plumber()
        .pipe sass()
        .pipe gulp.dest './assets/css'


gulp.task 'watch', ['build'], ->
    gulp.watch files.coffee, ['js']
    gulp.watch files.scss, ['css']


gulp.task 'build', ['js', 'css']
gulp.task 'default', ['build']
