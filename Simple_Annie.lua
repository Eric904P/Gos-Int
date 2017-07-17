if GetObjectName(GetMyHero()) ~= "Annie" then return end	--Checks if our hero is named "Annie" and stops the scripts if that's not the case

require("Inspired")											--Loads the Inspired lib

require("MixLib")
require("OpenPredict")

--[[LOCAL VARS]]

local passive = 0
local Qrange, Wrange, Erange, Rrange, Irange = 625, 625, 0, 600, 600
local Wdata = {delay=0.25, range=625, radius=80, speed=math.huge, angle=50}
local Rdata = {delay=0.25, range=600, radius=150, speed=math.huge}
local ignite = nil

local myHero = GetMyHero()

local _INTERRUPTIBLE_SPELLS = {
    ["KatarinaR"]                          = { charName = "Katarina",     DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
    ["Meditate"]                           = { charName = "MasterYi",     DangerLevel = 1, MaxDuration = 2.5, CanMove = false },
    ["Drain"]                              = { charName = "FiddleSticks", DangerLevel = 3, MaxDuration = 2.5, CanMove = false },
    ["Crowstorm"]                          = { charName = "FiddleSticks", DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
    ["GalioIdolOfDurand"]                  = { charName = "Galio",        DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
    ["MissFortuneBulletTime"]              = { charName = "MissFortune",  DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
    ["VelkozR"]                            = { charName = "Velkoz",       DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
    ["InfiniteDuress"]                     = { charName = "Warwick",      DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
    ["AbsoluteZero"]                       = { charName = "Nunu",         DangerLevel = 4, MaxDuration = 2.5, CanMove = false },
    ["ShenStandUnited"]                    = { charName = "Shen",         DangerLevel = 3, MaxDuration = 2.5, CanMove = false },
    ["FallenOne"]                          = { charName = "Karthus",      DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
    ["AlZaharNetherGrasp"]                 = { charName = "Malzahar",     DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
    ["Pantheon_GrandSkyfall_Jump"]         = { charName = "Pantheon",     DangerLevel = 5, MaxDuration = 2.5, CanMove = false },

}

local _GAPCLOSER_SPELLS = {
    ["AatroxQ"]              = "Aatrox",
    ["AkaliShadowDance"]     = "Akali",
    ["Headbutt"]             = "Alistar",
    ["FioraQ"]               = "Fiora",
    ["DianaTeleport"]        = "Diana",
    ["EliseSpiderQCast"]     = "Elise",
    ["FizzPiercingStrike"]   = "Fizz",
    ["GragasE"]              = "Gragas",
    ["HecarimUlt"]           = "Hecarim",
    ["JarvanIVDragonStrike"] = "JarvanIV",
    ["IreliaGatotsu"]        = "Irelia",
    ["JaxLeapStrike"]        = "Jax",
    ["KhazixE"]              = "Khazix",
    ["khazixelong"]          = "Khazix",
    ["LeblancSlide"]         = "LeBlanc",
    ["LeblancSlideM"]        = "LeBlanc",
    ["BlindMonkQTwo"]        = "LeeSin",
    ["LeonaZenithBlade"]     = "Leona",
    ["UFSlash"]              = "Malphite",
    ["Pantheon_LeapBash"]    = "Pantheon",
    ["PoppyHeroicCharge"]    = "Poppy",
    ["RenektonSliceAndDice"] = "Renekton",
    ["RivenTriCleave"]       = "Riven",
    ["SejuaniArcticAssault"] = "Sejuani",
    ["slashCast"]            = "Tryndamere",
    ["ViQ"]                  = "Vi",
    ["MonkeyKingNimbus"]     = "MonkeyKing",
    ["XenZhaoSweep"]         = "XinZhao",
    ["YasuoDashWrapper"]     = "Yasuo"
}

--[[EVENT HANDLERS]]

OnUpdateBuff(function(unit,buff)
	if unit and buff and (unit == GetMyHero()) and (buff.name == "pyromania") then
		passive = buff.Stacks
	end
end)

OnRemoveBuff(function(unit,buff)
	if unit and buff and (unit == GetMyHero()) and (buff.name == "pyromania") then
		passive = 0
	end 
end)

OnSpellCast(function(unit,spell)
	if unit and spell and (unit == GetMyHero()) and (spell.name == "InfernalGuardian") and AnnieMenu.Misc.rblk.Value() then
		local spellPred = GetCircularAOEPrediction(spell.target, Rdata, spell.startPos)
		if (spellPred.hitChance <= 0.8) then 
			spell.BlockCast() 
		end
	end
end)

OnProcessSpell(function(unit,spell)
	--INTERRUPTER
	if unit and spell and spell.name and unit.visionPos and spell.endPos then 
		if not AnnieMenu.Misc.chnl.Value() then return end
		if unit.team ~= myHero.team then 
			if _INTERRUPTIBLE_SPELLS[spell.name] then
				castStunInterruptable(unit, spell)
			end
		end
	end

	--ANTI-GAPCLOSER
	if unit and spell and spell.name and unit.visionPos and spell.endPos then
		if not AnnieMenu.Misc.gap.Value() then return end
		if unit.team ~= myHero.team then
			if _GAPCLOSER_SPELLS[spell.name] then
				local Gapcloser = _GAPCLOSER_SPELLS[spell.name]
				local add = false
				if spell.target and spell.target.isMe then
					add = true
					startPos = Vector(unit.visionPos)
					endPos = myHero
				elseif not spell.target then
					local endPos1 = Vector(unit.visionPos) + 300 * (Vector(spell.endPos) - Vector(unit.visionPos)):normalized()
	                local endPos2 = Vector(unit.visionPos) + 100 * (Vector(spell.endPos) - Vector(unit.visionPos)):normalized()
	                if (GetDistanceSqr(myHero.visionPos, unit.visionPos) > GetDistanceSqr(myHero.visionPos, endPos1) or GetDistanceSqr(myHero.visionPos, unit.visionPos) > GetDistanceSqr(myHero.visionPos, endPos2))  then
	                    add = true
	                end
	            end

	            if add then 
	            	castStunGapClosing(unit, spell)
	            end
	        end
	    end
	end
end)


OnLoad(function(myHero)
	FindIgnite()
	DrawMenu()
	Say("LOADED! GLHF :)")
end)

OnDraw(function(myHero)
	DrawCircle(myHero.x, myHero.y, myHero.z, 625, 0x111111)
	for i, enemy in ipairs(GetEnemyHeroes()) do
		DrawIndicator(enemy)
	end
end)

--[[GAME DATA]]

OnTick(function (myHero)									--The code inside the Function runs every tick
		
	local target = GetCurrentTarget()					--Saves the "best" enemy champ to the target variable
	local manaPercent = 100*(GetCurrentMana(myHero)/GetMaxMana(myHero))
	local iDmg = (50 + (20 * myHero.level))

  	if AnnieMenu.Misc.Rforce:Value() and ValidTarget(target, Rrange) and IsReady(_R) then --force ult key
    	local RPred = GetCircularAOEPrediction(target, Rdata, GetOrigin(myHero))
    	if RPred.HitChance == 1 then
			CastSkillShot(_R, RPred.castPos)			--Cast ult at predicted position
		end	
    end


	if Mix:Mode() == "LastHit" then
		if AnnieMenu.Farm.Q.Value() and Ready(_Q) then --Auto Q farm
			
			local Qdmg = CalcDamage(myHero, enemy, 0, 45 + 35 * GetCastLevel(myHero,_Q) + GetBonusAP(myHero) * 0.8)

			for m, minion in pairs(minionManager.objects) do
				--if minion.team == MINION_ENEMY and ValidTarget(minion, Qrange) and Qdmg > Mix:HealthPredict(minion, _Q.windUpTime+GetDistance(minion)/_Q.castSpeed, "OW")
				if minion.team == MINION_ENEMY and ValidTarget(minion, Qrange) and Qdmg > GetCurrentHP(minion) then
					CastTargetSpell(_Q, minion)
				end
			end
		end
	end

	if Mix:Mode() == "Harass" then

		if AnnieMenu.Farm.Q.Value() and Ready(_Q) then --Auto Q farm
			
			local Qdmg = CalcDamage(myHero, enemy, 0, 45 + 35 * GetCastLevel(myHero,_Q) + GetBonusAP(myHero) * 0.8)

			for m, minion in pairs(minionManager.objects) do
				--if minion.team == MINION_ENEMY and ValidTarget(minion, Qrange) and Qdmg > Mix:HealthPredict(minion, _Q.windUpTime+GetDistance(minion)/_Q.castSpeed, "OW")
				if minion.team == MINION_ENEMY and ValidTarget(minion, Qrange) and Qdmg > GetCurrentHP(minion) then
					CastTargetSpell(_Q, minion)
				end
			end
		end

		if AnnieMenu.Harass.Q.Value() and Ready(_Q) and ValidTarget(target, Qrange) and manaPercent >= AnnieMenu.Harass.mana.Value() then
			CastTargetSpell(target, _Q)
		end

		if AnnieMenu.Harass.W.Value() and Ready(_W) and ValidTarget(target, Wrange) and manaPercent >= AnnieMenu.Harass.mana.Value() then
			local Wpredict = GetConicAOEPrediction(target, Wdata)
			CastSkillShot(_W, Wpredict.castPos)
		end

		if AnnieMenu.Harass.E.Value() and Ready(_E) and passive < 4 and manaPercent >= AnnieMenu.Harass.mana.Value() then 
			CastSpell(_E)
		end
	end

	if Mix:Mode() == "Combo" then						--Check if we are in Combo mode (holding space)
			
		if AnnieMenu.Misc.estk.Value() and Ready(_E) and passive < 4 then --e first to stack stun
			CastSpell(_E)
		end --end E logic
		
		if AnnieMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 625) then	
			CastTargetSpell(target , _Q)
		end		--end Q logic
	
		if AnnieMenu.Combo.W:Value() and Ready(_W) and ValidTarget(target, 625) then
			local Wpredict = GetConicAOEPrediction(target, Wdata)
			CastSkillShot(_W, Wpredict.castPos)
		end	--end W logic
		
		if AnnieMenu.Combo.R:Value() and Ready(_R) and ValidTarget(target, 600) then
			--[[Old predict function function:
				GetPredictionForPlayer(startPos, targetUnit, targetMovespeed, SpellSpeed, SpellDelay, SpellRange, SpellWidth, SpellCollision, additionalHitbox)
				EXPLANATION OF EACH PARAMETER:
				startPos = GetOrigin(myHero)	that's our current spot
				targetUnit = target				that's our current target
				targetMovespeed = GetMoveSpeed(target) current MS of the target
				SpellSpeed = math.huge because it doesn't have to travel, it just appears
				SpellDelay = 75 the time in ms that we need to cast the spell (new speed .25 used for OpenPredict)
				SpellRange = 600 the range of R (see wiki)
				SpellWidth = 150 = radius/2 (see wiki)
				SpellCollision = false because the ult doesn't stop if it hits a creep
			]]
			local RPred = GetCircularAOEPrediction(target, Rdata, GetOrigin(myHero))
			if RPred.HitChance == 1 and ReturnTargsHit(target) >= AnnieMenu.Combo.Rhit.Value() then		--Checks targets hit to match menu settings
				if AnnieMenu.Combo.Rstun.Value() and passive ~= 4 then goto Rskip end
				CastSkillShot(_R, RPred.castPos)			--Cast ult at predicted position
				::Rskip::
			end		--Ends CastR logic
		end	--Ends the R logic

		if AnnieMenu.Combo.ign.Value() == 2 and Ready(ignite) and ValidTarget(target, Irange) then
			CastTargetSpell(ignite, target)
		end

		if AnnieMenu.Combo.ign.Value() == 3 and Ready(ignite) and ValidTarget(target, Irange) and iDmg >= GetCurrentHP(target) then
			CastTargetSpell(ignite, target)
		end
	end		--Ends the Combo Mode

	if Mix:Mode() == "LaneClear" then

		if AnnieMenu.Farm.W.Value() and Ready(_W) and manaPercent >= AnnieMenu.Farm.mana.Value() then
			local bestMob = {object=nil, hit=1}
			for m, minion in pairs(minionManager, objects) do
				if ValidTarget(minion, Wrange) then
					local cnt = wHitCountMinion(minion)
					if cnt > bestMob.hit then 
						bestMob.Object = minion
						bestMob.hit = cnt
					end
				end
			end
			local wPred = GetConicAOEPrediction(bestMob.Object, Wdata)
			CastSkillShot(_W, wPred.castPos)
		end

		if AnnieMenu.Farm.Q.Value() and Ready(_Q) then --Auto Q farm
			
			local Qdmg = CalcDamage(myHero, enemy, 0, 45 + 35 * GetCastLevel(myHero,_Q) + GetBonusAP(myHero) * 0.8)

			for m, minion in pairs(minionManager.objects) do
				--if minion.team == MINION_ENEMY and ValidTarget(minion, Qrange) and Qdmg > Mix:HealthPredict(minion, _Q.windUpTime+GetDistance(minion)/_Q.castSpeed, "OW")
				if minion.team == MINION_ENEMY and ValidTarget(minion, Qrange) and Qdmg > GetCurrentHP(minion) then
					CastTargetSpell(_Q, minion)
				end
			end
		end
	end
	
end)		--End script

--[[FUNCTIONS]]
function DrawMenu()
	local AnnieMenu = Menu("Annie", "Annie")						--Create a New Menu and call it AnnieMenu (the user only sees "Annie")

	AnnieMenu:SubMenu("Combo", "Combo")							--Create a New SubMenu and call it Combo
	AnnieMenu.Combo:Boolean("Q", "Use Q", true)						--Add a button to toggle the usage of Q
	AnnieMenu.Combo:Boolean("W", "Use W", true)						--Add a button to toggle the usage of W
	AnnieMenu.Combo:Boolean("E", "Use E", true)
	AnnieMenu.Combo:Boolean("R", "Use R", true)						--Add a button to toggle the usage of R
	AnnieMenu.Combo:Boolean("Rstun", "Only R if it will stun", true)
	AnnieMenu.Combo:Slider("Rhit", "Only R if it will hit X enemy heroes", 2, 1, 5, 1)
	AnnieMenu.Combo:List("ign", "Ignite mode:", 3, {"OFF", "Combo", "Killsteal"})

	AnnieMenu:SubMenu("Harass", "Harass")
	AnnieMenu.Harass:Boolean("Q", "Use Q", true)
	AnnieMenu.Harass:Boolean("W", "Use W", true)
	AnnieMenu.Harass:Boolean("E", "Use E", true)
	AnnieMenu.Harass:Slider("mana", "Minimum mana %", 25, 0, 100, 1)

	AnnieMenu:SubMenu("Farm", "Farm")
	AnnieMenu.Farm:Boolean("Q", "Lasthit with Q", true)
	AnnieMenu.Farm:Boolean("W", "Waveclear with W", true)
	AnnieMenu.Farm:Slider("mana", "Minimum mana %", 25, 0, 100, 1)

	AnnieMenu:SubMenu("Misc", "Misc")
	AnnieMenu.Misc:KeyBinding("Rforce", "Force best R, ignoring Combo settings", string.byte("T"))
	AnnieMenu.Misc:Boolean("rblk", "Block manual R if it will not hit", true)
	AnnieMenu.Misc:Boolean("gap", "Use stun on gapclose", true)
	AnnieMenu.Misc:Boolean("chnl", "Use stun to interrup channel", true)
end

function ReturnBestUltTarget(amountOfTargets)
	local targ = nil
	local range = (575)

	for i, enemy in ipairs(GetEnemyHeroes()) do
		if GetDistance(enemy, myHero) <= range then
			local count = 1
			for i, Tenemy in ipairs(GetEnemyHeroes()) do
				if enemy ~= Tenemy then
					if GetDistance(Tenemy, enemy) < 150 then
						count = count + 1
					end 
				end 
			end

			if count >= amountOfTargets then
				targ = enemy
				break
			end
		end 
	end 
	return targ
end 

function ReturnTargsHit(target) --assumes target will hit
	local range = 575
	local count = 1

	for i, enemy in ipairs(GetEnemyHeroes()) do
		if enemy ~= target then
			if GetDistance(enemy, target) < 150 then
				count = count + 1
			end
		end
	end
	return count
end

function wHitCountMinion(target)
	local count = 1
	local Wpred = GetConicAOEPrediction(target, Wdata, GetOrigin(GetMyHero()))
	local T = Wpred:mCollision()

	for _ in pairs(T) do count = count + 1 end

	return count
end

function FindIgnite()
	ignite = myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") and SUMMONER_1 or myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") and SUMMONER_2
end

function castStunGapClosing(unit, spell)
	if GetDistance(unit) < 600 and passive == 4 then
		if Ready(_Q) and Ready(_W) then
			CastTargetSpell(_Q, unit)
		elseif Ready(_Q) then
			CastTargetSpell(_Q, unit)
		elseif Ready(_W) then
			local wPred = GetConicAOEPrediction(unit, Wdata)
			CastSkillShot(_W, wPred.castPos)
		end
	end 
end 

function castStunInterruptable(unit, spell) 
	if GetDistance(unit) < 600 and passive == 4 then
		if Ready(_Q) and Ready(_W) then
			CastTargetSpell(_Q, unit)
		elseif Ready(_Q) then
			CastTargetSpell(_Q, unit)
		elseif Ready(_W) then
			local wPred = GetConicAOEPrediction(unit, Wdata)
			CastSkillShot(_W, wPred.castPos)
		end
	end 
end 

function Say(text)
	print("<font color=\"#FF0000\"><b>Eric's Annie:</b></font> <font color=\"#FFFFFF\">" .. text .. "</font>")
end

function DrawIndicator(enemy)
	local Qdmg, Wdmg, Rdmg = CalcSpellDamage(enemy)

	Qdmg = ((Qready and Qdmg) or 0)
	Wdmg = ((Wready and Wdmg) or 0)
	Rdmg = ((Rready and Rdmg) or 0)

    local damage = Qdmg + Wdmg + Rdmg

    local SPos, EPos = GetEnemyHPBarPos(enemy)

    -- Validate data
    if not SPos then return end

    local barwidth = EPos.x - SPos.x
    local Position = SPos.x + math.max(0, (enemy.health - damage) / enemy.maxHealth) * barwidth

    DrawText("|", 16, math.floor(Position), math.floor(SPos.y + 8), ARGB(255,0,255,0))
    DrawText("HP: "..math.floor(enemy.health - damage), 12, math.floor(SPos.x + 25), math.floor(SPos.y - 15), (enemy.health - damage) > 0 and ARGB(255, 0, 255, 0) or  ARGB(255, 255, 0, 0))
end 
