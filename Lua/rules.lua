-- Fixes TEXT MIMIC X.
function subrules()
	local mimicprotects = {}

	if (featureindex["all"] ~= nil) then
		for k,rules in ipairs(featureindex["all"]) do
			local rule = rules[1]
			local conds = rules[2]
			local ids = rules[3]
			local tags = rules[4]

			if (rule[3] == "all") then
				if (rule[2] ~= "is") then
					local nconds = {}

					if (featureindex["not all"] ~= nil) then
						for a,prules in ipairs(featureindex["not all"]) do
							local prule = prules[1]
							local pconds = prules[2]

							if (prule[1] == rule[1]) and (prule[2] == rule[2]) and (prule[3] == "not all") then
								local ipconds = invertconds(pconds)

								for c,d in ipairs(ipconds) do
									table.insert(nconds, d)
								end
							end
						end
					end

					for i,mat in pairs(objectlist) do
						if (findnoun(i) == false) then
							local newrule = {rule[1],rule[2],i}
							local newconds = {}
							for a,b in ipairs(conds) do
								table.insert(newconds, b)
							end
							for a,b in ipairs(nconds) do
								table.insert(newconds, b)
							end
							addoption(newrule,newconds,ids,false,nil,tags)
						end
					end
				end
			end

			if (rule[1] == "all") and (string.sub(rule[3], 1, 4) ~= "not ") then
				local nconds = {}

				if (featureindex["not all"] ~= nil) then
					for a,prules in ipairs(featureindex["not all"]) do
						local prule = prules[1]
						local pconds = prules[2]

						if (prule[1] == rule[1]) and (prule[2] == rule[2]) and (prule[3] == "not " .. rule[3]) then
							local ipconds = invertconds(pconds)

							if crashy_ then
								crashy = true
							end

							for c,d in ipairs(ipconds) do
								table.insert(nconds, d)
							end
						end
					end
				end

				for i,mat in pairs(objectlist) do
					if (findnoun(i) == false) then
						local newrule = {i,rule[2],rule[3]}
						local newconds = {}
						for a,b in ipairs(conds) do
							table.insert(newconds, b)
						end
						for a,b in ipairs(nconds) do
							table.insert(newconds, b)
						end
						addoption(newrule,newconds,ids,false,nil,tags)
					end
				end
			end

			if (rule[1] == "all") and (string.sub(rule[3], 1, 4) == "not ") then
				for i,mat in pairs(objectlist) do
					if (findnoun(i) == false) then
						local newrule = {i,rule[2],rule[3]}
						local newconds = {}
						for a,b in ipairs(conds) do
							table.insert(newconds, b)
						end
						addoption(newrule,newconds,ids,false,nil,tags)
					end
				end
			end
		end
	end

	if (featureindex["mimic"] ~= nil) then
		for i,rules in ipairs(featureindex["mimic"]) do
			local rule = rules[1]
			local conds = rules[2]
			local tags = rules[4]

			if (rule[2] == "mimic") then
				local object = rule[1]
				local target = rule[3]

				local isnot = false

				if (string.sub(target, 1, 4) == "not ") then
					target = string.sub(target, 5)
					isnot = true
				end

				if isnot then
					if (mimicprotects[object] == nil) then
						mimicprotects[object] = {}
					end

					table.insert(mimicprotects[object], {target, conds, rule[3]})
				end
			end
		end
	end

	if (featureindex["mimic"] ~= nil) then
		for i,rules in ipairs(featureindex["mimic"]) do
			local rule = rules[1]
			local conds = rules[2]
			local tags = rules[4]
			local verbtext = false
			for i,v in ipairs(tags) do
				if v == "verbtext" then
					verbtext = true
					break
				end
			end

			if (rule[2] == "mimic") then
				local object = rule[1]
				local target = rule[3]
				local mprotects = mimicprotects[object] or {}
				local extraconds = {}

				local valid = true

				if (string.sub(target, 1, 4) == "not ") then
					valid = false
				end

				for a,b in ipairs(mprotects) do
					if (b[1] == target) then
						local pconds = b[2]

						if (#pconds == 0) then
							valid = false
						else
							local newconds = invertconds(pconds)

							for c,d in ipairs(newconds) do
								table.insert(extraconds, d)
							end
						end
					end
				end

				local copythese = {}

				if valid then
					if (getmat(object,true) ~= nil) and (getmat(target,true) ~= nil) then
						if (featureindex[target] ~= nil) then
							copythese = featureindex[target]
						end
					end

					for a,b in ipairs(copythese) do
						local trule = b[1]
						local tconds = b[2]
						local ids = b[3]
						local ttags = b[4]

						local valid = true
						for c,d in ipairs(ttags) do
							if (d == "mimic") or (d == "text" and verbtext == true) then
								valid = false
							end
						end

						if (trule[1] == target) and (trule[2] ~= "mimic") and valid then
							local newconds = {}
							local newtags = {}

							for c,d in ipairs(tconds) do
								table.insert(newconds, d)
							end

							for c,d in ipairs(conds) do
								table.insert(newconds, d)
							end

							for c,d in ipairs(extraconds) do
								table.insert(newconds, d)
							end

							for c,d in ipairs(ttags) do
								table.insert(newtags, d)
							end

							for c,d in ipairs(tags) do
								table.insert(newtags, d)
							end

							table.insert(newtags, "mimic")

							local newword1 = object
							local newword2 = trule[2]
							local newword3 = trule[3]

							local newrule = {newword1, newword2, newword3}

							addoption(newrule,newconds,ids,true,nil,newtags)
						end
					end
				end
			end
		end
	end
end

--[[
Makes text rules apply to all text.
Also makes NOT METATEXT act as all text except the subject.
]]--
function addoption(option,conds_,ids,visible,notrule,tags_)
	--MF_alert(option[1] .. ", " .. option[2] .. ", " .. option[3])

	local visual = true

	if (visible ~= nil) then
		visual = visible
	end

	local conds = {}

	if (conds_ ~= nil) then
		conds = conds_
	else
		MF_alert("nil conditions in rule: " .. option[1] .. ", " .. option[2] .. ", " .. option[3])
	end

	local tags = tags_ or {}

	if (#option == 3) then
		local rule = {option,conds,ids,tags}
		table.insert(features, rule)
		local target = option[1]
		local verb = option[2]
		local effect = option[3]

		if (featureindex[effect] == nil) then
			featureindex[effect] = {}
		end

		if (featureindex[target] == nil) then
			featureindex[target] = {}
		end

		if (featureindex[verb] == nil) then
			featureindex[verb] = {}
		end

		table.insert(featureindex[effect], rule)
		table.insert(featureindex[verb], rule)

		if (target ~= effect) then
			table.insert(featureindex[target], rule)
		end

		if visual then
			local visualrule = copyrule(rule)
			table.insert(visualfeatures, visualrule)
		end

		local groupcond = false

		if (string.sub(target, 1, 5) == "group") or (string.sub(effect, 1, 5) == "group") or (string.sub(target, 1, 9) == "not group") or (string.sub(effect, 1, 9) == "not group") then
			groupcond = true
		end

		if (notrule ~= nil) then
			local notrule_effect = notrule[1]
			local notrule_id = notrule[2]

			if (notfeatures[notrule_effect] == nil) then
				notfeatures[notrule_effect] = {}
			end

			local nr_e = notfeatures[notrule_effect]

			if (nr_e[notrule_id] == nil) then
				nr_e[notrule_id] = {}
			end

			local nr_i = nr_e[notrule_id]

			table.insert(nr_i, rule)
		end

		if (#conds > 0) then
			local addedto = {}

			for i,cond in ipairs(conds) do
				local condname = cond[1]
				if (string.sub(condname, 1, 4) == "not ") then
					condname = string.sub(condname, 5)
				end

				if (condfeatureindex[condname] == nil) then
					condfeatureindex[condname] = {}
				end

				if (addedto[condname] == nil) then
					table.insert(condfeatureindex[condname], rule)
					addedto[condname] = 1
				end

				if (cond[2] ~= nil) then
					if (#cond[2] > 0) then
						local alreadyused = {}
						local newconds = {}
						local allfound = false

						--alreadyused[target] = 1

						for a,b in ipairs(cond[2]) do
							if (b ~= "all") and (b ~= "not all") then
								alreadyused[b] = 1
								table.insert(newconds, b)
							elseif (b == "all") then
								allfound = true
							elseif (b == "not all") then
								newconds = {"empty","text"}
							end

							if (string.sub(b, 1, 5) == "group") or (string.sub(b, 1, 9) == "not group") then
								groupcond = true
							end
						end

						if allfound then
							for a,mat in pairs(objectlist) do
								if (alreadyused[a] == nil) and (findnoun(a,nlist.short) == false) then
									table.insert(newconds, a)
									alreadyused[a] = 1
								end
							end
						end

						cond[2] = newconds
					end
				end
			end
		end

		if groupcond then
			table.insert(groupfeatures, rule)
		end

		local targetnot = string.sub(target, 1, 4)
		local targetnot_ = string.sub(target, 5)

		if (targetnot == "not ") and (objectlist[targetnot_] ~= nil) and (string.sub(targetnot_, 1, 5) ~= "group") and (string.sub(effect, 1, 5) ~= "group") and (string.sub(effect, 1, 9) ~= "not group") then
			if (targetnot_ ~= "all") then
				if (string.sub(targetnot_, 1, 5) == "text_") then
					for i,mat in pairs(fullunitlist) do
						if (i ~= targetnot_) and (string.sub(i, 1, 5) == "text_") then
							local rule = {i,verb,effect}
							local newconds = {}
							for a,b in ipairs(conds) do
								table.insert(newconds, b)
							end
							addoption(rule,newconds,ids,false,{effect,#featureindex[effect]},tags)
						end
					end
				else
					for i,mat in pairs(objectlist) do
						if (i ~= targetnot_) and (findnoun(i) == false) then
							local rule = {i,verb,effect}
							local newconds = {}
							for a,b in ipairs(conds) do
								table.insert(newconds, b)
							end
							addoption(rule,newconds,ids,false,{effect,#featureindex[effect]},tags)
						end
					end
				end
			else
				local mats = {"empty","text"}

				for m,i in pairs(mats) do
					local rule = {i,verb,effect}
					local newconds = {}
					for a,b in ipairs(conds) do
						table.insert(newconds, b)
					end
					addoption(rule,newconds,ids,false,{effect,#featureindex[effect]},tags)
				end
			end
		end
		if target == "text" and fullunitlist ~= nil then
			for a,b in pairs(fullunitlist) do -- fullunitlist contains all units, is new
				if (string.sub(a, 1, 5) == "text_") then
					local newconds = {}
					local newtags = {}
					local stop = false

					for c,d in ipairs(conds) do
						table.insert(newconds, d)
					end

					for c,d in ipairs(tags) do
						table.insert(newtags, d)
					end

					table.insert(newtags, "text")

					local newword1 = a
					local newword2 = verb
					local newword3 = effect
					if newword3 == "text" then
						if newword2 == "is" then
							newword3 = newword1
						elseif newword2 == "has" then
							newword3 = "text_text"
						elseif newword2 == "make" then
							stop = true
						end
					end
					if newword3 == "not text" then
						if newword2 == "is" then
							newword3 = "not " .. newword1
						elseif newword2 == "has" then
							newword3 = "not text_text"
						end
					end

					local newrule = {newword1, newword2, newword3}
					if not stop then
						addoption(newrule,newconds,ids,false,nil,newtags)
					end
				end
			end
		end
		if effect == "text" and (verb == "eat" or verb == "follow" or verb == "mimic") then
			for a,b in pairs(fullunitlist) do -- fullunitlist contains all units, is new
				if (string.sub(a, 1, 5) == "text_") then
					local newconds = {}
					local newtags = {}
					local stop = false

					for c,d in ipairs(conds) do
						table.insert(newconds, d)
					end

					for c,d in ipairs(tags) do
						table.insert(newtags, d)
					end

					table.insert(newtags, "verbtext")

					local newword1 = target
					local newword2 = verb
					local newword3 = a

					local newrule = {newword1, newword2, newword3}
					addoption(newrule,newconds,ids,false,nil,newtags)
				end
			end
		end
		if effect == "not text" and (verb == "eat" or verb == "follow" or verb == "mimic") then
			for a,b in pairs(fullunitlist) do -- fullunitlist contains all units, is new
				if (string.sub(a, 1, 5) == "text_") then
					local newconds = {}
					local newtags = {}
					local stop = false

					for c,d in ipairs(conds) do
						table.insert(newconds, d)
					end

					for c,d in ipairs(tags) do
						table.insert(newtags, d)
					end

					table.insert(newtags, "verbtext")

					local newword1 = target
					local newword2 = verb
					local newword3 = "not" .. a

					local newrule = {newword1, newword2, newword3}
					addoption(newrule,newconds,ids,false,nil,newtags)
				end
			end
		end
	end
end

-- Makes this just use the addoption function, so TEXT IS PUSH works.
function addbaserule(rule1,rule2,rule3,conds_)
	local conds = conds_ or {}
	local rule = {rule1,rule2,rule3}

	addoption(rule,conds,{},false,nil,{base})
end

--[[
Oh god I have to screw with grouprules, this is a terrible idea
Makes NOT METATEXT act as all text except the subject in group membership.
--]]
function grouprules()
	groupmembers = {}
	local groupmembers_quick = {}

	local isgroup = {}
	local isnotgroup = {}
	local xgroup = {}
	local xnotgroup = {}
	local groupx = {}
	local notgroupx = {}
	local groupxgroup = {}
	local groupxgroup_diffname = {}
	local groupisnotgroup = {}
	local notgroupisgroup = {}

	local evilrecursion = false
	local notgroupisgroup_diffname = {}

	local memberships = {}

	local combined = {}

	for i,v in ipairs(groupfeatures) do
		local rule = v[1]
		local conds = v[2]

		local type_isgroup = false
		local type_isnotgroup = false
		local type_xgroup = false
		local type_xnotgroup = false
		local type_groupx = false
		local type_notgroupx = false
		local type_recursive = false

		local groupname1 = ""
		local groupname2 = ""

		if (string.sub(rule[1], 1, 5) == "group") then
			type_groupx = true
			groupname1 = rule[1]
		elseif (string.sub(rule[1], 1, 9) == "not group") then
			type_notgroupx = true
			groupname1 = string.sub(rule[1], 5)
		end

		if (string.sub(rule[3], 1, 5) == "group") then
			type_xgroup = true
			groupname2 = rule[3]

			if (rule[2] == "is") then
				type_isgroup = true
			end
		elseif (string.sub(rule[3], 1, 9) == "not group") then
			type_xnotgroup = true
			groupname2 = string.sub(rule[3], 5)

			if (rule[2] == "is") then
				type_isnotgroup = true
			end
		end

		if (conds ~= nil) and (#conds > 0) then
			for a,cond in ipairs(conds) do
				local params = cond[2] or {}
				for c,param in ipairs(params) do
					if (string.sub(param, 1, 5) == "group") or (string.sub(param, 1, 9) == "not group") then
						type_recursive = true
						break
					end
				end
			end
		end

		if type_isgroup then
			if (type_groupx == false) and (type_notgroupx == false) then
				table.insert(isgroup, {v, type_recursive})

				if (memberships[rule[3]] == nil) then
					memberships[rule[3]] = {}
				end

				if (memberships[rule[3]][rule[1]] == nil) then
					memberships[rule[3]][rule[1]] = {}
				end

				table.insert(memberships[rule[3]][rule[1]], {v, type_recursive})
			elseif (type_notgroupx == false) then
				if (groupname1 == groupname2) then
					table.insert(groupxgroup, {v, type_recursive})
				else
					table.insert(groupxgroup_diffname, {v, type_recursive})
				end
			else
				if (groupname1 == groupname2) then
					table.insert(notgroupisgroup, {v, type_recursive})
				else
					evilrecursion = true
					table.insert(notgroupisgroup_diffname, {v, type_recursive})
				end
			end
		elseif type_xgroup then
			if (type_groupx == false) and (type_notgroupx == false) then
				table.insert(xgroup, {v, type_recursive})
			else
				table.insert(groupxgroup, {v, type_recursive})
			end
		elseif type_isnotgroup then
			if (type_groupx == false) and (type_notgroupx == false) then
				if (isnotgroup[rule[1]] == nil) then
					isnotgroup[rule[1]] = {}
				end

				table.insert(isnotgroup[rule[1]], {v, type_recursive})

				if (xnotgroup[rule[1]] == nil) then
					xnotgroup[rule[1]] = {}
				end

				table.insert(xnotgroup[rule[1]], {v, type_recursive})
			elseif (type_notgroupx == false) then
				if (groupname1 == groupname2) then
					table.insert(groupisnotgroup, {v, type_recursive})
				else
					table.insert(groupxgroup_diffname, {v, type_recursive})
				end
			else
				if (groupname1 == groupname2) then
					table.insert(groupxgroup, {v, type_recursive})
				else
					evilrecursion = true
					table.insert(notgroupisgroup_diffname, {v, type_recursive})
				end
			end
		elseif type_xnotgroup then
			if (xnotgroup[rule[1]] == nil) then
				xnotgroup[rule[1]] = {}
			end

			table.insert(xnotgroup[rule[1]], {v, type_recursive})
		elseif type_groupx then
			table.insert(groupx, {v, type_recursive})
		elseif type_notgroupx then
			table.insert(notgroupx, {v, type_recursive})
		end
	end

	local diffname_done = false
	local diffname_used = {}

	while (diffname_done == false) do
		diffname_done = true

		for i,v_ in ipairs(groupxgroup_diffname) do
			if (diffname_used[i] == nil) then
				local v = v_[1]
				local recursion = v_[2] or false

				local rule = v[1]
				local conds = v[2]
				local ids = v[3]
				local tags = v[4]

				local gn1 = rule[1]
				local gn2 = rule[3]

				local notrule = false
				if (string.sub(gn2, 1, 4) == "not ") then
					notrule = true
				end

				local newconds = {}
				newconds = copyconds(newconds,conds)

				for a,b_ in ipairs(isgroup) do
					local b = b_[1]
					local brec = b_[2] or recursion or false
					local grule = b[1]
					local gconds = b[2]

					if (grule[3] == gn1) then
						diffname_used[i] = 1
						diffname_done = false

						newconds = copyconds(newconds,gconds)

						local newrule = {grule[1],"is",gn2}

						if (notrule == false) then
							table.insert(isgroup, {{newrule,newconds,ids,tags}, brec})
						else
							if (isnotgroup[grule[1]] == nil) then
								isnotgroup[grule[1]] = {}
							end

							table.insert(isnotgroup[grule[1]], {{newrule,newconds,ids,tags}, brec})
						end
					end
				end
			end
		end
	end

	if evilrecursion then
		diffname_done = false
		local evilrec_id = ""
		local evilrec_id_base = ""
		local evilrec_memberships_base = {}
		local evilrec_memberships_quick = {}

		local evilrec_limit = 0

		for i,v in pairs(memberships) do
			evilrec_id_base = evilrec_id_base .. i
			for a,b in pairs(v) do
				evilrec_id_base = evilrec_id_base .. a

				if (evilrec_memberships_quick[i] == nil) then
					evilrec_memberships_quick[i] = {}
				end

				evilrec_memberships_quick[i][a] = b

				if (evilrec_memberships_base[i] == nil) then
					evilrec_memberships_base[i] = {}
				end

				evilrec_memberships_base[i][a] = b
			end
		end

		evilrec_id = evilrec_id_base

		while (diffname_done == false) and (evilrec_limit < 10) do
			local foundmembers = {}
			local foundid = evilrec_id_base

			for i,v in pairs(evilrec_memberships_base) do
				foundid = foundid .. i
				for a,b in pairs(v) do
					foundid = foundid .. a
				end
			end

			for i,v_ in ipairs(notgroupisgroup_diffname) do
				local v = v_[1]
				local recursion = v_[2] or false

				local rule = v[1]
				local conds = v[2]
				local ids = v[3]
				local tags = v[4]

				local notrule = false
				local gn1 = string.sub(rule[1], 5)
				local gn2 = rule[3]

				if (string.sub(gn2, 1, 4) == "not ") then
					notrule = true
					gn2 = string.sub(gn2, 5)
				end

				if (foundmembers[gn2] == nil) then
					foundmembers[gn2] = {}
				end

				for a,b in pairs(objectlist) do
					if (findnoun(a) == false) and ((evilrec_memberships_quick[gn1] == nil) or ((evilrec_memberships_quick[gn1] ~= nil) and (evilrec_memberships_quick[gn1][a] == nil))) then
						if (foundmembers[gn2][a] == nil) then
							foundmembers[gn2][a] = {}
						end

						table.insert(foundmembers[gn2][a], {v, recursion})
					end
				end
			end

			for i,v in pairs(foundmembers) do
				foundid = foundid .. i
				for a,b in pairs(v) do
					foundid = foundid .. a
				end
			end

			-- MF_alert(foundid .. " == " .. evilrec_id)

			if (foundid == evilrec_id) then
				diffname_done = true

				for i,v in pairs(foundmembers) do
					for a,d in pairs(v) do
						for c,b_ in ipairs(d) do
							local b = b_[1]
							local brule = b[1]
							local rec = b_[2] or false

							local newrule = {a,"is",brule[3]}
							local newconds = {}
							newconds = copyconds(newconds,b[2])
							local newids = concatenate(b[3])
							local newtags = concatenate(b[4])

							if (string.sub(brule[3], 1, 4) ~= "not ") then
								table.insert(isgroup, {{newrule,newconds,newids,newtags}, rec})
							else
								if (isnotgroup[a] == nil) then
									isnotgroup[a] = {}
								end

								table.insert(isnotgroup[a], {{newrule,newconds,newids,newtags}, rec})
							end
						end
					end
				end
			else
				evilrec_memberships_quick = {}
				evilrec_id = foundid

				for i,v in pairs(evilrec_memberships_base) do
					evilrec_memberships_quick[i] = {}

					for a,b in pairs(v) do
						evilrec_memberships_quick[i][a] = b
					end
				end

				for i,v in pairs(foundmembers) do
					evilrec_memberships_quick[i] = {}

					for a,b in pairs(v) do
						evilrec_memberships_quick[i][a] = b
					end
				end

				evilrec_limit = evilrec_limit + 1
			end
		end

		if (evilrec_limit >= 10) then
			HACK_INFINITY = 200
			destroylevel("infinity")
			return
		end
	end

	memberships = {}

	for i,v_ in ipairs(isgroup) do
		local v = v_[1]
		local recursion = v_[2] or false

		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]

		local name_ = rule[1]
		local namelist = {}

		if (string.sub(name_, 1, 4) ~= "not ") then
			namelist = {name_}
		else
			if string.sub(name_, 5, 9) == "text_" then --Exception for NOT METATEXT.
				for a,b in pairs(fullunitlist) do
					if (string.sub(a, 1, 5) == "text_") and (a ~= string.sub(name_, 5)) then
						table.insert(namelist, a)
					end
				end
			else
				for a,b in pairs(objectlist) do
					if (findnoun(a) == false) and (a ~= string.sub(name_, 5)) then
						table.insert(namelist, a)
					end
				end
			end
		end

		for index,name in ipairs(namelist) do
			local never = false

			local prevents = {}

			if (isnotgroup[name] ~= nil) then
				for a,b_ in ipairs(isnotgroup[name]) do
					local b = b_[1]
					local brule = b[1]

					local grouptype = string.sub(brule[3], 5)

					if (grouptype == rule[3]) then
						recursion = b_[2] or recursion
						local pconds,crashy,neverfound = invertconds(b[2])

						if (neverfound == false) then
							for a,cond in ipairs(pconds) do
								table.insert(prevents, cond)
							end
						else
							never = true
							break
						end
					end
				end
			end

			if (never == false) then
				local fconds = {}
				fconds = copyconds(fconds,conds)
				fconds = copyconds(fconds,prevents)

				table.insert(groupmembers, {name,fconds,rule[3],recursion})

				if (groupmembers_quick[name .. "_" .. rule[3]] == nil) then
					groupmembers_quick[name .. "_" .. rule[3]] = {}
				end

				table.insert(groupmembers_quick[name .. "_" .. rule[3]], {name,fconds,rule[3],recursion})

				if (memberships[rule[3]] == nil) then
					memberships[rule[3]] = {}
				end

				table.insert(memberships[rule[3]], {name,fconds})

				for a,b_ in ipairs(groupx) do
					local b = b_[1]
					recursion = b_[2] or recursion

					local grule = b[1]
					local gconds = b[2]
					local gids = b[3]
					local gtags = b[4]

					if (grule[1] == rule[3]) then
						local newrule = {name,grule[2],grule[3]}
						local newconds = {}
						local newids = concatenate(ids,gids)
						local newtags = concatenate(tags,gtags)

						newconds = copyconds(newconds,conds)
						newconds = copyconds(newconds,gconds)

						if (#prevents == 0) then
							table.insert(combined, {newrule,newconds,newids,newtags})
						else
							newconds = copyconds(newconds,prevents)
							table.insert(combined, {newrule,newconds,newids,newtags})
						end
					end
				end
			end
		end
	end

	for i,v_ in ipairs(groupxgroup) do
		local v = v_[1]
		local recursion = v_[2] or false

		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]

		local gn1 = rule[1]
		local gn2 = rule[3]

		local never = false

		local notrule = false
		if (string.sub(gn1, 1, 4) == "not ") then
			notrule = true
			gn1 = string.sub(gn1, 5)
		end

		local prevents = {}
		if (xnotgroup[gn1] ~= nil) then
			for a,b_ in ipairs(xnotgroup[gn1]) do
				local b = b_[1]
				local brule = b[1]

				if (brule[1] == rule[1]) and (brule[2] == rule[2]) and (brule[3] == "not " .. rule[3]) then
					recursion = b_[2] or recursion

					local pconds,crashy,neverfound = invertconds(b[2])

					if (neverfound == false) then
						for a,cond in ipairs(pconds) do
							table.insert(prevents, cond)
						end
					else
						never = true
						break
					end
				end
			end
		end

		if (never == false) then
			local team1 = {}
			local team2 = {}

			if (notrule == false) then
				if (memberships[gn1] ~= nil) then
					for a,b in ipairs(memberships[gn1]) do
						table.insert(team1, b)
					end
				end
			else
				local ignorethese = {}

				if (memberships[gn1] ~= nil) then
					for a,b in ipairs(memberships[gn1]) do
						ignorethese[b[1]] = 1

						local iconds,icrash,inever = invertconds(b[2])

						if (inever == false) then
							table.insert(team1, {b[1],iconds})
						end
					end
				end

				for a,b in pairs(objectlist) do
					if (findnoun(a) == false) and (ignorethese[a] == nil) then
						table.insert(team1, {a})
					end
				end
			end

			if (memberships[gn2] ~= nil) then
				for a,b in ipairs(memberships[gn2]) do
					table.insert(team2, b)
				end
			end

			for a,b in ipairs(team1) do
				for c,d in ipairs(team2) do
					local newrule = {b[1],rule[2],d[1]}
					local newconds = {}
					newconds = copyconds(newconds,conds)

					if (b[2] ~= nil) then
						newconds = copyconds(newconds,b[2])
					end

					if (d[2] ~= nil) then
						newconds = copyconds(newconds,d[2])
					end

					if (#prevents > 0) then
						newconds = copyconds(newconds,prevents)
					end

					local newids = concatenate(ids)
					local newtags = concatenate(tags)

					table.insert(combined, {newrule,newconds,newids,newtags})
				end
			end
		end
	end

	if (#notgroupx > 0) then
		for name,v in pairs(objectlist) do
			if (findnoun(name) == false) then
				for a,b_ in ipairs(notgroupx) do
					local b = b_[1]
					local recursion = b_[2] or false

					local rule = b[1]
					local conds = b[2]
					local ids = b[3]
					local tags = b[4]

					local newconds = {}
					newconds = copyconds(newconds,conds)

					local groupname = string.sub(rule[1], 5)
					local valid = true

					if (groupmembers_quick[name .. "_" .. groupname] ~= nil) then
						for c,d in ipairs(groupmembers_quick[name .. "_" .. groupname]) do
							recursion = d[4] or recursion

							local iconds,icrash,inever = invertconds(d[2])
							newconds = copyconds(newconds,iconds)

							if inever then
								valid = false
								break
							end
						end
					end

					if valid then
						local newrule = {name,rule[2],rule[3]}
						local newids = {}
						local newtags = {}
						newids = concatenate(newids,ids)
						newtags = concatenate(newtags,tags)

						table.insert(combined, {newrule,newconds,newids,newtags})
					end
				end
			end
		end
	end

	for i,v_ in ipairs(xgroup) do
		local v = v_[1]
		local recursion = v_[2] or false

		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]

		if (string.sub(rule[1], 1, 5) ~= "group") and (string.sub(rule[1], 1, 9) ~= "not group") and (rule[2] ~= "is") then
			local team2 = {}

			if (memberships[rule[3]] ~= nil) then
				for a,b in ipairs(memberships[rule[3]]) do
					table.insert(team2, b)
				end
			end

			for a,b in ipairs(team2) do
				local newrule = {rule[1],rule[2],b[1]}
				local newconds = {}
				newconds = copyconds(newconds,conds)

				if (b[2] ~= nil) then
					newconds = copyconds(newconds,b[2])
				end

				local newids = concatenate(ids)
				local newtags = concatenate(tags)

				table.insert(combined, {newrule,newconds,newids,newtags})
			end
		end
	end

	for i,k in pairs(xnotgroup) do
		for c,v_ in ipairs(k) do
			local v = v_[1]
			local recursion = v_[2] or false

			local rule = v[1]
			local conds = v[2]
			local ids = v[3]
			local tags = v[4]

			if (string.sub(rule[1], 1, 5) ~= "group") and (string.sub(rule[1], 1, 9) ~= "not group") and (rule[2] ~= "is") then
				local team2 = {}

				local gn2 = string.sub(rule[3], 5)

				if (memberships[gn2] ~= nil) then
					for a,b in ipairs(memberships[gn2]) do
						table.insert(team2, b)
					end
				end

				for a,b in ipairs(team2) do
					local newrule = {rule[1],rule[2],"not " .. b[1]}
					local newconds = {}
					newconds = copyconds(newconds,conds)

					if (b[2] ~= nil) then
						newconds = copyconds(newconds,b[2])
					end

					local newids = concatenate(ids)
					local newtags = concatenate(tags)

					table.insert(combined, {newrule,newconds,newids,newtags})
				end
			end
		end
	end

	for i,v_ in ipairs(groupisnotgroup) do
		local v = v_[1]
		local recursion = v_[2] or false

		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]

		local team1 = {}

		if (memberships[rule[1]] ~= nil) then
			for a,b in ipairs(memberships[rule[1]]) do
				table.insert(team1, b)
			end
		end

		for a,b in ipairs(team1) do
			local newrule = {b[1],"is","crash"}
			local newconds = {}
			newconds = copyconds(newconds,conds)

			if (b[2] ~= nil) then
				newconds = copyconds(newconds,b[2])
			end

			local newids = concatenate(ids)
			local newtags = concatenate(tags)

			table.insert(combined, {newrule,newconds,newids,newtags})
		end
	end

	for i,v_ in ipairs(notgroupisgroup) do
		local v = v_[1]
		local recursion = v_[2] or false

		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]

		local team1 = {}

		local gn1 = string.sub(rule[1], 5)

		local ignorethese = {}

		if (memberships[gn1] ~= nil) then
			for a,b in ipairs(memberships[gn1]) do
				ignorethese[b[1]] = 1

				local iconds,icrash,inever = invertconds(b[2])

				if (inever == false) then
					table.insert(team1, {b[1],iconds})
				end
			end
		end

		for a,b in pairs(objectlist) do
			if (findnoun(a) == false) and (ignorethese[a] == nil) then
				table.insert(team1, {a})
			end
		end

		for a,b in ipairs(team1) do
			local newrule = {b[1],"is","crash"}
			local newconds = {}
			newconds = copyconds(newconds,conds)

			if (b[2] ~= nil) then
				newconds = copyconds(newconds,b[2])
			end

			local newids = concatenate(ids)
			local newtags = concatenate(tags)

			table.insert(combined, {newrule,newconds,newids,newtags})
		end
	end

	for i,v in ipairs(combined) do
		addoption(v[1],v[2],v[3],false,nil,v[4])
	end
end
