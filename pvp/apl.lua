local Unlocker, awful, rotation = ...
local holy = rotation.paladin.holy
local player = awful.player

function rotation.APL_PvP()
    if awful.player.mounted then
        return
    end
    if awful.player.buff("Drink") then
        return
    end

    holy.AutoAttack()
    holy.DivineShield()
    holy.DivineProtection()
    holy.HandOfProtection()
    holy.HandOfSacrifice("cc")
    holy.HandOfSacrifice("seduction")
    holy.DivineSacrifice("cc")
    holy.DivineSacrifice("seduction")
    holy.HandOfSacrifice("defensive")
    holy.DivineSacrifice("defensive")
    holy.Consecration()
    holy.HammerOfJustice()
    holy.HammerOfWrath()
    holy.SacredShield()
    holy.DivineFavor()
    holy.HolyShock("defensive")
    holy.HolyShock("pets")
    holy.HandOfFreedom()
    holy.Cleanse()
    holy.JudgementOfWisdom()
    holy.TurnEvil("lich")
    holy.TurnEvil("gargoyle")
    holy.AuraMastery()
    holy.AvengingWrath()
    holy.FlashOfLight()
    holy.FlashOfLight("pets")

    -- Damage
    holy.HolyShock("burst")
    holy.ShieldOfRighteousness()
    holy.Exorcism()

    -- Buffs
    holy.DivineIllumination()
    holy.BlessingOfKings()
    holy.BeaconOfLight()
    holy.RighteousFury()
    holy.SealOfWisdom()
end
