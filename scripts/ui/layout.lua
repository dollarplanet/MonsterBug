local L = {}

L.DESIGN_W = 1080
L.DESIGN_H = 1920

local BASE = {
	top = {
		name = { x = 30, y = 1788, w = 540, h = 112 },
		pause = { x = 640, y = 1798, w = 96, h = 96 },
		end_turn = { x = 760, y = 1798, w = 290, h = 96 },
	},
	monster = {
		cx = 500,
		max_w = 900,
		max_h = 900,
	},
	slots = {
		label = { x = 30, y = 1228 },
		positions = {
			{ x = 30, y = 1078 },
			{ x = 560, y = 1078 },
			{ x = 30, y = 938 },
			{ x = 560, y = 938 },
		},
		w = 490,
		h = 120,
	},
	threat = {
		x = 30, y = 688, w = 1020, h = 172,
	},
	hand = {
		label_y = 592,
		y = 172,
		card_w = 260,
		card_h = 388,
		margin = 40,
	},
	weapon_mark = {
		pad = 12,
		aspect = 260 / 388,
	},
	monster_cards = {
		cx = 130,
		y = 1650,
		h = 210,
		gap = 156,
	},
	footer = {
		deck = { x = 30, y = 30, w = 150, h = 112 },
		health = { x = 410, y = 42, w = 640, h = 82 },
		deck_label_y = 126,
		health_label_y = 138,
	},
	card_text = {
		x = 10,
		y = 74,
		w = 182,
		h = 88,
	},
	reward_cards = {
		{ x = 110, y = 700 },
		{ x = 410, y = 700 },
		{ x = 710, y = 700 },
	},
	card_preview = {
		image = { cx = 540, cy = 1040, w = 540, h = 806 },
		close = { x = 350, y = 400, w = 380, h = 86 },
	},
}

local function copy_rect(r)
	return { x = r.x, y = r.y, w = r.w, h = r.h }
end

local function copy_pos(pos)
	return { x = pos.x, y = pos.y }
end

local function copy_positions(list)
	local out = {}
	for i, pos in ipairs(list) do
		out[i] = copy_pos(pos)
	end
	return out
end

function L.reset()
	L.W = L.DESIGN_W
	L.H = L.DESIGN_H
	L.scale = 1
	L.ox = 0
	L.extra_y = 0
	L.safe = { left = 0, right = 0, top = 0, bottom = 0 }

	L.top = {
		name = copy_rect(BASE.top.name),
		pause = copy_rect(BASE.top.pause),
		end_turn = copy_rect(BASE.top.end_turn),
	}
	L.monster = {
		cx = BASE.monster.cx,
		top = BASE.top.end_turn.y - 10,
		max_w = BASE.monster.max_w,
		max_h = BASE.monster.max_h,
	}
	L.slots = {
		label = copy_pos(BASE.slots.label),
		positions = copy_positions(BASE.slots.positions),
		w = BASE.slots.w,
		h = BASE.slots.h,
	}
	L.threat = {
		x = BASE.threat.x,
		y = BASE.threat.y,
		w = BASE.threat.w,
		h = BASE.threat.h,
		current = { x = 46, y = 704, w = 380, h = 140 },
		next = { x = 442, y = 704, w = 592, h = 140 },
	}
	L.hand = {
		label_y = BASE.hand.label_y,
		y = BASE.hand.y,
		card_w = BASE.hand.card_w,
		card_h = BASE.hand.card_h,
		margin = BASE.hand.margin,
		left = BASE.hand.margin,
		right = L.W - BASE.hand.margin,
	}
	L.weapon_mark = {
		pad = BASE.weapon_mark.pad,
		aspect = BASE.weapon_mark.aspect,
	}
	L.monster_cards = {
		cx = BASE.monster_cards.cx,
		y = BASE.monster_cards.y,
		h = BASE.monster_cards.h,
		gap = BASE.monster_cards.gap,
	}
	L.footer = {
		deck = copy_rect(BASE.footer.deck),
		health = copy_rect(BASE.footer.health),
		deck_label_y = BASE.footer.deck_label_y,
		health_label_y = BASE.footer.health_label_y,
	}
	L.card_text = copy_rect(BASE.card_text)
	L.modal = {
		reward_cards = copy_positions(BASE.reward_cards),
	}
	L.card_preview = {
		image = copy_rect(BASE.card_preview.image),
		close = copy_rect(BASE.card_preview.close),
	}
end

