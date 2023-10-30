local Unlocker, awful, rotation = ...
local holy = rotation.paladin.holy
local Spell = awful.Spell
local player, target, focus = awful.player, awful.target, awful.focus

awful.Populate({
    leveling_lay_on_hands            = Spell({ 48788, 27154, 10310, 2800, 633 }, { heal = true, IgnoreCasting = true }),
    leveling_beacon_of_light         = Spell(53563, { beneficial = true }),
    leveling_sacred_shield           = Spell(53601, { beneficial = true }),
    leveling_holy_shock              = Spell({ 48782, 48781, 27136, 27135, 25292, 10329, 10328, 3472, 1042, 1026, 647, 639, 635 }, { heal = true, alwaysFace = true }),
    leveling_flash_of_light          = Spell({ 48785, 48784, 27137, 19943, 19942, 19941, 19940, 19939, 19750 }, { heal = true }),
    leveling_holy_light              = Spell({ 48782, 48781, 27136, 27135, 25292, 10329, 10328, 3472, 1042, 1026, 647, 639, 635 }, { heal = true }),
    leveling_hand_of_sacrifice       = Spell(6940, { beneficial = true }),
    leveling_cleanse                 = Spell(4987, { effect = "magic", beneficial = true }),
    leveling_divine_shield           = Spell(642, { beneficial = true, IgnoreCasting = true }),
    leveling_divine_favor            = Spell(20216, { beneficial = true }),
    leveling_judgement_of_wisdom     = Spell(53408, { damage = "magic" }),
    leveling_judgement_of_light      = Spell(20271, { damage = "magic" }),
    leveling_divine_plea             = Spell(54428, { beneficial = true }),
    leveling_divine_illumination     = Spell(31842, { beneficial = true }),
    leveling_seal_of_wisdom          = Spell(20166, { beneficial = true }),
    leveling_auto_attack             = Spell(6603),
    leveling_avenging_wrath          = Spell(31884, { beneficial = true }),
    leveling_shield_of_righteousness = Spell({ 53600, 61411 }),
}, holy, getfenv(1))

local wasCasting = {}
function holy.WasCastingCheck()
    local time = awful.time
    if player.casting then
        wasCasting[player.castingid] = time
    end
    for spell, when in pairs(wasCasting) do
        if time - when > 0.200 + awful.buffer then
            wasCasting[spell] = nil
        end
    end
end

local tankBuffs = {
    ["Flask of Stoneblood"] = true,
    ["Shield Wall"] = true,
    ["Shield Block"] = true,
    ["Holy Shield"] = true,
    ["Righteous Fury"] = true,
    ["Bear Form"] = true,
    ["Savage Defense"] = true,
    ["Frenzied Regeneration"] = true,
    ["Frost Presence"] = true
}

local function isTank(unit)
    if unit.role == "tank" or unit.aggro or unit.threat == 3 then
        return true
    end

    if unit.buffs then
        for i, buff in ipairs(unit.buffs) do
            local name = unpack(buff)
            if tankBuffs[name] then
                return true
            end
        end
    end

    return false
end

awful.onTick(function()
    awful.fullGroup.loop(function(unit)
        if isTank(unit) then
            unit.setFocus()
        end
    end)

    if not focus.exists then return end
    if player.casting then return end
    if player.buff("Drink") then return end

    local path = awful.path(player, focus)
    path = path.simplify(1, 1)

    if focus.distance <= 20 and focus.los then return end
    if focus.distance >= 20 or not focus.los then
        path.draw()
        path.follow()
    end
end)

local satchelOfHelpfulGoods = awful.Item(51999)
awful.onTick(function()
    if not rotation.settings.uselayonhands then return end

    local mode, subMode = GetLFGMode(LE_LFG_CATEGORY_LFD)

    -- State: Not Queued, Queue for Random Dungeon
    if mode == nil then
        LFDQueueFrameFindGroupButton:Click()
    end

    -- State: Dungeon Found, Accept Invite
    if mode == "proposal" then
        LFGDungeonReadyDialogEnterDungeonButton:Click()
    end

    -- State: Dungeon finished, Leave Party
    satchelOfHelpfulGoods:Update(function(item)
        if not item.usable then return end
        if item:Use() then
            return awful.call("RunMacroText", "/run LeaveParty()")
        end
    end)
end)

local function filter(obj)
    return obj.los and not obj.dead
end

local startAttack = awful.unlock("StartAttack")

leveling_auto_attack:Callback(function(spell)
    local enemy = awful.enemies.within(5).filter(filter).lowest

    if not enemy or not enemy.combat then
        return
    end

    if target.exists and not spell.current then
        startAttack()
    end
end)

local debuffType = {
    ["Magic"] = true,
    ["Poison"] = true,
    ["Disease"] = true
}

leveling_cleanse:Callback(function(spell)
    if not spell.known then return end
    awful.fullGroup.within(40).filter(filter).loop(function(friend)
        if friend.hp < 60 then return end

        for i = 1, #friend.debuffs do
            local _, _, _, type = unpack(friend['debuff' .. i])
            if debuffType[type] then
                return spell:Cast(friend)
            end
        end
    end)
end)

