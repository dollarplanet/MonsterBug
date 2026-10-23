local cards = require("scripts.data.cards")

local M = {}

local PILES = { "draw", "hand", "discard" }
local ALL_PILES = { "draw", "hand", "discard", "burned" }

local function random_index(n)
	if n <= 0 then
		return nil
	end
	return math.random(n)
end

function M.health(run)
	return #run.draw + #run.hand + #run.discard
end

function M.add_card(run, id, dest)
	local inst = { id = id, uid = run.next_uid }
	run.next_uid = run.next_uid + 1
	if id == "Larva" then
		inst.hatch_timer = 2
	end
	dest = dest or "discard"
	if run[dest] == nil then
		dest = "discard"
	end
	table.insert(run[dest], inst)
	run.max_hp = (run.max_hp or 0) + 1
	return inst
end

function M.find(run, uid)
	for _, pile in ipairs(ALL_PILES) do
		local list = run[pile]
		for i = 1, #list do
			if list[i].uid == uid then
				return list[i], pile, i
			end
		end
	end
	return nil
end

function M.remove_uid(run, uid)
	local inst, pile, index = M.find(run, uid)
	if not inst then
		return nil, nil
	end
	table.remove(run[pile], index)
	return inst, pile
end

function M.add_to_pile(run, inst, dest)
	dest = dest or "discard"
	table.insert(run[dest], inst)
end

function M.damage_card(run, inst)
	local pile = nil
	for _, p in ipairs({ "draw", "hand", "discard" }) do
		for i = 1, #run[p] do
			if run[p][i].uid == inst.uid then
				table.remove(run[p], i)
				pile = p
				break
			end
		end
		if pile then
			break
		end
	end
	if not pile then
		return nil
	end
	run.burned[#run.burned + 1] = inst
	return inst
end

function M.exile_card(run, inst)
	local pile = nil
	for _, p in ipairs({ "draw", "hand", "discard" }) do
		for i = 1, #run[p] do
			if run[p][i].uid == inst.uid then
				table.remove(run[p], i)
				pile = p
				break
			end
		end
		if pile then
			break
		end
	end
	if not pile then
		return nil
	end
	run.max_hp = math.max(0, (run.max_hp or 0) - 1)
	return inst
end

local function collect(run, filter, exclude_uid, include_burned)
	local result = {}
	for _, pile in ipairs(include_burned and ALL_PILES or PILES) do
		local list = run[pile]
		for i = 1, #list do
			local inst = list[i]
			if inst.uid ~= exclude_uid then
				local def = cards[inst.id]
				if not filter or filter(inst, def, pile) then
					result[#result + 1] = inst
				end
			end
		end
	end
	return result
end

function M.damage_random(run, n, filter, exclude_uid)
	local burned = {}
	for _ = 1, n do
		local list = collect(run, filter, exclude_uid)
		if #list == 0 then
			break
		end
		local inst = list[random_index(#list)]
		if M.damage_card(run, inst) then
			burned[#burned + 1] = inst
		end
	end
	return burned
end

function M.exile_random(run, n, filter, exclude_uid)
	local removed = {}
	for _ = 1, n do
		local list = collect(run, filter, exclude_uid)
		if #list == 0 then
			break
		end
		local inst = list[random_index(#list)]
		if M.exile_card(run, inst) then
			removed[#removed + 1] = inst
		end
	end
	return removed
end

function M.discard_random(run, n)
	local moved = {}
	for _ = 1, n do
		if #run.draw == 0 then
			break
		end
		local index = random_index(#run.draw)
		local inst = table.remove(run.draw, index)
		run.discard[#run.discard + 1] = inst
		moved[#moved + 1] = inst
	end
	return moved
end

function M.find_junk(run)
	local result = {}
	for _, pile in ipairs(PILES) do
		for _, inst in ipairs(run[pile]) do
			local def = cards[inst.id]
			if def and (def.cat == "Junk" or def.cat == "Curse") then
				result[#result + 1] = inst
			end
		end
	end
	return result
end

function M.exile_junk(run, n)
	local removed = {}
	for _ = 1, n do
		local junk = M.find_junk(run)
		if #junk == 0 then
			break
		end
		local inst = junk[random_index(#junk)]
		if M.exile_card(run, inst) then
			removed[#removed + 1] = inst
		end
	end
	return removed
end

function M.revive_burned(run, n)
	local revived = {}
	for _ = 1, n do
		if #run.burned == 0 then
			break
		end
		local index = random_index(#run.burned)
		local inst = table.remove(run.burned, index)
		run.discard[#run.discard + 1] = inst
		revived[#revived + 1] = inst
	end
	return revived
end

function M.discard_hand(run)
	local count = #run.hand
	for _, inst in ipairs(run.hand) do
		run.discard[#run.discard + 1] = inst
	end
	run.hand = {}
	return count
end

function M.shuffle(run, list)
	for i = #list, 2, -1 do
		local j = math.random(i)
		list[i], list[j] = list[j], list[i]
	end
end

function M.shuffle_discard_into_draw(run)
	if #run.discard == 0 then
		return false
	end
	for _, inst in ipairs(run.discard) do
		run.draw[#run.draw + 1] = inst
	end
	run.discard = {}
	M.shuffle(run, run.draw)
	return true
end

function M.draw(run, n)
	local events = {}
	for _ = 1, n do
		if #run.draw == 0 then
			M.shuffle_discard_into_draw(run)
		end
		if #run.draw == 0 then
			events[#events + 1] = { t = "deck_empty" }
			break
		end

		local inst = table.remove(run.draw)
		local def = cards[inst.id]
		if def and def.curse then
			events[#events + 1] = { t = "poison", card = inst.id }
			local burned = M.damage_random(run, 1, nil, inst.uid)
			for _, b in ipairs(burned) do
				events[#events + 1] = { t = "burned", card = b.id, source = "poison" }
			end
			run.discard[#run.discard + 1] = inst
		else
			run.hand[#run.hand + 1] = inst
			events[#events + 1] = { t = "draw", card = inst.id }
			if inst.id == "Larva" then
				if not inst.hatch_timer then
					inst.hatch_timer = 2
				end
				events[#events + 1] = { t = "larva_draw", uid = inst.uid, turns = inst.hatch_timer }
			end
		end
	end
	return events
end

function M.new(seed)
	local run = {
		seed = seed or os.time(),
		next_uid = 1,
		draw = {},
		hand = {},
		discard = {},
		burned = {},
		max_hp = 0,
		encounter = 1,
		used_monsters = {},
		monster_id = nil,
		stats = { kills = 0, turns = 0, burns = 0 },
	}
	for _, id in ipairs(cards.starting_deck) do
		M.add_card(run, id, "discard")
	end
	M.shuffle(run, run.discard)
	for _, inst in ipairs(run.discard) do
		run.draw[#run.draw + 1] = inst
	end
	run.discard = {}
	return run
end

function M.validate(run)
	if type(run) ~= "table" then
		return false
	end
	for _, pile in ipairs(ALL_PILES) do
		if type(run[pile]) ~= "table" then
			return false
		end
		for _, inst in ipairs(run[pile]) do
			if type(inst) ~= "table" or not cards[inst.id] or type(inst.uid) ~= "number" then
				return false
			end
		end
	end
	return type(run.max_hp) == "number" and type(run.encounter) == "number"
end

function M.normalize(run)
	for _, pile in ipairs(ALL_PILES) do
		for _, inst in ipairs(run[pile]) do
			if inst.id == "Larva" and not inst.hatch_timer then
				inst.hatch_timer = 2
			end
		end
	end
	return run
end

return M
