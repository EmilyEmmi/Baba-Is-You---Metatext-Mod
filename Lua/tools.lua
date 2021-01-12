function issolid(unitid)
	local unit = mmf.newObject(unitid)
	local name = unit.strings[UNITNAME]

	if (unit.strings[UNITTYPE] == "text") then
		--name = "text""
	end

	local ispush = hasfeature(name,"is","push",unitid)
	local ispull = hasfeature(name,"is","pull",unitid)
	local ismove = hasfeature(name,"is","move",unitid)
	local isyou = hasfeature(name,"is","you",unitid) or hasfeature(name,"is","you2",unitid)

	if (ispush ~= nil) or (ispull ~= nil) or (ismove ~= nil) or (isyou ~= nil) then
		return true
	end

	return false
end

function isgone(unitid)
	if (issafe(unitid) == false) then
		local unit = mmf.newObject(unitid)
		local x,y,name = unit.values[XPOS],unit.values[YPOS],unit.strings[UNITNAME]

		if (unit.strings[UNITTYPE] == "text") then
			--name = "text""
		end

		local isyou = hasfeature(name,"is","you",unitid,x,y) or hasfeature(name,"is","you2",unitid,x,y)
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
				if (v ~= unitid) and (floating(v,unitid)) then
					return true
				end
			end
		end

		if (isyou ~= nil) then
			local isdefeat = findfeatureat(nil,"is","defeat",x,y)

			if (isdefeat ~= nil) then
				for i,v in ipairs(isdefeat) do
					if (floating(v,unitid)) then
						return true
					end
				end
			end
		end

		if (ismelt ~= nil) then
			local ishot = findfeatureat(nil,"is","hot",x,y)

			if (ishot ~= nil) then
				for i,v in ipairs(ishot) do
					if (floating(v,unitid)) then
						return true
					end
				end
			end
		end

		if (isshut ~= nil) then
			local isopen_ = findfeatureat(nil,"is","open",x,y)

			if (isopen_ ~= nil) then
				for i,v in ipairs(isopen_) do
					if (floating(v,unitid)) then
						return true
					end
				end
			end
		end

		if (isopen ~= nil) then
			local isshut_ = findfeatureat(nil,"is","shut",x,y)

			if (isshut_ ~= nil) then
				for i,v in ipairs(isshut_) do
					if (floating(v,unitid)) then
						return true
					end
				end
			end
		end

		if (isweak ~= nil) then
			local things = findallhere(x,y)

			if (things ~= nil) then
				for i,v in ipairs(things) do
					if (v ~= unitid) and (floating(v,unitid)) then
						return true
					end
				end
			end
		end
	end

	return false
end

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

function getname(unit,checktext)
	local result = unit.strings[UNITNAME]

	if (unit.strings[UNITTYPE] == "text") and (string.sub(result, 1, 5) ~= "text_") then
		result = "text_" .. result
	end
	if (unit.strings[UNITTYPE] == "text") and checktext == "text" then
		result = "text"
	end

	return result
end
