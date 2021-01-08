function init(tilemapid,roomsizex_,roomsizey_,tilesize_,Xoffset_,Yoffset_,generaldataid,generaldataid2,generaldataid4,generaldataid5,spritedataid,screenw_,screenh_)
	map = TileMap.new(tilemapid)
	generaldata = mmf.newObject(generaldataid)
	generaldata2 = mmf.newObject(generaldataid2)
	generaldata4 = mmf.newObject(generaldataid4)
	generaldata5 = mmf.newObject(generaldataid5)
	spritedata = mmf.newObject(spritedataid)

	roomsizex = roomsizex_
	roomsizey = roomsizey_
	tilesize = tilesize_
	f_tilesize = spritedata.values[FIXEDTILESIZE]
	Xoffset = Xoffset_
	Yoffset = Yoffset_

	screenw = screenw_
	screenh = screenh_

	features = {}
	visualfeatures = {}
	featureindex = {}
	condfeatureindex = {}
	objectdata = {}
	units = {}
	tiledunits = {}
	codeunits = {}
	unitlists = {}
	objectlist = {}
	fullunitlist = {}
	undobuffer = {}
	animunits = {}
	unitmap = {}
	unittypeshere = {}
	deleted = {}
	ruleids = {}
	updatelist = {}
	objectcolours = {}
	wordunits = {}
	groupunits = {}
	wordrelatedunits = {}
	letterunits = {}
	letterunits_map = {}
	paths = {}
	paradox = {}
	movelist = {}
	effecthistory = {}
	notfeatures = {}
	groupfeatures = {}
	pushedunits = {}
	customobjects = {}
	cobjects = {}
	condstatus = {}
	leveldata = {}
	leveldata.colours = {}
	leveldata.currcolour = 0
	undobuffer_editor = {{}}
	latestleveldetails = {lnum = -1, ltype = -1}

	generaldata.values[CURRID] = 0
	updatecode = 1
	doundo = true
	updateundo = true
	ruledebug = false
	modsinuse = false
	maprotation = 0
	mapdir = 3
	last_key = 0
	levelconversions = {}
	auto_dir = {}

	HACK_MOVES = 0
	HACK_INFINITY = 0
	movemap = {}

	Seed = 0
	Fixedseed = 100
	Seedingtype = 0

	mpath_marray = {}
	mpath_parray = {}
	mpath_lines = {}

	base_octave = 2

	generatetiles()
	formatobjlist()
	generatefreqs()
end

if (fixed_to_str == nil) then
	fixed_to_str = tostring
end

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

	if (unit.strings[UNITTYPE] ~= "text") or ((unit.strings[UNITTYPE] == "text") and (unit.values[TYPE] == 0)) then
		objectlist[name_] = 1
	end
	fullunitlist[name] = 1
	fullunitlist[name_] = 1

	if (unit.strings[UNITTYPE] == "text") then
		table.insert(codeunits, unit.fixed)
		updatecode = 1

		if (unit.values[TYPE] == 0) then
			local matname = string.sub(unit.strings[UNITNAME], 6)
			if (unitlists[matname] == nil) then
				unitlists[matname] = {}
			end
		elseif (unit.values[TYPE] == 5) then
			table.insert(letterunits, unit.fixed)
		end
	end

	if (unit.strings[UNITNAME] ~= "level") and (unit.className ~= "specialobject") then
		setcolour(unit.fixed)
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
end

