function rotate(dir)
	local rot = {2,3,0,1,4}

	return rot[dir+1]
end

function isthis(lookup,rule)
	for i,rules in ipairs(lookup) do
		local baserule = rules[1]

		if (baserule[3] == rule) and (baserule[2] == "is") then
			return true
		end
	end

	return false
end

function xthis(lookup,name,rule)
	local result = {}

	for i,rules in ipairs(lookup) do
		local baserule = rules[1]

		if (baserule[1] == name) and (baserule[2] == rule) then
			table.insert(result, baserule[3])
		end
	end

	return result
end

function findall(name_,ignorebroken_)
	local result = {}
	local name = name_[1]

	local checklist = unitlists[name]

	if (name == "text") then
		checklist = codeunits
	end

	local ignorebroken = ignorebroken_ or false

	if (checklist ~= nil) then
		for i,unitid in ipairs(checklist) do
			local unit = mmf.newObject(unitid)
			local unitname = getname(unit)

			local oldbroken = unit.broken
			if ignorebroken then
				unit.broken = 0
			end

			if (unitname == name) then
				if testcond(name_[2],unitid) then
					table.insert(result, unitid)
				end
			end

			unit.broken = oldbroken
		end
	end

	return result
end

function delunit(unitid)
	local unit = mmf.newObject(unitid)
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

	for i,v in pairs(groupunits) do
		if (i == unitid) then
			local currentundo = undobuffer[1]
			currentundo.groupunits[unit.strings[UNITNAME]] = 1
			updatecode = 1
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

				if (unit.strings[UNITNAME] == name) or ((unit.strings[UNITTYPE] == "text") and (name == "text")) then
					if testcond(conds,v) then
						table.insert(result, v)
					end
				end
			end
		end
	end

	return result
end

function findobstacle(x,y)
	local layer = map[0]
	local tile = layer:get_x(x,y)
	local result = {}
	local tileid = x + y * roomsizex

	if (tile ~= 255) then
		table.insert(result, -1)
	end

	if (unitmap[tileid] ~= nil) then
		for i,v in ipairs(unitmap[tileid]) do
			local unit = mmf.newObject(v)

			if (unit.flags[DEAD] == false) then
				table.insert(result, v)
			else
				MF_alert("Unitmap: found removed unit " .. unit.strings[UNITNAME])
			end
		end
	end

	return result
end

function update(unitid,x,y,dir_)
	if (unitid ~= nil) then
		local unit = mmf.newObject(unitid)

		local unitname = unit.strings[UNITNAME]
		local dir,olddir = unit.values[DIR],unit.values[DIR]
		local tiling = unit.values[TILING]
		local unittype = unit.strings[UNITTYPE]
		local oldx,oldy = unit.values[XPOS],unit.values[YPOS]

		if (dir_ ~= nil) then
			dir = dir_
		end

		if (x ~= oldx) or (y ~= oldy) or (dir ~= olddir) then
			updateundo = true

			addundo({"update",unitname,oldx,oldy,olddir,x,y,dir,unit.values[ID]},unitid)

			local ox,oy = x-oldx,y-oldy

			if (math.abs(ox) + math.abs(oy) == 1) and (unit.values[MOVED] == 0) then
				unit.x = unit.x + ox * tilesize * spritedata.values[TILEMULT] * generaldata2.values[ZOOM] * 0.25
				unit.y = unit.y + oy * tilesize * spritedata.values[TILEMULT] * generaldata2.values[ZOOM] * 0.25
			end

			unit.values[XPOS] = x
			unit.values[YPOS] = y
			unit.values[DIR] = dir
			unit.values[MOVED] = 1
			unit.values[POSITIONING] = 0

			updateunitmap(unitid,oldx,oldy,x,y,unit.strings[UNITNAME])

			if (tiling == 1) then
				dynamic(unitid)
				dynamicat(oldx,oldy)
			end

			if (unittype == "text") then
				updatecode = 1
			end

			if (featureindex["word"] ~= nil) or (featureindex["group"] ~= nil) then
				checkwordchanges(unitid,unitname)
			end
		end
	else
		MF_alert("Tried to update a nil unit")
	end
end

function updatedir(unitid,dir)
	if (unitid ~= nil) then
		local unit = mmf.newObject(unitid)
		local x,y = unit.values[XPOS],unit.values[YPOS]
		local unitname = unit.strings[UNITNAME]
		local unittype = unit.strings[UNITTYPE]
		local olddir = unit.values[DIR]

		if (dir ~= olddir) then
			updateundo = true
			addundo({"update",unitname,x,y,olddir,x,y,dir,unit.values[ID]},unitid)
			unit.values[DIR] = dir

			if (unittype == "text") then
				updatecode = 1
			end
		end
	else
		MF_alert("Tried to updatedir a nil unit")
	end
end

