local Unlocker, awful, rotation = ...

if awful.player.class2 ~= "PALADIN" then return end

local blue = { 0, 181, 255, 1 }
local white = { 255, 255, 255, 1 }
local background = { 0, 13, 49, 1 }

local gui, settings, cmd = awful.UI:New('ds', {
    title = "Dreams{ |cff00B5FFScripts |cffFFFFFF }",
    show = true,
    width = 345,
    height = 220,
    scale = 1,
    colors = {
        title = white,
        primary = white,
        accent = blue,
        background = background,
    }
})

rotation.settings = settings

local statusFrame = gui:StatusFrame({
    colors = {
        background = { 0, 0, 0, 0 },
        enabled = { 30, 240, 255, 1 },
    },
    maxWidth = 600,
    padding = 12,
})

statusFrame:Button({
    spellId = 20473,
    var = "useOOC",
    text = "OOC",
    size = 30
})

-- Welcome
local Welcome = gui:Tab(awful.textureEscape(53601, 16) .. "Welcome!")
Welcome:Text({
    text = "|cff00B5FFInformation",
    header = true,
    paddingBottom = 10,
})

Welcome:Text({
    text = "Set up Macros for your spells you want too use manually like Divine Sacrifice etc.",
    paddingBottom = 10,
})

Welcome:Text({
    text = "(See Macros tab for example)",
    paddingBottom = 10,
})

Welcome:Text({
    text = "|cff00B5FFDiscord",
    header = true,
    paddingBottom = 10,
})

Welcome:Text({
    text = "If you have any suggestions or questions, feel free to join the Discord and let me know!",
    paddingBottom = 10,
})

Welcome:Text({
    text = "|cffFF0099discord.gg/axWkr4sFMJ",
})

local Mode = gui:Tab(awful.textureEscape(53563, 16) .. " Rotation Mode")
Mode:Text({
    text = "|cff00B5FFRotation Mode",
    header = true,
    paddingBottom = 10,
})

Mode:Dropdown({
    var = "mode",
    tooltip = "Select the Rotation Mode.",
    options = {
        { label = awful.textureEscape(20473, 16) .. " PvE", value = "PvE", tooltip = "Use PvE Rotation" },
        { label = awful.textureEscape(53551, 16) .. " PvP", value = "PvP", tooltip = "Use PvP Rotation" },
    },
    placeholder = "None",
    header = "Select Rotation Mode",
})

local Spells = gui:Tab(awful.textureEscape(48782, 16) .. "Spell Settings")
Spells:Text({
    text = "|cff00B5FFSpell Settings",
    header = true,
    paddingBottom = 10,
})

Spells:Slider({
    text = awful.textureEscape(48782) .. "  Holy Light",
    var = "holy_light_friend_hp",
    min = 0,
    max = 100,
    default = 95,
    valueType = "%",
    tooltip = "Use Holy Light if unit has %HP or less"
})

Spells:Slider({
    text = awful.textureEscape(48782) .. "  Holy Light (Tank)",
    var = "holy_light_tank_hp",
    min = 0,
    max = 100,
    default = 95,
    valueType = "%",
    tooltip = "Use Holy Light if unit is Tank and has %HP or less"
})

Spells:Slider({
    text = awful.textureEscape(48825) .. "  Holy Shock",
    var = "holyshockHP",
    min = 0,
    max = 100,
    default = 80,
    valueType = "%",
    tooltip = "Use Holy Shock if unit has %HP or less"
})

Spells:Slider({
    text = awful.textureEscape(61411) .. "  Shield Of Righteousness",
    var = "shieldofrighteousnessMP",
    min = 0,
    max = 100,
    default = 80,
    valueType = "%",
    tooltip = "Use Shield Of Righteousness if you have %MP or less"
})

Spells:Slider({
    text = awful.textureEscape(48788) .. "  Lay On Hands",
    var = "layonhandsHP",
    min = 0,
    max = 100,
    default = 20,
    valueType = "%",
    tooltip = "Use Lay On hands if unit has %HP or less"
})

Spells:Slider({
    text = awful.textureEscape(6940) .. "  Hand Of Sacrifice (Tank)",
    var = "handofsacrificeHP",
    min = 0,
    max = 100,
    default = 60,
    valueType = "%",
    tooltip = "Use Hand Of Sacrifice if tank has %HP or less (Tanks only)"
})

Spells:Slider({
    text = awful.textureEscape(642) .. "  Divine Shield",
    var = "divineshieldHP",
    min = 0,
    max = 100,
    default = 20,
    valueType = "%",
    tooltip = "Use Divine Shield if you have %HP or less"
})

