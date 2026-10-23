local script_path = debug.getinfo(1, "S").source:sub(2)
local root = script_path:match("^(.*)/tools/[^/]+$") or "."
package.path = root .. "/?.lua;" .. package.path

_G.sys = _G.sys or {
	get_save_file = function()
		return "/tmp/monsterbug_sim_save"
	end,
	load = function()
		return nil
	end,
	save = function()
		return true
	end,
}

local cards = require("scripts.data.cards")
local monsters = require("scripts.data.monsters")
local state = require("scripts.game.state")
local combat = require("scripts.game.combat")
local run_mod = require("scripts.game.run")
local layout = require("scripts.ui.layout")
local i18n = require("scripts.data.i18n")

monsters.__TestSkip = {
	name = "Test Skip",
	tier = 1,
	slots = {
		{ part = "Head", need = "Blunt" },
		{ part = "Legs", need = "Slash" },
		{ part = "Abdomen", need = "Pierce" },
	},
	threats = { { kind = "skip", label = "sleep" } },
}

local function reset_piles(run)
	run.draw = {}
	run.hand = {}
	run.discard = {}
	run.burned = {}
	run.next_uid = 1
	run.max_hp = 0
	run.stats = { kills = 0, turns = 0, burns = 0 }
end

local function add_inst(run, id, pile, timer)
	local inst = { id = id, uid = run.next_uid }
	run.next_uid = run.next_uid + 1
	if timer then
		inst.hatch_timer = timer
	end
	table.insert(run[pile], inst)
	run.max_hp = run.max_hp + 1
	return inst
end

local function fill(run, id, count, pile)
	for _ = 1, count do
		add_inst(run, id, pile)
	end
end

local function test_larva_crash()
	local run = state.new(101)
	reset_piles(run)
	add_inst(run, "Meat", "hand")
	add_inst(run, "Meat", "hand")
	local larva = add_inst(run, "Larva", "hand", 1)
	local c = combat.new(run, "StagBeetle")
	local old_random = math.random
	math.random = function(n)
		if n then
			return 1
		end
		return 0
	end
	local ok, err = pcall(combat.end_turn, run, c)
	math.random = old_random
	assert(ok, "Larva hatch crash: " .. tostring(err))
	assert(larva ~= nil, "Larva fixture missing")
end

local function test_destroy_weapon_fallback()
	local run = state.new(102)
	reset_piles(run)
	fill(run, "Meat", 30, "draw")
	local c = combat.new(run, "GoliathBeetle")
	c.threat_index = 2
	c.turn = 2
	local before = state.health(run)
	local ok, err = pcall(combat.end_turn, run, c)
	assert(ok, "destroy_weapon crashed: " .. tostring(err))
	assert(state.health(run) < before, "destroy_weapon did not burn a fallback card")
end

local function test_skip_cycle()
	local run = state.new(103)
	reset_piles(run)
	fill(run, "Meat", 60, "draw")
	local c = combat.new(run, "PeacockSpider")
	c.threat_index = 2
	c.turn = 2
	local before = state.health(run)
	for _ = 1, 3 do
		local ok, err = pcall(combat.end_turn, run, c)
		assert(ok, "skip cycle crashed: " .. tostring(err))
	end
	assert(state.health(run) < before, "skip threat never cycled to damage")
end

local function test_skip_stall_guard()
	local run = state.new(104)
	reset_piles(run)
	fill(run, "Meat", 60, "draw")
	local c = combat.new(run, "__TestSkip")
	local before = state.health(run)
	for _ = 1, 4 do
		local ok, err = pcall(combat.end_turn, run, c)
		assert(ok, "stall guard crashed: " .. tostring(err))
	end
	assert(state.health(run) < before, "stall guard did not break the skip loop")
end

local function test_larva_pile(pile, seed)
	local run = state.new(seed)
	reset_piles(run)
	fill(run, "Meat", 30, "draw")
	local larva = add_inst(run, "Larva", pile, 1)
	local c = combat.new(run, "__TestSkip")
	local ok, err = pcall(combat.end_turn, run, c)
	assert(ok, "Larva in " .. pile .. " crashed: " .. tostring(err))
	local found, location = state.find(run, larva.uid)
	assert(not found or location == "burned", "Larva in " .. pile .. " did not hatch")
end

local function test_larva_all_piles()
	test_larva_pile("draw", 105)
	test_larva_pile("hand", 106)
	test_larva_pile("discard", 107)
