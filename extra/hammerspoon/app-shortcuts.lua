-- Sets up application shortcuts - <mods> + <number> - for the top 10 apps
--
-- <mods> + § shows the list of application shortcuts

local function activateApplication(name)
    local app = hs.application.find(name)
    if app then
        hs.application.launchOrFocus(name) --app:activate()
    else
        hs.alert(name .. " is not running", 0.3)
    end
end

function setupApplicationHotkeys(mods, apps)
    local help = ""
    local mods_text = table.concat(mods)

    for index, name in ipairs(apps) do
        if index <= 10 then
            local shortcut = index % 10
            help = help .. mods_text ..
                tostring(shortcut) ..  ": " .. name .. "\n"
            hs.hotkey.bind(mods, tostring(shortcut), function()
                activateApplication(name)
            end)
        end
    end

    help = help:gsub("^%s*(.-)%s*$", "%1")

    hs.hotkey.bind(mods, "§", function() hs.alert(help, 4) end)
end

