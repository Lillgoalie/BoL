--[[

    Nami Tsunami by Lillgoalie

    
    Instructions on saving the file:
    - Save the file in scripts folder
    
--]]

if myHero.charName ~= "Nami" then return end

require 'VPrediction'
require 'SOW'

local ts

local QRange, QSpeed, QDelay, QRadius = 865, 1750, 0.55, 250
local WRange = 725
local ERange = 800
local RSpeed, RDelay, RRadius = 1200, 0.5, 700

local VP = nil

local qOff, wOff, eOff, rOff = 0,0,0,0
local abilitySequence = {1, 2, 3, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1}

-- Code -------------------------------------------

function OnLoad()
    VP = VPrediction()
    Orbwalker = SOW(VP)
    ts = TargetSelector(TARGET_LESS_CAST, 900)

    Menu = scriptConfig("Nami Tsunami", "NamiBL")

    Menu:addSubMenu("["..myHero.charName.." - Orbwalker]", "SOWorb")
    Orbwalker:LoadToMenu(Menu.SOWorb)

    Menu:addSubMenu("["..myHero.charName.." - Combo]", "NamiCombo")
    Menu.NamiCombo:addParam("combo", "Combo mode", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    Menu.NamiCombo:addSubMenu("Q Settings", "qSet")
    Menu.NamiCombo.qSet:addParam("useQ", "Use Q in combo", SCRIPT_PARAM_ONOFF, true) 
    Menu.NamiCombo:addSubMenu("E Settings", "eSet")
    Menu.NamiCombo.eSet:addParam("useE", "Use E in combo", SCRIPT_PARAM_ONOFF, true)
    Menu.NamiCombo:addSubMenu("R Settings", "rSet") 
    Menu.NamiCombo.rSet:addParam("useR", "Use R in combo", SCRIPT_PARAM_ONOFF, true)
    Menu.NamiCombo.rSet:addParam("RuseRange", "Range to use ultimate", SCRIPT_PARAM_SLICE, 1000, 0, 2200, 0)
    Menu.NamiCombo.rSet:addParam("MinimumR", "Minimum enemies to ultimate on", SCRIPT_PARAM_SLICE, 1, 1, 5, 0)

    Menu:addSubMenu("["..myHero.charName.." - Harass]", "NamiHarass")
    Menu.NamiHarass:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
    Menu.NamiHarass:addParam("AutoHarass", "Auto Harass", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("A"))
    Menu.NamiHarass:addParam("QHarass", "Harass using Q", SCRIPT_PARAM_ONOFF, true)
    Menu.NamiHarass:addParam("WHarass", "Harass using W", SCRIPT_PARAM_ONOFF, true)

    Menu:addSubMenu("["..myHero.charName.." - Additionals]", "Ads")
    Menu.Ads:addParam("AutoLevelspells", "Auto-Level Spells", SCRIPT_PARAM_ONOFF, false)
    Menu.Ads:addSubMenu("Auto Heal Settings", "AutoHeal")
    Menu.Ads.AutoHeal:addParam("HealNami", "Auto Heal Yourself", SCRIPT_PARAM_ONOFF, true)
    Menu.Ads.AutoHeal:addParam("NamiPercent", "What % to heal yourself", SCRIPT_PARAM_SLICE, 70, 0, 100, 0)
    Menu.Ads.AutoHeal:addParam("HealAllies", "Auto Heal Allies", SCRIPT_PARAM_ONOFF, false)
    Menu.Ads.AutoHeal:addParam("AllyPercent", "What % to heal allies", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)

    Menu:addSubMenu("["..myHero.charName.." - Target Selector]", "targetSelector")
    Menu.targetSelector:addTS(ts)
    ts.name = "Focus"

    Menu:addSubMenu("["..myHero.charName.." - Drawings]", "drawings")
    Menu.drawings:addParam("drawCircleAA", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
    Menu.drawings:addParam("drawCircleQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
    Menu.drawings:addParam("drawCircleR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)

    PrintChat("<font color = \"#33CCCC\">Nami Tsunami by</font> <font color = \"#fff8e7\">Lillgoalie</font>")
end

function OnTick()
    ts:update()

    if Menu.NamiCombo.combo then
        ComboMode()
    end

    if Menu.NamiHarass.Harass then
        harass()
    end

    if Menu.NamiHarass.AutoHarass then
        autoharass()
    end

    if Menu.Ads.AutoLevelspells then
        AutoLevel()
    end

    if Menu.Ads.AutoHeal.HealNami then
        AutoHealNami()
    end

    if Menu.Ads.AutoHeal.HealAllies then
        AutoHealAllies()
    end
end

function AutoHealNami()
    if myHero:CanUseSpell(_W) and Menu.Ads.AutoHeal.HealNami and HealthCheck(myHero, Menu.Ads.AutoHeal.NamiPercent) then
        CastSpell(_W, myHero)
    end
end

function AutoHealAllies()
    for i, ally in ipairs(GetAllyHeroes()) do
        if ally ~= nil and GetDistance(ally) < WRange and not ally.dead and ally.visible and myHero:CanUseSpell(_W) == READY and Menu.Ads.AutoHeal.HealAllies and HealthCheck(ally, Menu.Ads.AutoHeal.AllyPercent) then
            CastSpell(_W, ally)
        end
    end
end

function harass()
    if Menu.NamiHarass.QHarass then
        for i, target in pairs(GetEnemyHeroes()) do
            if target ~= nil and ValidTarget(target, QRange) then
                if myHero:CanUseSpell(_Q) == READY then
                    local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(target, QDelay, QRadius, QRange, QSpeed)
                    if HitChance >= 2 and GetDistance(CastPosition) < QRange then
                        CastSpell(_Q, CastPosition.x, CastPosition.z)
                    end
                end
            end
        end
    end

    if Menu.NamiHarass.WHarass then
        for i, target in pairs(GetEnemyHeroes()) do
            if target ~= nil and ValidTarget(target, WRange) and myHero:CanUseSpell(_W) == READY then
                CastSpell(_W, target)
            end
        end
    end
end

function autoharass()
    if Menu.NamiHarass.QHarass then
        for i, target in pairs(GetEnemyHeroes()) do
            if target ~= nil and ValidTarget(target, QRange) then
                if myHero:CanUseSpell(_Q) == READY then
                    local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(target, QDelay, QRadius, QRange, QSpeed)
                    if HitChance >= 2 and GetDistance(CastPosition) < QRange then
                        CastSpell(_Q, CastPosition.x, CastPosition.z)
                    end
                end
            end
        end
    end

    if Menu.NamiHarass.WHarass then
        for i, target in pairs(GetEnemyHeroes()) do
            if target ~= nil and ValidTarget(target, WRange) and myHero:CanUseSpell(_W) == READY then
                CastSpell(_W, target)
            end
        end
    end
end

function AutoLevel()
    local qL, wL, eL, rL = player:GetSpellData(_Q).level + qOff, player:GetSpellData(_W).level + wOff, player:GetSpellData(_E).level + eOff, player:GetSpellData(_R).level + rOff
    if qL + wL + eL + rL < player.level then
        local spellSlot = { SPELL_1, SPELL_2, SPELL_3, SPELL_4, }
        local level = { 0, 0, 0, 0 }
        for i = 1, player.level, 1 do
            level[abilitySequence[i]] = level[abilitySequence[i]] + 1
        end
        for i, v in ipairs({ qL, wL, eL, rL }) do
        if v < level[i] then LevelSpell(spellSlot[i]) end
        end
    end
end

function ComboMode()
    if Menu.NamiCombo.combo then
        UseR()
        UseQ()
        UseE()
        UseW()
    end
end

function UseR()
    for i, target in pairs(GetEnemyHeroes()) do
        if target ~= nil and ValidTarget(target) then
            local AOECastPosition, MainTargetHitChance, nTargets = VP:GetLineAOECastPosition(target, RDelay, RRadius, Menu.NamiCombo.rSet.RuseRange, RSpeed, myHero)
            if MainTargetHitChance >= 2 and GetDistance(AOECastPosition) < Menu.NamiCombo.rSet.RuseRange and nTargets >= Menu.NamiCombo.rSet.MinimumR and myHero:CanUseSpell(_R) == READY and Menu.NamiCombo.rSet.useR then
                CastSpell(_R, AOECastPosition.x, AOECastPosition.z)
            end
        end
    end
end

function UseQ()
    if ts.target ~= nil and ValidTarget(ts.target, QRange) and myHero:CanUseSpell(_Q) == READY and Menu.NamiCombo.qSet.useQ then
        local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(ts.target, QDelay, QRadius, QRange, QSpeed)
        if HitChance >= 2 and GetDistance(CastPosition) < QRange then
            CastSpell(_Q, CastPosition.x, CastPosition.z)
        end
    end
end

function UseW()
    if ts.target ~= nil and ValidTarget(ts.target, WRange) and myHero:CanUseSpell(_W) == READY then
        CastSpell(_W, ts.target)
    end
end

function UseE()
    for i, ally in ipairs(GetAllyHeroes()) do
        if ally ~= nil and GetDistance(ally) < 800 and not ally.dead and ally.visible and myHero:CanUseSpell(_E) == READY and Menu.NamiCombo.eSet.useE then
            CastSpell(_E, ally)
        else
            if ts.target ~= nil and ValidTarget(ts.target, 625) then
                CastSpell(_E, myHero)
            end
        end
    end
end

function HealthCheck(unit, HealthValue)
    if unit.health < (unit.maxHealth * (HealthValue/100))
        then return true
    else
        return false
    end
end

function OnDraw()
    if Menu.drawings.drawCircleR then
        DrawCircle(myHero.x, myHero.y, myHero.z, Menu.NamiCombo.rSet.RuseRange, 0x111111)
    end     
    
    if Menu.drawings.drawCircleQ then
        DrawCircle(myHero.x, myHero.y, myHero.z, QRange, 0x111111)
    end
    
    if Menu.drawings.drawCircleAA then
        DrawCircle(myHero.x, myHero.y, myHero.z, 675, ARGB(255, 0, 255, 0))
    end
end