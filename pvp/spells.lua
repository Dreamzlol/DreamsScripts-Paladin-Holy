local Unlocker, awful, rotation = ...
local holy = rotation.paladin.holy
local Spell = awful.Spell
local player, target = awful.player, awful.target

if not rotation.settings.mode == "PvP" then
    return
end

awful.Populate({
    HammerOfJustice       = Spell(5588, { cc = "stun", effect = "magic", ignoreCasting = true }),
    HandOfProtection      = Spell(10278, { ignoreCasting = true, ignoreControl = true }),
    HandOfFreedom         = Spell(1044, { beneficial = true, ignoreControl = true }),
    DivineIllumination    = Spell(31842, { beneficial = true }),
    FlashOfLight          = Spell(48785, { beneficial = true }),
    HolyShock             = Spell(48825, { beneficial = true }),
    BlessingOfKings       = Spell(20217, { beneficial = true }),
    Cleanse               = Spell(4987, { beneficial = true }),
    BeaconOfLight         = Spell(53563, { beneficial = true }),
    SealOfWisdom          = Spell(20166, { beneficial = true }),
    SacredShield          = Spell(53601, { beneficial = true }),
    RighteousFury         = Spell(25780, { beneficial = true }),
    AvengingWrath         = Spell(31884, { beneficial = true }),
    DivineFavor           = Spell(20216, { beneficial = true }),
    HandOfSacrifice       = Spell(6940, { beneficial = true }),
    DivineProtection      = Spell(498, { beneficial = true }),
    DivineSacrifice       = Spell(64205, { beneficial = true }),
    Consecration          = Spell(48819, { ignoreCasting = true }),
    DivineShield          = Spell(642, { ignoreCasting = true }),
    JudgementOfWisdom     = Spell(53408, { damage = "magic" }),
    Exorcism              = Spell(48801, { damage = "magic" }),
    HammerOfWrath         = Spell(48806, { damage = "magic" }),
    TurnEvil              = Spell(10326),
    ShieldOfRighteousness = Spell(61411),
    HolyWrath             = Spell(48817),
    AutoAttack            = Spell(6603),
    AuraMastery           = Spell(31821),
}, holy, getfenv(1))

local SpellStopCasting = awful.unlock("SpellStopCasting")

local function unitFilter(obj)
    return obj.exists and obj.los and not obj.dead
end

local preemptive = {
    ["Repentance"] = true,
    ["Blind"] = true,
    ["Gouge"] = true,
    ["Scatter Shot"] = true,
    ["Psychic Scream"] = true,
    ["Polymorph"] = true,
    ["Seduction"] = true,
    ["Hex"] = true
}

awful.onEvent(function(info, event, source, dest)
    if event == "SPELL_CAST_SUCCESS" then
        if not source.enemy then
            return
        end
        if not dest.isUnit(player) then
            return
        end

        local friend = awful.friends.within(40).filter(unitFilter).lowest

        if not friend then
            return
        end
        local _, spellName = select(12, unpack(info))
        if preemptive[spellName] then
            SpellStopCasting()
            HandOfSacrifice:Cast(friend)
            return
        end
    end
end)

AutoAttack:Callback(function(spell)
    awful.totems.stomp(function(totem, uptime)
        if uptime < 0.3 then return end
        if totem.distance >= 5 then
            return
        end
        if spell:Cast(totem) then
            awful.alert("Destroying " .. totem.name, spell.id)
            return
        end
    end)

    if target.bcc and spell.current then
        StopAttack()
    elseif not target.enemy and spell.current then
        StartAttack()
    end
end)

