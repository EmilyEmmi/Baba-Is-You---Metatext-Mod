-- Remove lines that change name to "text"
function findtype(typedata,x,y,unitid_)
	local result = {}
	local unitid = 0
	local tileid = x + y * roomsizex
	local name = typedata[1]
	local conds = typedata[2]

	if (unitid_ ~= nil) then
		unitid = unitid_
	end

	if (unitmap[tileid] ~= nil) then
		for i,v in ipairs(unitmap[tileid]) do
			if (v ~= unitid) then
				local unit = mmf.newObject(v)

				if (unit.strings[UNITNAME] == name) then
					if testcond(conds,v) then
						table.insert(result, v)
					end
				end
			end
		end
	end

	return result
end

-- Fix TEXT MIMIC X.
function getmat(m,checkallunit)
	local found = false
	if checkallunit then
		for i,v in pairs(fullunitlist) do
			if (i == m) then
				found = true
			end
		end
	else
		for i,v in pairs(objectlist) do
			if (i == m) then
				found = true
			end
		end
	end

	if found then
		return m
	else
		return nil
	end
end

-- Make WRITE work with text.
function getmat_text(name)
	if string.sub(name,1,10) == "text_text_" then
		return true
	end
	local base = unitreference[name]
	local changed = objectpalette[name]

	if (generaldata.strings[WORLD] ~= generaldata.strings[BASEWORLD]) then
		return (changed ~= nil)
	else
		return (base ~= nil)
	end

	return false
end

-- Prevent text from being called "text", and also handles parameters
function getname(unit,pname_,pnot_)
	local result = unit.strings[UNITNAME]
	local pname = pname_ or ""
	local pnot = pnot_ or false
	if type(pname) ~= "string" then
		--Guys I fixed the bug that keeps getting reported
		pname = ""
	end

	if (unit.strings[UNITTYPE] == "text") and (string.sub(result, 1, 5) ~= "text_") then
		result = "text_" .. result -- Makes mesatext not refer to itself. There are probably other oddities though
	elseif (unit.strings[UNITTYPE] == "text") and ((pname == "text") or (pnot == true)) and (string.sub(pname,1,4) ~= "meta") and (string.sub(pname,1,5) ~= "text_") then
		result = "text"
	elseif (unit.strings[UNITTYPE] ~= "text") and (string.sub(pname,1,5) == "text_") and (pnot == true) then
		result = "text"
	elseif string.sub(pname,1,4) == "meta" then
		if metatext_includenoun or unit.strings[UNITTYPE] == "text" then
			local include = false
			local level = string.sub(pname,5)
			if tonumber(level) ~= nil and tonumber(level) >= -1 then
				local metalevel = getmetalevel(result)
				if metalevel == tonumber(level) then
					include = true
				end
			end
			if include == pnot then
				result = "text"
			elseif not pnot then
				result = pname
			end
		else
			result = "text"
		end
	end

	return result
end

