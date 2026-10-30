local W = {}

local v3 = vmath.vector3

W.fonts = {
	"ui_14", "ui_18", "ui_22", "ui_28", "ui_36", "ui_48", "ui_64",
}

function W.rect(x, y, w, h)
	return { x = x, y = y, w = w, h = h }
end

function W.contains(r, x, y)
	return r and x >= r.x and x <= r.x + r.w and y >= r.y and y <= r.y + r.h
end

function W.alpha(color, a)
	return vmath.vector4(color.x, color.y, color.z, a)
end

function W.layer(parent, z)
	local node = gui.new_box_node(v3(0, 0, 0), v3(0, 0, 0))
	gui.set_parent(node, parent)
	gui.set_color(node, vmath.vector4(0, 0, 0, 0))
	return node
end

function W.clear(node)
	if node then
		gui.delete_node(node)
	end
end

function W.box(parent, r, color, z)
	local node = gui.new_box_node(v3(r.x, r.y, 0), v3(r.w, r.h, 0))
	gui.set_parent(node, parent)
	gui.set_pivot(node, gui.PIVOT_SW)
	gui.set_color(node, color)
	return node
end

function W.image(parent, cx, cy, w, h, atlas, anim, color, z)
	local node = gui.new_box_node(v3(cx, cy, 0), v3(w, h, 0))
	gui.set_parent(node, parent)
	gui.set_size_mode(node, gui.SIZE_MODE_MANUAL)
	gui.set_texture(node, atlas)
	if anim then
		gui.play_flipbook(node, anim)
	end
	if color then
		gui.set_color(node, color)
	end
	return node
end

local function wrap_line(line, max_chars)
	if max_chars <= 0 or #line <= max_chars then
		return { line }
	end
	local out = {}
	local current = ""
	for word in string.gmatch(line, "%S+") do
		while #word > max_chars do
			if #current > 0 then
				out[#out + 1] = current
				current = ""
			end
			out[#out + 1] = string.sub(word, 1, max_chars)
			word = string.sub(word, max_chars + 1)
		end
		if #current == 0 then
			current = word
		elseif #current + 1 + #word <= max_chars then
			current = current .. " " .. word
		else
			out[#out + 1] = current
			current = word
		end
	end
	if #current > 0 then
		out[#out + 1] = current
	end
	return out
end

function W.wrap(text, max_chars)
	local out = {}
	for line in string.gmatch(tostring(text or "") .. "\n", "([^\n]*)\n") do
		local wrapped = wrap_line(line, max_chars)
		for _, part in ipairs(wrapped) do
			out[#out + 1] = part
		end
	end
	return table.concat(out, "\n")
end

function W.text(parent, x, y, value, font, color, z, max_chars)
	local text = value
	if max_chars and max_chars > 0 then
		text = W.wrap(text, max_chars)
	end
	local node = gui.new_text_node(v3(x, y, 0), text)
	gui.set_parent(node, parent)
	gui.set_font(node, font or "ui_22")
	gui.set_pivot(node, gui.PIVOT_W)
	gui.set_color(node, color or vmath.vector4(1, 1, 1, 1))
	return node
end

function W.text_center(parent, cx, cy, value, font, color, max_chars)
	local text = value
	if max_chars and max_chars > 0 then
		text = W.wrap(text, max_chars)
	end
	local node = gui.new_text_node(v3(cx, cy, 0), text)
	gui.set_parent(node, parent)
	gui.set_font(node, font or "ui_22")
	gui.set_pivot(node, gui.PIVOT_CENTER)
	gui.set_color(node, color or vmath.vector4(1, 1, 1, 1))
	return node
end

function W.dashed_rect(parent, r, color, opts)
	opts = opts or {}
	local dash = opts.dash or 14
	local gap = opts.gap or 10
	local thickness = opts.thickness or 3
	local step = dash + gap
	local x, y, w, h = r.x, r.y, r.w, r.h
	local nodes = {}

	local function add(dx, dy, dw, dh)
		nodes[#nodes + 1] = W.box(parent, W.rect(dx, dy, dw, dh), color, opts.z)
	end

	local i = 0
	while i < w do
		local len = math.min(dash, w - i)
		add(x + i, y, len, thickness)
		add(x + i, y + h - thickness, len, thickness)
		i = i + step
	end

	i = thickness
	local bottom = h - thickness
	while i < bottom do
		local len = math.min(dash, bottom - i)
		add(x, y + i, thickness, len)
		add(x + w - thickness, y + i, thickness, len)
		i = i + step
	end
	return nodes
end

function W.label(parent, r, value, font, color, z, pad)
	local p = pad or 16
	return W.text(parent, r.x + p, r.y + r.h / 2, value, font, color, z, nil)
end

function W.button(parent, r, label, font, callback, opts)
	opts = opts or {}
	local z = opts.z or 200
	local bg_color = opts.color or vmath.vector4(0.105, 0.073, 0.048, 0.94)
	local border_color = opts.border or vmath.vector4(0.36, 0.24, 0.14, 1)
	local text_color = opts.text_color or vmath.vector4(0.92, 0.83, 0.67, 1)
	local bg = W.box(parent, r, bg_color, z)
	local top = W.box(parent, W.rect(r.x, r.y + r.h - 3, r.w, 3), border_color, z + 1)
	local bottom = W.box(parent, W.rect(r.x, r.y, r.w, 2), W.alpha(border_color, 0.45), z + 1)
	local tx = W.text(parent, r.x + 18, r.y + r.h / 2, label, font, text_color, z + 2, opts.max_chars)
	local sub = nil
	if opts.sub then
		sub = W.text(parent, r.x + 18, r.y + r.h / 2 - 24, opts.sub, "ui_14", W.alpha(text_color, 0.72), z + 2)
	end
	return {
		rect = r,
		on_click = callback,
		nodes = { bg, top, bottom, tx, sub },
	}
end

function W.panel(parent, r, z, opts)
	opts = opts or {}
	local bg = W.box(parent, r, opts.color or vmath.vector4(0.055, 0.038, 0.026, 0.96), z or 10)
	local border = W.box(parent, W.rect(r.x, r.y + r.h - 2, r.w, 2), opts.border or vmath.vector4(0.36, 0.24, 0.14, 1), (z or 10) + 1)
	return bg, border
end

function W.button_hit(buttons, x, y)
	for i = #buttons, 1, -1 do
		local b = buttons[i]
		if W.contains(b.rect, x, y) then
			return b
		end
	end
	return nil
end

return W
