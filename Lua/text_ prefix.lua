-- This file adds the TEXT_ prefix and handles parsing.

-- Adds object to editor.
table.insert(editor_objlist_order,"text_text_")
editor_objlist["text_text_"] = {
  name = "text_text_",
  sprite_in_root = false,
  sprite = "text_textpre",
  unittype = "text",
  tags = {"text_special","abstract"},
  tiling = -1,
  type = 4,
  layer = 20,
  colour = {4, 0},
  colour_active = {4, 1},
}
formatobjlist()

-- Parsing + functionality.
function docode(firstwords)
	local donefirstwords = {}
	local existingfinals = {}
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
			local existing = unitdata[6] or {}
			local existing_wordid = unitdata[7] or 1
			local existing_id = unitdata[8] or ""

			if (string.sub(word, 1, 5) == "text_") then
				word = string.sub(word, 6)
			end

			local unit = mmf.newObject(unitid)
			local x,y = unit.values[XPOS],unit.values[YPOS]
			local tileid_id = x + y * roomsizex
			local unique_id = tostring(tileid_id) .. "_" .. existing_id

			--MF_alert("Testing " .. word .. ": " .. tostring(donefirstwords[unique_id]) .. ", " .. tostring(dir) .. ", " .. tostring(unitid) .. ", " .. tostring(unique_id))

			limiter = limiter + 1

			if (limiter > 5000) then
				MF_alert("Level destroyed - firstwords run too many times")
				destroylevel("toocomplex")
				return
			end

			--[[
			MF_alert("Current unique id: " .. tostring(unique_id))

			if (donefirstwords[unique_id] ~= nil) and (donefirstwords[unique_id][dir] ~= nil) then
				MF_alert("Already used: " .. tostring(unitid) .. ", " .. tostring(unique_id))
			end
			]]--

			if (donefirstwords[unique_id] == nil) or ((donefirstwords[unique_id] ~= nil) and (donefirstwords[unique_id][dir] == nil)) and (limiter < 5000) then
				local ox,oy = 0,0
				local name = word

				local drs = dirs[dir]
				ox = drs[1]
				oy = drs[2]

				if (donefirstwords[unique_id] == nil) then
					donefirstwords[unique_id] = {}
				end

				donefirstwords[unique_id][dir] = 1

				local sentences = {}
				local finals = {}
				local maxlen = 0
				local variations = 1
				local sent_ids = {}

				if (#existing == 0) then
					sentences,finals,maxlen,variations,sent_ids = calculatesentences(unitid,x,y,dir)
				else
					sentences[1] = existing
					maxlen = 3
					finals[1] = {}
					sent_ids = {existing_id}
				end

				if (sentences == nil) then
					return
				end

				--[[
				-- BIG DEBUG MESS
				if (variations > 0) then
					for i=1,variations do
						local dsent = ""
						local currsent = sentences[i]

						for a,b in ipairs(currsent) do
							dsent = dsent .. b[1] .. " "
						end

						MF_alert(tostring(k) .. ": Variant " .. tostring(i) .. ": " .. dsent)
					end
				end
				]]--

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

						local prefix = "" --How many "text_"s are being used.
						local tryasnoun = 0 --Which id we're going to use as type 0
						local gottagoback = false --True if we need to restart parsing

						local sent = sentences[i]
						local sent_id = sent_ids[i]

						local thissent = ""

						local j = 0
						for wordid=existing_wordid,#sent do
							j = j + 1

							local s = sent[wordid]
							local nexts = sent[wordid + 1] or {-1, -1, {-1}, 1}

							prevtiletype = currtiletype

							local tilename = s[1]
							local tiletype = s[2]
							local tileid = s[3][1]
							local tilewidth = s[4]

							local wordtile = false

							currtiletype = tiletype

							thissent = thissent .. tilename .. "," .. tostring(wordid) .. "  "

							for a,b in ipairs(s[3]) do
								table.insert(tileids, b)
							end

							--[[
								0 = objekti
								1 = verbi
								2 = quality
								3 = alkusana (LONELY)
								4 = Not/Text_
								5 = letter
								6 = And
								7 = ehtosana
								8 = customobject
							]]--

							if tiletype == 4 and tilename == "text_" and tryasnoun ~= wordid then --text_ logic starts here
								if tryasnoun == 0 then --If this is the first
									if wordid + 1 <= #sent then
										if (not stage2reached) then --False after infix conditions and verbs
											local phase = 0
											for fwordid=wordid + 1,#sent do --Now we start looking into the future
												if (sent[fwordid][2] ~= 4 or sent[fwordid][1] ~= "text_") or (phase == 1) then --If this isn't a text_, unless we already encountered a noun.
													if phase == 0 then --Move onto next phase if this is the first time
														phase = 1
													elseif (sent[fwordid][2] ~= 1 and sent[fwordid][2] ~= 6 and sent[fwordid][2] ~= 7 and sent[fwordid][2] ~= 4) then --Checks if this won't parse
														phase = 0
														break
													elseif sent[fwordid][2] ~= 4 then --stop if we know it will parse
														prefix = "text_" .. prefix
														phase = 0
														break
													end
												elseif phase == 0 then --If we ran into a text_ first, we're gonna try it as a noun
													tryasnoun = fwordid
												end
											end
											if phase == 1 then
												prefix = "text_" .. prefix
											elseif tryasnoun ~= 0 and prefix == "" then
												phase = 0
												for fwordid=wordid + 1,#sent do
													if (sent[fwordid][2] ~= 4 or sent[fwordid][1] ~= "text_") or (phase == 1 and sent[fwordid][1] == "text_") or (tryasnoun == fwordid) then
														if phase == 0 then
															phase = 1
														elseif (sent[fwordid][2] ~= 1 and sent[fwordid][2] ~= 6 and sent[fwordid][2] ~= 7) then
															tiletype = 9
															break
														else
															prefix = "text_" .. prefix
															break
														end
													end
												end
											else
												if prefix == "" then
													tiletype = 9
												end
												tryasnoun = 0
											end
										end

										if (stage == 3 or stage2reached) then
											for fwordid=wordid + 1,#sent do
												if (sent[fwordid][2] ~= 4 or sent[fwordid][1] ~= "text_") then
													gottagoback = true
													prefix = "text_" .. prefix
													break
												elseif fwordid == #sent then
													prefix = "text_" .. prefix
													tryasnoun = fwordid
													break
												end
											end
										end
									end
								else
									prefix = "text_" .. prefix --stack
								end
							elseif prefix ~= "" then --Parse this word as a noun
								tiletype = 0
								currtiletype = 0
								tryasnoun = 0
								if objectlist[prefix .. tilename] == nil and objectpalette[prefix .. tilename] ~= nil then
									objectlist[prefix .. tilename] = 1
								end
								prefix = ""
							end
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
										elseif (tiletype == 7) and (stage2reached == false) and (nocondsafterthis == false) and ((doingcond == false) or (prevstage ~= 4)) then
											doingcond = true
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
										elseif (tiletype == 7) and (nocondsafterthis == false) and ((prevtiletype ~= 6) or ((prevtiletype == 6) and doingcond)) then
											doingcond = true
											stage2reached = true
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
								if (#notids == 0) or (prevtiletype == 0) then
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

							if (prevtiletype ~= 4) and (wordid > existing_wordid) then
								prevsafewordid = wordid - 1
								prevsafewordtype = prevtiletype
							end

							--MF_alert(tilename .. ", " .. tostring(wordid) .. ", " .. tostring(stage) .. ", " .. tostring(#sent) .. ", " .. tostring(tiletype) .. ", " .. tostring(prevtiletype) .. ", " .. tostring(stop) .. ", " .. name .. ", " .. tostring(i))

							--MF_alert(tostring(k) .. "_" .. tostring(i) .. "_" .. tostring(wordid) .. ": " .. tilename .. ", " .. tostring(tiletype) .. ", " .. tostring(stop) .. ", " .. tostring(stage) .. ", " .. tostring(letterword_firstid).. ", " .. tostring(prevtiletype))

							if (stop == false) then
								local subsent_id = string.sub(sent_id, (wordid - existing_wordid)+1)
								current.sent = sent
								table.insert(current, {tilename, tiletype, tileids, tilewidth, wordid, subsent_id})
								tileids = {}

								if (wordid == #sent) and (#current >= 3) and (j > 1) then
									subsent_id = tostring(tileid_id) .. "_" .. string.sub(sent_id, 1, j) .. "_" .. tostring(dir)
									--MF_alert("Checking finals: " .. subsent_id .. ", " .. tostring(existingfinals[subsent_id]))
									if (existingfinals[subsent_id] == nil) then
										existingfinals[subsent_id] = 1
									else
										finals[i] = {}
									end
								end
							else
								for a=1,#s[3] do
									if (#tileids > 0) then
										table.remove(tileids, #tileids)
									end
								end

								if (tiletype == 0) and (prevtiletype == 0) and (#notids > 0) and not gottagoback then
									notids = {}
									notwidth = 0
								end

								if (#current >= 3) and (j > 1) then
									local subsent_id = tostring(tileid_id) .. "_" .. string.sub(sent_id, 1, j-1) .. "_" .. tostring(dir)
									--MF_alert("Checking finals: " .. subsent_id .. ", " .. tostring(existingfinals[subsent_id]))
									if (existingfinals[subsent_id] == nil) then
										existingfinals[subsent_id] = 1
									else
										finals[i] = {}
									end
								end

								if (wordid < #sent) then
									if (wordid > existing_wordid) then
										if (#notids > 0) and firstrealword and (notslot > 1) and ((tiletype ~= 7) or ((tiletype == 7) and (prevtiletype == 0))) and ((tiletype ~= 1) or ((tiletype == 1) and (prevtiletype == 0))) then
											-- MF_alert(tostring(notslot) .. ", not -> A, " .. unique_id .. ", " .. sent_id)
											local subsent_id = string.sub(sent_id, (notslot - existing_wordid)+1)
											table.insert(firstwords, {notids, dir, notwidth, "not", 4, sent, notslot, subsent_id})

											if (nexts[2] ~= nil) and ((nexts[2] == 0) or (nexts[2] == 3) or (nexts[2] == 4)) and (tiletype ~= 3) then
												-- MF_alert(tostring(wordid) .. ", " .. tilename .. " -> B, " .. unique_id .. ", " .. sent_id)
												subsent_id = string.sub(sent_id, j)
												table.insert(firstwords, {s[3], dir, tilewidth, tilename, tiletype, sent, wordid, subsent_id})
											end
										else
											if (prevtiletype == 0) and ((tiletype == 1) or (tiletype == 7)) then
												-- MF_alert(tostring(wordid-1) .. ", " .. sent[wordid - 1][1] .. " -> C, " .. unique_id .. ", " .. sent_id)
												local subsent_id = string.sub(sent_id, wordid - existing_wordid)
												table.insert(firstwords, {sent[wordid - 1][3], dir, tilewidth, tilename, tiletype, sent, wordid-1, subsent_id})
											elseif (prevsafewordtype == 0) and (prevsafewordid > 0) and (prevtiletype == 4) and (tiletype ~= 1) and (tiletype ~= 2) then
												-- MF_alert(tostring(prevsafewordid) .. ", " .. sent[prevsafewordid][1] .. " -> D, " .. unique_id .. ", " .. sent_id)
												local subsent_id = string.sub(sent_id, (prevsafewordid - existing_wordid)+1)
												table.insert(firstwords, {sent[prevsafewordid][3], dir, tilewidth, tilename, tiletype, sent, prevsafewordid, subsent_id})
											else
												-- MF_alert(tostring(wordid) .. ", " .. tilename .. " -> E, " .. unique_id .. ", " .. sent_id)
												local subsent_id = string.sub(sent_id, j)
												table.insert(firstwords, {s[3], dir, tilewidth, tilename, tiletype, sent, wordid, subsent_id})
											end
										end

										break
									elseif (wordid == existing_wordid) then
										if (nexts[3][1] ~= -1) then
											-- MF_alert(tostring(wordid+1) .. ", " .. nexts[1] .. " -> F, " .. unique_id .. ", " .. sent_id)
											local subsent_id = string.sub(sent_id, j+1)
											table.insert(firstwords, {nexts[3], dir, nexts[4], nexts[1], nexts[2], sent, wordid+1, subsent_id})
										end

										break
									end
								elseif gottagoback then
									gottagoback = false
									-- MF_alert(tostring(notslot) .. ", not -> A, " .. unique_id .. ", " .. sent_id)
									local subsent_id = string.sub(sent_id, (notslot - existing_wordid)+1)
									if notids[1] ~= nil then
										table.insert(firstwords, {notids, dir, notwidth, "text_", 4, sent, notslot, subsent_id})
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

						if (#sentence >= 3) then
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
						else
							valid = false
						end

						if valid then
							for index,wdata in ipairs(sentence) do
								local wname = wdata[1]
								local wtype = wdata[2]
								local wid = wdata[3]

								testing = testing .. wname .. " "

								local wcategory = -1

								if (wtype == 1) or (wtype == 3) or (wtype == 7) then
									wcategory = 1
								elseif (wtype ~= 4) and (wtype ~= 6) then
									wcategory = 0
								else
									table.insert(extraids_ifvalid, {prefix .. wname, wtype, wid})
									extraids_current = wname
									if wname == "text_" then
										extraids_current = "text_butnoun"
									end
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
										local sent = sentence.sent
										local wordid = wdata[5]
										local subsent_id = wdata[6]
										table.insert(firstwords, {{wid[1]}, dir, 1, wname, wtype, sent, wordid, subsent_id})
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
									if (wname == "text_") then
										prefix = prefix .. "text_"
									else
										if (prefix == "not ") then
											prefix = ""
										else
											prefix = "not "
										end
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

							if generaldata.flags[LOGGING] then
								rulelog(sentence, testing)
							end

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
--[[ Hempuli implemented a wonderful new system that makes rule parsing more efficient...
but that means every rule needs to have a noun. Modifies this to detect the prefix and claim there's a noun.]]--
function calculatesentences(unitid,x,y,dir)
	local drs = dirs[dir]
	local ox,oy = drs[1],drs[2]

	local finals = {}
	local sentences = {}
	local sentence_ids = {}

	local sents = {}
	local done = false
	local verbfound = false
	local objfound = false
	local starting = true

	local step = 0
	local rstep = 0
	local combo = {}
	local variantshere = {}
	local totalvariants = 1
	local maxpos = 0

	local limiter = 5000

	local combospots = {}

	local unit = mmf.newObject(unitid)

	local done = false
	while (done == false) and (totalvariants < limiter) do
		local words,letters,jletters = codecheck(unitid,ox*rstep,oy*rstep,dir,true,(step~=0))

		--MF_alert(tostring(unitid) .. ", " .. unit.strings[UNITNAME] .. ", " .. tostring(#words))

		step = step + 1
		rstep = rstep + 1

		if (totalvariants >= limiter) then
			MF_alert("Level destroyed - too many variants A")
			destroylevel("toocomplex")
			return nil
		end

		if (totalvariants < limiter) then
			if (#words > 0) then
				sents[step] = {}

				for i,v in ipairs(words) do
					--unitids, width, word, wtype, dir

					--MF_alert("Step " .. tostring(step) .. ", word " .. v[3] .. " here")

					if (v[4] == 1) then
						verbfound = true
					end

					if (v[4] == 0) or (v[4] == 4 and v[3] == "text_") then
						objfound = true
					end

					if starting and ((v[4] == 0) or (v[4] == 3) or (v[4] == 4)) then
						starting = false
					end

					table.insert(sents[step], v)
				end

				if starting then
					sents[step] = nil
					step = step - 1
				else
					totalvariants = totalvariants * #words
					variantshere[step] = #words
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
				end
			else
				--MF_alert("Step " .. tostring(step) .. ", no words here, " .. tostring(letters) .. ", " .. tostring(jletters))

				if jletters then
					variantshere[step] = 0
					sents[step] = {}
					combo[step] = 0

					if starting then
						sents[step] = nil
						step = step - 1
					end
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

	if (verbfound == false) or (step < 3) or (objfound == false) then
		return {},{},0,0,{}
	end

	maxpos = step

	local combostep = 0

	for i=1,totalvariants do
		step = 1
		sentences[i] = {}
		sentence_ids[i] = ""

		while (step < maxpos) do
			local c = combo[step]

			if (c ~= nil) then
				if (c > 0) then
					local s = sents[step]
					local word = s[c]

					local w = word[2]

					--MF_alert(tostring(i) .. ", step " .. tostring(step) .. ": " .. word[3] .. ", " .. tostring(#word[1]) .. ", " .. tostring(w))

					table.insert(sentences[i], {word[3], word[4], word[1], word[2]})
					sentence_ids[i] = sentence_ids[i] .. tostring(c - 1)

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

	return sentences,finals,maxpos,totalvariants,sentence_ids
end