end

local function test_larva_draw_preserves_timer()
	local run = state.new(108)
	reset_piles(run)
	local larva = add_inst(run, "Larva", "draw", 1)
	state.draw(run, 5)
	assert(larva.hatch_timer == 1, "draw reset Larva timer")
end

local function test_add_card_sets_timer()
	local run = state.new(109)
	reset_piles(run)
	local larva = state.add_card(run, "Larva", "discard")
	assert(larva.hatch_timer == 2, "spawned Larva timer not set")
end

local function test_larva_normalize()
	local run = state.new(110)
	reset_piles(run)
	local larva = add_inst(run, "Larva", "discard")
	larva.hatch_timer = nil
	state.normalize(run)
	assert(larva.hatch_timer == 2, "old save Larva timer not normalized")
end

local function test_multiple_larva_hatch()
	local run = state.new(111)
	reset_piles(run)
	fill(run, "Meat", 30, "draw")
	add_inst(run, "Larva", "hand", 1)
	add_inst(run, "Larva", "hand", 1)
	local c = combat.new(run, "__TestSkip")
	local ok, err = pcall(combat.end_turn, run, c)
	assert(ok, "multiple Larva hatch crashed: " .. tostring(err))
end

local function test_reward_pool()
	local obtainable = {}
	for _, id in ipairs(cards.starting_deck) do
		obtainable[id] = true
	end
	for _, id in ipairs(cards.reward_weapons) do
		obtainable[id] = true
	end
	for _, id in ipairs(cards.order) do
		if id ~= "Meat" and not cards.junk[id] then
			assert(obtainable[id], "unobtainable card: " .. id)
		end
	end
end