--Fixes TEXT HAS TEXT and NOT METATEXT HAS TEXT, and implements HAS META#.
function inside(name,x,y,dir_,unitid,leveldata_)
	local ins = {}
	local tileid = x + y * roomsizex
	local maptile = unitmap[tileid] or {}
	local dir = dir_

	local leveldata = leveldata_ or {}

	if (dir == 4) then
		dir = fixedrandom(0,3)
	end

	if (featureindex[name] ~= nil) then
		for i,rule in ipairs(featureindex[name]) do
			local baserule = rule[1]
			local conds = rule[2]

			local target = baserule[1]
			local verb = baserule[2]
			local object = baserule[3]

			if (target == name) and (verb == "has") then
				table.insert(ins, {object,conds})
			end
		end
	end

	if (#ins > 0) then
		for i,v in ipairs(ins) do
			local object = v[1]
			local conds = v[2]
			if testcond(conds,unitid,x,y) then
				if (object == "text") then
					object = "text_" .. name
				elseif string.sub(object,1,4) == "meta" then
					local level = string.sub(object,5)
					if tonumber(level) ~= nil and tonumber(level) >= -1 then
						local basename,_ = string.gsub(name,"text_","")
						if basename == "" then
							basename = "text_"
						end
						object = string.rep("text_",level + 1) .. basename
						if findnoun(object,nlist.short,true) ~= false then
							object = "_NONE_"
						end
					else
						object = "_NONE_"
					end
				end
				local did = false -- changes start here
				for a,mat in pairs(fullunitlist) do -- main change
					if (a == object) and (object ~= "empty") then
						if (object ~= "all") and (string.sub(object, 1, 5) ~= "group") then
							if unitreference[object] ~= nil then
								create(object,x,y,dir,nil,nil,nil,nil,leveldata)
								did = true
							end
						elseif (object == "all") then
							createall(v,x,y,unitid,nil,leveldata)
							did = true
						end
					end
				end
				if not did and string.sub(object,1,5) == "text_" then
					did = tryautogenerate(nil,object)
					if did then
						create(object,x,y,dir,nil,nil,nil,nil,leveldata)
					end
				end
			end
		end
	end
end

-- Makes sure text units and meta# are considered special nouns
function findnoun(noun,list_,ignoretext)
	local list = list_ or nlist.full

	for i,v in ipairs(list) do
		if (v == noun) or ((v == "group") and (string.sub(noun, 1, 5) == "group")) or (string.sub(noun,1,5) == "text_" and v == "text" and ignoretext ~= true) or (string.sub(noun,1,4) == "meta" and v == "all") then
			return true
		end
	end

	return false
end

-- Removes units from "meta#" unitlist when deleted.
function delunit(unitid)
	local unit = mmf.newObject(unitid)

	if (unit ~= nil) then
		local name = getname(unit, "text")
		local x,y = unit.values[XPOS],unit.values[YPOS]
		local unitlist = unitlists[name]
		local unitlist_ = unitlists[unit.strings[UNITNAME]] or {}
		local unittype = unit.strings[UNITTYPE]

		if (unittype == "text") then
			updatecode = 1
		end

		x = math.floor(x)
		y = math.floor(y)

		if (unitlist ~= nil) then
			for i,v in pairs(unitlist) do
				if (v == unitid) then
					v = {}
					table.remove(unitlist, i)
				end
			end
		end

		if (unitlist_ ~= nil) then
			for i,v in pairs(unitlist_) do
				if (v == unitid) then
					v = {}
					table.remove(unitlist_, i)
					break
				end
			end
		end

		-- This is the added part
		local level = getmetalevel(unit.strings[UNITNAME])
		if level >= -1 then
			local munitlist = unitlists["meta" .. level]
			if (munitlist ~= nil) then
				for i,v in pairs(munitlist) do
					if (v == unitid) then
						v = {}
						table.remove(munitlist, i)
					end
				end
			end
		end

		-- TÄMÄ EI EHKÄ TOIMI
		local tileid = x + y * roomsizex

		if (unitmap[tileid] ~= nil) then
			for i,v in pairs(unitmap[tileid]) do
				if (v == unitid) then
					v = {}
					table.remove(unitmap[tileid], i)
				end
			end

			if (#unitmap[tileid] == 0) then
				unitmap[tileid] = nil
			end
		end

		if (unittypeshere[tileid] ~= nil) then
			local uth = unittypeshere[tileid]

			local n = unit.strings[UNITNAME]

			if (uth[n] ~= nil) then
				uth[n] = uth[n] - 1

				if (uth[n] == 0) then
					uth[n] = nil
				end
			end
		end

		if (unit.strings[UNITTYPE] == "text") and (codeunits ~= nil) then
			for i,v in pairs(codeunits) do
				if (v == unitid) then
					v = {}
					table.remove(codeunits, i)
				end
			end

			if (unit.values[TYPE] == 5) then
				for i,v in pairs(letterunits) do
					if (v == unitid) then
						v = {}
						table.remove(letterunits, i)
					end
				end
			end
		end

		if (unit.values[TILING] > 1) and (animunits ~= nil) then
			for i,v in pairs(animunits) do
				if (v == unitid) then
					v = {}
					table.remove(animunits, i)
				end
			end
		end

		if (unit.values[TILING] == 1) and (tiledunits ~= nil) then
			for i,v in pairs(tiledunits) do
				if (v == unitid) then
					v = {}
					table.remove(tiledunits, i)
				end
			end
		end

		if (#wordunits > 0) and (unit.values[TYPE] == 0) and (unit.strings[UNITTYPE] ~= "text") then
			for i,v in pairs(wordunits) do
				if (v[1] == unitid) then
					local currentundo = undobuffer[1]
					table.insert(currentundo.wordunits, unit.values[ID])
					updatecode = 1
					v = {}
					table.remove(wordunits, i)
				end
			end
		end

		if (#wordrelatedunits > 0) then
			for i,v in pairs(wordrelatedunits) do
				if (v[1] == unitid) then
					local currentundo = undobuffer[1]
					table.insert(currentundo.wordrelatedunits, unit.values[ID])
					updatecode = 1
					v = {}
					table.remove(wordrelatedunits, i)
				end
			end
		end

		if (#visiontargets > 0) then
			for i,v in pairs(visiontargets) do
				if (v == unitid) then
					local currentundo = undobuffer[1]
					table.insert(currentundo.visiontargets, unit.values[ID])
					v = {}
					table.remove(visiontargets, i)
				end
			end
		end
	else
		MF_alert("delunit(): no object found with id " .. tostring(unitid))
	end

	for i,v in ipairs(units) do
		if (v.fixed == unitid) then
			v = {}
			table.remove(units, i)
		end
	end

	for i,data in pairs(updatelist) do
		if (data[1] == unitid) and (data[2] ~= "convert") then
			data[2] = "DELETED"
		end
	end
end

-- Adds option to exclude group rules made by "TEXT" or "META#" noun. It's used in conditions.lua.
function findgroup(grouptype_,invert_,limit_,checkedconds_,notextnoun_)
	local result = {}
	local limit = limit_ or 0
	local invert = invert_ or false
	local grouptype = grouptype_ or "group"
	local notextnoun = notextnoun_ or false
	local found = {}
	local alreadyused = {}

	limit = limit + 1

	local idstring = ""
	local currmembers = {}
	local handlerecursion = false

	for i,v in ipairs(groupmembers) do
		local name = v[1]
		local conds = v[2]
		local gtype = v[3]
		local recursion = v[4]
		local tags = v[5]
		local foundtag = false
		if notextnoun then
			for num,tag in pairs(tags) do
				if tag == "text" or string.sub(tag,1,4) == "meta" then
					foundtag = true
					break
				end
			end
		elseif name == "text" or string.sub(name,1,4) == "meta" then
			foundtag = true
		end

		if (gtype == grouptype) and foundtag == false then
			if hasconds(v) and (unitlists[name] ~= nil) then
				if (recursion == false) then
					for a,b in ipairs(unitlists[name]) do
						local unit = mmf.newObject(b)
						local x,y = unit.values[XPOS],unit.values[YPOS]

						if testcond(conds,b,x,y,nil,limit,checkedconds_) then
							table.insert(result, name)
							table.insert(currmembers, name)
							found[name] = 1
							idstring = idstring .. name
							break
						end
					end
				else
					handlerecursion = true
				end
			elseif (hasconds(v) == false) then
				table.insert(result, name)
				table.insert(currmembers, name)
				found[name] = 1
				idstring = idstring .. name
			end
		end
	end

	local reclimit = 0
	local curridstring = idstring

	while handlerecursion and (reclimit < 10) do
		local newidstring = idstring
		local newmembers = {}
		for i,v in ipairs(result) do
			table.insert(newmembers, v)
		end

		for i,v in ipairs(groupmembers) do
			local name = v[1]
			local conds = v[2]
			local gtype = v[3]
			local recursion = v[4]

			if recursion and (gtype == grouptype) then
				if hasconds(v) and (unitlists[name] ~= nil) then
					for a,b in ipairs(unitlists[name]) do
						local unit = mmf.newObject(b)
						local x,y = unit.values[XPOS],unit.values[YPOS]

						if testcond(conds,b,x,y,nil,limit,checkedconds_,nil,currmembers) then
							table.insert(newmembers, name)
							newidstring = newidstring .. name
							break
						end
					end
				elseif (hasconds(v) == false) then
					table.insert(newmembers, name)
					newidstring = newidstring .. name
				end
			end
		end

		--MF_alert(curridstring .. ", " .. newidstring)

		if (newidstring ~= curridstring) then
			currmembers = {}
			for i,v in ipairs(newmembers) do
				table.insert(currmembers, v)
			end
			curridstring = newidstring
			reclimit = reclimit + 1
		else
			for i,v in ipairs(currmembers) do
				found[v] = 1
				idstring = idstring .. v
				table.insert(result, v)
			end

			handlerecursion = false
		end
	end

	if (reclimit >= 10) then
		HACK_INFINITY = 200
		destroylevel("infinity")
		return
	end

	if invert then
		local actualresult = {}

		for a,mat in pairs(objectlist) do
			if (found[a] == nil) and (alreadyused[a] == nil) and (findnoun(a,nlist.short) == false) then
				table.insert(actualresult, a)
				alreadyused[a] = 1
			end
		end

		return actualresult
	end

	return result
end
