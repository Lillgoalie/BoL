--[[

	Jungle Assist by Lillgoalie (champion version)
    Version: 0.1
    
    Instructions on saving the file:
    - Save the file in scripts folder
]]

require "MapPosition"

HWID = Base64Encode(tostring(os.getenv("PROCESSOR_IDENTIFIER")..os.getenv("USERNAME")..os.getenv("COMPUTERNAME")..os.getenv("PROCESSOR_LEVEL")..os.getenv("PROCESSOR_REVISION")))
id = 321
ScriptName = "JungleAssist"
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIDAAAAJQAAAAgAAIAfAIAAAQAAAAQKAAAAVXBkYXRlV2ViAAEAAAACAAAADAAAAAQAETUAAAAGAUAAQUEAAB2BAAFGgUAAh8FAAp0BgABdgQAAjAHBAgFCAQBBggEAnUEAAhsAAAAXwAOAjMHBAgECAgBAAgABgUICAMACgAEBgwIARsNCAEcDwwaAA4AAwUMDAAGEAwBdgwACgcMDABaCAwSdQYABF4ADgIzBwQIBAgQAQAIAAYFCAgDAAoABAYMCAEbDQgBHA8MGgAOAAMFDAwABhAMAXYMAAoHDAwAWggMEnUGAAYwBxQIBQgUAnQGBAQgAgokIwAGJCICBiIyBxQKdQQABHwCAABcAAAAECAAAAHJlcXVpcmUABAcAAABzb2NrZXQABAcAAABhc3NlcnQABAQAAAB0Y3AABAgAAABjb25uZWN0AAQQAAAAYm9sLXRyYWNrZXIuY29tAAMAAAAAAABUQAQFAAAAc2VuZAAEGAAAAEdFVCAvcmVzdC9uZXdwbGF5ZXI/aWQ9AAQHAAAAJmh3aWQ9AAQNAAAAJnNjcmlwdE5hbWU9AAQHAAAAc3RyaW5nAAQFAAAAZ3N1YgAEDQAAAFteMC05QS1aYS16XQAEAQAAAAAEJQAAACBIVFRQLzEuMA0KSG9zdDogYm9sLXRyYWNrZXIuY29tDQoNCgAEGwAAAEdFVCAvcmVzdC9kZWxldGVwbGF5ZXI/aWQ9AAQCAAAAcwAEBwAAAHN0YXR1cwAECAAAAHBhcnRpYWwABAgAAAByZWNlaXZlAAQDAAAAKmEABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQA1AAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAMAAAADAAAAAwAAAAMAAAAEAAAABAAAAAUAAAAFAAAABQAAAAYAAAAGAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAgAAAAHAAAABQAAAAgAAAAJAAAACQAAAAkAAAAKAAAACgAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAsAAAAMAAAACwAAAAkAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAGAAAAAgAAAGEAAAAAADUAAAACAAAAYgAAAAAANQAAAAIAAABjAAAAAAA1AAAAAgAAAGQAAAAAADUAAAADAAAAX2EAAwAAADUAAAADAAAAYWEABwAAADUAAAABAAAABQAAAF9FTlYAAQAAAAEAEAAAAEBvYmZ1c2NhdGVkLmx1YQADAAAADAAAAAIAAAAMAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))()


function OnLoad()
	-- Create the menu
	Menu = scriptConfig("Jungle Assist", "JABL")

	Menu:addSubMenu("["..myHero.charName.." - Gank Guidance]", "NotifyGanks")
	Menu.NotifyGanks:addParam("GNF", "Enable gank guidance", SCRIPT_PARAM_ONOFF, true)
	Menu.NotifyGanks:addParam("percenthp", "What % to notify to gank", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)

	mapPosition = MapPosition()
	
	UpdateWeb(true, ScriptName, id, HWID)

	-- Message
 	PrintChat("<font color = \"#33CCCC\">Jungle Assist by</font> <font color = \"#fff8e7\">Lillgoalie</font>")
end

function OnBugsplat()
	UpdateWeb(false, ScriptName, id, HWID)
end

function OnUnload()
	UpdateWeb(false, ScriptName, id, HWID)
end

function OnTick()
	if GetGame().isOver then
		UpdateWeb(false, ScriptName, id, HWID)
		startUp = false;
	end
end

function OnDraw()
	DrawLine(0, 525, 90, 525, 5, ARGB(255, 0, 255, 0))
	DrawLine(0, 595, 90, 595, 5, ARGB(255, 0, 255, 0))
	DrawLine(90, 523, 90, 598, 5, ARGB(255, 0, 255, 0))

	if Menu.NotifyGanks.GNF then
		local Enemies = GetEnemyHeroes()
 		for i, enemy in pairs(Enemies) do
 			if ValidTarget(enemy) and enemy.health < (enemy.maxHealth*(Menu.NotifyGanks.percenthp*0.01)) then
 				if mapPosition:onTopLane(enemy) then
					DrawText("Gank Top!", 18, 5, 530, 0xFFFF0000)
				end
			end

			if ValidTarget(enemy) and enemy.health < (enemy.maxHealth*(Menu.NotifyGanks.percenthp*0.01)) then
 				if mapPosition:onMidLane(enemy) then
					DrawText("Gank Mid!", 18, 5, 550, 0xFFFF0000)
				end
			end

			if ValidTarget(enemy) and enemy.health < (enemy.maxHealth*(Menu.NotifyGanks.percenthp*0.01)) then
 				if mapPosition:onBotLane(enemy) then
					DrawText("Gank Bot!", 18, 5, 570, 0xFFFF0000)
				end
			end
		end
	end
end