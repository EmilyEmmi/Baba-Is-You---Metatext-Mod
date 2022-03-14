-- Use the in-game menu now.

table.insert( mod_hook_functions["level_start"], function()

metatext_fixquirks = get_setting("fix_quirks") --[[Set this to FALSE to:
Make TEXT IS TELE link text units of the same type together rather than all text units
Make TEXT IS MORE allow text units to grow into other text units as long as they are not the same type
Make TEXT IS GROUP, NOUN HAS/MAKE GROUP make NOUN HAS/MAKE every text in the level.]]

metatext_overlaystyle = get_setting("overlay_style",true) --[[Has 3 options:
0 disables this feature.
1 enables overlay if the "meta level" (the amount of times "text_" appears in the name excluding
if the name ends with "text_") does not match the name of the object.
Anything else always enables the overlay.]]

metatext_textisword = get_setting("text_word") --Makes TEXT IS WORD a default rule, and breaking it will make text not parse.

metatext_istextnometa = get_setting("is_nometa") --[[Makes METATEXT IS TEXT not turn the text object into it's metatext
counterpart, instead making it not transform.
Not recommended to set to TRUE if you are not using the Meta/Unmeta addon.]]

metatext_hasmaketextnometa = get_setting("hasmake_nometa") --[[Makes METATEXT HAS/MAKE TEXT not make the text object have/make
it's metatext counterpart. Since you can't make Has/Make Meta/Unmeta, this is really only useful for
consistency I guess.]]

metatext_autogenerate = get_setting("auto_gen",true) --[[Tries to add more metatext to the object palette if it does not exist.
Can only add up to 35 additional objects. REQUIRES metaunmeta.lua.
Comes with the following options:
0 disables this feature.
1 tries to use the correct sprite, if it exists. Otherwise, it uses the default.
2 is like 1, but if the sprite doesn't exist, it won't generate.
Anything else always uses the default sprite. If you choose this, you're gonna want the overlay on.
Note that if the nonexistant text is available in the editor object list, that will be referenced instead.]]

metatext_egg = get_setting("easter_egg") --Easter egg. Set to FALSE to disable.

end
)

-- New function, checks if rule relies on TEXT noun. Based off of hasfeature()
function checkiftextrule(rule1,rule2,rule3,unitid,findtextrule_)
  local findtextrule = false
  if findtextrule_ ~= nil then
    findtextrule = findtextrule_
  end
  if (featureindex[rule3] ~= nil) and (rule2 ~= nil) and (rule1 ~= nil) then
		for i,rules in ipairs(featureindex[rule3]) do
			local rule = rules[1]
			local conds = rules[2]
      local tags = rules[4]
      local foundtag = false
      for num,tag in pairs(tags) do
        if tag == "text" then
          foundtag = true
          break
        end
      end

			if (conds[1] ~= "never") and (foundtag == findtextrule) then
				if (rule[1] == rule1) and (rule[2] == rule2) and (rule[3] == rule3) then
					if testcond(conds,unitid) then
						return findtextrule
					end
				end
			end
		end
	end
	return (not findtextrule)
end

-- New function that writes the meta level of an object in the top right corner, if enabled.
function writemetalevel()
  if metatext_overlaystyle ~= 0 and not (generaldata.values[MODE] == 5) then
    MF_letterclear("metaoverlay")
    for id,unit in pairs(units) do
      local unitname = unit.strings[UNITNAME]
      if string.sub(unitname,1,10) == "text_text_" and unit.values[TYPE] == 0 and unit.visible then
        local _,metalevel = string.gsub(unitname,"text_","text_")
        if string.sub(unitname,-5) == "text_" then
          metalevel = metalevel - 2
        else
          metalevel = metalevel - 1
        end
        local show = true
        if metatext_overlaystyle == 1 then
          local c = changes[unit.className] or {}
          if c.image == nil then
            show = false
          else
            local _,imetalevel = string.gsub(c.image,"text_","text_")
            if string.sub(c.image,-5) == "text_" then
              imetalevel = imetalevel - 2
            else
              imetalevel = imetalevel - 1
            end
            if imetalevel == metalevel then
              show = false
            end
          end
        end
        if show then
          local color = {4,1}
          local unitcolor1,unitcolor2 = getcolour(unit.fixed)
          if unit.colours ~= nil and #unit.colours > 0 then
            local rosytaken = false
            for z,c in pairs(unit.colours) do
              unitcolor1,unitcolor2 = c[1],c[2]
              if tonumber(unitcolor1) == 4 and tonumber(unitcolor2) == 2 then
                rosytaken = true
                if color == {4,2} then
                  color = {4,0}
                  break
                end
              end
              if color[1] == tonumber(unitcolor1) and color[2] == tonumber(unitcolor2) then
                if rosytaken then
                  color = {4,0}
                  break
                else
                  color = {4,2}
                end
              end
            end
          else
            if unit.active == true or generaldata.values[MODE] == 5 then
              unitcolor1,unitcolor2 = getcolour(unit.fixed,"active")
            end
            if color[1] == tonumber(unitcolor1) and color[2] == tonumber(unitcolor2) then
              color = {4,2}
            end
          end
          writetext(metalevel,unit.fixed,(8 * spritedata.values[TILEMULT]),-(6 * spritedata.values[TILEMULT]),"metaoverlay",true,1,true,color)
        end
      end
    end
  end
