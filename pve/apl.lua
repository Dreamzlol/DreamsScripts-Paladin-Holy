local Unlocker, awful, rotation = ...
local holy = rotation.paladin.holy
local player, target = awful.player, awful.target

function rotation.apl_pve()
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
    holy.pve_lay_on_hands()
    holy.pve_divine_shield()
    holy.pve_avenging_wrath()
    holy.pve_holy_shock()
    holy.pve_hand_of_sacrifice()
    holy.pve_auto_attack()
    holy.pve_cleanse()
    holy.pve_judgement_of_light()
    holy.pve_divine_favor()
    holy.pve_divine_illumination()
    holy.pve_divine_plea()
    holy.pve_beacon_of_light()
    holy.pve_sacred_shield()

    -- Items
    holy.pve_inventory_slot_10()
    holy.pve_inventory_slot_13()
    holy.pve_inventory_slot_14()

    holy.pve_holy_light("incinerate_flesh")
    holy.pve_holy_light("friend")
    holy.pve_holy_light("tank")
    holy.pve_seal_of_wisdom()
    holy.pve_shield_of_righteousness()
end
