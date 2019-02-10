-- Lua BF++ Interpretter
-- Samuel Taylor
local socket = require('socket')

TOKENS = {
    ['.'] = true, -- Standard out
    [','] = true, -- Standard in
    ['['] = true, -- Loop start
    [']'] = true, -- Loop end
    ['<'] = true, -- Move back a cell
    ['>'] = true, -- Move ahead a cell
    ['+'] = true, -- Add 1 to the current cell
    ['-'] = true, -- Sub 1 from the current cell
    ['#'] = true, -- Open/close file
    ['%'] = true, -- Write val of current cell to file
    ['!'] = true, -- Read a char from file and set it as the current cell
    ['@'] = true, -- Open/close socket to localhost (on port 53333)
    ['&'] = true, -- Read 1 char from the socket and set as current cell
    ['*'] = true, -- Write val of current cell to socket
    ['~'] = true, -- goto cell[value of current cell]
    ['$'] = true, -- toggle character mode
    ['^'] = true  -- open a server socket
}

function run(filename)
    local file = io.open(filename, "r")

    if file == nil then
        print("\x1B[31mERROR: No such file\x1B[0m")
    else
        eval(file)
    end 
end

function only_tokens(file)
    local chr = 1
    local tcode = {}

    while chr ~= nil do
        chr = file:read(1)
        tcode[#tcode + 1] = (TOKENS[chr] ~= nil and chr or nil)
    end

    return tcode
end

function bracemapper(code)
    local stack = {}
    local bracemap = {}

    for pos, tok in ipairs(code) do
        if tok == '[' then
            table.insert(stack, pos)
        elseif tok == ']' then
            local start = table.remove(stack)
            bracemap[start] = pos
            bracemap[pos] = start
        end
    end

    return bracemap
end

function eval(file)
    local code = only_tokens(file)
    local bracemap = bracemapper(code)

    local file = nil
    local sock = nil

    local tape = {0}

    tape.__index = function(table, key)
        table[key] = 0
        return 0
    end

    setmetatable(tape, tape)

    local codeptr = 1
    local tapeptr = 1

    local codelen = #code
    
    local switch = {
        ['>'] = function() 
            tapeptr = tapeptr + 1
            if tape[tapeptr] == nil then 
                tape[tapeptr] = 0 
            end
        end,
        ['<'] = function()
            tapeptr = tapeptr > 1 and tapeptr - 1 or 1
        end,
        ['+'] = function()
            tape[tapeptr] = tape[tapeptr] + 1
            if tape[tapeptr] > 255 then
                tape[tapeptr] = 0
            end
        end,
        ['-'] = function()
            tape[tapeptr] = tape[tapeptr] - 1
            if tape[tapeptr] < 0 then
                tape[tapeptr] = 255
            end
        end,
        ['['] = function()
            if tape[tapeptr] == 0 then
                codeptr = bracemap[codeptr]
            end
        end,
        [']'] = function()
            if tape[tapeptr] ~= 0 then
                codeptr = bracemap[codeptr]
            end
        end,
        [','] = function()
            tape[tapeptr] = string.byte(io.read(1))
        end,
        ['.'] = function()
            io.write(
                string.char(tape[tapeptr])
            )
        end,
        ['#'] = function()
            if file == nil then
                local name = {}
                while tape[tapeptr] ~= 0 do
                    table.insert(name, string.char(tape[tapeptr]))
                    tapeptr = tapeptr + 1
                end

                local str = table.concat(name)
                file = io.open(str)
            else
                io.close(file)
                file = nil
            end
        end,
        ['%'] = function()
            if file ~= nil then
                file:write(tape[tapeptr])
            else    
                error(string.format( "\x1B[31mERROR @ %d: NO FILE OPEN\x1B[0m\n", codeptr))
                return
            end
        end,
        ['!'] = function()
            if file ~= nil then
                local c = file:read(1)

                if c == nil then
                    tape[tapeptr] = string.byte(c)
                else
                    tape[tapeptr] = 0
                end
            else    
                error(string.format( "\x1B[31mERROR @ %d: NO FILE OPEN\x1B[0m\n", codeptr))
                return
            end
        end,
        ['@'] = function()
            if sock == nil then
                local ip = {}
                while tape[tapeptr] ~= 0 do
                    table.insert(ip, string.char(tape[tapeptr]))
                    tapeptr = tapeptr + 1
                end

                local str = table.concat(ip)
                sock = socket.tcp()
                sock:connect(str, 53333)
            else
                sock:close(file)
                sock = nil
            end
        end,
        ['^'] = function()
            if sock == nil then
                local server = socket.bind("*", 53333)
                sock = socket.tcp()
                sock  = server:accept() -- returns the connected client
            else
                sock:close(file)
                sock = nil
            end
        end,
        ['*'] = function()
            if sock ~= nil then
                sock:send(string.char(tape[tapeptr]))
            else
                error(string.format( "\x1B[31mERROR @ %d: NO SOCKET OPEN\x1B[0m\n", codeptr))
            end
        end,
        ['&'] = function()
            if sock ~= nil then
                tape[tapeptr] = string.byte(sock:receive(1))
            else
                error(string.format( "\x1B[31mERROR @ %d: NO SOCKET OPEN\x1B[0m\n", codeptr))
            end
        end,
        ['~'] = function()
            if tape[tapeptr] < codelen then
                codeptr = tape[tapeptr] + 1
            else
                error(string.format( "\x1B[31mERROR @ %d: OUT OF RANGE\x1B[0m\n", codeptr))
            end
        end
    }

    while codeptr <= codelen do
        local tok = code[codeptr]

        switch[tok]()

        codeptr = codeptr + 1
    end
end

function main()
    if arg[1] ~= nil then
        run(arg[1])
    else
        error(string.format( "Uasge: %s <filename>", arg[0]))
    end
end

main()