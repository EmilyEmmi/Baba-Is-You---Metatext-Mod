-- Removes line that changes name to "text"
function startblock(light_)
	local light = light_ or false
	diceblock()

	if (light == false) then
		generaldata5.values[AUTO_ON] = 0

		destroylevel_check = false
		destroylevel_style = ""

		if (featureindex["level"] ~= nil) then
			local auto_on = hasfeature_count("level","is","auto",1)

			if (auto_on ~= nil) then
				generaldata5.values[AUTO_ON] = auto_on
			end
		end
	end

	if (light == false) and (featureindex["level"] ~= nil) then
		MF_levelrotation(0)
		maprotation = 0
		for i,v in ipairs(featureindex["level"]) do
			local rule = v[1]
			local conds = v[2]

			if testcond(conds,1) then
				if (rule[1] == "level") and (rule[2] == "is") then
					if (rule[3] == "right") then
						maprotation = 90
						mapdir = 0
						MF_levelrotation(90)
					elseif (rule[3] == "up") then
						maprotation = 180
						mapdir = 1
						MF_levelrotation(180)
					elseif (rule[3] == "left") then
						maprotation = 270
						mapdir = 2
						MF_levelrotation(270)
					elseif (rule[3] == "down") then
						maprotation = 0
						mapdir = 3
						MF_levelrotation(0)
					end
				end
			end
		end
	end

	for i,unit in ipairs(units) do
		local name = unit.strings[UNITNAME]
		local unitid = unit.fixed
		local unitrules = {}

		--[[ Remove to support metatext
		if (unit.strings[UNITTYPE] == "text") then
			name = "text"
		end]]--

		if (featureindex[name] ~= nil) then
			for a,b in ipairs(featureindex[name]) do
				local conds = b[2]

				if testcond(conds,unitid) then
					table.insert(unitrules, b)
				end
			end

			--local isfollow = xthis(unitrules,name,"follow")
			local isfloat = isthis(unitrules,"float")
			local sleep = isthis(unitrules,"sleep")
			local ismake = xthis(unitrules,name,"make")

			--[[
			local isright = isthis(unitrules,"right")
			local isup = isthis(unitrules,"up")
			local isleft = isthis(unitrules,"left")
			local isdown = isthis(unitrules,"down")

			if (sleep == false) then
				if isright then
					updatedir(unit.fixed,0)
				end
				if isup then
					updatedir(unit.fixed,1)
				end
				if isleft then
					updatedir(unit.fixed,2)
				end
				if isdown then
					updatedir(unit.fixed,3)
				end
			end
			]]--

			if isfloat then
				unit.values[FLOAT] = 1
			end

			if sleep then
				if (unit.values[TILING] == 2) or (unit.values[TILING] == 3) then
					unit.values[VISUALDIR] = -1
					unit.direction = ((unit.values[DIR] * 8 + unit.values[VISUALDIR]) + 32) % 32
				end
			end
		end
	end

	effectblock()
end

