--[[

    No Vayne No Gain by Lillgoalie (Condemn based on Vayne's Mighty Assistant by Manciuszz)
    Version: 1.4
    
    Features:
        - Combo Mode:
            - Uses Q in combo
            - Uses R in combo
        - Auto Condemn enemies
        - Auto Condemn gapclosers
        - Auto Condemn only the target enemy
        - Auto-Level Spells
        - Laneclear using Q with settings
        - Uses BOTRK

    
    Instructions on saving the file:
    - Save the file in scripts folder
    
--]]

require 'VPrediction'
require 'SOW'

if myHero.charName ~= "Vayne" then return end

local ts
local Menu
local enemyTable = GetEnemyHeroes()
local informationTable = {}
local spellExpired = true
local eRange, eSpeed, eDelay, eRadius = 1000, 2200, 0.25, nil
local VP = VPrediction()
local AllClassMenu = 16
local qOff, wOff, eOff, rOff = 0,0,0,0
local abilitySequence = {1, 2, 3, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3}

-- Code -------------------------------------------

function OnLoad()
    Orbwalker = SOW(VP)
    ts = TargetSelector(TARGET_NEAR_MOUSE,1000)

    Menu = scriptConfig("No Vayne No Gain", "VayneBL")

    Menu:addSubMenu("["..myHero.charName.." - Orbwalker]", "SOWorb")
    Orbwalker:LoadToMenu(Menu.SOWorb)

    Menu:addSubMenu("["..myHero.charName.." - Combo]", "VayneCombo")
    Menu.VayneCombo:addParam("combo", "Combo key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    Menu.VayneCombo:addParam("comboQ", "Use Q in combo", SCRIPT_PARAM_ONOFF, true)
    Menu.VayneCombo:addParam("comboR", "Use R in combo", SCRIPT_PARAM_ONOFF, true)
    Menu.VayneCombo:addParam("comboRRange", "Enemies in range for R", SCRIPT_PARAM_SLICE, 2, 0, 5, 0)
    Menu.VayneCombo:addSubMenu("Item usage", "itemUse")
    Menu.VayneCombo.itemUse:addParam("BOTRK", "Use BOTRK in combo", SCRIPT_PARAM_ONOFF, true)

    Menu:addSubMenu("["..myHero.charName.." - Laneclear]", "LaneC")
    Menu.LaneC:addParam("laneclr", "Laneclear key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
    Menu.LaneC:addParam("clearQ", "Use Q in laneclear", SCRIPT_PARAM_ONOFF, true)
    Menu.LaneC:addParam("laneclearMana", "Min mana % to use Q in laneclear", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)

    Menu:addSubMenu("["..myHero.charName.." - Additionals]", "Ads")
    Menu.Ads:addParam("AutoLevelspells", "Auto-Level Spells", SCRIPT_PARAM_ONOFF, false)

    Menu:addSubMenu("["..myHero.charName.." - Wall Tumble]", "WallT") -- Credits Jire
    Menu.WallT:addParam("midwall", "Mid Wall Key", SCRIPT_PARAM_ONKEYDOWN, false, 56)
    Menu.WallT:addParam("drakewall", "Drake Wall Key", SCRIPT_PARAM_ONKEYDOWN, false, 57)

    Menu:addSubMenu("["..myHero.charName.." - Condemn]", "Condemn")

    Menu.Condemn:addSubMenu("Features & Settings", "settingsSubMenu")
    Menu.Condemn:addSubMenu("Disable Auto-Condemn on", "condemnSubMenu")

    Menu.Condemn:addParam("autoCondemn", "Auto-Condemn Toggle:", SCRIPT_PARAM_ONKEYTOGGLE, false, 32)
    Menu.Condemn:addParam("switchKey", "Switch key mode:", SCRIPT_PARAM_ONOFF, false)

    Menu.Condemn:addSubMenu("Only Condemn current target", "OnlyCurrentTarget")
    Menu.Condemn.OnlyCurrentTarget:addParam("Condemntarget", "Only condemn current target", SCRIPT_PARAM_ONOFF, false)
    Menu.Condemn.OnlyCurrentTarget:addTS(ts)
    ts.name = "Condemn"

    Menu.Condemn.settingsSubMenu:addParam("PushAwayGapclosers", "Push Gapclosers Away", SCRIPT_PARAM_ONOFF, true)
    Menu.Condemn.settingsSubMenu:addParam("CondemnAssistant", "Condemn Visual Assistant:", SCRIPT_PARAM_ONOFF, true)
    Menu.Condemn.settingsSubMenu:addParam("pushDistance", "Push Distance", SCRIPT_PARAM_SLICE, 440, 0, 450, 0) -- Reducing this value means that the enemy has to be closer to the wall, so you could cast condemn.
    Menu.Condemn.settingsSubMenu:addParam("eyeCandy", "After-Condemn Circle:", SCRIPT_PARAM_ONOFF, true)
    if not VIP_USER then
        Menu.Condemn.settingsSubMenu:addParam("shootingMode", "Currently: No prediction", SCRIPT_PARAM_INFO, "NOT VIP")
    else
        Menu.Condemn.settingsSubMenu:addParam("shootingMode", "Prediction/No prediction:", SCRIPT_PARAM_ONOFF, true)
    end

    Menu.Condemn:permaShow("autoCondemn")
    -- Override in case it's stuck.
--    Menu.Condemn.pushDistance = 300
    Menu.Condemn.autoCondemn = true
    Menu.Condemn.switchKey = false

    for i, enemy in ipairs(enemyTable) do
        Menu.Condemn.condemnSubMenu:addParam("disableCondemn"..i, " >> "..enemy.charName, SCRIPT_PARAM_ONOFF, false)
        Menu.Condemn["disableCondemn"..i] = false -- Override
    end

    Menu:addSubMenu("["..myHero.charName.." - Drawings]", "drawings")
    Menu.drawings:addParam("drawCircleAA", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)



    PrintChat("<font color = \"#33CCCC\">No Vayne No Gain by</font> <font color = \"#fff8e7\">Lillgoalie</font>")
end

function OnTick()
    ts:update()

    if CountEnemyHeroInRange(600) >= Menu.VayneCombo.comboRRange then
        if (Menu.VayneCombo.comboR) then
            if (Menu.VayneCombo.combo) then
                if (myHero:CanUseSpell(_R) == READY) then
                    CastSpell(_R)
                end
            end
        end
    end

    if (Menu.VayneCombo.combo) then
        UseBotrk()
    end

    if Menu.Ads.AutoLevelspells then
        AutoLevel()
    end

    if Menu.WallT.drakewall then
        DrakeWall()
    end

    if Menu.WallT.midwall then
        MidWall()
    end
end

function DrakeWall()
     if Menu.WallT.drakewall and myHero.x < 11540 or myHero.x > 11600 or myHero.z < 4638 or myHero.z > 4712 then
      myHero:MoveTo(11590.95, 4656.26)
    else
      myHero:MoveTo(11590.95, 4656.26)
      CastSpell(_Q, 11334.74, 4517.47)
    end
end

function MidWall()
    if Menu.WallT.midwall and myHero.x < 6600 or myHero.x > 6660 or myHero.z < 8630 or myHero.z > 8680 then
      myHero:MoveTo(6623, 8649)
    else
      myHero:MoveTo(6623, 8649)
      CastSpell(_Q, 6010.5869140625, 8508.8740234375)
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

function UseBotrk()
    if ts.target ~= nil and Menu.VayneCombo.combo and GetDistance(ts.target) < 450 and not ts.target.dead and ts.target.visible and GetInventorySlotItem(3153) ~= nil and myHero:CanUseSpell(GetInventorySlotItem(3153)) == READY then
        if (Menu.VayneCombo.itemUse.BOTRK) then 
            CastSpell(GetInventorySlotItem(3153), ts.target)
        end
    end
end

function OnDraw()
    if myHero.dead then return end

    DrawCircle(6623, 100, 8649, 100, ARGB(0, 102, 0, 0))
    DrawCircle(11590.95, 100, 4656.26, 100, ARGB(0, 102, 0, 0))

    if (Menu.drawings.drawCircleAA) then
        DrawCircle(myHero.x, myHero.y, myHero.z, 655, ARGB(255, 0, 255, 0))
    end

    if Menu.Condemn.autoCondemn then
        if not Menu.Condemn.OnlyCurrentTarget.Condemntarget then
            CondemnAll()
        elseif Menu.Condemn.OnlyCurrentTarget.Condemntarget then
            CondemnNearMouse()
        end
    end
end

function CondemnAll()
        if IsKeyDown(AllClassMenu) then
        Menu.Condemn._param[1].pType = Menu.Condemn.switchKey and 2 or 3
        Menu.Condemn._param[1].text  = Menu.Condemn.switchKey and "Auto-Condemn OnHold:" or "Auto-Condemn Toggle:"
        if Menu.Condemn.switchKey and Menu.Condemn.autoCondemn then
            Menu.Condemn.autoCondemn = false
        end

        Menu.Condemn.settingsSubMenu._param[5].text  = Menu.Condemn.settingsSubMenu.shootingMode and VIP_USER and "Currently: VP" or "Currently: No prediction"
        if not VIP_USER then Menu.Condemn.settingsSubMenu.shootingMode = "NOT VIP" end
    end

    if myHero:CanUseSpell(_E) == READY then
        if Menu.Condemn.settingsSubMenu.PushAwayGapclosers then
            if not spellExpired and (GetTickCount() - informationTable.spellCastedTick) <= (informationTable.spellRange/informationTable.spellSpeed)*1000 then
                local spellDirection     = (informationTable.spellEndPos - informationTable.spellStartPos):normalized()
                local spellStartPosition = informationTable.spellStartPos + spellDirection
                local spellEndPosition   = informationTable.spellStartPos + spellDirection * informationTable.spellRange
                local heroPosition = Point(myHero.x, myHero.z)

                local lineSegment = LineSegment(Point(spellStartPosition.x, spellStartPosition.y), Point(spellEndPosition.x, spellEndPosition.y))
                --lineSegment:draw(ARGB(255, 0, 255, 0), 70)

                if lineSegment:distance(heroPosition) <= (not informationTable.spellIsAnExpetion and 65 or 200) then
                    CastSpell(_E, informationTable.spellSource)
                end
            else
                spellExpired = true
                informationTable = {}
            end
        end

        if not Menu.Condemn.OnlyCurrentTarget.Condemntarget and Menu.Condemn.autoCondemn then
            for i, enemyHero in ipairs(enemyTable) do
                if not Menu.Condemn.condemnSubMenu["disableCondemn"..i] then 
                    if enemyHero ~= nil and enemyHero.valid and not enemyHero.dead and enemyHero.visible and GetDistance(enemyHero) <= 715 and GetDistance(enemyHero) > 0 then
                        local enemyPosition = Menu.Condemn.settingsSubMenu.shootingMode and VIP_USER and VP:GetPredictedPos(enemyHero, eDelay, eSpeed) or enemyHero
                        local PushPos = enemyPosition + (Vector(enemyPosition) - myHero):normalized()*Menu.Condemn.settingsSubMenu.pushDistance

                        if enemyHero.x > 0 and enemyHero.z > 0 then
                            local checks = math.ceil((Menu.Condemn.settingsSubMenu.pushDistance)/65)
                            local checkDistance = (Menu.Condemn.settingsSubMenu.pushDistance)/checks
                            local InsideTheWall = false
                            for k=1, checks, 1 do
                                local checksPos = enemyPosition + (Vector(enemyPosition) - myHero):normalized()*(checkDistance*k)
                                local WallContainsPosition = IsWall(D3DXVECTOR3(checksPos.x, checksPos.y, checksPos.z))
                                if WallContainsPosition then
                                    InsideTheWall = true
                                    break
                                end
                            end

                            if InsideTheWall then CastSpell(_E, enemyHero) end

                            if Menu.Condemn.settingsSubMenu.eyeCandy and PushPos.x > 0 and PushPos.z > 0 then
                                DrawCircle(PushPos.x, PushPos.y, PushPos.z, 65, ARGB(255, 0, 255, 0))
                            end


                        end
                    end
                end
            end
        end
    end
end

function CondemnNearMouse()
        if IsKeyDown(AllClassMenu) then
        Menu.Condemn._param[1].pType = Menu.Condemn.switchKey and 2 or 3
        Menu.Condemn._param[1].text  = Menu.Condemn.switchKey and "Auto-Condemn OnHold:" or "Auto-Condemn Toggle:"
        if Menu.Condemn.switchKey and Menu.Condemn.autoCondemn then
            Menu.Condemn.autoCondemn = false
        end

        Menu.Condemn.settingsSubMenu._param[5].text  = Menu.Condemn.settingsSubMenu.shootingMode and VIP_USER and "Currently: VP" or "Currently: No prediction"
        if not VIP_USER then Menu.Condemn.settingsSubMenu.shootingMode = "NOT VIP" end
    end

    if myHero:CanUseSpell(_E) == READY then
        if Menu.Condemn.settingsSubMenu.PushAwayGapclosers then
            if not spellExpired and (GetTickCount() - informationTable.spellCastedTick) <= (informationTable.spellRange/informationTable.spellSpeed)*1000 then
                local spellDirection     = (informationTable.spellEndPos - informationTable.spellStartPos):normalized()
                local spellStartPosition = informationTable.spellStartPos + spellDirection
                local spellEndPosition   = informationTable.spellStartPos + spellDirection * informationTable.spellRange
                local heroPosition = Point(myHero.x, myHero.z)

                local lineSegment = LineSegment(Point(spellStartPosition.x, spellStartPosition.y), Point(spellEndPosition.x, spellEndPosition.y))
                --lineSegment:draw(ARGB(255, 0, 255, 0), 70)

                if lineSegment:distance(heroPosition) <= (not informationTable.spellIsAnExpetion and 65 or 200) then
                    CastSpell(_E, informationTable.spellSource)
                end
            else
                spellExpired = true
                informationTable = {}
            end
        end

        if Menu.Condemn.autoCondemn and Menu.Condemn.OnlyCurrentTarget.Condemntarget then
            for i, enemy in ipairs(enemyTable) do
                if not Menu.Condemn.condemnSubMenu["disableCondemn"..i] then 
                    if ts.target ~= nil and ts.target.valid and not ts.target.dead and ts.target.visible and GetDistance(ts.target) <= 715 and GetDistance(ts.target) > 0 then
                        local enemyPosition = Menu.Condemn.settingsSubMenu.shootingMode and VIP_USER and VP:GetPredictedPos(ts.target, eDelay, eSpeed) or ts.target
                        local PushPos = enemyPosition + (Vector(enemyPosition) - myHero):normalized()*Menu.Condemn.settingsSubMenu.pushDistance

                        if ts.target.x > 0 and ts.target.z > 0 then
                            local checks = math.ceil((Menu.Condemn.settingsSubMenu.pushDistance)/65)
                            local checkDistance = (Menu.Condemn.settingsSubMenu.pushDistance)/checks
                            local InsideTheWall = false
                            for k=1, checks, 1 do
                                local checksPos = enemyPosition + (Vector(enemyPosition) - myHero):normalized()*(checkDistance*k)
                                local WallContainsPosition = IsWall(D3DXVECTOR3(checksPos.x, checksPos.y, checksPos.z))
                                if WallContainsPosition then
                                    InsideTheWall = true
                                    break
                                end
                            end

                            if InsideTheWall then CastSpell(_E, ts.target) end

                            if Menu.Condemn.settingsSubMenu.eyeCandy and PushPos.x > 0 and PushPos.z > 0 then
                                DrawCircle(PushPos.x, PushPos.y, PushPos.z, 65, ARGB(255, 0, 255, 0))
                            end


                        end
                    end
                end
            end
        end
    end
end

function OnProcessSpell(unit, spell)
    if unit.isMe and spell.name:lower():find("attack") and Menu.VayneCombo.combo and Menu.VayneCombo.comboQ then
        SpellTarget = spell.target
        if SpellTarget.type == myHero.type then
            DelayAction(function() CastSpell(_Q, mousePos.x, mousePos.z) end, spell.windUpTime - GetLatency() / 2000)
        end
    end

    if unit.isMe and spell.name:lower():find("attack") and Menu.LaneC.clearQ and Menu.LaneC.laneclr and myHero.mana >= (myHero.maxMana*(Menu.LaneC.laneclearMana*0.01)) then
        SpellTarget = spell.target
            DelayAction(function() CastSpell(_Q, mousePos.x, mousePos.z) end, spell.windUpTime - GetLatency() / 2000)
    end

    if not Menu.Condemn.settingsSubMenu.PushAwayGapclosers then return end

    local jarvanAddition = unit.charName == "JarvanIV" and unit:CanUseSpell(_Q) ~= READY and _R or _Q -- Did not want to break the table below.
    local isAGapcloserUnit = {
--        ['Ahri']        = {true, spell = _R, range = 450,   projSpeed = 2200},
        ['Aatrox']      = {true, spell = _Q,                  range = 1000,  projSpeed = 1200, },
        ['Akali']       = {true, spell = _R,                  range = 800,   projSpeed = 2200, }, -- Targeted ability
        ['Alistar']     = {true, spell = _W,                  range = 650,   projSpeed = 2000, }, -- Targeted ability
        ['Diana']       = {true, spell = _R,                  range = 825,   projSpeed = 2000, }, -- Targeted ability
        ['Gragas']      = {true, spell = _E,                  range = 600,   projSpeed = 2000, },
        ['Graves']      = {true, spell = _E,                  range = 425,   projSpeed = 2000, exeption = true },
        ['Hecarim']     = {true, spell = _R,                  range = 1000,  projSpeed = 1200, },
        ['Irelia']      = {true, spell = _Q,                  range = 650,   projSpeed = 2200, }, -- Targeted ability
        ['JarvanIV']    = {true, spell = jarvanAddition,      range = 770,   projSpeed = 2000, }, -- Skillshot/Targeted ability
        ['Jax']         = {true, spell = _Q,                  range = 700,   projSpeed = 2000, }, -- Targeted ability
        ['Jayce']       = {true, spell = 'JayceToTheSkies',   range = 600,   projSpeed = 2000, }, -- Targeted ability
        ['Khazix']      = {true, spell = _E,                  range = 900,   projSpeed = 2000, },
        ['Leblanc']     = {true, spell = _W,                  range = 600,   projSpeed = 2000, },
        ['LeeSin']      = {true, spell = 'blindmonkqtwo',     range = 1300,  projSpeed = 1800, },
        ['Leona']       = {true, spell = _E,                  range = 900,   projSpeed = 2000, },
        ['Malphite']    = {true, spell = _R,                  range = 1000,  projSpeed = 1500 + unit.ms},
        ['Maokai']      = {true, spell = _Q,                  range = 600,   projSpeed = 1200, }, -- Targeted ability
        ['MonkeyKing']  = {true, spell = _E,                  range = 650,   projSpeed = 2200, }, -- Targeted ability
        ['Pantheon']    = {true, spell = _W,                  range = 600,   projSpeed = 2000, }, -- Targeted ability
        ['Poppy']       = {true, spell = _E,                  range = 525,   projSpeed = 2000, }, -- Targeted ability
        --['Quinn']       = {true, spell = _E,                  range = 725,   projSpeed = 2000, }, -- Targeted ability
        ['Renekton']    = {true, spell = _E,                  range = 450,   projSpeed = 2000, },
        ['Sejuani']     = {true, spell = _Q,                  range = 650,   projSpeed = 2000, },
        ['Shen']        = {true, spell = _E,                  range = 575,   projSpeed = 2000, },
        ['Tristana']    = {true, spell = _W,                  range = 900,   projSpeed = 2000, },
        ['Tryndamere']  = {true, spell = 'Slash',             range = 650,   projSpeed = 1450, },
        ['XinZhao']     = {true, spell = _E,                  range = 650,   projSpeed = 2000, }, -- Targeted ability
    }
    if unit.type == 'obj_AI_Hero' and unit.team == TEAM_ENEMY and isAGapcloserUnit[unit.charName] and GetDistance(unit) < 2000 and spell ~= nil then
        if spell.name == (type(isAGapcloserUnit[unit.charName].spell) == 'number' and unit:GetSpellData(isAGapcloserUnit[unit.charName].spell).name or isAGapcloserUnit[unit.charName].spell) then
            if spell.target ~= nil and spell.target.name == myHero.name or isAGapcloserUnit[unit.charName].spell == 'blindmonkqtwo' then
--                print('Gapcloser: ',unit.charName, ' Target: ', (spell.target ~= nil and spell.target.name or 'NONE'), " ", spell.name, " ", spell.projectileID)
                CastSpell(_E, unit)
            else
                spellExpired = false
                informationTable = {
                    spellSource = unit,
                    spellCastedTick = GetTickCount(),
                    spellStartPos = Point(spell.startPos.x, spell.startPos.z),
                    spellEndPos = Point(spell.endPos.x, spell.endPos.z),
                    spellRange = isAGapcloserUnit[unit.charName].range,
                    spellSpeed = isAGapcloserUnit[unit.charName].projSpeed,
                    spellIsAnExpetion = isAGapcloserUnit[unit.charName].exeption or false,
                }
            end
        end
    end


end