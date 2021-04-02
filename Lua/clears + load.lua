-- Both now clear FULLUNITLIST.
-- Since this is only one function for clears.lua and one for load.lua, I decided to just combine them.
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
	groupmembers = {}
	pushedunits = {}
	customobjects = {}
	cobjects = {}
	condstatus = {}
	emptydata = {}
	leveldata = {}
	leveldata.colours = {}
	leveldata.currcolour = 0

	visiontargets = {}

	generaldata.values[CURRID] = 0
	updateundo = true
	hiddenmap = nil
	levelconversions = {}
	last_key = 0
	auto_dir = {}
	destroylevel_check = false
	destroylevel_style = ""

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
end
function init(tilemapid,roomsizex_,roomsizey_,tilesize_,Xoffset_,Yoffset_,generaldataid,generaldataid2,generaldataid3,generaldataid4,generaldataid5,spritedataid,vardataid,screenw_,screenh_)
	map = TileMap.new(tilemapid)
	generaldata = mmf.newObject(generaldataid)
	generaldata2 = mmf.newObject(generaldataid2)
	generaldata3 = mmf.newObject(generaldataid3)
	generaldata4 = mmf.newObject(generaldataid4)
	generaldata5 = mmf.newObject(generaldataid5)
	spritedata = mmf.newObject(spritedataid)
	vardata = mmf.newObject(vardataid)

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
	wordrelatedunits = {}
	letterunits = {}
	letterunits_map = {}
	paths = {}
	paradox = {}
	movelist = {}
	effecthistory = {}
	notfeatures = {}
	groupfeatures = {}
	groupmembers = {}
	pushedunits = {}
	customobjects = {}
	cobjects = {}
	condstatus = {}
	emptydata = {}
	leveldata = {}
	leveldata.colours = {}
	leveldata.currcolour = 0
	undobuffer_editor = {{}}
	latestleveldetails = {lnum = -1, ltype = -1}
	edgetiles = {}
	funnywalls = {}
	visiontargets = {}

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
	destroylevel_check = false
	destroylevel_style = ""

	HACK_MOVES = 0
	HACK_INFINITY = 0
	movemap = {}

	Seed = 0
	Fixedseed = 100
	Seedingtype = 0

	base_octave = 3

	nlist = {}
	setupnounlists()
	generatetiles()
	formatobjlist()
	generatefreqs()

	baserulelist = {}
	setupbaserules()
end
