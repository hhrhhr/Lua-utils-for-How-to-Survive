package.path = "./?.luac;./?.lua"
require("util_binary_writer")

local dir = arg[1] or "."


local w = BinaryWriter
w:open(dir .. "/part_4_new.bin")

for j = 1, 2 do
    -- read .fnt
    local r = assert(io.open("./fonts/font_new_" .. j .. ".fnt"))
    local line
    local t1, t2, t3, t4, t5 = {}, {}, {}, {}, {}
    local chars = {}
    -- 1st line
    line = r:read("*l")
    for k, v in string.gmatch(line, "(%w+)=(%w+)") do
        t1[k] = tonumber(v)
    end
    -- 2nd line
    line = r:read("*l")
    for k, v in string.gmatch(line, "(%w+)=(%w+)") do
        t2[k] = tonumber(v)
    end
    -- 3rd line
    line = r:read("*l")
    -- 4rd line
    line = r:read("*l")
    for k, v in string.gmatch(line, "(%w+)=(%w+)") do
        t4[k] = tonumber(v)
    end
    -- chars
    for i = 1, 255 do
        local t = {0.0, 0.0, 0, 0, 0, 0, 0, 666}
        table.insert(chars, t)
    end
    for i = 1, t4.count do
        line = r:read("*l")
        local t = {}
        for k, v in string.gmatch(line, "(%a+)=([-%d]+)") do
            t[k] = tonumber(v)
        end
        chars[t.id] = {
            t["width"], t["xadvance"], t["x"], t["y"], 
            t["width"], t["height"], t["page"], 666}
    end
    r:close()


    w:uint32(36 + 20 * 255 + t2.pages * t2.scaleW * t2.scaleH * 4 - 8)
    w:uint32(0)
    w:uint32(255)
    w:uint32(1)
    w:uint32(t2.scaleW)
    if j == 1 then
        w:float32(50.0)
        w:float32(0.0)
        w:float32(7.0)
        w:float32(-3.0)
    else
        w:float32(31.0)
        w:float32(0.0)
        w:float32(-9.0)
        w:float32(-3.0)
    end

    for i = 1, 255 do
--print(i, chars[i][1], chars[i][2], chars[i][3], chars[i][4], chars[i][5], chars[i][6], chars[i][7], chars[i][8])
        w:float32(chars[i][1]) -- width
        w:float32(chars[i][2]) -- xadvance
        w:uint16(chars[i][3])  -- x
        w:uint16(chars[i][4])  -- y
        w:uint16(chars[i][5])  -- width
        w:uint16(chars[i][6])  -- height
        w:uint16(chars[i][7])  -- page
        w:uint16(chars[i][8])  -- ???
    end

    local bmp = assert(io.open("./fonts/font_new_" .. j .. ".bmp", "rb"))
    local size = bmp:seek("end")
    bmp:seek("set", 54)
    local data = bmp:read(size - 54)
    w:str(data)
    bmp:close()
end

w:close()