function clearunits(restore_)
	units = {}
	tiledunits = {}
	codeunits = {}
	animunits = {}
	unitlists = {}
	undobuffer = {}
	unitmap = {}
	unittypeshere = {}
	prevunitmap = {}
	ruleids = {}
	objectlist = {}
	fullunitlist = {}
	updatelist = {}
	objectcolours = {}
	wordunits = {}
	groupunits = {}
	wordrelatedunits = {}
	letterunits = {}
	letterunits_map = {}
	paths = {}
	paradox = {}
	movelist = {}
	deleted = {}
	effecthistory = {}
	notfeatures = {}
	groupfeatures = {}
	pushedunits = {}
	customobjects = {}
	cobjects = {}
	condstatus = {}
	leveldata = {}
	leveldata.colours = {}
	leveldata.currcolour = 0

	mpath_marray = {}
	mpath_parray = {}
	mpath_lines = {}

	generaldata.values[CURRID] = 0
	updateundo = true
	hiddenmap = nil
	levelconversions = {}
	last_key = 0
	auto_dir = {}

	HACK_MOVES = 0
	HACK_INFINITY = 0
	movemap = {}

	local restore = true
	if (restore_ ~= nil) then
		restore = norestore_
	end

	if restore then
		newundo()

		print("clearunits")

		restoredefaults()
	end

	mmf.resetObjectCache()
end

