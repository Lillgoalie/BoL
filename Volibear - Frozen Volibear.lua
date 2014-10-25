--[[
 
        Frozen Volibear by Lillgoalie (+Ikita's W KS script)
       
        Instructions on saving the file:
        - Save the file in scripts folder
       
--]]

if myHero.charName ~= "Volibear" then return end

require 'VPrediction'
require 'SOW'

local ts
local Menu

QRange, ERange, WRange, RRange = 600, 405, 400, 125
player = GetMyHero()

HWID = Base64Encode(tostring(os.getenv("PROCESSOR_IDENTIFIER")..os.getenv("USERNAME")..os.getenv("COMPUTERNAME")..os.getenv("PROCESSOR_LEVEL")..os.getenv("PROCESSOR_REVISION")))
id = 321
ScriptName = "FrozenVolibear"
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIDAAAAJQAAAAgAAIAfAIAAAQAAAAQKAAAAVXBkYXRlV2ViAAEAAAACAAAADAAAAAQAETUAAAAGAUAAQUEAAB2BAAFGgUAAh8FAAp0BgABdgQAAjAHBAgFCAQBBggEAnUEAAhsAAAAXwAOAjMHBAgECAgBAAgABgUICAMACgAEBgwIARsNCAEcDwwaAA4AAwUMDAAGEAwBdgwACgcMDABaCAwSdQYABF4ADgIzBwQIBAgQAQAIAAYFCAgDAAoABAYMCAEbDQgBHA8MGgAOAAMFDAwABhAMAXYMAAoHDAwAWggMEnUGAAYwBxQIBQgUAnQGBAQgAgokIwAGJCICBiIyBxQKdQQABHwCAABcAAAAECAAAAHJlcXVpcmUABAcAAABzb2NrZXQABAcAAABhc3NlcnQABAQAAAB0Y3AABAgAAABjb25uZWN0AAQQAAAAYm9sLXRyYWNrZXIuY29tAAMAAAAAAABUQAQFAAAAc2VuZAAEGAAAAEdFVCAvcmVzdC9uZXdwbGF5ZXI/aWQ9AAQHAAAAJmh3aWQ9AAQNAAAAJnNjcmlwdE5hbWU9AAQHAAAAc3RyaW5nAAQFAAAAZ3N1YgAEDQAAAFteMC05QS1aYS16XQAEAQAAAAAEJQAAACBIVFRQLzEuMA0KSG9zdDogYm9sLXRyYWNrZXIuY29tDQoNCgAEGwAAAEdFVCAvcmVzdC9kZWxldGVwbGF5ZXI/aWQ9AAQCAAAAcwAEBwAAAHN0YXR1cwAECAAAAHBhcnRpYWwABAgAAAByZWNlaXZlAAQDAAAAKmEABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQA1AAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAMAAAADAAAAAwAAAAMAAAAEAAAABAAAAAUAAAAFAAAABQAAAAYAAAAGAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAgAAAAHAAAABQAAAAgAAAAJAAAACQAAAAkAAAAKAAAACgAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAsAAAAMAAAACwAAAAkAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAGAAAAAgAAAGEAAAAAADUAAAACAAAAYgAAAAAANQAAAAIAAABjAAAAAAA1AAAAAgAAAGQAAAAAADUAAAADAAAAX2EAAwAAADUAAAADAAAAYWEABwAAADUAAAABAAAABQAAAF9FTlYAAQAAAAEAEAAAAEBvYmZ1c2NhdGVkLmx1YQADAAAADAAAAAIAAAAMAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))()

