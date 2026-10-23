-- Monster definitions. Monster names stay in English per the GDD.
-- Part names and threat descriptions are localized at runtime.

local monsters = {
	StagBeetle = {
		name = "Stag Beetle", tier = 2,
		slots = {
			{ part = "Mandibles", need = "Blunt" },
			{ part = "Shell", need = "Blunt" },
			{ part = "Legs", need = "Slash" },
		},
		threats = {
			{ kind = "burn", value = 1 },
			{ kind = "slash", value = 1 },
		},
	},
	Ladybug = {
		name = "Ladybug", tier = 1,
		slots = {
			{ part = "Wings", need = "Web" },
			{ part = "Shell", need = "Blunt" },
			{ part = "Abdomen", need = "Pierce" },
		},
		threats = {
			{ kind = "burn", value = 1 },
			{ kind = "burn", value = 1 },
		},
	},
	GoliathBeetle = {
		name = "Goliath Beetle", tier = 3,
		slots = {
			{ part = "Shell", need = "Blunt" },
			{ part = "Head/Horn", need = "Blunt" },
			{ part = "Legs", need = "Slash" },
		},
		threats = {
			{ kind = "burn", value = 3 },
			{ kind = "destroy_weapon" },
		},
	},
	JewelBeetle = {
		name = "Jewel Beetle", tier = 1,
		slots = {
			{ part = "Shell", need = "Blunt" },
			{ part = "Head", need = "Pierce" },
			{ part = "Abdomen", need = "Pierce" },
		},
		threats = {
			{ kind = "burn", value = 2 },
			{ kind = "burn", value = 2 },
		},
	},
	HerculesBeetle = {
		name = "Hercules Beetle", tier = 3,
		slots = {
			{ part = "Shell", need = "Blunt" },
			{ part = "Horn", need = "Blunt" },
			{ part = "Legs", need = "Slash" },
		},
		threats = {
			{ kind = "burn", value = 3 },
			{ kind = "insert_larva", value = 1 },
		},
	},
	BulletAnt = {
		name = "Bullet Ant", tier = 2,
		slots = {
			{ part = "Abdomen", need = "Pierce" },
			{ part = "Head", need = "Blunt" },
			{ part = "Legs", need = "Slash" },
		},
		threats = {
			{ kind = "poison", value = 1 },
		},
	},
	YellowjacketWasp = {
		name = "Yellowjacket Wasp", tier = 1,
		slots = {
			{ part = "Wings", need = "Web" },
			{ part = "Abdomen/Stinger", need = "Pierce" },
			{ part = "Neck", need = "Pierce" },
		},
		threats = {
			{ kind = "burn", value = 2 },
			{ kind = "sting", value = 2 },
		},
	},
	TarantulaHawk = {
		name = "Tarantula Hawk", tier = 3,
		slots = {
			{ part = "Wings", need = "Web" },
			{ part = "Abdomen", need = "Pierce" },
			{ part = "Legs", need = "Slash" },
		},
		threats = {
			{ kind = "burn", value = 2 },
			{ kind = "slash", value = 1 },
		},
	},
	HoneyBee = {
		name = "Honey Bee", tier = 1,
		slots = {
			{ part = "Wings", need = "Web" },
			{ part = "Abdomen", need = "Pierce" },
			{ part = "Head", need = "Blunt" },
		},
		threats = {
			{ kind = "burn", value = 1 },
			{ kind = "burn", value = 1 },
		},
	},
	AtlasMoth = {
		name = "Atlas Moth", tier = 3,
		slots = {
			{ part = "Wings", need = "Web" },
			{ part = "Body", need = "Pierce" },
			{ part = "Antennae", need = "Slash" },
		},
		threats = {
			{ kind = "burn", value = 3 },
			{ kind = "insert_larva", value = 1 },
		},
	},
	LunaMoth = {
		name = "Luna Moth", tier = 2,
		slots = {
			{ part = "Wings", need = "Web" },
			{ part = "Body", need = "Pierce" },
			{ part = "Tail", need = "Slash" },
		},
		threats = {
			{ kind = "skip", label = "sleep" },
			{ kind = "burn", value = 2 },
		},
	},
	MonarchButterfly = {
		name = "Monarch Butterfly", tier = 1,
		slots = {
			{ part = "Wings", need = "Web" },
			{ part = "Head", need = "Blunt" },
			{ part = "Abdomen", need = "Pierce" },
		},
		threats = {
			{ kind = "burn", value = 2 },
			{ kind = "burn", value = 2 },
		},
	},
	BlackWidow = {
		name = "Black Widow", tier = 3,
		slots = {
			{ part = "Abdomen", need = "Pierce" },
			{ part = "Head", need = "Blunt" },
			{ part = "Legs", need = "Slash" },
		},
		threats = {
			{ kind = "poison", value = 2 },
		},
	},
	GoliathBirdeater = {
		name = "Goliath Birdeater", tier = 3,
		slots = {
			{ part = "Abdomen", need = "Pierce" },
			{ part = "Head", need = "Blunt" },
			{ part = "Legs", need = "Slash" },
		},
		threats = {
			{ kind = "burn", value = 3 },
			{ kind = "destroy_weapon" },
		},
	},
	EmperorScorpion = {
		name = "Emperor Scorpion", tier = 3, boss = true,
		slots = {
			{ part = "Shell", need = "Blunt" },
			{ part = "Tail", need = "Slash" },
			{ part = "Legs", need = "Slash" },
			{ part = "Claws", need = "Pierce" },
		},
		threats = {
			{ kind = "burn", value = 3 },
			{ kind = "sting", value = 3 },
		},
	},
	PeacockSpider = {
		name = "Peacock Spider", tier = 1,
		slots = {
			{ part = "Abdomen", need = "Pierce" },
			{ part = "Head", need = "Blunt" },
			{ part = "Legs", need = "Slash" },
		},
		threats = {
			{ kind = "burn", value = 1 },
			{ kind = "skip", label = "dance" },
		},
	},
	StinkBug = {
		name = "Stink Bug", tier = 1,
		slots = {
			{ part = "Shell", need = "Blunt" },
			{ part = "Head", need = "Blunt" },
			{ part = "Legs", need = "Slash" },
		},
		threats = {
			{ kind = "prevent_play" },
			{ kind = "burn", value = 2 },
		},
	},
	AssassinBug = {
		name = "Assassin Bug", tier = 2,
		slots = {
			{ part = "Head", need = "Pierce" },
			{ part = "Proboscis", need = "Pierce" },
			{ part = "Front Legs", need = "Slash" },
		},
		threats = {
			{ kind = "pierce", value = 1 },
			{ kind = "burn", value = 1 },
		},
	},
	Cicada = {
		name = "Cicada", tier = 1,
		slots = {
			{ part = "Wings", need = "Web" },
			{ part = "Eyes", need = "Pierce" },
			{ part = "Abdomen", need = "Pierce" },
		},
		threats = {
			{ kind = "sound", value = 1 },
			{ kind = "burn", value = 1 },
		},
	},
	PrayingMantis = {
		name = "Praying Mantis", tier = 2,
		slots = {
			{ part = "Scythe Arms", need = "Slash" },
			{ part = "Neck", need = "Pierce" },
			{ part = "Wings", need = "Web" },
		},
		threats = {
			{ kind = "slash", value = 1 },
			{ kind = "pierce", value = 1 },
		},
	},
	Locust = {
		name = "Locust", tier = 2,
		slots = {
			{ part = "Hind Legs", need = "Slash" },
			{ part = "Wings", need = "Web" },
			{ part = "Abdomen", need = "Pierce" },
		},
		threats = {
			{ kind = "burn", value = 1 },
			{ kind = "slash", value = 1 },
		},
	},
	JerusalemCricket = {
		name = "Jerusalem Cricket", tier = 2,
		slots = {
			{ part = "Abdomen", need = "Pierce" },
			{ part = "Head", need = "Blunt" },
			{ part = "Legs", need = "Slash" },
		},
		threats = {
			{ kind = "burn", value = 1 },
			{ kind = "destroy_weapon" },
		},
	},
	Dragonfly = {
		name = "Dragonfly", tier = 1,
		slots = {
			{ part = "Wings", need = "Web" },
			{ part = "Tail", need = "Slash" },
			{ part = "Eyes", need = "Pierce" },
		},
		threats = {
			{ kind = "slash", value = 1 },
			{ kind = "slash", value = 1 },
		},
	},
	Centipede = {
		name = "Centipede", tier = 3,
		slots = {
			{ part = "Segments", need = "Blunt" },
			{ part = "Head", need = "Blunt" },
			{ part = "Legs", need = "Slash" },
		},
		threats = {
			{ kind = "burn", value = 2 },
			{ kind = "burn", value = 2 },
		},
	},
	Earwig = {
		name = "Earwig", tier = 1,
		slots = {
			{ part = "Pincers", need = "Slash" },
			{ part = "Head", need = "Blunt" },
			{ part = "Shell", need = "Blunt" },
		},
		threats = {
			{ kind = "burn", value = 1 },
			{ kind = "slash", value = 1 },
		},
	},
	Firefly = {
		name = "Firefly", tier = 1,
		slots = {
			{ part = "Abdomen", need = "Pierce" },
			{ part = "Wings", need = "Web" },
			{ part = "Head", need = "Blunt" },
		},
		threats = {
			{ kind = "burn", value = 2 },
			{ kind = "burn", value = 2 },
		},
	},
	Silverfish = {
		name = "Silverfish", tier = 1,
		slots = {
			{ part = "Head", need = "Blunt" },
			{ part = "Abdomen", need = "Pierce" },
			{ part = "Tail", need = "Slash" },
		},
		threats = {
			{ kind = "burn", value = 1 },
			{ kind = "burn", value = 1 },
		},
	},
	Termite = {
		name = "Termite", tier = 1,
		slots = {
			{ part = "Head", need = "Blunt" },
			{ part = "Abdomen", need = "Pierce" },
			{ part = "Legs", need = "Slash" },
		},
		threats = {
			{ kind = "burn", value = 1 },
			{ kind = "burn", value = 1 },
		},
	},
	Flea = {
		name = "Flea", tier = 1,
		slots = {
			{ part = "Shell", need = "Blunt" },
			{ part = "Legs", need = "Slash" },
			{ part = "Head", need = "Blunt" },
		},
		threats = {
			{ kind = "burn", value = 1 },
			{ kind = "burn", value = 1 },
		},
	},
	Glowworm = {
		name = "Glowworm", tier = 2,
		slots = {
			{ part = "Segments", need = "Blunt" },
			{ part = "Head", need = "Blunt" },
			{ part = "Abdomen", need = "Pierce" },
		},
		threats = {
			{ kind = "burn", value = 1 },
			{ kind = "burn", value = 1 },
		},
	},
}

