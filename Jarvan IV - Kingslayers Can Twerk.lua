--[[

	Jarvan IV - Kingslayers Can Twerk by Lillgoalie
	
	Instructions on saving the file:
	- Save the file in scripts folder
	
--]]

if myHero.charName ~= "JarvanIV" then return end

require 'SOW'
require 'VPrediction'

local VP = nil
local ts
local Menu

HWID = Base64Encode(tostring(os.getenv("PROCESSOR_IDENTIFIER")..os.getenv("USERNAME")..os.getenv("COMPUTERNAME")..os.getenv("PROCESSOR_LEVEL")..os.getenv("PROCESSOR_REVISION")))
id = 321
ScriptName = "KingslayersCanTwerk"
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIDAAAAJQAAAAgAAIAfAIAAAQAAAAQKAAAAVXBkYXRlV2ViAAEAAAACAAAADAAAAAQAETUAAAAGAUAAQUEAAB2BAAFGgUAAh8FAAp0BgABdgQAAjAHBAgFCAQBBggEAnUEAAhsAAAAXwAOAjMHBAgECAgBAAgABgUICAMACgAEBgwIARsNCAEcDwwaAA4AAwUMDAAGEAwBdgwACgcMDABaCAwSdQYABF4ADgIzBwQIBAgQAQAIAAYFCAgDAAoABAYMCAEbDQgBHA8MGgAOAAMFDAwABhAMAXYMAAoHDAwAWggMEnUGAAYwBxQIBQgUAnQGBAQgAgokIwAGJCICBiIyBxQKdQQABHwCAABcAAAAECAAAAHJlcXVpcmUABAcAAABzb2NrZXQABAcAAABhc3NlcnQABAQAAAB0Y3AABAgAAABjb25uZWN0AAQQAAAAYm9sLXRyYWNrZXIuY29tAAMAAAAAAABUQAQFAAAAc2VuZAAEGAAAAEdFVCAvcmVzdC9uZXdwbGF5ZXI/aWQ9AAQHAAAAJmh3aWQ9AAQNAAAAJnNjcmlwdE5hbWU9AAQHAAAAc3RyaW5nAAQFAAAAZ3N1YgAEDQAAAFteMC05QS1aYS16XQAEAQAAAAAEJQAAACBIVFRQLzEuMA0KSG9zdDogYm9sLXRyYWNrZXIuY29tDQoNCgAEGwAAAEdFVCAvcmVzdC9kZWxldGVwbGF5ZXI/aWQ9AAQCAAAAcwAEBwAAAHN0YXR1cwAECAAAAHBhcnRpYWwABAgAAAByZWNlaXZlAAQDAAAAKmEABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQA1AAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAMAAAADAAAAAwAAAAMAAAAEAAAABAAAAAUAAAAFAAAABQAAAAYAAAAGAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAgAAAAHAAAABQAAAAgAAAAJAAAACQAAAAkAAAAKAAAACgAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAsAAAAMAAAACwAAAAkAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAGAAAAAgAAAGEAAAAAADUAAAACAAAAYgAAAAAANQAAAAIAAABjAAAAAAA1AAAAAgAAAGQAAAAAADUAAAADAAAAX2EAAwAAADUAAAADAAAAYWEABwAAADUAAAABAAAABQAAAF9FTlYAAQAAAAEAEAAAAEBvYmZ1c2NhdGVkLmx1YQADAAAADAAAAAIAAAAMAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))()

