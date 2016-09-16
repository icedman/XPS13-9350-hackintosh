-- No animations please:
hs.window.animationDuration = 0

local function exitModalHotkey(hotkey)
    if hotkey then
        hotkey:exit()
    end
end


function centerFrontMostWindow(hotkey)
    local frontMostWindow = hs.window.focusedWindow()
    if not frontMostWindow then return exitModalHotkey(hotkey) end
    local windowFrame = frontMostWindow:frame()
    local screenFrame = frontMostWindow:screen():frame()
    windowFrame.x = (screenFrame.w - windowFrame.w) / 2
    windowFrame.y = (screenFrame.h - windowFrame.h) / 2
    frontMostWindow:setFrame(windowFrame)
    exitModalHotkey(hotkey)
end

-- When maximizing windows, the old frame is stored in memory so that a
-- second maximize can reset it. Window sizes are kept in memory and not
-- persisted (yet)! If there are 50 maximized windows in memory, all old,
-- no longer existing windows are removed (this hardly ever happens).
-- When reloading the configuration all maximized windows are first reset,
-- because otherwise the original settings are lost.

local maximizedWindows = {}
local maximizedWindowCount = 0

local function purgeMaximizedWindowsIfNeeded()
    if maximizedWindowCount < 50 then return end
    local purgeCount = 0
    for id, frame in pairs(maximizedWindows) do
        local window = hs.window.windowForID(id)
        if not window then
            maximizedWindows[id] = nil
            maximizedWindowCount = maximizedWindowCount - 1
            purgeCount = purgeCount + 1
        end
    end
end

local function maximizeWindow(window)
    maximizedWindows[window:id()] = window:frame()
    window:maximize()
    maximizedWindowCount = maximizedWindowCount + 1
    purgeMaximizedWindowsIfNeeded()
end

local function restoreWindow(window)
    local id = window:id()
    window:setFrame(maximizedWindows[id])
    maximizedWindows[id] = nil
    maximizedWindowCount = maximizedWindowCount - 1
end

function toggleFrontMostWindowMaximized(hotkey)
    local frontMostWindow = hs.window.focusedWindow()
    if not frontMostWindow then return exitModalHotkey(hotkey) end
    if maximizedWindows[frontMostWindow:id()] then
        restoreWindow(frontMostWindow)
    else
        maximizeWindow(frontMostWindow)
    end
    exitModalHotkey(hotkey)
end

function toggleFrontMostWindowFullScreen(hotkey)
    local frontMostWindow = hs.window.focusedWindow()
    if not frontMostWindow then return exitModalHotkey(hotkey) end
    frontMostWindow:toggleFullScreen()
    exitModalHotkey(hotkey)
end

local function restoreMaximizedWindows()
    for id, frame in pairs(maximizedWindows) do
        local window = hs.window.windowForID(id)
        if window then restoreWindow(window) end
    end
end

function cleanupWindowManagement()
    restoreMaximizedWindows()
    maximizedWindows = nil
    maximizedWindowCount = nil
end

function moveFrontMostWindow(x, y)
    local frontMostWindow = hs.window.focusedWindow()
    if not frontMostWindow then return end
    local windowFrame = frontMostWindow:frame()
    windowFrame.x = windowFrame.x + x
    windowFrame.y = windowFrame.y + y
    frontMostWindow:setFrame(windowFrame)
end

-- Create the hotkey to bind all kinds of window management functions to
-- The same hotkey, as well as Escape can be used to disable the mode again
function setupWindowManagementModalHotkey(modifiers, key)
    local hotkey = hs.hotkey.modal.new(modifiers, key)
    function hotkey:entered()
        hs.alert.show("Window management mode ON", 0.5)
    end
    function hotkey:exited()
        hs.alert.show("Window management mode OFF", 0.5)
    end
    hotkey:bind({}, "escape", function()
        hotkey:exit()
    end)
    hotkey:bind(modifiers, key, function()
        hotkey:exit()
    end)
    hotkey:bind({}, "g", function()
        hs.grid.show(function ()
            hotkey:exit()
        end)
    end)
    return hotkey
end