function L.configure(window_w, window_h, safe_area)
	window_w = tonumber(window_w) or L.DESIGN_W
	window_h = tonumber(window_h) or L.DESIGN_H
	if window_w <= 0 or window_h <= 0 then
		window_w, window_h = L.DESIGN_W, L.DESIGN_H
	end

	L.reset()

	local scale = math.min(window_w / L.DESIGN_W, window_h / L.DESIGN_H)
	if scale <= 0 then
		scale = 1
	end
	L.scale = scale
	L.W = window_w / scale
	L.H = window_h / scale
	L.ox = (L.W - L.DESIGN_W) / 2
	L.extra_y = L.H - L.DESIGN_H

	local safe = safe_area or {}
	L.safe.left = math.max(0, (safe.inset_left or 0) / scale)
	L.safe.right = math.max(0, (safe.inset_right or 0) / scale)
	L.safe.top = math.max(0, (safe.inset_top or 0) / scale)
	L.safe.bottom = math.max(0, (safe.inset_bottom or 0) / scale)

	L.top.name.x = L.safe.left + 30
	L.top.name.y = L.H - L.safe.top - 20 - L.top.name.h
	L.top.end_turn.x = L.W - L.safe.right - 30 - L.top.end_turn.w
	L.top.end_turn.y = L.top.name.y + 10
	L.top.pause.x = L.top.end_turn.x - 24 - L.top.pause.w
	L.top.pause.y = L.top.end_turn.y

	L.monster.cx = L.W / 2 - 40
	L.monster.top = L.top.end_turn.y - 10

	for _, pos in ipairs(L.slots.positions) do
		pos.x = pos.x + L.ox
		pos.y = pos.y + L.safe.bottom
	end
	L.slots.label.x = L.slots.label.x + L.ox
	L.slots.label.y = L.slots.label.y + L.safe.bottom

	L.threat.x = L.safe.left + 30
	L.threat.y = BASE.threat.y + L.safe.bottom
	L.threat.w = L.W - L.safe.left - L.safe.right - 60
	local threat_right = L.threat.x + L.threat.w
	L.threat.current.x = L.threat.x + 16
	L.threat.current.y = L.threat.y + 16
	L.threat.next.x = L.threat.current.x + L.threat.current.w + 16
	L.threat.next.y = L.threat.current.y
	L.threat.next.w = threat_right - 16 - L.threat.next.x

	L.hand.y = BASE.hand.y + L.safe.bottom
	L.hand.label_y = BASE.hand.label_y + L.safe.bottom
	L.hand.left = L.safe.left + L.hand.margin
	L.hand.right = L.W - L.safe.right - L.hand.margin

	L.monster_cards.cx = L.safe.left + 130
	L.monster_cards.y = L.top.name.y - 33 - L.monster_cards.h / 2

	L.footer.deck.x = L.safe.left + 30
	L.footer.deck.y = BASE.footer.deck.y + L.safe.bottom
	L.footer.health.x = L.W - L.safe.right - 30 - L.footer.health.w
	L.footer.health.y = BASE.footer.health.y + L.safe.bottom
	L.footer.deck_label_y = BASE.footer.deck_label_y + L.safe.bottom
	L.footer.health_label_y = BASE.footer.health_label_y + L.safe.bottom

	for i, rect in ipairs(L.modal.reward_cards) do
		rect.x = BASE.reward_cards[i].x + L.ox
		rect.y = BASE.reward_cards[i].y + L.safe.bottom + L.extra_y / 2
	end

	L.card_preview.image.cx = L.W / 2
	L.card_preview.image.cy = L.H / 2 + 80
	L.card_preview.close.x = L.W / 2 - L.card_preview.close.w / 2
	L.card_preview.close.y = L.H / 2 - 560
end

function L.slot_layout(count)
	count = math.max(1, math.min(5, count or 3))
	if count < 5 then
		local positions = {}
		for i = 1, count do
			positions[i] = L.slots.positions[i]
		end
		return {
			positions = positions,
			w = L.slots.w,
			h = L.slots.h,
			label_y = L.slots.label.y,
		}
	end
	local positions = {
		{ x = 30 + L.ox, y = 1218 + L.safe.bottom },
		{ x = 560 + L.ox, y = 1218 + L.safe.bottom },
		{ x = 30 + L.ox, y = 1078 + L.safe.bottom },
		{ x = 560 + L.ox, y = 1078 + L.safe.bottom },
		{ x = 30 + L.ox, y = 938 + L.safe.bottom },
	}
	return {
		positions = positions,
		w = L.slots.w,
		h = L.slots.h,
		label_y = positions[1].y + L.slots.h + 36,
	}
end

function L.hand_positions(count)
	local result = {}
	if count <= 0 then
		return result
	end
	local left = L.hand.left or L.hand.margin
	local right = L.hand.right or (L.W - L.hand.margin)
	local usable = math.max(0, right - left)
	local step = 0
	if count > 1 then
		step = (usable - L.hand.card_w) / (count - 1)
	end
	for i = 1, count do
		local x = left + L.hand.card_w / 2 + (i - 1) * step
		local rotation = (i - (count + 1) / 2) * 3
		result[i] = { x = x, y = L.hand.y, rotation = rotation }
	end
	return result
end

L.reset()

return L
