local L = require("scripts.ui.layout")
local P = require("scripts.ui.palette")
local W = require("scripts.ui.widgets")
local cards = require("scripts.data.cards")
local i18n = require("scripts.data.i18n")
local asset_map = require("scripts.data.asset_map")
local game_run = require("scripts.game.run")

local S = {}

local function t(app, key, ...)
	return i18n.text(app.lang, key, ...)
end

local function card_name(id)
	local def = cards[id]
	return def and def.name or tostring(id or "?")
end

local function draw_background(app)
	W.image(app.layer, 540, 960, 1080, 1920, asset_map.board.atlas, asset_map.board.anim, P.white, 1)
	W.box(app.layer, W.rect(0, 0, 1080, 1920), P.alpha(P.bg, 0.58), 2)
end

local function draw_emperor(app, x, y, size)
	local info = asset_map.monsters.EmperorScorpion
	if not info then
		return
	end
	local scale = math.min(size / info.w, size / info.h, 1)
	W.image(app.layer, x, y, info.w * scale, info.h * scale, info.atlas, info.anim, P.alpha(P.white, 0.72), 3)
end

local function button(app, r, label, callback, opts)
	app.buttons[#app.buttons + 1] = W.button(app.layer, r, label, opts and opts.font or "ui_28", callback, opts)
end

function S.menu(app)
	app.buttons = {}
	draw_background(app)
	draw_emperor(app, 770, 1160, 500)

	W.box(app.layer, W.rect(60, 1510, 500, 4), P.gold, 10)
	W.text(app.layer, 60, 1560, t(app, "title"), "ui_64", P.text, 10, 20)
	W.text(app.layer, 64, 1470, t(app, "subtitle"), "ui_18", P.gold_soft, 10, 44)

	local has_save = app.has_save == true
	local y = 920
	if has_save then
		button(app, W.rect(120, y, 840, 104), t(app, "continue_run"), function()
			app:continue_run()
		end, { color = P.teal, border = P.teal_bright, text_color = P.teal_text })
		y = y - 124
	end
	button(app, W.rect(120, y, 840, 104), t(app, "start_run"), function()
		app:new_run()
	end, { color = P.red, border = P.red_bright, text_color = P.text })
	y = y - 124
	button(app, W.rect(120, y, 840, 104), t(app, "help"), function()
		app:show_help(false)
	end, { color = P.panel, border = P.gold_soft, text_color = P.text })
	y = y - 124
	local lang_label = t(app, "language") .. ": " .. (app.lang == "id" and t(app, "lang_id") or t(app, "lang_en"))
	button(app, W.rect(120, y, 840, 104), lang_label, function()
		app:toggle_language()
	end, { color = P.panel, border = P.teal_bright, text_color = P.teal_text })

	W.text(app.layer, 120, 300, t(app, "hint_menu"), "ui_18", P.muted, 10, 56)
	W.text(app.layer, 120, 250, "v1.0  ·  DEFOLD", "ui_14", P.dim, 10, 30)
end

function S.help(app, return_to_pause)
	W.box(app.modal_layer, W.rect(0, 0, 1080, 1920), P.overlay, 1000)
	local panel = W.rect(70, 150, 940, 1600)
	W.panel(app.modal_layer, panel, 1001, { color = P.panel_dark, border = P.gold })
	W.text(app.modal_layer, 120, 1670, t(app, "howto_title"), "ui_48", P.gold, 1003)
	W.text(app.modal_layer, 120, 1030, t(app, "howto"), "ui_22", P.text, 1003, 58)
	app.modal_buttons[#app.modal_buttons + 1] = W.button(app.modal_layer, W.rect(350, 210, 380, 86), t(app, "back"), "ui_28", function()
		app:close_modal()
		if return_to_pause then
			app:show_pause()
		end
	end, { color = P.panel_soft, border = P.gold_soft, text_color = P.text })
end

function S.pause(app)
	W.box(app.modal_layer, W.rect(0, 0, 1080, 1920), P.overlay, 1000)
	W.panel(app.modal_layer, W.rect(180, 500, 720, 920), 1001, { color = P.panel_dark, border = P.gold })
	W.text(app.modal_layer, 225, 1350, t(app, "pause"), "ui_48", P.gold, 1003)
	local total = app.run and (app.run.encounters_total or game_run.ENCOUNTERS) or game_run.ENCOUNTERS
	W.text(app.modal_layer, 225, 1280, t(app, "encounter", app.run and app.run.encounter or 1, total), "ui_18", P.muted, 1003)

	local function mb(y, label, callback, opts)
		app.modal_buttons[#app.modal_buttons + 1] = W.button(app.modal_layer, W.rect(225, y, 630, 82), label, opts and opts.font or "ui_28", callback, opts)
	end

	mb(1160, t(app, "resume"), function()
		app:close_modal()
	end, { color = P.teal, border = P.teal_bright, text_color = P.teal_text })
	mb(1050, t(app, "help"), function()
		app:show_help(true)
	end, { color = P.panel_soft, border = P.gold_soft, text_color = P.text })
	local lang_label = t(app, "language") .. ": " .. (app.lang == "id" and t(app, "lang_id") or t(app, "lang_en"))
	mb(940, lang_label, function()
		app:toggle_language()
	end, { color = P.panel_soft, border = P.teal_bright, text_color = P.teal_text })
	mb(830, t(app, "save_quit"), function()
		app:quit_to_menu()
	end, { color = P.panel_soft, border = P.gold_soft, text_color = P.text })
	mb(720, t(app, "restart_run"), function()
		app:show_restart_confirm()
	end, { color = P.red, border = P.red_bright, text_color = P.text })
	mb(570, t(app, "close"), function()
		app:close_modal()
	end, { color = P.panel, border = P.border, text_color = P.muted })
end

function S.restart_confirm(app)
	W.box(app.modal_layer, W.rect(0, 0, 1080, 1920), P.overlay, 1000)
	W.panel(app.modal_layer, W.rect(140, 690, 800, 540), 1001, { color = P.panel_dark, border = P.red })
	W.text(app.modal_layer, 190, 1130, t(app, "restart_confirm"), "ui_28", P.text, 1003, 40)
	app.modal_buttons[#app.modal_buttons + 1] = W.button(app.modal_layer, W.rect(190, 880, 320, 84), t(app, "restart_run"), "ui_22", function()
		app:restart_run()
	end, { color = P.red, border = P.red_bright, text_color = P.text })
	app.modal_buttons[#app.modal_buttons + 1] = W.button(app.modal_layer, W.rect(570, 880, 320, 84), t(app, "back"), "ui_22", function()
		app:show_pause()
	end, { color = P.panel_soft, border = P.gold_soft, text_color = P.text })
end

function S.alert(app, list)
	W.box(app.modal_layer, W.rect(0, 0, 1080, 1920), P.overlay, 1000)
	W.panel(app.modal_layer, W.rect(110, 430, 860, 1080), 1001, { color = P.panel_dark, border = P.gold })
	W.text(app.modal_layer, 160, 1430, t(app, "alert_title"), "ui_48", P.gold, 1003)
	if #list == 0 then
		W.text(app.modal_layer, 160, 1200, t(app, "alert_empty"), "ui_28", P.muted, 1003)
	else
		for i, inst in ipairs(list) do
			local y = 1320 - (i - 1) * 300
			local r = W.rect(160, y, 760, 260)
			W.panel(app.modal_layer, r, 1002, { color = P.panel_soft, border = P.border })
			local def = cards[inst.id]
			W.text(app.modal_layer, r.x + 24, r.y + r.h - 40, def and def.name or tostring(inst.id), "ui_28", P.text, 1003, 38)
			W.text(app.modal_layer, r.x + 24, r.y + r.h / 2 - 45, i18n.card_text(app.lang, def or {}), "ui_18", P.muted, 1003, 60)
		end
	end
	app.modal_buttons[#app.modal_buttons + 1] = W.button(app.modal_layer, W.rect(350, 490, 380, 86), t(app, "close"), "ui_28", function()
		app:close_modal()
	end, { color = P.panel_soft, border = P.gold_soft, text_color = P.text })
end

function S.card_preview(app, card_id)
	local def = cards[card_id]
	if not def then
		return
	end
	local info = asset_map.cards[card_id]
	local r = L.card_preview

	W.box(app.modal_layer, W.rect(0, 0, 1080, 1920), P.overlay, 1000)
	if info then
		local image = W.image(app.modal_layer, r.image.cx, r.image.cy, r.image.w, r.image.h, info.atlas, info.anim, P.white, 1002)
		local scale = r.image.w / 260
		W.text(image, -112 * scale, -76 * scale, i18n.card_text(app.lang, def), "ui_28", P.text, 1, 21)
	end

	app.modal_buttons[#app.modal_buttons + 1] = {
		rect = W.rect(0, 0, 1080, 1920),
		on_click = function()
			app:close_modal()
		end,
	}
	app.modal_buttons[#app.modal_buttons + 1] = W.button(app.modal_layer, r.close, t(app, "close"), "ui_28", function()
		app:close_modal()
	end, { color = P.panel_soft, border = P.gold_soft, text_color = P.text })
end

function S.reward(app)
	app.buttons = {}
	local pending = app.run and app.run.pending_reward
	draw_background(app)
	W.text(app.layer, 60, 1710, t(app, "reward_title"), "ui_64", P.gold, 10, 20)
	W.text(app.layer, 64, 1640, t(app, "reward_desc"), "ui_22", P.text, 10)
	W.text(app.layer, 64, 1590, t(app, "encounter", app.run.encounter, app.run.encounters_total or game_run.ENCOUNTERS), "ui_18", P.muted, 10)

	if not pending then
		W.text(app.layer, 120, 900, "No reward pending.", "ui_28", P.muted, 10)
		return
	end

	for i, choice in ipairs(pending.choices) do
		local base = L.modal.reward_cards[i]
		local panel_r = W.rect(base.x - 18, base.y - 128, 276, 560)
		W.panel(app.layer, panel_r, 20, { color = P.panel, border = P.gold_soft })
		local info = asset_map.cards[choice.card]
		if info then
			W.image(app.layer, base.x + 120, base.y + 190, 240, 358, info.atlas, info.anim, P.white, 21)
		end

		local title = t(app, "reward_meat")
		local desc = card_name(choice.card)
		if choice.kind == "weapon" then
			title = t(app, "reward_weapon")
			desc = card_name(choice.card)
		elseif choice.kind == "cleanse" then
			title = choice.has_junk and t(app, "reward_cleanse") or t(app, "reward_cleanse_none")
			desc = choice.has_junk and card_name(choice.card) or t(app, "reward_cleanse_desc")
		end
		W.text(app.layer, panel_r.x + 20, panel_r.y + 100, title, "ui_28", P.gold, 22, 17)
		W.text(app.layer, panel_r.x + 20, panel_r.y + 58, desc, "ui_18", P.text, 22, 22)
		app.buttons[#app.buttons + 1] = {
			rect = panel_r,
			on_click = function()
				app:choose_reward(i)
			end,
		}
	end

	button(app, W.rect(350, 200, 380, 86), t(app, "save_quit"), function()
		app:quit_to_menu()
	end, { color = P.panel_soft, border = P.gold_soft, text_color = P.text, font = "ui_22" })
end

function S.result(app, victory)
	app.buttons = {}
	draw_background(app)
	if app.run and app.run.monster_id then
		local info = asset_map.monsters[app.run.monster_id]
		if info then
			local scale = math.min(620 / info.w, 620 / info.h, 1)
			W.image(app.layer, 540, 1190, info.w * scale, info.h * scale, info.atlas, info.anim, P.alpha(P.white, 0.55), 3)
		end
	end
	local title = victory and t(app, "victory_title") or t(app, "defeat_title")
	local desc = victory and t(app, "victory_desc") or t(app, "defeat_desc")
	local color = victory and P.gold or P.red_text
	W.text(app.layer, 60, 1580, title, "ui_64", color, 10, 20)
	W.text(app.layer, 64, 1510, desc, "ui_22", P.text, 10, 48)
	if app.run then
		local stats = t(app, "stats", app.run.encounter, app.run.encounters_total or game_run.ENCOUNTERS,
			app.run.stats.kills or 0, app.run.stats.turns or 0)
		W.text(app.layer, 64, 1340, stats, "ui_22", P.muted, 10, 40)
	end
	button(app, W.rect(120, 800, 840, 100), t(app, "new_run"), function()
		app:new_run()
	end, { color = P.red, border = P.red_bright, text_color = P.text })
	button(app, W.rect(120, 680, 840, 100), t(app, "main_menu"), function()
		app:go_menu()
	end, { color = P.panel, border = P.gold_soft, text_color = P.text })
end

return S
