--[[

	Jungle Assist by Lillgoalie (champion version)
    Version: 0.1
    
    Instructions on saving the file:
    - Save the file in scripts folder
]]

require "MapPosition"

function OnLoad()
	-- Create the menu
	Menu = scriptConfig("Jungle Assist", "JABL")

	Menu:addSubMenu("["..myHero.charName.." - Gank Guidance]", "NotifyGanks")
	Menu.NotifyGanks:addParam("GNF", "Enable gank guidance", SCRIPT_PARAM_ONOFF, true)
	Menu.NotifyGanks:addParam("percenthp", "What % to notify to gank", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)

	mapPosition = MapPosition()

	-- Message
 	PrintChat("<font color = \"#33CCCC\">Jungle Assist by</font> <font color = \"#fff8e7\">Lillgoalie</font>")
end

function OnTick()
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