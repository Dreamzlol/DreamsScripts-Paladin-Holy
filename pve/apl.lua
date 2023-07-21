local Unlocker, awful, rotation = ...
local holy = rotation.paladin.holy
local player = awful.player

function rotation.APL_PvE()
    if player.mounted or
        player.dead or
        player.buff("Drink") then
        return
    end

    if not rotation.settings.useOOC then
        if not player.combat then return end
    end
    if player.used("Divine Sacrifice", 10) then
        awful.call("RunMacroText", "/cancelaura Divine Sacrifice")
    end

    holy.LayOnHands()
    holy.DivineShield()
    holy.AvengingWrath()
    holy.HolyShock()
    holy.HandOfSacrifice()
    holy.AutoAttack()
    holy.Cleanse()
    holy.JudgementOfLight()
    holy.DivineFavor()
    holy.DivineIllumination()
    holy.DivinePlea()
    holy.BeaconOfLight()
    holy.SacredShield()
    holy.HolyLight("incinerate_flesh")
    holy.HolyLight("friend")
    holy.HolyLight("tank")
    holy.SealOfWisdom()
    holy.ShieldOfRighteousness()
end

return rotation.APL_PvE