-- Fixes MAKE, apparently it was broken before :/
function block(small_)
	local delthese = {}
	local doned = {}
	local unitsnow = #units
	local removalsound = 1
	local removalshort = ""

	local small = small_ or false

	local doremovalsound = false

	if (small == false) then
		if (generaldata2.values[ENDINGGOING] == 0) then
			local isdone = getunitswitheffect("done",false,delthese)

			for id,unit in ipairs(isdone) do
				table.insert(doned, unit)
			end

			if (#doned > 0) then
				setsoundname("turn",10)
			end
		end

		local ismore = getunitswitheffect("more",false,delthese)

		for id,unit in ipairs(ismore) do
			local x,y = unit.values[XPOS],unit.values[YPOS]
			local name = getname(unit)
			local doblocks = {}

			for i=1,4 do
				local drs = ndirs[i]
				ox = drs[1]
				oy = drs[2]

				local valid = true
				local obs = findobstacle(x+ox,y+oy)
				local tileid = (x+ox) + (y+oy) * roomsizex

				if (#obs > 0) then
					for a,b in ipairs(obs) do
						if (b == -1) then
							valid = false
						elseif (b ~= 0) and (b ~= -1) then
							local bunit = mmf.newObject(b)
							local obsname = getname(bunit)

							local obsstop = hasfeature(obsname,"is","stop",b,x+ox,y+oy)
							local obspush = hasfeature(obsname,"is","push",b,x+ox,y+oy)
							local obspull = hasfeature(obsname,"is","pull",b,x+ox,y+oy)

							if (obsstop ~= nil) or (obspush ~= nil) or (obspull ~= nil) or (obsname == name) then
								valid = false
								break
							end
						end
					end
				else
					local obsstop = hasfeature("empty","is","stop",2,x+ox,y+oy)
					local obspush = hasfeature("empty","is","push",2,x+ox,y+oy)
					local obspull = hasfeature("empty","is","pull",2,x+ox,y+oy)

					if (obsstop ~= nil) or (obspush ~= nil) or (obspull ~= nil) then
						valid = false
					end
				end

				if valid then
					local newunit = copy(unit.fixed,x+ox,y+oy)
				end
			end
		end
	end

	local isplay = getunitswithverb("play",delthese)

	for id,ugroup in ipairs(isplay) do
		local sound_freq = ugroup[1]
		local sound_units = ugroup[2]
		local sound_name = ugroup[3]

		if (#sound_units > 0) then
			local ptunes = play_data.tunes
			local pfreqs = play_data.freqs
			local multisample = false

			local tune = "beep"
			local freq = pfreqs[sound_freq] or 24000

			if (ptunes[sound_name] ~= nil) then
				if (type(ptunes[sound_name]) == "string") then
					tune = ptunes[sound_name]
				elseif (type(ptunes[sound_name]) == "table") then
					multisample = true
				end
			end

			if multisample then
				if (tonumber(string.sub(sound_freq, -1)) ~= nil) then
					local octave = math.min(math.max(tonumber(string.sub(sound_freq, -1)) - base_octave, 1), #ptunes[sound_name])
					local truefreq = string.sub(sound_freq, 1, #sound_freq-1)
					tune = ptunes[sound_name][octave]
					freq = pfreqs[truefreq]
				else
					tune = ptunes[sound_name][2]
				end
			end

			-- MF_alert(sound_name .. " played at " .. tostring(freq) .. " (" .. sound_freq .. ")")

			MF_playsound_freq(tune,freq)
			setsoundname("turn",11,nil)

			if (sound_name ~= "empty") then
				for a,unit in ipairs(sound_units) do
					local x,y = unit.values[XPOS],unit.values[YPOS]

					MF_particles("music",unit.values[XPOS],unit.values[YPOS],1,0,3,3,1)
				end
			end
		end
	end

	local issink = getunitswitheffect("sink",false,delthese)

	for id,unit in ipairs(issink) do
		local x,y = unit.values[XPOS],unit.values[YPOS]
		local tileid = x + y * roomsizex

		if (unitmap[tileid] ~= nil) then
			local water = findallhere(x,y)
			local sunk = false

			if (#water > 0) then
				for a,b in ipairs(water) do
					if floating(b,unit.fixed,x,y) then
						if (b ~= unit.fixed) then
							local dosink = true

							for c,d in ipairs(delthese) do
								if (d == unit.fixed) or (d == b) then
									dosink = false
								end
							end

							local safe1 = issafe(b)
							local safe2 = issafe(unit.fixed)

							if safe1 and safe2 then
								dosink = false
							end

							if dosink then
								generaldata.values[SHAKE] = 3

								if (safe1 == false) then
									table.insert(delthese, b)
								end

								local pmult,sound = checkeffecthistory("sink")
								removalshort = sound
								removalsound = 3
								local c1,c2 = getcolour(unit.fixed)
								MF_particles("destroy",x,y,15 * pmult,c1,c2,1,1)

								if (b ~= unit.fixed) and (safe2 == false) then
									sunk = true
								end
							end
						end
					end
				end
			end

			if sunk then
				table.insert(delthese, unit.fixed)
			end
		end
	end

	delthese,doremovalsound = handledels(delthese,doremovalsound)

	local isweak = getunitswitheffect("weak",false,delthese)

	for id,unit in ipairs(isweak) do
		if (issafe(unit.fixed) == false) and (unit.new == false) then
			local x,y = unit.values[XPOS],unit.values[YPOS]
			local stuff = findallhere(x,y)

			if (#stuff > 0) then
				for i,v in ipairs(stuff) do
					if floating(v,unit.fixed,x,y) then
						local vunit = mmf.newObject(v)
						local thistype = vunit.strings[UNITTYPE]
						if (v ~= unit.fixed) then
							local pmult,sound = checkeffecthistory("weak")
							MF_particles("destroy",x,y,5 * pmult,0,3,1,1)
							removalshort = sound
							removalsound = 1
							generaldata.values[SHAKE] = 4
							table.insert(delthese, unit.fixed)
							break
						end
					end
				end
			end
		end
	end

	delthese,doremovalsound = handledels(delthese,doremovalsound)

	local ismelt = getunitswitheffect("melt",false,delthese)

	for id,unit in ipairs(ismelt) do
		local hot = findfeature(nil,"is","hot")
		local x,y = unit.values[XPOS],unit.values[YPOS]

		if (hot ~= nil) then
			for a,b in ipairs(hot) do
				local lava = findtype(b,x,y,0)

				if (#lava > 0) and (issafe(unit.fixed) == false) then
					for c,d in ipairs(lava) do
						if floating(d,unit.fixed,x,y) then
							local pmult,sound = checkeffecthistory("hot")
							MF_particles("smoke",x,y,5 * pmult,0,1,1,1)
							generaldata.values[SHAKE] = 5
							removalshort = sound
							removalsound = 9
							table.insert(delthese, unit.fixed)
							break
						end
					end
				end
			end
		end
	end

	delthese,doremovalsound = handledels(delthese,doremovalsound)

	local isyou = getunitswitheffect("you",false,delthese)
	local isyou2 = getunitswitheffect("you2",false,delthese)
	local isyou3 = getunitswitheffect("3d",false,delthese)

	for i,v in ipairs(isyou2) do
		table.insert(isyou, v)
	end

	for i,v in ipairs(isyou3) do
		table.insert(isyou, v)
	end

	for id,unit in ipairs(isyou) do
		local x,y = unit.values[XPOS],unit.values[YPOS]
		local defeat = findfeature(nil,"is","defeat")

		if (defeat ~= nil) then
			for a,b in ipairs(defeat) do
				if (b[1] ~= "empty") then
					local skull = findtype(b,x,y,0)

					if (#skull > 0) and (issafe(unit.fixed) == false) then
						for c,d in ipairs(skull) do
							local doit = false

							if (d ~= unit.fixed) then
								if floating(d,unit.fixed,x,y) then
									local kunit = mmf.newObject(d)
									local kname = getname(kunit)

									local weakskull = hasfeature(kname,"is","weak",d)

									if (weakskull == nil) or ((weakskull ~= nil) and issafe(d)) then
										doit = true
									end
								end
							else
								doit = true
							end

							if doit then
								local pmult,sound = checkeffecthistory("defeat")
								MF_particles("destroy",x,y,5 * pmult,0,3,1,1)
								generaldata.values[SHAKE] = 5
								removalshort = sound
								removalsound = 1
								table.insert(delthese, unit.fixed)
							end
						end
					end
				end
			end
		end
	end

	delthese,doremovalsound = handledels(delthese,doremovalsound)

	local isshut = getunitswitheffect("shut",false,delthese)

	for id,unit in ipairs(isshut) do
		local open = findfeature(nil,"is","open")
		local x,y = unit.values[XPOS],unit.values[YPOS]

		if (open ~= nil) then
			for i,v in ipairs(open) do
				local key = findtype(v,x,y,0)

				if (#key > 0) then
					local doparts = false
					for a,b in ipairs(key) do
						if (b ~= 0) and floating(b,unit.fixed,x,y) then
							if (issafe(unit.fixed) == false) then
								generaldata.values[SHAKE] = 8
								table.insert(delthese, unit.fixed)
								doparts = true
								online = false
							end

							if (b ~= unit.fixed) and (issafe(b) == false) then
								table.insert(delthese, b)
								doparts = true
							end

							if doparts then
								local pmult,sound = checkeffecthistory("unlock")
								setsoundname("turn",7,sound)
								MF_particles("unlock",x,y,15 * pmult,2,4,1,1)
							end

							break
						end
					end
				end
			end
		end
	end

	delthese,doremovalsound = handledels(delthese,doremovalsound)

	local iseat = getunitswithverb("eat",delthese)
	local iseaten = {}

	for id,ugroup in ipairs(iseat) do
		local v = ugroup[1]

		if (ugroup[3] ~= "empty") then
			for a,unit in ipairs(ugroup[2]) do
				local x,y = unit.values[XPOS],unit.values[YPOS]
				local things = findtype({v,nil},x,y,unit.fixed)

				if (#things > 0) then
					for a,b in ipairs(things) do
						if (issafe(b) == false) and floating(b,unit.fixed,x,y) and (b ~= unit.fixed) and (iseaten[b] == nil) then
							generaldata.values[SHAKE] = 4
							table.insert(delthese, b)

							iseaten[b] = 1

							local pmult,sound = checkeffecthistory("eat")
							MF_particles("eat",x,y,5 * pmult,0,3,1,1)
							removalshort = sound
							removalsound = 1
						end
					end
				end
			end
		end
	end

	delthese,doremovalsound = handledels(delthese,doremovalsound)

	if (small == false) then
		local ismake = getunitswithverb("make",delthese)

		for id,ugroup in ipairs(ismake) do
			local v = ugroup[1]

			for a,unit in ipairs(ugroup[2]) do
				local x,y,dir,name = 0,0,4,""

				local leveldata = {}

				if (ugroup[3] ~= "empty") then
					x,y,dir = unit.values[XPOS],unit.values[YPOS],unit.values[DIR]
					name = getname(unit)
					leveldata = {unit.strings[U_LEVELFILE],unit.strings[U_LEVELNAME],unit.flags[MAPLEVEL],unit.values[VISUALLEVEL],unit.values[VISUALSTYLE],unit.values[COMPLETED],unit.strings[COLOUR],unit.strings[CLEARCOLOUR]}
				else
					x = math.floor(unit % roomsizex)
					y = math.floor(unit / roomsizex)
					name = "empty"
					dir = emptydir(x,y)
				end

				if (dir == 4) then
					dir = fixedrandom(0,3)
				end

				local exists = false

				if (v ~= "text") and (v ~= "all") then
					for b,mat in pairs(fullunitlist) do --This is the changed part.
						if (b == v) then
							exists = true
						end
					end
				else
					exists = true
				end

				if exists then
					local domake = true

					if (name ~= "empty") then
						local thingshere = findallhere(x,y)

						if (#thingshere > 0) then
							for a,b in ipairs(thingshere) do
								local thing = mmf.newObject(b)
								local thingname = thing.strings[UNITNAME]

								if (thing.flags[CONVERTED] == false) and ((thingname == v) or ((thing.strings[UNITTYPE] == "text") and (v == "text"))) then
									domake = false
								end
							end
						end
					end

					if domake then
						if (findnoun(v,nlist.short) == false) then
							create(v,x,y,dir,x,y,nil,nil,leveldata)
						elseif (v == "text") then
							if (name ~= "text") and (name ~= "all") then
								create("text_" .. name,x,y,dir,x,y,nil,nil,leveldata)
								updatecode = 1
							end
						elseif (string.sub(v, 1, 5) == "group") then
							local mem = findgroup(v)

							for c,d in ipairs(mem) do
								create(d,x,y,dir,x,y,nil,nil,leveldata)
							end
						end
					end
				end
			end
		end

		for i,unit in ipairs(doned) do
			addundo({"done",unit.strings[UNITNAME],unit.values[XPOS],unit.values[YPOS],unit.values[DIR],unit.values[ID],unit.fixed,unit.values[FLOAT]})
			updateundo = true

			unit.values[FLOAT] = 2
			unit.values[EFFECTCOUNT] = math.random(-10,10)
			unit.values[POSITIONING] = 7
			unit.flags[DEAD] = true

			delunit(unit.fixed)
		end
	end

	delthese,doremovalsound = handledels(delthese,doremovalsound)

	isyou = getunitswitheffect("you",false,delthese)
	isyou2 = getunitswitheffect("you2",false,delthese)
	isyou3 = getunitswitheffect("3d",false,delthese)

	for i,v in ipairs(isyou2) do
		table.insert(isyou, v)
	end

	for i,v in ipairs(isyou3) do
		table.insert(isyou, v)
	end

	for id,unit in ipairs(isyou) do
		if (unit.flags[DEAD] == false) and (delthese[unit.fixed] == nil) then
			local x,y = unit.values[XPOS],unit.values[YPOS]

			if (small == false) then
				local bonus = findfeature(nil,"is","bonus")

				if (bonus ~= nil) then
					for a,b in ipairs(bonus) do
						if (b[1] ~= "empty") then
							local flag = findtype(b,x,y,0)

							if (#flag > 0) then
								for c,d in ipairs(flag) do
									if floating(d,unit.fixed,x,y) then
										local pmult,sound = checkeffecthistory("bonus")
										MF_particles("bonus",x,y,10 * pmult,4,1,1,1)
										removalshort = sound
										removalsound = 2
										MF_playsound("bonus")
										MF_bonus(1)
										addundo({"bonus",1})
										generaldata.values[SHAKE] = 5
										table.insert(delthese, d)
									end
								end
							end
						end
					end
				end

				local ending = findfeature(nil,"is","end")

				if (ending ~= nil) then
					for a,b in ipairs(ending) do
						if (b[1] ~= "empty") then
							local flag = findtype(b,x,y,0)

							if (#flag > 0) then
								for c,d in ipairs(flag) do
									if floating(d,unit.fixed,x,y) and (generaldata.values[MODE] == 0) then
										if (generaldata.strings[WORLD] == generaldata.strings[BASEWORLD]) then
											MF_particles("unlock",x,y,10,1,4,1,1)
											MF_end(unit.fixed,d)
											break
										elseif (editor.values[INEDITOR] ~= 0) then
											local pmult = checkeffecthistory("win")

											MF_particles("win",x,y,10 * pmult,2,4,1,1)
											MF_end_single()
											MF_win()
											break
										else
											local pmult = checkeffecthistory("win")

											local mods_run = do_mod_hook("levelpack_end", {})

											if (mods_run == false) then
												MF_particles("win",x,y,10 * pmult,2,4,1,1)
												MF_end_single()
												MF_win()
												MF_credits(1)
											end
											break
										end
									end
								end
							end
						end
					end
				end
			end

			local win = findfeature(nil,"is","win")

			if (win ~= nil) then
				for a,b in ipairs(win) do
					if (b[1] ~= "empty") then
						local flag = findtype(b,x,y,0)
						if (#flag > 0) then
							for c,d in ipairs(flag) do
								if floating(d,unit.fixed,x,y) and (hasfeature(b[1],"is","done",d,x,y) == nil) and (hasfeature(b[1],"is","end",d,x,y) == nil) then
									local pmult = checkeffecthistory("win")

									MF_particles("win",x,y,10 * pmult,2,4,1,1)
									MF_win()
									break
								end
							end
						end
					end
				end
			end
		end
	end

	delthese,doremovalsound = handledels(delthese,doremovalsound)

	for i,unit in ipairs(units) do
		if (inbounds(unit.values[XPOS],unit.values[YPOS],1) == false) then
			--MF_alert("DELETED!!!")
			table.insert(delthese, unit.fixed)
		end
	end

	delthese,doremovalsound = handledels(delthese,doremovalsound)

	if (small == false) then
		local iscrash = getunitswitheffect("crash",false,delthese)

		if (#iscrash > 0) then
			HACK_INFINITY = 200
			destroylevel("infinity")
			return
		end
	end

	if doremovalsound then
		setsoundname("removal",removalsound,removalshort)
	end
end
