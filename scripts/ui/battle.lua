local L = require("scripts.ui.layout")
local P = require("scripts.ui.palette")
local W = require("scripts.ui.widgets")
local cards = require("scripts.data.cards")
local monsters = require("scripts.data.monsters")
local i18n = require("scripts.data.i18n")
local asset_map = require("scripts.data.asset_map")
local state = require("scripts.game.state")
local combat = require("scripts.game.combat")
local game_run = require("scripts.game.run")

local B = {}

local v3 = vmath.vector3

local function t(app, key, ...)
	return i18n.text(app.lang, key, ...)
end

local function card_name(id)
	local def = cards[id]
	return def and def.name or tostring(id or "?")
end

local function type_color(need)
	return P.type[need] or { bg = P.panel_soft, border = P.border, text = P.text }
end

local function slot_state(app, index, slot, valid_set, layout)
	local pos = layout.positions[index]
	local r = W.rect(pos.x, pos.y, layout.w, layout.h)
	local tc = type_color(slot.need)
	local selected = app.selected_uid ~= nil
	local valid = valid_set and valid_set[index]
	local bg_color = tc.bg
	local border_color = tc.border
	if slot.closed then
		bg_color = P.panel_dark
		border_color = P.dim
	elseif selected then
		if valid then
			bg_color = P.alpha(tc.bg, 1)
			border_color = P.gold
		else
			bg_color = P.alpha(tc.bg, 0.55)
			border_color = P.dim
		end
	end

	local bg, border = W.panel(app.layer, r, 40, { color = bg_color, border = border_color })
	local stripe = W.box(app.layer, W.rect(r.x, r.y, 9, r.h), slot.closed and P.dim or tc.border, 42)
	local part_color = slot.closed and P.muted or P.text
	local type_text_color = slot.closed and P.muted or tc.text
	W.text(app.layer, r.x + 24, r.y + r.h * 0.68, i18n.part(app.lang, slot.part), "ui_22", part_color, 44)
	W.text(app.layer, r.x + 24, r.y + r.h * 0.33, t(app, "need", i18n.need(app.lang, slot.need)), "ui_18", type_text_color, 44)
	local status = slot.closed and t(app, "closed") or t(app, "open")
	local status_color = slot.closed and P.muted or tc.text
	W.text(app.layer, r.x + r.w - 118, r.y + r.h / 2, status, "ui_14", status_color, 44)

	if not slot.closed then
		app.slot_hits[#app.slot_hits + 1] = { rect = r, index = index }
	end

	return bg, border, stripe
end

local function draw_monster(app)
	local id = app.combat.monster_id
	local def = monsters[id]
	local info = asset_map.monsters[id]
	if not def or not info then
		return
	end
	local scale = math.min(L.monster.max_w / info.w, L.monster.max_h / info.h, 1)
	local w = info.w * scale
	local h = info.h * scale
	local cx = L.monster.cx
	local cy = L.monster.bottom + h / 2
	W.image(app.layer, cx, cy, w, h, info.atlas, info.anim, P.white, 2)

	local tier_key = def.boss and "boss" or "insect"
	local encounter = t(app, "encounter", app.run.encounter, app.run.encounters_total or game_run.ENCOUNTERS)
	local tier = t(app, tier_key, def.tier)
	local panel_r = L.top.name
	W.panel(app.layer, panel_r, 500, { color = P.alpha(P.panel, 0.9), border = def.boss and P.red_bright or P.border })
	W.text(app.layer, panel_r.x + 20, panel_r.y + 72, def.name, def.boss and "ui_36" or "ui_36",
		def.boss and P.red_text or P.text, 502, 24)
	W.text(app.layer, panel_r.x + 20, panel_r.y + 30, encounter .. "  ·  " .. tier, "ui_18", P.muted, 502, 48)

	local statuses = {}
	if (app.combat.shield_charges or 0) > 0 then
		statuses[#statuses + 1] = t(app, "shield_status", app.combat.shield_charges)
	end
	if (app.combat.skip_attacks or 0) > 0 then
		statuses[#statuses + 1] = t(app, "skip_status", app.combat.skip_attacks)
	end
	if (app.combat.prevent_plays or 0) > 0 then
		statuses[#statuses + 1] = t(app, "prevent_status", app.combat.prevent_plays)
	end
	if app.combat.prevent_regen then
		statuses[#statuses + 1] = t(app, "regen_status")
	end
	if #statuses > 0 then
		W.text(app.layer, panel_r.x + 20, panel_r.y - 26, table.concat(statuses, "  ·  "), "ui_18", P.gold, 510, 52)
	end
end

local function draw_top(app)
	local monster = monsters[app.combat.monster_id]
	if not monster then
		return
	end

	local pause_rect = L.top.pause
	app.buttons[#app.buttons + 1] = W.button(app.layer, pause_rect, "II", "ui_28", function()
		app:show_pause()
	end, { color = P.panel, border = P.gold_soft, text_color = P.text, z = 510 })

	local end_rect = L.top.end_turn
	app.buttons[#app.buttons + 1] = W.button(app.layer, end_rect, t(app, "end_turn"), "ui_28", function()
		app:end_turn()
	end, {
		color = (app.combat.won or app.run.pending_reward) and P.panel_soft or P.red,
		border = P.red_bright,
		text_color = P.text,
		z = 510,
	})
end

local function draw_threat(app)
	local r = L.threat
	W.panel(app.layer, r, 300, { color = P.alpha(P.panel_dark, 0.94), border = P.red })
	local current = combat.current_threat(app.combat)
	local nexts = combat.next_threats(app.combat)

	local cur = L.threat.current
	W.text(app.layer, cur.x, cur.y + cur.h - 18, t(app, "threat_current"), "ui_14", P.red_text, 302, 30)
	W.text(app.layer, cur.x, cur.y + cur.h / 2 - 8, combat and i18n.threat(app.lang, current) or "-", "ui_28", P.text, 302, 22)

	local nxt = L.threat.next
	W.text(app.layer, nxt.x, nxt.y + nxt.h - 18, t(app, "threat_next"), "ui_14", P.gold_soft, 302, 30)
	local line_y = nxt.y + nxt.h - 52
	for i, item in ipairs(nexts) do
		local key = item.plus and "threat_turn_plus" or "threat_turn"
		local desc = i18n.threat(app.lang, item.threat)
		W.text(app.layer, nxt.x, line_y - (i - 1) * 32, t(app, key, item.turn, desc), "ui_18", P.muted, 302, 54)
	end
end

local function draw_card(app, inst, index, pos, count)
	local def = cards[inst.id]
	local info = asset_map.cards[inst.id]
	if not def or not info then
		return
	end
	local w = L.hand.card_w
	local h = L.hand.card_h
	local cx = pos.x
	local cy = L.hand.y + h / 2
	local z = 600 + index

	local glow = W.box(app.layer, W.rect(cx, cy, w + 16, h + 16), P.gold, z - 1)
	gui.set_pivot(glow, gui.PIVOT_CENTER)
	gui.set_rotation(glow, v3(0, 0, math.rad(pos.rotation)))
	gui.set_enabled(glow, false)

	local color = P.white
	local playable = def.playable ~= false and (def.cost or 0) <= app.combat.actions
	if not playable then
		color = vmath.vector4(0.58, 0.52, 0.46, 1)
	end

	local node = W.image(app.layer, cx, cy, w, h, info.atlas, info.anim, color, z)
	gui.set_rotation(node, v3(0, 0, math.rad(pos.rotation)))

	local text_color = playable and P.text or P.muted
	local desc = i18n.card_text(app.lang, def)
	W.text(node, -112, -76, desc, "ui_14", text_color, 1, 21)

	local view = {
		uid = inst.uid,
		card_id = inst.id,
		node = node,
		glow = glow,
		cx = cx,
		cy = cy,
		rotation = pos.rotation,
		z = z,
		rect = W.rect(cx - w / 2, cy - h / 2, w, h),
	}
	app.card_views[inst.uid] = view
	app.card_order[#app.card_order + 1] = view
end

local function draw_hand(app)
	local hand = app.run.hand or {}
	local positions = L.hand_positions(#hand)
	local label = t(app, "hand", app.combat.actions, #hand)
	W.text(app.layer, L.hand.margin, L.hand.label_y, label, "ui_22", P.gold, 590, 60)

	for i, inst in ipairs(hand) do
		draw_card(app, inst, i, positions[i], #hand)
	end

	if app.selected_uid then
		local inst = nil
		for _, it in ipairs(hand) do
			if it.uid == app.selected_uid then
				inst = it
				break
			end
		end
		if inst then
			local def = cards[inst.id]
			local name = def and def.name or tostring(inst.id)
			local mode = def and combat.target_mode(def, app.combat) or "none"
			local hint_key = mode == "none" and "hint_play" or "hint_battle"
			local prompt_r = W.rect(30, 632, 1020, 44)
			W.panel(app.layer, prompt_r, 592, { color = P.alpha(P.teal, 0.94), border = P.teal_bright })
			W.text(app.layer, 48, prompt_r.y + 22, name .. "  ·  " .. t(app, hint_key), "ui_18", P.teal_text, 594, 70)
		end
	end
end

local function draw_footer(app)
	local health = state.health(app.run)
	local max_hp = math.max(app.run.max_hp or 0, health, 1)
	local ratio = math.max(0, math.min(1, health / max_hp))

	local deck = L.footer.deck
	W.panel(app.layer, deck, 520, { color = P.alpha(P.panel, 0.94), border = P.gold_soft })
	W.text(app.layer, deck.x + 14, deck.y + 66, tostring(health), "ui_48", P.text, 522)
	W.text(app.layer, deck.x + 14, deck.y + 24, t(app, "deck_health"), "ui_14", P.muted, 522, 16)

	local hr = L.footer.health
	W.panel(app.layer, hr, 520, { color = P.panel_dark, border = P.border })
	local bar_color = ratio > 0.5 and P.green_bright or (ratio > 0.25 and P.orange_bright or P.red_bright)
	W.box(app.layer, W.rect(hr.x + 4, hr.y + 4, (hr.w - 8) * ratio, hr.h - 8), W.alpha(bar_color, 0.55), 521)
	W.text(app.layer, hr.x + 18, hr.y + hr.h / 2, t(app, "health_total"), "ui_18", P.text, 522)
	W.text(app.layer, hr.x + hr.w - 170, hr.y + hr.h / 2, string.format("%d / %d", health, max_hp), "ui_28", P.text, 522)

	W.text(app.layer, 30, L.footer.deck_label_y, t(app, "deck_hint"), "ui_14", P.muted, 525, 22)
	W.text(app.layer, 410, L.footer.health_label_y - 4, t(app, "deck_hint2"), "ui_14", P.muted, 525, 40)
end

function B.render(app)
	app.buttons = {}
	app.slot_hits = {}
	app.card_views = {}
	app.card_order = {}

	if not app.combat or not app.run then
		app:render_menu()
		return
	end

	W.image(app.layer, 540, 960, 1080, 1920, asset_map.board.atlas, asset_map.board.anim, P.white, 1)
	draw_monster(app)

	local label_r = W.rect(L.slots.label.x, L.slots.label.y - 18, 260, 44)
	W.panel(app.layer, label_r, 80, { color = P.alpha(P.panel_dark, 0.92), border = P.gold_soft })
	W.text(app.layer, label_r.x + 12, label_r.y + 22, t(app, "target_slots"), "ui_22", P.gold)

	local inst = nil
	if app.selected_uid then
		for _, it in ipairs(app.run.hand) do
			if it.uid == app.selected_uid then
				inst = it
				break
			end
		end
	end
	local valid_set = {}
	if inst then
		local def = cards[inst.id]
		if def then
			for _, idx in ipairs(combat.valid_targets(def, app.combat)) do
				valid_set[idx] = true
			end
		end
	end

	local slot_layout = L.slot_layout(#app.combat.slots)
	for i, slot in ipairs(app.combat.slots) do
		slot_state(app, i, slot, valid_set, slot_layout)
	end

	draw_threat(app)
	draw_hand(app)
	draw_footer(app)
	draw_top(app)

	app:update_card_selection()
end

return B