function smallclear()
	objectdata = {}
	deleted = {}
	updatelist = {}
	movelist = {}
	pushedunits = {}
	levelconversions = {}

	HACK_MOVES = 0
	HACK_INFINITY = 0
	movemap = {}

	if (#units > 2000) then
		destroylevel("toocomplex")
		updateundo = true
	end
end

function clear()
	features = {}
	featureindex = {}
	condfeatureindex = {}
	visualfeatures = {}
	objectdata = {}
	deleted = {}
	ruleids = {}
	updatelist = {}
	wordunits = {}
	groupunits = {}
	wordrelatedunits = {}
	letterunits_map = {}
	paradox = {}
	movelist = {}
	effecthistory = {}
	notfeatures = {}
	groupfeatures = {}
	pushedunits = {}
	condstatus = {}
	leveldata = {}
	leveldata.colours = {}
	leveldata.currcolour = 0

	mpath_marray = {}
	mpath_parray = {}
	mpath_lines = {}

	updatecode = 1
	updateundo = false
	hiddenmap = nil
	levelconversions = {}
	maprotation = 0
	mapdir = 3
	last_key = 0
	auto_dir = {}

	HACK_MOVES = 0
	HACK_INFINITY = 0
	movemap = {}

	print("clear")
	collectgarbage()
end

function command(key,player_)
	local keyid = -1
	if (keys[key] ~= nil) then
		keyid = keys[key]
	else
		print("no such key")
		return
	end

	local player = 1
	if (player_ ~= nil) then
		player = player_
	end

	do_mod_hook("command_given", {key,player})

	if (keyid <= 4) then
		if (generaldata5.values[AUTO_ON] == 0) then
			local drs = ndirs[keyid+1]
			local ox = drs[1]
			local oy = drs[2]
			local dir = keyid

			last_key = keyid

			if (auto_dir[player] == nil) then
				auto_dir[player] = 4
			end

			auto_dir[player] = keyid

			movecommand(ox,oy,dir,player)
			MF_update()
		else
			if (auto_dir[player] == nil) then
				auto_dir[player] = 4
			end

			auto_dir[player] = keyid

			if (auto_dir[1] == nil) and (featureindex["you2"] == nil) then
				auto_dir[1] = keyid
			end
		end
	end

	if (keyid == 5) then
		MF_restart(false)
		do_mod_hook("level_restart", {})
	elseif (keyid == 8) then
		MF_restart(true)
		do_mod_hook("level_restart", {})
	end

	dolog(key)
end

function command_auto()
	local moving = false
	local firstp = -1
	local secondp = -1

	if (auto_dir[1] ~= nil) then
		firstp = auto_dir[1]
		moving = true
	else
		firstp = 4
		moving = true
	end

	if (auto_dir[2] ~= nil) then
		secondp = auto_dir[2]
		moving = true
	else
		secondp = 4
		moving = true
	end

	do_mod_hook("turn_auto", {firstp,secondp,moving})

	if moving and (generaldata5.values[AUTO_ON] > 0) then
		for i=1,generaldata5.values[AUTO_ON] do
			if (firstp ~= 4) then
				last_key = firstp
			elseif (secondp ~= 4) then
				last_key = secondp
			else
				last_key = 4
			end

			local drs = ndirs[firstp+1]
			local ox = drs[1]
			local oy = drs[2]
			local dir = firstp

			movecommand(ox,oy,dir,3,secondp)
		end

		MF_update()
	end

	auto_dir = {}
end

function dolog(key)
	MF_log(key)
end

function createall(matdata,x_,y_,id_,dolevels_,leveldata_)
	local all = {}
	local empty = false
	local dolevels = dolevels_ or false

	local leveldata = leveldata_ or {}

	if (x_ == nil) and (y_ == nil) and (id_ == nil) then
		if (matdata[1] ~= "empty") and (matdata[1] ~= "group") then
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

	local delthese = {}

	if (#test > 0) then
		for i,v in ipairs(test) do
			if (empty == false) then
				local vunit = mmf.newObject(v)
				local x,y,dir = vunit.values[XPOS],vunit.values[YPOS],vunit.values[DIR],vunit.values[MOVED]

				for b,unit in pairs(objectlist) do
					if (b ~= "empty") and (b ~= "all") and (b ~= "level") and (b ~= "group") and (b ~= matdata[1]) and (b ~= "text") and (string.sub(b, 1, 5) ~= "text_") then
						local protect = hasfeature(matdata[1],"is","not " .. b,v,x,y)

						if (protect == nil) then
							local mat = findtype({b},x,y,v)
							--local tmat = findtext(x,y)

							if (#mat == 0) then
								create(b,x,y,dir,nil,nil,nil,nil,leveldata)


								if (matdata[1] == "text") or (string.sub(matdata[1], 1, 5) == "text_") or (matdata[1] == "level") then
									table.insert(delthese, v)
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
						if (b ~= "empty") and (b ~= "all") and (b ~= "level") and (b ~= "group") and (b ~= "text") and (string.sub(b, 1, 5) ~= "text_") and (blocked[target] == nil)  then
							create(b,x,y,dir,nil,nil,nil,nil,leveldata)
						end
					end
				end
			end
		end
	end

	for a,b in ipairs(delthese) do
		delete(b)
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
				if (b ~= "empty") and (b ~= "all") and (b ~= "level") and (b ~= "group") and (blocked[target] == nil) then
					table.insert(levelconversions, {b, {}})
				end
			end
		end
	end
end

function setunitmap()
	unitmap = {}
	unittypeshere = {}
	local delthese = {}

	local limit = 6

	if (generaldata.strings[WORLD] == generaldata.strings[BASEWORLD]) and ((generaldata.strings[CURRLEVEL] == "89level") or (generaldata.strings[CURRLEVEL] == "33level")) then
		limit = 3
	end

	if (generaldata.strings[WORLD] == "baba_m") and ((generaldata.strings[CURRLEVEL] == "89level") or (generaldata.strings[CURRLEVEL] == "33level")) then
		limit = 2
	end

	for i,unit in ipairs(units) do
		local tileid = unit.values[XPOS] + unit.values[YPOS] * roomsizex
		local valid = true

		--print(tostring(unit.values[XPOS]) .. ", " .. tostring(unit.values[YPOS]) .. ", " .. unit.strings[UNITNAME])

		if (unitmap[tileid] == nil) then
			unitmap[tileid] = {}
			unittypeshere[tileid] = {}
		end

		local uth = unittypeshere[tileid]
		local name = unit.strings[UNITNAME]

		if (uth[name] == nil) then
			uth[name] = 0
		end

		if (uth[name] < limit) then
			uth[name] = uth[name] + 1
		elseif (string.len(unit.strings[U_LEVELFILE]) == 0) then
			table.insert(delthese, unit)
			valid = false
		end

		if valid then
			table.insert(unitmap[tileid], unit.fixed)
		end
	end

	for i,unit in ipairs(delthese) do
		local x,y,dir,unitname = unit.values[XPOS],unit.values[YPOS],unit.values[DIR],unit.strings[UNITNAME]
		addundo({"remove",unitname,x,y,dir,unit.values[ID],unit.values[ID],unit.strings[U_LEVELFILE],unit.strings[U_LEVELNAME],unit.values[VISUALLEVEL],unit.values[COMPLETED],unit.values[VISUALSTYLE],unit.flags[MAPLEVEL],unit.strings[COLOUR],unit.strings[CLEARCOLOUR],unit.followed,unit.back_init})
		delunit(unit.fixed)
		MF_remove(unit.fixed)
	end
end

function setundo(this)
	if (this ~= nil) then
		if (this == 1) then
			updateundo = true
		elseif (this == 0) then
			updateundo = false
		end
	else
		print("undo is nil!")
		updateundo = true
	end
end

function victory()
	MF_win()
end

function poscorrect(unitid,rotation,zoom,offset)
	local unit = mmf.newObject(unitid)

	local midpointx = roomsizex * tilesize * 0.5 * spritedata.values[TILEMULT]
	local midtilex = math.floor(roomsizex * 0.5) - 0.5

	if (roomsizex % 2 == 1) then
		midtilex = math.floor(roomsizex * 0.5)
	end

	local midpointy = roomsizey * tilesize * 0.5 * spritedata.values[TILEMULT]
	local midtiley = math.floor(roomsizey * 0.5) - 0.5

	if (roomsizey % 2 == 1) then
		midtiley = math.floor(roomsizey * 0.5)
	end

	local x,y = unit.values[XPOS],unit.values[YPOS]
	local dx = x - midtilex
	local dy = y - midtiley

	local dir = 0 - math.atan2(dy,dx) + math.rad(rotation)
	local dist = math.sqrt((dy)^2 + (dx)^2)

	local newx = Xoffset + midpointx + math.cos(dir) * dist * zoom * tilesize * spritedata.values[TILEMULT]
	local newy = Yoffset + midpointy - math.sin(dir) * dist * zoom * tilesize * spritedata.values[TILEMULT]

	if (unit.values[FLOAT] == 0) then
		unit.x = newx
		unit.y = newy + offset * spritedata.values[TILEMULT]
	elseif (unit.values[FLOAT] == 1) then
		unit.x = newx
		--unit.y = newy + offset * spritedata.values[TILEMULT]
	end
end

function stringintable(this,data)
	if (#data > 0) then
		for i,v in ipairs(data) do
			if (this == v) then
				return true
			end
		end
	end

	return false
end

function levelborder(absolute_,ox_,oy_)
	local edgetiles = {}
	local l = map[0]

	local absolute = absolute_ or false
	local ox,oy = Xoffset,Yoffset

	if absolute then
		ox = ox_
		oy = oy_
	end

	for i=0,roomsizex-1 do
		for j=0,roomsizey-1 do
			if (i == 0) or (j == 0) or (i == roomsizex-1) or (j == roomsizey-1) then
				local unitid = MF_create("edge")
				local unit = mmf.newObject(unitid)

				table.insert(edgetiles, unitid)

				unit.layer = 1
				unit.values[ONLINE] = 1
				unit.values[XPOS] = i
				unit.values[YPOS] = j
				unit.values[POSITIONING] = 20
				unit.x = ox + i * tilesize * spritedata.values[TILEMULT] + tilesize * 0.5 * spritedata.values[TILEMULT]
				unit.y = oy + j * tilesize * spritedata.values[TILEMULT] + tilesize * 0.5 * spritedata.values[TILEMULT]
				unit.scaleX = spritedata.values[SPRITEMULT] * spritedata.values[TILEMULT]
				unit.scaleY = spritedata.values[SPRITEMULT] * spritedata.values[TILEMULT]

				l:set(i,j,0,0)
			end
		end
	end

	local c1,c2 = getuicolour("edge")

	for i,unitid in ipairs(edgetiles) do
		local unit = mmf.newObject(unitid)

		local dynamicdir = dynamictile(unitid,unit.values[XPOS],unit.values[YPOS],"edge")

		unit.direction = dynamicdir

		MF_setcolour(unitid,c1,c2)
	end
end

function updatescreen(x,y)
	Xoffset = x
	Yoffset = y
end

function updateroomsize(tilesize_,roomsizex_,roomsizey_)
	tilesize = tilesize_

	roomsizex = roomsizex_
	roomsizey = roomsizey_

	local delthese = {}

	for i,unit in pairs(units) do
		if (unit.values[XPOS] >= roomsizex - 1) or (unit.values[YPOS] >= roomsizey - 1) then
			table.insert(delthese, unit.fixed)
		else
			MF_setsublayer(0,unit.values[XPOS],unit.values[YPOS],unit.values[LAYER],unit.values[DIR])
		end
	end

	for i,v in ipairs(delthese) do
		local unit = mmf.newObject(v)

		if (generaldata.values[MODE] == 5) then
			removetile(unit.fixed,unit.values[XPOS],unit.values[YPOS])
		else
			delunit(unit.fixed)
		end
	end

	setunitmap()
end

function checkerasesafety(text_)
	local text = string.sub(text_, 2, string.len(text_) - 1)

	local delete = true

	MF_alert(text_ .. ", " .. text)

	if (string.sub(text, 1, 5) == "baba_") and (string.sub(text, -8) == "_convert") and (string.len(text) > 13) then
		delete = false
	end

	local sparethese =
	{
		baba = 1,
		baba_prize = 2,
		baba_clears = 3,
		baba_bonus = 4,
		baba_complete = 5,
		baba_converts = 6,
		baba_converts_single = 7,
		baba_end_single = 8,
		baba_done_single = 9,
	}

	if (sparethese[text] ~= nil) then
		delete = false
	end

	return delete,text
end

function fixedrandom(low,high)
	if (Seedingtype > 0) then
		Seed = math.random(0, 0x7FFFFFFF)
		math.randomseed(Fixedseed)
	end

	local result = math.random(low, high)

	if (Seedingtype > 0) then
		Fixedseed = math.random(0, 0x7FFFFFFF)
		math.randomseed(Seed)
	end

	return result
end

function setfixedrandom(text)
	if (Seedingtype == 2) then
		Fixedseed = string.len(text) * #units
	elseif (Seedingtype == 1) then
		Fixedseed = MF_random(1, 0x7FFFFFFF)
	end
end

function overrideundoseeding()
	local undob = undobuffer[1]
	undob.fixedseed = Fixedseed
end

function setseedingtype(t)
	Seedingtype = t
end

function generatefreqs()
	local notes = {"a","asharp","b","c","csharp","d","dsharp","e","f","fsharp","g","gsharp"}
	local octaves = 3
	local base = base_octave
	local basefreq = 24000
	local freq = basefreq
	local step = 2 ^ (1/12)
	local prev = ""

	for i,v in ipairs(notes) do
		play_data.freqs[v] = math.floor(freq)

		freq = freq * step
	end

	freq = basefreq

	play_data.freqs["aflat"] = freq / step

	for i,v in ipairs(notes) do
		if (string.sub(v, -5) ~= "sharp") then
			local name = v .. "flat"
			local pair = prev .. "sharp"

			if (play_data.freqs[pair] ~= nil) then
				play_data.freqs[name] = play_data.freqs[pair]
			end

			prev = v
		end
	end

	for j_=1,octaves do
		local j = base + (j_-1)
		freq = (basefreq * 0.5) * 2 ^ j_
		prev = ""

		for i,v in ipairs(notes) do
			local name = v .. tostring(j)
			play_data.freqs[name] = math.floor(freq)

			freq = freq * step
		end

		freq = (basefreq * 0.5) * 2 ^ j_

		local aflat = "aflat" .. tostring(j)
		play_data.freqs[aflat] = freq / step

		for i,v in ipairs(notes) do
			if (string.sub(v, -5) ~= "sharp") then
				local name = v .. "flat" .. tostring(j)
				local pair = prev .. "sharp" .. tostring(j)

				if (play_data.freqs[pair] ~= nil) then
					play_data.freqs[name] = play_data.freqs[pair]
				end

				prev = v
			end
		end
	end
end
