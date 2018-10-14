#!/usr/bin/env lua

--ps=require'posix'

function read_file_home(name)
	local s
	local i = io.open(os.getenv("HOME").."/"..name)
	if i then
		s = i:read"*a"
	else
		s = "no file"
	end
	i:close()
	return s
end

function output(cmd)
    local i = io.popen(cmd)
    local s = i:read"*a"
    io.close(i)
    return s
end
red="#ff6666"
yellow="#ffff00"

local line
function nextline(txt,color)
    if line ~= "[" then line = line .. "," end
    txt = string.gsub(txt,'\n','')
    addcolor = color == nil and "" or ', "color":"' .. color .. '"'
    line = line .. '{"full_text":"' .. txt .. '"' .. addcolor .. '}'
end

print '{"version":1} ['
for i=0, math.huge do
    line="["
    p=string.match(
    	output"upower -i /org/freedesktop/UPower/devices/battery_BAT0",
    	"percentage: +(%d+)%%")
    if p then
	p=p+0
	nextline("battery "..p.."%", p<30 and red or p<80 and yellow or nil)
    end
    nextline("weather "..output"cat ~/tmp/weather")
    nextline(output"date +'%y.%m.%d %a %H:%M'")
    nextline(read_file_home"tmp/layout")
    line = line.."],"
    print(line)
    if math.fmod(i,200) == 0 then
	os.execute("weather.sh > ~/tmp/weather &")
    end
    os.execute "sleep 5"
    --ps.sleep(5)
end

--rm ~/tmp/weather
