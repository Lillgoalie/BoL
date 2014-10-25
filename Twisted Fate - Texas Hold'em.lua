--[[

	Twisted Fate - Texas Hold'em by Lillgoalie
	
	Instructions on saving the file:
	- Save the file in scripts folder
	
--]]

if myHero.charName ~= "TwistedFate" then return end

require 'SOW'
require 'VPrediction'

local VP = nil
local ts
local Menu
local Recalling
local DRAWGANKTEXT
local AdditionalTimeGank = 0
local CurrentTimeGank = 0

HWID = Base64Encode(tostring(os.getenv("PROCESSOR_IDENTIFIER")..os.getenv("USERNAME")..os.getenv("COMPUTERNAME")..os.getenv("PROCESSOR_LEVEL")..os.getenv("PROCESSOR_REVISION")))
id = 321
ScriptName = "TexasHoldem"
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIDAAAAJQAAAAgAAIAfAIAAAQAAAAQKAAAAVXBkYXRlV2ViAAEAAAACAAAADAAAAAQAETUAAAAGAUAAQUEAAB2BAAFGgUAAh8FAAp0BgABdgQAAjAHBAgFCAQBBggEAnUEAAhsAAAAXwAOAjMHBAgECAgBAAgABgUICAMACgAEBgwIARsNCAEcDwwaAA4AAwUMDAAGEAwBdgwACgcMDABaCAwSdQYABF4ADgIzBwQIBAgQAQAIAAYFCAgDAAoABAYMCAEbDQgBHA8MGgAOAAMFDAwABhAMAXYMAAoHDAwAWggMEnUGAAYwBxQIBQgUAnQGBAQgAgokIwAGJCICBiIyBxQKdQQABHwCAABcAAAAECAAAAHJlcXVpcmUABAcAAABzb2NrZXQABAcAAABhc3NlcnQABAQAAAB0Y3AABAgAAABjb25uZWN0AAQQAAAAYm9sLXRyYWNrZXIuY29tAAMAAAAAAABUQAQFAAAAc2VuZAAEGAAAAEdFVCAvcmVzdC9uZXdwbGF5ZXI/aWQ9AAQHAAAAJmh3aWQ9AAQNAAAAJnNjcmlwdE5hbWU9AAQHAAAAc3RyaW5nAAQFAAAAZ3N1YgAEDQAAAFteMC05QS1aYS16XQAEAQAAAAAEJQAAACBIVFRQLzEuMA0KSG9zdDogYm9sLXRyYWNrZXIuY29tDQoNCgAEGwAAAEdFVCAvcmVzdC9kZWxldGVwbGF5ZXI/aWQ9AAQCAAAAcwAEBwAAAHN0YXR1cwAECAAAAHBhcnRpYWwABAgAAAByZWNlaXZlAAQDAAAAKmEABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQA1AAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAMAAAADAAAAAwAAAAMAAAAEAAAABAAAAAUAAAAFAAAABQAAAAYAAAAGAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAgAAAAHAAAABQAAAAgAAAAJAAAACQAAAAkAAAAKAAAACgAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAsAAAAMAAAACwAAAAkAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAGAAAAAgAAAGEAAAAAADUAAAACAAAAYgAAAAAANQAAAAIAAABjAAAAAAA1AAAAAgAAAGQAAAAAADUAAAADAAAAX2EAAwAAADUAAAADAAAAYWEABwAAADUAAAABAAAABQAAAF9FTlYAAQAAAAEAEAAAAEBvYmZ1c2NhdGVkLmx1YQADAAAADAAAAAIAAAAMAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))()

