-- This is an optional file that adds two new objects. It is not needed for the mod to work.

-- Adds object to editor.
table.insert(editor_objlist_order,"text_meta")
table.insert(editor_objlist_order,"text_unmeta")
table.insert(editor_objlist_order,"text_meta-1")
table.insert(editor_objlist_order,"text_meta0")
table.insert(editor_objlist_order,"text_meta1")
table.insert(editor_objlist_order,"text_meta2")
table.insert(editor_objlist_order,"text_meta3")
editor_objlist["text_meta"] = {
  name = "text_meta",
  sprite_in_root = false,
  unittype = "text",
  tags = {"text_quality","text_special"},
  tiling = -1,
  type = 2,
  layer = 20,
  colour = {4, 0},
  colour_active = {4, 1},
}
editor_objlist["text_unmeta"] = {
  name = "text_unmeta",
  sprite_in_root = false,
  unittype = "text",
  tags = {"text_quality","text_special"},
  tiling = -1,
  type = 2,
  layer = 20,
  colour = {3, 0},
  colour_active = {3, 1},
}
editor_objlist["text_meta-1"] = {
  name = "text_meta-1",
  sprite_in_root = false,
  unittype = "text",
  tags = {"text_special","abstract"},
  tiling = -1,
  type = 0,
  layer = 20,
  colour = {4, 1},
  colour_active = {4, 2},
}
editor_objlist["text_meta0"] = {
  name = "text_meta0",
  sprite_in_root = false,
  unittype = "text",
  tags = {"text_special","abstract"},
  tiling = -1,
  type = 0,
  layer = 20,
  colour = {3, 0},
  colour_active = {3, 1},
}
editor_objlist["text_meta1"] = {
  name = "text_meta1",
  sprite_in_root = false,
  unittype = "text",
  tags = {"text_special","abstract"},
  tiling = -1,
  type = 0,
  layer = 20,
  colour = {3, 0},
  colour_active = {3, 1},
}
editor_objlist["text_meta2"] = {
  name = "text_meta2",
  sprite_in_root = false,
  unittype = "text",
  tags = {"text_special","abstract"},
  tiling = -1,
  type = 0,
  layer = 20,
  colour = {3, 0},
  colour_active = {3, 1},
}
editor_objlist["text_meta3"] = {
  name = "text_meta3",
  sprite_in_root = false,
  unittype = "text",
  tags = {"text_special","abstract"},
  tiling = -1,
  type = 0,
  layer = 20,
  colour = {3, 0},
  colour_active = {3, 1},
}
formatobjlist()

-- Disables if X IS X, like REVERT.
function postrules(alreadyrun_)
	local protects = {}
	local newruleids = {}
	local ruleeffectlimiter = {}
	local playrulesound = false
	local alreadyrun = alreadyrun_ or false

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

			local newconds = {{"never",{}}}

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

						if (targetrule[1] == target) and (((targetrule[2] == "is") and (target ~= object)) or (targetrule[2] == "write")) and ((getmat(object) ~= nil) or (object == "revert") or (targetrule[2] == "write") or (object == "meta")  or (object == "unmeta")) and (string.sub(object, 1, 5) ~= "group") then
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

	if (spritedata.values[VISION] == 0) then
		ruleblockeffect()
	end

	return playrulesound
end

