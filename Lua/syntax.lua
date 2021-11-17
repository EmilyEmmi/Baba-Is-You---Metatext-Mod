-- Implement FULLUNITLIST, and also add text units to "text" unitlist (for WITHOUT)
function addunit(id,undoing_)
	local unitid = #units + 1

	units[unitid] = {}
	units[unitid] = mmf.newObject(id)

	local unit = units[unitid]

	getmetadata(unit)

	local truename = unit.className

	if (changes[truename] ~= nil) then
		dochanges(id)
	end

	if (unit.values[ID] == -1) then
		unit.values[ID] = newid()
	end

	if (unit.values[XPOS] > 0) and (unit.values[YPOS] > 0) then
		addunitmap(id,unit.values[XPOS],unit.values[YPOS],unit.strings[UNITNAME])
	end

	if (unit.values[TILING] == 1) then
		table.insert(tiledunits, unit.fixed)
	end

	if (unit.values[TILING] > 1) then
		table.insert(animunits, unit.fixed)
	end

	local name = getname(unit)
	local name_ = unit.strings[NAME]

	if (unitlists[name] == nil) then
		unitlists[name] = {}
	end

	table.insert(unitlists[name], unit.fixed)

	if fullunitlist == nil then
		fullunitlist = {}
	end
	if (unit.strings[UNITTYPE] ~= "text") or ((unit.strings[UNITTYPE] == "text") and (unit.values[TYPE] == 0)) then
		objectlist[name_] = 1
		fullunitlist[name_] = 1
		if unit.strings[UNITTYPE] == "text" then
			if (unitlists["text"] == nil) then
				unitlists["text"] = {}
			end
			table.insert(unitlists["text"], unit.fixed)
		end
	end
	fullunitlist[name] = 1

	if (unit.strings[UNITTYPE] == "text") then
		table.insert(codeunits, unit.fixed)
		updatecode = 1

		if (unit.values[TYPE] == 0) then
			local matname = string.sub(unit.strings[UNITNAME], 6)
			if (unitlists[matname] == nil) then
				unitlists[matname] = {}
			end
		elseif (unit.values[TYPE] == 5 or (unit.values[TYPE] == 4 and unit.strings[UNITNAME] == "text_text_")) then
			table.insert(letterunits, unit.fixed)
		end
	end

	unit.colour = {}

	if (unit.strings[UNITNAME] ~= "level") and (unit.className ~= "specialobject") then
		local cc1,cc2 = setcolour(unit.fixed)
		unit.colour = {cc1,cc2}
	end

	local undoing = undoing_ or false

	unit.back_init = 0
	unit.broken = 0

	if (unit.className ~= "path") and (unit.className ~= "specialobject") then
		statusblock({id},undoing)
		MF_animframe(id,math.random(0,2))
	end

	unit.active = false
	unit.new = true
	unit.colours = {}
	unit.currcolour = 0
	unit.followed = -1
	unit.xpos = unit.values[XPOS]
	unit.ypos = unit.values[YPOS]

	if (spritedata.values[VISION] == 1) and (undoing == false) then
		local hasvision = hasfeature(name,"is","3d",id,unit.values[XPOS],unit.values[YPOS])
		if (hasvision ~= nil) then
			table.insert(visiontargets, id)
		elseif (spritedata.values[CAMTARGET] == unit.values[ID]) then
			visionmode(0,0,nil,{unit.values[XPOS],unit.values[YPOS],unit.values[DIR]})
		end
	end

	if (spritedata.values[VISION] == 1) and (spritedata.values[CAMTARGET] ~= unit.values[ID]) then
		if (unit.values[ZLAYER] <= 15) then
			if (unit.values[ZLAYER] > 10) then
				setupvision_wall(unit.fixed)
			end

			MF_setupvision_single(unit.fixed)
		end
	end

	if generaldata.flags[LOGGING] and (generaldata.flags[RESTARTED] == false) then
		if levelstart then
			dolog("init_object","event",unit.strings[UNITNAME] .. ":" .. tostring(unit.values[XPOS]) .. ":" .. tostring(unit.values[YPOS]))
		elseif (undoing == false) then
			dolog("new_object","event",unit.strings[UNITNAME] .. ":" .. tostring(unit.values[XPOS]) .. ":" .. tostring(unit.values[YPOS]))
		end
	end
end

