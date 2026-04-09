-- Lucina Engine Widgets Script for MPV
-- VERSION 7.0 (GRADIENT & OPACITY EDITION)

local utils = require 'mp.utils'

local function get_config_path()
    return (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")) .. "/lucina_widgets.conf"
end

local config = {
    clock_enabled = "true", clock_color = "FFFFFF", clock_size = "48", clock_pos_x = "50", clock_pos_y = "50", clock_format = "%H:%M:%S",
    sys_enabled = "true", sys_color = "FFFFFF", sys_size = "20", sys_pos_x = "5", sys_pos_y = "95",
    visualizer_enabled = "true", viz_color = "00FFFF", viz_color_top = "FF00FF", viz_opacity = "00",
    viz_alpha_top = "FF", viz_alpha_bottom = "00", viz_gradient_mode = "true",
    viz_num_bars = "40", viz_max_height = "200", viz_bar_gap = "2",
}

function load_config()
    local f = io.open(get_config_path(), "r")
    if f then
        for line in f:lines() do
            local k, v = line:match("([^=]+)=(.+)")
            if k and v then config[k] = v:gsub("[\r\n]", "") end
        end
        f:close()
    end
end
load_config()
mp.add_periodic_timer(2, load_config)

function hex_to_ass(hex)
    if not hex or #hex ~= 6 then return "FFFFFF" end
    local b, g, r = hex:sub(5,6), hex:sub(3,4), hex:sub(1,2)
    return b .. g .. r
end

local cava_bars = {}

function read_cava_data()
    local f = io.open("/tmp/lucina_cava.data", "r")
    if f then
        local data = f:read("*all")
        f:close()
        local nb = {}
        for v in data:gmatch("(%d+)") do table.insert(nb, tonumber(v)) end
        return nb
    end
    return nil
end

function draw()
    local w, h = mp.get_osd_size()
    if not w or w == 0 then w = 1280; h = 720 end
    
    local newData = read_cava_data()
    if newData and #newData > 0 then cava_bars = newData end
    
    local ass = ""
    
    -- DRAW CAVA WITH GRADIENTS
    if config.visualizer_enabled == "true" and #cava_bars > 0 then
        local num_bars = #cava_bars
        local bw = w / num_bars
        local gap = tonumber(config.viz_bar_gap or 2)
        local max_h = tonumber(config.viz_max_height or 200)
        
        local color_bottom = hex_to_ass(config.viz_color or "00FFFF")
        local color_top = hex_to_ass(config.viz_color_top or "FF00FF")
        local alpha_bottom = config.viz_alpha_bottom or "00"
        local alpha_top = config.viz_alpha_top or "FF"
        
        ass = ass .. "{\\pos(0,0)}{\\p1}"
        
        if config.viz_gradient_mode == "true" then
            -- Gradient Mode: \1vc(top-left, top-right, bottom-right, bottom-left)
            -- \1va(top-left, top-right, bottom-right, bottom-left)
            ass = ass .. string.format("{\\1vc(%s,%s,%s,%s)}{\\1va(&H%s&,&H%s&,&H%s&,&H%s&)}", 
                color_top, color_top, color_bottom, color_bottom,
                alpha_top, alpha_top, alpha_bottom, alpha_bottom)
        else
            -- Solid Mode
            ass = ass .. string.format("{\\1c&H%s&}{\\alpha&H%s&}", color_bottom, alpha_bottom)
        end

        for i, v in ipairs(cava_bars) do
            local bh = (v / 100) * max_h
            if bh < 2 then bh = 2 end
            local x1 = math.floor((i-1)*bw)
            local x2 = math.floor(x1 + bw - gap)
            ass = ass .. string.format("m %d %d l %d %d l %d %d l %d %d ", x1, h, x2, h, x2, h-bh, x1, h-bh)
        end
        ass = ass .. "{\\p0}\n"
    end

    -- Clock
    if config.clock_enabled == "true" then
        local xc, yc = tonumber(config.clock_pos_x or 50)*w/100, tonumber(config.clock_pos_y or 50)*h/100
        ass = ass .. string.format("{\\an5}{\\pos(%d,%d)}{\\fs%d}{\\1c&H%s&}%s\n", 
            xc, yc, tonumber(config.clock_size or 48), hex_to_ass(config.clock_color), os.date(config.clock_format))
    end
    
    mp.set_osd_ass(w, h, ass)
end

mp.add_periodic_timer(0.04, draw)
