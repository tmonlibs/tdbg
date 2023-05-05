local conf      = require "tdebug.conf"
local tdo       = require "tdebug.do"
local runChunk  = tdo.runChunk
local banner    = tdo.banner

local prompt = 'sql> '
local LuaPrompt = require "croissant.luaprompt"

local function repl()
    local history = tdo.loadHistory()
    local multiline = false
    local finished = false

    _G.quit = function()
        finished = true
    end

    banner()

    while not finished do
        local code = LuaPrompt {
            prompt      = prompt,
            multiline   = multiline,
            history     = history,
            tokenColors = conf.syntaxColors,
            help        = require(conf.help),
            quit        = _G.quit
        }:ask()

        if code ~= "" and (not history[1] or history[1] ~= code) then
            table.insert(history, 1, code)

            tdo.appendToHistory(code)
        end

        if runChunk((multiline or "") .. code) then
            multiline = (multiline or "") .. code .. "\n"
        else
            multiline = nil
        end
    end
end

return {
    repl    = repl,
    runFile = runFile,
}
