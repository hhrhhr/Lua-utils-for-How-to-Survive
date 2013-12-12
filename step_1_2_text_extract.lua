package.path = "./?.luac;./?.lua"
require("util_binary_reader")

local dir = arg[1] or "."
local no_convert = (arg[2] or nil)

print()

local source = {}
if no_convert ~= nil then
    for i = 1, 256 do
        table.insert(source, i)
    end
else
    source = {
     48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  97,  98,  99, 100, 101, 102,  -- 16
    103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118,  -- 32
    119, 120, 121, 122,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  -- 48
     77,  78,  79,  80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90,  32,  61,  -- 64
     47,  58,  43,  39,  44,  34,  46,  45, 162,  62,  60,  33,  63,  95,  91,  93,  -- 80
     40,  41, 233, 232, 224, 234, 249,  37, 164, 244, 169, 151,  36,  38,  42,  59,  -- 96
     64,  92,  94,  96, 123, 124, 125, 126, 128, 130, 131, 132, 133, 140, 145, 146,  -- 112
    147, 148, 149, 150, 151, 152, 153, 156,  32, 163, 165, 168, 170, 173, 174, 176,  -- 128
    181, 183, 187, 188, 189, 190, 191, 192, 193, 194, 197, 198, 199, 200, 201, 202,  -- 144
    203, 207, 212, 217, 219, 220, 225, 226, 230, 231, 235, 238, 239, 251, 252, 178,  -- 160
     64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  -- 176
     64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  -- 192
     64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  -- 208
     64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  -- 224
     64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  -- 240
     64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64   -- 256
    }
end


local r = BinaryReader
r:open(dir .. "/part_3.bin")

local lang = {}
local i = 0
while r:pos() < r:size() do
    local t = {}
    t.size = r:uint32()
    t.unkn = r:uint32()

    local c = {}
    for j = 1, t.size/2 do
        local char = r:uint8()
        if char ~= 0 then
            char = string.char(source[char])
        else
            char = ""
        end
        table.insert(c, char)
        assert(0 == r:uint8(), "!!! " .. r:pos())
    end
    t.str = table.concat(c)
    table.insert(lang, t)
    i = i + 1
end
r:close()

local w = assert(io.open(dir .. "/text_orig.txt", "w+"))
for k, v in ipairs(lang) do
    if v.size == 2 then
        if v.unkn ~= 0 then
            assert(false, "!!! " .. k)
        end
    elseif k == 68 then
        w:write(string.format("%4d [%10u] = ", k, v.unkn))
        w:write(string.rep("_", 31))
        for i=31, 255 do w:write(string.char(i)) end
        w:write("\n")
    else
        w:write(string.format("%4d [%10u] = %s\n", k, v.unkn, v.str))
    end
end
w:close()