function OnLoad()
	ts = TargetSelector(TARGET_LESS_CAST, 1450)
	SelectGoldR = false

	Menu = scriptConfig("[Twisted Fate] Texas Hold'em", "TFBL")
	VP = VPrediction()
	Orbwalker = SOW(VP)
	Menu:addTS(ts)
    ts.name = "Focus"
	
	Menu:addSubMenu("["..myHero.charName.." - Orbwalker]", "SOWorb")
	Orbwalker:LoadToMenu(Menu.SOWorb)

	Menu:addSubMenu("["..myHero.charName.." - Combo]", "TFCombo")
	Menu.TFCombo:addParam("combo", "Combo mode", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Menu.TFCombo:addSubMenu("Q Settings", "Qset")
	Menu.TFCombo.Qset:addParam("comboQ", "Use Q in combo", SCRIPT_PARAM_ONOFF, true)
	Menu.TFCombo.Qset:addParam("qRange", "Use Q if target is in selected range", SCRIPT_PARAM_SLICE, 1200, 1, 1450, 0)
	Menu.TFCombo.Qset:addParam("qHitChance", "Hitchance", SCRIPT_PARAM_SLICE, 2, 1, 4, 0)
	Menu.TFCombo:addSubMenu("W Settings", "Wset")
	Menu.TFCombo.Wset:addParam("autoW", "Auto W in combo [BETA]", SCRIPT_PARAM_ONOFF, true)

	Menu:addSubMenu("["..myHero.charName.." - Pick Card]", "Wsel")
	Menu.Wsel:addParam("selectgold", "Select Gold", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
	Menu.Wsel:addParam("selectblue", "Select Blue", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	Menu.Wsel:addParam("selectred", "Select Red", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))

	Menu:addSubMenu("["..myHero.charName.." - Harass]", "Harass")
	Menu.Harass:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
	Menu.Harass:addSubMenu("Harass Settings", "Hset")
	Menu.Harass.Hset:addParam("harassrange", "Harass Range", SCRIPT_PARAM_SLICE, 1200, 1, 1450, 0)
	Menu.Harass:addParam("autoharass", "Auto-Harass", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("A"))
	Menu.Harass:addSubMenu("Auto-Harass Settings", "AHset")
	Menu.Harass.AHset:addParam("autoharassmana", "Don't Auto-Harass if mana %", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	Menu.Harass.AHset:addParam("autoharassrange", "Auto-Harass Range", SCRIPT_PARAM_SLICE, 1200, 1, 1450, 0)
	Menu.Harass.AHset:addParam("QHitChance", "Auto-Harass Hitchance", SCRIPT_PARAM_SLICE, 4, 1, 4, 0)

	Menu:addSubMenu("["..myHero.charName.." - Laneclear]", "LaneClear")
	Menu.LaneClear:addParam("lclr", "Laneclear with spells", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	Menu.LaneClear:addParam("lclrMana", "Blue instead of red if mana % <", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)

	Menu:addSubMenu("["..myHero.charName.." - Additionals]", "Ads")
	Menu.Ads:addParam("goldR", "Select Gold Card When Using Ultimate", SCRIPT_PARAM_ONOFF, true)
	Menu.Ads:addParam("notifyR", "Notify if enemy has selected HP percent in selected range", SCRIPT_PARAM_ONOFF, true)
	Menu.Ads:addParam("notifyRange", "Notify Range", SCRIPT_PARAM_SLICE, 4500, 1, 5000, 0)
	Menu.Ads:addParam("notifyPercent", "HP Percentage", SCRIPT_PARAM_SLICE, 25, 1, 100, 0)

	Menu:addSubMenu("["..myHero.charName.." - Drawings]", "drawings")
	Menu.drawings:addParam("drawCircleAA", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
	Menu.drawings:addParam("drawCircleQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	Menu.drawings:addParam("drawCircleW", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
	Menu.drawings:addParam("drawCircleR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	Menu.drawings:addParam("drawMinimapCircleR", "Draw R Range on Minimap", SCRIPT_PARAM_ONOFF, true)

	Menu.Wsel:permaShow("selectgold")
	Menu.Wsel:permaShow("selectblue")
	Menu.Wsel:permaShow("selectred")

	DRAWGANKTEXT = false

	enemyMinions = minionManager(MINION_ENEMY, 600, myHero)
	
	UpdateWeb(true, ScriptName, id, HWID)

	PrintChat("<font color = \"#33CCCC\">Texas Hold'em by</font> <font color = \"#fff8e7\">Lillgoalie</font>")
end

function OnBugsplat()
	UpdateWeb(false, ScriptName, id, HWID)
end

function OnUnload()
	UpdateWeb(false, ScriptName, id, HWID)
end

function OnTick()
	if myHero.dead then return end
	ts:update()
	enemyMinions:update()
	CardSelect()
	NotifyGank()
	UltGoldCard()
	AdditionalTimeGank = os.clock()
	
	if GetGame().isOver then
		UpdateWeb(false, ScriptName, id, HWID)
		startUp = false;
	end

	if Menu.TFCombo.combo then
		ComboTF()
	end

	if Menu.LaneClear.lclr then
		Laneclear()
	end

	if Menu.Harass.harass then
		Harass()
	end

	if Menu.Harass.autoharass then
		AutoHarass()
	end
end

function NotifyGank()
	if Menu.Ads.notifyR then
		for i, ultTarget in pairs(GetEnemyHeroes()) do
			if HealthCheck(ultTarget, Menu.Ads.notifyPercent) and Menu.Ads.notifyRange >= GetDistance(ultTarget) then
				DRAWGANKTEXT = true
				CurrentTimeGank = os.clock()
			else
				DRAWGANKTEXT = false
			end
		end
	end
end

function UltGoldCard()
	if SelectGoldR == true then
        if myHero:GetSpellData(_W).name == "goldcardlock" then
            CastSpell(_W)
        	SelectGoldR = false
    	elseif myHero:GetSpellData(_W).name == "PickACard" then
        	CastSpell(_W)
        end
    end
end

function OnProcessSpell(unit, spell)
    if unit.isMe and spell.name == "gate" then 
    	if Menu.Ads.goldR then 
    		SelectGoldR = true
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

function Harass()
	if ts.target ~= nil and ValidTarget(ts.target, 1450) then
    	local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, 0.5, 80, Menu.Harass.Hset.harassrange, 1450, myHero, false)
    	if HitChance >= 2 and GetDistance(CastPosition) < Menu.Harass.Hset.harassrange then
        	CastSpell(_Q, CastPosition.x, CastPosition.z)
    	end
	end
end

function AutoHarass()
	if ts.target ~= nil and ValidTarget(ts.target, 1450) and not Recalling then
    	local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, 0.5, 80, Menu.Harass.AHset.autoharassrange, 1450, myHero, false)
    	if HitChance >= Menu.Harass.AHset.QHitChance and GetDistance(CastPosition) < Menu.Harass.AHset.autoharassrange and (Menu.Harass.AHset.autoharassmana*0.01)*myHero.maxMana < myHero.mana then
        	CastSpell(_Q, CastPosition.x, CastPosition.z)
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

function Laneclear()
	local Name = myHero:GetSpellData(_W).name
	for i, minion in pairs(enemyMinions.objects) do
  		if minion ~= nil and ValidTarget(minion, 600) and myHero:CanUseSpell(_W) == READY and (Menu.LaneClear.lclrMana*0.01)*myHero.maxMana < myHero.mana then
  			spellName = "redcardlock"
			if Name == "PickACard" then
				CastSpell(_W)
			end
  		end
  	end

  	for i, minion in pairs(enemyMinions.objects) do
  		if minion ~= nil and ValidTarget(minion, 600) and myHero:CanUseSpell(_W) == READY and (Menu.LaneClear.lclrMana*0.01)*myHero.maxMana > myHero.mana then
  			spellName = "bluecardlock"
			if Name == "PickACard" then
				CastSpell(_W)
			end
  		end
  	end
end

function ComboTF()
	if Menu.TFCombo.Wset.autoW then
		ComboW()
	end

	if Menu.TFCombo.Qset.comboQ then
		CastQ()
	end
end

function CastQ()
	if ts.target ~= nil and ValidTarget(ts.target) then
    	local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, 0.5, 80, Menu.TFCombo.Qset.qRange, 1450, myHero, false)
    	if HitChance >= Menu.TFCombo.Qset.qHitChance and GetDistance(CastPosition) < Menu.TFCombo.Qset.qRange then
        	CastSpell(_Q, CastPosition.x, CastPosition.z)
    	end
	end
end

function ComboW()
	for i, Target in pairs(GetEnemyHeroes()) do
		if myHero:GetSpellData(_W).name == "PickACard" and Target ~= nil and ValidTarget(Target, 900) then
            CastSpell(_W)
        end

		if Target ~= nil and ValidTarget(Target, 900) then
			local AOECastPosition, MainTargetHitChance, nTargets = VP:GetCircularAOECastPosition(Target, 0, 80, 600, 2000, myHero)
			if nTargets >= 2 then
				spellName = "redcardlock"
				if Name == "PickACard" then
					CastSpell(_W)
				end
			end
		end

		if (0.25*myHero.maxMana) > myHero.mana and Target ~= nil and ValidTarget(Target, 900) then
			spellName = "bluecardlock"
			if Name == "PickACard" then
				CastSpell(_W)
			end
		end

		if (0.25*myHero.maxMana) < myHero.mana and Target ~= nil and ValidTarget(Target, 900) then
			spellName = "goldcardlock"
			if Name == "PickACard" then
				CastSpell(_W)
			end
		end
	end
end

function CardSelect()
	local Name = myHero:GetSpellData(_W).name

	if Menu.Wsel.selectblue then
		SelectCard = "Blue"
	else
		if not Menu.Wsel.selectred and not Menu.Wsel.selectgold then
			SelectCard = nil
		end
	end

	if Menu.Wsel.selectred then
		SelectCard = "Red"
	else
		if not Menu.Wsel.selectblue and not Menu.Wsel.selectgold then
			SelectCard = nil
		end
	end

	if Menu.Wsel.selectgold then
		SelectCard = "Gold"
	else
		if not Menu.Wsel.selectred and not Menu.Wsel.selectblue then
			SelectCard = nil
		end
	end

	if SelectCard == "Blue" then
		spellName = "bluecardlock"
		if Name == "PickACard" then
			CastSpell(_W)
		end
	end

	if SelectCard == "Red" then
		spellName = "redcardlock"
		if Name == "PickACard" then
			CastSpell(_W)
		end
	end

	if SelectCard == "Gold" then
		spellName = "goldcardlock"
		if Name == "PickACard" then
			CastSpell(_W)
		end
	end

	if Name == spellName then
		CastSpell(_W)
		SelectCard = nil
	end
end

function OnDraw()
	if Menu.drawings.drawCircleW then
		DrawCircle(myHero.x, myHero.y, myHero.z, 600, 0x111111)
	end		
	
	if Menu.drawings.drawCircleQ then
		DrawCircle(myHero.x, myHero.y, myHero.z, Menu.TFCombo.Qset.qRange, 0x111111)
	end
	
	if Menu.drawings.drawCircleAA then
		DrawCircle(myHero.x, myHero.y, myHero.z, 600, ARGB(255, 0, 255, 0))
	end

	if Menu.drawings.drawCircleR then
		DrawCircle(myHero.x, myHero.y, myHero.z, 5500, 0x111111)
	end

	if Menu.drawings.drawMinimapCircleR and myHero.level >= 6 then
		DrawCircleMinimap(myHero.x, myHero.y, myHero.z, 5500)
	end

	if DRAWGANKTEXT or ((AdditionalTimeGank-CurrentTimeGank) <= 2) then
		DrawText("Enemy less than selected hp in selected range!", 24, 760, 910, 0xFFFF0000)
	end	
end