local P = {}

P.bg = vmath.vector4(0.025, 0.018, 0.012, 1)
P.overlay = vmath.vector4(0, 0, 0, 0.82)
P.panel = vmath.vector4(0.055, 0.038, 0.026, 0.96)
P.panel_dark = vmath.vector4(0.028, 0.019, 0.013, 0.97)
P.panel_soft = vmath.vector4(0.105, 0.073, 0.048, 0.94)
P.border = vmath.vector4(0.36, 0.24, 0.14, 1)
P.gold = vmath.vector4(0.88, 0.70, 0.39, 1)
P.gold_soft = vmath.vector4(0.62, 0.46, 0.25, 1)
P.muted = vmath.vector4(0.55, 0.44, 0.33, 1)
P.dim = vmath.vector4(0.28, 0.22, 0.17, 1)
P.text = vmath.vector4(0.92, 0.83, 0.67, 1)

P.red = vmath.vector4(0.48, 0.12, 0.08, 1)
P.red_bright = vmath.vector4(0.87, 0.24, 0.17, 1)
P.red_text = vmath.vector4(1.0, 0.62, 0.53, 1)
P.green = vmath.vector4(0.10, 0.25, 0.11, 1)
P.green_bright = vmath.vector4(0.39, 0.76, 0.40, 1)
P.green_text = vmath.vector4(0.73, 1.0, 0.72, 1)
P.blue = vmath.vector4(0.09, 0.15, 0.27, 1)
P.blue_bright = vmath.vector4(0.42, 0.62, 0.91, 1)
P.blue_text = vmath.vector4(0.72, 0.84, 1.0, 1)
P.orange = vmath.vector4(0.40, 0.22, 0.05, 1)
P.orange_bright = vmath.vector4(0.96, 0.60, 0.16, 1)
P.orange_text = vmath.vector4(1.0, 0.82, 0.52, 1)
P.teal = vmath.vector4(0.07, 0.24, 0.22, 1)
P.teal_bright = vmath.vector4(0.32, 0.75, 0.69, 1)
P.teal_text = vmath.vector4(0.70, 1.0, 0.94, 1)

P.type = {
	Blunt = { bg = P.orange, border = P.orange_bright, text = P.orange_text },
	Slash = { bg = P.blue, border = P.blue_bright, text = P.blue_text },
	Pierce = { bg = P.green, border = P.green_bright, text = P.green_text },
	Web = { bg = P.teal, border = P.teal_bright, text = P.teal_text },
	Fire = { bg = vmath.vector4(0.33, 0.10, 0.04, 1), border = P.red_bright, text = P.red_text },
}

P.white = vmath.vector4(1, 1, 1, 1)
P.black = vmath.vector4(0, 0, 0, 1)

function P.alpha(color, a)
	return vmath.vector4(color.x, color.y, color.z, a)
end

return P
