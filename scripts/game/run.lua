local cards = require("scripts.data.cards")
local monsters = require("scripts.data.monsters")
local state = require("scripts.game.state")
local combat = require("scripts.game.combat")
local storage = require("scripts.game.storage")

local M = {}

M.ENCOUNTERS = 8

local function has(list, value)
	for _, v in ipairs(list or {}) do
		if v == value then
			return true
		end
	end
	return false
end

function M.pick_monster(run)
	local total = run.encounters_total or M.ENCOUNTERS
	if run.encounter >= total then
		run.monster_id = "EmperorScorpion"
		return "EmperorScorpion"
	end

	local tier = monsters.encounter_tiers[run.encounter] or 3
	local candidates = {}
	local fallback = {}
	for _, id in ipairs(monsters.order) do
		local def = monsters[id]
		if not def.boss and not has(run.used_monsters, id) then
			fallback[#fallback + 1] = id
			if def.tier == tier then
				candidates[#candidates + 1] = id
			end
		end
	end
	if #candidates == 0 then
		candidates = fallback
	end
	if #candidates == 0 then
		for _, id in ipairs(monsters.order) do
			if not monsters[id].boss then
				candidates[#candidates + 1] = id
			end
		end
	end
	local id = candidates[math.random(#candidates)]
	run.used_monsters[#run.used_monsters + 1] = id
	run.monster_id = id
	return id
end

function M.new(seed)
	seed = seed or os.time()
	math.randomseed(seed)
	local run = state.new(seed)
	run.encounter = 1
	run.encounters_total = M.ENCOUNTERS
	run.monster_id = nil
	M.pick_monster(run)
	return run
end

function M.start_encounter(run)
	if #run.hand > 0 then
		state.discard_hand(run)
	end
	if not run.monster_id then
		M.pick_monster(run)
	end
	local c = combat.new(run, run.monster_id)
	local events = combat.begin(run, c)
	return c, events
end

function M.finish_encounter(run, c)
	if c and c.won then
		run.stats.kills = (run.stats.kills or 0) + 1
	end
	state.discard_hand(run)
end

function M.next_encounter(run)
	run.encounter = run.encounter + 1
	run.monster_id = nil
	if run.encounter > (run.encounters_total or M.ENCOUNTERS) then
		return false
	end
	M.pick_monster(run)
	return true
end

function M.reward_choices(run)
	local weapon = cards.reward_weapons[math.random(#cards.reward_weapons)]
	local junk = state.find_junk(run)
	local cleanse_card = "Meat"
	if #junk > 0 then
		cleanse_card = junk[math.random(#junk)].id
	end
	return {
		{ kind = "meat", card = "Meat", has_junk = #junk > 0 },
		{ kind = "weapon", card = weapon, has_junk = #junk > 0 },
		{ kind = "cleanse", card = cleanse_card, has_junk = #junk > 0 },
	}
end

function M.apply_reward(run, choice)
	if not choice then
		return nil
	end
	if choice.kind == "weapon" then
		local inst = state.add_card(run, choice.card, "discard")
		return { kind = "weapon", card = choice.card, inst = inst }
	elseif choice.kind == "cleanse" then
		local removed = state.exile_junk(run, 1)
		if #removed > 0 then
			return { kind = "cleanse", card = removed[1].id }
		end
		state.add_card(run, "Meat", "discard")
		return { kind = "cleanse_none", card = "Meat" }
	else
		local inst = state.add_card(run, "Meat", "discard")
		return { kind = "meat", card = "Meat", inst = inst }
	end
end

function M.serialize(run, c)
	return {
		run = run,
		combat = c and combat.serialize(c) or nil,
	}
end

function M.load_payload(payload)
	if type(payload) ~= "table" or not state.validate(payload.run) then
		return nil, nil
	end
	local run = state.normalize(payload.run)
	if not run.encounters_total then
		run.encounters_total = 6
	end
	local c = nil
	if payload.combat then
		c = combat.deserialize(payload.combat)
	end
	return run, c
end

function M.save(lang, run, c)
	local data = { lang = lang }
	if run then
		local payload = M.serialize(run, c)
		data.run = payload.run
		data.combat = payload.combat
	end
	return storage.save(data)
end

function M.clear_run(lang)
	return storage.save({ lang = lang })
end

function M.set_language(lang)
	local data = storage.load() or {}
	data.lang = lang
	return storage.save(data)
end

function M.load()
	return storage.load()
end

return M
