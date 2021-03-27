var fs = require('fs');
var path = require('path');

const BASEPATH =  path.dirname(__dirname)+'/';
const STRATEGIES_PATH = BASEPATH+'BeardedSpice/MediaStrategies/';
const MANIFEST = STRATEGIES_PATH+'manifest.json';
const STRATEGY_EXT = '.js';
const SUPPORTED_STRSATEGIES_MD_FILE_PATH = BASEPATH+'docs/supported-strategies.md';
const MD_HEADER = '## Supported web media players.\n\n';


try {
    let out = {};
    let mdOut = MD_HEADER;

    let re = /\'\**(.+?)\'/g;
    fs.readdirSync(STRATEGIES_PATH).forEach(el => {
        if (path.extname(el) == STRATEGY_EXT) {
            try {
                let stg = fs.readFileSync(STRATEGIES_PATH+el, 'utf8');
                const obj = eval(stg);
                out[path.basename(el, STRATEGY_EXT)] = {'version': obj.version, 'name': obj.displayName};
                mdOut += '- '+obj.displayName;
                if (obj.accepts.method == 'predicateOnTab' && obj.accepts.args.indexOf('URL') > -1) {
                    let list = [];
                    let item;
                    while ((item = re.exec(obj.accepts.format)) !== null) {
                        list.push(item[1]);
                    }
                if (list.length) {
                        mdOut += ' ('+list.join(', ')+')';
                    }
                }
                mdOut +='\n';
            } catch (error) {
                console.error(error)
            }
        }
    });
    fs.writeFileSync(MANIFEST,JSON.stringify(out));
    fs.writeFileSync(SUPPORTED_STRSATEGIES_MD_FILE_PATH,mdOut);
    console.log('Updated files successful');
} catch (error) {
    console.error(error)
}
