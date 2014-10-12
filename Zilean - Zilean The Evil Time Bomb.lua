--[[

	Zilean The Evil Time Bomb by Lillgoalie
	
	Instructions on saving the file:
	- Save the file in scripts folder
	
--]]
if myHero.charName ~= "Zilean" then return end

require 'SOW'
require 'VPrediction'

local ts
local VP = nil
local Recalling

function OnLoad()
	-- Target Selector
	ts = TargetSelector(TARGET_LOW_HP_PRIORITY, 1200)

	VP = VPrediction()

	-- Create the menu
	Menu = scriptConfig("Zilean by Lillgoalie", "ZileanBL")
	Orbwalker = SOW(VP)
    Menu:addTS(ts)
    ts.name = "Focus"

	Menu:addSubMenu("["..myHero.charName.." - Orbwalker]", "SOWorb")
    Orbwalker:LoadToMenu(Menu.SOWorb)
	
	Menu:addSubMenu("["..myHero.charName.." - Combo]", "Combo")
	Menu.Combo:addParam("combo", "Combo Mode", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Menu.Combo:addParam("comboE", "Use E on enemy in combo", SCRIPT_PARAM_ONOFF, true)
	Menu.Combo:addParam("Eself", "Use E on yourself if out of range", SCRIPT_PARAM_ONOFF, true)
	
	Menu:addSubMenu("["..myHero.charName.." - Harass]", "Harass")
	Menu.Harass:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
	Menu.Harass:addParam("autoharass", "Auto Harass", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("A"))
	
	Menu:addSubMenu("["..myHero.charName.." - Additionals]", "Ads")
	Menu.Ads:addParam("FarmR", "Farm R with W", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("U"))
	Menu.Ads:addParam("TravelMode", "Travel Mode", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("T"))
	Menu.Ads:addParam("escape", "Escape key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	Menu.Ads:addParam("lifesave", "Life saving Ultimate", SCRIPT_PARAM_ONOFF, true)
	Menu.Ads:addParam("percenthp", "What % to ult", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)

	Menu:addSubMenu("["..myHero.charName.." - Drawings]", "drawings")
	Menu.drawings:addParam("drawCircleAA", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
	Menu.drawings:addParam("drawCircleQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	Menu.drawings:addParam("drawCircleR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	
	-- Message
	PrintChat("<font color = \"#33CCCC\">Zilean by</font> <font color = \"#fff8e7\">Lillgoalie</font>")
end

function OnTick()
	-- Check for enemies repeatly
	ts:update()
	if Menu.Ads.lifesave then
		LifeSave()
	end
	
	if Menu.Ads.escape then
		Escape()
	end
	
	-- Enemy in range?
	if (ts.target ~= nil) and ValidTarget(ts.target) then
		-- Combo key pressed?
		if (Menu.Combo.combo) then
			-- Able to cast Q?
			if (myHero:CanUseSpell(_Q) == READY) then
				-- Cast spell on target
				CastSpell(_Q, ts.target)
			end
				-- Able to cast W?
			if (myHero:CanUseSpell(_W) == READY) then
				-- Not able to cast Q?
				if (myHero:CanUseSpell(_Q) ~= READY) then
					-- Cast spell on enemy
					CastSpell(_W)
				end
			end
			
			-- E in combo enabled?
			if (Menu.Combo.comboE) then
				-- Able to cast E?
				if (myHero:CanUseSpell(_E) == READY) and GetDistance(ts.target) < 700 then
					-- Cast spell on target
					CastSpell(_E, ts.target)
				end
			end

			if Menu.Combo.Eself then
				if (myHero:CanUseSpell(_E) == READY) and GetDistance(ts.target) < 1200 and GetDistance(ts.target) > 700 then
					CastSpell(_E, myHero)
				end
			end
		end
	end
	
	if (ts.target ~= nil) and ValidTarget(ts.target) then
		if (Menu.Combo.combo == false) then
			if (Menu.Harass.harass) then
				if (myHero:CanUseSpell(_Q) == READY) then
					CastSpell(_Q, ts.target)
					else
					
					if (myHero:CanUseSpell(_W) == READY) then
						CastSpell(_W)
					end
				end
			end
		end
	end
	
	if (ts.target ~= nil) and ValidTarget(ts.target) then
		if (Menu.Combo.combo == false) then
			if (Menu.Harass.autoharass) and not Recalling then
				if (myHero:CanUseSpell(_Q) == READY) then
					CastSpell(_Q, ts.target)
					if (myHero:CanUseSpell(_Q) ~= READY) then
						CastSpell(_W)
					end
				end
			end
		end
	end
		
	-- Combo key not pressed?
	if (Menu.Combo.combo == false) then
		-- Travel mode enabled in menu?
		if (Menu.Ads.TravelMode) then
			-- E Ready?
			if (myHero:CanUseSpell(_E) == READY) then
				CastSpell(_E, myHero)
			else
			
			if (myHero:CanUseSpell(_W) == READY) then
				CastSpell(_W)
			end
			end
		end
	end
	
	-- Is farming R enabled in menu?
	if (Menu.Ads.FarmR) then
		-- Is champion higher than level 6?
		if (myHero.level >= 6) then
			-- Can't use R?
			if (myHero:CanUseSpell(_R) ~= READY) then
				-- Can we use W?
				if (myHero:CanUseSpell(_W) == READY) then
					-- Cast W
					CastSpell(_W)
				end
			end
		end
	end
end

function Escape()
	if myHero:CanUseSpell(_E) then
		CastSpell(_E, myHero)
	end
	myHero:MoveTo(mousePos.x, mousePos.z)
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

function LifeSave()
	if myHero.health < (myHero.maxHealth*(Menu.Ads.percenthp*0.01)) then
		if myHero:CanUseSpell(_R) then
			CastSpell(_R)
		end
	end

	for i=1, heroManager.iCount do
        local ally = heroManager:getHero(i)
        if ally.team == myHero.team and ally.team ~= TEAM_ENEMY and myHero:CanUseSpell(_R) == READY and ally.health < (ally.maxHealth * (Menu.Ads.percenthp*0.01)) and GetDistance(myHero, ally) < 900 and ally ~= nil then
            CastSpell(_R, ally)
        end
    end
end

function OnDraw()
	--Draw Range if activated in menu
	if (Menu.drawings.drawCircleAA) then
		DrawCircle(myHero.x, myHero.y, myHero.z, 600, ARGB(255, 0, 255, 0))
	end

	if (Menu.drawings.drawCircleQ) then
		DrawCircle(myHero.x, myHero.y, myHero.z, 700, 0x111111)
	end

	if (Menu.drawings.drawCircleR) then
		DrawCircle(myHero.x, myHero.y, myHero.z, 900, 0x111111)
	end
end