local Unlocker, awful, rotation = ...
local holy = rotation.paladin.holy
local player = awful.player

function rotation.aplLeveling()
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

    holy.WasCastingCheck()
    holy.leveling_lay_on_hands()
    holy.leveling_divine_shield()
    holy.leveling_avenging_wrath()
    holy.leveling_holy_shock()
    holy.leveling_hand_of_sacrifice()
    holy.leveling_auto_attack()
    holy.leveling_cleanse()
    holy.leveling_judgement_of_light()
    holy.leveling_divine_favor()
    holy.leveling_divine_illumination()
    holy.leveling_divine_plea()
    holy.leveling_beacon_of_light()
    holy.leveling_sacred_shield()
    holy.leveling_flash_of_light("tank")
    holy.leveling_flash_of_light("friend")
    holy.leveling_holy_light("tank")
    holy.leveling_holy_light("friend")
    holy.leveling_seal_of_wisdom()
    holy.leveling_shield_of_righteousness()
end
