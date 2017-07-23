var gulp = require('gulp');
var series = require('stream-series');

var inject = require('gulp-inject');
var csv2json = require('gulp-csv2json');
var grename = require('gulp-rename');
var prgfpath = "C:\\Program Files (x86)\\";
var resipath = prgfpath + "SMzH\\pointless Resistance\\resistors\\myresistors.csv";
const transform = require('gulp-transform');

function transformFn(contents) {
    var res = "[";
    var lines = contents.replace("\r", '').split("\n");
    var first = true;
    var fields = ["value", "tolerance", "comment"];
    for (var i = 0; i < lines.length; i++) {
        var line = lines[i];
        if (typeof line === "string") {
            if (line.indexOf("#") === 0) continue;
            line=line.replace("\r", "");
            if(line.length===0) continue;
            if (!first) {
                res += ",";
            }
            res += '{';
            var cols = line.split(";");
            var cmax = Math.min(cols.length, fields.length);
            for (var c = 0; c < cmax; c++) {
                if (c > 0) res += ",";
                res += '"' + fields[c] + '" : "' + cols[c] + '"';
            }
            res += '}\n';

            first = false;
        }
    }
    res += "]";
    return res;
}

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

//
// gulp.task('resistor-csv2json', function () {
//     var csvParseOptions = {
//         comment: '#',
//         delimiter:';',
//         skip_empty_lines:true
//     }; //based on options specified here : http://csv.adaltas.com/parse/
//     //['Value','Tolerance','Comment']
//
//     return gulp.src("./src/myresistors.csv")
//         .pipe(csv2json(csvParseOptions))
//         .pipe(grename({extname: '.json'}))
//         .pipe(gulp.dest('data'))
// });