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
    engineering_gloves()
    trinket()
    holy.HolyLight("incinerate_flesh")
    holy.HolyLight("friend")
    holy.HolyLight("tank")
    holy.SealOfWisdom()
    holy.ShieldOfRighteousness()
end

return rotation.APL_PvE
