var gulp = require('gulp');

var inject = require('gulp-inject');

gulp.task('index', function () {
    var target = gulp.src('./index.html');
    var sources = gulp.src(['./src/**/*.js', './assets/**/*.css'], {read: false});
    return target.pipe(
        inject(sources,
            {
                addRootSlash: false
            }
        ))
        .pipe(gulp.dest('.'));
});