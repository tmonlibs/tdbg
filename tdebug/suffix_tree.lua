local fio = require 'fio'

local suffix_tree = {}

local suffix_arrays = {} -- memoize file x tree resuls
local normalized_files = {} -- memoize normalization results

--[[
    Normalize `debug.getinfo().source` names:
    - remove leading '@';
    - remove trailing new lines (if any);
    - if there is leading '.' or '..' then calculate full path
      using current directory.
]]
local function normalize_file(file, resolve_dots)
    local srcfile = file
    if not file then
        return ''
    end
    if normalized_files[file] then
        return normalized_files[file]
    end
    file = file:gsub('^@', ''):gsub('\n', '')
    if resolve_dots and file:sub(1,1) == '.' then
        file = fio.abspath(fio.pathjoin(cwd, file))
    end
    normalized_files[srcfile] = file
    return file
end

function suffix_tree.new()
    return suffix_tree
end

-- This function is on a hot path of a debugger hook.
-- Try very hard to avoid wasting of CPU cycles, so reuse
-- previously calculated results via memoization
function suffix_tree.build_array(file, resolve_dots)
    local decorated_name = file
    if suffix_arrays[decorated_name] ~= nil then
        return suffix_arrays[decorated_name]
    end

    local suffixes = {}
    file = normalize_file(file, resolve_dots)
    --[[
        we would very much prefer to use simple:
           for v in file:gmatch('[^/]+') do
        loop here, but string.gmatch is very slow
        and that we actually need here are simple strchr's.
    ]]
    local i = 0
    local j
    local v
    repeat
        j = file:find('/', i, true)
        if j ~= nil then
            v = file:sub(i, j - 1)
            if v ~= '.' then -- just skip '.' for current dir
                if v == '..' then
                    table.remove(suffixes)
                else
                    table.insert(suffixes, 1, v)
                end
            end
            i = j + 1
        end
    until j == nil
    -- don't forget to process the trailing segment
    v = file:sub(i, #file)
    if v ~= '.' then -- just skip '.' for current dir
        if v == '..' then
            table.remove(suffixes)
        else
            table.insert(suffixes, 1, v)
        end
    end

    suffix_arrays[decorated_name] = suffixes
    return suffixes
end

-- Merge suffix array A to the tree T:
--   Given input array ['E.lua','C','B'] which is suffix array
--   corresponding to the input path '@B/./C/E.lua',
--   we build tree of a form:
--     T['E.lua']['C']['B'] = {}
function suffix_tree.append_array(T, A)
    assert(type(T) == 'table')
    assert(type(A) == 'table')
    if #A < 1 then
        return
    end
    local C = T -- advance current node, starting from root
    local P -- prior node
    for i = 1, #A do
        local v = A[i]
        if not C[v] then
            C[v] = {}
            C[v]['$ref'] = 1 --reference counter
        else
            C[v]['$ref'] = C[v]['$ref'] + 1
        end
        P = C
        C = C[v]
    end
    local last = A[#A]
    P[last]['$f'] = true
end


-- lookup into suffix tree T given constructed suffix array S
function suffix_tree.lookup_array(T, S)
    if #S < 1 then
        return false
    end
    -- we need to make sure that at least once
    -- we have matched node inside of loop
    -- so bail out immediately if there is no any single
    -- match
    if T[S[1]] == nil then
        return false
    end

    local C = T
    local P -- last accessed node
    local v
    for i = 1, #S do
        v = S[i]
        if C[v] == nil then
            return not not P[S[i - 1]]['$f']
        end
        P = C
        C = C[v]
    end
    return not not P[v]['$f']
end

--[[
    Given suffix tree T try to remove suffix array A
    from the tree. Leafs and intermediate nodes will be
    cleaned up only once their reference counter '$ref'
    will reach 1.
]]
function suffix_tree.remove_array(T, A)
    local C = T
    local mem_walk = {}
    -- walks down tree, remembering pointers for inner directories
    for i = 1, #A do
        mem_walk[i] = C
        local v = A[i]
        if C[v] == nil then
            return false
        end
        C = C[v]
    end

    -- now walk in revert order cleaning subnodes,
    -- starting from deepest reachable leaf
    for i = #A, 1, -1 do
        C = mem_walk[i]
        local v = A[i]
        assert(C[v] ~= nil)
        assert(C[v]['$ref'] >= 1)
        C[v]['$ref'] = C[v]['$ref'] - 1
        if C[v]['$ref'] <= 1 then
            mem_walk[i] = nil
            C[v] = nil
        end
    end
end

return suffix_tree
