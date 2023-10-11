local Unlocker, awful, rotation = ...
local holy = rotation.paladin.holy
local Spell = awful.Spell
local player, target, focus = awful.player, awful.target, awful.focus

awful.Populate({
    pve_lay_on_hands            = Spell(48788, { beneficial = true, IgnoreCasting = true }),
    pve_beacon_of_light         = Spell(53563, { beneficial = true }),
    pve_sacred_shield           = Spell(53601, { beneficial = true }),
    pve_holy_shock              = Spell(48825, { beneficial = true }),
    pve_holy_light              = Spell(48782, { beneficial = true }),
    pve_hand_of_sacrifice       = Spell(6940, { beneficial = true }),
    pve_cleanse                 = Spell(4987, { beneficial = true }),
    pve_divine_shield           = Spell(642, { IgnoreCasting = true }),
    pve_divine_favor            = Spell(20216),
    pve_judgement_of_wisdom     = Spell(53408),
    pve_judgement_of_light      = Spell(20271),
    pve_divine_plea             = Spell(54428),
    pve_divine_illumination     = Spell(31842),
    pve_seal_of_wisdom          = Spell(20166),
    pve_auto_attack             = Spell(6603),
    pve_avenging_wrath          = Spell(31884),
    pve_shield_of_righteousness = Spell(61411),
}, holy, getfenv(1))

local function isBoss(unit)
    return unit.level == -1
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

local function filter(obj)
    return obj.los and not obj.dead
end

local StartAttack = awful.unlock("StartAttack")

local function isTank(unit)
    if unit.role == "Tank" or unit.aggro or unit.threat == 3 then
        return true
    end

    if unit.buffs then -- Ensure that unit.buffs is not nil before using ipairs
        for i, buff in ipairs(unit.buffs) do
            local name = unpack(buff)
            if tankBuffs[name] then
                return true
            end
        end
    end

    return false
end

pve_auto_attack:Callback(function(spell)
    local enemy = awful.enemies.within(5).filter(filter).lowest

    if not enemy or not enemy.combat then
        return
    end

    if target.exists and not spell.current then
        StartAttack()
    end
end)

local debuffType = {
    ["Magic"] = true,
    ["Poison"] = true,
    ["Disease"] = true
}

local debuffName = {
    ["Frostbolt"] = true,
    ["Frostbolt Volley"] = true,
    ["Cone of Cold"] = true,
    ["Frost Nova"] = true,
    ["Unstable Affliction"] = true
}

pve_cleanse:Callback(function(spell)
    if not rotation.settings.usecleanse then
        return
    end

    awful.fullGroup.within(40).filter(filter).loop(function(friend)
        if not friend then
            return
        end
        if friend.hp < 60 then
            return
        end

        for i = 1, #friend.debuffs do
            local name, _, _, type = unpack(friend['debuff' .. i])
            if debuffType[type] and not debuffName[name] then
                if spell:Cast(friend) then
                    awful.alert(spell.name, spell.id)
                    return
                end
            end
        end
    end)
end)

