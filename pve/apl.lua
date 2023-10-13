local Unlocker, awful, rotation = ...
local holy = rotation.paladin.holy
local player, target = awful.player, awful.target

local function engineering_gloves()
    local UseInventoryItem = awful.unlock("UseInventoryItem")
    local getItemCooldown = GetInventoryItemCooldown("player", 10)

    if target and target.exists then
        if target.level == -1 and getItemCooldown == 0 then
            if UseInventoryItem(10) then
                awful.alert("Hyperspeed Accelerators", 54758)
                return
            end
        end
    end
end

local function trinket()
    local UseInventoryItem = awful.unlock("UseInventoryItem")
    local getItemCooldown13 = GetInventoryItemCooldown("player", 13)
    local getItemCooldown14 = GetInventoryItemCooldown("player", 14)

    if target and target.exists then
        if target.level == -1 then
            if getItemCooldown13 == 0 then
                UseInventoryItem(13)
                return
            elseif getItemCooldown14 == 0 then
                UseInventoryItem(14)
                return
            end
        end
    end
end

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
    engineering_gloves()
    trinket()
    holy.pve_holy_light("incinerate_flesh")
    holy.pve_holy_light("friend")
    holy.pve_holy_light("tank")
    holy.pve_seal_of_wisdom()
    holy.pve_shield_of_righteousness()
end
