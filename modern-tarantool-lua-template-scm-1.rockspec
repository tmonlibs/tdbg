-- name of the package to be published
package = 'modern-tarantool-lua-template'

-- version of the package; it's mandatory, but we don't use it in Tarantool;
-- instead, provide below a specific branch in the package's repository at
-- GitHub and set version to some stub value, e.g. 'scm-1'
version = 'scm-1'

-- url and branch of the package's repository at GitHub
source  = {
    url    = 'git://github.com/tmonlibs/modern-tarantool-lua-template.git';
}

-- general information about the package;
-- for a Tarantool package, we require three fields (summary, homepage, license)
-- and more package information is always welcome
description = {
    summary  = "Modern template of Lua module for Tarantool";
    detailed = [[
    A ready-to-use Lua module template.
    Clone and modify it to create new modules.
    ]];
    homepage = 'https://github.com/tarantool/modulekit.git';
    maintainer = "Don't Forget <to@fill-your.name>";
    license  = 'BSD2';
}

-- Lua version and other packages on which this one depends;
-- Tarantool currently supports strictly Lua 5.1
dependencies = {
    'lua >= 5.1';
}

-- build options and paths for the package;
-- this package distributes modules in pure Lua, so the build type = 'builtin';
-- also, specify here paths to all Lua modules within the package
-- (this package contains just one Lua module named 'modern-tarantool-lua-template')
build = {
    type = 'builtin';
    modules = {
        ['modern-tarantool-lua-template'] = 'modern-tarantool-lua-template/init.lua';
    }
}