local function test_run_progression()
	local run = run_mod.new(112)
	assert(run.encounters_total == 8, "new run total is not 8")
	run.encounter = 8
	run.used_monsters = {}
	run_mod.pick_monster(run)
	assert(run.monster_id == "EmperorScorpion", "final encounter is not the boss")
	assert(#monsters.EmperorScorpion.slots == 5, "boss does not have 5 slots")
	for _, id in ipairs(monsters.order) do
		local def = monsters[id]
		if def.tier == 2 and not def.boss then
			assert(#def.slots == 4, id .. " tier 2 does not have 4 slots")
		elseif def.tier == 3 and not def.boss then
			assert(#def.slots == 5, id .. " tier 3 does not have 5 slots")
		end
	end
end

local function test_old_save_migration()
	local payload = { run = run_mod.new(113) }
	payload.run.encounters_total = nil
	local migrated = run_mod.load_payload(payload)
	assert(migrated and migrated.encounters_total == 6, "old save total not migrated to 6")
end

local function test_slot_layout()
	for _, count in ipairs({ 3, 4, 5 }) do
		local slots = layout.slot_layout(count)
		assert(#slots.positions == count, "slot layout missing positions for " .. count)
		assert(slots.w and slots.h, "slot layout missing size for " .. count)
	end
end

local function test_i18n_encounters()
	assert(i18n.text("en", "encounter", 8, 8):find("8/8"), "English encounter total missing")
	assert(i18n.text("id", "stats", 8, 8, 5, 20):find("8/8"), "Indonesian stats total missing")
end

local function test_molotov_no_junk()
	local run = state.new(114)
	reset_piles(run)
	local molotov = add_inst(run, "MolotovCocktail", "hand")
	add_inst(run, "Meat", "hand")
	add_inst(run, "Meat", "hand")
	local c = combat.new(run, "StagBeetle")
	c.actions = 3
	local ok = combat.play(run, c, molotov.uid, nil)
	assert(ok, "Molotov play failed")
	assert(#run.hand == 2, "Molotov discarded non-junk cards")
	assert(run.hand[1].id == "Meat" and run.hand[2].id == "Meat", "Molotov removed the wrong cards")
end

local function test_threat_cycle()
	for _, id in ipairs(monsters.order) do
		local def = monsters[id]
		if #def.threats > 0 then
			local run = state.new(200)
			reset_piles(run)
			fill(run, "Meat", 30, "draw")
			local c = combat.new(run, id)
			c.threat_index = #def.threats
			c.turn = #def.threats
			local ok, err = pcall(combat.end_turn, run, c)
			assert(ok, "threat cycle crashed for " .. id .. ": " .. tostring(err))
			assert(c.threat_index == 1, "threat did not wrap for " .. id)
		end
	end
end

local function choose_play(run, c)
	for _, inst in ipairs(run.hand) do
		local def = cards[inst.id]
		if def and def.playable ~= false and inst.id ~= "Larva"
			and (def.cost or 0) <= c.actions then
			local mode = combat.target_mode(def, c)
			if mode == "slot" then
				local targets = combat.valid_targets(def, c)
				if #targets > 0 then
					return inst.uid, targets[1]
				end
			elseif mode == "none" then
				local effect = def.effect or {}
				if next(effect) then
					return inst.uid, nil
				end
			end
		end
	end
	return nil, nil
end

local function play_turn(run, c, trace)
	local guard = 0
	while c.actions > 0 and guard < 32 do
		guard = guard + 1
		local uid, slot = choose_play(run, c)
		if not uid then
			if trace then
				print("  no play")
			end
			break
		end
		local inst = state.find(run, uid)
		local ok, result = combat.play(run, c, uid, slot)
		if trace then
			print(string.format(
				"  play %s slot=%s ok=%s actions=%d",
				inst and inst.id or "?",
				tostring(slot),
				tostring(ok),
				c.actions
			))
		end
		if not ok then
			local kind = result and result[1] and result[1].t
			if kind ~= "prevented" then
				break
			end
		elseif c.won or state.health(run) <= 0 then
			break
		end
	end
end

local function choose_reward(run, choices)
	local health = state.health(run)
	local weapon, meat, cleanse
	local has_junk = false
	for _, choice in ipairs(choices) do
		if choice.kind == "weapon" then
			weapon = choice
		elseif choice.kind == "meat" then
			meat = choice
		elseif choice.kind == "cleanse" then
			cleanse = choice
			if choice.has_junk then
				has_junk = true
			end
		end
	end
	if health <= 8 and meat then
		return meat
	end
	if has_junk and cleanse then
		return cleanse
	end
	return weapon or meat or cleanse or choices[1]
end

local function simulate_run(seed, turn_cap)
	math.randomseed(seed)
	local run = run_mod.new(seed)
	local c = run_mod.start_encounter(run)
	local turns = 0
	while true do
		turns = turns + 1
		if turns > turn_cap then
			return "stuck", run, turns
		end
		play_turn(run, c)
		if c.won then
			run_mod.finish_encounter(run, c)
			local choices = run_mod.reward_choices(run)
			run_mod.apply_reward(run, choose_reward(run, choices))
			if state.health(run) <= 0 then
				return "lost", run, turns
			end
			if not run_mod.next_encounter(run) then
				return "won", run, turns
			end
			c = run_mod.start_encounter(run)
		else
			local _, status = combat.end_turn(run, c)
			if status == "lost" then
				return "lost", run, turns
			end
		end
	end
end

local function inspect_run(seed, turn_cap)
	math.randomseed(seed)
	local run = run_mod.new(seed)
	local c = run_mod.start_encounter(run)
	local turns = 0
	while true do
		turns = turns + 1
		if turns > turn_cap then
			local closed = {}
			local open = {}
			for i, slot in ipairs(c.slots) do
				if slot.closed then
					closed[#closed + 1] = slot.part
				else
					open[#open + 1] = i .. ":" .. slot.part .. ":" .. slot.need
				end
			end
			local hand = {}
			for _, inst in ipairs(run.hand) do
				hand[#hand + 1] = inst.id
			end
			local threat = combat.current_threat(c)
			print(string.format(
				"stuck seed=%d turn=%d encounter=%d monster=%s hp=%d stall=%d threat=%s actions=%d prevent=%d shield=%d",
				seed,
				turns,
				run.encounter,
				tostring(c.monster_id),
				state.health(run),
				c.stall_turns or 0,
				tostring(threat and threat.kind),
				c.actions,
				c.prevent_plays or 0,
				c.shield_charges or 0
			))
			print("closed: " .. table.concat(closed, ", "))
			print("open: " .. table.concat(open, ", "))
			print("hand: " .. table.concat(hand, ", "))
			print(string.format(
				"draw=%d discard=%d burned=%d",
				#run.draw,
				#run.discard,
				#run.burned
			))
			return "stuck"
		end
		play_turn(run, c)
		if c.won then
			run_mod.finish_encounter(run, c)
			local choices = run_mod.reward_choices(run)
			run_mod.apply_reward(run, choose_reward(run, choices))
			if state.health(run) <= 0 then
				print("lost seed=" .. seed .. " turn=" .. turns .. " encounter=" .. run.encounter)
				return "lost"
			end
			if not run_mod.next_encounter(run) then
				print("won seed=" .. seed .. " turn=" .. turns)
				return "won"
			end
			c = run_mod.start_encounter(run)
		else
			local _, status = combat.end_turn(run, c)
			if status == "lost" then
				print("lost seed=" .. seed .. " turn=" .. turns .. " encounter=" .. run.encounter)
				return "lost"
			end
		end
	end
end

local function trace_run(seed, turn_cap)
	math.randomseed(seed)
	local run = run_mod.new(seed)
	local c = run_mod.start_encounter(run)
	local turns = 0
	while turns < turn_cap do
		turns = turns + 1
		local threat = combat.current_threat(c)
		local hand = {}
		for _, inst in ipairs(run.hand) do
			hand[#hand + 1] = inst.id
		end
		print(string.format(
			"T%02d enc=%d mon=%s hp=%d hand=%d draw=%d discard=%d actions=%d threat=%s stall=%d",
			turns,
			run.encounter,
			tostring(c.monster_id),
			state.health(run),
			#run.hand,
			#run.draw,
			#run.discard,
			c.actions,
			tostring(threat and threat.kind),
			c.stall_turns or 0
		))
		print("  hand: " .. table.concat(hand, ", "))
		play_turn(run, c, true)
		if c.won then
			run_mod.finish_encounter(run, c)
			local choices = run_mod.reward_choices(run)
			local choice = choose_reward(run, choices)
			print("  WON reward=" .. tostring(choice and choice.kind) .. " card=" .. tostring(choice and choice.card))
			run_mod.apply_reward(run, choice)
			if state.health(run) <= 0 then
				print("  LOST after reward turn=" .. turns)
				return
			end
			if not run_mod.next_encounter(run) then
				print("  RUN WON turn=" .. turns)
				return
			end
			c = run_mod.start_encounter(run)
		else
			local _, status = combat.end_turn(run, c)
			print("  end_turn status=" .. tostring(status) .. " hp=" .. state.health(run))
			if status == "lost" then
				return
			end
		end
	end
	print("  TRACE LIMIT")
end

local function suite(runs)
	local stats = {
		won = 0,
		lost = 0,
		stuck = 0,
		turns = 0,
		max_turns = 0,
		encounters = 0,
		win_turns = 0,
		loss_turns = 0,
	}
	local errors = 0
	local stuck_seeds = {}
	for i = 1, runs do
		local ok, result, run, turns = pcall(simulate_run, i, 300)
		if not ok then
			errors = errors + 1
			print("ERROR seed " .. i .. ": " .. tostring(result))
		else
			stats[result] = stats[result] + 1
			stats.turns = stats.turns + turns
			stats.encounters = stats.encounters + (run.stats.kills or 0)
			if result == "won" then
				stats.win_turns = stats.win_turns + turns
			elseif result == "lost" then
				stats.loss_turns = stats.loss_turns + turns
			end
			if turns > stats.max_turns then
				stats.max_turns = turns
			end
			if result == "stuck" then
				stuck_seeds[#stuck_seeds + 1] = i
			end
		end
	end
	local total = runs - errors
	if total > 0 then
		print(string.format(
			"runs=%d won=%d lost=%d stuck=%d errors=%d avg_turns=%.1f avg_win_turns=%.1f avg_loss_turns=%.1f avg_encounter=%.1f max_turns=%d",
			runs,
			stats.won,
			stats.lost,
			stats.stuck,
			errors,
			stats.turns / total,
			stats.win_turns / math.max(1, stats.won),
			stats.loss_turns / math.max(1, stats.lost),
			stats.encounters / total,
			stats.max_turns
		))
		if #stuck_seeds > 0 then
			print("stuck seeds: " .. table.concat(stuck_seeds, ", "))
		end
	end
	if errors > 0 or stats.stuck > 0 then
		os.exit(1)
	end
end

local function test_weapon_marks()
	local run = state.new(115)
	reset_piles(run)
	local c = combat.new(run, "StagBeetle")

	local hammer = add_inst(run, "StoneHammer", "hand")
	c.actions = 3
	local ok = combat.play(run, c, hammer.uid, 1)
	assert(ok, "target weapon play failed")
	assert(c.slots[1].weapon and c.slots[1].weapon.card == "StoneHammer", "target weapon mark missing")
	assert(c.slots[1].weapon.angle >= -45 and c.slots[1].weapon.angle <= 45, "target angle out of range")

	local shield = add_inst(run, "WoodenShield", "hand")
	c.actions = 3
	ok = combat.play(run, c, shield.uid, 2)
	assert(ok, "support play failed")
	assert(c.slots[2].weapon == nil, "support card was placed on a slot")
	assert(#c.monster_cards == 1 and c.monster_cards[1].card == "WoodenShield", "support mark missing")

	local sledge = add_inst(run, "GiantSledge", "hand")
	c.actions = 3
	ok = combat.play(run, c, sledge.uid, nil)
	assert(ok, "untargeted weapon play failed")
	assert(#c.monster_cards == 2 and c.monster_cards[2].card == "GiantSledge", "untargeted weapon mark missing")

	local molotov = add_inst(run, "MolotovCocktail", "hand")
	c.actions = 3
	ok = combat.play(run, c, molotov.uid, nil)
	assert(ok, "Molotov play failed")
	assert(#c.monster_cards == 3 and c.monster_cards[3].card == "MolotovCocktail", "Molotov mark missing")

	local seen = {}
	for _, mark in ipairs(c.monster_cards) do
		assert(mark.angle >= -45 and mark.angle <= 45, "monster angle out of range")
		assert(not seen[mark.angle], "duplicate monster card angle")
		seen[mark.angle] = true
	end

	local loaded = combat.deserialize(combat.serialize(c))
	assert(loaded and loaded.slots[1].weapon and loaded.slots[1].weapon.card == "StoneHammer",
		"target mark lost after save")
	assert(#loaded.monster_cards == 3, "monster marks lost after save")
	for i, mark in ipairs(c.monster_cards) do
		assert(loaded.monster_cards[i].card == mark.card, "monster mark card mismatch after save")
		assert(loaded.monster_cards[i].angle == mark.angle, "monster mark angle mismatch after save")
	end
end

local function run_tests()
	local tests = {
		{ "larva_crash", test_larva_crash },
		{ "destroy_weapon_fallback", test_destroy_weapon_fallback },
		{ "skip_cycle", test_skip_cycle },
		{ "skip_stall_guard", test_skip_stall_guard },
		{ "larva_all_piles", test_larva_all_piles },
		{ "larva_draw_preserves_timer", test_larva_draw_preserves_timer },
		{ "add_card_sets_timer", test_add_card_sets_timer },
		{ "larva_normalize", test_larva_normalize },
		{ "multiple_larva_hatch", test_multiple_larva_hatch },
		{ "reward_pool", test_reward_pool },
		{ "run_progression", test_run_progression },
		{ "old_save_migration", test_old_save_migration },
		{ "slot_layout", test_slot_layout },
		{ "i18n_encounters", test_i18n_encounters },
		{ "molotov_no_junk", test_molotov_no_junk },
		{ "weapon_marks", test_weapon_marks },
		{ "threat_cycle", test_threat_cycle },
	}
	local failures = 0
	for _, item in ipairs(tests) do
		local ok, err = pcall(item[2])
		if ok then
			print("PASS " .. item[1])
		else
			failures = failures + 1
			print("FAIL " .. item[1] .. ": " .. tostring(err))
		end
	end
	if failures > 0 then
		os.exit(1)
	end
end

local mode = "test"
local runs = 100
local seed = 1
local i = 1
while i <= #arg do
	if arg[i] == "--suite" then
		mode = "suite"
	elseif arg[i] == "--test" then
		mode = "test"
	elseif arg[i] == "--runs" then
		i = i + 1
		runs = tonumber(arg[i]) or runs
	elseif arg[i] == "--inspect" then
		mode = "inspect"
		i = i + 1
		seed = tonumber(arg[i]) or seed
	elseif arg[i] == "--trace" then
		mode = "trace"
		i = i + 1
		seed = tonumber(arg[i]) or seed
	end
	i = i + 1
end

if mode == "suite" then
	suite(runs)
elseif mode == "inspect" then
	inspect_run(seed, 300)
elseif mode == "trace" then
	trace_run(seed, 100)
else
	run_tests()
end
