local i18n = {
	id = {
		title = "MONSTER BUG",
		subtitle = "BONGKAR ANATOMI. JAGA DECK.",
		start_run = "MULAI RUN",
		continue_run = "LANJUTKAN",
		help = "CARA MAIN",
		language = "BAHASA",
		back = "KEMBALI",
		resume = "LANJUT",
		main_menu = "MENU UTAMA",
		restart_run = "ULANG RUN",
		restart_confirm = "Yakin ingin memulai run baru?",
		save_quit = "SIMPAN & KELUAR",
		pause = "JEDA",
		close = "TUTUP",
		end_turn = "END TURN",
		encounter = "PERTARUNGAN %d/%d",
		insect = "SERANGGA · TIER %d",
		boss = "BOSS · TIER %d",
		target_slots = "TARGET SLOT",
		threat_current = "ANCAMAN SAAT INI",
		threat_next = "JADWAL BERIKUTNYA",
		threat_turn = "T%d: %s",
		threat_turn_plus = "T%d+: %s",
		open = "TERBUKA",
		closed = "TERTUTUP",
		need = "Butuh: %s",
		hand = "TANGAN · %d AKSI",
		deck_health = "DECK (NYAWA)",
		health_total = "NYAWA TOTAL",
		deck_hint = "Kartu terpakai -> discard",
		deck_hint2 = "Kartu terbakar -> keluar permanen",
		game_over_deck = "Deck habis = GAME OVER",
		deck_empty = "Tumpukan habis!",
		prevent_play = "Monster mencegah 1 main.",
		hint_battle = "Seret ke slot. Ketuk 2x: detail.",
		hint_play = "Seret kartu ini untuk main. Ketuk 2x: detail.",
		hint_menu = "Tap untuk memilih. Kamu bisa keluar kapan saja.",
		lang_id = "INDONESIA",
		lang_en = "ENGLISH",
		shield_status = "Perisai: %d",
		skip_status = "Serangan dicegah: %d",
		prevent_status = "Main dicegah: %d",
		regen_status = "Anti-regen",
		reward_title = "MONSTER TUMBANG",
		reward_desc = "Pilih 1 hadiah.",
		reward_meat = "Tambah Nyawa",
		reward_weapon = "Senjata Baru",
		reward_cleanse = "Buang Sampah",
		reward_cleanse_none = "Tidak ada sampah",
		reward_cleanse_desc = "Buang 1 kartu sampah.",
		reward_added = "%s ditambahkan.",
		reward_removed = "%s dibuang.",
		reward_none = "Tidak ada sampah. Dapat Meat.",
		victory_title = "BOSS TUMBANG",
		defeat_title = "DECK HABIS",
		victory_desc = "Kamu menyelesaikan run ini.",
		defeat_desc = "Nyawa habis. Coba lagi.",
		stats = "Encounter: %d/%d\nMonster dikalahkan: %d\nTurn dimainkan: %d",
		new_run = "RUN BARU",
		alert_title = "3 KARTU TERATAS",
		alert_empty = "Tumpukan kosong.",
		not_enough_actions = "Aksi tidak cukup.",
		invalid_target = "Target tidak cocok.",
		no_target = "Tidak ada slot yang cocok.",
		unplayable = "Kartu ini tidak bisa dimainkan.",
		prevented = "Gerakanmu dicegah!",
		choose_slot = "Pilih slot target.",
		slot_closed = "Slot %s tertutup!",
		slot_bonus = "Bonus target! Slot tambahan tertutup.",
		burned = "%s terbakar!",
		shield_absorb = "Perisai menahan %d bakaran.",
		larva_inserted = "Larva disisipkan (%d).",
		larva_hatch = "Larva menetas! 2 kartu terbakar.",
		larva_draw = "Larva menetas dalam %d turn.",
		poison_draw = "Racun! 1 kartu terbakar.",
		destroy_weapon = "Senjata dihancurkan: %s",
		destroy_weapon_none = "Tidak ada senjata. 1 kartu terbakar.",
		destroy_weapon_absorbed = "Tidak ada senjata. Shield menyerap serangan.",
		heal_revived = "Nyawa pulih: %s",
		heal_meat = "Meat ditambahkan.",
		junk_removed = "Sampah dibuang: %s",
		no_junk = "Tidak ada sampah.",
		attack = "Monster menyerang: %s",
		attack_skipped = "Serangan monster dicegah.",
		monster_dead = "Semua slot tertutup!",
		card_played = "%s dimainkan.",
		draw_poison = "Poison! Nyawa -1.",
		shield_gain = "Perisai +%d.",
		action_gain = "+%d aksi.",
		skip_gain = "Serangan dicegah %d turn.",
		status = "STATUS",
		none = "-",
		ok = "OK",
		howto_title = "CARA MAIN",
		howto = [[TUJUAN
Tutup semua slot tubuh monster sebelum deck habis.

DECK = NYAWA
Jumlah kartu di tumpukan, tangan, dan discard adalah Nyawa. Kartu yang terbakar hilang permanen.

AKSI
Kamu punya 3 aksi per turn. Biaya aksi ada di kartu. Sisa aksi tidak terbawa.

CARA MAIN
Seret kartu ke slot yang cocok, atau tap kartu lalu tap slot. Kartu Support dimainkan dengan menyeretnya. Ketuk dua kali kartu untuk memperbesar dan membaca detail.

ANCAMAN
Monster menyerang di akhir turn. Lihat panel ancaman untuk jadwal berikutnya.

SAMPAH
Larva, Twig, Dry Leaf, dan Poison mengotori deck. Buang dengan reward atau kartu pembersih.]],
		threats = {
			burn = "Bakar %d",
			slash = "Potong %d",
			pierce = "Tusuk %d",
			sting = "Sengat (Tusuk %d)",
			poison = "Racun (Bakar %d/turn)",
			insert_larva = "Sisip %d Larva",
			destroy_weapon = "Hancurkan Senjata",
			skip = "Lewati Giliran",
			sleep = "Tidur (Lewati)",
			dance = "Menari (Lewati)",
			prevent_play = "Bau (Cegah 1 main)",
			sound = "Suara (Bakar %d)",
		},
		types = {
			Blunt = "Pukul",
			Slash = "Potong",
			Pierce = "Tusuk",
			Web = "Jaring",
			Fire = "Api",
			Support = "Support",
			Passive = "Pasif",
			Junk = "Sampah",
			Curse = "Kutukan",
		},
		parts = {
			Mandibles = "Rahang",
			Shell = "Cangkang",
			Legs = "Kaki",
			Wings = "Sayap",
			Abdomen = "Perut",
			["Head/Horn"] = "Kepala/Tanduk",
			Head = "Kepala",
			Horn = "Tanduk",
			Body = "Tubuh",
			Antennae = "Antena",
			Tail = "Ekor",
			["Scythe Arms"] = "Lengan Sabit",
			Neck = "Leher",
			["Hind Legs"] = "Kaki Belakang",
			["Front Legs"] = "Kaki Depan",
			Eyes = "Mata",
			Segments = "Ruas",
			Pincers = "Capit",
			Proboscis = "Probosis",
			["Abdomen/Stinger"] = "Perut/Sengat",
		},
	},
	en = {
		title = "MONSTER BUG",
		subtitle = "DISMANTLE THE ANATOMY. GUARD THE DECK.",
		start_run = "START RUN",
		continue_run = "CONTINUE",
		help = "HOW TO PLAY",
		language = "LANGUAGE",
		back = "BACK",
		resume = "RESUME",
		main_menu = "MAIN MENU",
		restart_run = "RESTART RUN",
		restart_confirm = "Start a new run? Current progress will be lost.",
		save_quit = "SAVE & QUIT",
		pause = "PAUSE",
		close = "CLOSE",
		end_turn = "END TURN",
		encounter = "ENCOUNTER %d/%d",
		insect = "INSECT · TIER %d",
		boss = "BOSS · TIER %d",
		target_slots = "TARGET SLOTS",
		threat_current = "CURRENT THREAT",
		threat_next = "NEXT THREATS",
		threat_turn = "T%d: %s",
		threat_turn_plus = "T%d+: %s",
		open = "OPEN",
		closed = "CLOSED",
		need = "Need: %s",
		hand = "HAND · %d ACTIONS",
		deck_health = "DECK (HEALTH)",
		health_total = "TOTAL HEALTH",
		deck_hint = "Played cards -> discard",
		deck_hint2 = "Burned cards -> gone forever",
		game_over_deck = "Deck empty = GAME OVER",
		deck_empty = "The deck is empty!",
		prevent_play = "The monster prevented 1 play.",
		hint_battle = "Drag to a slot. Double-tap: details.",
		hint_play = "Drag this card to play. Double-tap: details.",
		hint_menu = "Tap to choose. You can leave at any time.",
		lang_id = "INDONESIA",
		lang_en = "ENGLISH",
		shield_status = "Shield: %d",
		skip_status = "Attacks prevented: %d",
		prevent_status = "Plays prevented: %d",
		regen_status = "Anti-regen",
		reward_title = "MONSTER DOWN",
		reward_desc = "Choose 1 reward.",
		reward_meat = "Gain Health",
		reward_weapon = "New Weapon",
		reward_cleanse = "Remove Junk",
		reward_cleanse_none = "No junk",
		reward_cleanse_desc = "Remove 1 junk card.",
		reward_added = "%s added.",
		reward_removed = "%s removed.",
		reward_none = "No junk. Meat gained.",
		victory_title = "BOSS DOWN",
		defeat_title = "DECK EMPTY",
		victory_desc = "You completed the run.",
		defeat_desc = "Your health ran out. Try again.",
		stats = "Encounter: %d/%d\nMonsters killed: %d\nTurns played: %d",
		new_run = "NEW RUN",
		alert_title = "TOP 3 CARDS",
		alert_empty = "The deck is empty.",
		not_enough_actions = "Not enough actions.",
		invalid_target = "Wrong target.",
		no_target = "No matching slot.",
		unplayable = "This card cannot be played.",
		prevented = "Your play was prevented!",
		choose_slot = "Choose a target slot.",
		slot_closed = "%s closed!",
		slot_bonus = "Target bonus! Extra slot closed.",
		burned = "%s burned!",
		shield_absorb = "Shield absorbed %d burn(s).",
		larva_inserted = "Larva inserted (%d).",
		larva_hatch = "Larva hatched! 2 cards burned.",
		larva_draw = "Larva hatches in %d turns.",
		poison_draw = "Poison! 1 card burned.",
		destroy_weapon = "Weapon destroyed: %s",
		destroy_weapon_none = "No weapon. 1 card burned.",
		destroy_weapon_absorbed = "No weapon. Shield absorbed the attack.",
		heal_revived = "Health restored: %s",
		heal_meat = "Meat added.",
		junk_removed = "Junk removed: %s",
		no_junk = "No junk.",
		attack = "Monster attacks: %s",
		attack_skipped = "Monster attack prevented.",
		monster_dead = "All slots closed!",
		card_played = "%s played.",
		draw_poison = "Poison! Health -1.",
		shield_gain = "Shield +%d.",
		action_gain = "+%d actions.",
		skip_gain = "Attacks prevented for %d turn(s).",
		status = "STATUS",
		none = "-",
		ok = "OK",
		howto_title = "HOW TO PLAY",
		howto = [[GOAL
Close every body slot before the deck runs out.

DECK = HEALTH
Cards in draw pile, hand and discard are your health. Burned cards are gone forever.

ACTIONS
You get 3 actions per turn. The action cost is printed on each card. Leftover actions do not carry over.

HOW TO PLAY
Drag a card onto a matching slot, or tap a card then tap a slot. Support cards are played by dragging them. Double-tap a card to enlarge it and read the details.

THREATS
The monster attacks at the end of the turn. Read the threat panel for the upcoming schedule.

JUNK
Larva, Twig, Dry Leaf and Poison clog your deck. Remove them through rewards or cleansing cards.]],
		threats = {
			burn = "Burn %d",
			slash = "Slash %d",
			pierce = "Pierce %d",
			sting = "Sting (Pierce %d)",
			poison = "Poison (Burn %d/turn)",
			insert_larva = "Insert %d Larva",
			destroy_weapon = "Destroy Weapon",
			skip = "Skip Turn",
			sleep = "Sleep (Skip)",
			dance = "Dance (Skip)",
			prevent_play = "Stink (Prevent 1 play)",
			sound = "Sound (Burn %d)",
		},
		types = {
			Blunt = "Blunt",
			Slash = "Slash",
			Pierce = "Pierce",
			Web = "Web",
			Fire = "Fire",
			Support = "Support",
			Passive = "Passive",
			Junk = "Junk",
			Curse = "Curse",
		},
		parts = {
			Mandibles = "Mandibles",
			Shell = "Shell",
			Legs = "Legs",
			Wings = "Wings",
			Abdomen = "Abdomen",
			["Head/Horn"] = "Head/Horn",
			Head = "Head",
			Horn = "Horn",
			Body = "Body",
			Antennae = "Antennae",
			Tail = "Tail",
			["Scythe Arms"] = "Scythe Arms",
			Neck = "Neck",
			["Hind Legs"] = "Hind Legs",
			["Front Legs"] = "Front Legs",
			Eyes = "Eyes",
			Segments = "Segments",
			Pincers = "Pincers",
			Proboscis = "Proboscis",
			["Abdomen/Stinger"] = "Abdomen/Stinger",
		},
	},
}

function i18n.text(lang, key, ...)
	local table_for_lang = i18n[lang] or i18n.id
	local value = table_for_lang[key]
	if value == nil then
		value = i18n.id[key]
	end
	if type(value) == "string" and select("#", ...) > 0 then
		local ok, formatted = pcall(string.format, value, ...)
		if ok then
			return formatted
		end
	end
	return value or key
end

function i18n.part(lang, part)
	local table_for_lang = i18n[lang] or i18n.id
	return (table_for_lang.parts and table_for_lang.parts[part]) or part
end

function i18n.need(lang, need)
	local table_for_lang = i18n[lang] or i18n.id
	return (table_for_lang.types and table_for_lang.types[need]) or need
end

function i18n.threat(lang, threat)
	local table_for_lang = i18n[lang] or i18n.id
	local labels = table_for_lang.threats
	local kind = threat.kind
	if kind == "skip" and threat.label and labels[threat.label] then
		return labels[threat.label]
	end
	local template = labels[kind] or kind
	if threat.value then
		return string.format(template, threat.value)
	end
	return template
end

function i18n.card_text(lang, card)
	if lang == "en" then
		return card.en_text or card.id_text or ""
	end
	return card.id_text or card.en_text or ""
end

return i18n