Spells:Slider({
    text = awful.textureEscape(20216) .. "  Divine Favor",
    var = "divinefavorHP",
    min = 0,
    max = 100,
    default = 60,
    valueType = "%",
    tooltip = "Use Divine Favor if unit has %HP or less"
})

Spells:Slider({
    text = awful.textureEscape(31884) .. "  Avenging Wrath",
    var = "avengingwrathHP",
    min = 0,
    max = 100,
    default = 40,
    valueType = "%",
    tooltip = "Use Avenging Wrath if unit has %HP or less"
})

Spells:Slider({
    text = awful.textureEscape(54428) .. "  Divine Plea",
    var = "divinepleaMP",
    min = 0,
    max = 100,
    default = 60,
    valueType = "%",
    tooltip = "Use Divine Plea if unit has %MP or less"
})

Spells:Slider({
    text = awful.textureEscape(31842) .. "  Divine Illumination",
    var = "divineilluminationMP",
    min = 0,
    max = 100,
    default = 60,
    valueType = "%",
    tooltip = "Use Divine Illumination if unit has %MP or less"
})

local names = {}
awful.fullGroup.loop(function(friend)
    table.insert(names, friend.name)
end)

local options = {
    { label = "None", value = "None" },
}

if names then
    for i, name in ipairs(names) do
        table.insert(options, { label = name, value = name })
    end
end

Spells:Text({
    text = awful.textureEscape(53563) .. "Beacon of Light",
})

Spells:Text({
    text =
    "For now, because a bug in the Awful Framework, just set your Unit as Focus. Dropdown is coming back when the Awful Devs fixed it.",
})

Spells:Text({
    text = awful.textureEscape(53601) .. "Sacred Shield",
})

Spells:Text({
    text =
    "For now, because a bug in the Awful Framework, just set your Unit as Focus. Dropdown is coming back when the Awful Devs fixed it.",
})

local Toggles = gui:Tab(awful.textureEscape(6064, 16) .. "Toggles")
Toggles:Text({
    text = "|cff00B5FFToggles",
    header = true,
    paddingBottom = 10,
})

Toggles:Checkbox({
    text = "Use Holy Light",
    var = "useholylight",
    tooltip = "Use Holy Light",
    default = true
})

Toggles:Checkbox({
    text = "Use Holy Shock",
    var = "useholyshock",
    tooltip = "Use Holy Shock",
    default = true
})

Toggles:Checkbox({
    text = "Use Lay On Hands",
    var = "uselayonhands",
    tooltip = "Use Lay On Hands",
    default = true
})

Toggles:Checkbox({
    text = "Use Hand Of Sacrifice (Tank)",
    var = "usehandofsacrifice",
    tooltip = "Use Hand Of Sacrifice (Tanks only)",
    default = true
})

Toggles:Checkbox({
    text = "Use Divine Shield",
    var = "usedivineshield",
    tooltip = "Use Divine Shield",
    default = true
})

Toggles:Checkbox({
    text = "Use Divine Favor",
    var = "usedivinefavor",
    tooltip = "Use Divine Shield",
    default = true
})

Toggles:Checkbox({
    text = "Use Avenging Wrath",
    var = "useavengingwrath",
    tooltip = "Use Divine Shield",
    default = true
})

Toggles:Checkbox({
    text = "Use Shield Of Righteousness",
    var = "useshieldofrighteousness",
    tooltip = "Use Shield Of Righteousness",
    default = true
})

Toggles:Checkbox({
    text = "Use Divine Plea",
    var = "usedivineplea",
    tooltip = "Use Divine Plea",
    default = true
})

Toggles:Checkbox({
    text = "Use Divine Illumination",
    var = "usedivineillumination",
    tooltip = "Use Divine Illumination",
    default = true
})

Toggles:Checkbox({
    text = "Use Cleanse",
    var = "usecleanse",
    tooltip = "Use Cleanse",
    default = true
})

local Macros = gui:Tab(awful.textureEscape(1706, 16) .. "Macros")
Macros:Text({
    text = "|cff00B5FFMacros",
    header = true,
    paddingBottom = 10,
})

Macros:Text({
    text = awful.textureEscape(64205) .. "  Divine Sacrifice",
    header = true,
    paddingBottom = 10,
})

Macros:Text({ text = "#showtooltip Divine Sacrifice" })
Macros:Text({ text = "/awful cast Divine Sacrifice" })
