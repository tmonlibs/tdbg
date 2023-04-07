--[[
local commands_help = {
    {'b.reak.point $location|add_break.point', 'set new breakpoints at module.lua+num', cmd_add_breakpoint},
    {'bd.elete $location|delete_break.point', 'delete breakpoints',  cmd_remove_breakpoint},
    {'bl.ist|list_break.points', 'list breakpoints', cmd_list_breakpoints},
    {'c.ont.inue', 'continue execution', cmd_continue},
    {'d.own', 'move down the stack by one frame',  cmd_down},
    {'e.val $expression', 'execute the statement',  cmd_eval},
    {'f.inish|step_out', 'step forward until exiting the current function',  cmd_finish},
    {'h.elp|?', 'print this help message',  cmd_help},
    {'l.ocals', 'print the function arguments, locals and upvalues',  cmd_locals},
    {'n.ext|step_over', 'step forward by one line (skipping over functions)',  cmd_next},
    {'p.rint $expression', 'execute the expression and print the result',  cmd_print},
    {'q.uit', 'exit debugger', cmd_quit},
    {'s.t.ep|step_into', 'step forward by one line (into functions)', cmd_step},
    {'t.race|bt', 'print the stack trace',  cmd_trace},
    {'u.p', 'move up the stack by one frame',  cmd_up},
    {'w.here $linecount', 'print source code around the current line', cmd_where},
}
]]

local commands_map = {}

function commands_map.build(commands, writeln)
    local gen_commands = {}
    if writeln ~= nil then
        commands_map.writeln = writeln
    end

    for _, cmds in ipairs(commands) do
        local c, h, f = unpack(cmds)
        local first = true
        local main_cmd
        local pattern = '^[^%s]+%s+([^%s]+)'
        --[[
            "expected argument" is treated as a global attribute,
            active for all command's aliases.
        ]]
        local arg_exp = false

        for subcmds in c:gmatch('[^|]+') do
            local arg = subcmds:match(pattern)
            subcmds = subcmds:match('^([^%s]+)')
            local cmd = ''
            local gen = subcmds:gmatch('[^.]+')
            local prefix = gen()
            local suffix = ''
            local segment = prefix

            -- remember the first segment (main shortcut for command)
            if first then
                main_cmd = prefix
                arg_exp = arg
            end

            repeat
                cmd = cmd .. segment
                gen_commands[cmd] = {
                    help = h,
                    handler = f,
                    first = first,
                    suffix = suffix,
                    aliases = {},
                    arg = arg_exp
                }
                if first then
                    table.insert(gen_commands, main_cmd)
                else
                    assert(#main_cmd > 0)
                    table.insert(gen_commands[main_cmd].aliases, cmd)
                end
                first = false
                segment = gen()
                suffix = suffix .. (segment or '')
            until not segment
        end
    end
    commands_map.map = gen_commands
    return commands_map
end

-- Recognize a command, then return command handler,
-- 1st argument passed, and flag what argument is expected.
function commands_map.match(self, line)
    local gen = line:gmatch('[^%s]+')
    local cmd = gen()
    local arg1st = gen()
    local map = assert(self.map)
    local entry = map[cmd]
    if not entry then
        return nil
    else
        return entry.handler, arg1st, entry.arg
    end
end

commands_map.writeln = print

local colors = require 'tdebug.colors'

function commands_map.help(self)
    local cmd_map = assert(self.map)
    for _, v in ipairs(cmd_map) do
        local map = cmd_map[v]
        if #map.aliases > 0 then
            local fun = require 'fun'
            local txt = ''
            fun.each(function(x) txt = txt .. ', ' .. colors.yellow(x) end,
                     map.aliases)
            commands_map.writeln(colors.blue(v) .. ', ' .. string.sub(txt, 3, #txt) ..
                        ' ' .. (map.arg or ''))
        else
            commands_map.writeln(colors.blue(v) .. ' ' .. (map.arg or ''));
        end
        commands_map.writeln(colors.grey('    -- ' .. map.help))
    end
    commands_map.writeln('')

    return false
end


return commands_map
