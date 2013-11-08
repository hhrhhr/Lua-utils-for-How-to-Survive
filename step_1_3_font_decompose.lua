package.path = "./?.luac;./?.lua"
require("util_binary_reader")

local dir = arg[1] or "."

--[[
local r = assert(io.open(dir .. "/part_0.bin"))
local fonts = 0
for i = 1, 4 do
    fonts = r:read()
end
r:close()
]]
local fonts = 2

r = BinaryReader
r:open(dir .."/part_4.bin")

for j = 1, fonts do
    local size = r:uint32()
    local zero = r:uint32()
    local count = r:uint32()
    local pages = r:uint32()
    local width = r:uint32()

    local w = assert(io.open(dir .. "/font_orig_" .. j .. ".txt", "w+"))
    w:write(count .. ", ")
    w:write(pages .. ", ")
    w:write(width .. ", ")
    w:write(r:float() .. ".0, ")
    w:write(r:float() .. ".0, ")
    w:write(r:float() .. ".0, ")
    w:write(r:float() .. ".0\n")

    for i = 1, count do
        w:write(i .. ", ")
        w:write(r:float() .. ".0, ")
        w:write(r:float() .. ".0, ")
        w:write(r:uint16() .. ", ")
        w:write(r:uint16() .. ", ")
        w:write(r:uint16() .. ", ")
        w:write(r:uint16() .. ", ")
        w:write(r:uint16() .. ", ")
        w:write(r:uint16() .. "\n")
    end
    w:close()


    local dword = function(x)
        local s = ""
        for i = 1, 4 do
            s = s .. string.char(x % 256)
            x = math.floor(x/256)
        end
        return s
    end

    w = assert(io.open(dir .. "/font_orig_" .. j .. ".bmp", "w+b"))
    local fhdr = 14
    local ihdr = 40
    w:write("BM")
    w:write(dword(fhdr + ihdr + width * width * pages * 4))
    w:write("\0\0\0\0")
    w:write(dword(fhdr + ihdr))
    w:write(dword(ihdr))
    w:write(dword(width))
    w:write(dword(-width * pages))
    w:write("\1\0\32\0")
    w:write("\0\0\0\0\0\0\0\0")
    w:write("\0\0\0\0\0\0\0\0")
    w:write("\0\0\0\0\0\0\0\0")
    local argb = r:str(width * width * pages * 4)
    w:write(argb)
    w:close()
end

r:close()
