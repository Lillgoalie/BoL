if myHero.charName ~= "Malphite" then return end

require 'VPrediction'
require 'SOW'

local ts
local VP = nil

QRange, WRange, ERange, RRange = 625, 125, 390, 1000

HWID = Base64Encode(tostring(os.getenv("PROCESSOR_IDENTIFIER")..os.getenv("USERNAME")..os.getenv("COMPUTERNAME")..os.getenv("PROCESSOR_LEVEL")..os.getenv("PROCESSOR_REVISION")))
id = 321
ScriptName = "ForgottenMalphite"
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIDAAAAJQAAAAgAAIAfAIAAAQAAAAQKAAAAVXBkYXRlV2ViAAEAAAACAAAADAAAAAQAETUAAAAGAUAAQUEAAB2BAAFGgUAAh8FAAp0BgABdgQAAjAHBAgFCAQBBggEAnUEAAhsAAAAXwAOAjMHBAgECAgBAAgABgUICAMACgAEBgwIARsNCAEcDwwaAA4AAwUMDAAGEAwBdgwACgcMDABaCAwSdQYABF4ADgIzBwQIBAgQAQAIAAYFCAgDAAoABAYMCAEbDQgBHA8MGgAOAAMFDAwABhAMAXYMAAoHDAwAWggMEnUGAAYwBxQIBQgUAnQGBAQgAgokIwAGJCICBiIyBxQKdQQABHwCAABcAAAAECAAAAHJlcXVpcmUABAcAAABzb2NrZXQABAcAAABhc3NlcnQABAQAAAB0Y3AABAgAAABjb25uZWN0AAQQAAAAYm9sLXRyYWNrZXIuY29tAAMAAAAAAABUQAQFAAAAc2VuZAAEGAAAAEdFVCAvcmVzdC9uZXdwbGF5ZXI/aWQ9AAQHAAAAJmh3aWQ9AAQNAAAAJnNjcmlwdE5hbWU9AAQHAAAAc3RyaW5nAAQFAAAAZ3N1YgAEDQAAAFteMC05QS1aYS16XQAEAQAAAAAEJQAAACBIVFRQLzEuMA0KSG9zdDogYm9sLXRyYWNrZXIuY29tDQoNCgAEGwAAAEdFVCAvcmVzdC9kZWxldGVwbGF5ZXI/aWQ9AAQCAAAAcwAEBwAAAHN0YXR1cwAECAAAAHBhcnRpYWwABAgAAAByZWNlaXZlAAQDAAAAKmEABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQA1AAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAMAAAADAAAAAwAAAAMAAAAEAAAABAAAAAUAAAAFAAAABQAAAAYAAAAGAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAgAAAAHAAAABQAAAAgAAAAJAAAACQAAAAkAAAAKAAAACgAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAsAAAAMAAAACwAAAAkAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAGAAAAAgAAAGEAAAAAADUAAAACAAAAYgAAAAAANQAAAAIAAABjAAAAAAA1AAAAAgAAAGQAAAAAADUAAAADAAAAX2EAAwAAADUAAAADAAAAYWEABwAAADUAAAABAAAABQAAAF9FTlYAAQAAAAEAEAAAAEBvYmZ1c2NhdGVkLmx1YQADAAAADAAAAAIAAAAMAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))()

