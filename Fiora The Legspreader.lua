--[[
    Fiora The Legspreader by Lillgoalie & ELSN
]]

if myHero.charName ~= "Fiora" then return end

require 'VPrediction'
require 'SOW'

local QREADY, WREADY, EREADY, RREADY  = false, false, false, false
local VP = nil
local qRange = 600
local rRange = 400
local qOff, wOff, eOff, rOff = 0,0,0,0
local abilitySequence = {2, 3, 1, 2, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3} 

local Spots = { 
        { x = 1297, y = 51, z = 8113}
}

function OnLoad()
    VP = VPrediction()
    ts = TargetSelector(TARGET_LESS_CAST, qRange)
    Orbwalker = SOW(VP)
    
    Menu = scriptConfig("Fiora The Legspreader", "FioraTLS")
    
    Menu:addSubMenu("["..myHero.charName.." - Orbwalker]", "SOWorb")
    Orbwalker:LoadToMenu(Menu.SOWorb) 
     
    Menu:addSubMenu("["..myHero.charName.." - Combo]", "FioraCombo")
    Menu.FioraCombo:addParam("combo", "Combo mode", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    Menu.FioraCombo:addSubMenu("Q Settings", "qSet")
    Menu.FioraCombo.qSet:addParam("useQ", "Use Q in combo", SCRIPT_PARAM_ONOFF, true) 
    Menu.FioraCombo:addSubMenu("W Settings", "wSet")
    Menu.FioraCombo.wSet:addParam("autoW", "Auto-parry", SCRIPT_PARAM_ONOFF, true)
    Menu.FioraCombo:addSubMenu("E Settings", "eSet")
    Menu.FioraCombo.eSet:addParam("useE", "Use E in combo", SCRIPT_PARAM_ONOFF, true)
    Menu.FioraCombo:addSubMenu("R Settings", "rSet") 
    Menu.FioraCombo.rSet:addParam("useR", "Use R in combo", SCRIPT_PARAM_ONOFF, true)
    -- Menu.FioraCombo.rSet:addParam("useROn", "Use R on # amount of enemies", SCRIPT_PARAM_SLICE, 1, 1, 5, 0)
	--[[
    Menu:addSubMenu("["..myHero.charName.." - Harass]", "Harass")
    Menu.Harass:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
    Menu.Harass:addParam("autoharass", "Auto-Harass", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("A"))
    Menu.Harass:addParam("UseQ", "Use Q in Harass", SCRIPT_PARAM_ONOFF, true)
    Menu.Harass:addParam("UseE", "Use E in Harass", SCRIPT_PARAM_ONOFF, false)
	]]

    Menu:addSubMenu("["..myHero.charName.." - Laneclear]", "Laneclear")
    Menu.Laneclear:addParam("lclr", "Laneclear Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
    Menu.Laneclear:addParam("UseQclear", "Use Q in Laneclear", SCRIPT_PARAM_ONOFF, true)
    Menu.Laneclear:addParam("UseEclear", "Use E in Laneclear", SCRIPT_PARAM_ONOFF, false)
    Menu.Laneclear:addParam("lclrMana", "Use Spells if mana is over %", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)

    Menu:addSubMenu("["..myHero.charName.." - Jungleclear]", "Jungleclear")
    Menu.Jungleclear:addParam("jclr", "Jungleclear Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
    Menu.Jungleclear:addParam("UseQclear", "Use Q in Jungleclear", SCRIPT_PARAM_ONOFF, true)
    Menu.Jungleclear:addParam("UseEclear", "Use E in Jungleclear", SCRIPT_PARAM_ONOFF, true)
     
    Menu:addSubMenu("["..myHero.charName.." - Additionals]", "Ads")
    Menu.Ads:addParam("autoLevel", "Auto-Level Spells", SCRIPT_PARAM_ONOFF, false)
    Menu.Ads:addParam("ksQ", "Killsteal using Q", SCRIPT_PARAM_ONOFF, true)
    Menu.Ads:addParam("ksR", "Killsteal using R", SCRIPT_PARAM_ONOFF, false)
    Menu.Ads:addParam("escapeKey", "Escape Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))

    Menu:addSubMenu("["..myHero.charName.." - Target Selector]", "targetSelector")
    Menu.targetSelector:addTS(ts)
    ts.name = "Focus"
           
    Menu:addSubMenu("["..myHero.charName.." - Drawings]", "drawings")
    Menu.drawings:addParam("drawCircleAA", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
    Menu.drawings:addParam("drawCircleQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
    Menu.drawings:addParam("drawCircleR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)

    enemyMinions = minionManager(MINION_ENEMY, qRange, myHero, MINION_SORT_MAXHEALTH_DEC)
    jungleMinions = minionManager(MINION_JUNGLE, qRange, myHero, MINION_SORT_MAXHEALTH_DEC)
           
    PrintChat("<font color = \"#33CCCC\">Fiora The Legspreader by</font> <font color = \"#fff8e7\">Lillgoalie</font> <font color = \"#33CCCC\">&</font> <font color = \"#fff8e7\">ELSN</font>")
end

function OnTick()
    if myHero.dead then return end
    ts:update()
    jungleMinions:update()
    enemyMinions:update()
    CDHandler()
  
    if Menu.Ads.escapeKey then
        EscapeMode()
    end
  
    if Menu.Laneclear.lclr then
        LaneClear()
    end
  
    if Menu.Jungleclear.jclr then
        JungleClear()
    end
  
    if Menu.Ads.autoLevel then
        AutoLevel()
    end
  
    if Menu.FioraCombo.combo then
        ComboMode()
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

function LaneClear()
    for i, minion in pairs(enemyMinions.objects) do
        if minion ~= nil and ValidTarget(minion, qRange) and QREADY and Menu.Laneclear.UseQclear and ManaCheck(myHero, Menu.Laneclear.lclrMana) then 
            CastSpell(_Q, minion)
        end
     
        if minion ~= nil and ValidTarget(minion, 100) and EREADY and Menu.Laneclear.UseEclear and ManaCheck(myHero, Menu.Laneclear.lclrMana) then
            CastSpell(_E)
        end
    end
end

function JungleClear()
    local jMinions = jungleMinions.objects[1]
    if jMinions ~= nil and ValidTarget(jMinions, qRange) then
        if QREADY and Menu.Jungleclear.UseQclear then
            CastSpell(_Q, jMinions)
        end
        if EREADY and Menu.Jungleclear.UseEclear then           
            CastSpell(_E)
        end
    end
end

function CDHandler()
    QREADY = (myHero:CanUseSpell(_Q) == READY) 
    WREADY = (myHero:CanUseSpell(_W) == READY)
    EREADY = (myHero:CanUseSpell(_E) == READY)
    RREADY = (myHero:CanUseSpell(_R) == READY)
    -- RavenousREADY = (GetInventorySlotItem(3074) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3074) == READY))
    -- TiamatREADY = (GetInventorySlotItem(3077) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3077) == READY))
end
  
function EscapeMode()
    myHero:MoveTo(mousePos.x, mousePos.z)
    --[[
    for i, minion in pairs(enemyMinions.objects) do
        if minion ~= nil and ValidTarget(minion, qRange) then
            if GetDistance(minion) < 600 and GetDistance(minion) > 500 and QREADY and isFacing(myHero, minion, 600) then
                if EREADY then
                    CastSpell(_E)
                end
                CastSpell(_Q, minion)
            end

            if GetDistance(minion) < 500 and GetDistance(minion) > 300 and QREADY and isFacing(myHero, minion, 600) then
                if EREADY then
                    CastSpell(_E)
                end
                CastSpell(_Q, minion)
            end
            
            if GetDistance(minion) < 300 and GetDistance(minion) > 0 and QREADY and isFacing(myHero, minion, 600) then
                if EREADY then
                    CastSpell(_E)
                end
                CastSpell(_Q, minion)
            end
        end
    end
    ]]
end
    

function ComboMode() 
    if Menu.FioraCombo.rSet.useR and ts.target ~= nil and ValidTarget(ts.target, rRange) then
        Rcast()
    end
  
    if Menu.FioraCombo.qSet.useQ and ts.target ~= nil and ValidTarget(ts.target, 600) then
        Qcast() 
    end
      
    if Menu.FioraCombo.eSet.useE and ts.target ~= nil and ValidTarget(ts.target, 250) then
        Ecast()
    end
end 

function Qcast()
    if GetDistance(ts.target) > 270 and QREADY then
        CastSpell(_Q, ts.target)
    end
end

function Ecast()
    if EREADY then
        CastSpell(_E)
    end
end

function Rcast()
    CastSpell(_R, ts.target)
    --[[
    if RREADY then
        for i, target in ipairs(GetEnemyHeroes()) do
            if target ~= nil and ValidTarget(target, 400) then
                local AOECastPosition, MainTargetHitChance, nTargets = VPrediction:GetCircularAOECastPosition(target, 0.5, 300, 400, 2000, myHero) 
                if nTargets >= Menu.FioraCombo.rSet.useROn then
                    CastSpell(_R, target)
                end
            end
        end
    end
    ]]
end

-- Credit HeX for AutoParry
function OnProcessSpell(unit, spell)
    if Menu.FioraCombo.wSet.autoW then
        if unit ~= nil and unit.type == "obj_AI_Hero" and GetDistance(spell.endPos) <= 50 and unit.team ~= myHero.team and not unit.isMe then
            for i=1, #Abilities do
                if (spell.name == Abilities[i] or spell.name:find(Abilities[i]) ~= nil) then
                    if WREADY and (getDmg("AD", myHero, unit) >= (myHero.maxHealth*0.06) or getDmg("AD", myHero, unit) >= (myHero.health*0.04)) then
                        CastSpell(_W)
                    else
                        if WREADY then
                            CastSpell(_W)
                        end
                    end
                end
            end
        end
    end
end

Abilities = {
"GarenSlash2", "SiphoningStrikeAttack", "LeonaShieldOfDaybreakAttack", "RenektonExecute", "ShyvanaDoubleAttackHit", "DariusNoxianTacticsONHAttack", "TalonNoxianDiplomacyAttack", "Parley", "MissFortuneRicochetShot", "RicochetAttack", "jaxrelentlessattack", "Attack"
}

function ManaCheck(unit, ManaValue)
    if unit.mana > (unit.maxMana * (ManaValue/100))
        then return true
    else
        return false
    end
end
        
function KSQ()
    for i, enemy in ipairs(GetEnemyHeroes()) do
        qDmg = getDmg("Q", enemy, myHero)
                
        if QREADY and enemy ~= nil and ValidTarget(enemy, 600) and enemy.health < qDmg then
            CastSpell(_Q, enemy)
        end
    end
end
        
function KSR()
    for i, enemy in ipairs(GetEnemyHeroes()) do
        rDmg = getDmg("R", enemy, myHero)
                
        if RREADY and enemy ~= nil and ValidTarget(enemy, 600) and enemy.health < rDmg then
            CastSpell(_R, enemy)
        end
    end
end

-- Credit Feez for isFacing
function isFacing(source, target, lineLength)
    local sourceVector = Vector(source.visionPos.x, source.visionPos.z)
    local sourcePos = Vector(source.x, source.z)
    sourceVector = (sourceVector-sourcePos):normalized()
    sourceVector = sourcePos + (sourceVector*(GetDistance(target, source)))
    return GetDistanceSqr(target, {x = sourceVector.x, z = sourceVector.y}) <= (lineLength and lineLength^2 or 90000)
end

function OnDraw()
    if Menu.drawings.drawCircleAA then
        DrawCircle(myHero.x, myHero.y, myHero.z, 250, ARGB(255, 0, 255, 0))
    end

    if Menu.drawings.drawCircleQ then
        DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x111111)
    end
  
    if Menu.drawings.drawCircleR then
        DrawCircle(myHero.x, myHero.y, myHero.z, rRange, 0x111111)
    end
  
    --[[if Menu.Ads.escapeKey then
        EscapeDrawings()
    end]]
end

--[[function EscapeDrawings()
    DrawCircle(Spot.x, Spot.y, Spot.z, 50, 0x111111)
end]]--