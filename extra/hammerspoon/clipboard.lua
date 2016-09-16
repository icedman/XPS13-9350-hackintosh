--[[
   base on https://github.com/victorso/.hammerspoon/blob/master/tools/clipboard.lua
   Modified by Marvin Sanchez

   save clipboard copies to textfile
]]--


local cbFile = hs.configdir .. "/../clipboard_history.txt"

snd = nil -- hs.sound.getByName("Pop")

-- Feel free to change those settings
local frequency = 0.8 -- Speed in seconds to check for clipboard changes. If you check too frequently, you will loose performance, if you check sparsely you will loose copies
local cbOpen = false

-- Don't change anything bellow this line
local jumpcut = hs.menubar.new()
local pasteboard = require("hs.pasteboard") -- http://www.hammerspoon.org/docs/hs.pasteboard.html
local last_change = pasteboard.changeCount() -- displays how many times the pasteboard owner has changed // Indicates a new copy has been made

function pasteboardToClipboard(item)

   if cbOpen == false then
      return
   end

   local f = assert(io.open(cbFile, "a"))
   f:write(item)
   f:write("\n\n-----\n\n")
   f:close()
   
   if snd == nil then
   	  return
   end 
	   
   snd:play()

end


-- If the pasteboard owner has changed, we add the current item to our history and update the counter.
function storeCopy()
   now = pasteboard.changeCount()
   if (now > last_change) then
      current_clipboard = pasteboard.getContents()
      -- asmagill requested this feature. It prevents the history from keeping items removed by password managers
      if (current_clipboard == nil and honor_clearcontent) then
        --  clearLastItem()
      else
         pasteboardToClipboard(current_clipboard)
      end
      last_change = now
   end
end

function toggleCB()
    cbOpen = not cbOpen
    jumpcut:setTitle("✂")
    if cbOpen then
        jumpcut:returnToMenuBar()
        timer:start()
    else
        jumpcut:removeFromMenuBar()
        timer:stop()
    end
end

function clearCB()
    local f = assert(io.open(cbFile, "w"))
    f:close()
end

--Checks for changes on the pasteboard. Is it possible to replace with eventtap?
timer = hs.timer.new(frequency, storeCopy)

menuData = {}
table.insert(menuData, {title="Clear", fn = function() clearCB() end })
jumpcut:setMenu(menuData)

hs.hotkey.bind({"cmd", "shift"}, "v", toggleCB)
