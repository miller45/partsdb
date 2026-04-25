var fn = "C:\\Users\\rklein\\Documents\\eagle\\spinner\\controlboard.top.drill.tap";

var fs = require('fs');
var path = require('path');
var dosls = "\r\n";

var workerObject = function () {
    this.filels = "\n";
    this.outdir = "";
    this.filebasename = "";
    this.process = function (data) {

        if (data.indexOf(dosls)) {
            this.filefs = dosls;
        }
        var lines = data.split(this.filefs);
        //remark incomptible lines
        for (var i = 0; i < lines.length; i++) {
            lines[i] = lines[i].replace(/^(S[0-9]+)/, '( $1 )')
        }
        var outfile = path.join(this.outdir, this.filebasename) + ".nc";
        var tblob = lines.join(this.filefs);
        fs.writeFile(outfile, tblob, 'utf8');
        //return lines.join(this.filefs);
    };
    this.execute = function (fn) {
        var that = this;
        this.outdir = path.dirname(fn);
        this.filebasename = fn.substr(this.outdir.length + 1).replace(".tap", "");
        fs.readFile(fn, 'utf8', function (err, data) {
            that.process(data);
        });
    };
};

var wo = new workerObject();
wo.execute(fn);




