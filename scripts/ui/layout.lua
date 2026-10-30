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
		label = { x = 30, y = 1592 },
		cols = 4,
		rows = 2,
		w = 220,
		h = 328,
		gap_x = 24,
		gap_y = 20,
		margin_x = 30,
		bottom_y = 880,
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
		cx = 90,
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

local function compute_slot_grid()
	local cols = BASE.slots.cols
	local rows = BASE.slots.rows
	local gap_x = BASE.slots.gap_x
	local gap_y = BASE.slots.gap_y
	local w = BASE.slots.w
	local available = L.W - L.safe.left - L.safe.right - BASE.slots.margin_x * 2
	local needed = cols * w + (cols - 1) * gap_x
	if needed > available and available > 0 then
		w = math.max(120, (available - (cols - 1) * gap_x) / cols)
	end
	local h = w * BASE.slots.h / BASE.slots.w
	local grid_w = cols * w + (cols - 1) * gap_x
	local grid_h = rows * h + (rows - 1) * gap_y
	local left = L.safe.left + (L.W - L.safe.left - L.safe.right - grid_w) / 2
	local bottom = BASE.slots.bottom_y + L.safe.bottom
	local max_top = (L.top.name.y or (L.H - L.safe.top - 132)) - 72
	if bottom + grid_h > max_top then
		bottom = max_top - grid_h
	end
	if bottom < L.safe.bottom + 10 then
		bottom = L.safe.bottom + 10
	end

	L.slots.w = w
	L.slots.h = h
	L.slots.gap_x = gap_x
	L.slots.gap_y = gap_y
	L.slots.cols = cols
	L.slots.rows = rows
	L.slots.left = left
	L.slots.bottom = bottom
	L.slots.top = bottom + grid_h
	L.slots.grid_w = grid_w
	L.slots.grid_h = grid_h

	local positions = {}
	for row = 0, rows - 1 do
		local y = bottom + (rows - 1 - row) * (h + gap_y)
		for col = 0, cols - 1 do
			positions[#positions + 1] = {
				x = left + col * (w + gap_x),
				y = y,
			}
		end
	end
	L.slots.positions = positions
	L.slots.label.x = left
	L.slots.label.y = L.slots.top + 36
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
		positions = {},
		cols = BASE.slots.cols,
		rows = BASE.slots.rows,
		w = BASE.slots.w,
		h = BASE.slots.h,
		gap_x = BASE.slots.gap_x,
		gap_y = BASE.slots.gap_y,
		left = 0,
		bottom = BASE.slots.bottom_y,
		top = 0,
		grid_w = 0,
		grid_h = 0,
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
	compute_slot_grid()
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

	L.monster_cards.cx = L.safe.left + 90
	L.monster_cards.y = L.top.name.y - 33 - L.monster_cards.h / 2

	compute_slot_grid()

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
	count = math.max(1, math.min(6, count or 3))
	local w = L.slots.w
	local h = L.slots.h
	local gap_x = L.slots.gap_x
	local gap_y = L.slots.gap_y
	local left = L.slots.left
	local bottom = L.slots.bottom
	local top = bottom + h + gap_y
	local positions = {}

	local function add_row(y, first, last)
		for i = first, last do
			positions[i] = { x = left + (i - first) * (w + gap_x), y = y }
		end
	end

	if count <= L.slots.cols then
		local row_w = count * w + (count - 1) * gap_x
		local x = left + (L.slots.grid_w - row_w) / 2
		for i = 1, count do
			positions[i] = { x = x, y = bottom }
			x = x + w + gap_x
		end
	else
		add_row(bottom, 1, 4)
		positions[5] = { x = left + (L.slots.cols - 1) * (w + gap_x), y = top }
		if count >= 6 then
			positions[6] = { x = left, y = top }
		end
	end

	local label_y = positions[1].y + h + 36
	for _, pos in ipairs(positions) do
		label_y = math.max(label_y, pos.y + h + 36)
	end

	return {
		positions = positions,
		w = w,
		h = h,
		left = left,
		label_y = label_y,
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