leveling_lay_on_hands:Callback(function(spell)
    if not spell.known then return end
    local friend = awful.fullGroup.within(40).filter(filter).lowest
    if not friend then return end

    if friend.hp < rotation.settings.layonhandsHP then
        if spell:Cast(friend) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

leveling_shield_of_righteousness:Callback(function(spell)
    if not rotation.settings.useshieldofrighteousness then return end
    if not spell.known then return end

    local enemy = awful.enemies.within(5).filter(filter).lowest
    if not enemy then return end
    if not enemy.combat then return end

    if player.manaPct < rotation.settings.shieldofrighteousnessMP then
        if spell:Cast(enemy) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

leveling_lay_on_hands:Callback(function(spell)
    if not rotation.settings.uselayonhands then return end
    if not spell.known then return end

    local friend = awful.fullGroup.within(40).filter(filter).lowest
    if not friend then return end

    if friend.hp < rotation.settings.layonhandsHP then
        if spell:Cast(friend) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

leveling_hand_of_sacrifice:Callback(function(spell)
    if not rotation.settings.usehandofsacrifice then return end
    if not spell.known then return end

    local friend = awful.fullGroup.within(40).filter(filter).lowest
    if not friend then return end
    if not isTank(friend) then return end

    if friend.buff("Hand of Sacrifice") and friend.hp < rotation.settings.handofsacrificeHP then
        if spell:Cast(friend) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

leveling_divine_shield:Callback(function(spell)
    if not rotation.settings.usedivineshield then return end
    if not spell.known then return end

    local friend = awful.fullGroup.within(40).filter(filter).lowest
    if not friend then return end
    if not isTank(friend) then return end

    if friend.buff("Hand of Sacrifice", player) and player.hp < rotation.settings.divineshieldHP then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

leveling_beacon_of_light:Callback(function(spell)
    if not spell.known then return end
    if not focus then return end

    if focus.buffRemains("Beacon Of Light", player) < 5 then
        if spell:Cast(focus) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

leveling_sacred_shield:Callback(function(spell)
    if not spell.known then return end
    if not focus then return end
    if focus.buff("Sacred Shield") then return end

    if focus.buffRemains("Sacred Shield") < 5 then
        if spell:Cast(focus) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

leveling_divine_favor:Callback(function(spell)
    if not rotation.settings.usedivinefavor then return end
    if not spell.known then return end
    if not target.exists then return end

    local friend = awful.fullGroup.within(40).filter(filter).lowest
    if not friend then return end

    if friend.hp < rotation.settings.divinefavorHP then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

leveling_holy_shock:Callback(function(spell)
    if not rotation.settings.useholyshock then return end
    if not spell.known then return end
    if not player.moving then return end

    local friend = awful.fullGroup.within(40).filter(filter).lowest
    if not friend then return end

    if friend.hp < rotation.settings.holyshockHP then
        if spell:Cast(friend) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

leveling_avenging_wrath:Callback(function(spell)
    if not rotation.settings.useavengingwrath then return end
    if not spell.known then return end
    if not target.exists then return end

    local friend = awful.fullGroup.within(40).filter(filter).lowest
    if not friend then return end

    if friend.hp < rotation.settings.avengingwrathHP then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

leveling_holy_light:Callback("friend", function(spell)
    if not rotation.settings.useholylight then return end
    if not spell.known then return end
    if wasCasting[spell.id] then return end
    local friend = awful.fullGroup.within(40).filter(filter).lowest
    if not friend then return end
    if isTank(friend) then return end
    if player.moving then return end
    if friend.hp > rotation.settings.holy_light_friend_hp then return end

    if friend.hp < rotation.settings.holy_light_friend_hp then
        if spell:Cast(friend) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

leveling_holy_light:Callback("tank", function(spell)
    if not rotation.settings.useholylight then return end
    if not spell.known then return end
    if wasCasting[spell.id] then return end
    local friend = awful.fullGroup.within(40).filter(filter).lowest
    if not friend then return end
    if not isTank(friend) then return end
    if player.moving then return end
    if friend.hp > rotation.settings.holy_light_tank_hp then return end

    if friend.hp < rotation.settings.holy_light_tank_hp then
        if spell:Cast(friend) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

leveling_flash_of_light:Callback("friend", function(spell)
    if not rotation.settings.useFlashOfLight then return end
    if not spell.known then return end
    if wasCasting[spell.id] then return end
    local friend = awful.fullGroup.within(40).filter(filter).lowest
    if not friend then return end
    if isTank(friend) then return end
    if player.moving then return end
    if friend.hp > rotation.settings.flashOfLightFriendHp then return end

    if friend.hp < rotation.settings.flashOfLightFriendHp then
        if spell:Cast(friend) then
            if not player.facing(focus, 15) then
                focus.face()
            end
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

leveling_flash_of_light:Callback("tank", function(spell)
    if not rotation.settings.useFlashOfLight then return end
    if not spell.known then return end
    if wasCasting[spell.id] then return end
    local friend = awful.fullGroup.within(40).filter(filter).lowest
    if not friend then return end
    if not isTank(friend) then return end
    if player.moving then return end
    if friend.hp > rotation.settings.flashOfLightTankHp then return end

    if friend.hp < rotation.settings.flashOfLightTankHp then
        if spell:Cast(friend) then
            if not player.facing(focus, 15) then
                focus.face()
            end
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)


leveling_judgement_of_light:Callback(function(spell)
    if not spell.known then return end
    local enemy = awful.enemies.within(40).filter(filter).lowest

    if not enemy then return end
    if not enemy.combat then return end

    if not player.buff("Judgements of the Pure") then
        if spell:Cast(enemy) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

leveling_divine_plea:Callback(function(spell)
    if not rotation.settings.usedivineplea then return end
    if not spell.known then return end

    if player.manaPct < rotation.settings.divinepleaMP then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

leveling_divine_illumination:Callback(function(spell)
    if not rotation.settings.usedivineillumination then return end
    if not spell.known then return end

    if player.manaPct < rotation.settings.divineilluminationMP or (player.buff("Bloodlust") or player.buff("Heroism")) then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

leveling_seal_of_wisdom:Callback(function(spell)
    if not spell.known then return end

    if not player.buff("Seal of Wisdom") then
        if spell:Cast(player) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)
