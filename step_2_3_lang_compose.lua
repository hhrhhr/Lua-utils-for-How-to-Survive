package.path = "./?.luac;./?.lua"
require("util_binary_writer")

local function save_block(source, target, size)
    local BUFFER_SIZE = 65536
    local data = ""
    while size > BUFFER_SIZE do
        data = source:read(BUFFER_SIZE)
        target:str(data)
        size = size - BUFFER_SIZE
    end
    data = source:read(size)
    target:str(data)
end


local dir = arg[1] or "."

local w = BinaryWriter
w:open(dir .. "/Common_PC.new")

local r = assert(io.open(dir .. "/part_0.bin"))
local h = {}
for i = 1, 6 do
    h[i] = r:read() -- 1-2-3-4 ; count  1, 2, 3, 4
end                 -- 5-6     ; time, unknown
r:close()


r = {}
local s = {}
for i = 1, 4 do
    local name = dir .. "/part_" .. i .. "_new.bin"
    r[i] = io.open(name, "rb")
    if r[i] == nil then
        name = dir .. "/part_" .. i .. ".bin"
        r[i] = assert(io.open(name, "rb"), "ERROR: file " .. name .. " not opened")
    end
    s[i] = r[i]:seek("end")
    r[i]:seek("set")
end



print("write header...")

w:str("RKET")
w:str("\x00\x00\x00\x00")
w:uint32(h[5])
w:uint32(h[6])

w:uint32(0)
w:uint32(s[2] - h[2] * 4)
w:uint32(s[3])
w:uint32(s[4])

w:uint32(h[1])
w:uint32(h[2])
w:uint32(h[3])
w:uint32(h[4])

w:str("\xAF\xAF\xAF\xAF\xAF\xAF\xAF\xAF")


for i = 1, 4 do
    print("write part " .. i .. "...")
    save_block(r[i], w, s[i])
    r[i]:close()
end

w:close()
