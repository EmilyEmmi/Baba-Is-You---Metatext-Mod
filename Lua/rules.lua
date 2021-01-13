function postrules(alreadyrun_)
	if (featureindex["text"] ~= nil) then
		for k,rules in ipairs(featureindex["text"]) do
			local rule = rules[1]
			local conds = rules[2]
			local ids = rules[3]
			local tags = rules[4]
			if rule[1] == "text" then
				for a,b in pairs(fullunitlist) do -- fullunitlist contains all units, is new
					if (string.sub(a, 1, 5) == "text_") then
						local newconds = {}
						local newtags = {}

						for c,d in ipairs(conds) do
							table.insert(newconds, d)
						end

						for c,d in ipairs(tags) do
							table.insert(newtags, d)
						end

						table.insert(newtags, "text")

						local newword1 = a
						local newword2 = rule[2]
						local newword3 = rule[3]
						if newword3 == "text" and newword2 == "is" then
							newword3 = newword1
						end
						if newword3 == "not text" and newword2 == "is" then
							newword3 = "not " .. newword1
						end

						local newrule = {newword1, newword2, newword3}
						addoption(newrule,newconds,ids,false,nil,newtags)
					end
				end
			end
		end
	end

	local newruleids = {}
	local ruleeffectlimiter = {}
	local playrulesound = false
	local alreadyrun = alreadyrun_ or false

	local protects = {}
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
						if (i ~= "empty") and (i ~= "all") and (i ~= "level") and (i ~= "group") and (i ~= "text") and (string.sub(i, 1, 5) ~= "text_") then
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
					if (i ~= "empty") and (i ~= "all") and (i ~= "level") and (i ~= "group") and (i ~= "text") and (string.sub(i, 1, 5) ~= "text_") then
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
					if (i ~= "empty") and (i ~= "all") and (i ~= "level") and (i ~= "group") and (i ~= "text") and (string.sub(i, 1, 5) ~= "text_") then
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
							if (d == "mimic") then
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

	for i,unit in ipairs(units) do
		unit.active = false
	end

	local limit = #features

	for i,rules in ipairs(features) do
		if (i <= limit) then
			local rule = rules[1]
			local conds = rules[2]
			local ids = rules[3]

			if (rule[1] == rule[3]) and (rule[2] == "is") then
				table.insert(protects, i)
			end

			if (ids ~= nil) then
				local works = true
				local idlist = {}
				local effectsok = false

				if (#ids > 0) then
					for a,b in ipairs(ids) do
						table.insert(idlist, b)
					end
				end

				if (#idlist > 0) and works then
					for a,d in ipairs(idlist) do
						for c,b in ipairs(d) do
							if (b ~= 0) then
								local bunit = mmf.newObject(b)

								if (bunit.strings[UNITTYPE] == "text") then
									bunit.active = true
									setcolour(b,"active")
								end
								newruleids[b] = 1

								if (ruleids[b] == nil) and (#undobuffer > 1) and (alreadyrun == false) and (generaldata5.values[LEVEL_DISABLERULEEFFECT] == 0) then
									if (ruleeffectlimiter[b] == nil) then
										local x,y = bunit.values[XPOS],bunit.values[YPOS]
										local c1,c2 = getcolour(b,"active")
										--MF_alert(b)
										MF_particles_for_unit("bling",x,y,5,c1,c2,1,1,b)
										ruleeffectlimiter[b] = 1
									end

									if (rule[2] ~= "play") then
										playrulesound = true
									end
								end
							end
						end
					end
				elseif (#idlist > 0) and (works == false) then
					for a,visualrules in pairs(visualfeatures) do
						local vrule = visualrules[1]
						local same = comparerules(rule,vrule)

						if same then
							table.remove(visualfeatures, a)
						end
					end
				end
			end

			local rulenot = 0
			local neweffect = ""

			local nothere = string.sub(rule[3], 1, 4)

			if (nothere == "not ") then
				rulenot = 1
				neweffect = string.sub(rule[3], 5)
			end

			if (rulenot == 1) then
				local newconds,crashy = invertconds(conds,nil,rule[3])

				local newbaserule = {rule[1],rule[2],neweffect}

				local target = rule[1]
				local verb = rule[2]

				for a,b in ipairs(featureindex[target]) do
					local same = comparerules(newbaserule,b[1])

					if same then
						--MF_alert(rule[1] .. ", " .. rule[2] .. ", " .. neweffect .. ": " .. b[1][1] .. ", " .. b[1][2] .. ", " .. b[1][3])
						local theseconds = b[2]

						if (#newconds > 0) then
							if (newconds[1] ~= "never") then
								for c,d in ipairs(newconds) do
									table.insert(theseconds, d)
								end
							else
								theseconds = {"never",{}}
							end
						end

						if crashy then
							addoption({rule[1],"is","crash"},theseconds,ids,false,nil,rules[4])
						end

						b[2] = theseconds
					end
				end
			end
		end
	end

	if (#protects > 0) then
		for i,v in ipairs(protects) do
			local rule = features[v]

			local baserule = rule[1]
			local conds = rule[2]

			local target = baserule[1]

			local newconds = {{"never"}}

			if (conds[1] ~= "never") then
				if (#conds > 0) then
					newconds = {}

					for a,b in ipairs(conds) do
						local condword = b[1]
						local condgroup = {}

						if (string.sub(condword, 1, 1) == "(") then
							condword = string.sub(condword, 2)
						end

						if (string.sub(condword, -1) == ")") then
							condword = string.sub(condword, 1, #condword - 1)
						end

						local newcondword = "not " .. condword

						if (string.sub(condword, 1, 3) == "not") then
							newcondword = string.sub(condword, 5)
						end

						if (a == 1) then
							newcondword = "(" .. newcondword
						end

						if (a == #conds) then
							newcondword = newcondword .. ")"
						end

						if (b[2] ~= nil) then
							for c,d in ipairs(b[2]) do
								table.insert(condgroup, d)
							end
						end

						table.insert(newconds, {newcondword, condgroup})
					end
				end

				if (featureindex[target] ~= nil) then
					for a,rules in ipairs(featureindex[target]) do
						local targetrule = rules[1]
						local targetconds = rules[2]

						local object = targetrule[3]

						if (targetrule[1] == target) and (targetrule[2] == "is") and (target ~= object) and ((getmat(object) ~= nil) or (object == "revert")) and (object ~= "group") then
							if (#newconds > 0) then
								if (newconds[1] == "never") then
									targetconds = {}
								end

								for c,d in ipairs(newconds) do
									table.insert(targetconds, d)
								end
							end

							rules[2] = targetconds
						end
					end
				end
			end
		end
	end

	ruleids = newruleids

	ruleblockeffect()

	return playrulesound
end

function grouprules()
	local memberchecks = {}
	local notmemberchecks = {}
	local parsemembers = {}
	local otherchecks = {}
	local nototherchecks = {}
	local groupis = {}
	local recursion = false

	--MF_alert("Updating grouprules")

	for i,v in ipairs(groupfeatures) do
		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]

		if (rule[1] ~= "group") and (rule[1] ~= "not group") and (rule[3] ~= "group") and (rule[3] ~= "not group") then
			table.insert(otherchecks, v)
		elseif (rule[1] ~= "group") and (rule[1] ~= "not group") and ((rule[3] == "group") or (rule[3] == "not group")) then
			if (rule[2] == "is") then
				local valid = true
				local groupcond = false

				for a,cond in ipairs(conds) do
					if (cond[1] == "never") then
						valid = false
						break
					end

					for c,param in ipairs(cond[2]) do
						if (param == "group") then
							recursion = true
							groupcond = true
							break
						elseif (param == "not group") then
							recursion = true
							break
						end
					end
				end

				if valid then
					local obj = rule[1]

					local notmember = false
					local notrule = false

					if (string.sub(obj, 1, 4) == "not ") then
						obj = string.sub(obj, 5)
						notrule = true
					end

					if (rule[3] == "not group") then
						notmember = true
					end

					if notrule then
						table.insert(parsemembers, {obj, conds, notmember, groupcond})
					else
						if (notmember == false) then
							if (memberchecks[obj] == nil) then
								memberchecks[obj] = {}
							end

							table.insert(memberchecks[obj], {conds, groupcond})
						else
							if (notmemberchecks[obj] == nil) then
								notmemberchecks[obj] = {}
							end

							table.insert(notmemberchecks[obj], {conds, groupcond})
						end
					end
				end
			else
				if (rule[3] == "group") then
					table.insert(otherchecks, v)
				elseif (rule[3] == "not group") then
					local obj = rule[1]

					if (nototherchecks[obj] == nil) then
						nototherchecks[obj] = {}
					end

					table.insert(nototherchecks[obj], {rule[2], conds})
				end
			end
		elseif (rule[1] == "group") or (rule[1] == "not group") then
			table.insert(groupis, v)
		end
	end

	for i,v in ipairs(parsemembers) do
		local notname = v[1]
		local notmember = v[3]

		if (notname ~= "all") then
			for m,mat in pairs(objectlist) do
				if (m ~= notname) and (m ~= "all") and (m ~= "level") and (m ~= "group") and (m ~= "text") and (string.sub(m, 1, 5) ~= "text_") and (m ~= "empty") then
					if (notmember == false) then
						--MF_alert("added " .. m)

						if (memberchecks[m] == nil) then
							memberchecks[m] = {}
						end

						table.insert(memberchecks[m], {v[2], v[4]})
					else
						if (notmemberchecks[m] == nil) then
							notmemberchecks[m] = {}
						end

						table.insert(notmemberchecks[m], {v[2], v[4]})
					end
				end
			end
		else
			if (notmember == false) then
				--MF_alert("added " .. m)

				if (memberchecks["empty"] == nil) then
					memberchecks["empty"] = {}
				end

				if (memberchecks["text"] == nil) then
					memberchecks["text"] = {}
				end

				table.insert(memberchecks["empty"], {v[2], v[4]})
				table.insert(memberchecks["text"], {v[2], v[4]})
			else
				if (notmemberchecks["empty"] == nil) then
					notmemberchecks["empty"] = {}
				end

				if (notmemberchecks["text"] == nil) then
					notmemberchecks["text"] = {}
				end

				table.insert(notmemberchecks["empty"], {v[2], v[4]})
				table.insert(notmemberchecks["text"], {v[2], v[4]})
			end
		end
	end

	local membercode = ""
	local oldmembercode = ""
	groupunits = {}
	local memberlist = {}
	local oldmemberlist = {}
	local done = false
	local limit = 0

	-- Muista lisätä kaikki membercheckin ja notmembercheckin jäsenet groupunitseihin! Myös condseista!! findunits(name,groupunits,conds)

	while (done == false) and (limit < 400) do
		for member,data in pairs(memberchecks) do
			local members = nil

			if (member ~= "empty") then
				members = unitlists[member]
			else
				members = findempty()
			end

			for h,j in ipairs(data) do
				local found = false
				local addtolist = false
				local condstotest = {}
				local notcondstotest = {}
				local conds = j[1]
				local groupcond = j[2]

				local autofail = false

				if recursion or (groupcond == false) then
					for i,cond in ipairs(conds) do
						local ncond = {cond[1], {}}
						addtolist = true

						for a,param in ipairs(cond[2]) do
							if (param ~= "group") and (param ~= "not group") then
								table.insert(ncond[2], param)

								if (param ~= "all") then
									groupunits[param] = 1
								end
							elseif (param == "group") then
								recursion = true
								for c,d in ipairs(oldmemberlist) do
									table.insert(ncond[2], d[1])
									groupunits[d[1]] = 1
								end
							else
								recursion = true
								if (#oldmemberlist > 0) then
									for e,f in ipairs(oldmemberlist) do
										table.insert(ncond[2], "not " .. f[1])
									end
								else
									table.insert(ncond[2], "not edge")
								end

								for m,mat in pairs(objectlist) do
									if (m ~= "all") and (m ~= "level") and (m ~= "group") and (m ~= "text") and (string.sub(m, 1, 5) ~= "text_") and (m ~= "empty") then
										local addthis = true

										for e,f in ipairs(oldmemberlist) do
											if (m == f[1]) then
												addthis = false
												break
											end
										end

										if addthis then
											groupunits[m] = 1
										end
									end
								end
							end
						end

						table.insert(condstotest, ncond)
					end
				end

				if (notmemberchecks[member] ~= nil) then
					for a,b in ipairs(notmemberchecks[member]) do
						if (#b[1] == 0) then
							autofail = true
							break
						end

						table.insert(notcondstotest, {})

						local nctest = notcondstotest[#notcondstotest]
						local ncgroupcond = b[2]
						addtolist = true

						if recursion or (ncgroupcond == false) then
							for i,cond in ipairs(b[1]) do
								local ncond = {cond[1], {}}

								for a,param in ipairs(cond[2]) do
									if (param ~= "group") and (param ~= "not group") then
										table.insert(ncond[2], param)

										if (param ~= "all") then
											groupunits[param] = 1
										end
									elseif (param == "group") then
										recursion = true
										for c,d in ipairs(oldmemberlist) do
											table.insert(ncond[2], d[1])
											groupunits[d[1]] = 1
										end
									else
										recursion = true
										if (#oldmemberlist > 0) then
											for e,f in ipairs(oldmemberlist) do
												table.insert(ncond[2], "not " .. f[1])
											end
										else
											table.insert(ncond[2], "not edge")
										end

										for m,mat in pairs(objectlist) do
											if (m ~= "all") and (m ~= "level") and (m ~= "group") and (m ~= "text") and (string.sub(m, 1, 5) ~= "text_") and (m ~= "empty") then
												local addthis = true

												for e,f in ipairs(oldmemberlist) do
													if (m == f[1]) then
														addthis = false
														break
													end
												end

												if addthis then
													groupunits[m] = 1
												end
											end
										end
									end
								end

								table.insert(nctest, ncond)
							end
						end
					end
				end

				if (#condstotest == 0) and (#notcondstotest == 0) and (autofail == false) then
					found = true
				end

				if (autofail == false) and (members ~= nil) then
					for a,b in ipairs(members) do
						local x,y = -1,-1
						local unitid = b

						if (member == "empty") then
							local x = math.floor(b % roomsizex)
							local y = math.floor(b / roomsizex)
							unitid = 2
						end

						local nottest = false

						for c,d in ipairs(notcondstotest) do
							if testcond(d,unitid,x,y) then
								nottest = true
								break
							end
						end

						if (nottest == false) and testcond(condstotest,unitid,x,y) then
							if (member ~= "empty") then
								local bunit = mmf.newObject(b)

								if (bunit.flags[DEAD] == false) then
									found = true
								end
							else
								found = true
							end
						end
					end
				end

				if addtolist then
					groupunits[member] = 1
				end

				if found then
					local fullconds = {}
					if (#notcondstotest > 0) then
						for i,v in ipairs(notcondstotest) do
							fullconds = invertconds(v,fullconds)
						end
					end
					for i,v in ipairs(condstotest) do
						table.insert(fullconds, v)
					end

					table.insert(memberlist, {member, fullconds})
					membercode = membercode .. member
				end
			end
		end

		if (recursion == false) then
			done = true
		else
			MF_alert(membercode .. ", " .. oldmembercode)

			if (membercode ~= oldmembercode) then
				oldmembercode = membercode
				membercode = ""
				groupunits = {}
				oldmemberlist = {}

				for a,b in ipairs(memberlist) do
					table.insert(oldmemberlist, {b[1], b[2]})
				end

				memberlist = {}
			else
				done = true
			end
		end

		limit = limit + 1

		if (limit >= 400) then
			HACK_INFINITY = 200
			destroylevel("infinity")
			return
		end
	end

	for i,v in ipairs(otherchecks) do
		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]

		local newconds = {}
		local newtags = {}

		local valid = true

		if (rule[3] == "group") then
			local obj = rule[1]
			if (nototherchecks[obj] ~= nil) then
				for a,b in ipairs(nototherchecks[obj]) do
					if (b[1] == rule[2]) then
						if (#b[2] == 0) then
							valid = false
							break
						else
							newconds = invertconds(b[2],newconds)
						end
					end
				end
			end
		end

		if valid then
			for a,cond in ipairs(conds) do
				local newcond = {cond[1], {}}

				for c,param in ipairs(cond[2]) do
					if (param ~= "group") and (param ~= "not group") then
						table.insert(newcond[2], param)
					elseif (param == "group") then
						if (#memberlist > 0) then
							for e,f in ipairs(memberlist) do
								table.insert(newcond[2], f[1])
							end
						else
							table.insert(newcond[2], "_none_")
						end
					else
						if (#memberlist > 0) then
							for e,f in ipairs(memberlist) do
								table.insert(newcond[2], "not " .. f[1])
							end
						else
							table.insert(newcond[2], "not edge")
						end
					end
				end

				table.insert(newconds, newcond)
			end

			for c,tag in ipairs(tags) do
				table.insert(newtags, tag)
			end

			table.insert(newtags, "group")

			if (rule[3] ~= "group") and (rule[3] ~= "not group") then
				addoption(rule,newconds,ids,false,nil,newtags)
			elseif (rule[3] == "group") then
				for a,b in ipairs(memberlist) do
					local newrule = {rule[1],rule[2],b[1]}

					addoption(newrule,newconds,ids,false,nil,newtags)
				end
			end
		end
	end

	for g,v in ipairs(groupis) do
		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]

		local newconds = {}
		for a,cond in ipairs(conds) do
			local newcond = {cond[1], {}}

			for c,param in ipairs(cond[2]) do
				if (param ~= "group") and (param ~= "not group") then
					table.insert(newcond[2], param)
				elseif (param == "group") then
					if (#memberlist > 0) then
						for e,f in ipairs(memberlist) do
							table.insert(newcond[2], f[1])
						end
					else
						table.insert(newcond[2], "_none_")
					end
				else
					if (#memberlist > 0) then
						for e,f in ipairs(memberlist) do
							table.insert(newcond[2], "not " .. f[1])
						end
					else
						table.insert(newcond[2], "not edge")
					end
				end
			end

			table.insert(newconds, newcond)
		end

		local newtags = {}

		for c,tag in ipairs(tags) do
			table.insert(newtags, tag)
		end

		table.insert(newtags, "group")

		local targets = {}
		if (rule[1] == "group") then
			targets = memberlist
		elseif (rule[1] == "not group") then
			for m,mat in pairs(objectlist) do
				if (m ~= "all") and (m ~= "text") and (string.sub(m, 1, 5) ~= "text_") and (m ~= "group") and (m ~= "all") and (m ~= "level") then
					local valid = true

					for e,f in ipairs(memberlist) do
						if (f[1] == m) then
							valid = false
						end
					end

					if valid then
						table.insert(targets, {m, {}})
					end
				end
			end
		end

		if (rule[3] ~= "group") and (rule[3] ~= "not group") then
			for a,b in ipairs(targets) do
				local mname = b[1]

				local finalconds = {}
				for c,d in ipairs(newconds) do
					table.insert(finalconds, d)
				end
				for c,d in ipairs(b[2]) do
					table.insert(finalconds, d)
				end

				local newrule = {mname,rule[2],rule[3]}
				addoption(newrule,finalconds,ids,false,nil,newtags)
			end
		else
			if (rule[1] ~= "not group") then
				for a,b in ipairs(memberlist) do
					local mname = b[1]
					local mname2 = b[1]

					if (rule[3] == "not group") then
						mname2 = "not " .. b[1]
					end

					local finalconds = {}
					for c,d in ipairs(newconds) do
						table.insert(finalconds, d)
					end
					for c,d in ipairs(b[2]) do
						table.insert(finalconds, d)
					end

					if (rule[1] == "group") then
						local newrule = {mname,rule[2],mname2}
						addoption(newrule,finalconds,ids,false,nil,newtags)
					end
				end
			else
				if (rule[3] == "group") then
					for m,mat in pairs(objectlist) do
						if (m ~= "all") and (m ~= "level") and (m ~= "group") and (m ~= "text") and (string.sub(m, 1, 5) ~= "text_") and (m ~= "empty") then
							local addthis = true

							for e,f in ipairs(memberlist) do
								if (m == f[1]) then
									addthis = false
									break
								end
							end

							if addthis then
								local mname = m
								local newrule = {mname,"is","crash"}
								addoption(newrule,newconds,ids,false,nil,newtags)
							end
						end
					end
				end
			end
		end
	end
end
