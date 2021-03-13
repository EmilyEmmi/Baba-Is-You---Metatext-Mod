-- Removes lines that change name to "text"
function startblock(light_)
	local light = light_ or false
	diceblock()

	if (light == false) then
		generaldata5.values[AUTO_ON] = 0

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

-- Fixes FOLLOW TEXT
function moveblock()
	local isshift = findallfeature(nil,"is","shift",true)
	local istele = findallfeature(nil,"is","tele",true)
	local isfollow = findfeature(nil,"follow",nil,true)

	local doned = {}

	if (isfollow ~= nil) then
		for h,j in ipairs(isfollow) do
			local allfollows = findall(j)

			if (#allfollows > 0) then
				for k,l in ipairs(allfollows) do
					if (issleep(l) == false) then
						local unit = mmf.newObject(l)
						local x,y,name,dir = unit.values[XPOS],unit.values[YPOS],unit.strings[UNITNAME],unit.values[DIR]
						local unitrules = {}
						local followedfound = false

						--[[ Remove to support metatext
						if (unit.strings[UNITTYPE] == "text") then
							name = "text"
						end]]--

						if (featureindex[name] ~= nil) then
							for a,b in ipairs(featureindex[name]) do
								local baserule = b[1]
								local conds = b[2]

								local verb = baserule[2]

								if (verb == "follow") then
									if testcond(conds,l) then
										table.insert(unitrules, b)
									end
								end
							end
						end

						local follow = xthis(unitrules,name,"follow")

						if (#follow > 0) and (unit.flags[DEAD] == false) then
							local distance = 9999
							local targetdir = -1
							local stophere = false
							local highesttarget = false
							local counterclockwise = false

							local priorityfollow = -1
							local priorityfollowdir = -1

							local highpriorityfollow = -1
							local highpriorityfollowdir = -1

							for i,v in ipairs(follow) do
								local these = findall({v})
								-- Add text units to list of followed units
								if v == "text" then
									local texts = {}
									for i,v in pairs(fullunitlist) do
										if (string.sub(i, 1, 5) == "text_") then
											for i,v in pairs(findall({i})) do
												table.insert(these,v)
											end
										end
									end
								end
								-- Add text units to list of followed units

								if (#these > 0) and (stophere == false) then
									for a,b in ipairs(these) do
										if (b ~= unit.fixed) and (stophere == false) then
											local funit = mmf.newObject(b)

											local fx,fy = funit.values[XPOS],funit.values[YPOS]

											local xdir = fx-x
											local ydir = fy-y
											local dist = math.abs(xdir) + math.abs(ydir)
											local fdir = -1

											if (math.abs(xdir) <= math.abs(ydir)) then
												if (ydir >= 0) then
													fdir = 3
												else
													fdir = 1
												end
											else
												if (xdir > 0) then
													fdir = 0
												else
													fdir = 2
												end
											end

											if (dist <= distance) and (dist > 0) then
												distance = dist
												targetdir = fdir

												--MF_alert(name .. ": suggested dir " .. tostring(targetdir))

												if (dist == 1) then
													if (unit.followed ~= funit.values[ID]) then
														local ndrs = ndirs[dir + 1]
														local ox,oy = ndrs[1],ndrs[2]

														priorityfollow = funit.values[ID]
														priorityfollowdir = targetdir

														if (x + ox == fx) and (y + oy == fy) then
															highpriorityfollow = funit.values[ID]
															highpriorityfollowdir = targetdir
															highesttarget = true
															--MF_alert(tostring(unit.fixed) .. " moves forward: " .. tostring(dir) .. ", " .. tostring(targetdir))
														elseif (highesttarget == false) then
															local turnl = (dir + 1 + 4) % 4
															local ndrsl = ndirs[turnl + 1]
															local oxl,oyl = ndrsl[1],ndrsl[2]

															if (x + oxl == fx) and (y + oyl == fy) then
																highpriorityfollow = funit.values[ID]
																highpriorityfollowdir = targetdir
																counterclockwise = true
																--MF_alert(tostring(unit.fixed) .. " turns left: " .. tostring(dir) .. ", " .. tostring(turnl) .. ", " .. tostring(targetdir))
															elseif (counterclockwise == false) then
																local turnr = (dir - 1 + 4) % 4
																local ndrsr = ndirs[turnr + 1]
																local oxr,oyr = ndrsr[1],ndrsr[2]

																if (x + oxr == fx) and (y + oyr == fy) then
																	highpriorityfollow = funit.values[ID]
																	highpriorityfollowdir = targetdir
																	--MF_alert(tostring(unit.fixed) .. " turns right: " .. tostring(dir) .. ", " .. tostring(turnr) .. ", " .. tostring(targetdir))
																end
															end
														end
													else
														followedfound = true
														stophere = true
														break
													end
												end
											end
										end
									end

									if stophere then
										break
									end
								end

								if stophere then
									break
								end
							end

							if (followedfound == false) then
								if (highpriorityfollow > -1) then
									addundo({"followed",unit.values[ID],unit.followed,highpriorityfollow},unit.fixed)
									unit.followed = highpriorityfollow
									targetdir = highpriorityfollowdir
									stophere = true
									followedfound = true
								elseif (priorityfollow > -1) then
									addundo({"followed",unit.values[ID],unit.followed,priorityfollow},unit.fixed)
									unit.followed = priorityfollow
									targetdir = priorityfollowdir
									stophere = true
									followedfound = true
								elseif (unit.followed > -1) then
									addundo({"followed",unit.values[ID],unit.followed,0},unit.fixed)
									unit.followed = -1
								end
							end

							if (targetdir >= 0) then
								--MF_alert(unit.strings[UNITNAME] .. " faces to " .. tostring(targetdir))
								updatedir(unit.fixed,targetdir)
							end
						end
					end
				end
			end
		end
	end

	local isback = findallfeature(nil,"is","back",true)

	for i,unitid in ipairs(isback) do
		local unit = mmf.newObject(unitid)

		local undooffset = #undobuffer - unit.back_init

		local undotargetid = undooffset * 2 + 1

		if (undotargetid <= #undobuffer) and (unit.back_init > 0) and (unit.flags[DEAD] == false) then
			local currentundo = undobuffer[undotargetid]

			particles("wonder",unit.values[XPOS],unit.values[YPOS],1,{3,0})

			updateundo = true

			if (currentundo ~= nil) then
				for a,line in ipairs(currentundo) do
					local style = line[1]

					if (style == "update") and (line[9] == unit.values[ID]) then
						local uid = line[9]

						if (paradox[uid] == nil) then
							local ux,uy = unit.values[XPOS],unit.values[YPOS]
							local oldx,oldy = line[6],line[7]
							local x,y,dir = line[3],line[4],line[5]

							local ox = x - oldx
							local oy = y - oldy

							--[[
							Enable this to make the Back effect relative to current position
							x = ux + ox
							y = uy + oy
							]]--

							--MF_alert(unit.strings[UNITNAME] .. " is being updated from " .. tostring(ux) .. ", " .. tostring(uy) .. ", offset " .. tostring(ox) .. ", " .. tostring(oy))

							if (ox ~= 0) or (oy ~= 0) then
								addaction(unitid,{"update",x,y,dir})
							else
								addaction(unitid,{"updatedir",dir})
							end
							updateundo = true

							if (objectdata[unitid] == nil) then
								objectdata[unitid] = {}
							end

							local odata = objectdata[unitid]

							odata.tele = 1
						else
							particles("hot",line[3],line[4],1,{1, 1})
							updateundo = true
						end
					elseif (style == "create") and (line[3] == unit.values[ID]) then
						local uid = line[4]

						--MF_alert(unit.strings[UNITNAME] .. " back: " .. tostring(uid) .. ", " .. tostring(line[3]))

						if (paradox[uid] == nil) then
							local name = unit.strings[UNITNAME]

							local delname = {}

							for b,bline in ipairs(currentundo) do
								--MF_alert(" -- " .. bline[1] .. ", " .. tostring(bline[6]))

								if (bline[1] == "remove") and (bline[6] == uid) then
									local x,y,dir,levelfile,levelname,vislevel,complete,visstyle,maplevel,colour,clearcolour,followed,back_init = bline[3],bline[4],bline[5],bline[8],bline[9],bline[10],bline[11],bline[12],bline[13],bline[14],bline[15],bline[16],bline[17]

									local newname = bline[2]

									local newunitname = ""
									local newunitid = 0

									local ux,uy = unit.values[XPOS],unit.values[YPOS]

									newunitname = unitreference[newname]
									newunitid = MF_emptycreate(newunitname,ux,uy)

									local newunit = mmf.newObject(newunitid)
									newunit.values[ONLINE] = 1
									newunit.values[XPOS] = ux
									newunit.values[YPOS] = uy
									newunit.values[DIR] = dir
									newunit.values[ID] = bline[6]
									newunit.flags[9] = true

									newunit.strings[U_LEVELFILE] = levelfile
									newunit.strings[U_LEVELNAME] = levelname
									newunit.flags[MAPLEVEL] = maplevel
									newunit.values[VISUALLEVEL] = vislevel
									newunit.values[VISUALSTYLE] = visstyle
									newunit.values[COMPLETED] = complete

									newunit.strings[COLOUR] = colour
									newunit.strings[CLEARCOLOUR] = clearcolour

									if (newunit.className == "level") then
										MF_setcolourfromstring(newunitid,colour)
									end

									addunit(newunitid,true)
									addunitmap(newunitid,x,y,newunit.strings[UNITNAME])
									dynamic(unitid)

									newunit.followed = followed
									newunit.back_init = back_init

									if (newunit.strings[UNITTYPE] == "text") then
										updatecode = 1
									end

									local undowordunits = currentundo.wordunits
									local undowordrelatedunits = currentundo.wordrelatedunits

									if (#undowordunits > 0) then
										for a,b in ipairs(undowordunits) do
											if (b == bline[6]) then
												updatecode = 1
											end
										end
									end

									local uname = getname(newunit)

									if (#undowordrelatedunits > 0) then
										for a,b in ipairs(undowordrelatedunits) do
											if (b == bline[6]) then
												updatecode = 1
											end
										end
									end

									table.insert(delname, {newunit.strings[UNITNAME], bline[6]})
								end
							end

							addundo({"remove",unit.strings[UNITNAME],unit.values[XPOS],unit.values[YPOS],unit.values[DIR],unit.values[ID],unit.values[ID],unit.strings[U_LEVELFILE],unit.strings[U_LEVELNAME],unit.values[VISUALLEVEL],unit.values[COMPLETED],unit.values[VISUALSTYLE],unit.flags[MAPLEVEL],unit.strings[COLOUR],unit.strings[CLEARCOLOUR],unit.followed,unit.back_init})

							for a,b in ipairs(delname) do
								MF_alert("added undo for " .. b[1] .. " with ID " .. tostring(b[2]))
								addundo({"create",b[1],b[2],b[2],"back"})
							end

							delunit(unitid)
							dynamic(unitid)
							MF_specialremove(unitid,2)
						end
					end
				end
			end
		end
	end

	doupdate()

	for i,unitid in ipairs(istele) do
		if (isgone(unitid) == false) then
			local unit = mmf.newObject(unitid)
			local name = getname(unit)
			local x,y = unit.values[XPOS],unit.values[YPOS]

			local targets = findallhere(x,y)
			local telethis = false
			local telethisx,telethisy = 0,0

			if (#targets > 0) then
				for i,v in ipairs(targets) do
					local vunit = mmf.newObject(v)
					local thistype = vunit.strings[UNITTYPE]
					local vname = getname(vunit)

					local targetvalid = isgone(v)
					local targetstill = hasfeature(vname,"is","still",v,x,y)
					-- Luultavasti ei väliä onko kohde tuhoutumassa?

					if (targetstill == nil) and floating(v,unitid,x,y) then
						local targetname = getname(vunit)
						if (objectdata[v] == nil) then
							objectdata[v] = {}
						end

						local odata = objectdata[v]

						if (odata.tele == nil) then
							if (targetname ~= name) and (v ~= unitid) then
								local teles = istele

								if (#teles > 1) then
									local teletargets = {}
									local targettele = 0

									for a,b in ipairs(teles) do
										local tele = mmf.newObject(b)
										local telename = getname(tele)

										if (b ~= unitid) and (telename == name) and (tele.flags[DEAD] == false) then
											table.insert(teletargets, b)
										end
									end

									if (#teletargets > 0) then
										local randomtarget = fixedrandom(1, #teletargets)
										targettele = teletargets[randomtarget]
										local limit = 0

										while (targettele == unitid) and (limit < 10) do
											randomtarget = fixedrandom(1, #teletargets)
											targettele = teletargets[randomtarget]
											limit = limit + 1
										end

										odata.tele = 1

										local tele = mmf.newObject(targettele)
										local tx,ty = tele.values[XPOS],tele.values[YPOS]
										local vx,vy = vunit.values[XPOS],vunit.values[YPOS]

										update(v,tx,ty)

										local pmult,sound = checkeffecthistory("tele")

										MF_particles("glow",vx,vy,5 * pmult,1,4,1,1)
										MF_particles("glow",tx,ty,5 * pmult,1,4,1,1)
										setsoundname("turn",6,sound)
									end
								end
							end
						end
					end
				end
			end
		end
	end

	for a,unitid in ipairs(isshift) do
		if (unitid ~= 2) and (unitid ~= 1) then
			local unit = mmf.newObject(unitid)
			local x,y,dir = unit.values[XPOS],unit.values[YPOS],unit.values[DIR]

			local things = findallhere(x,y,unitid)

			if (#things > 0) and (isgone(unitid) == false) then
				for e,f in ipairs(things) do
					if floating(unitid,f,x,y) and (issleep(unitid,x,y) == false) then
						local newunit = mmf.newObject(f)
						local name = newunit.strings[UNITNAME]

						if (newunit.flags[DEAD] == false) then
							addundo({"update",name,x,y,newunit.values[DIR],x,y,unit.values[DIR],newunit.values[ID]})
							newunit.values[DIR] = unit.values[DIR]
						end
					end
				end
			end
		end
	end

	doupdate()
end
