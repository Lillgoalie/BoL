if myHero.charName ~= "Sion" then return end

require 'VPrediction'
require 'SOW'

local ts
local QRange, WRange, ERange, RRange = 550, 450, 250, 250
local EActive = false

function OnLoad()
	VP = VPrediction()
	-- Target Selector
	ts = TargetSelector(TARGET_LESS_CAST, 550)
		
	Menu = scriptConfig("Sion Says by Lillgoalie", "SionBL")
	Orbwalker = SOW(VP)
	Menu:addTS(ts)
	
	Menu:addSubMenu("["..myHero.charName.." - Orbwalker]", "SOWorb")
	Orbwalker:LoadToMenu(Menu.SOWorb)

	Menu:addSubMenu("["..myHero.charName.." - Combo]", "SionCombo")
	Menu.SionCombo:addParam("combo", "Combo mode", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Menu.SionCombo:addParam("comboQ", "Use Q in Combo", SCRIPT_PARAM_ONOFF, true)
	Menu.SionCombo:addParam("comboW", "Use W in Combo", SCRIPT_PARAM_ONOFF, true)
	Menu.SionCombo:addParam("comboE", "Use E in Combo", SCRIPT_PARAM_ONOFF, true)
	Menu.SionCombo:addParam("comboR", "Use R in Combo", SCRIPT_PARAM_ONOFF, true)
	
	Menu:addSubMenu("["..myHero.charName.." - Harass]", "Harass")
	Menu.Harass:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
	Menu.Harass:addParam("autoharass", "Auto Harass", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("A"))
	Menu.Harass:addParam("harassQ", "Use Q in Harass", SCRIPT_PARAM_ONOFF, true)
	Menu.Harass:addParam("harassW", "Use W in Harass", SCRIPT_PARAM_ONOFF, false)

	Menu:addSubMenu("["..myHero.charName.." - Additionals]", "Ads")
	Menu.Ads:addParam("ks", "Killsteal with Q", SCRIPT_PARAM_ONOFF, true)
	
	Menu:addSubMenu("["..myHero.charName.." - Drawings]", "drawings")
	Menu.drawings:addParam("drawCircleAA", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
	Menu.drawings:addParam("drawCircleQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	Menu.drawings:addParam("drawCircleW", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
	
	PrintChat("<font color = \"#33CCCC\">Sion Says by</font> <font color = \"#fff8e7\">Lillgoalie</font>")
end

function OnTick()
	ts:update()
	KS()

	if Menu.SionCombo.combo then
		Sioncombo()
	end

	if Menu.Harass.harass then
		_harass()
	end

	if Menu.Harass.autoharass then
		autoHarass()
	end

	if Menu.Ads.farmE then
		FarmClear()
	end

	if Menu.Ads.clearE then
		FarmClear()
	end
end

function OnGainBuff(myHero, buff)
	if buff.name == "Enrage" then
		EActive = true
	end
end

function OnLoseBuff(myHero, buff)
	if buff.name == "Enrage" then
		EActive = false
	end
end

function KS()
	for i=1, heroManager.iCount do
		local enemy = heroManager:GetHero(i)
		if ValidTarget(enemy) and Menu.Ads.ks then
			qDmg = getDmg("Q",enemy,myHero) or 0
			if enemy.health <= qDmg and GetDistance(enemy) <= QRange and myHero:CanUseSpell(_Q) == READY then
				CastSpell(_Q, enemy)
			end
		end
	end
end

function _harass()
	if myHero:CanUseSpell(_Q) == READY and ValidTarget(ts.target, QRange) and Menu.Harass.harassQ then
		CastSpell(_Q, ts.target)
	end

	if myHero:CanUseSpell(_W) == READY and ValidTarget(ts.target, WRange) and Menu.Harass.harassW then
		CastSpell(_W)
	end
end

function autoHarass()
	if myHero:CanUseSpell(_Q) == READY and ValidTarget(ts.target, QRange) and Menu.Harass.harassQ then
		CastSpell(_Q, ts.target)
	end

	if myHero:CanUseSpell(_W) == READY and ValidTarget(ts.target, WRange) and Menu.Harass.harassW then
		CastSpell(_W)
	end
end

function Sioncombo()
	if myHero:CanUseSpell(_Q) == READY and ValidTarget(ts.target, QRange) and Menu.SionCombo.comboQ then
		CastSpell(_Q, ts.target)
	end

	if myHero:CanUseSpell(_W) == READY and ValidTarget(ts.target, WRange) and Menu.SionCombo.comboW then
		CastSpell(_W)
	end

	if myHero:CanUseSpell(_E) == READY and ValidTarget(ts.target, ERange) and Menu.SionCombo.comboE and not EActive then
		CastSpell(_E)
	end

	if myHero:CanUseSpell(_R) == READY and ValidTarget(ts.target, RRange) and Menu.SionCombo.comboR then
		CastSpell(_R)
	end
end

function OnDraw()
	if Menu.drawings.drawCircleW then
		DrawCircle(myHero.x, myHero.y, myHero.z, WRange, 0x111111)
	end		
	
	if Menu.drawings.drawCircleQ then
		DrawCircle(myHero.x, myHero.y, myHero.z, QRange, 0x111111)
	end
	
	if Menu.drawings.drawCircleAA then
		DrawCircle(myHero.x, myHero.y, myHero.z, 250, ARGB(255, 0, 255, 0))
	end
end