end
table.insert( mod_hook_functions["always"], writemetalevel)

-- Allows TEXT_ to also act as a letter, and enables TEXT IS WORD behavior with letters if enabled
function formlettermap()
	letterunits_map = {}

	local lettermap = {}
	local letterunitlist = {}

	if (#letterunits > 0) then
		for i,unitid in ipairs(letterunits) do
			local unit = mmf.newObject(unitid)

			if (unit.values[TYPE] == 5 or (unit.values[TYPE] == 4 and unit.strings[UNITNAME] == "text_text_")) and (unit.flags[DEAD] == false) then
        local valid = true
        if metatext_textisword and (#wordunits > 0) then
          valid = false
          for c,d in ipairs(wordunits) do
            if (unitid == d[1]) and testcond(d[2],d[1]) then
              valid = true
              break
            end
          end
        end
        if valid then
          local x,y = unit.values[XPOS],unit.values[YPOS]
          local tileid = x + y * roomsizex

          local name = string.sub(unit.strings[UNITNAME], 6)

          if (lettermap[tileid] == nil) then
            lettermap[tileid] = {}
          end

          table.insert(lettermap[tileid], {name, unitid})
        end
			end
		end

		for tileid,v in pairs(lettermap) do
			local x = math.floor(tileid % roomsizex)
			local y = math.floor(tileid / roomsizex)

			local ux,uy = x,y-1
			local lx,ly = x-1,y
			local dx,dy = x,y+1
			local rx,ry = x+1,y

			local tidr = rx + ry * roomsizex
			local tidu = ux + uy * roomsizex
			local tidl = lx + ly * roomsizex
			local tidd = dx + dy * roomsizex

			local continuer = false
			local continued = false

			if (lettermap[tidr] ~= nil) then
				continuer = true
			end

			if (lettermap[tidd] ~= nil) then
				continued = true
			end

			if (#cobjects > 0) then
				for a,b in ipairs(v) do
					local n = b[1]
					if (cobjects[n] ~= nil) then
						continuer = true
						continued = true
						break
					end
				end
			end

			if (lettermap[tidl] == nil) and continuer then
				letterunitlist = formletterunits(x,y,lettermap,1,letterunitlist)
			end

			if (lettermap[tidu] == nil) and continued then
				letterunitlist = formletterunits(x,y,lettermap,2,letterunitlist)
			end
		end

		if (unitreference["text_play"] ~= nil) then
			letterunitlist = cullnotes(letterunitlist)
		end

		for i,v in ipairs(letterunitlist) do
			local x = v[3]
			local y = v[4]
			local w = v[6]
			local dir = v[5]

			local dr = dirs[dir]
			local ox,oy = dr[1],dr[2]

      --[[
      MF_debug(x,y,1)
      MF_alert("In database: " .. v[1] .. ", dir " .. tostring(v[5]))
      ]]--

			local tileid = x + y * roomsizex

			if (letterunits_map[tileid] == nil) then
				letterunits_map[tileid] = {}
			end

			table.insert(letterunits_map[tileid], {v[1], v[2], v[3], v[4], v[5], v[6], v[7]})

			if (w > 1) then
				local endtileid = (x + ox * (w - 1)) + (y + oy * (w - 1)) * roomsizex

				if (letterunits_map[endtileid] == nil) then
					letterunits_map[endtileid] = {}
				end

				table.insert(letterunits_map[endtileid], {v[1], v[2], v[3], v[4], v[5], v[6], v[7]})
			end
		end
	end
end
-- Fix a bug where TEXT_ spells itself, causing rule duplication
-- unfortunatly, that means TEXT_ cannot be spelled with letters
function findletterwords(word_,wordpos_,subword_,mainbranch_)
	local word = word_
	local subword = subword_
	local wordpos = wordpos_ or 0
	local mainbranch = true
	local found = false
	local foundsub = false
	local fullwords = {}
	local fullwords_c = {}
	local newbranches = {}

	if (mainbranch_ ~= nil) then
		mainbranch = mainbranch_
	end

	local result = {}

	if (string.len(word) > 1) then
		for i,v in pairs(unitreference) do
			local name = i

			if (string.len(name) > 5) and (string.sub(name, 1, 5) == "text_") then
				name = string.sub(name, 6)
			end

			if (string.len(word) <= string.len(name)) and (string.sub(name, 1, string.len(word)) == word) then
				if (string.len(word) == string.len(name)) then
					table.insert(fullwords, {name, 0})
					found = true
				else
					found = true
				end
			end

			if (wordpos > 0) and (string.len(word) >= 2) and mainbranch then
				if (string.len(name) >= string.len(subword)) and (string.sub(name, 1, string.len(subword)) == subword) then

					if (subword == name) then
						table.insert(fullwords, {name, wordpos + 1})
						foundsub = true
					else
						table.insert(newbranches, {subword, wordpos})
						foundsub = true
					end


					table.insert(newbranches, {subword, wordpos})
					foundsub = true
				end
			end
		end
	end

	if (string.len(word) > 0) then
		for c,d in pairs(cobjects) do
			if (c ~= 1) and (string.len(tostring(c)) > 0) then
				local name = c

				if (string.len(name) > 5) and (string.sub(name, 1, 5) == "text_") then
					name = string.sub(name, 6)
				end

				if (string.len(word) <= string.len(name)) and (string.sub(name, 1, string.len(word)) == word) then
					if (string.len(word) == string.len(name)) then
						table.insert(fullwords_c, {name, 0})
						found = true
					else
						found = true
					end
				end

				if (wordpos > 0) and (string.len(word) >= 2) and mainbranch then
					if (string.len(name) >= string.len(subword)) and (string.sub(name, 1, string.len(subword)) == subword) then
						table.insert(newbranches, {subword, wordpos})
						foundsub = true
					end
				end
			end
		end
	end

	if (string.len(word) <= 1) then
		found = true
	end

	if (#fullwords > 0) then
		for i,v in ipairs(fullwords) do
			local text = v[1]
			local textpos = v[2]
			local alttext = "text_" .. text

			local name_base = unitreference[text]
			local name_general = objectpalette[text]
			local altname_base = unitreference[alttext]
			local altname_general = objectpalette[alttext]

			local realname = altname_general
			local realname_general = name_general

			if (generaldata.strings[WORLD] == generaldata.strings[BASEWORLD]) then
				realname = altname_base
				realname_general = name_base
			end

			if (realname ~= nil) then
				local name = getactualdata_objlist(realname,"name")
				local wtype = getactualdata_objlist(realname,"type")

				if string.sub(name,-5) ~= "text_" and ((name == text) or (name == alttext)) then
					if (wtype ~= 5) then
						if (realname_general ~= nil) then
							objectlist[text] = 1
						elseif (((text == "all") or (text == "empty")) and (realname ~= nil)) then
							objectlist[text] = 1
						end

						table.insert(result, {name, wtype, textpos})
					end
				end
			end
		end
	end

	if (#fullwords_c > 0) then
		for i,v in ipairs(fullwords_c) do
			if (word == v[1]) then
				table.insert(result, {v[1], 8, v[2]})
			end
		end
	end

	return found,result,newbranches
end

-- Try to add more metatext if it doesn't exist.
function tryautogenerate(want,tilename)
  if metatext_autogenerate ~= 0 then
    if want == nil then
      local test = tilename
      local count = 0
      if objectpalette["text_" .. test] == nil then
        while objectpalette[test] == nil do
          if string.sub(test,1,5) == "text_" then
            test = string.sub(test,6)
            count = count + 1
          else
            return false
          end
        end
        local prefix = string.sub(tilename,1,(5*count))
        tilename = test
        want = prefix .. tilename
      else
        want = tilename
        tilename = "text_" .. test
      end
    end
    if editor_objlist_reference[want] ~= nil then
      local data = editor_objlist[editor_objlist_reference[want]]
      local root = data.sprite_in_root
      if root == nil then
        root = true
      end
      local colour = data.colour
      local active = data.colour_active
      local colourasstring = colour[1] .. "," .. colour[2]
      local activeasstring = active[1] .. "," .. active[2]
      local new =
      {
          want,
          data.sprite or data.name,
          colourasstring,
          data.tiling,
          0,
          "text",
          activeasstring,
          root,
          data.layer or 10,
          nil,
      }
      local target = "120"
      while target ~= nil do
        local done = true
        for objname,data in pairs(objectpalette) do
          if data == "object" .. target then
            done = false
            target = tostring(tonumber(target) + 1)
            while string.len(target) < 3 do
              target = "0" .. target
            end
          end
        end
        if done then break end
      end
      savechange("object" .. target,new,nil,true)
      dochanges_full("object" .. target)
      objectpalette[want] = "object" .. target
      objectlist[want] = 1
      if root == true then
        fullunitlist[want] = "fixroot" .. (data.sprite or data.name)
      else
        fullunitlist[want] = "fix" .. (data.sprite or data.name)
      end
      return true
    else
      local realname = objectpalette[tilename]
      local root = getactualdata_objlist(realname,"sprite_in_root")
      local colour = getactualdata_objlist(realname,"colour")
      local active = getactualdata_objlist(realname,"active")
      if colour == nil then
        return false
      end
      local sprite = getactualdata_objlist(realname,"sprite",true) or getactualdata_objlist(realname,"name")
      local colourasstring = colour[1] .. "," .. colour[2]
      local activeasstring = active[1] .. "," .. active[2]
      local new =
      {
          want,
          sprite,
          colourasstring,
          getactualdata_objlist(realname,"tiling"),
          0,
          "text",
          activeasstring,
          root,
          getactualdata_objlist(realname,"layer"),
          nil,
      }
      if metatext_autogenerate == 1 or metatext_autogenerate == 2 then
        if MF_findsprite("text_"..sprite.."_0_1.png",false) then
          sprite = "text_"..sprite
          new[2] = sprite
          root = false
          new[8] = root
        elseif metatext_autogenerate == 2 then
          return false
        end
      end
      local target = "120"
      while target ~= "156" do
        local done = true
        for objname,data in pairs(objectpalette) do
          if data == "object" .. target then
            done = false
            target = tostring(tonumber(target) + 1)
            while string.len(target) < 3 do
              target = "0" .. target
            end
          end
        end
        if done then break end
      end
      if target == "156" then
        return false
      else
        savechange("object" .. target,new,nil,true)
        dochanges_full("object" .. target)
        objectpalette[want] = "object" .. target
        objectlist[want] = 1
        if root == true then
          fullunitlist[want] = "fixroot" .. sprite
        else
          fullunitlist[want] = "fix" .. sprite
        end
        return true
      end
    end
  end
  return false
end

-- Allows metatext to be named in editor.
function editor_trynamechange(object,newname_,fixed,objlistid,oldname_)
	local valid = true

	local newname = newname_ or "error"
	local oldname = oldname_ or "error"
	local checking = true

	newname = string.gsub(newname, "_", "UNDERDASH")
	newname = string.gsub(newname, "%W", "")
	newname = string.gsub(newname, "UNDERDASH", "_")

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

    if string.find(newname, "text_text_") == nil then
  		for i,v in ipairs(editor_currobjlist) do
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
  		end
    end
	end

	return valid
end

-- Fix issue with FEAR.
function getunitverbtargets(rule2)
	local group = {}
	local result = {}

	if (featureindex[rule2] ~= nil) then
		for i,v in ipairs(featureindex[rule2]) do
			local rule = v[1]
			local conds = v[2]

			local name = rule[1]

			local isnot = string.sub(rule[3], 1, 4)

			if (rule[2] == rule2) and (conds[1] ~= "never") and (findnoun(rule[1],nlist.brief) == false) and (isnot ~= "not ") and (rule[1] ~= "text") then
				if (group[name] == nil) then
					group[name] = {}
				end

				table.insert(group[name], {rule[3], conds})
			end
		end

		for name,v in pairs(group) do
			if (string.sub(name, 1, 4) ~= "not ") then
				if (name ~= "empty") then
					local fgroupmembers = unitlists[name] or {}
					local finalgroup = {}

					for a,b in ipairs(fgroupmembers) do
						local myverbs = {}

						for c,d in ipairs(v) do
							if testcond(d[2],b) then
								local unit = mmf.newObject(b)

								if (unit.flags[DEAD] == false) then
									table.insert(myverbs, d[1])
								end
							end
						end

						table.insert(finalgroup, {b, myverbs})
					end

					table.insert(result, {name, finalgroup})
				else
					local empties = findempty()
					local finalgroup = {}

					if (#empties > 0) then
						for a,b in ipairs(empties) do
							local x = math.floor(b % roomsizex)
							local y = math.floor(b / roomsizex)
							local myverbs = {}

							for c,d in ipairs(v) do
								if testcond(d[2],2,x,y) then
									table.insert(myverbs, d[1])
								end
							end

							table.insert(finalgroup, {b, myverbs})
						end

						table.insert(result, {name, finalgroup})
					end
				end
			end
		end
	end

	return result
end
