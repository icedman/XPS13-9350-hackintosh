-- hs.alert("(Re)loading Hammerspoon configuration", 1)

require "terminal"
require "caffeine"
require "clipboard"

function reloadConfiguration()
    removeCaffeine()
    hs.reload()
end

function showDateAndTime()
    hs.alert(os.date("It's %I:%M on %A, %e %B %G"), 2)
end

function panic()
	hs.execute("/usr/local/bin/cscreen -x 1280 -y 800")
	hs.execute("/usr/local/bin/cscreen -x 1440 -y 900")
end

--
-- headphones
--
local headmenu = hs.menubar.new()
--headmenu:setTitle("☊")
local headiconset = false
menuData = {}

function update_audio_icon()
	local headphones = hs.audiodevice.findOutputByName("Headphones (Black Front)")
	local current = hs.audiodevice.defaultOutputDevice()
	if current:name() == headphones:name() then
		if headiconset == false then
			headmenu:setIcon("headphones.png")
			headiconset = true
		end
		headmenu:returnToMenuBar()
	else
	    headmenu:removeFromMenuBar()
	end	
end
update_audio_icon()

function toggle_audio()
	local speakers = hs.audiodevice.findOutputByName("Speaker (Analog)")
	local headphones = hs.audiodevice.findOutputByName("Headphones (Black Front)")
	local current = hs.audiodevice.defaultOutputDevice()
	
	if current:name() == headphones:name() then
		speakers:setDefaultOutputDevice()
	else
		headphones:setDefaultOutputDevice()
	end
	
	update_audio_icon()
end

--
-- Hotkeys
--
local hyper = {"⌘", "⌥", "⌃", "⇧"}

local cmd = {"⌘"}
local mash = {"⌘", "⌥", "⌃"}
local alt = {"⌥"}
local shortcuts = {"⌘", "⌃"}

--hs.hotkey.bind(shortcuts,  "1", function() toggleApplication("Finder") end)
--hs.hotkey.bind(shortcuts,  "2", function() toggleApplication("Safari") end)
--hs.hotkey.bind(shortcuts,  "3", function() toggleApplication("Preview") end)
--hs.hotkey.bind(shortcuts,  "4", function() toggleApplication("TextWrangler") end)
hs.hotkey.bind(shortcuts,  "\\", function() toggleTerminal() end)

hs.hotkey.bind(mash, "=", function() toggleCaffeine() end)
hs.hotkey.bind(mash, "delete", function() sleepNow() end)
hs.hotkey.bind(mash, "-", function() showDateAndTime() end)
hs.hotkey.bind(mash, "r", function() reloadConfiguration() end)
hs.hotkey.bind(cmd, "`", function() toggle_audio() end)
