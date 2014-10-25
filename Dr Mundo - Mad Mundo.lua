--[[
 
        Mad Mundo by Lillgoalie
        Version: 1.0
       
        Features:
			Combo Mode
			Harass and Autoharass (Q)
			KS with Q
       
        Instructions on saving the file:
        - Save the file in scripts folder
       
--]]

if myHero.charName ~= "DrMundo" then return end

require 'VPrediction'

local ts
local VP = nil
local QRange, WRange, ERange, RRange = 1000, 320, 225, 0
local WActive = false

HWID = Base64Encode(tostring(os.getenv("PROCESSOR_IDENTIFIER")..os.getenv("USERNAME")..os.getenv("COMPUTERNAME")..os.getenv("PROCESSOR_LEVEL")..os.getenv("PROCESSOR_REVISION")))
id = 321
ScriptName = "MadMundo"
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIDAAAAJQAAAAgAAIAfAIAAAQAAAAQKAAAAVXBkYXRlV2ViAAEAAAACAAAADAAAAAQAETUAAAAGAUAAQUEAAB2BAAFGgUAAh8FAAp0BgABdgQAAjAHBAgFCAQBBggEAnUEAAhsAAAAXwAOAjMHBAgECAgBAAgABgUICAMACgAEBgwIARsNCAEcDwwaAA4AAwUMDAAGEAwBdgwACgcMDABaCAwSdQYABF4ADgIzBwQIBAgQAQAIAAYFCAgDAAoABAYMCAEbDQgBHA8MGgAOAAMFDAwABhAMAXYMAAoHDAwAWggMEnUGAAYwBxQIBQgUAnQGBAQgAgokIwAGJCICBiIyBxQKdQQABHwCAABcAAAAECAAAAHJlcXVpcmUABAcAAABzb2NrZXQABAcAAABhc3NlcnQABAQAAAB0Y3AABAgAAABjb25uZWN0AAQQAAAAYm9sLXRyYWNrZXIuY29tAAMAAAAAAABUQAQFAAAAc2VuZAAEGAAAAEdFVCAvcmVzdC9uZXdwbGF5ZXI/aWQ9AAQHAAAAJmh3aWQ9AAQNAAAAJnNjcmlwdE5hbWU9AAQHAAAAc3RyaW5nAAQFAAAAZ3N1YgAEDQAAAFteMC05QS1aYS16XQAEAQAAAAAEJQAAACBIVFRQLzEuMA0KSG9zdDogYm9sLXRyYWNrZXIuY29tDQoNCgAEGwAAAEdFVCAvcmVzdC9kZWxldGVwbGF5ZXI/aWQ9AAQCAAAAcwAEBwAAAHN0YXR1cwAECAAAAHBhcnRpYWwABAgAAAByZWNlaXZlAAQDAAAAKmEABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQA1AAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAMAAAADAAAAAwAAAAMAAAAEAAAABAAAAAUAAAAFAAAABQAAAAYAAAAGAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAgAAAAHAAAABQAAAAgAAAAJAAAACQAAAAkAAAAKAAAACgAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAsAAAAMAAAACwAAAAkAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAGAAAAAgAAAGEAAAAAADUAAAACAAAAYgAAAAAANQAAAAIAAABjAAAAAAA1AAAAAgAAAGQAAAAAADUAAAADAAAAX2EAAwAAADUAAAADAAAAYWEABwAAADUAAAABAAAABQAAAF9FTlYAAQAAAAEAEAAAAEBvYmZ1c2NhdGVkLmx1YQADAAAADAAAAAIAAAAMAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))()

