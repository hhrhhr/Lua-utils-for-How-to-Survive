package.path = "./?.luac;./?.lua"
require("util_binary_writer")

local dir = arg[1] or "."

local r = assert(io.open(dir .. "/part_0.bin"))
local strings = 0
for i = 1, 3 do
    strings = r:read()
end
r:close()

local str = {}
for i = 1, strings do
    local t = {}
    t.size = 0
    t.unkn = 0
    t.str = ""
    table.insert(str, t)
end

local cnt = 1
for line in io.lines(dir .. "/text_new.txt") do
    for i, u, s in string.gmatch(line, "(%d+) %[%s*(%d+)%] = (.+)") do
        i = tonumber(i)
        str[i].size = #s
        str[i].unkn = u
        str[i].str = s
    end
    cnt = cnt + 1
end

local w = BinaryWriter
w:open(dir .. "/part_3_new.bin")

for k, v in ipairs(str) do
    w:uint32((v.size + 1) * 2)
    w:uint32(v.unkn)
    for i = 1, v.size do
        w:str(string.sub(v.str, i, i))
        w:str("\0")
    end
    w:str("\0\0")
end

w:close()