function findtext(x,y)
	local result = {}
	local tileid = x + y * roomsizex

	if (unitmap[tileid] ~= nil) then
		for i,v in ipairs(unitmap[tileid]) do
			local unit = mmf.newObject(v)

			if (unit.strings[UNITTYPE] == "text") then
				table.insert(result, v)
			end
		end
	end

	return result
end

function findallhere(x,y,exclude_,fpaths_)
	local result = {}

	local exclude = 0
	if (exclude_ ~= nil) then
		exclude = exclude_
	end

	local fpaths = false
	if (fpaths_ ~= nil) then
		fpaths = fpaths_
	end

	local tileid = x + y * roomsizex

	if (unitmap[tileid] ~= nil) then
		for i,unitid in ipairs(unitmap[tileid]) do
			if (unitid ~= exclude) then
				table.insert(result, unitid)
			end
		end
	end

	if fpaths then
		local pathshere = MF_findpaths(x,y)

		if (#pathshere > 0) then
			for i,v in ipairs(pathshere) do
				table.insert(result, v)
			end
		end
	end

	return result
end

function findempty(conds_,checkonly_)
	local result = {}
	local array = {}
	local layer = map[0]

	local conds = conds_ or {}

	local checkonly = false
	if (checkonly_ ~= nil) then
		checkonly = checkonly_
	end

	for i,unit in ipairs(units) do
		local x,y = unit.values[XPOS],unit.values[YPOS]
		local arrayid = x + y * roomsizex

		if (array[arrayid] == nil) then
			array[arrayid] = {}
			table.insert(array[arrayid], unit.fixed)
		end
	end

	for i=0,roomsizex-1 do
		for j=0,roomsizey-1 do
			local empty = 1
			local tile = layer:get_x(i,j)
			local arrayid = i + j * roomsizex

			if (tile ~= 255) or (array[arrayid] ~= nil) then
				empty = 0
			end

			if (empty == 1) then
				if (#conds == 0) or ((#conds > 0) and testcond(conds,2,i,j)) then
					table.insert(result, i + j * roomsizex)

					if checkonly then
						return result
					end
				end
			end
		end
	end

	return result
end

function delete(unitid,x_,y_,total_)
	local total = total_ or false

	local check = unitid

	if (unitid == 2) then
		check = 200 + x_ + y_ * roomsizex
	end

	if (deleted[check] == nil) then
		local unit = {}
		local x,y,dir = 0,0,4
		local unitname = ""
		local insidename = ""

		if (unitid ~= 2) then
			unit = mmf.newObject(unitid)
			x,y,dir = unit.values[XPOS],unit.values[YPOS],unit.values[DIR]
			unitname = unit.strings[UNITNAME]
			insidename = getname(unit)
		else
			x,y = x_,y_
			unitname = "empty"
			insidename = "empty"
		end

		x = math.floor(x)
		y = math.floor(y)

		if (total == false) and inbounds(x,y,1) then
			local leveldata = {}

			if (unitid == 2) then
				dir = emptydir(x,y)
			else
				leveldata = {unit.strings[U_LEVELFILE],unit.strings[U_LEVELNAME],unit.flags[MAPLEVEL],unit.values[VISUALLEVEL],unit.values[VISUALSTYLE],unit.values[COMPLETED],unit.strings[COLOUR],unit.strings[CLEARCOLOUR]}
			end

			inside(insidename,x,y,dir,unitid,leveldata)
		end

		if (unitid ~= 2) then
			addundo({"remove",unitname,x,y,dir,unit.values[ID],unit.values[ID],unit.strings[U_LEVELFILE],unit.strings[U_LEVELNAME],unit.values[VISUALLEVEL],unit.values[COMPLETED],unit.values[VISUALSTYLE],unit.flags[MAPLEVEL],unit.strings[COLOUR],unit.strings[CLEARCOLOUR],unit.followed,unit.back_init},unitid)
			unit = {}
			delunit(unitid)
			MF_remove(unitid)

			--MF_alert("Removed " .. tostring(unitid))

			if inbounds(x,y,1) then
				dynamicat(x,y)
			end
		end

		deleted[check] = 1
	else
		MF_alert("already deleted")
	end
end

function writerules(parent,name,x_,y_)
	local basex = x_
	local basey = y_
	local linelimit = 12
	local maxcolumns = 4

	local x,y = basex,basey

	if (#visualfeatures > 0) then
		writetext(langtext("rules") .. ":",0,x,y,name,true,2,true)
	end

	local i_ = 1

	local count = 0
	local allrules = {}

	for i,rules in ipairs(visualfeatures) do
		local text = ""
		local rule = rules[1]

		text = text .. rule[1] .. " "

		local conds = rules[2]
		local ids = rules[3]
		local tags = rules[4]

		local fullinvis = true
		for a,b in ipairs(ids) do
			for c,d in ipairs(b) do
				local dunit = mmf.newObject(d)

				if dunit.visible then
					fullinvis = false
				end
			end
		end

		if (fullinvis == false) then
			if (#conds > 0) then
				for a,cond in ipairs(conds) do
					local middlecond = true

					if (cond[2] == nil) or ((cond[2] ~= nil) and (#cond[2] == 0)) then
						middlecond = false
					end

					if middlecond then
						text = text .. cond[1] .. " "

						if (cond[2] ~= nil) then
							if (#cond[2] > 0) then
								for c,d in ipairs(cond[2]) do
									text = text .. d .. " "

									if (#cond[2] > 1) and (c ~= #cond[2]) then
										text = text .. "& "
									end
								end
							end
						end

						if (a < #conds) then
							text = text .. "& "
						end
					else
						text = cond[1] .. " " .. text
					end
				end
			end

			local target = rule[3]
			local isnot = string.sub(target, 1, 4)
			local target_ = target

			if (isnot == "not ") then
				target_ = string.sub(target, 5)
			else
				isnot = ""
			end

			if (word_names[target_] ~= nil) then
				target = isnot .. word_names[target_]
			end

			text = text .. rule[2] .. " " .. target

			for a,b in ipairs(tags) do
				if (b == "mimic") then
					text = text .. " (mimic)"
				end
			end

			if (allrules[text] == nil) then
				allrules[text] = 1
				count = count + 1
			else
				allrules[text] = allrules[text] + 1
			end
			i_ = i_ + 1
		end
	end

	local columns = math.min(maxcolumns, math.floor((count - 1) / linelimit) + 1)
	local columnwidth = math.min(screenw - f_tilesize * 2, columns * f_tilesize * 10) / columns

	i_ = 1

	local maxlimit = 4 * linelimit

	for i,v in pairs(allrules) do
		local text = i

		if (i_ <= maxlimit) then
			local currcolumn = math.floor((i_ - 1) / linelimit) - (columns * 0.5)
			x = basex + columnwidth * currcolumn + columnwidth * 0.5
			y = basey + (((i_ - 1) % linelimit) + 1) * f_tilesize * 0.8
		end

		if (i_ <= maxlimit-1) then
			if (v == 1) then
				writetext(text,0,x,y,name,true,2,true)
			elseif (v > 1) then
				writetext(tostring(v) .. " x " .. text,0,x,y,name,true,2,true)
			end
		end

		i_ = i_ + 1
	end

	if (i_ > maxlimit-1) then
		writetext("(+ " .. tostring(i_ - maxlimit) .. ")",0,x,y,name,true,2,true)
	end
end

function mapcells()
	local count = 0

	for i,v in pairs(unitmap) do
		if (#v > 0) then
			count = count + 1
		end
	end

	return count
end

function copy(unitid,x,y)
	for i,unit in ipairs(units) do
		if (unit.fixed == unitid) then
			local oldx,oldy,dir,name,float = unit.values[XPOS],unit.values[YPOS],unit.values[DIR],unit.strings[UNITNAME],unit.values[FLOAT]

			local leveldata = {unit.strings[U_LEVELFILE],unit.strings[U_LEVELNAME],unit.flags[MAPLEVEL],unit.values[VISUALLEVEL],unit.values[VISUALSTYLE],unit.values[COMPLETED],unit.strings[COLOUR],unit.strings[CLEARCOLOUR]}

			local this = create(name,x,y,dir,oldx,oldy,float,nil,leveldata)
			return this
		end
	end
end

function create(name,x,y,dir,oldx_,oldy_,float_,skipundo_,leveldata_)
	local oldx,oldy,float = x,y,0
	local tileid = x + y * roomsizex

	if (oldx_ ~= nil) then
		oldx = oldx_
	end

	if (oldy_ ~= nil) then
		oldy = oldy_
	end

	if (float_ ~= nil) then
		float = float_
	end

	local skipundo = skipundo_ or false

	local unitname = unitreference[name]

	local newunitid = MF_emptycreate(unitname,oldx,oldy)
	local newunit = mmf.newObject(newunitid)

	local id = newid()

	newunit.values[ONLINE] = 1
	newunit.values[XPOS] = x
	newunit.values[YPOS] = y
	newunit.values[DIR] = dir
	newunit.values[ID] = id
	newunit.values[FLOAT] = float
	newunit.flags[CONVERTED] = true

	if (leveldata_ ~= nil) and (#leveldata_ > 0) then
		newunit.strings[U_LEVELFILE] = leveldata_[1]
		newunit.strings[U_LEVELNAME] = leveldata_[2]
		newunit.flags[MAPLEVEL] = leveldata_[3]
		newunit.values[VISUALLEVEL] = leveldata_[4]
		newunit.values[VISUALSTYLE] = leveldata_[5]
		newunit.values[COMPLETED] = leveldata_[6]

		newunit.strings[COLOUR] = leveldata_[7]
		newunit.strings[CLEARCOLOUR] = leveldata_[8]

		if (newunit.className == "level") and (newunit.values[COMPLETED] == 0) then
			newunit.values[COMPLETED] = 1
		end

		if (string.len(leveldata_[7]) > 0) then
			local c = MF_parsestring(leveldata_[7])
			MF_setcolour(newunitid,c[1],c[2])
		end
	end

	newunit.flags[9] = true

	if (skipundo == false) then
		addundo({"create",name,id,-1,"create"})
	end

	addunit(newunitid)
	addunitmap(newunitid,x,y,newunit.strings[UNITNAME])
	dynamic(newunitid)

	local testname = getname(newunit)
	if (hasfeature(testname,"is","word",newunitid,x,y) ~= nil) then
		updatecode = 1
	end

	return newunit.fixed
end

function getunitid(id)
	local style = style_ or ""

	for i,unit in ipairs(units) do
		if (unit.values[ID] == id) then
			return unit.fixed
		end
	end

	MF_alert("No valid unitid found for this ID: " .. tostring(id))
	return 0
end

function newid()
	local result = generaldata.values[CURRID]
	generaldata.values[CURRID] = generaldata.values[CURRID] + 1
	return result
end

function addunitmap(id,x,y,name)
	local doadd = true
	local tileid = x + y * roomsizex

	if (unitmap[tileid] == nil) then
		unitmap[tileid] = {}
	else
		for a,b in ipairs(unitmap[tileid]) do
			if (b == id) then
				doadd = false
			end
		end
	end

	if (unittypeshere[tileid] == nil) then
		unittypeshere[tileid] = {}
	end

	local uth = unittypeshere[tileid]

	if (uth[name] == nil) then
		uth[name] = 0
	end

	if doadd then
		table.insert(unitmap[tileid], id)
		uth[name] = uth[name] + 1
	end
end

function updateunitmap(id,oldx,oldy,x,y,name)
	local tileid = x + y * roomsizex
	local oldtileid = oldx + oldy * roomsizex

	if (unitmap[oldtileid] ~= nil) then
		for i,v in ipairs(unitmap[oldtileid]) do
			if (v == id) then
				table.remove(unitmap[oldtileid], i)
			end
		end
	end

	if (unittypeshere[oldtileid] ~= nil) then
		local uth = unittypeshere[oldtileid]

		if (uth[name] ~= nil) then
			uth[name] = uth[name] - 1

			if (uth[name] == 0) then
				uth[name] = nil
			end
		end
	end

	addunitmap(id,x,y,name)
end

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
					for a,mat in pairs(objectlist) do
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

function animate()
	for i,unitid in ipairs(animunits) do
		local unit = mmf.newObject(unitid)
		local name = unit.strings[UNITNAME]
		local sleep = hasfeature(name,"is","sleep",unitid)

		if (unit.values[TILING] == 4) then
			if (sleep == nil) then
				if (unit.values[VISUALDIR] ~= -1) then
					unit.values[VISUALDIR] = (unit.values[VISUALDIR] + 1) % 4
				else
					MF_particles("destroy",unit.values[XPOS],unit.values[YPOS],1,3,1,3,1)
					unit.values[VISUALDIR] = 0
				end

				unit.direction = ((unit.values[VISUALDIR]) + 32) % 32
			else
				--unit.values[VISUALDIR] = -1
				unit.direction = ((unit.values[VISUALDIR]) + 32) % 32
			end
		end

		if (unit.values[TILING] == 3) then
			if (sleep == nil) then
				if (unit.values[VISUALDIR] ~= -1) then
					unit.values[VISUALDIR] = (unit.values[VISUALDIR] + 1) % 4
				else
					MF_particles("destroy",unit.values[XPOS],unit.values[YPOS],1,3,1,3,1)
					unit.values[VISUALDIR] = 0
				end

				unit.direction = ((unit.values[DIR] * 8 + unit.values[VISUALDIR]) + 32) % 32
			else
				--unit.values[VISUALDIR] = -1
				unit.direction = ((unit.values[DIR] * 8 + unit.values[VISUALDIR]) + 32) % 32
			end
		end

		if (unit.values[TILING] == 2) then
			if (sleep == nil) then
				if (unit.values[VISUALDIR] == -1) then
					MF_particles("destroy",unit.values[XPOS],unit.values[YPOS],1,3,1,3,1)
					unit.values[VISUALDIR] = 0
				end

				unit.direction = ((unit.values[DIR] * 8 + unit.values[VISUALDIR]) + 32) % 32
			else
				unit.values[VISUALDIR] = -1
				unit.direction = ((unit.values[DIR] * 8 + unit.values[VISUALDIR]) + 32) % 32
			end
		end
	end
end

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

function floating(id1,id2,x_,y_)
	local empty1,empty2 = false,false
	local x = x_ or 0
	local y = y_ or 0

	local float1,float2 = -1,-1

	if (id1 ~= 2) then
		local unit1 = mmf.newObject(id1)
		float1 = unit1.values[FLOAT]
	else
		local emptyfloat = hasfeature("empty","is","float",2,x,y)
		if (emptyfloat ~= nil) then
			float1 = 1
		else
			float1 = 0
		end
	end

	if (id2 ~= 2) then
		local unit2 = mmf.newObject(id2)
		float2 = unit2.values[FLOAT]
	else
		local emptyfloat = hasfeature("empty","is","float",2,x,y)
		if (emptyfloat ~= nil) then
			float2 = 1
		else
			float2 = 0
		end
	end

	if (float1 == float2) then
		return true
	end

	return false
end

function floating_level(id,x_,y_)
	local levelfloat = findfeature("level","is","float")
	local valid = 0
	local unitfloat = -1

	local x = x_ or 0
	local y = y_ or 0

	if (id ~= 2) then
		local unit = mmf.newObject(id)
		unitfloat = unit.values[FLOAT]
	else
		if (x_ == nil) or (y_ == nil) then
			local emptyfloat = findallfeature("empty","is","float")
			if (#emptyfloat > 0) then
				unitfloat = 1
			else
				unitfloat = 0
			end
		else
			local emptyfloat = hasfeature("empty","is","float",2,x,y)

			if (emptyfloat ~= nil) then
				unitfloat = 1
			else
				unitfloat = 0
			end
		end
	end

	if (levelfloat ~= nil) then
		for i,v in ipairs(levelfloat) do
			if testcond(v[2],1) then
				valid = 1
			end
		end
	end

	if (unitfloat == valid) then
		return true
	end

	return false
end

function emptydir(x,y)
	local dir = 4
	local followcheck = false

	if (featureindex["empty"] ~= nil) then
		for a,b in ipairs(featureindex["empty"]) do
			local rule = b[1]
			local econds = b[2]

			if (rule[1] == "empty") then
				if (rule[2] == "is") then
					if (issleep(2,x,y) == false) then
						if (rule[3] == "right") and testcond(econds,2,x,y,{"facing"}) then
							dir = 0
						elseif (rule[3] == "up") and testcond(econds,2,x,y,{"facing"}) then
							dir = 1
						elseif (rule[3] == "left") and testcond(econds,2,x,y,{"facing"}) then
							dir = 2
						elseif (rule[3] == "down") and testcond(econds,2,x,y,{"facing"}) then
							dir = 3
						end
					end
				elseif (rule[2] == "follow") and (rule[3] ~= "all") and (rule[3] ~= "group") and (rule[3] ~= "empty") and (rule[3] ~= "level") then
					local distance = 9999
					local targetdir = -1

					if (followcheck == false) and (issleep(2,x,y) == false) and (objectlist[rule[3]] ~= nil) and (unitlists[rule[3]] ~= nil) then
						if testcond(econds,2,x,y,{"facing"}) then
							for i,v in ipairs(unitlists[rule[3]]) do
								local funit = mmf.newObject(v)

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
									followcheck = true
								end
							end
						end
					end

					if (targetdir ~= -1) then
						dir = targetdir
					end
				end
			end
		end
	end

	return dir
end

function issafe(unitid,x,y)
	name = ""

	if (unitid ~= 1) and (unitid ~= 2) then
		local unit = mmf.newObject(unitid)
		name = getname(unit)
	elseif (unitid == 1) then
		name = "level"
	else
		name = "empty"
	end

	local safe = hasfeature(name,"is","safe",unitid,x,y)

	if (safe ~= nil) then
		return true
	end

	return false
end

function issleep(unitid,x_,y_)
	local name = ""

	if (unitid ~= 1) and (unitid ~= 2) then
		local unit = mmf.newObject(unitid)
		local name = getname(unit)
	elseif (unitid == 2) then
		name = "empty"
	elseif (unitid == 1) then
		name = "level"
	end

	local x = x_ or 0
	local y = y_ or 0

	local sleep = hasfeature(name,"is","sleep",unitid,x,y)

	if (sleep ~= nil) then
		return true
	end

	return false
end

function isstill(unitid,x,y)
	name = ""

	if (unitid ~= 1) and (unitid ~= 2) then
		local unit = mmf.newObject(unitid)
		name = getname(unit)
	elseif (unitid == 1) then
		name = "level"
	else
		name = "empty"
	end

	local still = hasfeature(name,"is","still",unitid,x,y)

	if (still ~= nil) then
		return true
	end

	return false
end

function isstill_or_locked(unitid,x,y,dir)
	name = ""

	if (unitid ~= 1) and (unitid ~= 2) then
		local unit = mmf.newObject(unitid)
		name = getname(unit)
	elseif (unitid == 1) then
		name = "level"
	else
		name = "empty"
	end

	local still = canmove(name,unitid,dir,x,y)

	return still
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

function destroylevel(special_)
	if (generaldata.values[MODE] ~= 5) then
		local special = special_ or ""

		local dellist = {}
		for i,unit in ipairs(units) do
			table.insert(dellist, unit.fixed)
		end

		if (#dellist > 0) then
			for i,unitid in ipairs(dellist) do
				local unit = mmf.newObject(unitid)
				local c1,c2 = getcolour(unitid)
				local pmult,sound = checkeffecthistory("destroylevel")

				if (special ~= "infinity") and (special ~= "empty") and (special ~= "bonus") then
					MF_particles("bling",unit.values[XPOS],unit.values[YPOS],10 * pmult,c1,c2,1,1)
				elseif (special == "bonus") then
					MF_particles("win",unit.values[XPOS],unit.values[YPOS],10 * pmult,4,1,1,1)
				end

				delete(unitid,nil,nil,true)
			end
		end

		if (special == "infinity") then
			if (HACK_INFINITY >= 200) then
				writetext(langtext("ingame_infiniteloop"),0,screenw * 0.5 - 12,screenh * 0.5 + 60,0,true,2,true,{4,1},3)
				HACK_INFINITY = 0

				MF_playsound("infinity")
				setsoundname("removal",2)

				local isignid = MF_specialcreate("Special_infinity")
				local isign = mmf.newObject(isignid)

				isign.x = screenw * 0.5
				isign.y = screenh * 0.5 - 36
				MF_setcolour(isignid,4,1)
			end
		elseif (special == "toocomplex") then
			writetext(langtext("ingame_toocomplex"),0,screenw * 0.5 - 12,screenh * 0.5,0,true,2,true,{4,1},3)
			HACK_INFINITY = 0

			MF_playsound("infinity")
			setsoundname("removal",2)
		elseif (special ~= "empty") and (special ~= "bonus") then
			setsoundname("removal",1)
		elseif (special == "bonus") then
			MF_playsound("bonus")
		end

		updatecode = 1
		features = {}
		featureindex = {}
		visualfeatures = {}
		notfeatures = {}
		collectgarbage()
	else
		timedmessage("Destroylevel() called from editor. Report this!")
	end
end

function findunitat(name,x,y)
	local id = x + y * roomsizex

	local result = {}

	if (unitmap[id] ~= nil) then
		for i,v in ipairs (unitmap[id]) do
			local unit = mmf.newObject(v)

			if (unit.strings[UNITNAME] == name) or (name == nil) then
				table.insert(result, v)
			end
		end
	end

	return result
end

function checkwordchanges(unitid,unitname)
	if (#wordunits > 0) then
		for i,v in ipairs(wordunits) do
			if (v[1] == unitid) then
				updatecode = 1
				return
			end
		end
	end

	for i,v in pairs(groupunits) do
		if (i == unitname) then
			updatecode = 1
			return
		end
	end

	if (#wordrelatedunits > 0) then
		for i,v in ipairs(wordrelatedunits) do
			if (v[1] == unitid) then
				updatecode = 1
				return
			end
		end
	end
end

function getpath(root)
	local world = generaldata.strings[WORLD]

	if (root == 1) then
		return "Data/"
	else
		return "Data/Worlds/" .. world .. "/"
	end
end

function append(t1,t2)
	local result = {}

	for i,v in ipairs(t1) do
		table.insert(result, v)
	end

	for i,v in ipairs(t2) do
		table.insert(result, v)
	end

	return result
end

function getname(unit,checktext)
	local result = unit.strings[UNITNAME]

	if (unit.strings[UNITTYPE] == "text") and checktext == "text" then
		result = "text"
	end

	return result
end

function getemptytiles()
	local pos = {}

	for i=1,roomsizex-2 do
		for j=1,roomsizey-2 do
			local tileid = i + j * roomsizex

			if (unitmap[tileid] == nil) then
				table.insert(pos, {i, j})
			else
				if (#unitmap[tileid] == 0) then
					table.insert(pos, {i, j})
				end
			end
		end
	end

	return pos
end

function setsoundname(type,id,short)
	local result = ""

	if (id > 0) then
		local sound = soundnames[id]

		if (sound ~= nil) then
			result = sound.name

			if (sound.count ~= nil) then
				local rnd = math.random(1,sound.count)
				result = result .. tostring(rnd)
			end
		end
	end

	if (short ~= nil) then
		result = result .. short
	end

	--MF_alert(result)

	if (type == "removal") then
		generaldata2.strings[REMOVALSOUND] = result
	elseif (type == "turn") then
		generaldata2.strings[TURNSOUND] = result
	end

	return result
end

function checkturnsound()
	if (generaldata2.strings[TURNSOUND] == "") and (editor.strings[MENU] == "ingame") then
		if updateundo then
			setsoundname("turn",8)
		end
	end
end

function getlevelsurrounds(levelid)
	local level = mmf.newObject(levelid)

	local dirids = {"r","u","l","d","dr","ur","ul","dl","o"}
	local x,y,dir = level.values[XPOS],level.values[YPOS],level.values[DIR]

	local result = tostring(dir) .. ","

	for i,v in ipairs(dirs_diagonals) do
		result = result .. dirids[i] .. ","

		local ox,oy = v[1],v[2]

		local tileid = (x + ox) + (y + oy) * roomsizex

		if (unitmap[tileid] ~= nil) then
			if (#unitmap[tileid] > 0) then
				for a,b in ipairs(unitmap[tileid]) do
					if (b ~= levelid) then
						local unit = mmf.newObject(b)
						local name = getname(unit)

						result = result .. name .. ","
					end
				end
			else
				result = result .. "-" .. ","
			end
		else
			result = result .. "-" .. ","
		end
	end

	generaldata2.strings[LEVELSURROUNDS] = result
end

function parsesurrounds()
	local surrounds = MF_parsestring(generaldata2.strings[LEVELSURROUNDS])
	local result = {}
	local stage = 0

	local dirids = {"r","u","l","d","dr","ur","ul","dl","o"}

	for i,v in ipairs(surrounds) do
		if (i == 1) then
			result.dir = tonumber(v)
		else
			if (v == dirids[stage + 1]) then
				stage = stage + 1
			else
				local dir = dirids[stage]

				if (result[dir] == nil) then
					result[dir] = {}
				end

				table.insert(result[dir], v)
			end
		end
	end

	return result
end

function copytable(t1,t2)
	local result = {}

	for i,v in ipairs(t2) do
		table.insert(result, v)
	end

	table.insert(t1, result)

	return t1
end

function copysubtable(t1,t2)
	for i,v in ipairs(t2) do
		local result = {}
		for a,b in ipairs(v) do
			table.insert(result, b)
		end
		table.insert(t1, result)
	end

	return t1
end

function checkeffecthistory(id)
	local result = false
	local sound = ""
	local mult = 1

	if (effecthistory[id] ~= nil) then
		result = true
		mult = 0.5
		effecthistory[id] = effecthistory[id] + 1

		if (effecthistory[id] % 1 > 0) then
			sound = "_short"
		end

		if (effecthistory[id] > 5) then
			mult = 0.2
		end
	else
		effecthistory[id] = 2
	end

	return mult,sound,result
end

function updateeffecthistory()
	for i,v in pairs(effecthistory) do
		if (v > 1.5) then
			effecthistory[i] = 1.5
		else
			effecthistory[i] = nil
		end
	end
end

function reseteffecthistory()
	effecthistory = {}
end

function genflowercolour()
	local result = ""

	local c = colours.flowers
	local rnd = math.random(1, #c)
	local colour = c[rnd]

	local c1,c2 = colour[1],colour[2]

	result = tostring(c1) .. "," .. tostring(c2)

	return result,c1,c2
end

function gettiledata(id,data)
	local tiledata = tileslist[id]
	local changedata = changes[id] or {}
	local result = ""

	local datapairs =
	{
		name = "name",
	}

	if (tiledata[data] ~= nil) then
		result = tiledata[data]

		local pairing = datapairs[data] or "null"

		if (changes[pairing] ~= nil) then
			result = changes[pairing]
		end
	else
		MF_alert("No tiledata found for " .. id .. " with name " .. data)
	end

	return result
end

function displaybigtext(text_,colour,translated_,offsetx_,offsety_)
	local translated = translated_ or false
	local text = text_

	if translated then
		text = langtext(text_)
	end

	local ox = offsetx_ or 0
	local oy = offsety_ or 0

	local c1 = {colour[1], colour[2]}
	local c2 = {colour[3], colour[4]}

	writetext(text,0,screenw * 0.5 + ox,screenh * 0.5 + oy + 4,0,true,3,true,c2,4)
	writetext(text,0,screenw * 0.5 + ox,screenh * 0.5 + oy,0,true,3,true,c1,4)
end

function gettablestring(t)
	local result = ""

	for i,v in ipairs(t) do
		result = result .. tostring(v)

		if (i < #t) then
			result = result .. ","
		end
	end

	return result
end

function pickoption(opts,opt)
	return opts[opt]
end

function getpathdetails(obj,style_,gate_,req_)
	local name = getactualdata_objlist(obj,"name") or "unknown"

	local styles = { "hidden", "visible" }
	local gates = { "", "levels", "clears", "bonuses", "local levels" }

	local style = styles[style_ + 1] or "error"
	local gate = gates[gate_ + 1] or "error"

	local gatetext = ""
	if (gate_ > 0) and (req_ > 0) then
		gatetext = ", " .. tostring(req_) .. " " .. gate
	end

	local result = name .. " (" .. style .. gatetext .. ")"

	return result
end

function getnamegivingtitle(id)
	local textcode = namegivingtitles[id]
	local result,filters = "","lower,maxlen24"

	if (textcode ~= nil) then
		result = langtext(textcode[1],true)

		if (textcode[2] ~= nil) then
			filters = textcode[2]
		end
	end

	return result,filters
end

function findunits(name,db,conds)
	local result = db or {}

	if (name ~= "empty") and (name ~= "all") and (name ~= "group") then
		if (unitlists[name] ~= nil) then
			for i,v in ipairs(unitlists[name]) do
				table.insert(result, {v, conds})
			end
		end
	end

	return result
end

function flipnot(text)
	local result = ""

	if (string.sub(text, 1, 4) == "not ") then
		result = string.sub(text, 5)
	else
		result = "not " .. text
	end

	return result
end

function inbounds(x,y,style_)
	local style = style_ or 0

	if (style == 1) then
		return (x > 0) and (y > 0) and (x < roomsizex - 1) and (y < roomsizey - 1)
	else
		return (x >= 0) and (y >= 0) and (x < roomsizex) and (y < roomsizey)
	end
end

function findfears(unitid,feartargets,x_,y_)
	local result,resultdir = false,4
	local amount = 0

	local ox,oy = 0,0
	local x,y = 0,0
	local name = ""
	local dir = 4

	if (unitid ~= 2) then
		local unit = mmf.newObject(unitid)
		x,y = unit.values[XPOS],unit.values[YPOS]
		name = getname(unit)
		dir = unit.values[DIR]
	else
		x,y = x_,y_
		name = "empty"
		dir = emptydir(x,y)
	end

	local feardirs = {}
	local maxfear = 0

	for j=0,3 do
		local i = (((dir + 2) + j) % 4) + 1
		local ndrs = ndirs[i]
		ox = ndrs[1]
		oy = ndrs[2]

		local dirfound = false
		local diramount = 0

		if (#feartargets > 0) then
			for a,v in ipairs(feartargets) do
				local foundfears = {}

				if (v ~= "empty") then
					foundfears = findtype({v, nil},x+ox,y+oy,unitid)
				else
					local tileid = (x + ox) + (y + oy) * roomsizex
					if (unitmap[tileid] == nil) or (#unitmap[tileid] == 0) then
						foundfears = {"a","b"}
					end
				end

				if (#foundfears > 0) then
					dirfound = true
					result = true
					resultdir = rotate(i-1)
					diramount = diramount + 1
				end
			end
		end

		if dirfound then
			feardirs[i] = diramount
			maxfear = math.max(maxfear, diramount)
		else
			feardirs[i] = 0
		end
	end

	local totalfeardirs = 0

	for i,v in ipairs(feardirs) do
		if (v >= maxfear) then
			totalfeardirs = totalfeardirs + 1
		else
			feardirs[i] = 0
		end
	end

	if (totalfeardirs > 0) then
		amount = maxfear
	end

	if (totalfeardirs > 1) then
		resultdir = dir
		local searching = true
		local tests = 0

		while searching do
			local problems = false

			if (feardirs[resultdir+1] == 1) then
				problems = true
			else
				local obs,obslist,special = check(unitid,x,y,resultdir)

				local obsresult = 0
				for i,v in ipairs(obs) do
					if (v == 1) then
						obsresult = 1
						break
					end
				end

				if (obsresult ~= 0) then
					problems = true
				end
			end

			if (problems == false) then
				searching = false
			else
				if (tests == 0) then
					resultdir = (resultdir - 1 + 4) % 4
				elseif (tests == 1) then
					resultdir = (resultdir + 2 + 4) % 4
				elseif (tests == 2) then
					resultdir = (resultdir + 1 + 4) % 4
				elseif (tests == 3) then
					resultdir = (resultdir - 2 + 4) % 4
				end

				tests = tests + 1
			end

			if (tests >= 4) then
				searching = false
				result = false
				resultdir = 4
			end
		end
	end

	return result,resultdir,amount
end

function getlettermultiplier()
	local result = 0

	if (generaldata.strings[BUILD] == "m") then
		if (generaldata.strings[LANG] == "en") then
			result = 1
		else
			result = 0.33
		end
	end

	return result
end

function isitbroken(name,id,x,y,checkedconds)
	if (hasfeature(name,"is","broken",id,x,y,checkedconds) ~= nil) then
		return 1
	end

	return 0
end

function getinputcount(listid)
	local data = controlnames[listid] or {}

	return #data
end

function canmove(name,unitid,dir,x,y)
	local still = hasfeature(name,"is","still",unitid,x,y)

	if (still ~= nil) then
		return true
	end

	if (dir ~= nil) then
		local opts = {"lockedright","lockedup","lockedleft","lockeddown"}
		local opt = opts[dir+1]

		if (opt ~= nil) then
			still = hasfeature(name,"is",opt,unitid,x,y)

			if (still ~= nil) then
				return true
			end
		end
	end

	return false
end
