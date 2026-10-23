local L = {}

L.W = 1080
L.H = 1920

L.top = {
	name = { x = 30, y = 1788, w = 540, h = 112 },
	pause = { x = 640, y = 1798, w = 96, h = 96 },
	end_turn = { x = 760, y = 1798, w = 290, h = 96 },
}

L.monster = {
	cx = 500,
	top = L.top.end_turn.y - 10,
	max_w = 900,
	max_h = 900,
}

L.slots = {
	label = { x = 30, y = 1228 },
	positions = {
		{ x = 30, y = 1078 },
		{ x = 560, y = 1078 },
		{ x = 30, y = 938 },
		{ x = 560, y = 938 },
	},
	w = 490,
	h = 120,
}

L.threat = {
	x = 30, y = 688, w = 1020, h = 172,
	current = { x = 46, y = 704, w = 380, h = 140 },
	next = { x = 442, y = 704, w = 592, h = 140 },
}

L.hand = {
	label_y = 592,
	y = 172,
	card_w = 260,
	card_h = 388,
	margin = 40,
}

L.weapon_mark = {
	pad = 12,
	aspect = 260 / 388,
}

L.monster_cards = {
	cx = 130,
	y = 1650,
	h = 210,
	gap = 156,
}

L.footer = {
	deck = { x = 30, y = 30, w = 150, h = 112 },
	health = { x = 410, y = 42, w = 640, h = 82 },
	deck_label_y = 126,
	health_label_y = 138,
}

L.card_text = {
	x = 10,
	y = 74,
	w = 182,
	h = 88,
}

L.modal = {
	reward_cards = {
		{ x = 110, y = 700 },
		{ x = 410, y = 700 },
		{ x = 710, y = 700 },
	},
}

L.card_preview = {
	image = { cx = 540, cy = 1040, w = 540, h = 806 },
	close = { x = 350, y = 400, w = 380, h = 86 },
}

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
		{ x = 30, y = 1218 },
		{ x = 560, y = 1218 },
		{ x = 30, y = 1078 },
		{ x = 560, y = 1078 },
		{ x = 30, y = 938 },
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
	local usable = L.W - L.hand.margin * 2
	local step = 0
	if count > 1 then
		step = (usable - L.hand.card_w) / (count - 1)
	end
	for i = 1, count do
		local x = L.hand.margin + L.hand.card_w / 2 + (i - 1) * step
		local rotation = (i - (count + 1) / 2) * 3
		result[i] = { x = x, y = L.hand.y, rotation = rotation }
	end
	return result
end

return L
