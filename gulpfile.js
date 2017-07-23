var gulp = require('gulp');
var series = require('stream-series');
var inject = require('gulp-inject');
var grename = require('gulp-rename');
var prgfpath = "C:\\Program Files (x86)\\";
var resipath = prgfpath + "SMzH\\pointless Resistance\\resistors\\myresistors.csv";
const transform = require('gulp-transform');
const transformFn = require('./gulp-custom-csv-transform');


gulp.task('index', function () {
    var target = gulp.src('./index.html');
    var main = gulp.src(['./src/app.js'], {read: false});
    var sources = gulp.src(['./src/**/*.js', '!./src/app.js', './assets/**/*.css'], {read: false});
    return target.pipe(
        inject(series(main, sources),
            {
                addRootSlash: false
            }
        ))
        .pipe(gulp.dest('.'));
});

gulp.task('resistor-csv2json', function () {

    return gulp.src(resipath)
        .pipe(transform(transformFn, {encoding: 'utf8'}))
        .pipe(grename({extname: '.json'}))
        .pipe(gulp.dest('data'))
});

gulp.task('default',['resistor-csv2json','index']);