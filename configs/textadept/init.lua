
-- keys
textadept.editing.AUTOPAIR=false

buffer.set_theme(
	not CURSES and "dark" or "term",
	--{font = 'PT Sans',fontsize=14}
	--{font = 'DejaVu Sans Condensed',fontsize=13}
	--{font = 'DejaVu Sans',fontsize=13}
	{font = 'Input Sans',fontsize=13}
	--{font = 'iosevka',fontsize=11}
	--{font = 'Liberation Sans',fontsize=15}
	--{font = 'Ubuntu Condensed',fontsize=14}
	)

package.path = "/opt/textadept/modules/?/init.lua;" .. package.path
package.path = "/opt/textadept/modules/?.lua;" .. package.path
local home = os.getenv"HOME"
package.path = home.."/.textadept/textadept-vi/?.lua;" .. package.path
package.cpath = home.."/.textadept/textadept-vi/?.so;" .. package.cpath
--_G.vi_mode = require 'vi_mode' 

events.connect(events.LEXER_LOADED, function(lang)
    buffer.tab_width = 8
    buffer.use_tabs = true
require('elastic_tabstops').enable()

local property = buffer.property
property["color.cyan"]	= 0xc0c000
property["color.yellow"]	= 0x00c0c0
property["color.white"]	= 0xc0c0c0
property["color.magenta"]	= 0xc000c0
property['style.class'] 	= 'fore:%(color.yellow),bold'
property['style.comment'] 	= 'fore:%(color.green)'
property['style.constant'] 	= 'fore:%(color.cyan)'
property['style.embedded'] 	= '%(style.keyword),back:%(color.black)'
property['style.error'] 	= 'fore:%(color.red),bold'
property['style.function'] 	= 'fore:%(color.blue)'
property['style.identifier']	= ''
property['style.keyword'] 	= 'fore:%(color.yellow)'
property['style.label'] 	= 'fore:%(color.red),bold'
property['style.number'] 	= 'fore:%(color.cyan)'
property['style.operator'] 	= 'fore:%(color.white)'
property['style.preprocessor'] 	= 'fore:%(color.magenta)'
property['style.regex'] 	= 'fore:%(color.cyan),bold'
property['style.string'] 	= 'fore:%(color.cyan)'
property['style.type'] 	= 'fore:%(color.magenta)'
property['style.variable'] 	= 'fore:%(color.blue),bold'
property['style.whitespace'] 	= ''
end)



local function send_selection_to_tmux()
  textadept.editing.select_paragraph()
  local txt = buffer:get_sel_text();
  local fh = assert(io.open('/tmp/mytmux','w'))
  fh:write(txt)
  io.close(fh)
  spawn('tmux load-buffer /tmp/mytmux ; paste-buffer -d')
--  spawn('tmux set-buffer "' .. txt .. '"\n',nil,print,print,print);
--  spawn("tmux paste-buffer -d",nil,print,print,print);
end

keys.ct = send_selection_to_tmux

