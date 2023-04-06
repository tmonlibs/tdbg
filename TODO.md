TODO
----

[x] External shell will be created as separate utility in Lua, let's name it `tdbg` which will use Tarantool as mere Lua interpreter, and for access to internal structures and modules. That's why go- or python-based solution will not fly here.

1. Debugger mode
   [x] Integrate debugger support commands 'break', 'cont', 'watch', etc. (Borrow from Tarantool `luadebug.lua`)
   [x] Activate debugger mode via `-d`;
   [ ] Switch to `term.colors` for colored output;
   [ ] Extract to file command parsing code;
   [ ] Introduce to config extensibility mechanism;
   [ ] Integrated documentation for Tarantool modules and functions. Extensibility mechanism here;

2. All the useful goodies expected from REPL:
   [ ] Lua syntax highlighting (croissant);
   [ ] Persistent history;
   [ ] Multiline;
   [ ] Formatted/readable data inspection;
   [ ] Auto-completion;
   [ ] Command help;
   [ ] Switch to debugger mode;
3. SQL:
   [ ] Syntax highlighting for SQL;
   [ ] Tabulated output for executed queries;
   [ ] Paging support;
   [ ] Execution plans;
   [ ]  Counters;
4. Profiler(s) [from `luacov` to `sysprof`];
