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
		if target == "text" then
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

--[[
Hey, you found an unfinished feature!
This is the TEXT_ prefix, which would allow any text to be parsed as its metatext form.
For example, TEXT_ LONELY IS YOU would make LONELY text YOU.
It still has some bugs, which is why it is commented out.
I'll make it work sometime in the future.
]]--
--[[function docode(firstwords)
	local donefirstwords = {}
	local limiter = 0

	if (#firstwords > 0) then
		for k,unitdata in ipairs(firstwords) do
			if (type(unitdata[1]) == "number") then
				timedmessage("Old rule format detected. Please replace modified .lua files to ensure functionality.")
			end

			local unitids = unitdata[1]
			local unitid = unitids[1]
			local dir = unitdata[2]
			local width = unitdata[3]
			local word = unitdata[4]
			local wtype = unitdata[5]

			if (string.sub(word, 1, 5) == "text_") then
				word = string.sub(word, 6)
			end

			local unit = mmf.newObject(unitid)
			local x,y = unit.values[XPOS],unit.values[YPOS]
			local tileid = x + y * roomsizex

			--MF_alert("Testing " .. word .. ": " .. tostring(donefirstwords[tileid]) .. ", " .. tostring(dir) .. ", " .. tostring(unitid))
			limiter = limiter + 1

			if (limiter > 5000) then
				MF_alert("Level destroyed - firstwords run too many times")
				destroylevel("toocomplex")
				return
			end

			if (donefirstwords[tileid] == nil) or ((donefirstwords[tileid] ~= nil) and (donefirstwords[tileid][dir] == nil)) and (limiter < 5000) then
				local ox,oy = 0,0
				local name = word

				local drs = dirs[dir]
				ox = drs[1]
				oy = drs[2]

				if (donefirstwords[tileid] == nil) then
					donefirstwords[tileid] = {}
				end

				donefirstwords[tileid][dir] = 1

				local sentences,finals,maxlen,variations = calculatesentences(unitid,x,y,dir)

				if (sentences == nil) then
					return
				end

				--MF_alert(tostring(k) .. ", " .. tostring(variations))

				if (maxlen > 2) then
					for i=1,variations do
						local current = finals[i]
						local letterword = ""
						local stage = 0
						local prevstage = 0
						local tileids = {}

						local notids = {}
						local notwidth = 0
						local notslot = 0

						local stage3reached = false
						local stage2reached = false
						local doingcond = false
						local nocondsafterthis = false
						local condsafeand = false

						local firstrealword = false
						local letterword_prevstage = 0
						local letterword_firstid = 0

						local currtiletype = 0
						local prevtiletype = 0
						local currtilename = ""
						local prevtilename = ""
						local origin = 0

						local prevsafewordid = 0
						local prevsafewordtype = 0

						local stop = false

						local sent = sentences[i]

						local thissent = ""

						for wordid=1,#sent do
							local s = sent[wordid]
							local nexts = sent[wordid + 1] or {-1, -1, {-1}, 1}

							prevtiletype = currtiletype
							prevtilename = currtilename

							local tilename = s[1]
							local tiletype = s[2]
							local tileid = s[3][1]
							local tilewidth = s[4]

							local wordtile = false

							currtiletype = tiletype
							currtilename = tilename

							local dontadd = false

							thissent = thissent .. tilename .. "," .. tostring(wordid) .. "  "

							for a,b in ipairs(s[3]) do
								table.insert(tileids, b)
							end

							~~{{ I had to change this in order for this function to comment out properly.
								0 = objekti
								1 = verbi
								2 = quality
								3 = alkusana (LONELY)
								4 = Not
								5 = letter
								6 = And
								7 = ehtosana
								8 = customobject
							}}~~

							~~{{if (prevtiletype == 4 and prevtilename == "text_") then
								if (stage == 0 or stage == 1) and tiletype == 3 then
									stage = 7
								elseif stage ~= 9 and tiletype ~= 4 then
									tiletype = 0
									currtiletype = 0
								end
							end}}~~
							if (prevtiletype == 4 and prevtilename == "text_") and (tiletype ~= 4 or tilename ~= "text_") then
								if tiletype == 4 then
									currtiletype = 0
									origin = wordid
								end
								tiletype = 0
							end

							if (tiletype ~= 5) then
								if (stage == 0) then
									if (tiletype == 0) then
										prevstage = stage
										stage = 2
									elseif (tiletype == 3) then
										prevstage = stage
										stage = 1
									elseif (tiletype ~= 4) then
										prevstage = stage
										stage = -1
										stop = true
									end
								elseif (stage == 1) then
									if (tiletype == 0) then
										prevstage = stage
										stage = 2
									elseif (tiletype == 6) then
										prevstage = stage
										stage = 6
									elseif (tiletype ~= 4) then
										prevstage = stage
										stage = -1
										stop = true
									end
								elseif (stage == 2) then
									if (wordid ~= #sent) then
										if (tiletype == 1) and (prevtiletype ~= 4) and ((prevstage ~= 4) or doingcond or (stage3reached == false)) then
											stage2reached = true
											doingcond = false
											prevstage = stage
											nocondsafterthis = true
											stage = 3
										elseif ((tiletype == 7) and (stage2reached == false) and (nocondsafterthis == false)) then
											doingcond = true
											condsafeand = true
											prevstage = stage
											stage = 3
										elseif (tiletype == 6) and (prevtiletype ~= 4) then
											prevstage = stage
											stage = 4
										elseif (tiletype ~= 4) then
											prevstage = stage
											stage = -1
											stop = true
										end
									else
										stage = -1
										stop = true
									end
								elseif (stage == 3) then
									stage3reached = true

									if (tiletype == 0) or (tiletype == 2) or (tiletype == 8) then
										prevstage = stage
										stage = 5
									elseif (tiletype ~= 4) then
										stage = -1
										stop = true
									end
								elseif (stage == 4) then
									if (wordid <= #sent) then
										if (tiletype == 0) or ((tiletype == 2) and stage3reached) or ((tiletype == 8) and stage3reached) then
											prevstage = stage
											stage = 2
										elseif ((tiletype == 1) and stage3reached) and (doingcond == false) and (prevtiletype ~= 4) then
											stage2reached = true
											nocondsafterthis = true
											prevstage = stage
											stage = 3
										elseif (tiletype == 7) and (nocondsafterthis == false) and ((prevtiletype ~= 6) or ((prevtiletype == 6) and condsafeand)) then
											doingcond = true
											stage2reached = true
											condsafeand = true
											prevstage = stage
											stage = 3
										elseif (tiletype ~= 4) then
											prevstage = stage
											stage = -1
											stop = true
										end
									else
										stage = -1
										stop = true
									end
								elseif (stage == 5) then
									if (wordid ~= #sent) then
										if (tiletype == 1) and doingcond and (prevtiletype ~= 4) then
											stage2reached = true
											doingcond = false
											prevstage = stage
											nocondsafterthis = true
											stage = 3
										elseif (tiletype == 6) and (prevtiletype ~= 4) then
											prevstage = stage
											stage = 4
										elseif (tiletype ~= 4) then
											prevstage = stage
											stage = -1
											stop = true
										end
									else
										stage = -1
										stop = true
									end
								elseif (stage == 6) then
									if (tiletype == 3) then
										prevstage = stage
										stage = 1
									elseif (tiletype ~= 4) then
										prevstage = stage
										stage = -1
										stop = true
									end
								elseif (stage == 7) then
									prevstage = stage
									stage = 8
									tiletype = 9
									currtiletype = 9
									turnintonoun = #current + 1
								elseif (stage == 8) then
									prevtiletype = 3
									if (tiletype == 0) then
										prevstage = 1
										stage = 2
									elseif (tiletype == 6) then
										prevstage = stage
										stage = 9
									elseif (wordid ~= #sent) then
										prevtiletype = 0
										if (tiletype == 1) and (prevtiletype ~= 4) and ((prevstage ~= 4) or doingcond or (stage3reached == false)) then
											stage2reached = true
											doingcond = false
											prevstage = 2
											nocondsafterthis = true
											stage = 3
											current[turnintonoun][2] = 0
										elseif ((tiletype == 7) and (stage2reached == false) and (nocondsafterthis == false)) then
											doingcond = true
											condsafeand = true
											prevstage = 2
											stage = 3
											current[turnintonoun][2] = 0
										elseif (tiletype == 6) and (prevtiletype ~= 4) then
											prevstage = 2
											stage = 4
											current[turnintonoun][2] = 0
										elseif (tiletype ~= 4) then
											prevstage = 2
											stage = -1
											stop = true
										end
									else
										stage = -1
										stop = true
									end
								elseif (stage == 9) then
									if (tiletype == 3) then
										prevstage = 6
										stage = 1
									elseif (wordid <= #sent) then
										if (tiletype == 0) or ((tiletype == 2) and stage3reached) or ((tiletype == 8) and stage3reached) then
											prevstage = 4
											stage = 2
											current[turnintonoun][2] = 0
										elseif ((tiletype == 1) and stage3reached) and (doingcond == false) and (prevtiletype ~= 4) then
											stage2reached = true
											nocondsafterthis = true
											prevstage = 4
											stage = 3
											current[turnintonoun][2] = 0
										elseif (tiletype == 7) and (nocondsafterthis == false) and ((prevtiletype ~= 6) or ((prevtiletype == 6) and condsafeand)) then
											doingcond = true
											stage2reached = true
											condsafeand = true
											prevstage = 4
											stage = 3
											current[turnintonoun][2] = 0
										elseif tiletype == 4 and tilename == "text_" then
											current[turnintonoun][2] = 0
											stage = 0
										elseif (tiletype ~= 4) then
											prevstage = 4
											stage = -1
											stop = true
										end
									else
										stage = -1
										stop = true
									end
								end
							end

							if (stage > 0) then
								firstrealword = true
							end

							if (tiletype == 4) then
								if (#notids == 0) then
									notids = s[3]
									notwidth = tilewidth
									notslot = wordid
								end
							else
								if (stop == false) and (tiletype ~= 0) then
									notids = {}
									notwidth = 0
									notslot = 0
								end
							end

							if (prevtiletype ~= 4) then
								prevsafewordid = wordid - 1
								prevsafewordtype = prevtiletype
							end

							--MF_alert(tilename .. ", " .. tostring(wordid) .. ", " .. tostring(stage) .. ", " .. tostring(#sent) .. ", " .. tostring(tiletype) .. ", " .. tostring(prevtiletype) .. ", " .. tostring(stop))

							--MF_alert(tostring(k) .. "_" .. tostring(i) .. "_" .. tostring(wordid) .. ": " .. tilename .. ", " .. tostring(tiletype) .. ", " .. tostring(stop) .. ", " .. tostring(stage) .. ", " .. tostring(letterword_firstid).. ", " .. tostring(prevtiletype))

							if (stop == false) then
								if (dontadd == false) then
									table.insert(current, {tilename, tiletype, tileids, tilewidth})
									tileids = {}
								end
							else
								for a=1,#s[3] do
									if (#tileids > 0) then
										table.remove(tileids, #tileids)
									end
								end

								if (tiletype == 0) and (prevtiletype == 0) and (#notids > 0) then
									notids = {}
									notwidth = 0
								end

								if (wordid < #sent) then
									if (wordid > 1) then
										if (#notids > 0) and firstrealword and (notslot > 1) and (tiletype ~= 7) and ((tiletype ~= 1) or ((tiletype == 1) and (prevtiletype == 0))) then
											--MF_alert("Notstatus added to firstwords" .. ", " .. tostring(wordid) .. ", " .. tostring(nexts[2]))
											table.insert(firstwords, {notids, dir, notwidth, "not", 4})

											if (nexts[2] ~= nil) and ((nexts[2] == 0) or (nexts[2] == 3) or (nexts[2] == 4)) and (tiletype ~= 3) then
												--MF_alert("Also added " .. tostring(wordid) .. ", " .. tilename)
												table.insert(firstwords, {s[3], dir, tilewidth, tilename, tiletype})
											end
										else
											if origin ~= 0 then
												--MF_alert("Added previous word: " .. sent[origin][1] .. " to firstwords")
												table.insert(firstwords, {sent[origin][3], dir, tilewidth, tilename, tiletype})
											elseif ((prevtiletype == 0) and ((tiletype == 1) or (tiletype == 7))) or ((prevtiletype == 3) and (tiletype == 0)) then
												--MF_alert("Added previous word: " .. sent[wordid - 1][1] .. " to firstwords")
												table.insert(firstwords, {sent[wordid - 1][3], dir, tilewidth, tilename, tiletype})
											elseif (prevsafewordtype == 0) and (prevsafewordid > 0) and (prevtiletype == 4) and (tiletype ~= 1) and (tiletype ~= 2) then
												--MF_alert("Added previous safe word: " .. sent[prevsafewordid][1] .. " to firstwords")
												table.insert(firstwords, {sent[prevsafewordid][3], dir, tilewidth, tilename, tiletype})
											else
												--MF_alert("Added the current word: " .. s[1] .. " to firstwords")
												table.insert(firstwords, {s[3], dir, tilewidth, tilename, tiletype})
											end
										end

										break
									elseif (wordid == 1) then
										if (nexts[3][1] ~= -1) then
											--MF_alert(nexts[1] .. " added to firstwords E" .. ", " .. tostring(wordid))
											table.insert(firstwords, {nexts[3], dir, nexts[4], nexts[1], nexts[2]})
										end

										break
									end
								end
							end
						end

						--MF_alert(thissent)
					end
				end

				if (#finals > 0) then
					for i,sentence in ipairs(finals) do
						local group_objects = {}
						local group_targets = {}
						local group_conds = {}

						local group = group_objects
						local stage = 0

						local prefix = ""

						local allowedwords = {0}
						local allowedwords_extra = {}

						local testing = ""

						local extraids = {}
						local extraids_current = ""
						local extraids_ifvalid = {}

						local valid = true

						if (#finals > 1) then
							for a,b in ipairs(finals) do
								if (#b == #sentence) and (a > i) then
									local identical = true

									for c,d in ipairs(b) do
										local currids = d[3]
										local equivids = sentence[c][3] or {}

										for e,f in ipairs(currids) do
											--MF_alert(tostring(a) .. ": " .. tostring(f) .. ", " .. tostring(equivids[e]))
											if (f ~= equivids[e]) then
												identical = false
											end
										end
									end

									if identical then
										--MF_alert(sentence[1][1] .. ", " .. sentence[2][1] .. ", " .. sentence[3][1] .. " (" .. tostring(i) .. ") is identical to " .. b[1][1] .. ", " .. b[2][1] .. ", " .. b[3][1] .. " (" .. tostring(a) .. ")")
										valid = false
									end
								end
							end
						end

						if valid then
							for index,wdata in ipairs(sentence) do
								local wname = wdata[1]
								local wtype = wdata[2]
								local wid = wdata[3]

								testing = testing .. wname .. ", "

								local wcategory = -1

								if (wtype == 1) or (wtype == 3) or (wtype == 7) then
									wcategory = 1
								elseif (wtype ~= 4) and (wtype ~= 6) then
									wcategory = 0
								else
									table.insert(extraids_ifvalid, {prefix .. wname, wtype, wid})
									extraids_current = wname
								end

								if (wcategory == 0) then
									local allowed = false

									for a,b in ipairs(allowedwords) do
										if (b == wtype) then
											allowed = true
											break
										end
									end

									if (allowed == false) then
										for a,b in ipairs(allowedwords_extra) do
											if (wname == b) then
												allowed = true
												break
											end
										end
									end

									if allowed then
										table.insert(group, {prefix .. wname, wtype, wid})
									else
										table.insert(firstwords, {{wid[1]}, dir, 1, wname, wtype})
										break
									end
								elseif (wcategory == 1) then
									if (index < #sentence) then
										allowedwords = {0}
										allowedwords_extra = {}

										local realname = unitreference["text_" .. wname]
										local cargtype = false
										local cargextra = false

										local argtype = {0}
										local argextra = {}

										if (changes[realname] ~= nil) then
											local wchanges = changes[realname]

											if (wchanges.argtype ~= nil) then
												argtype = wchanges.argtype
												cargtype = true
											end

											if (wchanges.argextra ~= nil) then
												argextra = wchanges.argextra
												cargextra = true
											end
										end

										if (cargtype == false) or (cargextra == false) then
											local wvalues = tileslist[realname] or {}

											if (cargtype == false) then
												argtype = wvalues.argtype or {0}
											end

											if (cargextra == false) then
												argextra = wvalues.argextra or {}
											end
										end

										--MF_alert(wname .. ", " .. tostring(realname) .. ", " .. "text_" .. wname)

										if (realname == nil) then
											MF_alert("No object found for " .. wname .. "!")
											valid = false
											break
										else
											if (wtype == 1) then
												allowedwords = argtype

												stage = 1
												local target = {prefix .. wname, wtype, wid}
												table.insert(group_targets, {target, {}})
												local sid = #group_targets
												group = group_targets[sid][2]

												newcondgroup = 1
											elseif (wtype == 3) then
												allowedwords = {0}
												local cond = {prefix .. wname, wtype, wid}
												table.insert(group_conds, {cond, {}})
											elseif (wtype == 7) then
												allowedwords = argtype
												allowedwords_extra = argextra

												stage = 2
												local cond = {prefix .. wname, wtype, wid}
												table.insert(group_conds, {cond, {}})
												local sid = #group_conds
												group = group_conds[sid][2]
											end
										end
									end
								end

								if (wtype == 4) then
									if wname == "not" then
										if (prefix == "not ") then
											prefix = ""
										else
											prefix = "not "
										end
									elseif wname == "text_" then
										prefix = prefix .. "text_"
									end
								else
									if unitreference[prefix .. wname] ~= nil and unitreference["text_text_"] ~= nil then
										objectlist[prefix .. wname] = 1
										fullunitlist[prefix .. wname] = 1
									end
									prefix = ""
								end

								if (wname ~= extraids_current) and (string.len(extraids_current) > 0) and (wtype ~= 4) then
									for a,extraids_valid in ipairs(extraids_ifvalid) do
										table.insert(extraids, {prefix .. extraids_valid[1], extraids_valid[2], extraids_valid[3]})
									end

									extraids_ifvalid = {}
									extraids_current = ""
								end
							end
							--MF_alert("Testing: " .. testing)

							local conds = {}
							local condids = {}
							for c,group_cond in ipairs(group_conds) do
								local rule_cond = group_cond[1][1]
								--table.insert(condids, group_cond[1][3])

								condids = copytable(condids, group_cond[1][3])

								table.insert(conds, {rule_cond,{}})
								local condgroup = conds[#conds][2]

								for e,condword in ipairs(group_cond[2]) do
									local rule_condword = condword[1]
									--table.insert(condids, condword[3])

									condids = copytable(condids, condword[3])

									table.insert(condgroup, rule_condword)
								end
							end

							for c,group_object in ipairs(group_objects) do
								local rule_object = group_object[1]

								for d,group_target in ipairs(group_targets) do
									local rule_verb = group_target[1][1]

									for e,target in ipairs(group_target[2]) do
										local rule_target = target[1]

										local finalconds = {}
										for g,finalcond in ipairs(conds) do
											table.insert(finalconds, {finalcond[1], finalcond[2]})
										end

										local rule = {rule_object,rule_verb,rule_target}

										local ids = {}
										ids = copytable(ids, group_object[3])
										ids = copytable(ids, group_target[1][3])
										ids = copytable(ids, target[3])

										for g,h in ipairs(extraids) do
											ids = copytable(ids, h[3])
										end

										for g,h in ipairs(condids) do
											ids = copytable(ids, h)
										end

										addoption(rule,finalconds,ids)
									end
								end
							end
						end
					end
				end
			end
		end
	end
end]]--
