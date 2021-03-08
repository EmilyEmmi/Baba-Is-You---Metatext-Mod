-- Both: Remove lines that change name to "text"
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

-- Fix MIMIC
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

-- Prevent text from being called "text"
function getname(unit,checktext,checktext2)
	local result = unit.strings[UNITNAME]

	if (unit.strings[UNITTYPE] == "text") and (string.sub(result, 1, 5) ~= "text_") then
		result = "text_" .. result
	end
	if (unit.strings[UNITTYPE] == "text") and ((checktext == "text") or (checktext2 == true)) then
		result = "text"
	end

	return result
end

-- Fix TEXT HAS TEXT
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
				if (object ~= "text") then
					for a,mat in pairs(fullunitlist) do
						if (a == object) and (object ~= "empty") and (object ~= "group") then
							if (object ~= "all") then
								create(object,x,y,dir,nil,nil,nil,nil,leveldata)
							else
								createall(v,x,y,unitid,nil,leveldata)
							end
						end
					end
				else
					create("text_" .. name,x,y,dir,nil,nil,nil,nil,leveldata)
				end
			end
		end
	end
end
