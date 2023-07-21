local Unlocker, awful, rotation = ...
local holy = rotation.paladin.holy
local class = awful.player.class2
local currentMode = nil

if class ~= "PALADIN" then
    return
end

awful.print("|cffFFFFFFDreams{ |cff00B5FFScripts |cffFFFFFF} - Holy Loaded!")
awful.print("|cffFFFFFFDreams{ |cff00B5FFScripts |cffFFFFFF} - Version: 2.0.1")


holy:Init(function()
    if rotation.settings.mode ~= currentMode then
        currentMode = rotation.settings.mode
        if rotation.settings.mode == "PvE" then
            awful.print("|cffFFFFFFDreams{ |cff00B5FFScripts |cffFFFFFF} - Roation Mode: PvE")
        elseif rotation.settings.mode == "PvP" then
            awful.print("|cffFFFFFFDreams{ |cff00B5FFScripts |cffFFFFFF} - Roation Mode: PvP")
        end
    end

    if rotation.settings.mode == "PvE" then
        rotation.APL_PvE()
    elseif rotation.settings.mode == "PvP" then
        rotation.APL_PvP()
    end
end)