function OnLoad()
	VP = VPrediction()

	-- Target Selector
	ts = TargetSelector(TARGET_NEAR_MOUSE,1300)

	-- Create the menu
	Menu = scriptConfig("Mad Mundo by Lillgoalie", "MundoS")
	
	Menu:addTS(ts)
	
	Menu:addSubMenu("["..myHero.charName.." - Combo]", "Combo")
	Menu.Combo:addParam("combo", "Combo mode", SCRIPT_PARAM_ONKEYDOWN, false, 32)

	Menu:addSubMenu("["..myHero.charName.." - Harass]", "Harass")
	Menu.Harass:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
	Menu.Harass:addParam("autoharass", "Auto Harass", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("A"))
	
	Menu:addSubMenu("["..myHero.charName.." - Additionals]", "Ads")
	Menu.Ads:addParam("KS", "Killsteal using Q", SCRIPT_PARAM_ONOFF, true)
	Menu.Ads:addParam("lifesave", "Life saving Ultimate", SCRIPT_PARAM_ONOFF, true)
	Menu.Ads:addParam("percenthp", "What % to ult", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	
	Menu:addSubMenu("["..myHero.charName.." - Drawings]", "drawings")
	Menu.drawings:addParam("drawCircleAA", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
	Menu.drawings:addParam("drawCircleQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	
	UpdateWeb(true, ScriptName, id, HWID)
	
	-- Message
	PrintChat("<font color = \"#33CCCC\">Mad Mundo by</font> <font color = \"#fff8e7\">Lillgoalie</font>")
end

function OnTick()
	ts:update()
	
	if GetGame().isOver then
		UpdateWeb(false, ScriptName, id, HWID)
		startUp = false;
	end

	if Menu.Ads.lifesave then
		LifeSave()
	end

	if Menu.Ads.KS then
		Killsteal()
	end

	if Menu.Combo.combo then
		Combo()
	end

	if Menu.Harass.harass then
		Harass()
	end

	if Menu.Harass.autoharass then
		AutoHarass()
	end
end

function OnBugsplat()
	UpdateWeb(false, ScriptName, id, HWID)
end

function OnUnload()
	UpdateWeb(false, ScriptName, id, HWID)
end

function Killsteal()
    for i = 1, heroManager.iCount do
        local Enemy = heroManager:getHero(i)
        if myHero:CanUseSpell(_Q) == READY and ValidTarget(Enemy, QRange, true) and Enemy.health < getDmg("Q",Enemy,myHero) + 30 then
        	if ValidTarget(ts.target, QRange) and myHero:CanUseSpell(_Q) == READY then
				for i, target in pairs(GetEnemyHeroes()) do
           		local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, 0.5, 75, 1000, 1500, myHero, true)
            		if HitChance >= 2 and GetDistance(CastPosition) < 1300 then
                		CastSpell(_Q, CastPosition.x, CastPosition.z)
           			end
        		end
			end
        end
    end
end

function Harass()
	if ValidTarget(ts.target, QRange) and myHero:CanUseSpell(_Q) == READY then
		for i, target in pairs(GetEnemyHeroes()) do
            local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, 0.5, 75, 1000, 1500, myHero, true)
            	if HitChance >= 2 and GetDistance(CastPosition) < 1300 then
                	CastSpell(_Q, CastPosition.x, CastPosition.z)
           		end
        end
	end
end

function AutoHarass()
	if ValidTarget(ts.target, QRange) and myHero:CanUseSpell(_Q) == READY then
		for i, target in pairs(GetEnemyHeroes()) do
            local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, 0.5, 75, 1000, 1500, myHero, true)
            	if HitChance >= 2 and GetDistance(CastPosition) < 1300 then
                	CastSpell(_Q, CastPosition.x, CastPosition.z)
           		end
        end
	end
end

function Combo()
	if ValidTarget(ts.target, QRange) and myHero:CanUseSpell(_Q) == READY then
		for i, target in pairs(GetEnemyHeroes()) do
            local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, 0.5, 75, 1000, 1500, myHero, true)
            	if HitChance >= 2 and GetDistance(CastPosition) < 1300 then
                	CastSpell(_Q, CastPosition.x, CastPosition.z)
           		end
        end
	end

	if not WActive and myHero:CanUseSpell(_W) == READY and CountEnemyHeroInRange(WRange) >= 1 then
		CastSpell(_W)
		else 

		if WActive and CountEnemyHeroInRange(WRange) == 0 then
			CastSpell(_W)
		end
	end

	if CountEnemyHeroInRange(ERange) >= 1 and myHero:CanUseSpell(_E) == READY then
		CastSpell(_E)
	end
end

function OnGainBuff(myHero, buff)
	if buff.name == "BurningAgony" then
		WActive = true
	end
end

function OnLoseBuff(myHero, buff)
	if buff.name == "BurningAgony" then
		WActive = false
	end
end

function LifeSave()
	if myHero.health < (myHero.maxHealth*(Menu.Ads.percenthp*0.01)) then
		if myHero:CanUseSpell(_R) then
			CastSpell(_R)
		end
	end
end

function OnDraw()
	if Menu.drawings.drawCircleQ then
		DrawCircle(myHero.x, myHero.y, myHero.z, QRange, 0x111111)
	end
	
	if Menu.drawings.drawCircleAA then
		DrawCircle(myHero.x, myHero.y, myHero.z, ERange, ARGB(255, 0, 255, 0))
	end
end