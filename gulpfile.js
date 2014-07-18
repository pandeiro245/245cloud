var gulp = require('gulp')
, coffee = require('gulp-coffee')
;

gulp.task('coffee', function() {
    gulp.src('app/*.coffee')
        .pipe(coffee())
        .pipe(gulp.dest('public'));
});

gulp.task('watch', function() {
    gulp.watch('app/**', function(event) {
        gulp.run('coffee');
    });
});

gulp.task('default', function() {
    gulp.run('coffee');
});
