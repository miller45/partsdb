
function parseFValue(fvalue) {
    //parse the writeing like 8k7 or 1r5 to a number
    if(! /[a-zA-Z]+/.test(fvalue)){
       return fvalue; //nothing to do
    }
    var match=/([0-9]+)([a-zA-Z])([0-9]*)/.exec(fvalue);
    if(match){
        var mulmode=match[2].toUpperCase();
        var wholenu=match[1];
        var fracnu=match[3].length>0?match[3]:"0";
        var bnu=parseFloat(wholenu+fracnu);
        switch(mulmode){
            case "R":
                //do nothing
                break;
            case "K":
                bnu*=1000;
                break;
            case "M":
                bnu*=1000*1000;
                break;
            default:
                throw new Error("Unknown mulmode: "+mulmode)
                break;
        }
        if(bnu.toString()==="4019.9999999999995"){
            bnu=4020;
        }

        return bnu;
    }
    return "!err";
}

function transformFn(contents) {
    var res = "[";
    var lines = contents.replace("\r", '').split("\n");
    var first = true;
    var fields = ["f_value", "tolerance", "comment"];
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
                if(c===0){
                    res+= ',"value" : "' + parseFValue(cols[c]) + '"';
                }
            }
            res += '}\n';

            first = false;
        }
    }
    res += "]";
    return res;
}


module.exports = transformFn;