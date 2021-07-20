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

-- Prevent text from being called "text", and implement hacky NOT METATEXT in conditions solution.
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
				for a,mat in pairs(fullunitlist) do -- ONLY CHANGED LINE
					if (a == object) and (object ~= "empty") then
						if (object ~= "all") and (string.sub(object, 1, 5) ~= "group") then
							create(object,x,y,dir,nil,nil,nil,nil,leveldata)
						elseif (object == "all") then
							createall(v,x,y,unitid,nil,leveldata)
						elseif (string.sub(object, 1, 5) == "group") then
							local mem = findgroup(object)

							for c,d in ipairs(mem) do
								create(d,x,y,dir,nil,nil,nil,nil,leveldata)
							end
						end
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

-- Not actually in tools.lua but whatever. Allows editor to rename objects to metatext.
function editor_trynamechange(object,newname_,fixed,objlistid,oldname_)
	local valid = true

	local newname = newname_ or "error"
	local oldname = oldname_ or "error"
	local checking = true

	newname = string.gsub(newname, "_", "UNDERDASH")
	newname = string.gsub(newname, "%W", "")
	newname = string.gsub(newname, "UNDERDASH", "_")

	--[[while (string.find(newname, "text_text_") ~= nil) do
		newname = string.gsub(newname, "text_text_", "text_")
	end]]--

	while checking do
		checking = false

		for a,obj in pairs(editor_currobjlist) do
			if (obj.name == newname) then
				checking = true

				if (tonumber(string.sub(obj.name, -1)) ~= nil) then
					local num = tonumber(string.sub(obj.name, -1)) + 1

					newname = string.sub(newname, 1, string.len(newname)-1) .. tostring(num)
				else
					newname = newname .. "2"
				end
			end
		end
	end

	if (#newname == 0) or (newname == "level") or (newname == "text_crash") or (newname == "text_error") or (newname == "crash") or (newname == "error") or (newname == "text_never") or (newname == "never") or (newname == "text_") then
		valid = false
	end

	if (string.find(newname, "#") ~= nil) then
		valid = false
	end

	MF_alert("Trying to change name: " .. object .. ", " .. newname .. ", " .. tostring(valid))

	if valid then
		savechange(object,{newname},fixed)
		MF_updateobjlistname_hack(objlistid,newname)

		--[[for i,v in ipairs(editor_currobjlist) do
			if (v.object == object) then
				v.name = newname
			end

			if (v.name == "text_" .. oldname) then
				v.name = "text_" .. newname
				local vid = MF_create(v.object)
				savechange(v.object,{v.name},vid)
				MF_cleanremove(vid)

				MF_alert("Found text_" .. oldname .. ", changing to text_" .. newname)

				MF_updateobjlistname_byname("text_" .. oldname,"text_" .. newname)
			elseif (string.sub(oldname, 1, 5) == "text_") and (v.name == string.sub(oldname, 6)) and (string.sub(newname, 1, 5) == "text_") then
				v.name = string.sub(newname, 6)
				local vid = MF_create(v.object)
				savechange(v.object,{v.name},vid)
				MF_cleanremove(vid)

				MF_alert("Found " .. oldname .. ", changing to " .. newname)

				MF_updateobjlistname_byname(string.sub(oldname, 6),string.sub(newname, 6))
			end
		end]]--
	end

	return valid
end