AuraMastery:Callback(function(spell)
    local friend = awful.fullGroup.within(40).filter(unitFilter).lowest

    if not friend then
        return
    end
    if friend.hp < 60 then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

DivineIllumination:Callback(function(spell)
    if player.manaPct < 60 then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

HandOfFreedom:Callback(function(spell)
    awful.friends.within(30).filter(unitFilter).loop(function(friend)
        if player.hp < 60 and (player.slowed or player.rooted) then
            if spell:Cast(player) then
                awful.alert(spell.name, spell.id)
                return
            end
        end

        if not friend then
            return
        end
        if friend.slowed and friend.rooted then
            if spell:Cast(friend) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end)
end)

DivineShield:Callback(function(spell)
    if player.hp < 40 and player.combat then
        if spell:Cast(player) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

DivineFavor:Callback(function(spell)
    local friend = awful.fullGroup.within(40).filter(unitFilter).lowest

    if not player.combat then
        return
    end
    if not friend then
        return
    end
    if friend.hp < 40 then
        if spell:Cast(player) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

AvengingWrath:Callback(function(spell)
    local friend = awful.fullGroup.within(40).filter(unitFilter).lowest

    if not player.combat then
        return
    end
    if player.cooldown("Divine Shield") == 0 then
        return
    end
    if not friend then
        return
    end
    if friend.hp < 60 then
        if spell:Cast(friend) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

HandOfProtection:Callback(function(spell)
    local friend = awful.friends.within(40).filter(unitFilter).lowest

    if not friend or not friend.v2attackers then
        return
    end

    local _, melee = friend.v2attackers()
    if friend.hp < 40 and melee > 0 or (friend.disarm or (friend.disorient and friend.disorientRemains > 5)) then
        if spell:Cast(friend) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

DivineProtection:Callback(function(spell)
    if player.cooldown("Divine Shield") == 0 then
        return
    end
    if player.cooldown("Avenging Wrath") == 0 then
        return
    end
    if player.hp < 60 then
        if spell:Cast(player) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

DivineSacrifice:Callback("defensive", function(spell)
    local friend = awful.fullGroup.within(30).filter(unitFilter).lowest

    if not friend then
        return
    end
    if not friend.buff then
        return
    end
    if friend.buff("Hand of Sacrifice") then
        return
    end
    if friend.hp < 70 then
        if spell:Cast(friend) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

local onCast = {
    ["Polymorph"] = true,
    ["Seduction"] = true,
    ["Fear"] = true,
    ["Hex"] = true
}

DivineSacrifice:Callback("cc", function(spell)
    awful.enemies.loop(function(enemy)
        if enemy.castTarget.isUnit(player) and onCast[enemy.casting] and enemy.castPct > 60 then
            SpellStopCasting()
            spell:Cast()
            return
        else
            if onCast[enemy.casting] and player.castRemains <= enemy.castRemains then
                SpellStopCasting()
            end
            if onCast[enemy.casting] and player.castRemains >= enemy.castRemains then
                SpellStopCasting()
            end
            if onCast[enemy.casting] and player.castRemains >= enemy.castRemains then
                SpellStopCasting()
            end
        end
    end)
end)

DivineSacrifice:Callback("seduction", function(spell)
    awful.enemyPets.loop(function(pet)
        if pet.castTarget.isUnit(player) and onCast[pet.casting] and pet.castPct > 60 then
            SpellStopCasting()
            spell:Cast()
            return
        else
            if onCast[pet.casting] and player.gcdRemains <= pet.castRemains then
                SpellStopCasting()
            end
            if onCast[pet.casting] and player.gcdRemains >= pet.castRemains then
                SpellStopCasting()
            end
            if onCast[pet.casting] and player.gcdRemains >= pet.castRemains then
                SpellStopCasting()
            end
        end
    end)
end)

HandOfSacrifice:Callback("defensive", function(spell)
    local friend = awful.friends.within(40).filter(unitFilter).lowest

    if not friend then
        return
    end
    if not friend.buff then
        return
    end
    if friend.buff("Divine Sacrifice") then
        return
    end
    if friend.hp < 70 then
        if spell:Cast(friend) then
            awful.alert(spell.name, spell.id)
        end
    end
end)

local onCast = {
    ["Polymorph"] = true,
    ["Seduction"] = true,
    ["Fear"] = true,
    ["Hex"] = true
}

HandOfSacrifice:Callback("cc", function(spell)
    local friend = awful.friends.within(40).filter(unitFilter).lowest

    awful.enemies.loop(function(enemy)
        if enemy.castTarget.isUnit(player) and onCast[enemy.casting] and enemy.castPct > 60 then
            awful.call("SpellStopCasting")
            awful.call("SpellStopCasting")
            spell:Cast(friend)
            return
        else
            if onCast[enemy.casting] and
                (player.castRemains <= enemy.castRemains or player.castRemains >= enemy.castRemains or
                    player.channelRemains >= enemy.castRemains) then
                awful.call("SpellStopCasting")
                awful.call("SpellStopCasting")
            end
        end
    end)
end)

HandOfSacrifice:Callback("seduction", function(spell)
    local friend = awful.friends.within(40).filter(unitFilter).lowest

    awful.enemyPets.loop(function(pet)
        if pet.castTarget.isUnit(player) and onCast[pet.casting] and pet.castPct > 60 then
            awful.call("SpellStopCasting")
            awful.call("SpellStopCasting")
            spell:Cast(friend)
            return
        else
            if onCast[pet.casting] and
                (player.castRemains <= pet.castRemains or player.castRemains >= pet.castRemains or player.channelRemains >=
                    pet.castRemains) then
                awful.call("SpellStopCasting")
                awful.call("SpellStopCasting")
            end
        end
    end)
end)

HolyShock:Callback("defensive", function(spell)
    local friend = awful.fullGroup.within(40).filter(unitFilter).lowest

    if friend and friend.hp < 90 then
        if spell:Cast(friend) then
            awful.alert(spell.name, spell.id)
        end
    end
end)

HolyShock:Callback("pets", function(spell)
    local pet = awful.friendlyPets.within(40).filter(unitFilter).lowest

    if not pet then
        return
    end
    if pet.hp < 60 then
        if spell:Cast(pet) then
            awful.alert(spell.name, spell.id)
        end
    end
end)

HolyShock:Callback("burst", function(spell)
    local enemy = awful.enemies.within(20).filter(unitFilter).lowest

    if not enemy then
        return
    end
    if enemy.hp < 10 then
        if spell:Cast(enemy) then
            awful.alert(spell.name .. "(Offensive)", spell.id)
        end
    end
end)

FlashOfLight:Callback(function(spell)
    local friend = awful.fullGroup.within(40).filter(unitFilter).lowest

    if not friend then
        return
    end
    if friend.hp < 90 then
        if spell:Cast(friend) then
            awful.alert(spell.name, spell.id)
        end
    end
end)

FlashOfLight:Callback("pets", function(spell)
    local pet = awful.friendlyPets.within(40).filter(unitFilter).lowest

    if not pet then
        return
    end
    if pet.hp < 90 then
        if spell:Cast(pet) then
            awful.alert(spell.name, spell.id)
        end
    end
end)

local dispelDefensive = {
    ["Earthgrab"] = true,
    ["Psychic Scream"] = true,
    ["Psychic Horror"] = true,
    ["Entrapment"] = true,
    ["Polymorph"] = true,
    ["Seduction"] = true,
    ["Frost Nova"] = true,
    ["Howl of Terror"] = true,
    ["Earthbind"] = true,
    ["Faerie Fire"] = true,
    ["Cone of Cold"] = true,
    ["Silencing Shot"] = true,
    ["Deep Freeze"] = true,
    ["Pin"] = true,
    ["Hammer of Justice"] = true,
    ["Flame Shock"] = true,
    ["Fear"] = true,
    ["Entangling Roots"] = true,
    ["Freezing Arrow Effect"] = true,
    ["Freezing Trap"] = true,
    ["Chains of Ice"] = true,
    ["Immolate"] = true,
    ["Frostbolt"] = true,
    ["Dragon's Breath"] = true,
    ["Turn Evil"] = true,
    ["Repentance"] = true,
    ["Shadowflame"] = true,
    ["Hungering Cold"] = true,
    ["Hibernate"] = true,
    ["Freeze"] = true,
    ["Freezing Trap Effect"] = true,
    ["Strangulate"] = true,
    ["Death Coil"] = true,
    ["Silence"] = true,
    ["Shadowfury"] = true,
    ["Slow"] = true
}

local dispelBlacklist = {
    ["Unstable Affliction"] = true
}

local dispelByType = {
    ["Magic"] = true,
    ["Poison"] = true,
    ["Disease"] = true
}

Cleanse:Callback(function(spell)
    local friend = awful.fullGroup.within(40).filter(unitFilter).lowest

    if not friend then
        return
    end
    if not friend.debuffs then
        return
    end
    for _, debuff in ipairs(friend.debuffs) do
        local name, _, _, type = unpack(debuff)

        -- CC
        if dispelDefensive[name] and not dispelBlacklist[name] and friend.hp > 40 then
            if spell:Cast(friend) then
                awful.alert(spell.name, spell.id)
                return
            end
        end

        -- ALL
        if dispelByType[type] and player.manaPct > 40 and friend.hp > 80 then
            if spell:Cast(friend) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end
end)

SacredShield:Callback(function(spell)
    local friend = awful.fullGroup.within(40).filter(unitFilter).lowest

    if not friend then
        return
    end
    if player.used("Sacred Shield", 5) then
        return
    end
    if friend.hp < 90 and not friend.buff("Sacred Shield") then
        if spell:Cast(friend) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

BeaconOfLight:Callback(function(spell)
    if not player.buff("Beacon of Light") and player.manaPct > 40 then
        if spell:Cast(player) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

JudgementOfWisdom:Callback(function(spell)
    awful.totems.stomp(function(totem, uptime)
        if uptime < 0.3 then
            return
        end
        if spell:Cast(totem) then
            awful.alert("Destroying " .. totem.name, spell.id)
            return
        end
    end)

    local enemy = awful.enemies.within(40).filter(unitFilter).lowest

    if not enemy then
        return
    end
    if enemy.bcc then
        return
    end
    if not enemy.combat then
        return
    end
    if enemy.hp < 40 or not player.buff("Judgements of the Pure") then
        if spell:Cast(enemy) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

HammerOfWrath:Callback(function(spell)
    local enemy = awful.enemies.within(30).filter(unitFilter).lowest

    if not enemy then
        return
    end
    if enemy.bcc then
        return
    end
    if not enemy.combat then
        return
    end
    if enemy.hp < 20 then
        if spell:Cast(enemy, {
            face = true
        }) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

Exorcism:Callback(function(spell)
    local friend = awful.fullGroup.within(40).filter(unitFilter).lowest

    local enemy = awful.enemies.within(30).filter(unitFilter).lowest

    if not enemy then
        return
    end
    if enemy.bcc then
        return
    end
    if not enemy.combat then
        return
    end
    if friend.hp > 80 then
        if spell:Cast(enemy) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

ShieldOfRighteousness:Callback(function(spell)
    local friend = awful.fullGroup.within(40).filter(unitFilter).lowest

    local enemy = awful.enemies.within(5).filter(unitFilter).lowest

    if not enemy or not friend then
        return
    end
    if friend.hp > 80 then
        if spell:Cast(enemy, {
            face = true
        }) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

Consecration:Callback(function(spell)
    local enemy = awful.enemies.within(10).filter(unitFilter)

    if not enemy then
        return
    end
    if enemy.stealth then
        if spell:Cast() then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

HammerOfJustice:Callback(function(spell)
    awful.enemies.within(10).filter(unitFilter).loop(function(enemy)
        if not enemy then
            return
        end
        if enemy.stealth or player.hp < 20 then
            if spell:Cast(enemy) then
                awful.alert(spell.name, spell.id)
                return
            end
        end

        if enemy.casting and enemy.stunDR >= 0.25 then
            if spell:Cast(enemy) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end)
end)

TurnEvil:Callback("gargoyle", function(spell)
    awful.enemyPets.within(20).filter(unitFilter).loop(function(pet)
        if pet.id == 27829 and not pet.debuff("Turn Evil") then
            if spell:Cast(pet) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end)
end)

TurnEvil:Callback("lich", function(spell)
    awful.enemies.within(20).filter(unitFilter).loop(function(enemy)
        if not enemy then
            return
        end
        if enemy.buff("Lichborne") and not enemy.debuff("Turn Evil") then
            if spell:Cast(enemy) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end)
end)

RighteousFury:Callback(function(spell)
    if player.buff("Righteous Fury") then
        return
    end
    if not player.used("Righteous Fury", 10) then
        if spell:Cast(player) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)

BlessingOfKings:Callback(function(spell)
    awful.fullGroup.within(30).filter(unitFilter).loop(function(friend)
        if not friend then
            return
        end
        if friend.hp < 60 then
            return
        end
        if friend.buff("Blessing of Kings") then
            return
        end
        if friend.buff("Greater Blessing of Kings") then
            return
        end
        if player.manaPct > 40 then
            if spell:Cast(friend) then
                awful.alert(spell.name, spell.id)
                return
            end
        end
    end)
end)

SealOfWisdom:Callback(function(spell)
    if not player.buff("Seal of Wisdom") then
        if spell:Cast(player) then
            awful.alert(spell.name, spell.id)
            return
        end
    end
end)
