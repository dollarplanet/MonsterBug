local cards = require("scripts.data.cards")
local monsters = require("scripts.data.monsters")
local state = require("scripts.game.state")

local M = {}

local function add(events, t, data)
	data = data or {}
	data.t = t
	events[#events + 1] = data
end

local function norm(value)
	return string.lower(value or "")
end

local function contains(value, key)
	return norm(value):find(norm(key), 1, true) ~= nil
end

function M.part_matches(part, key)
	local n = norm(part)
	local k = norm(key)
	if k == "shield" then
		return n:find("shell", 1, true) ~= nil or n:find("shield", 1, true) ~= nil
	end
	if k == "leg" or k == "legs" then
		return n:find("leg", 1, true) ~= nil
	end
	if k == "wing" then
		return n:find("wing", 1, true) ~= nil
	end
	if k == "abdomen" then
		return n:find("abdomen", 1, true) ~= nil
	end
	return contains(part, key)
end

function M.is_shield(slot)
	return M.part_matches(slot.part, "shield")
end

function M.new(run, monster_id)
	local def = monsters[monster_id]
	if not def then
		return nil
	end
	local c = {
		monster_id = monster_id,
		turn = 1,
		actions = 3,
		max_actions = 3,
		threat_index = 1,
		skip_attacks = 0,
		shield_charges = 0,
		prevent_plays = 0,
		prevent_regen = false,
		stall_turns = 0,
		progress_turn = false,
		won = false,
		slots = {},
	}
	for i, slot in ipairs(def.slots) do
		c.slots[i] = { part = slot.part, need = slot.need, closed = false }
	end
	return c
end

function M.begin(run, c)
	c.turn = 1
	c.actions = 3
	c.threat_index = 1
	c.skip_attacks = 0
	c.shield_charges = 0
	c.prevent_plays = 0
	c.prevent_regen = false
	c.stall_turns = 0
	c.progress_turn = false
	c.won = false
	return state.draw(run, 5)
end

function M.current_threat(c)
	local def = monsters[c.monster_id]
	if not def then
		return { kind = "skip" }
	end
	local count = #def.threats
	if count == 0 then
		return { kind = "skip" }
	end
	local index = ((c.threat_index - 1) % count) + 1
	return def.threats[index]
end

function M.next_threats(c)
	local def = monsters[c.monster_id]
	local result = {}
	if not def then
		return result
	end
	local count = #def.threats
	if count == 0 then
		return result
	end
	for i = 1, 2 do
		local wanted = c.threat_index + i
		local index = ((wanted - 1) % count) + 1
		result[#result + 1] = {
			turn = c.turn + i,
			threat = def.threats[index],
			plus = wanted > count,
		}
	end
	return result
end

function M.valid_targets(card, c)
	local e = card.effect and card.effect.close
	if not e or e.match == "all_shields" then
		return {}
	end
	local result = {}
	for i, slot in ipairs(c.slots) do
		if not slot.closed then
			local ok = false
			if e.match == "any" then
				ok = true
			elseif e.match == "type" and slot.need == e.type then
				ok = true
			elseif e.match == "part" and M.part_matches(slot.part, e.part) then
				ok = true
			end
			if not ok and e.bonus_part and M.part_matches(slot.part, e.bonus_part) then
				ok = true
			end
			if not ok and e.ignore_shield and M.is_shield(slot) then
				ok = true
			end
			if ok then
				result[#result + 1] = i
			end
		end
	end
	return result
end

function M.target_mode(card, c)
	local e = card.effect and card.effect.close
	if not e then
		return "none"
	end
	if e.match == "all_shields" then
		return "none"
	end
	local valid = M.valid_targets(card, c)
	if #valid == 0 then
		if e.optional then
			return "none"
		end
		return "invalid"
	end
	return "slot"
end

function M.all_closed(c)
	for _, slot in ipairs(c.slots) do
		if not slot.closed then
			return false
		end
	end
	return true
end

local function close_slots(run, c, card, slot_index, events)
	local e = card.effect.close
	local closed = {}

	if e.match == "all_shields" then
		for _, slot in ipairs(c.slots) do
			if not slot.closed and M.is_shield(slot) then
				slot.closed = true
				closed[#closed + 1] = slot.part
			end
		end
		if #closed == 0 and e.fallback_any then
			for _, slot in ipairs(c.slots) do
				if not slot.closed then
					slot.closed = true
					closed[#closed + 1] = slot.part
					break
				end
			end
		end
	else
		if not slot_index then
			if e.optional then
				return true
			end
			return false, { { t = "choose_slot" } }
		end
		local slot = c.slots[slot_index]
		if not slot or slot.closed then
			return false, { { t = "invalid_target" } }
		end
		slot.closed = true
		closed[#closed + 1] = slot.part

		local total = e.count or 1
		if e.bonus_part and M.part_matches(slot.part, e.bonus_part) then
			total = total + (e.bonus_extra or 1)
			add(events, "slot_bonus")
		end

		while #closed < total do
			local found = nil
			for i, s in ipairs(c.slots) do
				if not s.closed and s.need == slot.need then
					found = i
					break
				end
			end
			if not found then
				local valid = M.valid_targets(card, c)
				for _, i in ipairs(valid) do
					if not c.slots[i].closed then
						found = i
						break
					end
				end
			end
			if not found then
				for i, s in ipairs(c.slots) do
					if not s.closed then
						found = i
						break
					end
				end
			end
			if not found then
				break
			end
			c.slots[found].closed = true
			closed[#closed + 1] = c.slots[found].part
		end
	end

	if #closed == 0 then
		return false, { { t = "no_target" } }
	end
	c.progress_turn = true
	add(events, "closed", { parts = closed, count = #closed })
	return true
end

local function burn_direct(run, n, events, source)
	local list = state.damage_random(run, n)
	for _, inst in ipairs(list) do
		add(events, "burned", { card = inst.id, source = source })
		run.stats.burns = run.stats.burns + 1
	end
	return #list
end

local function burn_with_shield(run, c, n, events)
	local absorbed = 0
	local burned = 0
	for _ = 1, n do
		if c.shield_charges > 0 then
			c.shield_charges = c.shield_charges - 1
			absorbed = absorbed + 1
		else
			local list = state.damage_random(run, 1)
			if #list == 0 then
				break
			end
			burned = burned + 1
			add(events, "burned", { card = list[1].id, source = "monster" })
			run.stats.burns = run.stats.burns + 1
		end
	end
	if absorbed > 0 then
		add(events, "shield_absorb", { count = absorbed })
	end
	return burned, absorbed
end

function M.apply_threat(run, c, threat, events)
	if not threat then
		return
	end
	local kind = threat.kind
	local value = threat.value or 1
	if kind == "burn" or kind == "slash" or kind == "pierce" or kind == "sting"
		or kind == "poison" or kind == "sound" then
		burn_with_shield(run, c, value, events)
	elseif kind == "insert_larva" then
		for _ = 1, value do
			state.add_card(run, "Larva", "discard")
		end
		add(events, "larva_inserted", { count = value })
	elseif kind == "destroy_weapon" then
		local list = state.damage_random(run, 1, function(_, def)
			return def and (def.cat == "Blunt" or def.cat == "Slash" or def.cat == "Pierce"
				or def.cat == "Web" or def.cat == "Fire")
		end)
		if #list > 0 then
			add(events, "destroy_weapon", { card = list[1].id })
		else
			local burned, absorbed = burn_with_shield(run, c, 1, events)
			add(events, "destroy_weapon_none", { burned = burned, absorbed = absorbed })
		end
	elseif kind == "prevent_play" then
		c.prevent_plays = 1
		add(events, "prevent_play")
	elseif kind == "skip" then
		add(events, "skip", { label = threat.label })
	end
end

local function apply_secondary(run, c, card, events)
	local e = card.effect or {}
	if e.prevent_attack then
		c.skip_attacks = c.skip_attacks + e.prevent_attack
		add(events, "skip_gain", { count = e.prevent_attack })
	end
	if e.insert_larva then
		for _ = 1, e.insert_larva do
			state.add_card(run, "Larva", "discard")
		end
		add(events, "larva_inserted", { count = e.insert_larva })
	end
	if e.burn_larva then
		local list = state.damage_random(run, e.burn_larva, function(inst)
			return inst.id == "Larva"
		end)
		for _, inst in ipairs(list) do
			add(events, "burned", { card = inst.id, source = "torch" })
			run.stats.burns = run.stats.burns + 1
		end
	end
	if e.prevent_regen then
		c.prevent_regen = true
	end
	if e.shield then
		c.shield_charges = c.shield_charges + e.shield
		add(events, "shield_gain", { count = e.shield })
	end
	if e.actions then
		c.actions = c.actions + e.actions
		add(events, "action_gain", { count = e.actions })
	end
	if e.heal then
		local revived = state.revive_burned(run, e.heal)
		if #revived > 0 then
			for _, inst in ipairs(revived) do
				add(events, "heal_revived", { card = inst.id })
			end
		else
			state.add_card(run, "Meat", "discard")
			add(events, "heal_meat")
		end
	end
	if e.burn_junk then
		local removed = state.exile_junk(run, e.burn_junk)
		if #removed > 0 then
			for _, inst in ipairs(removed) do
				add(events, "junk_removed", { card = inst.id })
			end
		else
			add(events, "no_junk")
		end
	end
	if e.alert then
		add(events, "alert")
	end
end

function M.play(run, c, uid, slot_index)
	local inst, pile = state.find(run, uid)
	if not inst or pile ~= "hand" then
		return false, { { t = "not_in_hand" } }
	end
	local card = cards[inst.id]
	if not card or card.playable == false then
		return false, { { t = "unplayable" } }
	end
	if c.won then
		return false, {}
	end
	if (c.prevent_plays or 0) > 0 then
		c.prevent_plays = c.prevent_plays - 1
		return false, { { t = "prevented" } }
	end
	local cost = card.cost or 0
	if cost > c.actions then
		return false, { { t = "not_enough_actions" } }
	end

	local mode = M.target_mode(card, c)
	if mode == "invalid" then
		return false, { { t = "no_target" } }
	end
	if mode == "slot" then
		if not slot_index then
			return false, { { t = "choose_slot" } }
		end
		local valid = M.valid_targets(card, c)
		local ok = false
		for _, i in ipairs(valid) do
			if i == slot_index then
				ok = true
				break
			end
		end
		if not ok then
			return false, { { t = "invalid_target" } }
		end
	end

	local events = {}
	c.actions = c.actions - cost
	state.remove_uid(run, uid)
	add(events, "card_played", { card = inst.id })

	local ok, err = true, nil
	if card.effect and card.effect.close then
		ok, err = close_slots(run, c, card, slot_index, events)
	end
	if not ok then
		c.actions = c.actions + cost
		state.add_to_pile(run, inst, "hand")
		return false, err or { { t = "invalid_target" } }
	end

	apply_secondary(run, c, card, events)

	if inst.id == "Larva" then
		run.burned[#run.burned + 1] = inst
		add(events, "burned", { card = inst.id, source = "exile" })
		run.stats.burns = run.stats.burns + 1
	else
		state.add_to_pile(run, inst, "discard")
	end

	if M.all_closed(c) then
		c.won = true
		add(events, "monster_dead", { monster = c.monster_id })
	end
	return true, events
end

function M.end_turn(run, c)
	local events = {}
	if c.won then
		return events, "ok"
	end

	local larvae = {}
	for _, pile in ipairs({ "draw", "hand", "discard" }) do
		for _, inst in ipairs(run[pile]) do
			if inst.id == "Larva" then
				larvae[#larvae + 1] = inst
			end
		end
	end

	for _, inst in ipairs(larvae) do
		local found, pile = state.find(run, inst.uid)
		if found and pile ~= "burned" then
			if not inst.hatch_timer then
				inst.hatch_timer = 2
			end
			inst.hatch_timer = inst.hatch_timer - 1
			if inst.hatch_timer <= 0 then
				add(events, "larva_hatch")
				local burned = state.damage_random(run, 2, nil, inst.uid)
				for _, b in ipairs(burned) do
					add(events, "burned", { card = b.id, source = "larva" })
					run.stats.burns = run.stats.burns + 1
				end
				state.damage_card(run, inst)
				add(events, "burned", { card = inst.id, source = "larva" })
				run.stats.burns = run.stats.burns + 1
			end
		end
	end

	state.discard_hand(run)
	c.prevent_plays = 0

	if state.health(run) <= 0 then
		return events, "lost"
	end

	if c.progress_turn then
		c.stall_turns = 0
	else
		c.stall_turns = (c.stall_turns or 0) + 1
	end
	c.progress_turn = false

	if (c.stall_turns or 0) >= 2 then
		burn_direct(run, 1, events, "stall")
		if state.health(run) <= 0 then
			return events, "lost"
		end
	end

	local threat = M.current_threat(c)
	if c.skip_attacks > 0 then
		c.skip_attacks = c.skip_attacks - 1
		add(events, "attack_skipped", { remaining = c.skip_attacks })
	else
		add(events, "attack", { threat = threat })
		M.apply_threat(run, c, threat, events)
	end

	local def = monsters[c.monster_id]
	if def then
		local count = #def.threats
		if count > 0 then
			c.threat_index = (c.threat_index % count) + 1
		end
	end

	if state.health(run) <= 0 then
		return events, "lost"
	end

	c.turn = c.turn + 1
	c.actions = 3
	run.stats.turns = run.stats.turns + 1

	local draw_events = state.draw(run, 5)
	for _, e in ipairs(draw_events) do
		events[#events + 1] = e
	end

	if state.health(run) <= 0 then
		return events, "lost"
	end
	return events, "ok"
end

function M.serialize(c)
	local slots = {}
	for i, slot in ipairs(c.slots) do
		slots[i] = { part = slot.part, need = slot.need, closed = slot.closed }
	end
	return {
		monster_id = c.monster_id,
		turn = c.turn,
		actions = c.actions,
		max_actions = c.max_actions,
		threat_index = c.threat_index,
		skip_attacks = c.skip_attacks,
		shield_charges = c.shield_charges,
		prevent_plays = c.prevent_plays,
		prevent_regen = c.prevent_regen,
		stall_turns = c.stall_turns or 0,
		progress_turn = c.progress_turn or false,
		won = c.won,
		slots = slots,
	}
end

function M.deserialize(data)
	if type(data) ~= "table" or not monsters[data.monster_id] then
		return nil
	end
	local c = M.new(nil, data.monster_id)
	if not c then
		return nil
	end
	c.turn = data.turn or 1
	c.actions = data.actions or 3
	c.max_actions = data.max_actions or 3
	c.threat_index = data.threat_index or 1
	c.skip_attacks = data.skip_attacks or 0
	c.shield_charges = data.shield_charges or 0
	c.prevent_plays = data.prevent_plays or 0
	c.prevent_regen = data.prevent_regen or false
	c.stall_turns = data.stall_turns or 0
	c.progress_turn = data.progress_turn or false
	c.won = data.won or false
	if type(data.slots) == "table" then
		for i, slot in ipairs(c.slots) do
			if data.slots[i] then
				slot.closed = data.slots[i].closed or false
			end
		end
	end
	return c
end

return M