function OnLoad()
	VP = VPrediction()
	-- Target Selector
	ts = TargetSelector(TARGET_LOW_HP_PRIORITY,1000)

	Menu = scriptConfig("Forgotten Malphite by Lillgoalie", "Malphite")

	Orbwalker = SOW(VP)
    Menu:addTS(ts)
    ts.name = "Focus"
           
    Menu:addSubMenu("["..myHero.charName.." - Orbwalker]", "SOWorb")
    Orbwalker:LoadToMenu(Menu.SOWorb)

	Menu:addSubMenu("["..myHero.charName.." - Combo]", "MalpCombo")
	Menu.MalpCombo:addParam("combo", "Combo mode", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Menu.MalpCombo:addParam("comboR", "Use R in Combo", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("["..myHero.charName.." - Harass]", "Harass")
	Menu.Harass:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
	Menu.Harass:addParam("autoharass", "Auto Harass", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("A"))

	Menu:addSubMenu("["..myHero.charName.." - Additionals]", "Ads")
	Menu.Ads:addParam("ks", "Killsteal with Q", SCRIPT_PARAM_ONOFF, true)
	Menu.Ads:addParam("escape", "Escape key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))

	Menu:addSubMenu("["..myHero.charName.." - Drawings]", "drawings")
	Menu.drawings:addParam("drawCircleAA", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
	Menu.drawings:addParam("drawCircleQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	Menu.drawings:addParam("drawCircleR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)

	enemyMinions = minionManager(MINION_ENEMY, 625, myHero)
	jungleMinions = minionManager(MINION_JUNGLE, 625, myHero)
	
	UpdateWeb(true, ScriptName, id, HWID)

	PrintChat("<font color = \"#33CCCC\">Forgotten Malphite by</font> <font color = \"#fff8e7\">Lillgoalie</font>")
end

function OnBugsplat()
	UpdateWeb(false, ScriptName, id, HWID)
end

function OnUnload()
	UpdateWeb(false, ScriptName, id, HWID)
end

function Escape()
	myHero:MoveTo(mousePos.x, mousePos.z)
	for i, minion in pairs(enemyMinions.objects) do
  		if minion ~= nil and ValidTarget(minion, 625) and myHero:CanUseSpell(_Q) == READY then
  			CastSpell(_Q, minion)
  		end
  	end

  	for i, minion in pairs(jungleMinions.objects) do
  		if minion ~= nil and ValidTarget(minion, 625) and myHero:CanUseSpell(_Q) == READY then
  			CastSpell(_Q, minion)
  		end
  	end

  	for i, escapeTarget in pairs(GetEnemyHeroes()) do
  		if escapeTarget ~= nil and ValidTarget(escapeTarget, 625) and myHero:CanUseSpell(_Q) == READY then
  			CastSpell(_Q, escapeTarget)
  		end
  	end
end

function OnTick()
	-- Check for enemies repeatly
	ts:update()
	jungleMinions:update()
	enemyMinions:update()
	Killsteal()
	
	if GetGame().isOver then
		UpdateWeb(false, ScriptName, id, HWID)
		startUp = false;
	end

	if Menu.Ads.escape then
		Escape()
	end

	if Menu.MalpCombo.combo then
		Malpcombo()
	end

	if Menu.Harass.harass then
		Harass()
	end

	if Menu.Harass.autoharass then
		AutoHarass()
	end
end

function Killsteal()
	for i=1, heroManager.iCount do
		local enemy = heroManager:GetHero(i)
		if ValidTarget(enemy) and Menu.Ads.ks then
			qDmg = (myHero:CanUseSpell(_Q) == READY and getDmg("Q",enemy,myHero) or 0)
			if enemy.health <= (qDmg) and GetDistance(enemy) <= QRange and myHero.CanUseSpell(_Q) == READY then
				CastSpell(_Q, enemy)
			end
		end
	end
end

function Malpcombo()
	if ValidTarget(ts.target, RRange) and myHero:CanUseSpell(_R) == READY and Menu.MalpCombo.comboR then
			for i, target in pairs(GetEnemyHeroes()) do
				local CastPosition,  HitChance,  Position = VP:GetCircularAOECastPosition(ts.target, 0, 270, 1000, 700, myHero)
					if HitChance >= 2 and GetDistance(CastPosition) < 1000 then
						CastSpell(_R, CastPosition.x, CastPosition.z)
			end
		end
	end

	if ValidTarget(ts.target, ERange) and myHero:CanUseSpell(_E) == READY then
		CastSpell(_E)
	end

	if ValidTarget(ts.target, QRange) and myHero:CanUseSpell(_Q) == READY then
		CastSpell(_Q, ts.target)
	end

	if ValidTarget(ts.target, WRange) and myHero:CanUseSpell(_W) == READY then
		CastSpell(_W)
	end
end

function Harass()
	if ValidTarget(ts.target, ERange) and myHero:CanUseSpell(_E) == READY then
		CastSpell(_E)
	end

	if ValidTarget(ts.target, QRange) and myHero:CanUseSpell(_Q) == READY then
		CastSpell(_Q, ts.target)
	end
end

function AutoHarass()
	if ValidTarget(ts.target, ERange) and myHero:CanUseSpell(_E) == READY then
		CastSpell(_E)
	end

	if ValidTarget(ts.target, QRange) and myHero:CanUseSpell(_Q) == READY then
		CastSpell(_Q, ts.target)
	end
end

function OnDraw()
	if Menu.drawings.drawCircleR then
		DrawCircle(myHero.x, myHero.y, myHero.z, RRange, 0x111111)
	end		

	if Menu.drawings.drawCircleQ then
		DrawCircle(myHero.x, myHero.y, myHero.z, QRange, 0x111111)
	end

	if Menu.drawings.drawCircleAA then
		DrawCircle(myHero.x, myHero.y, myHero.z, 125, ARGB(255, 0, 255, 0))
	end
end