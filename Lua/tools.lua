-- All: Remove lines that change name to "text"
function issolid(unitid)
	local unit = mmf.newObject(unitid)
	local name = unit.strings[UNITNAME]

	--[[ Remove to support metatext
	if (unit.strings[UNITTYPE] == "text") then
		name = "text"
	end]]--

	local ispush = hasfeature(name,"is","push",unitid)
	local ispull = hasfeature(name,"is","pull",unitid)
	local ismove = hasfeature(name,"is","move",unitid)
	local isyou = hasfeature(name,"is","you",unitid) or hasfeature(name,"is","you2",unitid) or hasfeature(name,"is","3d",unitid)

	if (ispush ~= nil) or (ispull ~= nil) or (ismove ~= nil) or (isyou ~= nil) then
		return true
	end

	return false
end
function isgone(unitid)
	if (issafe(unitid) == false) then
		local unit = mmf.newObject(unitid)
		local x,y,name = unit.values[XPOS],unit.values[YPOS],unit.strings[UNITNAME]

		--[[ Remove to support metatext
		if (unit.strings[UNITTYPE] == "text") then
			name = "text"
		end]]--

		local isyou = hasfeature(name,"is","you",unitid,x,y) or hasfeature(name,"is","you2",unitid,x,y) or hasfeature(name,"is","3d",unitid,x,y)
		local ismelt = hasfeature(name,"is","melt",unitid,x,y)
		local isweak = hasfeature(name,"is","weak",unitid,x,y)
		local isshut = hasfeature(name,"is","shut",unitid,x,y)
		local isopen = hasfeature(name,"is","open",unitid,x,y)
		local ismove = hasfeature(name,"is","move",unitid,x,y)
		local ispush = hasfeature(name,"is","push",unitid,x,y)
		local ispull = hasfeature(name,"is","pull",unitid,x,y)
		local eat = findfeatureat(nil,"eat",name,x,y)

		if (eat ~= nil) then
			for i,v in ipairs(eat) do
				if (v ~= unitid) then
					return true
				end
			end
		end

		local issink = findfeatureat(nil,"is","sink",x,y)

		if (issink ~= nil) then
			for i,v in ipairs(issink) do
				if (v ~= unitid) and floating(v,unitid,x,y) then
					return true
				end
			end
		end

		if (isyou ~= nil) then
			local isdefeat = findfeatureat(nil,"is","defeat",x,y)

			if (isdefeat ~= nil) then
				for i,v in ipairs(isdefeat) do
					if floating(v,unitid,x,y) then
						return true
					end
				end
			end
		end

		if (ismelt ~= nil) then
			local ishot = findfeatureat(nil,"is","hot",x,y)

			if (ishot ~= nil) then
				for i,v in ipairs(ishot) do
					if floating(v,unitid,x,y) then
						return true
					end
				end
			end
		end

		if (isshut ~= nil) then
			local isopen_ = findfeatureat(nil,"is","open",x,y)

			if (isopen_ ~= nil) then
				for i,v in ipairs(isopen_) do
					if floating(v,unitid,x,y) then
						return true
					end
				end
			end
		end

		if (isopen ~= nil) then
			local isshut_ = findfeatureat(nil,"is","shut",x,y)

			if (isshut_ ~= nil) then
				for i,v in ipairs(isshut_) do
					if floating(v,unitid,x,y) then
						return true
					end
				end
			end
		end

		if (isweak ~= nil) then
			local things = findallhere(x,y)

			if (things ~= nil) then
				for i,v in ipairs(things) do
					if (v ~= unitid) and floating(v,unitid,x,y) then
						return true
					end
				end
			end
		end
	end

	return false
end
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

-- Prevent text from being called "text", except in some parameter cases
function getname(unit,pname_,pnot_)
	local result = unit.strings[UNITNAME]
	local pname = pname_ or ""
	local pnot = pnot_ or ""

	if (unit.strings[UNITTYPE] == "text") and (string.sub(result, 1, 5) ~= "text_") then
		result = "text_" .. result
	end
	if (unit.strings[UNITTYPE] == "text") and ((pname == "text") or (pnot == true)) and (string.sub(pname,1,5) ~= "text_") then
		result = "text"
	end
	if (unit.strings[UNITTYPE] ~= "text") and (string.sub(pname,1,5) == "text_") and (pnot == true) then
		result = "text"
	end

	return result
end

--Fixes TEXT HAS TEXT and NOT METATEXT HAS TEXT.
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
				end
				local did = false
				for a,mat in pairs(fullunitlist) do -- ONLY CHANGED LINE
					if (a == object) and (object ~= "empty") then
						if (object ~= "all") and (string.sub(object, 1, 5) ~= "group") then
							create(object,x,y,dir,nil,nil,nil,nil,leveldata)
							did = true
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

-- Makes sure text units are considered special nouns
function findnoun(noun,list_,ignoretext)
	local list = list_ or nlist.full

	for i,v in ipairs(list) do
		if (v == noun) or ((v == "group") and (string.sub(noun, 1, 5) == "group")) or (string.sub(noun,1,5) == "text_" and v == "text" and ignoretext ~= true) then
			return true
		end
	end

	return false
end

-- Removes text units from "text" unitlist when deleted
function delunit(unitid)
	local unit = mmf.newObject(unitid)

	if (unit ~= nil) then
		local name = getname(unit)
		local x,y = unit.values[XPOS],unit.values[YPOS]
		local unitlist = unitlists[name]
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
		if (unittype == "text") then
			local textunitlist = unitlists["text"]
			if (textunitlist ~= nil) then
				for i,v in pairs(textunitlist) do
					if (v == unitid) then
						v = {}
						table.remove(textunitlist, i)
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

-- Adds option to exclude group rules made by "text" noun
function findgroup(grouptype_,invert_,limit_,checkedconds_,notextnoun_)
	local result = {}
	local limit = limit_ or 0
	local invert = invert_ or false
	local grouptype = grouptype_ or "group"
	local nottextnoun = nottextnoun_ or false
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
		local tags = v[4]
		local foundtag = false
		if nottextnoun then
			for num,tag in pairs(tags) do
				if tag == "text" then
					foundtag = true
					break
				end
			end
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
