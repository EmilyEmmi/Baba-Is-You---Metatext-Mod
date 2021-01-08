function code(alreadyrun_)
	local playrulesound = false
	local alreadyrun = alreadyrun_ or false

	if (updatecode == 1) then
		HACK_INFINITY = HACK_INFINITY + 1
		--MF_alert("code being updated!")

		MF_removeblockeffect(0)
		wordrelatedunits = {}

		do_mod_hook("rule_update",{alreadyrun})

		if (HACK_INFINITY < 200) then
			local checkthese = {}
			local wordidentifier = ""
			wordunits,wordidentifier,wordrelatedunits = findwordunits()

			if (#wordunits > 0) then
				for i,v in ipairs(wordunits) do
					if testcond(v[2],v[1]) then
						table.insert(checkthese, v[1])
					end
				end
			end

			features = {}
			featureindex = {}
			condfeatureindex = {}
			visualfeatures = {}
			notfeatures = {}
			groupfeatures = {}
			local firstwords = {}
			local alreadyused = {}

			addbaserule("text","is","push")
			addbaserule("level","is","stop")
			addbaserule("cursor","is","select")

			formlettermap()

			if (#codeunits > 0) then
				for i,v in ipairs(codeunits) do
					table.insert(checkthese, v)
				end
			end

			if (#checkthese > 0) or (#letterunits > 0) then
				for iid,unitid in ipairs(checkthese) do
					local unit = mmf.newObject(unitid)
					local x,y = unit.values[XPOS],unit.values[YPOS]
					local ox,oy,nox,noy = 0,0
					local tileid = x + y * roomsizex

					setcolour(unit.fixed)

					if (alreadyused[tileid] == nil) and (unit.values[TYPE] ~= 5) then
						for i=1,2 do
							local drs = dirs[i+2]
							local ndrs = dirs[i]
							ox = drs[1]
							oy = drs[2]
							nox = ndrs[1]
							noy = ndrs[2]

							--MF_alert("Doing firstwords check for " .. unit.strings[UNITNAME] .. ", dir " .. tostring(i))

							local hm = codecheck(unitid,ox,oy,i)
							local hm2 = codecheck(unitid,nox,noy,i)

							if (#hm == 0) and (#hm2 > 0) then
								--MF_alert("Added " .. unit.strings[UNITNAME] .. " to firstwords, dir " .. tostring(i))

								table.insert(firstwords, {{unitid}, i, 1, unit.strings[UNITNAME], unit.values[TYPE]})

								if (alreadyused[tileid] == nil) then
									alreadyused[tileid] = {}
								end

								alreadyused[tileid][i] = 1
							end
						end
					end
				end

				--table.insert(checkthese, {unit.strings[UNITNAME], unit.values[TYPE], unit.values[XPOS], unit.values[YPOS], 0, 1, {unitid})

				for a,b in pairs(letterunits_map) do
					for iid,data in ipairs(b) do
						local x,y,i = data[3],data[4],data[5]
						local unitids = data[7]
						local width = data[6]
						local word,wtype = data[1],data[2]

						local unitid = unitids[1]

						local tileid = x + y * roomsizex

						if (alreadyused[tileid] == nil) or ((alreadyused[tileid] ~= nil) and (alreadyused[tileid][i] == nil)) then
							local drs = dirs[i+2]
							local ndrs = dirs[i]
							ox = drs[1]
							oy = drs[2]
							nox = ndrs[1] * width
							noy = ndrs[2] * width

							local hm = codecheck(unitid,ox,oy,i)
							local hm2 = codecheck(unitid,nox,noy,i)

							--MF_alert(word .. ", " .. tostring(hm) .. ", " .. tostring(hm2) .. ", " .. tostring(width))

							if (#hm == 0) and (#hm2 > 0) then
								table.insert(firstwords, {unitids, i, width, word, wtype})

								if (alreadyused[tileid] == nil) then
									alreadyused[tileid] = {}
								end

								alreadyused[tileid][i] = 1
							end
						end
					end
				end

				docode(firstwords,wordunits)
				grouprules()
				playrulesound = postrules(alreadyrun)
				updatecode = 0

				local newwordunits,newwordidentifier,wordrelatedunits = findwordunits()

				--MF_alert("ID comparison: " .. newwordidentifier .. " - " .. wordidentifier)

				if (newwordidentifier ~= wordidentifier) then
					updatecode = 1
					code(true)
				else
					--domaprotation()
				end
			end
		else
			MF_alert("Level destroyed - code() run too many times")
			destroylevel("infinity")
			return
		end

		if (alreadyrun == false) then
			effects_decors()
		end
	end

	if (alreadyrun == false) then
		local rulesoundshort = ""
		alreadyrun = true
		if playrulesound and (generaldata5.values[LEVEL_DISABLERULEEFFECT] == 0) then
			local pmult,sound = checkeffecthistory("rule")
			rulesoundshort = sound
			local rulename = "rule" .. tostring(math.random(1,5)) .. rulesoundshort
			MF_playsound(rulename)
		end
	end
end

function docode(firstwords)
	local donefirstwords = {}
	local limiter = 0

	if (#firstwords > 0) then
		for k,unitdata in ipairs(firstwords) do
			if (type(unitdata[1]) == "number") then
				timedmessage("Old rule format detected. Please replace modified .lua files to ensure functionality.")
			end

			local unitids = unitdata[1]
			local unitid = unitids[1]
			local dir = unitdata[2]
			local width = unitdata[3]
			local word = unitdata[4]
			local wtype = unitdata[5]

			if (string.sub(word, 1, 5) == "text_") then
				word = string.sub(word, 6)
			end

			local unit = mmf.newObject(unitid)
			local x,y = unit.values[XPOS],unit.values[YPOS]
			local tileid = x + y * roomsizex

			--MF_alert("Testing " .. word .. ": " .. tostring(donefirstwords[tileid]) .. ", " .. tostring(dir) .. ", " .. tostring(unitid))
			limiter = limiter + 1

			if (limiter > 5000) then
				MF_alert("Level destroyed - firstwords run too many times")
				destroylevel("toocomplex")
				return
			end

			if (donefirstwords[tileid] == nil) or ((donefirstwords[tileid] ~= nil) and (donefirstwords[tileid][dir] == nil)) and (limiter < 5000) then
				local ox,oy = 0,0
				local name = word

				local drs = dirs[dir]
				ox = drs[1]
				oy = drs[2]

				if (donefirstwords[tileid] == nil) then
					donefirstwords[tileid] = {}
				end

				donefirstwords[tileid][dir] = 1

				local sentences,finals,maxlen,variations = calculatesentences(unitid,x,y,dir)

				if (sentences == nil) then
					return
				end

				--MF_alert(tostring(k) .. ", " .. tostring(variations))

				if (maxlen > 2) then
					for i=1,variations do
						local current = finals[i]
						local letterword = ""
						local stage = 0
						local prevstage = 0
						local tileids = {}

						local notids = {}
						local notwidth = 0
						local notslot = 0

						local stage3reached = false
						local stage2reached = false
						local doingcond = false
						local nocondsafterthis = false
						local condsafeand = false

						local firstrealword = false
						local letterword_prevstage = 0
						local letterword_firstid = 0

						local currtiletype = 0
						local prevtiletype = 0

						local prevsafewordid = 0
						local prevsafewordtype = 0

						local stop = false

						local sent = sentences[i]

						local thissent = ""

						for wordid=1,#sent do
							local s = sent[wordid]
							local nexts = sent[wordid + 1] or {-1, -1, {-1}, 1}

							prevtiletype = currtiletype

							local tilename = s[1]
							local tiletype = s[2]
							local tileid = s[3][1]
							local tilewidth = s[4]

							local wordtile = false

							currtiletype = tiletype

							local dontadd = false

							thissent = thissent .. tilename .. "," .. tostring(wordid) .. "  "

							for a,b in ipairs(s[3]) do
								table.insert(tileids, b)
							end

							--[[
								0 = objekti
								1 = verbi
								2 = quality
								3 = alkusana (LONELY)
								4 = Not
								5 = letter
								6 = And
								7 = ehtosana
								8 = customobject
							]]--

							if (tiletype ~= 5) then
								if (stage == 0) then
									if (tiletype == 0) then
										prevstage = stage
										stage = 2
									elseif (tiletype == 3) then
										prevstage = stage
										stage = 1
									elseif (tiletype ~= 4) then
										prevstage = stage
										stage = -1
										stop = true
									end
								elseif (stage == 1) then
									if (tiletype == 0) then
										prevstage = stage
										stage = 2
									elseif (tiletype == 6) then
										prevstage = stage
										stage = 6
									elseif (tiletype ~= 4) then
										prevstage = stage
										stage = -1
										stop = true
									end
								elseif (stage == 2) then
									if (wordid ~= #sent) then
										if (tiletype == 1) and (prevtiletype ~= 4) and ((prevstage ~= 4) or doingcond or (stage3reached == false)) then
											stage2reached = true
											doingcond = false
											prevstage = stage
											nocondsafterthis = true
											stage = 3
										elseif ((tiletype == 7) and (stage2reached == false) and (nocondsafterthis == false)) then
											doingcond = true
											condsafeand = true
											prevstage = stage
											stage = 3
										elseif (tiletype == 6) and (prevtiletype ~= 4) then
											prevstage = stage
											stage = 4
										elseif (tiletype ~= 4) then
											prevstage = stage
											stage = -1
											stop = true
										end
									else
										stage = -1
										stop = true
									end
								elseif (stage == 3) then
									stage3reached = true

									if (tiletype == 0) or (tiletype == 2) or (tiletype == 8) then
										prevstage = stage
										stage = 5
									elseif (tiletype ~= 4) then
										stage = -1
										stop = true
									end
								elseif (stage == 4) then
									if (wordid <= #sent) then
										if (tiletype == 0) or ((tiletype == 2) and stage3reached) or ((tiletype == 8) and stage3reached) then
											prevstage = stage
											stage = 2
										elseif ((tiletype == 1) and stage3reached) and (doingcond == false) and (prevtiletype ~= 4) then
											stage2reached = true
											nocondsafterthis = true
											prevstage = stage
											stage = 3
										elseif (tiletype == 7) and (nocondsafterthis == false) and ((prevtiletype ~= 6) or ((prevtiletype == 6) and condsafeand)) then
											doingcond = true
											stage2reached = true
											condsafeand = true
											prevstage = stage
											stage = 3
										elseif (tiletype ~= 4) then
											prevstage = stage
											stage = -1
											stop = true
										end
									else
										stage = -1
										stop = true
									end
								elseif (stage == 5) then
									if (wordid ~= #sent) then
										if (tiletype == 1) and doingcond and (prevtiletype ~= 4) then
											stage2reached = true
											doingcond = false
											prevstage = stage
											nocondsafterthis = true
											stage = 3
										elseif (tiletype == 6) and (prevtiletype ~= 4) then
											prevstage = stage
											stage = 4
										elseif (tiletype ~= 4) then
											prevstage = stage
											stage = -1
											stop = true
										end
									else
										stage = -1
										stop = true
									end
								elseif (stage == 6) then
									if (tiletype == 3) then
										prevstage = stage
										stage = 1
									elseif (tiletype ~= 4) then
										prevstage = stage
										stage = -1
										stop = true
									end
								end
							end

							if (stage > 0) then
								firstrealword = true
							end

							if (tiletype == 4) then
								if (#notids == 0) then
									notids = s[3]
									notwidth = tilewidth
									notslot = wordid
								end
							else
								if (stop == false) and (tiletype ~= 0) then
									notids = {}
									notwidth = 0
									notslot = 0
								end
							end

							if (prevtiletype ~= 4) then
								prevsafewordid = wordid - 1
								prevsafewordtype = prevtiletype
							end

							--MF_alert(tilename .. ", " .. tostring(wordid) .. ", " .. tostring(stage) .. ", " .. tostring(#sent) .. ", " .. tostring(tiletype) .. ", " .. tostring(prevtiletype) .. ", " .. tostring(stop))

							--MF_alert(tostring(k) .. "_" .. tostring(i) .. "_" .. tostring(wordid) .. ": " .. tilename .. ", " .. tostring(tiletype) .. ", " .. tostring(stop) .. ", " .. tostring(stage) .. ", " .. tostring(letterword_firstid).. ", " .. tostring(prevtiletype))

							if (stop == false) then
								if (dontadd == false) then
									table.insert(current, {tilename, tiletype, tileids, tilewidth})
									tileids = {}
								end
							else
								for a=1,#s[3] do
									if (#tileids > 0) then
										table.remove(tileids, #tileids)
									end
								end

								if (tiletype == 0) and (prevtiletype == 0) and (#notids > 0) then
									notids = {}
									notwidth = 0
								end

								if (wordid < #sent) then
									if (wordid > 1) then
										if (#notids > 0) and firstrealword and (notslot > 1) and (tiletype ~= 7) and ((tiletype ~= 1) or ((tiletype == 1) and (prevtiletype == 0))) then
											--MF_alert("Notstatus added to firstwords" .. ", " .. tostring(wordid) .. ", " .. tostring(nexts[2]))
											table.insert(firstwords, {notids, dir, notwidth, "not", 4})

											if (nexts[2] ~= nil) and ((nexts[2] == 0) or (nexts[2] == 3) or (nexts[2] == 4)) and (tiletype ~= 3) then
												--MF_alert("Also added " .. tostring(wordid) .. ", " .. tilename)
												table.insert(firstwords, {s[3], dir, tilewidth, tilename, tiletype})
											end
										else
											if (prevtiletype == 0) and ((tiletype == 1) or (tiletype == 7)) then
												--MF_alert("Added previous word: " .. sent[wordid - 1][1] .. " to firstwords")
												table.insert(firstwords, {sent[wordid - 1][3], dir, tilewidth, tilename, tiletype})
											elseif (prevsafewordtype == 0) and (prevsafewordid > 0) and (prevtiletype == 4) and (tiletype ~= 1) and (tiletype ~= 2) then
												--MF_alert("Added previous safe word: " .. sent[prevsafewordid][1] .. " to firstwords")
												table.insert(firstwords, {sent[prevsafewordid][3], dir, tilewidth, tilename, tiletype})
											else
												--MF_alert("Added the current word: " .. s[1] .. " to firstwords")
												table.insert(firstwords, {s[3], dir, tilewidth, tilename, tiletype})
											end
										end

										break
									elseif (wordid == 1) then
										if (nexts[3][1] ~= -1) then
											--MF_alert(nexts[1] .. " added to firstwords E" .. ", " .. tostring(wordid))
											table.insert(firstwords, {nexts[3], dir, nexts[4], nexts[1], nexts[2]})
										end

										break
									end
								end
							end
						end

						--MF_alert(thissent)
					end
				end

				if (#finals > 0) then
					for i,sentence in ipairs(finals) do
						local group_objects = {}
						local group_targets = {}
						local group_conds = {}

						local group = group_objects
						local stage = 0

						local prefix = ""

						local allowedwords = {0}
						local allowedwords_extra = {}

						local testing = ""

						local extraids = {}
						local extraids_current = ""
						local extraids_ifvalid = {}

						local valid = true

						if (#finals > 1) then
							for a,b in ipairs(finals) do
								if (#b == #sentence) and (a > i) then
									local identical = true

									for c,d in ipairs(b) do
										local currids = d[3]
										local equivids = sentence[c][3] or {}

										for e,f in ipairs(currids) do
											--MF_alert(tostring(a) .. ": " .. tostring(f) .. ", " .. tostring(equivids[e]))
											if (f ~= equivids[e]) then
												identical = false
											end
										end
									end

									if identical then
										--MF_alert(sentence[1][1] .. ", " .. sentence[2][1] .. ", " .. sentence[3][1] .. " (" .. tostring(i) .. ") is identical to " .. b[1][1] .. ", " .. b[2][1] .. ", " .. b[3][1] .. " (" .. tostring(a) .. ")")
										valid = false
									end
								end
							end
						end

						if valid then
							for index,wdata in ipairs(sentence) do
								local wname = wdata[1]
								local wtype = wdata[2]
								local wid = wdata[3]

								testing = testing .. wname .. ", "

								local wcategory = -1

								if (wtype == 1) or (wtype == 3) or (wtype == 7) then
									wcategory = 1
								elseif (wtype ~= 4) and (wtype ~= 6) then
									wcategory = 0
								else
									table.insert(extraids_ifvalid, {prefix .. wname, wtype, wid})
									extraids_current = wname
								end

								if (wcategory == 0) then
									local allowed = false

									for a,b in ipairs(allowedwords) do
										if (b == wtype) then
											allowed = true
											break
										end
									end

									if (allowed == false) then
										for a,b in ipairs(allowedwords_extra) do
											if (wname == b) then
												allowed = true
												break
											end
										end
									end

									if allowed then
										table.insert(group, {prefix .. wname, wtype, wid})
									else
										table.insert(firstwords, {{wid[1]}, dir, 1, wname, wtype})
										break
									end
								elseif (wcategory == 1) then
									if (index < #sentence) then
										allowedwords = {0}
										allowedwords_extra = {}

										local realname = unitreference["text_" .. wname]
										local cargtype = false
										local cargextra = false

										local argtype = {0}
										local argextra = {}

										if (changes[realname] ~= nil) then
											local wchanges = changes[realname]

											if (wchanges.argtype ~= nil) then
												argtype = wchanges.argtype
												cargtype = true
											end

											if (wchanges.argextra ~= nil) then
												argextra = wchanges.argextra
												cargextra = true
											end
										end

										if (cargtype == false) or (cargextra == false) then
											local wvalues = tileslist[realname] or {}

											if (cargtype == false) then
												argtype = wvalues.argtype or {0}
											end

											if (cargextra == false) then
												argextra = wvalues.argextra or {}
											end
										end

										--MF_alert(wname .. ", " .. tostring(realname) .. ", " .. "text_" .. wname)

										if (realname == nil) then
											MF_alert("No object found for " .. wname .. "!")
											valid = false
											break
										else
											if (wtype == 1) then
												allowedwords = argtype

												stage = 1
												local target = {prefix .. wname, wtype, wid}
												table.insert(group_targets, {target, {}})
												local sid = #group_targets
												group = group_targets[sid][2]

												newcondgroup = 1
											elseif (wtype == 3) then
												allowedwords = {0}
												local cond = {prefix .. wname, wtype, wid}
												table.insert(group_conds, {cond, {}})
											elseif (wtype == 7) then
												allowedwords = argtype
												allowedwords_extra = argextra

												stage = 2
												local cond = {prefix .. wname, wtype, wid}
												table.insert(group_conds, {cond, {}})
												local sid = #group_conds
												group = group_conds[sid][2]
											end
										end
									end
								end

								if (wtype == 4) then
									if (prefix == "not ") then
										prefix = ""
									else
										prefix = "not "
									end
								else
									prefix = ""
								end

								if (wname ~= extraids_current) and (string.len(extraids_current) > 0) and (wtype ~= 4) then
									for a,extraids_valid in ipairs(extraids_ifvalid) do
										table.insert(extraids, {prefix .. extraids_valid[1], extraids_valid[2], extraids_valid[3]})
									end

									extraids_ifvalid = {}
									extraids_current = ""
								end
							end
							--MF_alert("Testing: " .. testing)

							local conds = {}
							local condids = {}
							for c,group_cond in ipairs(group_conds) do
								local rule_cond = group_cond[1][1]
								--table.insert(condids, group_cond[1][3])

								condids = copytable(condids, group_cond[1][3])

								table.insert(conds, {rule_cond,{}})
								local condgroup = conds[#conds][2]

								for e,condword in ipairs(group_cond[2]) do
									local rule_condword = condword[1]
									--table.insert(condids, condword[3])

									condids = copytable(condids, condword[3])

									table.insert(condgroup, rule_condword)
								end
							end

							for c,group_object in ipairs(group_objects) do
								local rule_object = group_object[1]

								for d,group_target in ipairs(group_targets) do
									local rule_verb = group_target[1][1]

									for e,target in ipairs(group_target[2]) do
										local rule_target = target[1]

										local finalconds = {}
										for g,finalcond in ipairs(conds) do
											table.insert(finalconds, {finalcond[1], finalcond[2]})
										end

										local rule = {rule_object,rule_verb,rule_target}

										local ids = {}
										ids = copytable(ids, group_object[3])
										ids = copytable(ids, group_target[1][3])
										ids = copytable(ids, target[3])

										for g,h in ipairs(extraids) do
											ids = copytable(ids, h[3])
										end

										for g,h in ipairs(condids) do
											ids = copytable(ids, h)
										end

										addoption(rule,finalconds,ids)
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

function codecheck(unitid,ox,oy,cdir_,ignore_end_)
	local unit = mmf.newObject(unitid)
	local ux,uy = unit.values[XPOS],unit.values[YPOS]
	local x = unit.values[XPOS] + ox
	local y = unit.values[YPOS] + oy
	local result = {}
	local letters = false
	local justletters = false
	local cdir = cdir_ or 0

	local ignore_end = false
	if (ignore_end_ ~= nil) then
		ignore_end = ignore_end_
	end

	if (cdir == 0) then
		MF_alert("CODECHECK - CDIR == 0 - why??")
	end

	local tileid = x + y * roomsizex

	if (unitmap[tileid] ~= nil) then
		for i,b in ipairs(unitmap[tileid]) do
			local v = mmf.newObject(b)
			local w = 1

			if (v.values[TYPE] ~= 5) then
				if (v.strings[UNITTYPE] == "text") then
					table.insert(result, {{b}, w, v.strings[NAME], v.values[TYPE], cdir})
				else
					if (#wordunits > 0) then
						for c,d in ipairs(wordunits) do
							if (b == d[1]) and testcond(d[2],d[1]) then
								table.insert(result, {{b}, w, v.strings[UNITNAME], v.values[TYPE], cdir})
							end
						end
					end
				end
			else
				justletters = true
			end
		end
	end

	if (letterunits_map[tileid] ~= nil) then
		for i,v in ipairs(letterunits_map[tileid]) do
			local unitids = v[7]
			local width = v[6]
			local word = v[1]
			local wtype = v[2]
			local dir = v[5]

			if (string.len(word) > 5) and (string.sub(word, 1, 5) == "text_") then
				word = string.sub(v[1], 6)
			end

			local valid = true
			if ignore_end and ((x ~= v[3]) or (y ~= v[4])) and (width > 1) then
				valid = false
			end

			if (cdir ~= 0) and (width > 1) then
				if ((cdir == 1) and (ux > v[3]) and (ux < v[3] + width)) or ((cdir == 2) and (uy > v[4]) and (uy < v[4] + width)) then
					valid = false
				end
			end

			--MF_alert(word .. ", " .. tostring(valid) .. ", " .. tostring(dir) .. ", " .. tostring(cdir))

			if (dir == cdir) and valid then
				table.insert(result, {unitids, width, word, wtype, dir})
				letters = true
			end
		end
	end

	return result,letters,justletters
end

function addoption(option,conds_,ids,visible,notrule,tags_)
	--MF_alert(option[1] .. ", " .. option[2] .. ", " .. option[3])

	local visual = true

	if (visible ~= nil) then
		visual = visible
	end

	local conds = {}

	if (conds_ ~= nil) then
		conds = conds_
	else
		print("nil conditions in rule: " .. option[1] .. ", " .. option[2] .. ", " .. option[3])
	end

	local tags = tags_ or {}

	if (#option == 3) then
		local rule = {option,conds,ids,tags}
		table.insert(features, rule)
		local target = option[1]
		local verb = option[2]
		local effect = option[3]

		if (featureindex[effect] == nil) then
			featureindex[effect] = {}
		end

		if (featureindex[target] == nil) then
			featureindex[target] = {}
		end

		if (featureindex[verb] == nil) then
			featureindex[verb] = {}
		end

		table.insert(featureindex[effect], rule)

		--[[
		if (string.sub(effect, 1, 4) == "not ") and (string.sub(effect, 5) ~= target) then
			local noteffect = string.sub(effect, 5)

			if (featureindex[noteffect] == nil) then
				featureindex[noteffect] = {}
			end

			MF_alert(target .. ", " .. verb .. ", " .. effect)

			table.insert(featureindex[noteffect], rule)
		end
		]]--

		table.insert(featureindex[verb], rule)

		if (target ~= effect) then
			table.insert(featureindex[target], rule)
		end

		if visual then
			local visualrule = copyrule(rule)
			table.insert(visualfeatures, visualrule)
		end

		local groupcond = false

		if (target == "group") or (effect == "group") or (target == "not group") or (effect == "not group") then
			groupcond = true
		end

		if (notrule ~= nil) then
			local notrule_effect = notrule[1]
			local notrule_id = notrule[2]

			if (notfeatures[notrule_effect] == nil) then
				notfeatures[notrule_effect] = {}
			end

			local nr_e = notfeatures[notrule_effect]

			if (nr_e[notrule_id] == nil) then
				nr_e[notrule_id] = {}
			end

			local nr_i = nr_e[notrule_id]

			table.insert(nr_i, rule)
		end

		if (#conds > 0) then
			local addedto = {}

			for i,cond in ipairs(conds) do
				local condname = cond[1]
				if (string.sub(condname, 1, 4) == "not ") then
					condname = string.sub(condname, 5)
				end

				if (condfeatureindex[condname] == nil) then
					condfeatureindex[condname] = {}
				end

				if (addedto[condname] == nil) then
					table.insert(condfeatureindex[condname], rule)
					addedto[condname] = 1
				end

				if (cond[2] ~= nil) then
					if (#cond[2] > 0) then
						local alreadyused = {}
						local newconds = {}
						local allfound = false

						--alreadyused[target] = 1

						for a,b in ipairs(cond[2]) do
							if (b ~= "all") and (b ~= "not all") then
								alreadyused[b] = 1
								table.insert(newconds, b)
							elseif (b == "all") then
								allfound = true
							elseif (b == "not all") then
								newconds = {"empty","text"}
							end

							if (b == "group") or (b == "not group") then
								groupcond = true
							end
						end

						if allfound then
							for a,mat in pairs(objectlist) do
								if (alreadyused[a] == nil) and (a ~= "group") and (a ~= "all") and (a ~= "text") and (string.sub(a, 1, 5) ~= "text_") then
									table.insert(newconds, a)
									alreadyused[a] = 1
								end
							end
						end

						cond[2] = newconds
					end
				end
			end
		end

		if groupcond then
			table.insert(groupfeatures, rule)
		end

		local targetnot = string.sub(target, 1, 4)
		local targetnot_ = string.sub(target, 5)

		if (targetnot == "not ") and (objectlist[targetnot_] ~= nil) and (targetnot_ ~= "group") and (effect ~= "group") and (effect ~= "not group") then
			if (targetnot_ ~= "all") then
				for i,mat in pairs(objectlist) do
					if (i ~= "empty") and (i ~= "all") and (i ~= "level") and (i ~= "group") and (i ~= targetnot_) and (i ~= "text") and (string.sub(i, 1, 5) ~= "text_") then
						local rule = {i,verb,effect}
						local newconds = {}
						for a,b in ipairs(conds) do
							table.insert(newconds, b)
						end
						addoption(rule,newconds,ids,false,{effect,#featureindex[effect]},tags)
					end
				end
			else
				local mats = {"empty","text"}

				for m,i in pairs(mats) do
					local rule = {i,verb,effect}
					local newconds = {}
					for a,b in ipairs(conds) do
						table.insert(newconds, b)
					end
					addoption(rule,newconds,ids,false,{effect,#featureindex[effect]},tags)
				end
			end
		end
	end
end

function postrules(alreadyrun_)
	if (featureindex["text"] ~= nil) then
		for k,rules in ipairs(featureindex["text"]) do
			local rule = rules[1]
			local conds = rules[2]
			local ids = rules[3]
			local tags = rules[4]
			if rule[1] == "text" then
				for a,b in pairs(fullunitlist) do -- fullunitlist contains all units, is new
					if (string.sub(a, 1, 5) == "text_") then
						local newconds = {}
						local newtags = {}

						for c,d in ipairs(conds) do
							table.insert(newconds, d)
						end

						for c,d in ipairs(tags) do
							table.insert(newtags, d)
						end

						table.insert(newtags, "text")

						local newword1 = a
						local newword2 = rule[2]
						local newword3 = rule[3]
						if newword3 == "text" and newword2 == "is" then
							newword3 = newword1
						end

						local newrule = {newword1, newword2, newword3}
						addoption(newrule,newconds,ids,false,nil,newtags)
					end
				end
			end
		end
	end

	local newruleids = {}
	local ruleeffectlimiter = {}
	local playrulesound = false
	local alreadyrun = alreadyrun_ or false

	local protects = {}
	local mimicprotects = {}

	if (featureindex["all"] ~= nil) then
		for k,rules in ipairs(featureindex["all"]) do
			local rule = rules[1]
			local conds = rules[2]
			local ids = rules[3]
			local tags = rules[4]

			if (rule[3] == "all") then
				if (rule[2] ~= "is") then
					local nconds = {}

					if (featureindex["not all"] ~= nil) then
						for a,prules in ipairs(featureindex["not all"]) do
							local prule = prules[1]
							local pconds = prules[2]

							if (prule[1] == rule[1]) and (prule[2] == rule[2]) and (prule[3] == "not all") then
								local ipconds = invertconds(pconds)

								for c,d in ipairs(ipconds) do
									table.insert(nconds, d)
								end
							end
						end
					end

					for i,mat in pairs(objectlist) do
						if (i ~= "empty") and (i ~= "all") and (i ~= "level") and (i ~= "group") and (i ~= "text") and (string.sub(i, 1, 5) ~= "text_") then
							local newrule = {rule[1],rule[2],i}
							local newconds = {}
							for a,b in ipairs(conds) do
								table.insert(newconds, b)
							end
							for a,b in ipairs(nconds) do
								table.insert(newconds, b)
							end
							addoption(newrule,newconds,ids,false,nil,tags)
						end
					end
				end
			end

			if (rule[1] == "all") and (string.sub(rule[3], 1, 4) ~= "not ") then
				local nconds = {}

				if (featureindex["not all"] ~= nil) then
					for a,prules in ipairs(featureindex["not all"]) do
						local prule = prules[1]
						local pconds = prules[2]

						if (prule[1] == rule[1]) and (prule[2] == rule[2]) and (prule[3] == "not " .. rule[3]) then
							local ipconds = invertconds(pconds)

							if crashy_ then
								crashy = true
							end

							for c,d in ipairs(ipconds) do
								table.insert(nconds, d)
							end
						end
					end
				end

				for i,mat in pairs(objectlist) do
					if (i ~= "empty") and (i ~= "all") and (i ~= "level") and (i ~= "group") and (i ~= "text") and (string.sub(i, 1, 5) ~= "text_") then
						local newrule = {i,rule[2],rule[3]}
						local newconds = {}
						for a,b in ipairs(conds) do
							table.insert(newconds, b)
						end
						for a,b in ipairs(nconds) do
							table.insert(newconds, b)
						end
						addoption(newrule,newconds,ids,false,nil,tags)
					end
				end
			end

			if (rule[1] == "all") and (string.sub(rule[3], 1, 4) == "not ") then
				for i,mat in pairs(objectlist) do
					if (i ~= "empty") and (i ~= "all") and (i ~= "level") and (i ~= "group") and (i ~= "text") and (string.sub(i, 1, 5) ~= "text_") then
						local newrule = {i,rule[2],rule[3]}
						local newconds = {}
						for a,b in ipairs(conds) do
							table.insert(newconds, b)
						end
						addoption(newrule,newconds,ids,false,nil,tags)
					end
				end
			end
		end
	end

	if (featureindex["mimic"] ~= nil) then
		for i,rules in ipairs(featureindex["mimic"]) do
			local rule = rules[1]
			local conds = rules[2]
			local tags = rules[4]

			if (rule[2] == "mimic") then
				local object = rule[1]
				local target = rule[3]

				local isnot = false

				if (string.sub(target, 1, 4) == "not ") then
					target = string.sub(target, 5)
					isnot = true
				end

				if isnot then
					if (mimicprotects[object] == nil) then
						mimicprotects[object] = {}
					end

					table.insert(mimicprotects[object], {target, conds, rule[3]})
				end
			end
		end
	end

	if (featureindex["mimic"] ~= nil) then
		for i,rules in ipairs(featureindex["mimic"]) do
			local rule = rules[1]
			local conds = rules[2]
			local tags = rules[4]

			if (rule[2] == "mimic") then
				local object = rule[1]
				local target = rule[3]
				local mprotects = mimicprotects[object] or {}
				local extraconds = {}

				local valid = true

				if (string.sub(target, 1, 4) == "not ") then
					valid = false
				end

				for a,b in ipairs(mprotects) do
					if (b[1] == target) then
						local pconds = b[2]

						if (#pconds == 0) then
							valid = false
						else
							local newconds = invertconds(pconds)

							for c,d in ipairs(newconds) do
								table.insert(extraconds, d)
							end
						end
					end
				end

				local copythese = {}

				if valid then
					if (getmat(object,true) ~= nil) and (getmat(target,true) ~= nil) then
						if (featureindex[target] ~= nil) then
							copythese = featureindex[target]
						end
					end

					for a,b in ipairs(copythese) do
						local trule = b[1]
						local tconds = b[2]
						local ids = b[3]
						local ttags = b[4]

						local valid = true
						for c,d in ipairs(ttags) do
							if (d == "mimic") then
								valid = false
							end
						end

						if (trule[1] == target) and (trule[2] ~= "mimic") and valid then
							local newconds = {}
							local newtags = {}

							for c,d in ipairs(tconds) do
								table.insert(newconds, d)
							end

							for c,d in ipairs(conds) do
								table.insert(newconds, d)
							end

							for c,d in ipairs(extraconds) do
								table.insert(newconds, d)
							end

							for c,d in ipairs(ttags) do
								table.insert(newtags, d)
							end

							for c,d in ipairs(tags) do
								table.insert(newtags, d)
							end

							table.insert(newtags, "mimic")

							local newword1 = object
							local newword2 = trule[2]
							local newword3 = trule[3]

							local newrule = {newword1, newword2, newword3}

							addoption(newrule,newconds,ids,true,nil,newtags)
						end
					end
				end
			end
		end
	end

	for i,unit in ipairs(units) do
		unit.active = false
	end

	local limit = #features

	for i,rules in ipairs(features) do
		if (i <= limit) then
			local rule = rules[1]
			local conds = rules[2]
			local ids = rules[3]

			if (rule[1] == rule[3]) and (rule[2] == "is") then
				table.insert(protects, i)
			end

			if (ids ~= nil) then
				local works = true
				local idlist = {}
				local effectsok = false

				if (#ids > 0) then
					for a,b in ipairs(ids) do
						table.insert(idlist, b)
					end
				end

				if (#idlist > 0) and works then
					for a,d in ipairs(idlist) do
						for c,b in ipairs(d) do
							if (b ~= 0) then
								local bunit = mmf.newObject(b)

								if (bunit.strings[UNITTYPE] == "text") then
									bunit.active = true
									setcolour(b,"active")
								end
								newruleids[b] = 1

								if (ruleids[b] == nil) and (#undobuffer > 1) and (alreadyrun == false) and (generaldata5.values[LEVEL_DISABLERULEEFFECT] == 0) then
									if (ruleeffectlimiter[b] == nil) then
										local x,y = bunit.values[XPOS],bunit.values[YPOS]
										local c1,c2 = getcolour(b,"active")
										--MF_alert(b)
										MF_particles_for_unit("bling",x,y,5,c1,c2,1,1,b)
										ruleeffectlimiter[b] = 1
									end

									if (rule[2] ~= "play") then
										playrulesound = true
									end
								end
							end
						end
					end
				elseif (#idlist > 0) and (works == false) then
					for a,visualrules in pairs(visualfeatures) do
						local vrule = visualrules[1]
						local same = comparerules(rule,vrule)

						if same then
							table.remove(visualfeatures, a)
						end
					end
				end
			end

			local rulenot = 0
			local neweffect = ""

			local nothere = string.sub(rule[3], 1, 4)

			if (nothere == "not ") then
				rulenot = 1
				neweffect = string.sub(rule[3], 5)
			end

			if (rulenot == 1) then
				local newconds,crashy = invertconds(conds,nil,rule[3])

				local newbaserule = {rule[1],rule[2],neweffect}

				local target = rule[1]
				local verb = rule[2]

				for a,b in ipairs(featureindex[target]) do
					local same = comparerules(newbaserule,b[1])

					if same then
						--MF_alert(rule[1] .. ", " .. rule[2] .. ", " .. neweffect .. ": " .. b[1][1] .. ", " .. b[1][2] .. ", " .. b[1][3])
						local theseconds = b[2]

						if (#newconds > 0) then
							if (newconds[1] ~= "never") then
								for c,d in ipairs(newconds) do
									table.insert(theseconds, d)
								end
							else
								theseconds = {"never",{}}
							end
						end

						if crashy then
							addoption({rule[1],"is","crash"},theseconds,ids,false,nil,rules[4])
						end

						b[2] = theseconds
					end
				end
			end
		end
	end

	if (#protects > 0) then
		for i,v in ipairs(protects) do
			local rule = features[v]

			local baserule = rule[1]
			local conds = rule[2]

			local target = baserule[1]

			local newconds = {{"never"}}

			if (conds[1] ~= "never") then
				if (#conds > 0) then
					newconds = {}

					for a,b in ipairs(conds) do
						local condword = b[1]
						local condgroup = {}

						if (string.sub(condword, 1, 1) == "(") then
							condword = string.sub(condword, 2)
						end

						if (string.sub(condword, -1) == ")") then
							condword = string.sub(condword, 1, #condword - 1)
						end

						local newcondword = "not " .. condword

						if (string.sub(condword, 1, 3) == "not") then
							newcondword = string.sub(condword, 5)
						end

						if (a == 1) then
							newcondword = "(" .. newcondword
						end

						if (a == #conds) then
							newcondword = newcondword .. ")"
						end

						if (b[2] ~= nil) then
							for c,d in ipairs(b[2]) do
								table.insert(condgroup, d)
							end
						end

						table.insert(newconds, {newcondword, condgroup})
					end
				end

				if (featureindex[target] ~= nil) then
					for a,rules in ipairs(featureindex[target]) do
						local targetrule = rules[1]
						local targetconds = rules[2]

						local object = targetrule[3]

						if (targetrule[1] == target) and (targetrule[2] == "is") and (target ~= object) and ((getmat(object) ~= nil) or (object == "revert")) and (object ~= "group") then
							if (#newconds > 0) then
								if (newconds[1] == "never") then
									targetconds = {}
								end

								for c,d in ipairs(newconds) do
									table.insert(targetconds, d)
								end
							end

							rules[2] = targetconds
						end
					end
				end
			end
		end
	end

	ruleids = newruleids

	ruleblockeffect()

	return playrulesound
end

function grouprules()
	local memberchecks = {}
	local notmemberchecks = {}
	local parsemembers = {}
	local otherchecks = {}
	local nototherchecks = {}
	local groupis = {}
	local recursion = false

	--MF_alert("Updating grouprules")

	for i,v in ipairs(groupfeatures) do
		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]

		if (rule[1] ~= "group") and (rule[1] ~= "not group") and (rule[3] ~= "group") and (rule[3] ~= "not group") then
			table.insert(otherchecks, v)
		elseif (rule[1] ~= "group") and (rule[1] ~= "not group") and ((rule[3] == "group") or (rule[3] == "not group")) then
			if (rule[2] == "is") then
				local valid = true
				local groupcond = false

				for a,cond in ipairs(conds) do
					if (cond[1] == "never") then
						valid = false
						break
					end

					for c,param in ipairs(cond[2]) do
						if (param == "group") then
							recursion = true
							groupcond = true
							break
						elseif (param == "not group") then
							recursion = true
							break
						end
					end
				end

				if valid then
					local obj = rule[1]

					local notmember = false
					local notrule = false

					if (string.sub(obj, 1, 4) == "not ") then
						obj = string.sub(obj, 5)
						notrule = true
					end

					if (rule[3] == "not group") then
						notmember = true
					end

					if notrule then
						table.insert(parsemembers, {obj, conds, notmember, groupcond})
					else
						if (notmember == false) then
							if (memberchecks[obj] == nil) then
								memberchecks[obj] = {}
							end

							table.insert(memberchecks[obj], {conds, groupcond})
						else
							if (notmemberchecks[obj] == nil) then
								notmemberchecks[obj] = {}
							end

							table.insert(notmemberchecks[obj], {conds, groupcond})
						end
					end
				end
			else
				if (rule[3] == "group") then
					table.insert(otherchecks, v)
				elseif (rule[3] == "not group") then
					local obj = rule[1]

					if (nototherchecks[obj] == nil) then
						nototherchecks[obj] = {}
					end

					table.insert(nototherchecks[obj], {rule[2], conds})
				end
			end
		elseif (rule[1] == "group") or (rule[1] == "not group") then
			table.insert(groupis, v)
		end
	end

	for i,v in ipairs(parsemembers) do
		local notname = v[1]
		local notmember = v[3]

		if (notname ~= "all") then
			for m,mat in pairs(objectlist) do
				if (m ~= notname) and (m ~= "all") and (m ~= "level") and (m ~= "group") and (m ~= "text") and (string.sub(m, 1, 5) ~= "text_") and (m ~= "empty") then
					if (notmember == false) then
						--MF_alert("added " .. m)

						if (memberchecks[m] == nil) then
							memberchecks[m] = {}
						end

						table.insert(memberchecks[m], {v[2], v[4]})
					else
						if (notmemberchecks[m] == nil) then
							notmemberchecks[m] = {}
						end

						table.insert(notmemberchecks[m], {v[2], v[4]})
					end
				end
			end
		else
			if (notmember == false) then
				--MF_alert("added " .. m)

				if (memberchecks["empty"] == nil) then
					memberchecks["empty"] = {}
				end

				if (memberchecks["text"] == nil) then
					memberchecks["text"] = {}
				end

				table.insert(memberchecks["empty"], {v[2], v[4]})
				table.insert(memberchecks["text"], {v[2], v[4]})
			else
				if (notmemberchecks["empty"] == nil) then
					notmemberchecks["empty"] = {}
				end

				if (notmemberchecks["text"] == nil) then
					notmemberchecks["text"] = {}
				end

				table.insert(notmemberchecks["empty"], {v[2], v[4]})
				table.insert(notmemberchecks["text"], {v[2], v[4]})
			end
		end
	end

	local membercode = ""
	local oldmembercode = ""
	groupunits = {}
	local memberlist = {}
	local oldmemberlist = {}
	local done = false
	local limit = 0

	-- Muista lisätä kaikki membercheckin ja notmembercheckin jäsenet groupunitseihin! Myös condseista!! findunits(name,groupunits,conds)

	while (done == false) and (limit < 400) do
		for member,data in pairs(memberchecks) do
			local members = nil

			if (member ~= "empty") then
				members = unitlists[member]
			else
				members = findempty()
			end

			for h,j in ipairs(data) do
				local found = false
				local addtolist = false
				local condstotest = {}
				local notcondstotest = {}
				local conds = j[1]
				local groupcond = j[2]

				local autofail = false

				if recursion or (groupcond == false) then
					for i,cond in ipairs(conds) do
						local ncond = {cond[1], {}}
						addtolist = true

						for a,param in ipairs(cond[2]) do
							if (param ~= "group") and (param ~= "not group") then
								table.insert(ncond[2], param)

								if (param ~= "all") then
									groupunits[param] = 1
								end
							elseif (param == "group") then
								recursion = true
								for c,d in ipairs(oldmemberlist) do
									table.insert(ncond[2], d[1])
									groupunits[d[1]] = 1
								end
							else
								recursion = true
								if (#oldmemberlist > 0) then
									for e,f in ipairs(oldmemberlist) do
										table.insert(ncond[2], "not " .. f[1])
									end
								else
									table.insert(ncond[2], "not edge")
								end

								for m,mat in pairs(objectlist) do
									if (m ~= "all") and (m ~= "level") and (m ~= "group") and (m ~= "text") and (string.sub(m, 1, 5) ~= "text_") and (m ~= "empty") then
										local addthis = true

										for e,f in ipairs(oldmemberlist) do
											if (m == f[1]) then
												addthis = false
												break
											end
										end

										if addthis then
											groupunits[m] = 1
										end
									end
								end
							end
						end

						table.insert(condstotest, ncond)
					end
				end

				if (notmemberchecks[member] ~= nil) then
					for a,b in ipairs(notmemberchecks[member]) do
						if (#b[1] == 0) then
							autofail = true
							break
						end

						table.insert(notcondstotest, {})

						local nctest = notcondstotest[#notcondstotest]
						local ncgroupcond = b[2]
						addtolist = true

						if recursion or (ncgroupcond == false) then
							for i,cond in ipairs(b[1]) do
								local ncond = {cond[1], {}}

								for a,param in ipairs(cond[2]) do
									if (param ~= "group") and (param ~= "not group") then
										table.insert(ncond[2], param)

										if (param ~= "all") then
											groupunits[param] = 1
										end
									elseif (param == "group") then
										recursion = true
										for c,d in ipairs(oldmemberlist) do
											table.insert(ncond[2], d[1])
											groupunits[d[1]] = 1
										end
									else
										recursion = true
										if (#oldmemberlist > 0) then
											for e,f in ipairs(oldmemberlist) do
												table.insert(ncond[2], "not " .. f[1])
											end
										else
											table.insert(ncond[2], "not edge")
										end

										for m,mat in pairs(objectlist) do
											if (m ~= "all") and (m ~= "level") and (m ~= "group") and (m ~= "text") and (string.sub(m, 1, 5) ~= "text_") and (m ~= "empty") then
												local addthis = true

												for e,f in ipairs(oldmemberlist) do
													if (m == f[1]) then
														addthis = false
														break
													end
												end

												if addthis then
													groupunits[m] = 1
												end
											end
										end
									end
								end

								table.insert(nctest, ncond)
							end
						end
					end
				end

				if (#condstotest == 0) and (#notcondstotest == 0) and (autofail == false) then
					found = true
				end

				if (autofail == false) and (members ~= nil) then
					for a,b in ipairs(members) do
						local x,y = -1,-1
						local unitid = b

						if (member == "empty") then
							local x = math.floor(b % roomsizex)
							local y = math.floor(b / roomsizex)
							unitid = 2
						end

						local nottest = false

						for c,d in ipairs(notcondstotest) do
							if testcond(d,unitid,x,y) then
								nottest = true
								break
							end
						end

						if (nottest == false) and testcond(condstotest,unitid,x,y) then
							if (member ~= "empty") then
								local bunit = mmf.newObject(b)

								if (bunit.flags[DEAD] == false) then
									found = true
								end
							else
								found = true
							end
						end
					end
				end

				if addtolist then
					groupunits[member] = 1
				end

				if found then
					local fullconds = {}
					if (#notcondstotest > 0) then
						for i,v in ipairs(notcondstotest) do
							fullconds = invertconds(v,fullconds)
						end
					end
					for i,v in ipairs(condstotest) do
						table.insert(fullconds, v)
					end

					table.insert(memberlist, {member, fullconds})
					membercode = membercode .. member
				end
			end
		end

		if (recursion == false) then
			done = true
		else
			MF_alert(membercode .. ", " .. oldmembercode)

			if (membercode ~= oldmembercode) then
				oldmembercode = membercode
				membercode = ""
				groupunits = {}
				oldmemberlist = {}

				for a,b in ipairs(memberlist) do
					table.insert(oldmemberlist, {b[1], b[2]})
				end

				memberlist = {}
			else
				done = true
			end
		end

		limit = limit + 1

		if (limit >= 400) then
			HACK_INFINITY = 200
			destroylevel("infinity")
			return
		end
	end

	for i,v in ipairs(otherchecks) do
		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]

		local newconds = {}
		local newtags = {}

		local valid = true

		if (rule[3] == "group") then
			local obj = rule[1]
			if (nototherchecks[obj] ~= nil) then
				for a,b in ipairs(nototherchecks[obj]) do
					if (b[1] == rule[2]) then
						if (#b[2] == 0) then
							valid = false
							break
						else
							newconds = invertconds(b[2],newconds)
						end
					end
				end
			end
		end

		if valid then
			for a,cond in ipairs(conds) do
				local newcond = {cond[1], {}}

				for c,param in ipairs(cond[2]) do
					if (param ~= "group") and (param ~= "not group") then
						table.insert(newcond[2], param)
					elseif (param == "group") then
						if (#memberlist > 0) then
							for e,f in ipairs(memberlist) do
								table.insert(newcond[2], f[1])
							end
						else
							table.insert(newcond[2], "_none_")
						end
					else
						if (#memberlist > 0) then
							for e,f in ipairs(memberlist) do
								table.insert(newcond[2], "not " .. f[1])
							end
						else
							table.insert(newcond[2], "not edge")
						end
					end
				end

				table.insert(newconds, newcond)
			end

			for c,tag in ipairs(tags) do
				table.insert(newtags, tag)
			end

			table.insert(newtags, "group")

			if (rule[3] ~= "group") and (rule[3] ~= "not group") then
				addoption(rule,newconds,ids,false,nil,newtags)
			elseif (rule[3] == "group") then
				for a,b in ipairs(memberlist) do
					local newrule = {rule[1],rule[2],b[1]}

					addoption(newrule,newconds,ids,false,nil,newtags)
				end
			end
		end
	end

	for g,v in ipairs(groupis) do
		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]

		local newconds = {}
		for a,cond in ipairs(conds) do
			local newcond = {cond[1], {}}

			for c,param in ipairs(cond[2]) do
				if (param ~= "group") and (param ~= "not group") then
					table.insert(newcond[2], param)
				elseif (param == "group") then
					if (#memberlist > 0) then
						for e,f in ipairs(memberlist) do
							table.insert(newcond[2], f[1])
						end
					else
						table.insert(newcond[2], "_none_")
					end
				else
					if (#memberlist > 0) then
						for e,f in ipairs(memberlist) do
							table.insert(newcond[2], "not " .. f[1])
						end
					else
						table.insert(newcond[2], "not edge")
					end
				end
			end

			table.insert(newconds, newcond)
		end

		local newtags = {}

		for c,tag in ipairs(tags) do
			table.insert(newtags, tag)
		end

		table.insert(newtags, "group")

		local targets = {}
		if (rule[1] == "group") then
			targets = memberlist
		elseif (rule[1] == "not group") then
			for m,mat in pairs(objectlist) do
				if (m ~= "all") and (m ~= "text") and (string.sub(m, 1, 5) ~= "text_") and (m ~= "group") and (m ~= "all") and (m ~= "level") then
					local valid = true

					for e,f in ipairs(memberlist) do
						if (f[1] == m) then
							valid = false
						end
					end

					if valid then
						table.insert(targets, {m, {}})
					end
				end
			end
		end

		if (rule[3] ~= "group") and (rule[3] ~= "not group") then
			for a,b in ipairs(targets) do
				local mname = b[1]

				local finalconds = {}
				for c,d in ipairs(newconds) do
					table.insert(finalconds, d)
				end
				for c,d in ipairs(b[2]) do
					table.insert(finalconds, d)
				end

				local newrule = {mname,rule[2],rule[3]}
				addoption(newrule,finalconds,ids,false,nil,newtags)
			end
		else
			if (rule[1] ~= "not group") then
				for a,b in ipairs(memberlist) do
					local mname = b[1]
					local mname2 = b[1]

					if (rule[3] == "not group") then
						mname2 = "not " .. b[1]
					end

					local finalconds = {}
					for c,d in ipairs(newconds) do
						table.insert(finalconds, d)
					end
					for c,d in ipairs(b[2]) do
						table.insert(finalconds, d)
					end

					if (rule[1] == "group") then
						local newrule = {mname,rule[2],mname2}
						addoption(newrule,finalconds,ids,false,nil,newtags)
					end
				end
			else
				if (rule[3] == "group") then
					for m,mat in pairs(objectlist) do
						if (m ~= "all") and (m ~= "level") and (m ~= "group") and (m ~= "text") and (string.sub(m, 1, 5) ~= "text_") and (m ~= "empty") then
							local addthis = true

							for e,f in ipairs(memberlist) do
								if (m == f[1]) then
									addthis = false
									break
								end
							end

							if addthis then
								local mname = m
								local newrule = {mname,"is","crash"}
								addoption(newrule,newconds,ids,false,nil,newtags)
							end
						end
					end
				end
			end
		end
	end
end

function copyrule(rule)
	local baserule = rule[1]
	local conds = rule[2]
	local ids = rule[3]
	local tags = rule[4]

	local newbaserule = {}
	local newconds = {}
	local newids = {}
	local newtags = {}

	newbaserule = {baserule[1],baserule[2],baserule[3]}

	if (#conds > 0) then
		for i,cond in ipairs(conds) do
			local newcond = {cond[1]}

			if (cond[2] ~= nil) then
				local condnames = cond[2]
				newcond[2] = {}

				for a,b in ipairs(condnames) do
					table.insert(newcond[2], b)
				end
			end

			table.insert(newconds, newcond)
		end
	end

	if (#ids > 0) then
		for i,id in ipairs(ids) do
			local iid = {}

			for a,b in ipairs(id) do
				table.insert(iid, b)
			end

			table.insert(newids, iid)
		end
	end

	if (#tags > 0) then
		for i,tag in ipairs(tags) do
			table.insert(newtags, tag)
		end
	end

	local newrule = {newbaserule,newconds,newids,newtags}

	return newrule
end

function comparerules(baserule1,baserule2)
	local same = true

	for i,v in ipairs(baserule1) do
		if (v ~= baserule2[i]) then
			same = false
		end
	end

	return same
end

function findwordunits()
	local result = {}
	local alreadydone = {}
	local checkrecursion = {}
	local related = {}

	local identifier = ""

	if (featureindex["word"] ~= nil) then
		for i,v in ipairs(featureindex["word"]) do
			local rule = v[1]
			local conds = v[2]
			local ids = v[3]

			local name = rule[1]

			if (objectlist[name] ~= nil) and (name ~= "text") and (alreadydone[name] == nil) then
				local these = findall({name,{}})
				alreadydone[name] = 1

				if (#these > 0) then
					for a,b in ipairs(these) do
						local bunit = mmf.newObject(b)
						local valid = true

						if (featureindex["broken"] ~= nil) then
							if (hasfeature(getname(bunit),"is","broken",b,bunit.values[XPOS],bunit.values[YPOS]) ~= nil) then
								valid = false
							end
						end

						if valid then
							table.insert(result, {b, conds})
							identifier = identifier .. name
							-- LISÄÄ TÄHÄN LISÄÄ DATAA
						end
					end
				end
			end

			for a,b in ipairs(conds) do
				local condtype = b[1]
				local params = b[2] or {}

				identifier = identifier .. condtype

				if (#params > 0) then
					for c,d in ipairs(params) do
						identifier = identifier .. tostring(d)

						related = findunits(d,related,conds)
					end
				end
			end

			--MF_alert("Going through " .. name)

			if (#ids > 0) then
				if (#ids[1] == 1) then
					local firstunit = mmf.newObject(ids[1][1])

					local notname = name
					if (string.sub(name, 1, 4) == "not ") then
						notname = string.sub(name, 5)
					end

					if (firstunit.strings[UNITNAME] ~= "text_" .. name) and (firstunit.strings[UNITNAME] ~= "text_" .. notname) then
						--MF_alert("Checking recursion for " .. name)
						table.insert(checkrecursion, {name, i})
					end
				end
			else
				MF_alert("No ids listed in Word-related rule! rules.lua line 1302 - this needs fixing asap (related to grouprules line 1118)")
			end
		end

		for a,checkname_ in ipairs(checkrecursion) do
			local found = false

			local checkname = checkname_[1]

			local b = checkname
			if (string.sub(b, 1, 4) == "not ") then
				b = string.sub(checkname, 5)
			end

			for i,v in ipairs(featureindex["word"]) do
				local rule = v[1]
				local ids = v[3]
				local tags = v[4]

				if (rule[1] == b) or (rule[1] == "all") or ((rule[1] ~= b) and (string.sub(rule[1], 1, 3) == "not")) then
					for c,g in ipairs(ids) do
						for a,d in ipairs(g) do
							local idunit = mmf.newObject(d)

							-- Tässä pitäisi testata myös Group!
							if (idunit.strings[UNITNAME] == "text_" .. rule[1]) or (rule[1] == "all") then
								--MF_alert("Matching objects - found")
								found = true
							elseif (rule[1] == "group") then
								--MF_alert("Group - found")
								found = true
							elseif (rule[1] ~= checkname) and (string.sub(rule[1], 1, 3) == "not") then
								--MF_alert("Not Object - found")
								found = true
							end
						end
					end

					for c,g in ipairs(tags) do
						if (g == "mimic") then
							found = true
						end
					end
				end
			end

			if (found == false) then
				--MF_alert("Wordunit status for " .. b .. " is unstable!")
				identifier = "null"
				wordunits = {}

				for i,v in pairs(featureindex["word"]) do
					local rule = v[1]
					local ids = v[3]

					--MF_alert("Checking to disable: " .. rule[1] .. " " .. ", not " .. b)

					if (rule[1] == b) or (rule[1] == "not " .. b) then
						v[2] = {{"never",{}}}
					end
				end

				if (string.sub(checkname, 1, 4) == "not ") then
					local notrules_word = notfeatures["word"]
					local notrules_id = checkname_[2]
					local disablethese = notrules_word[notrules_id]

					for i,v in ipairs(disablethese) do
						v[2] = {{"never",{}}}
					end
				end
			end
		end
	end

	--MF_alert("Current id (end): " .. identifier)

	return result,identifier,related
end

function ruleblockeffect()
	local handled = {}

	for i,rules in pairs(features) do
		local rule = rules[1]
		local conds = rules[2]
		local ids = rules[3]
		local blocked = false

		for a,b in ipairs(conds) do
			if (b[1] == "never") then
				blocked = true
				break
			end
		end

		--MF_alert(rule[1] .. " " .. rule[2] .. " " .. rule[3] .. ": " .. tostring(blocked))

		if blocked then
			for a,d in ipairs(ids) do
				for c,b in ipairs(d) do
					if (handled[b] == nil) then
						local runit = mmf.newObject(b)

						local blockid = MF_create("Ingame_blocked")
						local bunit = mmf.newObject(blockid)

						bunit.x = runit.x
						bunit.y = runit.y

						bunit.values[XPOS] = runit.values[XPOS]
						bunit.values[YPOS] = runit.values[YPOS]
						bunit.layer = 1
						bunit.values[ZLAYER] = 20
						bunit.values[TYPE] = b

						bunit.scaleX = spritedata.values[TILEMULT] * generaldata2.values[ZOOM]
						bunit.scaleY = spritedata.values[TILEMULT] * generaldata2.values[ZOOM]

						bunit.visible = runit.visible

						local c1,c2 = getuicolour("blocked")
						MF_setcolour(blockid,c1,c2)

						handled[b] = 2
					end
				end
			end
		else
			for a,d in ipairs(ids) do
				for c,b in ipairs(d) do
					if (handled[b] == nil) then
						handled[b] = 1
					elseif (handled[b] == 2) then
						MF_removeblockeffect(b)
					end
				end
			end
		end
	end
end

function getsentencevariant(sentences,combo)
	local result = {}

	for i,words in ipairs(sentences) do
		local currcombo = combo[i]

		local current = words[currcombo]

		table.insert(result, current)
	end

	return result
end

function addbaserule(rule1,rule2,rule3)
	if (featureindex[rule1] == nil) then
		featureindex[rule1] = {}
	end

	if (featureindex[rule2] == nil) then
		featureindex[rule2] = {}
	end

	if (featureindex[rule3] == nil) then
		featureindex[rule3] = {}
	end

	local rule = {rule1,rule2,rule3}
	local fullrule = {rule,{},{},{"base"}}
	table.insert(features, fullrule)
	table.insert(featureindex[rule1], fullrule)
	table.insert(featureindex[rule2], fullrule)
	table.insert(featureindex[rule3], fullrule)
end

function calculatesentences(unitid,x,y,dir)
	local drs = dirs[dir]
	local ox,oy = drs[1],drs[2]

	local finals = {}
	local sentences = {}
	local sents = {}
	local done = false

	local step = 0
	local combo = {}
	local variantshere = {}
	local totalvariants = 1
	local maxpos = 0

	local limiter = 3000

	local combospots = {}

	local unit = mmf.newObject(unitid)

	local done = false
	while (done == false) and (totalvariants < limiter) do
		local words,letters,jletters = codecheck(unitid,ox*step,oy*step,dir,true)

		--MF_alert(tostring(unitid) .. ", " .. unit.strings[UNITNAME] .. ", " .. tostring(#words))

		step = step + 1

		if (totalvariants >= limiter) then
			MF_alert("Level destroyed - too many variants A")
			destroylevel("toocomplex")
			return nil
		end

		if (totalvariants < limiter) then
			if (#words > 0) then
				totalvariants = totalvariants * #words
				variantshere[step] = #words
				sents[step] = {}
				combo[step] = 1

				if (totalvariants >= limiter) then
					MF_alert("Level destroyed - too many variants B")
					destroylevel("toocomplex")
					return nil
				end

				if (#words > 1) then
					combospots[#combospots + 1] = step
				end

				if (totalvariants > #finals) then
					local limitdiff = totalvariants - #finals
					for i=1,limitdiff do
						table.insert(finals, {})
					end
				end

				for i,v in ipairs(words) do
					--unitids, width, word, wtype, dir

					--MF_alert("Step " .. tostring(step) .. ", word " .. v[3] .. " here")

					table.insert(sents[step], v)
				end
			else
				--MF_alert("Step " .. tostring(step) .. ", no words here, " .. tostring(letters) .. ", " .. tostring(jletters))

				if jletters then
					variantshere[step] = 0
					sents[step] = {}
					combo[step] = 0
				else
					done = true
				end
			end
		end
	end

	--MF_alert(tostring(step) .. ", " .. tostring(totalvariants))

	if (totalvariants >= limiter) then
		MF_alert("Level destroyed - too many variants C")
		destroylevel("toocomplex")
		return nil
	end

	maxpos = step

	local combostep = 0

	for i=1,totalvariants do
		step = 1
		sentences[i] = {}

		while (step < maxpos) do
			local c = combo[step]

			if (c ~= nil) then
				if (c > 0) then
					local s = sents[step]
					local word = s[c]

					local w = word[2]

					--MF_alert(tostring(i) .. ", step " .. tostring(step) .. ": " .. word[3] .. ", " .. tostring(#word[1]) .. ", " .. tostring(w))

					table.insert(sentences[i], {word[3], word[4], word[1], word[2]})

					step = step + w
				else
					break
				end
			else
				MF_alert("c is nil, " .. tostring(step))
				break
			end
		end

		if (#combospots > 0) then
			combostep = 0

			local targetstep = combospots[combostep + 1]

			combo[targetstep] = combo[targetstep] + 1

			while (combo[targetstep] > variantshere[targetstep]) do
				combo[targetstep] = 1

				combostep = (combostep + 1) % #combospots

				targetstep = combospots[combostep + 1]

				combo[targetstep] = combo[targetstep] + 1
			end
		end
	end

	--[[
	MF_alert(tostring(totalvariants) .. ", " .. tostring(#sentences))
	for i,v in ipairs(sentences) do
		local text = ""

		for a,b in ipairs(v) do
			text = text .. b[1] .. " "
		end

		MF_alert(text)
	end
	]]--

	return sentences,finals,maxpos,totalvariants
end

function invertconds(conds,db,target_)
	local newconds = db or {}
	local crash = false
	local doparentheses = true

	if (#conds > 0) then
		for a,cond in ipairs(conds) do
			local newcond = {}
			local condname = cond[1]
			local condname_s = ""
			local params = cond[2]

			local prefix = string.sub(condname, 1, 4)

			if (prefix == "(not") then
				condname_s = string.sub(condname, 6)
				condname = string.sub(condname, 6)
			elseif (prefix == "not ") then
				condname_s = string.sub(condname, 5)
				condname = string.sub(condname, 5)
			else
				condname_s = condname
				condname = "not " .. condname
			end

			newcond[1] = condname
			newcond[2] = {}
			local valid = true

			if (#params > 0) then
				for m,n in ipairs(params) do
					if (condname_s ~= "feeling") then
						table.insert(newcond[2], n)
					else
						--MF_alert(n .. ", " .. tostring(target_) .. ", " .. cond[1] .. ", " .. condname .. ", " .. condname_s)
						if (target_ == nil) or (target_ ~= "not " .. n) then
							table.insert(newcond[2], n)
						elseif (cond[1] == "feeling") then
							crash = true
						end
					end
				end
			end

			if (#params > 0) and (#newcond[2] == 0) then
				valid = false
			end

			if valid then
				table.insert(newconds, newcond)
			end
		end
	else
		table.insert(newconds, {"never"})
		doparentheses = false
	end

	if doparentheses then
		for i,cond in ipairs(newconds) do
			if (i == 1) then
				cond[1] = "(" .. cond[1]
			end

			if (i == #newconds) then
				cond[1] = cond[1] .. ")"
			end
		end
	end

	return newconds,crash
end