-- Implementation.
function conversion(dolevels_)
	local alreadydone = {}
	local dolevels = dolevels_ or false

	for i,v in pairs(features) do
		local words = v[1]

		local operator = words[2]

		if (operator == "is") or (operator == "write") or (operator == "become") then
			local output = {}
			local name = words[1]
			local thing = words[3]

			if (not dolevels) and (operator == "is" or operator == "become") and name ~= "text" and (string.sub(name,1,4)) ~= "meta" and ((thing ~= "not " .. name) and (thing ~= "all") and (thing ~= "text") and (thing ~= "revert") and (thing ~= "meta") and (thing ~= "unmeta")) and unitreference[thing] == nil and string.sub(thing,1,5) == "text_" and ((unitlists[name] ~= nil and #unitlists[name] > 0) or name == "empty" or name == "level") then
				tryautogenerate(thing)
			elseif (not dolevels) and operator == "write" and name ~= "text" and (string.sub(name,1,4)) ~= "meta" and (thing ~= "not " .. name) and unitreference["text_" .. thing] == nil and string.sub(thing,1,5) == "text_" and ((unitlists[name] ~= nil and #unitlists[name] > 0) or name == "empty" or name == "level") then
				tryautogenerate("text_" .. thing)
			end
			if (name ~= "text") and (string.sub(name,1,4) ~= "meta") and ((getmat(thing) ~= nil) or (thing == "not " .. name) or (thing == "all") or (unitreference[thing] ~= nil) or ((thing == "text") and (unitreference["text_text"] ~= nil)) or (thing == "revert") or (thing == "meta") or (thing == "unmeta") or ((string.sub(thing,1,4) == "meta") and (unitreference["text_" .. thing] ~= nil)) or ((operator == "write") and getmat_text("text_" .. name))) then
				if (featureindex[name] ~= nil) and (alreadydone[name] == nil) then
					alreadydone[name] = 1

					for a,b in ipairs(featureindex[name]) do
						local rule = b[1]
						local conds = b[2]
						local target,verb,object = rule[1],rule[2],rule[3]

						if (verb == "is") or (verb == "become") then
							if (target == name) and (object ~= "word") and ((object ~= name) or (verb == "become")) then
								if (object ~= "text") and (object ~= "revert") and (object ~= "meta") and (object ~= "unmeta") and (string.sub(object,1,4) ~= "meta") then
									if (object == "not " .. name) then
										table.insert(output, {"error", conds, "is"})
									else
										for d,mat in pairs(objectlist) do
											if (string.sub(d, 1, 5) ~= "group") and (d == object) then
												table.insert(output, {object, conds, "is"})
											end
										end
									end
								elseif (name ~= object) or (verb == "become") then
									if (object ~= "revert") and (object ~= "meta") and (object ~= "unmeta") then
										table.insert(output, {object, conds, "is"})
									else
										table.insert(output, 1, {object, conds, "is"})
									end
								end
							end
						elseif (verb == "write") then
							if (string.sub(object, 1, 4) ~= "not ") and (target == name) then
								table.insert(output, {object, conds, "write"})
							end
						end
					end
				end

				if (#output > 0) then
					local conversions = {}

					for k,v3 in pairs(output) do
						local object = v3[1]
						local conds = v3[2]
						local op = v3[3]

						if (op == "is") then
							if (findnoun(object,nlist.brief) == false) and (object ~= "word") and (object ~= "text") and (object ~= "meta") and (object ~= "unmeta") then
								table.insert(conversions, v3)
							elseif (object == "all") then
								--[[
								addaction(0,{"createall",{name,conds},dolevels})
								createall({name,conds})
								]]--
								table.insert(conversions, {"createall",conds})
							elseif (object == "text") or (object == "meta") then
								local valid = true -- don't attempt conversion if the object does not exist
								if string.sub(name,1,5) == "text_" and unitreference["text_" .. name] == nil and unitreference[name] ~= nil and unitlists[name] ~= nil and #unitlists[name] > 0 then
									valid = tryautogenerate("text_" .. name,name)
								end
								if valid then
									table.insert(conversions, {"text_" .. name,conds})
								end
							elseif (object == "unmeta") and string.sub(name,1,5) == "text_" then
								local valid = true -- don't attempt conversion if the object does not exist
								if string.sub(name,6,10) == "text_" and unitreference[string.sub(name,6)] == nil and unitreference[name] ~= nil and unitlists[name] ~= nil and #unitlists[name] > 0 then
									valid = tryautogenerate(string.sub(name,6))
								end
								if valid then
									table.insert(conversions, {string.sub(name,6),conds})
								end
							elseif (string.sub(object,1,4) == "meta") then
								local level = string.sub(object,5)
								if tonumber(level) ~= nil and tonumber(level) >= -1 then
									local basename,_ = string.gsub(name,"text_","")
									if basename == "" then
										basename = "text_"
									end
									local newname = string.rep("text_",level + 1) .. basename
									local valid = true -- don't attempt conversion the if object does not exist
									if tonumber(level) >= 0 and unitreference[newname] == nil and ((unitreference[name] ~= nil and unitlists[name] ~= nil and #unitlists[name] > 0) or name == "empty" or name == "level") then
										if string.sub(newname,1,5) == "text_" then
											valid = tryautogenerate(newname)
										else
											valid = false
										end
									end
									if valid then
										table.insert(conversions, {newname,conds})
									end
								end
							end
						elseif (op == "write") then
							table.insert(conversions, v3)
						end
					end

					if (#conversions > 0) then
						convert(name,conversions,dolevels)
					end
				end
			end
		end
	end
end