local extra_slots = {
	StagBeetle = {
		{ part = "Head", need = "Pierce" },
	},
	BulletAnt = {
		{ part = "Thorax", need = "Slash" },
	},
	LunaMoth = {
		{ part = "Antennae", need = "Blunt" },
	},
	AssassinBug = {
		{ part = "Legs", need = "Blunt" },
	},
	PrayingMantis = {
		{ part = "Abdomen", need = "Pierce" },
	},
	Locust = {
		{ part = "Head", need = "Blunt" },
	},
	JerusalemCricket = {
		{ part = "Wings", need = "Web" },
	},
	Glowworm = {
		{ part = "Wings", need = "Web" },
	},
	GoliathBeetle = {
		{ part = "Mandibles", need = "Pierce" },
		{ part = "Abdomen", need = "Slash" },
	},
	HerculesBeetle = {
		{ part = "Head", need = "Pierce" },
		{ part = "Abdomen", need = "Slash" },
	},
	TarantulaHawk = {
		{ part = "Head", need = "Blunt" },
		{ part = "Thorax", need = "Blunt" },
	},
	AtlasMoth = {
		{ part = "Head", need = "Blunt" },
		{ part = "Legs", need = "Slash" },
	},
	BlackWidow = {
		{ part = "Thorax", need = "Slash" },
		{ part = "Fangs", need = "Pierce" },
	},
	GoliathBirdeater = {
		{ part = "Fangs", need = "Pierce" },
		{ part = "Thorax", need = "Blunt" },
	},
	EmperorScorpion = {
		{ part = "Stinger", need = "Pierce" },
	},
	Centipede = {
		{ part = "Antennae", need = "Pierce" },
		{ part = "Tail", need = "Slash" },
	},
}

for id, slots in pairs(extra_slots) do
	for _, slot in ipairs(slots) do
		table.insert(monsters[id].slots, slot)
	end
end

monsters.order = {
	"StagBeetle", "Ladybug", "GoliathBeetle", "JewelBeetle", "HerculesBeetle",
	"BulletAnt", "YellowjacketWasp", "TarantulaHawk", "HoneyBee", "AtlasMoth",
	"LunaMoth", "MonarchButterfly", "BlackWidow", "GoliathBirdeater", "EmperorScorpion",
	"PeacockSpider", "StinkBug", "AssassinBug", "Cicada", "PrayingMantis",
	"Locust", "JerusalemCricket", "Dragonfly", "Centipede", "Earwig",
	"Firefly", "Silverfish", "Termite", "Flea", "Glowworm",
}

monsters.encounter_tiers = { 1, 1, 2, 2, 3, 3, 3 }

return monsters
