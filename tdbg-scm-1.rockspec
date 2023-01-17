package = 'tdbg'

version = 'scm-1'

source  = {
    url    = 'git://github.com/tmonlibs/tdbg.git';
}

description = {
    summary  = "Debugging REPL";
    detailed = [[
    tdbg - a convenient debugging REPL for Tarantool.
    ]];
    homepage = 'https://github.com/tmonlibs/tdbg.git';
    maintainer = "Timur Safin <tsafin@tarantool.org>";
    license  = 'BSD2';
}

dependencies = {
    'lua >= 5.1';
}

build = {
    type = 'builtin';
    modules = {
        ['tdbg'] = 'tdbg/init.lua';
    }
}
