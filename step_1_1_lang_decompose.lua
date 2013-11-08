package.path = "./?.luac;./?.lua"
require("util_binary_reader")


local function save_block(source, name, offset, size)
    local BUFFER_SIZE = 65536

    local pos = source:pos()
    source:seek(offset)

    local w = assert(io.open(name, "w+b"))
    local data = ""
    --io.write("\n")
    while size > BUFFER_SIZE do
        data = source:str(BUFFER_SIZE)
        w:write(data)
        size = size - BUFFER_SIZE
        --io.write(".")
    end
    data = source:str(size)
    w:write(data)
    w:close()
    --io.write("\n")

    source:seek(pos)
end


local r = BinaryReader
r:open(arg[1])

local dir = arg[2] or "."
--os.execute("mkdir " .. dir .. " >nul 2>&1")


local h = {}    -- header

h.fourcc = "RKET";              r:idstring(h.fourcc)
h.zero = "\x00\x00\x00\x00";    r:idstring(h.zero)
h.time = r:uint32()    -- unix time
h.unkn = r:uint32()

h.data = {}
for i = 1, 4 do
    h.data[i] = {}
    h.data[i].size = r:uint32()
end
for i = 1, 4 do
    h.data[i].count = r:uint32()
end
h.last = r:str(8)


io.write(string.sub(arg[1], -3))
io.write(string.format(" %10d, (%10d); ", h.time, h.unkn))
for i = 1, 4 do
    io.write(string.format("%8d (%5d), ", h.data[i].size, h.data[i].count))
end
io.write("\n\n")




local name = dir .. "/part_0.bin"
local w = assert(io.open(name, "w+"))

for i = 1, 4 do
    w:write(h.data[i].count .. "\n")
end
w:write(h.time .. "\n")
w:write(h.unkn .. "\n")
w:close()




local pos = r:pos()
io.write("part 1 offset: " .. pos)

for i = 1, h.data[1].count do
    local size = r:uint32()
    local pos = r:pos() + size + 4
    r:seek(pos)
end

local start = pos
pos = r:pos()
local size = pos - start
name = dir .. "/part_1.bin"

io.write(", size: " .. size .. ", name: " .. name .. "\n")
save_block(r, name, start, size)




io.write("part 2 offset: " .. pos)

for i = 1, h.data[2].count do
    local unkn1     = r:uint32()
    local fourcc    = r:uint32()
    local tmp       = r:str(8)  -- skip 8 bytes
    local size      = 0

    if fourcc == 1481851972 then    -- "DDSX"
        size = r:uint32()
    elseif fourcc == 0 then         -- raw
        size = unkn1
    else
        assert(false, "\n\n!!! unknown fourcc: " .. fourcc)
    end

    local pos = r:pos() + size
    r:seek(pos)
end

start = pos
pos = r:pos()
size = pos - start
name = dir .. "/part_2.bin"

io.write(", size: " .. size .. ", name: " .. name .. "\n")
save_block(r, name, start, size)




io.write("part 3 offset: " .. pos)

for i = 1, h.data[3].count do
    local size = r:uint32()

    local pos = r:pos() + size + 4
    r:seek(pos)
end

start = pos
pos = r:pos()
size = pos - start
name = dir .. "/part_3.bin"

io.write(", size: " .. size .. ", name: " .. name .. "\n")
save_block(r, name, start, size)




io.write("part 4 offset: " .. pos)

for i = 1, h.data[4].count do
    local size = r:uint32()

    local pos = r:pos() + size + 4
    r:seek(pos)
end

start = pos
pos = r:pos()
size = pos - start
name = dir .. "/part_4.bin"

io.write(", size: " .. size .. ", name: " .. name .. "\n")
save_block(r, name, start, size)



r:close()
