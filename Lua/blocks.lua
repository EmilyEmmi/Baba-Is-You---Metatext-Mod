function effectblock()
	local levelhide = nil

	if (featureindex["level"] ~= nil) then
		levelhide = hasfeature("level","is","hide",1)

		local isred = hasfeature("level","is","red",1)
		local isblue = hasfeature("level","is","blue",1)
		local isgreen = hasfeature("level","is","green",1)
		local islime = hasfeature("level","is","lime",1)
		local isyellow = hasfeature("level","is","yellow",1)
		local ispurple = hasfeature("level","is","purple",1)
		local ispink = hasfeature("level","is","pink",1)
		local isrosy = hasfeature("level","is","rosy",1)
		local isblack = hasfeature("level","is","black",1)
		local isgrey = hasfeature("level","is","grey",1)
		local issilver = hasfeature("level","is","silver",1)
		local iswhite = hasfeature("level","is","white",1)
		local isbrown = hasfeature("level","is","brown",1)
		local isorange = hasfeature("level","is","orange",1)
		local iscyan = hasfeature("level","is","cyan",1)

		local colours = {isred, isorange, isyellow, islime, isgreen, iscyan, isblue, ispurple, ispink, isrosy, isblack, isgrey, issilver, iswhite, isbrown}
		local ccolours = {{2,2},{2,3},{2,4},{5,3},{5,2},{1,4},{3,2},{3,1},{4,1},{4,2},{0,4},{0,1},{0,2},{0,3},{6,1}}

		leveldata.colours = {}
		local c1,c2 = -1,-1

		for a=1,#ccolours do
			if (colours[a] ~= nil) then
				local c = ccolours[a]

				if (#leveldata.colours == 0) then
					c1 = c[1]
					c2 = c[2]
				end

				table.insert(leveldata.colours, {c[1],c[2]})
			end
		end

		if (#leveldata.colours == 1) then
			if (c1 > -1) and (c2 > -1) then
				if (c1 == 0) and (c2 == 4) then
					MF_backcolour(c1, c2)
				else
					MF_backcolour_dim(c1, c2)
				end
			end
		elseif (#leveldata.colours == 0) then
			MF_backcolour(0, 4)
		end
	else
		MF_backcolour(0, 4)
	end

	local resetcolour = {}
	local updatecolour = {}

	for i,unit in ipairs(units) do
		unit.new = false

		if (levelhide == nil) then
			unit.visible = true
		else
			unit.visible = false
		end

		if (unit.className ~= "level") then
			local name = getname(unit)
			local isred = hasfeature(name,"is","red",unit.fixed)
			local isblue = hasfeature(name,"is","blue",unit.fixed)
			local islime = hasfeature(name,"is","lime",unit.fixed)
			local isgreen = hasfeature(name,"is","green",unit.fixed)
			local isyellow = hasfeature(name,"is","yellow",unit.fixed)
			local ispurple = hasfeature(name,"is","purple",unit.fixed)
			local ispink = hasfeature(name,"is","pink",unit.fixed)
			local isrosy = hasfeature(name,"is","rosy",unit.fixed)
			local isblack = hasfeature(name,"is","black",unit.fixed)
			local isgrey = hasfeature(name,"is","grey",unit.fixed)
			local issilver = hasfeature(name,"is","silver",unit.fixed)
			local iswhite = hasfeature(name,"is","white",unit.fixed)
			local isbrown = hasfeature(name,"is","brown",unit.fixed)
			local isorange = hasfeature(name,"is","orange",unit.fixed)
			local iscyan = hasfeature(name,"is","cyan",unit.fixed)

			unit.colours = {}

			local colours = {isred, isorange, isyellow, islime, isgreen, iscyan, isblue, ispurple, ispink, isrosy, isblack, isgrey, issilver, iswhite, isbrown}
			local ccolours = {{2,2},{2,3},{2,4},{5,3},{5,2},{1,4},{3,2},{3,1},{4,1},{4,2},{0,4},{0,1},{0,2},{0,3},{6,1}}

			local c1,c2,ca = -1,-1,-1

			for a=1,#ccolours do
				if (colours[a] ~= nil) then
					local c = ccolours[a]

					if (#unit.colours == 0) then
						c1 = c[1]
						c2 = c[2]
						ca = a
					end

					table.insert(unit.colours, c)
				end
			end

			if (#unit.colours == 1) then
				if (c1 > -1) and (c2 > -1) and (ca > 0) then
					MF_setcolour(unit.fixed,c1,c2)
					unit.values[A] = ca
				end
			elseif (#unit.colours == 0) then
				if (unit.values[A] > 0) and (math.floor(unit.values[A]) == unit.values[A]) then
					if (unit.strings[UNITTYPE] ~= "text") or (unit.active == false) then
						setcolour(unit.fixed)
					else
						setcolour(unit.fixed,"active")
					end
					unit.values[A] = 0
				end
			else
				unit.values[A] = ca
			end
		end
	end

	if (levelhide == nil) then
		local ishide = findallfeature(nil,"is","hide",true)

		for i,unitid in ipairs(ishide) do
			local unit = mmf.newObject(unitid)

			unit.visible = false
		end
	end
end

function statusblock(ids,undoing_,noturn_)
	local checkthese = {}
	local undoing = undoing_ or false
	local noturn = noturn_ or false

	--MF_alert("Statusblock called")

	generaldata5.values[AUTO_ON] = 0

	if (featureindex["level"] ~= nil) then
		local auto_on = hasfeature_count("level","is","auto",1)

		if (auto_on ~= nil) then
			generaldata5.values[AUTO_ON] = auto_on
		end
	end

	if (ids == nil) then
		for k,unit in ipairs(units) do
			table.insert(checkthese, unit)
		end
	else
		for i,v in ipairs(ids) do
			local vunit = mmf.newObject(v)
			table.insert(checkthese, vunit)
		end
	end

	for i,unit in pairs(checkthese) do
		local name = getname(unit)

		if (undoing == false) then
			local realbroken = unit.broken
			unit.broken = 0
			local broken = hasfeature(name,"is","broken",unit.fixed)
			unit.broken = realbroken

			if (broken ~= nil) and (unit.broken == 0) then
				unit.broken = 1
				addundo({"broken",1,unit.values[ID]})
			elseif (broken == nil) and (unit.broken == 1) then
				unit.broken = 0
				addundo({"broken",0,unit.values[ID]})
			end

			local ur = hasfeature_count(name,"is","right",unit.fixed)
			local uu = hasfeature_count(name,"is","up",unit.fixed)
			local ul = hasfeature_count(name,"is","left",unit.fixed)
			local ud = hasfeature_count(name,"is","down",unit.fixed)

			local turn = {}
			local deturn = {}

			if (featureindex["turn"] ~= nil) then
				for a,b in ipairs(featureindex["turn"]) do
					local rule = b[1]
					local conds = b[2]

					if (rule[1] == name) and (rule[2] == "is") and (rule[3] == "turn") then
						table.insert(turn, {rule[2], conds})
					end
				end
			end

			if (featureindex["deturn"] ~= nil) then
				for a,b in ipairs(featureindex["deturn"]) do
					local rule = b[1]
					local conds = b[2]

					if (rule[1] == name) and (rule[2] == "is") and (rule[3] == "deturn") then
						table.insert(deturn, {rule[2], conds})
					end
				end
			end

			if (issleep(unit.fixed) == false) then
				local currdir = unit.values[DIR]
				local fdir = currdir

				if (noturn == false) and ((ur > 0) or (uu > 0) or (ul > 0) or (ud > 0)) then
					if (ur > uu) and (ur > ul) and (ur > ud) then
						fdir = 0
					elseif (uu > ur) and (uu > ul) and (uu > ud) then
						fdir = 1
					elseif (ul > ur) and (ul > uu) and (ul > ud) then
						fdir = 2
					elseif (ud > ur) and (ud > ul) and (ud > uu) then
						fdir = 3
					elseif (currdir == 3) then
						if (ul > 0) and (ul >= uu) and (ul >= ur) then
							fdir = 2
						elseif (uu > 0) and (uu > ul) and (uu >= ur) then
							fdir = 1
						elseif (ur > 0) and (ur > ul) and (ur > uu) then
							fdir = 0
						end
					elseif (currdir == 2) then
						if (uu > 0) and (uu >= ur) and (uu >= ul) then
							fdir = 1
						elseif (ur > 0) and (ur > uu) and (ur >= ud) then
							fdir = 0
						elseif (ud > 0) and (ud > ur) and (ud > uu) then
							fdir = 3
						end
					elseif (currdir == 1) then
						if (ur > 0) and (ur >= ul) and (ur >= ud) then
							fdir = 0
						elseif (ud > 0) and (ud > ur) and (ud >= ul) then
							fdir = 3
						elseif (ul > 0) and (ul > ur) and (ul > ud) then
							fdir = 2
						end
					elseif (currdir == 0) then
						if (ud > 0) and (ud >= ul) and (ud >= uu) then
							fdir = 3
						elseif (ul > 0) and (ul > ud) and (ul >= uu) then
							fdir = 2
						elseif (uu > 0) and (uu > ud) and (uu > ul) then
							fdir = 1
						end
					end

					--MF_alert(tostring(currdir) .. ", " .. tostring(fdir))

					if (fdir ~= currdir) then
						updatedir(unit.fixed,fdir)
						currdir = fdir
					end
				end

				if ((turn ~= nil) or (deturn ~= nil)) and (undoing == false) and (noturn == false) then
					local x,y = unit.values[XPOS],unit.values[YPOS]
					local turns = 0
					local deturns = 0

					if (turn ~= nil) then
						for a,b in ipairs(turn) do
							if testcond(b[2],unit.fixed,x,y) then
								turns = turns + 1
							end
						end
					end

					if (deturn ~= nil) then
						for a,b in ipairs(deturn) do
							if testcond(b[2],unit.fixed,x,y) then
								deturns = deturns + 1
							end
						end
					end

					if (turns >= deturns) then
						turns = turns - deturns
						deturns = 0
					end

					if (deturns >= turns) then
						deturns = deturns - turns
						turns = 0
					end

					if (turns > 0) then
						for d=1,turns do
							currdir = ((currdir + 4) - 1) % 4
						end

						updatedir(unit.fixed,currdir)
					end

					if (deturns > 0) then
						for d=1,deturns do
							currdir = ((currdir + 4) + 1) % 4
						end

						updatedir(unit.fixed,currdir)
					end
				end
			end

			if (generaldata.values[MODE] == 0) then
				if (featureindex["back"] ~= nil) then
					local isback = hasfeature(name,"is","back",unit.fixed)

					if (isback == nil) and (unit.back_init ~= 0) then
						addundo({"backset",name,unit.values[ID],unit.back_init})
						unit.back_init = 0
					end

					if (isback ~= nil) and (unit.back_init == 0) then
						addundo({"backset",name,unit.values[ID],0})
						unit.back_init = #undobuffer + 1
					end
				elseif (unit.back_init ~= 0) then
					addundo({"backset",name,unit.values[ID],unit.back_init})
					unit.back_init = 0
				end
			end
		end


		local oldfloat = unit.values[FLOAT]
		local newfloat = 0
		if (unit.values[FLOAT] < 2) and (generaldata.values[MODE] == 0) then
			unit.values[FLOAT] = 0
		end

		local isfloat = hasfeature(name,"is","float",unit.fixed)

		if (isfloat ~= nil) and (generaldata.values[MODE] == 0) then
			unit.values[FLOAT] = 1
			newfloat = 1
		end

		if (undoing == false) then
			if (oldfloat ~= newfloat) and (generaldata.values[MODE] == 0) and (generaldata2.values[ENDINGGOING] == 0) then
				addaction(unit.fixed,{"dofloat",oldfloat,newfloat,unit.values[ID],unit.fixed,name})
			end
		end
	end
end

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

						if (unit.strings[UNITTYPE] == "text") then
							--name = "text"
						end

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
									local undogroupunits = currentundo.groupunits
									local undowordrelatedunits = currentundo.wordrelatedunits

									if (#undowordunits > 0) then
										for a,b in ipairs(undowordunits) do
											if (b == bline[6]) then
												updatecode = 1
											end
										end
									end

									local uname = getname(newunit)

									if (#undogroupunits > 0) then
										for a,b in pairs(undogroupunits) do
											--MF_alert("Check " .. tostring(b) .. ", " .. tostring(line[6]))
											if (b == uname) then
												updatecode = 1
											end
										end
									end

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

					if (targetstill == nil) and floating(v,unitid) then
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
					if floating(unitid,f) and (issleep(unitid,x,y) == false) then
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

function fallblock()
	local checks = {}

	local isfall = findallfeature(nil,"is","fall",true)
	local isfall_r = findallfeature(nil,"is","fallright",true)
	local isfall_u = findallfeature(nil,"is","fallup",true)
	local isfall_l = findallfeature(nil,"is","fallleft",true)

	local flist = {}
	flist.down = {}
	flist.right = {}
	flist.up = {}
	flist.left = {}

	local fd,fr,fu,fl = flist.down,flist.right,flist.up,flist.left

	for a,unitid in ipairs(isfall) do
		table.insert(checks, {unitid, 3})

		if (fd[unitid] == nil) then
			fd[unitid] = 1
		else
			fd[unitid] = fd[unitid] + 1
		end
	end

	for a,unitid in ipairs(isfall_r) do
		table.insert(checks, {unitid, 0})

		if (fr[unitid] == nil) then
			fr[unitid] = 1
		else
			fr[unitid] = fr[unitid] + 1
		end
	end

	for a,unitid in ipairs(isfall_u) do
		table.insert(checks, {unitid, 1})

		if (fu[unitid] == nil) then
			fu[unitid] = 1
		else
			fu[unitid] = fu[unitid] + 1
		end

		if (fd[unitid] ~= nil) and (fd[unitid] > 0)and (fu[unitid] > 0) then
			fd[unitid] = fd[unitid] - 1
			fu[unitid] = fu[unitid] - 1
		end
	end

	for a,unitid in ipairs(isfall_l) do
		table.insert(checks, {unitid, 2})

		if (fl[unitid] == nil) then
			fl[unitid] = 1
		else
			fl[unitid] = fl[unitid] + 1
		end

		if (fr[unitid] ~= nil) and (fr[unitid] > 0)and (fl[unitid] > 0) then
			fr[unitid] = fr[unitid] - 1
			fl[unitid] = fl[unitid] - 1
		end
	end

	local done = false
	local objdatalist = {}

	local limiter = 0
	local limit = 1000

	while (done == false) and (limiter < limit) do
		local settled = true

		if (#checks > 0) then
			for a,data in pairs(checks) do
				local unitid = data[1]
				local falldir = data[2]

				if (objectdata[unitid] == nil) then
					objectdata[unitid] = {}
				end

				local drs = ndirs[falldir + 1]
				local ox,oy = drs[1],drs[2]

				local unit = mmf.newObject(unitid)
				local x,y,dir = unit.values[XPOS],unit.values[YPOS],unit.values[DIR]
				local name = getname(unit)
				local onground = false

				local valid = false

				local flistnames = {"right", "up", "left", "down"}
				local flist_ = flist[flistnames[falldir + 1]]

				if (flist_[unitid] ~= nil) and (flist_[unitid] > 0) then
					valid = true
				end

				local odata = objectdata[unitid]
				if (odata.fallen ~= nil) and (odata.fallen ~= falldir) then
					valid = false
					onground = true
				end

				if (odata.fallen == nil) then
					table.insert(objdatalist, {unitid, falldir})
				end

				if unit.flags[DEAD] or canmove(name,unitid,falldir,x,y) then
					valid = false
				end

				if valid then
					while (onground == false) and (limiter < limit) do
						local below,below_,specials = check(unitid,x,y,falldir,false,"fall")
						local deletethese = {}

						local result = 0
						for c,d in pairs(below) do
							if (d ~= 0) then
								result = 1
							else
								if (below_[c] ~= 0) and (result ~= 1) then
									if (result ~= 0) then
										result = 2
									else
										for e,f in ipairs(specials) do
											if (f[1] == below_[c]) then
												result = 2
											end

											if (f[2] == "weak") then
												table.insert(deletethese, f[1])
											end
										end
									end
								end
							end
							--MF_alert(tostring(y) .. " -- " .. tostring(d) .. " (" .. tostring(below_[c]) .. ")")
						end

						--MF_alert(tostring(y) .. " -- result: " .. tostring(result))

						if (result ~= 1) then
							local gone = false

							if (result == 0) then
								update(unitid,x + ox,y + oy)
							elseif (result == 2) then
								gone = move(unitid,ox,oy,dir,specials,true,true,x,y)
							end

							-- Poista tästä kommenttimerkit jos haluat, että fall tsekkaa juttuja per pudottu tile
							if (gone == false) then
								x = x + ox
								y = y + oy
								settled = false

								for a,b in ipairs(deletethese) do
									delete(b,x,y)

									local pmult,sound = checkeffecthistory("weak")
									setsoundname("removal",1,sound)
									generaldata.values[SHAKE] = 3
									MF_particles("destroy",x,y,5 * pmult,0,3,1,1)
								end

								if unit.flags[DEAD] then
									onground = true
									settled = true
									table.remove(checks, a)
								else
									update(unitid,x,y)
									--[[
									local stillgoing = hasfeature(name,"is","fall",unitid,x,y)
									if (stillgoing == nil) then
										onground = true
										table.remove(checks, a)
									end
									]]--
								end
							else
								onground = true
							end
						else
							onground = true
						end

						limiter = limiter + 1
					end
				else
					onground = true
				end
			end

			if settled then
				done = true
			end
		else
			done = true
		end
	end

	if (limiter >= limit) then
		HACK_INFINITY = 200
		destroylevel("infinity")
		return
	end

	for i,v in ipairs(objdatalist) do
		local unitid = v[1]
		local falldir = v[2]

		if (objectdata[unitid] == nil) then
			objectdata[unitid] = {}
		end

		local odata = objectdata[unitid]

		if (odata.fallen == nil) then
			odata.fallen = falldir
		end
	end
end

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

			--MF_alert(sound_name .. " played at " .. tostring(freq) .. " (" .. sound_freq .. ")")

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
					if floating(b,unit.fixed) then
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
					if floating(v,unit.fixed) then
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
						if floating(d,unit.fixed) then
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

	for i,v in ipairs(isyou2) do
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
								if floating(d,unit.fixed) then
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
						if (b ~= 0) and floating(b,unit.fixed) then
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
						if (issafe(b) == false) and floating(b,unit.fixed) and (b ~= unit.fixed) and (iseaten[b] == nil) then
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
					for b,mat in pairs(objectlist) do
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
						if (v ~= "empty") and (v ~= "all") and (v ~= "text") and (v ~= "group") then
							create(v,x,y,dir,x,y,nil,nil,leveldata)
						elseif (v == "text") then
							if (name ~= "text") and (name ~= "all") then
								create("text_" .. name,x,y,dir,x,y,nil,nil,leveldata)
								updatecode = 1
							end
						end
					end
				end
			end
		end

		for i,unit in ipairs(doned) do
			addundo({"done",unit.strings[UNITNAME],unit.values[XPOS],unit.values[YPOS],unit.values[DIR],unit.values[ID],unit.fixed,unit.values[FLOAT]})

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

	for i,v in ipairs(isyou2) do
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
									if floating(d,unit.fixed) then
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
									if floating(d,unit.fixed) and (generaldata.values[MODE] == 0) then
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
								if floating(d,unit.fixed) and (hasfeature(b[1],"is","done",d,x,y) == nil) and (hasfeature(b[1],"is","end",d,x,y) == nil) then
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

function handledels(delthese,doremovalsound)
	local result = doremovalsound or false

	for i,uid in pairs(delthese) do
		result = true

		if (deleted[uid] == nil) then
			delete(uid)
			deleted[uid] = 1
		end
	end

	return {},result
end

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

		if (unit.strings[UNITTYPE] == "text") then
			--name = "text"
		end

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

function levelblock()
	local unlocked = false
	local things = {}
	local donethings = {}

	local emptythings = {}

	if (featureindex["level"] ~= nil) then
		for i,v in ipairs(featureindex["level"]) do
			table.insert(things, v)
		end
	end

	if (featureindex["empty"] ~= nil) then
		for i,v in ipairs(featureindex["empty"]) do
			local rule = v[1]

			if (rule[1] == "empty") and ((rule[2] == "is") or (rule[2] == "eat")) then
				table.insert(emptythings, v)
			end
		end
	end

	local lstill = isstill_or_locked(1,nil,nil,mapdir)
	local lsleep = issleep(1)
	local lsafe = issafe(1)
	local emptybonus = false
	local emptydone = false

	if (#emptythings > 0) then
		for i=1,roomsizex-2 do
			for j=1,roomsizey-2 do
				local tileid = i + j * roomsizex

				if (unitmap[tileid] == nil) or (#unitmap[tileid] == 0) then
					local esafe = issafe(2,i,j)

					--MF_alert(tostring(i) .. ", " .. tostring(j))
					local keypair = ""
					local winpair = ""
					local hotpair = ""
					local defeatpair = ""
					local bonuspair = ""
					local endpair = ""

					local canmelt = false
					local candefeat = false
					local canwin = false
					local canbonus = false
					local canend = false

					local unlock = false
					local victory = false
					local melt = false
					local defeat = false
					local bonus = false
					local ending = false

					for a,rules in ipairs(emptythings) do
						local rule = rules[1]
						local conds = rules[2]

						if (rule[2] == "is") then
							if (rule[3] == "open") and testcond(conds,2,i,j) then
								if (string.len(keypair) == 0) then
									keypair = "shut"
								elseif (keypair == "open") then
									unlock = true
								end
							elseif (rule[3] == "shut") and testcond(conds,2,i,j) then
								if (string.len(keypair) == 0) then
									keypair = "open"
								elseif (keypair == "shut") then
									unlock = true
								end
							end

							if (rule[3] == "melt") and testcond(conds,2,i,j) then
								canmelt = true

								if (string.len(hotpair) == 0) then
									hotpair = "hot"
								elseif (hotpair == "melt") then
									melt = true
								end
							elseif (rule[3] == "hot") and testcond(conds,2,i,j) then
								if (string.len(hotpair) == 0) then
									hotpair = "melt"
								elseif (hotpair == "hot") then
									melt = true
								end
							end

							if (rule[3] == "defeat") and testcond(conds,2,i,j) then
								if (string.len(defeatpair) == 0) then
									defeatpair = "you"
								elseif (defeatpair == "defeat") then
									defeat = true
								end
							elseif ((rule[3] == "you") or (rule[3] == "you2")) and testcond(conds,2,i,j) then
								candefeat = true
								canwin = true

								if (string.len(defeatpair) == 0) then
									defeatpair = "defeat"
								elseif (defeatpair == "you") then
									defeat = true
								end
							end

							if (rule[3] == "win") and testcond(conds,2,i,j) then
								if (string.len(winpair) == 0) then
									winpair = "you"
								elseif (winpair == "win") then
									victory = true
								end
							elseif ((rule[3] == "you") or (rule[3] == "you2")) and testcond(conds,2,i,j) then
								candefeat = true
								canwin = true

								if (string.len(winpair) == 0) then
									winpair = "win"
								elseif (winpair == "you") then
									victory = true
								end
							end

							if (rule[3] == "bonus") and testcond(conds,2,i,j) then
								if (string.len(bonuspair) == 0) then
									bonuspair = "you"
								elseif (bonuspair == "bonus") then
									bonus = true
								end

								canbonus = true
							elseif ((rule[3] == "you") or (rule[3] == "you2")) and testcond(conds,2,i,j) then
								if (string.len(bonuspair) == 0) then
									bonuspair = "bonus"
								elseif (bonuspair == "you") then
									bonus = true
								end
							end

							if (rule[3] == "end") and testcond(conds,2,i,j) then
								if (string.len(endpair) == 0) then
									endpair = "you"
								elseif (bonuspair == "end") then
									ending = true
								end

								canend = true
							elseif ((rule[3] == "you") or (rule[3] == "you2")) and testcond(conds,2,i,j) then
								if (string.len(endpair) == 0) then
									endpair = "end"
								elseif (endpair == "you") then
									ending = true
								end
							end

							if (rule[3] == "done") and testcond(conds,2,i,j) then
								emptydone = true
							end

							if (keypair == "shut") and (hasfeature("level","is","shut",1,i,j) ~= nil) and floating_level(2,i,j) then
								unlock = true
							elseif (keypair == "open") and (hasfeature("level","is","open",1,i,j) ~= nil) and floating_level(2,i,j) then
								unlock = true
							end

							if canmelt and (hasfeature("level","is","hot",1,i,j) ~= nil) and floating_level(2,i,j) then
								melt = true
							end

							if candefeat and (hasfeature("level","is","defeat",1,i,j) ~= nil) and floating_level(2,i,j) then
								defeat = true
							end

							if canwin and (hasfeature("level","is","win",1,i,j) ~= nil) and floating_level(2,i,j) then
								victory = true
							end

							if canbonus and ((hasfeature("level","is","you",1,i,j) ~= nil) or (hasfeature("level","is","you2",1,i,j) ~= nil)) and floating_level(2,i,j) then
								bonus = true
							end

							if canend and ((hasfeature("level","is","you",1,i,j) ~= nil) or (hasfeature("level","is","you2",1,i,j) ~= nil)) and floating_level(2,i,j) then
								ending = true
							end
						elseif (rule[2] == "eat") and (rule[3] == "level") and (lsafe == false) then
							if testcond(conds,2,i,j) and floating_level(2,i,j) then
								local pmult,sound = checkeffecthistory("eat")
								setsoundname("removal",1,sound)
								destroylevel()
								return
							end
						end
					end

					local alive = true

					if unlock and (esafe == false) and alive then
						setsoundname("turn",7)

						if (math.random(1,4) == 1) then
							MF_particles("unlock",i,j,1,2,4,1,1)
						end

						alive = false
						delete(2,i,j)
					end

					if melt and (esafe == false) and alive then
						setsoundname("turn",9)

						if (math.random(1,4) == 1) then
							MF_particles("smoke",i,j,1,0,1,1,1)
						end

						alive = false
						delete(2,i,j)
					end

					if defeat and (esafe == false) and alive then
						setsoundname("turn",1)

						if (math.random(1,4) == 1) then
							MF_particles("destroy",i,j,1,0,3,1,1)
						end

						alive = false
						delete(2,i,j)
					end

					if bonus and (esafe == false) and alive then
						setsoundname("turn",2)

						if (math.random(1,4) == 1) then
							MF_particles("win",i,j,1,4,2,1,1)
						end

						if (emptybonus == false) then
							MF_playsound("bonus")
							MF_bonus(1)
							addundo({"bonus",1})
							emptybonus = true
						end

						alive = false
						delete(2,i,j)
					end

					if victory and alive then
						MF_win()
						return
					end

					if ending and alive and (generaldata.strings[WORLD] ~= generaldata.strings[BASEWORLD]) then
						if (editor.values[INEDITOR] ~= 0) then
							MF_end_single()
							MF_win()
							return
						else
							MF_end_single()
							MF_win()
							MF_credits(1)
							return
						end
					end
				end
			end
		end
	end

	if emptydone then
		MF_playsound("doneall_c")
	end

	if (#things > 0) then
		for i,rules in ipairs(things) do
			local rule = rules[1]
			local conds = rules[2]

			--MF_alert(rule[1] .. " " .. rule[2] .. " " .. rule[3] .. ", " .. tostring(testcond(conds,1)))

			if testcond(conds,1) then
				if (rule[2] == "eat") then
					local target = rule[3]

					local eaten = {}

					if (target ~= "all") and (target ~= "group") and (target ~= "empty") then
						if (unitlists[target] ~= nil) then
							if (target == "level") and (#unitlists["level"] > 0) and (lsafe == false) then
								local pmult,sound = checkeffecthistory("eat")
								setsoundname("removal",1,sound)
								destroylevel()
								return
							end

							for a,unitid in ipairs(unitlists[target]) do
								if (issafe(unitid) == false) then
									table.insert(eaten, unitid)
								end
							end
						end
					elseif (target == "empty") then
						local empties = findempty()

						for a,b in ipairs(empties) do
							local x = b % roomsizex
							local y = math.floor(b / roomsizex)

							generaldata.values[SHAKE] = 4

							local pmult,sound = checkeffecthistory("eat")
							MF_particles("eat",x,y,5 * pmult,0,3,1,1)
							setsoundname("removal",1,sound)

							delete(2,x,y)
						end
					end

					for a,b in ipairs(eaten) do
						local bunit = mmf.newObject(b)
						local x,y = bunit.values[XPOS],bunit.values[YPOS]
						generaldata.values[SHAKE] = 4

						local pmult,sound = checkeffecthistory("eat")
						MF_particles("eat",x,y,5 * pmult,0,3,1,1)
						setsoundname("removal",1,sound)

						delete(b,x,y)
					end
				elseif (rule[2] == "is") then
					local action = rule[3]

					if (action == "you") or (action == "you2") then
						local defeats = findfeature(nil,"is","defeat")
						local wins = findfeature(nil,"is","win")
						local ends = findfeature(nil,"is","end")

						if (defeats ~= nil) then
							for a,b in ipairs(defeats) do
								if (b[1] ~= "level") then
									local allyous = findall(b)

									if (#allyous > 0) then
										for c,d in ipairs(allyous) do
											if (issafe(1) == false) and floating_level(d) then
												destroylevel()
												return
											end
										end
									end
								elseif testcond(b[2],1) and (lsafe == false) then
									destroylevel()
									return
								end
							end
						end

						if ((#findallfeature("empty","is","defeat") > 0) or (#findallfeature("empty","is","defeat") > 0)) and floating_level(2) and (lsafe == false) then
							destroylevel()
							return
						end

						local canwin = false
						local canend = false

						if (wins ~= nil) then
							for a,b in ipairs(wins) do
								if (b[1] ~= "level") then
									local allyous = findall(b)

									if (#allyous > 0) then
										for c,d in ipairs(allyous) do
											if floating_level(d) then
												canwin = true
											end
										end
									end
								elseif testcond(b[2],1) then
									canwin = true
								end
							end
						end

						if (ends ~= nil) then
							for a,b in ipairs(ends) do
								if (b[1] ~= "level") then
									local allyous = findall(b)

									if (#allyous > 0) then
										for c,d in ipairs(allyous) do
											if floating_level(d) then
												canend = true
											end
										end
									end
								elseif testcond(b[2],1) then
									canend = true
								end
							end
						end

						if ((#findallfeature("empty","is","win") > 0) or (#findallfeature("empty","is","win") > 0)) and floating_level(2) then
							canwin = true
						end

						if ((#findallfeature("empty","is","end") > 0) or (#findallfeature("empty","is","end") > 0)) and floating_level(2) then
							canend = true
						end

						if canwin then
							MF_win()
							return
						end

						if canend and (generaldata.strings[WORLD] ~= generaldata.strings[BASEWORLD]) then
							if (editor.values[INEDITOR] ~= 0) then
								MF_end_single()
								MF_win()
								return
							else
								MF_end_single()
								MF_win()
								MF_credits(1)
								return
							end
						end
					elseif (action == "defeat") then
						local yous = findfeature(nil,"is","you")
						local yous2 = findfeature(nil,"is","you2")

						if (yous == nil) then
							yous = {}
						end

						if (yous2 ~= nil) then
							for i,v in ipairs(yous2) do
								table.insert(yous, v)
							end
						end

						if (yous ~= nil) then
							for a,b in ipairs(yous) do
								if (b[1] ~= "level") then
									local allyous = findall(b)

									if (#allyous > 0) then
										for c,d in ipairs(allyous) do
											if (issafe(d) == false) and floating_level(d) then
												local unit = mmf.newObject(d)

												local pmult,sound = checkeffecthistory("defeat")
												MF_particles("destroy",unit.values[XPOS],unit.values[YPOS],5 * pmult,0,3,1,1)
												setsoundname("removal",1,sound)
												generaldata.values[SHAKE] = 2
												delete(d)
											end
										end
									end
								elseif testcond(b[2],1) and (lsafe == false) then
									destroylevel()
									return
								end
							end
						end
					elseif (action == "weak") then
						for i,unit in ipairs(units) do
							local name = unit.strings[UNITNAME]
							if (unit.strings[UNITTYPE] == "text") then
								--name = "text"
							end

							if floating_level(unit.fixed) and (lsafe == false) then
								destroylevel()
							end
						end
					elseif (action == "hot") then
						local melts = findfeature(nil,"is","melt")

						if (melts ~= nil) then
							for a,b in ipairs(melts) do
								local allmelts = findall(b)

								if (#allmelts > 0) then
									for c,d in ipairs(allmelts) do
										if (issafe(d) == false) and floating_level(d) then
											local unit = mmf.newObject(d)

											local pmult,sound = checkeffecthistory("hot")
											MF_particles("smoke",unit.values[XPOS],unit.values[YPOS],5 * pmult,0,1,1,1)
											generaldata.values[SHAKE] = 2
											setsoundname("removal",9,sound)
											delete(d)
										end
									end
								end
							end
						end
					elseif (action == "melt") then
						local hots = findfeature(nil,"is","hot")

						if (hots ~= nil) and (lsafe == false) then
							for a,b in ipairs(hots) do
								local doit = false

								if (b[1] ~= "level") then
									local allhots = findall(b)

									for c,d in ipairs(allhots) do
										if floating_level(d) then
											doit = true
										end
									end
								elseif testcond(b[2],1) then
									doit = true
								end

								if doit then
									destroylevel()
								end
							end
						end

						if (#findallfeature("empty","is","hot") > 0) and floating_level(2) and (lsafe == false) then
							destroylevel()
							return
						end
					elseif (action == "open") then
						local shuts = findfeature(nil,"is","shut")

						local openthese = {}

						if (shuts ~= nil) then
							for a,b in ipairs(shuts) do
								local doit = false

								if (b[1] ~= "level") then
									local allshuts = findall(b)

									for c,d in ipairs(allshuts) do
										if floating_level(d) then
											doit = true

											if (issafe(d) == false) then
												table.insert(openthese, d)
											end
										end
									end
								elseif testcond(b[2],1) then
									doit = true
								end

								if doit then
									if (lsafe == false) then
										destroylevel()
										return
									end
								end
							end
						end

						if (#openthese > 0) then
							generaldata.values[SHAKE] = 8

							for a,b in ipairs(openthese) do
								local bunit = mmf.newObject(b)
								local bx,by = bunit.values[XPOS],bunit.values[YPOS]

								local pmult,sound = checkeffecthistory("unlock")
								setsoundname("turn",7,sound)
								MF_particles("unlock",bx,by,15 * pmult,2,4,1,1)

								delete(b)
								deleted[b] = 1
							end
						end

						if (#findallfeature("empty","is","shut") > 0) and floating_level(2) and (lsafe == false) then
							destroylevel()
							return
						end
					elseif (action == "shut") then
						local opens = findfeature(nil,"is","open")

						local openthese = {}

						if (opens ~= nil) then
							for a,b in ipairs(opens) do
								local doit = false

								if (b[1] ~= "level") then
									local allopens = findall(b)

									for c,d in ipairs(allopens) do
										if floating_level(d) then
											doit = true

											if (issafe(d) == false) then
												table.insert(openthese, d)
											end
										end
									end
								elseif testcond(b[2],1) then
									doit = true
								end

								if doit then
									if (lsafe == false) then
										destroylevel()
										return
									end
								end
							end
						end

						if (#openthese > 0) then
							generaldata.values[SHAKE] = 8

							for a,b in ipairs(openthese) do
								local bunit = mmf.newObject(b)
								local bx,by = bunit.values[XPOS],bunit.values[YPOS]

								local pmult,sound = checkeffecthistory("unlock")
								setsoundname("turn",7,sound)
								MF_particles("unlock",bx,by,15 * pmult,2,4,1,1)

								delete(b)
								deleted[b] = 1
							end
						end

						if (#findallfeature("empty","is","open") > 0) and floating_level(2) and (lsafe == false) then
							destroylevel()
							return
						end
					elseif (action == "sink") then
						local openthese = {}

						for a,unit in ipairs(units) do
							local name = unit.strings[UNITNAME]

							if (unit.strings[UNITTYPE] == "text") then
								--name = "text"
							end

							if floating_level(unit.fixed) then
								if (lsafe == false) then
									destroylevel()
									return
								end

								if (issafe(unit.fixed) == false) then
									table.insert(openthese, unit.fixed)
								end
							end
						end

						if (#openthese > 0) then
							generaldata.values[SHAKE] = 3

							for a,b in ipairs(openthese) do
								local bunit = mmf.newObject(b)
								local bx,by = bunit.values[XPOS],bunit.values[YPOS]

								local pmult,sound = checkeffecthistory("sink")
								setsoundname("removal",3,sound)
								local c1,c2 = getcolour(b)
								MF_particles("destroy",bx,by,15 * pmult,c1,c2,1,1)

								delete(b)
								deleted[b] = 1
							end
						end
					elseif (action == "done") then
						local doned = {}
						for a,unit in ipairs(units) do
							table.insert(doned, unit)
						end

						for a,unit in ipairs(doned) do
							addundo({"done",unit.strings[UNITNAME],unit.values[XPOS],unit.values[YPOS],unit.values[DIR],unit.values[ID],unit.fixed,unit.values[FLOAT]})

							unit.values[FLOAT] = 2
							unit.values[EFFECTCOUNT] = math.random(-10,10)
							unit.values[POSITIONING] = 7
							unit.flags[DEAD] = true

							delunit(unit.fixed)
						end

						MF_playsound("doneall_c")
					elseif (action == "bonus") then
						local yous = findfeature(nil,"is","you")
						local yous2 = findfeature(nil,"is","you2")

						if (yous == nil) then
							yous = {}
						end

						if (yous2 ~= nil) then
							for i,v in ipairs(yous2) do
								table.insert(yous, v)
							end
						end

						if (yous ~= nil) then
							for a,b in ipairs(yous) do
								if (b[1] ~= "level") then
									local allyous = findall(b)

									if (#allyous > 0) then
										for c,d in ipairs(allyous) do
											if (issafe(d) == false) and floating_level(d) then
												destroylevel("bonus")
												return
											end
										end
									end
								elseif testcond(b[2],1) then
									if (lsafe == false) then
										destroylevel("bonus")
										return
									end
								end
							end
						end

						if ((#findallfeature("empty","is","you") > 0) or (#findallfeature("empty","is","you2") > 0)) and floating_level(2) and (lsafe == false) then
							destroylevel("bonus")
							return
						end
					elseif (action == "win") then
						local yous = findfeature(nil,"is","you")
						local yous2 = findfeature(nil,"is","you2")

						if (yous == nil) then
							yous = {}
						end

						if (yous2 ~= nil) then
							for i,v in ipairs(yous2) do
								table.insert(yous, v)
							end
						end

						local canwin = false

						if (yous ~= nil) then
							for a,b in ipairs(yous) do
								local allyous = findall(b)
								local doit = false

								for c,d in ipairs(allyous) do
									if floating_level(d) then
										doit = true
									end
								end

								if doit then
									canwin = true
									for c,d in ipairs(allyous) do
										local unit = mmf.newObject(d)
										local pmult,sound = checkeffecthistory("win")
										MF_particles("win",unit.values[XPOS],unit.values[YPOS],10 * pmult,2,4,1,1)
									end
								end
							end
						end

						local emptyyou = false
						if ((#findallfeature("empty","is","you") > 0) or (#findallfeature("empty","is","you2") > 0)) and floating_level(2) then
							emptyyou = true
						end

						if (hasfeature("level","is","you",1) ~= nil) or (hasfeature("level","is","you2",1) ~= nil) or emptyyou then
							canwin = true
						end

						if canwin then
							MF_win()
							return
						end
					elseif (action == "end") then
						local yous = findfeature(nil,"is","you")
						local yous2 = findfeature(nil,"is","you2")

						if (yous == nil) then
							yous = {}
						end

						if (yous2 ~= nil) then
							for i,v in ipairs(yous2) do
								table.insert(yous, v)
							end
						end

						local canend = false

						if (yous ~= nil) then
							for a,b in ipairs(yous) do
								local allyous = findall(b)
								local doit = false

								for c,d in ipairs(allyous) do
									if floating_level(d) then
										doit = true
									end
								end

								if doit then
									canend = true
									for c,d in ipairs(allyous) do
										local unit = mmf.newObject(d)
										local pmult,sound = checkeffecthistory("win")
										MF_particles("win",unit.values[XPOS],unit.values[YPOS],10 * pmult,2,4,1,1)
									end
								end
							end
						end

						local emptyyou = false
						if ((#findallfeature("empty","is","you") > 0) or (#findallfeature("empty","is","you2") > 0)) and floating_level(2) then
							emptyyou = true
						end

						if (hasfeature("level","is","you",1) ~= nil) or (hasfeature("level","is","you2",1) ~= nil) or emptyyou then
							canend = true
						end

						if canend and (generaldata.strings[WORLD] ~= generaldata.strings[BASEWORLD]) then
							if (editor.values[INEDITOR] ~= 0) then
								MF_end_single()
								MF_win()
								break
							else
								MF_end_single()
								MF_win()
								MF_credits(1)
								break
							end
						end
					elseif (action == "tele") then
						for a,unit in ipairs(units) do
							local x,y = unit.values[XPOS],unit.values[YPOS]

							local tx,ty = fixedrandom(1,roomsizex-2),fixedrandom(1,roomsizey-2)

							if floating_level(unit.fixed) then
								update(unit.fixed,tx,ty)

								local pmult,sound = checkeffecthistory("tele")
								MF_particles("glow",x,y,5 * pmult,1,4,1,1)
								MF_particles("glow",tx,ty,5 * pmult,1,4,1,1)
								setsoundname("turn",6,sound)
							end
						end
					elseif (action == "move") then
						local dir = mapdir

						local drs = ndirs[dir + 1]
						local ox,oy = drs[1],drs[2]

						if (lstill == false) and (lsleep == false) then
							addundo({"levelupdate",Xoffset,Yoffset,Xoffset + ox * tilesize,Yoffset + oy * tilesize,dir,dir})
							MF_scrollroom(ox * tilesize,oy * tilesize)
							updateundo = true
						end
					elseif (action == "nudgeright") then
						local dir = 0

						local drs = ndirs[dir + 1]
						local ox,oy = drs[1],drs[2]

						if (lstill == false) and (lsleep == false) then
							addundo({"levelupdate",Xoffset,Yoffset,Xoffset + ox * tilesize,Yoffset + oy * tilesize,mapdir,mapdir})
							MF_scrollroom(ox * tilesize,oy * tilesize)
							updateundo = true
						end
					elseif (action == "nudgeup") then
						local dir = 1

						local drs = ndirs[dir + 1]
						local ox,oy = drs[1],drs[2]

						if (lstill == false) and (lsleep == false) then
							addundo({"levelupdate",Xoffset,Yoffset,Xoffset + ox * tilesize,Yoffset + oy * tilesize,mapdir,mapdir})
							MF_scrollroom(ox * tilesize,oy * tilesize)
							updateundo = true
						end
					elseif (action == "nudgeleft") then
						local dir = 2

						local drs = ndirs[dir + 1]
						local ox,oy = drs[1],drs[2]

						if (lstill == false) and (lsleep == false) then
							addundo({"levelupdate",Xoffset,Yoffset,Xoffset + ox * tilesize,Yoffset + oy * tilesize,mapdir,mapdir})
							MF_scrollroom(ox * tilesize,oy * tilesize)
							updateundo = true
						end
					elseif (action == "nudgedown") then
						local dir = 3

						local drs = ndirs[dir + 1]
						local ox,oy = drs[1],drs[2]

						if (lstill == false) and (lsleep == false) then
							addundo({"levelupdate",Xoffset,Yoffset,Xoffset + ox * tilesize,Yoffset + oy * tilesize,mapdir,mapdir})
							MF_scrollroom(ox * tilesize,oy * tilesize)
							updateundo = true
						end
					elseif (action == "fall") then
						local drop = 20
						local dir = mapdir

						local ox = 0
						local oy = 1

						if (lstill == false) then
							addundo({"levelupdate",Xoffset,Yoffset,Xoffset + tilesize * drop * ox,Yoffset + tilesize * drop * oy,dir,dir})
							MF_scrollroom(tilesize * drop * ox,tilesize * drop * oy)
							updateundo = true
						end
					elseif (action == "fallright") then
						local drop = 35
						local dir = mapdir

						local ox = 1
						local oy = 0

						if (lstill == false) then
							addundo({"levelupdate",Xoffset,Yoffset,Xoffset + tilesize * drop * ox,Yoffset + tilesize * drop * oy,dir,dir})
							MF_scrollroom(tilesize * drop * ox,tilesize * drop * oy)
							updateundo = true
						end
					elseif (action == "fallup") then
						local drop = 20
						local dir = mapdir

						local ox = 0
						local oy = -1

						if (lstill == false) then
							addundo({"levelupdate",Xoffset,Yoffset,Xoffset + tilesize * drop * ox,Yoffset + tilesize * drop * oy,dir,dir})
							MF_scrollroom(tilesize * drop * ox,tilesize * drop * oy)
							updateundo = true
						end
					elseif (action == "fallleft") then
						local drop = 35
						local dir = mapdir

						local ox = -1
						local oy = 0

						if (lstill == false) then
							addundo({"levelupdate",Xoffset,Yoffset,Xoffset + tilesize * drop * ox,Yoffset + tilesize * drop * oy,dir,dir})
							MF_scrollroom(tilesize * drop * ox,tilesize * drop * oy)
							updateundo = true
						end
					elseif (rule[3] == "turn") then
						local newmapdir = (mapdir - 1 + 4) % 4
						local newmaprotation = ((mapdir + 1 + 4) % 4) * 90

						addundo({"maprotation",maprotation,newmaprotation,newmapdir})
						addundo({"mapdir",mapdir,newmapdir})
						maprotation = newmaprotation
						mapdir = newmapdir
						MF_levelrotation(maprotation)
					elseif (rule[3] == "deturn") then
						local newmapdir = (mapdir + 1 + 4) % 4
						local newmaprotation = ((mapdir + 1 + 4) % 4) * 90

						addundo({"maprotation",maprotation,newmaprotation,newmapdir})
						addundo({"mapdir",mapdir,newmapdir})
						maprotation = newmaprotation
						mapdir = newmapdir
						MF_levelrotation(maprotation)
					elseif (action == "empty") then
						destroylevel("empty")
					end
				end
			end
		end
	end

	if (featureindex["done"] ~= nil) then
		for i,v in ipairs(featureindex["done"]) do
			table.insert(donethings, v)
		end
	end

	if (#donethings > 0) and (generaldata.values[WINTIMER] == 0) then
		for i,rules in ipairs(donethings) do
			local rule = rules[1]
			local conds = rules[2]

			if (#conds == 0) then
				if (rule[1] == "all") and (rule[2] == "is") and (rule[3] == "done") then
					if (generaldata.strings[WORLD] == generaldata.strings[BASEWORLD]) and (editor.values[INEDITOR] == 0) then
						MF_playsound("doneall_c")
						MF_allisdone()
					elseif (editor.values[INEDITOR] ~= 0) then
						local pmult = checkeffecthistory("win")

						MF_playsound("doneall_c")
						MF_done_single()
						MF_win()
						break
					else
						local pmult = checkeffecthistory("win")

						local mods_run = do_mod_hook("levelpack_done", {})

						if (mods_run == false) then
							MF_playsound("doneall_c")
							MF_done_single()
							MF_win()
							MF_credits(2)
						end
						break
					end
				end
			end
		end
	end

	if (generaldata.strings[WORLD] == generaldata.strings[BASEWORLD]) and (generaldata.strings[CURRLEVEL] == "305level") then
		local numfound = false

		if (featureindex["image"] ~= nil) then
			for i,v in ipairs(featureindex["image"]) do
				local rule = v[1]
				local conds = v[2]

				if (rule[1] == "image") and (rule[2] == "is") and (#conds == 0) then
					local num = rule[3]

					local nums = {
						one = {1, "image_desc_1"},
						two = {2, "image_desc_2"},
						three = {3, "image_desc_3"},
						four = {4, "image_desc_4"},
						five = {5, "image_desc_5"},
						six = {6, "image_desc_6"},
						seven = {7, "image_desc_7"},
						eight = {8, "image_desc_8"},
						nine = {9, "image_desc_9"},
						ten = {10, "image_desc_10"},
						fourteen = {11, "image_desc_11"},
						sixteen = {12, "image_desc_12"},
						minusone = {13, "image_desc_13"},
						minustwo = {14, "image_desc_14"},
						minusthree = {15, "image_desc_15"},
						minusten = {16, "image_desc_16"},
						win = {0, "win"}
					}

					if (nums[num] ~= nil) then
						local data = nums[num]

						if (data[2] ~= "win") then
							MF_setart(data[1], langtext(data[2],true))
							numfound = true
						else
							local yous = findallfeature(nil,"is","you",true)
							local yous2 = findallfeature(nil,"is","you2",true)

							if (#yous2 > 0) then
								for a,b in ipairs(yous2) do
									table.insert(yous, b)
								end
							end

							for a,b in ipairs(yous) do
								local unit = mmf.newObject(b)
								local x,y = unit.values[XPOS],unit.values[YPOS]

								if (x > roomsizex - 16) then
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

		if (numfound == false) then
			MF_setart(0,"")
		end
	end

	if unlocked then
		setsoundname("turn",7)
	end
end

function findplayer()
	local playerfound = false

	local players1 = findfeature(nil,"is","you")
	local players2 = findfeature(nil,"is","you2")

	local players = {}
	if (players1 ~= nil) then
		for i,v in ipairs(players1) do
			table.insert(players, v)
		end
	end

	if (players2 ~= nil) then
		for i,v in ipairs(players2) do
			table.insert(players, v)
		end
	end

	if (players ~= nil) then
		for i,v in ipairs(players) do
			if (v[1] ~= "level") and (v[1] ~= "empty") then
				local allplayers = findall(v)

				if (#allplayers > 0) then
					playerfound = true
				end
			elseif (v[1] == "level") then
				if testcond(v[2],1) then
					playerfound = true
				end
			elseif (v[1] == "empty") then
				local empties = findempty(v[2],true)

				if (#empties > 0) then
					playerfound = true
				end
			end
		end
	end

	if playerfound then
		MF_musicstate(0)
		generaldata2.values[NOPLAYER] = 0
	else
		MF_musicstate(1)
		generaldata2.values[NOPLAYER] = 1
	end
end

function diceblock()
	condstatus = {}

	if (condfeatureindex["often"] ~= nil) then
		for i,v in ipairs(condfeatureindex["often"]) do
			local conds = v[2]

			local identifier = tostring(conds)

			if (condstatus[identifier] == nil) then
				condstatus[identifier] = {}
			end

			local data = condstatus[identifier]

			--[[
			for a,b in ipairs(conds) do
				if (b[1] == "often") or (b[1] == "not often") then
					local rnd = fixedrandom(1,4)

					local id = "often" .. tostring(a)

					data[id] = rnd
				end
			end
			]]--
		end
	end

	if (condfeatureindex["seldom"] ~= nil) then
		for i,v in ipairs(condfeatureindex["seldom"]) do
			local conds = v[2]

			local identifier = tostring(conds)

			if (condstatus[identifier] == nil) then
				condstatus[identifier] = {}
			end

			local data = condstatus[identifier]

			--[[
			for a,b in ipairs(conds) do
				if (b[1] == "seldom") or (b[1] == "not seldom") then
					local rnd = fixedrandom(1,6)

					local id = "seldom" .. tostring(a)

					data[id] = rnd
				end
			end
			]]--
		end
	end
end