function OnLoad()
	ultActive = false

	Menu = scriptConfig("[Jarvan IV] Kingslayers Can Twerk", "TTKBL")
	VP = VPrediction()
	Orbwalker = SOW(VP)
	
	Menu:addSubMenu("["..myHero.charName.." - Orbwalker]", "SOWorb")
	Orbwalker:LoadToMenu(Menu.SOWorb)

	Menu:addSubMenu("["..myHero.charName.." - Combo]", "JCombo")
	Menu.JCombo:addParam("combo", "Combo mode", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Menu.JCombo:addParam("comboEQ", "Use Q+E and QE in Combo", SCRIPT_PARAM_ONOFF, true)
	Menu.JCombo:addParam("comboSaveEQ", "Always save E+Q for EQ combo", SCRIPT_PARAM_ONOFF, false)
	Menu.JCombo:addParam("comboW", "Use W in Combo", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("["..myHero.charName.." - Harass]", "Harass")
	Menu.Harass:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
	Menu.Harass:addParam("autoharass", "Auto-Harass", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("A"))
	Menu.Harass:addParam("ahMana", "Auto-Harass if mana is over %", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)

	Menu:addSubMenu("["..myHero.charName.." - Laneclear]", "LaneClear")
	Menu.LaneClear:addParam("laneClear", "Laneclear with spells", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	Menu.LaneClear:addParam("laneclearQ", "Use Q in Laneclear", SCRIPT_PARAM_ONOFF, true)
	Menu.LaneClear:addParam("lclrMana", "Use Spells if mana is over %", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)

	Menu:addSubMenu("["..myHero.charName.." - Additionals]", "Ads")
	Menu.Ads:addParam("EQcommand", "Key for EQ combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("c"))

	Menu:addSubMenu("["..myHero.charName.." - Drawings]", "drawings")
	Menu.drawings:addParam("drawCircleAA", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
	Menu.drawings:addParam("drawCircleEQ", "Draw EQ Range", SCRIPT_PARAM_ONOFF, true)
	Menu.drawings:addParam("drawCircleR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)

	Menu.JCombo:permaShow("combo")

	enemyMinions = minionManager(MINION_ENEMY, 700, myHero)
	
	UpdateWeb(true, ScriptName, id, HWID)

	PrintChat("<font color = \"#33CCCC\">Kingslayers Can Twerk by</font> <font color = \"#fff8e7\">Lillgoalie</font>")
end

function OnBugsplat()
	UpdateWeb(false, ScriptName, id, HWID)
end

function OnUnload()
	UpdateWeb(false, ScriptName, id, HWID)
end

function OnTick()
	if myHero.dead then return end
	enemyMinions:update()
	
	if GetGame().isOver then
		UpdateWeb(false, ScriptName, id, HWID)
		startUp = false;
	end

	if Menu.JCombo.combo then
		JarvanCombo()
	end

	if Menu.Ads.EQcommand then
		mousePosEQ()
	end

	if Menu.LaneClear.laneclearQ and Menu.LaneClear.laneClear then
		lclr()
	end

	if Menu.Harass.harass then
		useHarass()
	end

	if Menu.Harass.autoharass then
		useAutoHarass()
	end
end

function useHarass()
	for i, target in pairs(GetEnemyHeroes()) do
        local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, 0.5, 70, 700, 1000, myHero, false)
        if target ~= nil and ValidTarget(target) and HitChance >= 2 and GetDistance(CastPosition) < 700 and myHero:CanUseSpell(_Q) == READY then
           	CastSpell(_Q, CastPosition.x, CastPosition.z)
        end
	end
end

function useAutoHarass()
	for i, target in pairs(GetEnemyHeroes()) do
        local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, 0.5, 70, 700, 1000, myHero, false)
        if target ~= nil and ValidTarget(target) and HitChance >= 2 and GetDistance(CastPosition) < 700 and myHero:CanUseSpell(_Q) == READY and ManaCheck(myHero, Menu.Harass.ahMana) then
           	CastSpell(_Q, CastPosition.x, CastPosition.z)
        end
	end
end

function lclr()
	for i, minion in pairs(enemyMinions.objects) do
		if minion ~= nil and ValidTarget(minion, 700) then
        	local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(minion, 0.5, 70, 700, 1000, myHero, false)
        	if HitChance >= 2 and GetDistance(CastPosition) < 700 and myHero:CanUseSpell(_Q) == READY and ManaCheck(myHero, Menu.LaneClear.lclrMana) then
           		CastSpell(_Q, CastPosition.x, CastPosition.z)
        	end
        end
    end
end

function ManaCheck(unit, ManaValue)
	if unit.mana < (unit.maxMana * (ManaValue/100))
		then return true
	else
		return false
	end
end

function JarvanCombo()
	if Menu.JCombo.comboEQ then
		ComboEQ()
	end

	if Menu.JCombo.comboW then
		ComboW()
	end
end

function ComboW()
	if CountEnemyHeroInRange(280) >= 1 then
		CastSpell(_W)
	end
end

function ComboEQ()
	if Menu.JCombo.combo then
		if Menu.JCombo.comboSaveEQ then
			for i, target in pairs(GetEnemyHeroes()) do
        		local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(target, 0.5, 70, 800, 1000)
        		if target ~= nil and ValidTarget(target) and HitChance >= 2 and GetDistance(CastPosition) < 800 and myHero:CanUseSpell(_E) == READY and myHero:CanUseSpell(_Q) == READY then
            		CastSpell(_E, CastPosition.x, CastPosition.z)
           			CastSpell(_Q, CastPosition.x, CastPosition.z)
        		end
    		end
		else
			for i, target in pairs(GetEnemyHeroes()) do
        		local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(target, 0.5, 70, 800, 1000)
        		if target ~= nil and ValidTarget(target) and HitChance >= 2 and GetDistance(CastPosition) < 800 then
            		CastSpell(_E, CastPosition.x, CastPosition.z)
           			CastSpell(_Q, CastPosition.x, CastPosition.z)
           		end
        	end
    	end
	end
end

function mousePosEQ()
	if myHero:CanUseSpell(_E) == READY and myHero:CanUseSpell(_Q) == READY then
		CastSpell(_E, mousePos.x, mousePos.z)
		CastSpell(_Q, mousePos.x, mousePos.z)
	end
end

function PluginOnCreateObj(obj)
	if obj.name:find("JarvanCataclysm_tar.troy") then
		ultActive = true
	end
end

function PluginOnDeleteObj(obj)
	if obj.name:find("JarvanCataclysm_tar.troy") then
		ultActive = false
	end
end

function OnDraw()
	if myHero.dead then return end

	if Menu.drawings.drawCircleEQ then
		DrawCircle(myHero.x, myHero.y, myHero.z, 800, 0x111111)
	end
	
	if Menu.drawings.drawCircleAA then
		DrawCircle(myHero.x, myHero.y, myHero.z, 250, ARGB(255, 0, 255, 0))
	end

	if Menu.drawings.drawCircleR then
		DrawCircle(myHero.x, myHero.y, myHero.z, 650, 0x111111)
	end
end