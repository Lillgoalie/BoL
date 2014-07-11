--[[
 
        Furry Pussy Nidalee by Lillgoalie
       
        Instructions on saving the file:
        - Save the file in scripts folder
       
--]]

if myHero.charName ~= "Nidalee" then return end
     
require 'VPrediction'
require 'SOW'

local ts
local Recalling
local VP = nil

function OnLoad()
    VP = VPrediction()
            -- Target Selector
    ts = TargetSelector(TARGET_LESS_CAST, 1500)
                   
    Menu = scriptConfig("Furry Pussy Nidalee by Lillgoalie", "NidaleeBL")
    Orbwalker = SOW(VP)
    Menu:addTS(ts)
    ts.name = "Focus"
           
    Menu:addSubMenu("["..myHero.charName.." - Orbwalker]", "SOWorb")
    Orbwalker:LoadToMenu(Menu.SOWorb)
     
    Menu:addSubMenu("["..myHero.charName.." - Combo]", "NidaCombo")
    Menu.NidaCombo:addParam("combo", "Combo mode", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    Menu.NidaCombo:addSubMenu("Q Settings", "Qset")
    Menu.NidaCombo.Qset:addParam("comboQ", "Use Q in Human Combo", SCRIPT_PARAM_ONOFF, true)
    Menu.NidaCombo.Qset:addParam("comboCougarQ", "Use Q in Cougar Combo", SCRIPT_PARAM_ONOFF, true)
    Menu.NidaCombo:addSubMenu("W Settings", "Wset")
    Menu.NidaCombo.Wset:addParam("comboW", "Use W in Human Combo", SCRIPT_PARAM_ONOFF, true)
    Menu.NidaCombo.Wset:addParam("comboCougarW", "Use W in Cougar Combo", SCRIPT_PARAM_ONOFF, true)
    Menu.NidaCombo.Wset:addParam("Wstunned", "Only use W on stunned targets", SCRIPT_PARAM_ONOFF, true)
    Menu.NidaCombo:addSubMenu("E Settings", "Eset")
    Menu.NidaCombo.Eset:addParam("comboCougarE", "Use E in Cougar Combo", SCRIPT_PARAM_ONOFF, true)
    Menu.NidaCombo:addParam("FormSwitch", "Auto-Switch Form", SCRIPT_PARAM_ONOFF, true)
           
    Menu:addSubMenu("["..myHero.charName.." - Harass]", "Harass")
    Menu.Harass:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
    Menu.Harass:addParam("autoharass", "Auto Harass", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("A"))
     
    Menu:addSubMenu("["..myHero.charName.." - Additionals]", "Ads")
    Menu.Ads:addParam("ks", "Killsteal with Q", SCRIPT_PARAM_ONOFF, true)
    Menu.Ads:addParam("escape", "Escape key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
    Menu.Ads:addSubMenu("Auto Heal Settings", "AutoHeal")
    Menu.Ads.AutoHeal:addParam("HealNida", "Auto Heal Yourself", SCRIPT_PARAM_ONOFF, true)
    Menu.Ads.AutoHeal:addParam("NidaPercent", "What % to heal yourself", SCRIPT_PARAM_SLICE, 70, 0, 100, 0)
    Menu.Ads.AutoHeal:addParam("HealAllies", "Auto Heal Allies", SCRIPT_PARAM_ONOFF, false)
    Menu.Ads.AutoHeal:addParam("AllyPercent", "What % to heal allies", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
           
    Menu:addSubMenu("["..myHero.charName.." - Drawings]", "drawings")
    Menu.drawings:addSubMenu("Human Form Drawings", "humandrawings")
    Menu.drawings.humandrawings:addParam("drawCircleAA", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
    Menu.drawings.humandrawings:addParam("drawCircleQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
    Menu.drawings.humandrawings:addParam("drawCircleW", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
    Menu.drawings.humandrawings:addParam("drawCircleE", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
    Menu.drawings:addSubMenu("Cougar Form Drawings", "cougardrawings")
    Menu.drawings.cougardrawings:addParam("drawCircleAA", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
    Menu.drawings.cougardrawings:addParam("drawCircleQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
    Menu.drawings.cougardrawings:addParam("drawCircleW", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
    Menu.drawings.cougardrawings:addParam("drawCircleE", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
           
	PrintChat("<font color = \"#33CCCC\">Furry Pussy Nidalee by</font> <font color = \"#fff8e7\">Lillgoalie</font>")
end

function OnTick()
	if myHero.dead then return end
	ts:update()
	Check()
	Harass()
	AutoHarass()
	Escape()

	--[[ if Menu.Ads.ks then
		NidaKillSteal()
	end ]]

	if Menu.NidaCombo.combo and NIDACOUGAR then
		cougarcombo()
	end

	if Menu.NidaCombo.combo and NIDAHUMAN then
		humancombo()
	end

	if ts.target ~= nil and myHero:CanUseSpell(_R) == READY and ValidTarget(ts.target) and GetDistance(ts.target, myHero) < 400 and Menu.NidaCombo.FormSwitch and Menu.NidaCombo.combo then
		if myHero:GetSpellData(_Q).name == "JavelinToss" 
		or myHero:GetSpellData(_W).name == "Bushwhack"
		or myHero:GetSpellData(_E).name == "PrimalSurge"
			then CastSpell(_R)
		end
	end

	if ts.target ~= nil and myHero:CanUseSpell(_R) == READY and ValidTarget(ts.target) and GetDistance(ts.target, myHero) > 400 and Menu.NidaCombo.combo and Menu.NidaCombo.FormSwitch then
		if myHero:GetSpellData(_Q).name == "Takedown"
		or myHero:GetSpellData(_W).name == "Pounce"
		or myHero:GetSpellData(_E).name == "Swipe"
			then CastSpell(_R)
		end
	end

	if Menu.Ads.AutoHeal.HealNida or Menu.Ads.AutoHeal.HealAllies then
		Autoheal()
	end
end

function Harass()
	if ts.target ~= nil and ValidTarget(ts.target, 1400) and Menu.Harass.harass and NIDAHUMAN then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, 0.5, 30, 1400, 1300, myHero, true)
		if HitChance >= 2  and GetDistance(ts.target) <= 1400 and myHero:CanUseSpell(_Q) == READY then 
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
	end
end

function AutoHarass()
	if ts.target ~= nil and ValidTarget(ts.target, 1400) and Menu.Harass.autoharass and NIDAHUMAN and not Recalling then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, 0.5, 30, 1400, 1300, myHero, true)
		if HitChance >= 2  and GetDistance(ts.target) <= 1400 and myHero:CanUseSpell(_Q) == READY then 
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
	end
end

function Autoheal()
    if myHero:CanUseSpell(_E) == READY and Menu.Ads.AutoHeal.HealNida and myHero.health < (myHero.maxHealth * (Menu.Ads.AutoHeal.NidaPercent*0.01)) and NIDAHUMAN and not Recalling then
        CastSpell(_E, myHero)
    end

	for i=1, heroManager.iCount do
        local ally = heroManager:getHero(i)
        if ally.team == myHero.team and ally.team ~= TEAM_ENEMY and myHero:CanUseSpell(_E) == READY and Menu.Ads.AutoHeal.HealAllies and ally.health < (ally.maxHealth * (Menu.Ads.AutoHeal.AllyPercent*0.01)) and GetDistance(myHero, ally) < 600 and ally ~= nil and NIDAHUMAN and not Recalling then
            CastSpell(_E, ally)
        end
    end
end

function Check() 
	if myHero:GetSpellData(_Q).name == "JavelinToss" 
	or myHero:GetSpellData(_W).name == "Bushwhack"
	or myHero:GetSpellData(_E).name == "PrimalSurge"
		then NIDAHUMAN = true NIDACOUGAR = false
	end
	if myHero:GetSpellData(_Q).name == "Takedown"
	or myHero:GetSpellData(_W).name == "Pounce"
	or myHero:GetSpellData(_E).name == "Swipe"
		then NIDAHUMAN = false NIDACOUGAR = true
	end
end

function cougarcombo()
	if myHero:CanUseSpell(_Q) == READY and Menu.NidaCombo.Qset.comboCougarQ and ValidTarget(ts.target, 300) and ts.target ~= nil then
		CastSpell(_Q)
	end

	for i, target in pairs(GetEnemyHeroes()) do
		if myHero:CanUseSpell(_E) == READY and Menu.NidaCombo.Eset.comboCougarE and ValidTarget(target, 300) and ts.target ~= nil then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, 0.5, 200, 290, 1800, myHero, false)
			if HitChance >= 2  and GetDistance(ts.target) <= 290 and myHero:CanUseSpell(_E) == READY then 
				CastSpell(_E, CastPosition.x, CastPosition.z)
			end
		end
	end

	for i, target in pairs(GetEnemyHeroes()) do
		if myHero:CanUseSpell(_W) == READY and target ~= nil and Menu.NidaCombo.Wset.comboCougarW and ValidTarget(target) then
			CastSpell(_W, mousePos.x, mousePos.z)
		end
	end

	for i, target in pairs(GetEnemyHeroes()) do
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, 0.5, 200, 290, 1800, myHero, true)
		if HitChance >= 2  and GetDistance(ts.target) <= 290 and myHero:CanUseSpell(_E) == READY then 
			CastSpell(_E, CastPosition.x, CastPosition.z)
		end
	end
end


function humancombo()
	if myHero:CanUseSpell(_Q) == READY then
		ComboQ()
	end

	if myHero:CanUseSpell(_W) == READY then
		ComboW()
	end
end

function ComboQ()
	if ts.target ~= nil and ValidTarget(ts.target, 1400) and Menu.NidaCombo.Qset.comboQ then
		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, 0.5, 30, 1400, 1300, myHero, true)
		if HitChance >= 2  and GetDistance(ts.target) <= 1400 and myHero:CanUseSpell(_Q) == READY then 
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
	end
end

function ComboW()
	if ts.target ~= nil and ValidTarget(ts.target, 1200) and Menu.NidaCombo.Wset.comboW and Menu.NidaCombo.Wset.Wstunned then
		local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(ts.target, 0.5, 125, 900)
		if HitChance >= 4  and GetDistance(ts.target) <= 1200 and myHero:CanUseSpell(_W) == READY then 
			CastSpell(_W, CastPosition.x, CastPosition.z)
		end
	end

	if ts.target ~= nil and ValidTarget(ts.target, 1200) and Menu.NidaCombo.Wset.comboW and not Menu.NidaCombo.Wset.Wstunned then
		local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(ts.target, 0.5, 125, 900)
		if HitChance >= 2  and GetDistance(ts.target) <= 1200 and myHero:CanUseSpell(_W) == READY then 
			CastSpell(_W, CastPosition.x, CastPosition.z)
		end
	end
end

function OnCreateObj(obj)
	if obj ~= nil then
		if obj.name:find("TeleportHome.troy") then
			Recalling = true
		end 
	end
end
function OnDeleteObj(obj)
	if obj ~= nil then
		if obj.name:find("TeleportHome.troy") then
			Recalling = false
		end
	end
end

function Escape()
	if Menu.Ads.escape then
		myHero:MoveTo(mousePos.x, mousePos.z)
		if myHero:CanUseSpell(_W) and NIDACOUGAR then
			CastSpell(_W, mousePos.x, mousePos.z)
		elseif NIDAHUMAN and myHero:CanUseSpell(_R) then
			CastSpell(_R)
		end
	end
end

function OnDraw()
    if Menu.drawings.humandrawings.drawCircleQ and NIDAHUMAN then
        DrawCircle(myHero.x, myHero.y, myHero.z, 1400, 0x111111)
    end     
    
    if Menu.drawings.humandrawings.drawCircleW and NIDAHUMAN then
        DrawCircle(myHero.x, myHero.y, myHero.z, 900, 0x111111)
    end

    if Menu.drawings.humandrawings.drawCircleE and NIDAHUMAN then
        DrawCircle(myHero.x, myHero.y, myHero.z, 600, 0x111111)
    end
    
    if Menu.drawings.humandrawings.drawCircleAA and NIDAHUMAN then
        DrawCircle(myHero.x, myHero.y, myHero.z, 550, ARGB(255, 0, 255, 0))
    end

    if Menu.drawings.cougardrawings.drawCircleQ and NIDACOUGAR then
        DrawCircle(myHero.x, myHero.y, myHero.z, 300, 0x111111)
    end     
    
    if Menu.drawings.cougardrawings.drawCircleW and NIDACOUGAR then
        DrawCircle(myHero.x, myHero.y, myHero.z, 375, 0x111111)
    end

    if Menu.drawings.cougardrawings.drawCircleE and NIDACOUGAR then
        DrawCircle(myHero.x, myHero.y, myHero.z, 300, 0x111111)
    end
    
    if Menu.drawings.cougardrawings.drawCircleAA and NIDACOUGAR then
        DrawCircle(myHero.x, myHero.y, myHero.z, 250, ARGB(255, 0, 255, 0))
    end
end

--[[
function NidaKillSteal()
	for i=1, heroManager.iCount do
		local enemy = heroManager:GetHero(i)
		if ValidTarget(enemy) and Menu.Ads.ks then
			qDmg = getDmg("Q",enemy,myHero) or 0
			if (GetDistance(enemy) > 525) then
				if enemy.health <= (qDmg * (0.01 * (GetDistance(enemy) * 0.166667))) and GetDistance(enemy) <= 1400 and myHero:CanUseSpell(_Q) == READY then
					local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, 0.5, 60, 1400, 1300, myHero, true)
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			elseif (GetDistance(enemy) < 525) then
				if enemy.health <= qDmg and GetDistance(enemy) <= 1400 and myHero:CanUseSpell(_Q) == READY then
					local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, 0.5, 60, 1400, 1300, myHero, true)
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end
		end
	end
end
]]