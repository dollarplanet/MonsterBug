-- Card definitions. Names and categories are baked into the card images.
-- Descriptions are dynamic and rendered at runtime in the selected language.

local cards = {
	StoneHammer = {
		name = "Stone Hammer", cat = "Blunt", cost = 1,
		effect = { close = { match = "type", type = "Blunt", count = 1, bonus_part = "Shield", bonus_extra = 1 } },
		id_text = "Tutup 1 slot Pukul.\n+1 bila target Perisai.",
		en_text = "Close 1 Blunt slot.\n+1 if target is Shield.",
	},
	WoodenMallet = {
		name = "Wooden Mallet", cat = "Blunt", cost = 1,
		effect = { close = { match = "type", type = "Blunt", count = 1 } },
		id_text = "Tutup 1 slot Pukul.",
		en_text = "Close 1 Blunt slot.",
	},
	WarHammer = {
		name = "War Hammer", cat = "Blunt", cost = 2,
		effect = { close = { match = "type", type = "Blunt", count = 2 } },
		id_text = "Tutup 2 slot Pukul.",
		en_text = "Close 2 Blunt slots.",
	},
	SpikedClub = {
		name = "Spiked Club", cat = "Blunt", cost = 1,
		effect = { close = { match = "type", type = "Blunt", count = 1, bonus_part = "Leg", bonus_extra = 1 } },
		id_text = "Tutup 1 slot Pukul.\n+1 bila target Kaki.",
		en_text = "Close 1 Blunt slot.\n+1 if target is Leg.",
	},
	GiantSledge = {
		name = "Giant Sledge", cat = "Blunt", cost = 3,
		effect = { close = { match = "all_shields", count = 1, fallback_any = true } },
		id_text = "Hancurkan semua Shield.",
		en_text = "Break all Shields.",
	},
	Gauntlet = {
		name = "Gauntlet", cat = "Blunt", cost = 0,
		effect = { close = { match = "any", count = 1 } },
		id_text = "Tutup 1 slot apa pun.",
		en_text = "Close any 1 slot.",
	},

	Machete = {
		name = "Machete", cat = "Slash", cost = 1,
		effect = { close = { match = "type", type = "Slash", count = 1, bonus_part = "Leg", bonus_extra = 1 } },
		id_text = "Tutup 1 slot Potong.\n+1 bila target Kaki.",
		en_text = "Close 1 Slash slot.\n+1 if target is Leg.",
	},
	HeavyAxe = {
		name = "Heavy Axe", cat = "Slash", cost = 2,
		effect = { close = { match = "type", type = "Slash", count = 1 } },
		id_text = "Tutup 1 slot Potong.",
		en_text = "Close 1 Slash slot.",
	},
	BoneSickle = {
		name = "Bone Sickle", cat = "Slash", cost = 1,
		effect = { close = { match = "type", type = "Slash", count = 1, bonus_part = "Wing", bonus_extra = 1 } },
		id_text = "Tutup 1 slot Potong.\n+1 bila target Sayap.",
		en_text = "Close 1 Slash slot.\n+1 if target is Wing.",
	},
	SerratedSword = {
		name = "Serrated Sword", cat = "Slash", cost = 2,
		effect = { close = { match = "type", type = "Slash", count = 2 } },
		id_text = "Tutup 2 slot Potong.",
		en_text = "Close 2 Slash slots.",
	},
	Chainsaw = {
		name = "Chainsaw", cat = "Slash", cost = 3,
		effect = { close = { match = "part", part = "Leg", count = 2 } },
		id_text = "Tutup 2 slot Kaki.",
		en_text = "Close 2 Leg slots.",
	},
	FoldingKnife = {
		name = "Folding Knife", cat = "Slash", cost = 0,
		effect = { close = { match = "any", count = 1 } },
		id_text = "Tutup 1 slot apa pun.",
		en_text = "Close any 1 slot.",
	},

	BoneDagger = {
		name = "Bone Dagger", cat = "Pierce", cost = 1,
		effect = { close = { match = "type", type = "Pierce", count = 1, bonus_part = "Abdomen", bonus_extra = 1 } },
		id_text = "Tutup 1 slot Tusuk.\n+1 bila target Perut.",
		en_text = "Close 1 Pierce slot.\n+1 if target is Abdomen.",
	},
	SharpSpear = {
		name = "Sharp Spear", cat = "Pierce", cost = 1,
		effect = { close = { match = "type", type = "Pierce", count = 1 } },
		id_text = "Tutup 1 slot Tusuk.",
		en_text = "Close 1 Pierce slot.",
	},
	PoisonDagger = {
		name = "Poison Dagger", cat = "Pierce", cost = 1,
		effect = { close = { match = "type", type = "Pierce", count = 1 }, prevent_regen = true },
		id_text = "Tutup 1 slot Tusuk.\nCegah regen.",
		en_text = "Close 1 Pierce slot.\nPrevent regen.",
	},
	DemonTrident = {
		name = "Demon Trident", cat = "Pierce", cost = 2,
		effect = { close = { match = "type", type = "Pierce", count = 2 } },
		id_text = "Tutup 2 slot Tusuk.",
		en_text = "Close 2 Pierce slots.",
	},
	PiercingArrow = {
		name = "Piercing Arrow", cat = "Pierce", cost = 2,
		effect = { close = { match = "type", type = "Pierce", count = 1, ignore_shield = true } },
		id_text = "Tutup 1 slot Tusuk.\nAbaikan Shield.",
		en_text = "Close 1 Pierce slot.\nIgnore Shield.",
	},
	StingerNeedle = {
		name = "Stinger Needle", cat = "Pierce", cost = 0,
		effect = { close = { match = "any", count = 1 } },
		id_text = "Tutup 1 slot apa pun.",
		en_text = "Close any 1 slot.",
	},

	FiberWeb = {
		name = "Fiber Web", cat = "Web", cost = 1,
		effect = { close = { match = "part", part = "Wing", count = 1 }, prevent_attack = 1 },
		id_text = "Tutup 1 Sayap.\nCegah 1 serangan.",
		en_text = "Close 1 Wing slot.\nPrevent 1 attack.",
	},
	SteelWeb = {
		name = "Steel Web", cat = "Web", cost = 2,
		effect = { close = { match = "part", part = "Wing", count = 1 }, prevent_attack = 2 },
		id_text = "Tutup 1 Sayap.\nCegah 2 serangan.",
		en_text = "Close 1 Wing slot.\nPrevent 2 attacks.",
	},
	GlueTrap = {
		name = "Glue Trap", cat = "Web", cost = 1,
		effect = { close = { match = "part", part = "Leg", count = 1 }, prevent_attack = 1 },
		id_text = "Tutup 1 Kaki.\nCegah 1 serangan.",
		en_text = "Close 1 Leg slot.\nPrevent 1 attack.",
	},
	SpiderWeb = {
		name = "Spider Web", cat = "Web", cost = 1,
		effect = { close = { match = "any", count = 1 }, insert_larva = 1 },
		id_text = "Tutup 1 slot.\nSisip Larva.",
		en_text = "Close any 1 slot.\nInsert Larva.",
	},
	Torch = {
		name = "Torch", cat = "Fire", cost = 2,
		effect = { close = { match = "part", part = "Wing", count = 1, optional = true }, burn_larva = 1 },
		id_text = "Bakar 1 Larva.\nTutup 1 Sayap.",
		en_text = "Burn 1 Larva.\nClose 1 Wing slot.",
	},
	FireArrow = {
		name = "Fire Arrow", cat = "Fire", cost = 1,
		effect = { close = { match = "part", part = "Wing", count = 1 } },
		id_text = "Bakar 1 slot Sayap.",
		en_text = "Burn 1 Wing slot.",
	},
	MolotovCocktail = {
		name = "Molotov Cocktail", cat = "Fire", cost = 2,
		effect = { burn_junk = 2 },
		id_text = "Buang 2 kartu sampah.",
		en_text = "Remove 2 junk cards.",
	},

	WoodenShield = {
		name = "Wooden Shield", cat = "Support", cost = 1,
		effect = { shield = 2 },
		id_text = "Tahan 2 kehilangan kartu.",
		en_text = "Prevent 2 burns.",
	},
	Focus = {
		name = "Focus", cat = "Support", cost = 0,
		effect = { actions = 1 },
		id_text = "+1 Aksi turn ini.",
		en_text = "+1 Action this turn.",
	},
	Alert = {
		name = "Alert", cat = "Support", cost = 1,
		effect = { alert = true },
		id_text = "Lihat 3 kartu teratas.",
		en_text = "Look at top 3 cards.",
	},
	RedPotion = {
		name = "Red Potion", cat = "Support", cost = 0,
		effect = { heal = 1 },
		id_text = "+1 Nyawa.",
		en_text = "+1 Health.",
	},
	GreenPotion = {
		name = "Green Potion", cat = "Support", cost = 0,
		effect = { actions = 2 },
		id_text = "+2 Aksi turn ini.",
		en_text = "+2 Actions this turn.",
	},
	SmokeBomb = {
		name = "Smoke Bomb", cat = "Support", cost = 1,
		effect = { prevent_attack = 1 },
		id_text = "Cegah serangan 1 turn.",
		en_text = "Prevent 1 turn attack.",
	},

	Meat = {
		name = "Meat", cat = "Passive", cost = nil, playable = false,
		effect = {},
		id_text = "Tidak bisa dimainkan.\n+1 Nyawa.",
		en_text = "Cannot be played.\n+1 Health.",
	},
	Larva = {
		name = "Larva", cat = "Junk", cost = nil, playable = true, special = "larva",
		effect = { exile_larva = true },
		id_text = "Aksi: Exile (Nyawa -1).\nMenetas 2 turn.",
		en_text = "Action: Exile (Health -1).\nHatches in 2 turns.",
	},
	Twig = {
		name = "Twig", cat = "Junk", cost = nil, playable = false,
		effect = {},
		id_text = "Tidak bisa dimainkan.",
		en_text = "Cannot be played.",
	},
	DryLeaf = {
		name = "Dry Leaf", cat = "Junk", cost = nil, playable = false,
		effect = {},
		id_text = "Tidak bisa dimainkan.",
		en_text = "Cannot be played.",
	},
	Poison = {
		name = "Poison", cat = "Curse", cost = nil, playable = false, curse = true,
		effect = {},
		id_text = "Nyawa -1 saat di-draw.",
		en_text = "Health -1 when drawn.",
	},
}

cards.order = {
	"StoneHammer", "WoodenMallet", "WarHammer", "SpikedClub", "GiantSledge", "Gauntlet",
	"Machete", "HeavyAxe", "BoneSickle", "SerratedSword", "Chainsaw", "FoldingKnife",
	"BoneDagger", "SharpSpear", "PoisonDagger", "DemonTrident", "PiercingArrow", "StingerNeedle",
	"FiberWeb", "SteelWeb", "GlueTrap", "SpiderWeb", "Torch", "FireArrow", "MolotovCocktail",
	"WoodenShield", "Focus", "Alert", "RedPotion", "GreenPotion", "SmokeBomb",
	"Meat", "Larva", "Twig", "DryLeaf", "Poison",
}

cards.junk = { Larva = true, Twig = true, DryLeaf = true, Poison = true }

cards.reward_weapons = {}
for _, id in ipairs(cards.order) do
	if id ~= "Meat" and not cards.junk[id] then
		cards.reward_weapons[#cards.reward_weapons + 1] = id
	end
end

cards.starting_deck = {
	"StoneHammer", "StoneHammer", "BoneDagger", "BoneDagger",
	"Machete", "Machete", "FiberWeb", "Torch", "WoodenShield", "Focus",
}

return cards