pve_shield_of_righteousness:Callback(function(spell)
    if not rotation.settings.useshieldofrighteousness then
        return
    end

    local enemy = awful.enemies.within(5).filter(filter).lowest

    if not enemy then
        return
    end
    if not enemy.combat then
        return
    end

    if player.manaPct < rotation.settings.shieldofrighteousnessMP then
        if spell:Cast(enemy) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_lay_on_hands:Callback(function(spell)
    if not rotation.settings.uselayonhands then
        return
    end

    local friend = awful.fullGroup.within(40).filter(filter).lowest

    if not friend then
        return
    end

    if friend.hp < rotation.settings.layonhandsHP then
        if spell:Cast(friend) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_hand_of_sacrifice:Callback(function(spell)
    if not rotation.settings.usehandofsacrifice then
        return
    end

    local friend = awful.fullGroup.within(40).filter(filter).lowest

    if not friend then
        return
    end
    if not isTank(friend) then
        return
    end

    if friend.buff("Hand of Sacrifice") and friend.hp < rotation.settings.handofsacrificeHP then
        if spell:Cast(friend) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_divine_shield:Callback(function(spell)
    if not rotation.settings.usedivineshield then
        return
    end

    local friend = awful.fullGroup.within(40).filter(filter).lowest

    if not friend then
        return
    end
    if not isTank(friend) then
        return
    end

    if friend.buff("Hand of Sacrifice", player) and player.hp < rotation.settings.divineshieldHP then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_beacon_of_light:Callback(function(spell)
    if not focus then
        return
    end

    if focus.buffRemains("Beacon Of Light", player) < 5 then
        if spell:Cast(focus) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_sacred_shield:Callback(function(spell)
    if not focus then
        return
    end

    if focus.buff("Sacred Shield") then
        return
    end

    if focus.buffRemains("Sacred Shield") < 5 then
        if spell:Cast(focus) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_divine_favor:Callback(function(spell)
    if not rotation.settings.usedivinefavor then
        return
    end
    if not target.exists then
        return
    end
    if not isBoss(target) then
        return
    end

    local friend = awful.fullGroup.within(40).filter(filter).lowest

    if not friend then
        return
    end

    if friend.hp < rotation.settings.divinefavorHP then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_holy_shock:Callback(function(spell)
    if not rotation.settings.useholyshock then
        return
    end
    if not player.moving then
        return
    end

    local friend = awful.fullGroup.within(40).filter(filter).lowest

    if not friend then
        return
    end

    if friend.hp < rotation.settings.holyshockHP then
        if spell:Cast(friend) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_avenging_wrath:Callback(function(spell)
    if not rotation.settings.useavengingwrath then
        return
    end
    if not target.exists then
        return
    end

    local friend = awful.fullGroup.within(40).filter(filter).lowest

    if not friend then
        return
    end

    if isBoss(target) and friend.hp < rotation.settings.avengingwrathHP then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

local store_holy_light_setting = rotation.settings.holy_light_friend_hp

pve_holy_light:Callback("friend", function(spell)
    if not rotation.settings.useholylight then
        return
    end
    local friend = awful.fullGroup.within(40).filter(filter).lowest
    if not friend then
        return
    end
    if isTank(friend) then
        return
    end
    if player.moving then
        return
    end
    if player.casting then
        return
    end

    -- Boss Logic: Anub
    if awful.encounterID == 649 and player.buff("Leeching Swarm") then
        rotation.settings.holy_light_friend_hp = 20
    else
        rotation.settings.holy_light_friend_hp = store_holy_light_setting
    end

    if friend.hp < rotation.settings.holy_light_friend_hp then
        if spell:Cast(friend) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_holy_light:Callback("tank", function(spell)
    if not rotation.settings.useholylight then return end
    local friend = awful.fullGroup.within(40).filter(filter).lowest
    if not friend then return end
    if not isTank(friend) then return end
    if player.moving then return end
    if player.casting then return end

    if friend.hp < rotation.settings.holy_light_tank_hp then
        if spell:Cast(friend) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_holy_light:Callback("incinerate_flesh", function(spell)
    if player.moving then
        return
    end
    if player.casting then
        return
    end

    awful.fullGroup.within(40).filter(filter).loop(function(friend)
        if friend.debuff("Incinerate Flesh") then
            if spell:Cast(friend) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end)
end)


pve_judgement_of_light:Callback(function(spell)
    local enemy = awful.enemies.within(40).filter(filter).lowest

    if not enemy then
        return
    end
    if not enemy.combat then
        return
    end

    if not player.buff("Judgements of the Pure") then
        if spell:Cast(enemy) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_divine_plea:Callback(function(spell)
    if not rotation.settings.usedivineplea then
        return
    end

    if player.manaPct < rotation.settings.divinepleaMP then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_divine_illumination:Callback(function(spell)
    if not rotation.settings.usedivineillumination then
        return
    end
    if not target.exists then
        return
    end

    if isBoss(target) and player.manaPct < rotation.settings.divineilluminationMP or (player.buff("Bloodlust") or player.buff("Heroism")) then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

pve_seal_of_wisdom:Callback(function(spell)
    if not player.buff(20166) then
        if spell:Cast(player) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)