-- Fix TEXT IS ALL
function createall(matdata,x_,y_,id_,dolevels_,leveldata_)
	local all = {}
	local empty = false
	local dolevels = dolevels_ or false

	local leveldata = leveldata_ or {}

	if (x_ == nil) and (y_ == nil) and (id_ == nil) then
		if (matdata[1] ~= "empty") and (findnoun(matdata[1],nlist.brief) == false) then
			all = findall(matdata)
		elseif (matdata[1] == "empty") then
			all = findempty(matdata[2])
			empty = true
		end
	end
	local test = {}

	if (x_ ~= nil) and (y_ ~= nil) and (id_ ~= nil) then
		local check = findtype(matdata,x_,y_,id_)

		if (#check > 0) then
			for i,v in ipairs(check) do
				if (v ~= 0) then
					table.insert(test, v)
				end
			end
		end
	end

	if (#all > 0) then
		for i,v in ipairs(all) do
			table.insert(test, v)
		end
	end

	if (dolevels == false) then
		local delthese = {}

		if (#test > 0) then
			for i,v in ipairs(test) do
				if (empty == false) then
					local vunit = mmf.newObject(v)
					local x,y,dir = vunit.values[XPOS],vunit.values[YPOS],vunit.values[DIR]

					if (vunit.flags[CONVERTED] == false) then
						for b,unit in pairs(objectlist) do
							if (findnoun(b) == false) and (b ~= matdata[1]) then
								local protect = hasfeature(matdata[1],"is","not " .. b,v,x,y)

								if (protect == nil) then
									local mat = findtype({b},x,y,v)
									--local tmat = findtext(x,y)

									if (#mat == 0) then
										local nunitid,ningameid = create(b,x,y,dir,nil,nil,nil,nil,leveldata)
										local nrevertdata = getrevertorigin(ningameid,vunit.values[ID],matdata[1])
										addundo({"convert",matdata[1],mat,ningameid,vunit.values[ID],x,y,dir,nrevertdata})

										if (matdata[1] == "text") or (string.sub(matdata[1],1,5) == "text_") or (matdata[1] == "level") then --THE LEGENDARY CHANGED LINE
											table.insert(delthese, v)
										end
									end
								end
							end
						end
					end
				else
					local x = v % roomsizex
					local y = math.floor(v / roomsizex)
					local dir = 4

					local blocked = {}

					local valid = true
					if (emptydata[v] ~= nil) then
						if (emptydata[v]["conv"] ~= nil) and emptydata[v]["conv"] then
							valid = false
						end
					end

					if valid then
						if (featureindex["empty"] ~= nil) then
							for i,rules in ipairs(featureindex["empty"]) do
								local rule = rules[1]
								local conds = rules[2]

								if (rule[1] == "empty") and (rule[2] == "is") and (string.sub(rule[3], 1, 4) == "not ") then
									if testcond(conds,1,x,y) then
										local target = string.sub(rule[3], 5)
										blocked[target] = 1
									end
								end
							end
						end

						if (blocked["all"] == nil) then
							for b,mat in pairs(objectlist) do
								if (findnoun(b) == false) and (blocked[target] == nil)  then
									local nunitid,ningameid = create(b,x,y,dir,nil,nil,nil,nil,leveldata)
									local nrevertdata = getrevertorigin(ningameid,2,matdata[1])
									addundo({"convert",matdata[1],mat,ningameid,2,x,y,dir,nrevertdata})
								end
							end
						end
					end
				end
			end
		end

		for a,b in ipairs(delthese) do
			delete(b)
		end
	end

	if (matdata[1] == "level") and dolevels then
		local blocked = {}

		if (featureindex["level"] ~= nil) then
			for i,rules in ipairs(featureindex["level"]) do
				local rule = rules[1]
				local conds = rules[2]

				if (rule[1] == "level") and (rule[2] == "is") and (string.sub(rule[3], 1, 4) == "not ") then
					if testcond(conds,1,x,y) then
						local target = string.sub(rule[3], 5)
						blocked[target] = 1
					end
				end
			end
		end

		if (blocked["all"] == nil) and ((matdata[2] == nil) or testcond(matdata[2],1)) then
			for b,unit in pairs(objectlist) do
				if (findnoun(b,nlist.brief) == false) and (b ~= "empty") and (b ~= "level") and (blocked[target] == nil) then
					table.insert(levelconversions, {b, {}})
				end
			end
		end
	end
end