function OnLoad()
	VP = VPrediction()

	-- Target Selector
	ts = TargetSelector(TARGET_LOW_HP_PRIORITY,700)

	-- Create the menu
	Menu = scriptConfig("Frozen Volibear by Lillgoalie", "FrozenVolibear")
	
	Orbwalker = SOW(VP)
    Menu:addTS(ts)
    ts.name = "Focus"

    Menu:addSubMenu("["..myHero.charName.." - Orbwalker]", "SOWorb")
    Orbwalker:LoadToMenu(Menu.SOWorb)

	Menu:addSubMenu("["..myHero.charName.." - Combo]", "VoliCombo")
	Menu.VoliCombo:addParam("combo", "Combo mode", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Menu.VoliCombo:addParam("comboQ", "Use Q in Combo", SCRIPT_PARAM_ONOFF, true)
	Menu.VoliCombo:addParam("comboW", "Use W in Combo", SCRIPT_PARAM_ONOFF, false)
	Menu.VoliCombo:addParam("comboE", "Use E in Combo", SCRIPT_PARAM_ONOFF, true)
	Menu.VoliCombo:addSubMenu("Ultimate Settings", "Rset")
	Menu.VoliCombo.Rset:addParam("comboR", "Use R in Combo", SCRIPT_PARAM_ONOFF, true)
	Menu.VoliCombo.Rset:addParam("MinimumR", "Minimum enemies to ult", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	
	Menu:addSubMenu("["..myHero.charName.." - Additionals]", "Ads")
	Menu.Ads:addParam("ks", "Enable Killsteal", SCRIPT_PARAM_ONOFF, true)
	Menu.Ads:addParam("escape", "Escape key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))

	Menu:addSubMenu("["..myHero.charName.." - Drawings]", "drawings")
	Menu.drawings:addParam("drawCircleAA", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
	Menu.drawings:addParam("drawCircleQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	Menu.drawings:addParam("drawCircleW", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
	Menu.drawings:addParam("drawCircleE", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	
	UpdateWeb(true, ScriptName, id, HWID)
	
	-- Message
	PrintChat("<font color = \"#33CCCC\">Frozen Volibear by</font> <font color = \"#fff8e7\">Lillgoalie</font>")
end

function OnBugsplat()
	UpdateWeb(false, ScriptName, id, HWID)
end

function OnUnload()
	UpdateWeb(false, ScriptName, id, HWID)
end

function OnTick()
	if myHero.dead then return end
	-- Check for enemies repeatly
	ts:update()
	KillSteal()
	
	if GetGame().isOver then
		UpdateWeb(false, ScriptName, id, HWID)
		startUp = false;
	end

	-- VoliCombo key pressed?
	if (Menu.VoliCombo.combo) then
		-- Activate function VoliCombo
		Volicombo()
	end
end

function KillSteal()
	if player:GetSpellData(_W).level > 0 and Menu.Ads.ks and player:CanUseSpell(_W) == READY then

		for i=1, heroManager.iCount do
			local target = heroManager:GetHero(i)
			local baseHP = (472 + 92*player.level) * 1.03
			local biteDamage = player:CalcDamage(target, math.floor( (((player:GetSpellData(_W).level-1)*45) + 80 + (player.maxHealth - baseHP)*0.15) * (1 + (target.maxHealth - target.health)/(target.maxHealth))))

			if target ~= nil and target.visible == true and target.team ~= player.team and target.dead == false and player:GetDistance(target) < 400 and player:CanUseSpell(_W) == READY then
				if target.health < biteDamage then
					CastSpell(_W, target)
				end
			end
		end
	end
end

function Escape()
	if myHero:CanUseSpell(_Q) then
		CastSpell(_Q)
	end
	myHero:MoveTo(mousePos.x, mousePos.z)
end
			
function Volicombo()
	-- Can use spell, E in range and enabled?
	if ValidTarget(ts.target, ERange) and myHero:CanUseSpell(_E) == READY and Menu.VoliCombo.comboE then
		-- Cast E
		CastSpell(_E)
	end
	
	-- Can use spell and range and enabled?
	if ValidTarget(ts.target, QRange) and myHero:CanUseSpell(_Q) == READY and Menu.VoliCombo.comboQ then
		-- Cast Q
		CastSpell(_Q)
	end
	-- Can use spell and range and enabled?
	if ValidTarget(ts.target, RRange) and CountEnemyHeroInRange(400) >= Menu.VoliCombo.Rset.MinimumR and myHero:CanUseSpell(_R) == READY and Menu.VoliCombo.comboR then
		-- Cast R
		CastSpell(_R)
	end
	-- Can use spell and range and enabled?
	if ValidTarget(ts.target, WRange) and myHero:CanUseSpell(_W) == READY and Menu.VoliCombo.comboW then
		-- Cast W
		CastSpell(_W, ts.target)
	end
end

function OnDraw()
	if Menu.drawings.drawCircleAA then
		DrawCircle(myHero.x, myHero.y, myHero.z, RRange, ARGB(255, 0, 255, 0))
	end
	
	if Menu.drawings.drawCircleQ then
		DrawCircle(myHero.x, myHero.y, myHero.z, QRange, 0x111111)
	end
			
	if Menu.drawings.drawCircleW then
		DrawCircle(myHero.x, myHero.y, myHero.z, WRange, 0x111111)
	end		

	if Menu.drawings.drawCircleE then
		DrawCircle(myHero.x, myHero.y, myHero.z, ERange, 0x111111)
	end		
end