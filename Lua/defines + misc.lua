metatext_fixquirks = true --[[ Set this to FALSE to:
Make TEXT IS TELE link text units of the same type together rather than all text units
Make TEXT IS MORE allow text units to grow into other text units as long as they are not the same type
Make TEXT IS GROUP, NOUN HAS/MAKE GROUP make NOUN HAS/MAKE every text in the level.]]--
metatext_overlaystyle = "withoutsprite" --[[ Has 3 options:
"none" disables this feature.
"withoutsprite" enables overlay if the sprite being used does not match the level of metatext_
"always" always enables the overlay.]]--

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

-- Unused functions that tried to use actual sprites for overlay.
function createmetaoverlay()
  if overlayids == nil then
    overlayids = {}
  end
  for id,unit in pairs(units) do
    local unitname = unit.strings[UNITNAME]
    if unitname ~= "text_text_" and string.sub(unitname,1,10) == "text_text_" then
      if overlayids[unit.fixed] == nil then
        local overid = MF_create("Editor_line_indicator")
        local ounit = mmf.newObject(overid)

        ounit.x = unit.x
        ounit.y = unit.y

        ounit.values[XPOS] = unit.values[XPOS]
        ounit.values[YPOS] = unit.values[YPOS]
        ounit.layer = 1
        ounit.values[ZLAYER] = 20
        ounit.values[TYPE] = unit.fixed

        ounit.scaleX = spritedata.values[TILEMULT] * generaldata2.values[ZOOM]
        ounit.scaleY = spritedata.values[TILEMULT] * generaldata2.values[ZOOM]

        ounit.visible = unit.visible

        local c1,c2 = getuicolour("blocked")
        MF_setcolour(overid,c1,c2)
        overlayids[unit.fixed] = overid
      end
    elseif overlayids[unit.fixed] ~= nil then
      MF_remove(overlayids[unit.fixed])
      overlayids[unit.fixed] = nil
    end
  end
end
function updatemetaoverlay()
  if overlayids == nil then
    overlayids = {}
  end
  for unitid,overid in pairs(overlayids) do
    local unit = mmf.newObject(unitid)
    local unitname = unit.strings[UNITNAME]
    if unitname ~= "text_text_" and string.sub(unitname,1,10) == "text_text_" then
      local ounit = mmf.newObject(overid)

      ounit.x = unit.x
      ounit.y = unit.y

      ounit.values[XPOS] = unit.values[XPOS]
      ounit.values[YPOS] = unit.values[YPOS]
      ounit.layer = 1
      ounit.values[ZLAYER] = 20
      ounit.values[TYPE] = unit.fixed

      ounit.scaleX = spritedata.values[TILEMULT] * generaldata2.values[ZOOM]
      ounit.scaleY = spritedata.values[TILEMULT] * generaldata2.values[ZOOM]

      ounit.visible = unit.visible

      local c1,c2 = getuicolour("blocked")
      MF_setcolour(overid,c1,c2)
      overlayids[unit.fixed] = overid
    elseif overlayids[unit.fixed] ~= nil then
      MF_remove(overid)
      overlayids[unit.fixed] = nil
    end
  end
end
--table.insert( mod_hook_functions["rule_update_after"], createmetaoverlay)
--table.insert( mod_hook_functions["always"], updatemetaoverlay)

-- New function that writes the meta level of an object in the top right corner, if enabled.
function writemetalevel()
  MF_letterclear("metaoverlay")
  if metatext_overlaystyle ~= "none" then
    for id,unit in pairs(units) do
      local unitname = unit.strings[UNITNAME]
      if string.sub(unitname,1,10) == "text_text_" and unit.values[TYPE] == 0 then
        local _,metalevel = string.gsub(unitname,"text_","text_")
        if string.sub(unitname,-5) == "text_" then
          metalevel = metalevel - 2
        else
          metalevel = metalevel - 1
        end
        local show = true
        if metatext_overlaystyle == "withoutsprite" then
          local c = changes[unit.className] or {}
          if c.image == nil or c.image == unitname then
            show = false
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
          writetext(metalevel,-1,unit.x + 6,unit.y - 6,"metaoverlay",true,1,true,color)
        end
      end
    end
  end
end
table.insert( mod_hook_functions["always"], writemetalevel)
