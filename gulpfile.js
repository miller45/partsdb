var gulp = require('gulp');
var series = require('stream-series');
var inject = require('gulp-inject');

gulp.task('index', function () {
    var target = gulp.src('./index.html');
    var main = gulp.src(['./src/app.js'], {read: false});
    var sources = gulp.src(['./src/**/*.js','!./src/app.js', './assets/**/*.css'], {read: false});
    return target.pipe(
        inject(series(main,sources),
            {
                addRootSlash: false
            }
        ))
        .pipe(gulp.dest('.'));
});