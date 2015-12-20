gulp       = require 'gulp'
coffee     = require 'gulp-coffee'
concat     = require 'gulp-concat'
plumber    = require 'gulp-plumber'
sass       = require 'gulp-sass'
#sourcemaps = require 'gulp-sourcemaps'


files =
    coffee: './app/**/*.coffee'
    scss  : './assets/css/**/*.scss'

gulp.task 'js', ->
    gulp.src files.coffee
        .pipe plumber()
        #.pipe sourcemaps.init
        #    loadMaps: true
        .pipe coffee
            bare: true
        .pipe concat 'app2.js'
        #.pipe sourcemaps.write '.',
        #    addComment: true
        #    sourceRoot: '/src'
        .pipe gulp.dest './tmp/kintone'


gulp.task 'css', ->
    gulp.src files.scss
        .pipe plumber()
        .pipe sass()
        .pipe gulp.dest './assets/css'

gulp.task 'venders', ->
    gulp.src('kintone/js/*.js').pipe(concat('venders.js')).pipe(gulp.dest('./tmp/kintone'))

gulp.task 'kintone', ->
    gulp.src('tmp/kintone/*.js').pipe(concat('kintone.js')).pipe(gulp.dest('./tmp'))

gulp.task 'watch', ['build'], ->
    gulp.watch files.coffee, ['js']
    gulp.watch files.scss, ['css']

gulp.task 'build', ['js']
#gulp.task 'build', ['js', 'css', 'venders', 'kintone']
#gulp.task 'build', ['kintone']
gulp.task 'default', ['build']
