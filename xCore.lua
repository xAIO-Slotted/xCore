DB = {}
X = {}
X.helper = {}

-- Teams
local TEAM_ALLY = g_local.team
local TEAM_ENEMY = 300 - g_local.team
local TEAM_JUNGLE = 300

-- DamageTypes
local DAMAGE_TYPE_PHYSICAL = 1
local DAMAGE_TYPE_MAGICAL = 2
local DAMAGE_TYPE_TRUE = 3

-- Item Slots
local ItemSlots = { e_spell_slot.item1, e_spell_slot.item2, e_spell_slot.item3, e_spell_slot.item4, e_spell_slot.item5,
	e_spell_slot.item6, e_spell_slot.item7 }

-- Dash Database
-- Contains all the dashes and their spellslots.

DB.Dash = {
	aatrox = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	garen = {
		{
			slot = 0,
			menuslot = "Q"
		}
	},
	ahri = {
		{
			slot = 3,
			menuslot = "R"
		}
	},
	akali = {
		{
			slot = 2,
			menuslot = "E"
		},
		{
			slot = 3,
			menuslot = "R"
		}
	},
	alistar = {
		{
			slot = 1,
			menuslot = "W",
			targeted = true
		}
	},
	amumu = {
		{
			slot = 0,
			menuslot = "Q"
		}
	},
	azir = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	belveth = {
		{
			slot = 0,
			menuslot = "Q"
		}
	},
	braum = {
		{
			slot = 1,
			menuslot = "W"
		}
	},
	caitlyn = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	camille = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	corki = {
		{
			slot = 1,
			menuslot = "W"
		}
	},
	diana = {
		{
			slot = 2,
			menuslot = "E",
			targeted = true
		}
	},
	ekko = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	elise = {
		{
			slot = 0,
			menuslot = "Q"
		}
	},
	evelynn = {
		{
			slot = 2,
			menuslot = "E",
			targeted = true
		}
	},
	ezreal = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	fiora = {
		{
			slot = 0,
			menuslot = "Q"
		}
	},
	fiddlesticks = {
		{
			slot = 3,
			menuslot = "R"
		}
	},
	fizz = {
		{
			slot = 0,
			menuslot = "Q"
		}
	},
	galio = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	gnar = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	gragas = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	graves = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	hecarim = {
		{
			slot = 46,
			menuslot = "E"
		},
		{
			slot = 3,
			menuslot = "R"
		}
	},
	illaoi = {
		{
			slot = 1,
			menuslot = "W",
			targeted = true
		}
	},
	irelia = {
		{
			slot = 0,
			menuslot = "Q",
			targeted = true
		}
	},
	ksante = {
		{
			slot = 1,
			menuslot = "W",
		},
		{
			slot = 2,
			menuslot = "E"
		},
		{
			slot = 3,
			menuslot = "R",
			targeted = true
		}
	},
	ivern = {
		{
			slot = 0,
			menuslot = "Q"
		}
	},
	rell = {
		{
			slot = 1,
			menuslot = "W"
		}
	},
	gwen = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	viego = {
		{
			slot = 1,
			menuslot = "W"
		}
	},
	jarvaniv = {
		{
			slot = 0,
			menuslot = "Q"
		},
		{
			slot = 3,
			menuslot = "R"
		}
	},
	jax = {
		{
			slot = 0,
			menuslot = "Q",
			targeted = true
		}
	},
	jayce = {
		{
			slot = 0,
			menuslot = "Q",
			targeted = true
		}
	},
	kaisa = {
		{
			slot = 3,
			menuslot = "R"
		}
	},
	kalista = {
		{
			slot = 0,
			menuslot = "Q"
		}
	},
	kassadin = {
		{
			slot = 3,
			menuslot = "R"
		}
	},
	katarina = {
		{
			slot = 49,
			menuslot = "E",
			targeted = true
		}
	},
	kayn = {
		{
			slot = 0,
			menuslot = "Q"
		}
	},
	khazix = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	kindred = {
		{
			slot = 0,
			menuslot = "Q"
		}
	},
	kled = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	leblanc = {
		{
			slot = 1,
			menuslot = "W"
		},
		{
			slot = 3,
			menuslot = "R"
		}
	},
	leesin = {
		{
			slot = 0,
			menuslot = "Q",
			targeted = true
		},
		{
			slot = 1,
			menuslot = "W"
		}
	},
	leona = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	lillia = {
		{
			slot = 1,
			menuslot = "W"
		}
	},
	lissandra = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	lucian = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	malphite = {
		{
			slot = 3,
			menuslot = "R"
		}
	},
	maokai = {
		{
			slot = 1,
			menuslot = "W",
			targeted = true
		}
	},
	masteryi = {
		{
			slot = 0,
			menuslot = "Q",
			targeted = true
		}
	},
	nautilus = {
		{
			slot = 0,
			menuslot = "Q"
		}
	},
	nidalee = {
		{
			slot = 1,
			menuslot = "W"
		}
	},
	nocturne = {
		{
			slot = 3,
			menuslot = "R"
		}
	},
	ornn = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	pantheon = {
		{
			slot = 1,
			menuslot = "W",
			targeted = true
		}
	},
	poppy = {
		{
			slot = 2,
			menuslot = "E",
			targeted = true
		}
	},
	pyke = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	samira = {
		{
			slot = 2,
			menuslot = "E",
			targeted = true
		}
	},
	nilah = {
		{
			slot = 2,
			menuslot = "E",
			targeted = true
		}
	},
	qiyana = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	quinn = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	rakan = {
		{
			slot = 1,
			menuslot = "W"
		},
		{
			slot = 2,
			menuslot = "E",
			targeted = true
		}
	},
	reksai = {
		{
			slot = 2,
			menuslot = "E"
		},
		{
			slot = 3,
			menuslot = "R"
		}
	},
	renekton = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	rengar = {
		{
			slot = -1,
			menuslot = "P"
		}
	},
	riven = {
		{
			slot = 0,
			menuslot = "Q1"
		},
		{
			slot = 0,
			menuslot = "Q2"
		},
		{
			slot = 0,
			menuslot = "Q3"
		},
		{
			slot = 2,
			menuslot = "E"
		}
	},
	sejuani = {
		{
			slot = 0,
			menuslot = "Q"
		}
	},
	shen = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	shaco = {
		{
			slot = 0,
			menuslot = "Q"
		}
	},
	shyvana = {
		{
			slot = 3,
			menuslot = "R"
		}
	},
	sylas = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	talon = {
		{
			slot = 0,
			menuslot = "Q"
		},
		{
			slot = 2,
			menuslot = "E"
		}
	},
	thresh = {
		{
			slot = 0,
			menuslot = "Q"
		}
	},
	tristana = {
		{
			slot = 1,
			menuslot = "W"
		}
	},
	tryndamere = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	urgot = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	vayne = {
		{
			slot = 0,
			menuslot = "Q"
		}
	},
	vi = {
		{
			slot = 0,
			menuslot = "Q"
		}
	},
	volibear = {
		{
			slot = 3,
			menuslot = "R"
		}
	},
	vex = {
		{
			slot = 3,
			menuslot = "R"
		}
	},
	warwick = {
		{
			slot = 0,
			menuslot = "Q",
			targeted = true
		},
		{
			slot = 3,
			menuslot = "R"
		}
	},
	monkeyking = {
		{
			slot = 1,
			menuslot = "W"
		},
		{
			slot = 2,
			menuslot = "E",
			targeted = true
		}
	},
	xinzhao = {
		{
			slot = 2,
			menuslot = "E",
			targeted = true
		}
	},
	yasuo = {
		{
			slot = 2,
			menuslot = "E",
			targeted = true
		}
	},
	yone = {
		{
			slot = 0,
			menuslot = "Q"
		},
		{
			slot = 3,
			menuslot = "R"
		}
	},
	yuumi = {
		{
			slot = 1,
			menuslot = "W",
			targeted = true
		}
	},
	zac = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	zeri = {
		{
			slot = 2,
			menuslot = "E"
		}
	},
	zed = {
		{
			slot = 1,
			menuslot = "W"
		},
		{
			slot = 3,
			menuslot = "R"
		}
	},
	ziggs = {
		{
			slot = 1,
			menuslot = "W"
		}
	}
}
-- Health

local get_percent_hp = function(unit)
	return 100 * unit.health / unit.max_health
end

local get_percent_missing_hp = function(unit)
	return (1 - (unit.health / unit.max_health)) * 100
end

local get_missing_hp = function(unit)
	return (unit.max_health - unit.health)
end

-- We only need this for special cases.
local get_base_hp = function(unit)
	if unit.champion_name == "Sylas" then
		return 575 + (129 * (unit.level - 1)) * (0.7025 + (0.0175 * (unit.level - 1)))
	elseif unit.champion_name == "Chogath" then
		return 607 + (110 * (unit.level - 1)) * (0.7025 + (0.0175 * (unit.level - 1)))
	elseif unit.champion_name == "Volibear" then
		return 650 + (104 * (unit.level - 1)) * (0.7025 + (0.0175 * (unit.level - 1)))
	elseif unit.champion_name == "Vladimir" then
		return 537 + (96 * (unit.level - 1)) * (0.7025 + (0.0175 * (unit.level - 1)))
	elseif unit.champion_name == "DrMundo" then
		return 653 + (103 * (unit.level - 1)) * (0.7025 + (0.0175 * (unit.level - 1)))
	elseif unit.champion_name == "Maokai" then
		return 635 + (109 * (unit.level - 1)) * (0.7025 + (0.0175 * (unit.level - 1)))
	elseif unit.champion_name == "KSante" then
		return 610 + (108 * (unit.level - 1)) * (0.7025 + (0.0175 * (unit.level - 1)))
	elseif unit.champion_name == "Sett" then
		return 670 + (114 * (unit.level - 1)) * (0.7025 + (0.0175 * (unit.level - 1)))
	elseif unit.champion_name == "Nunu" then
		return 610 + (90 * (unit.level - 1)) * (0.7025 + (0.0175 * (unit.level - 1)))
	end
end

-- Buffs

local has_buff = function(unit, buffname)
	local buff = features.buff_cache:get_buff(unit.index, buffname)
	if buff and buff:get_stacks() > 0 then
		return buff:get_stacks()
	end
	return 0
end

local get_buff_data = function(unit, buffname)
	local buff = features.buff_cache:get_buff(unit.index, buffname)
	if buff and buff:get_stacks() > 0 then
		return buff
	end
	return { active = false, hard_cc = false, disabling = false, knock_up = false, silence = false, cripple = false,
		invincible = false, slow = false, type = 0, start_time = 0, end_time = 0, alt_amount = 0, name = "", amount = 0 }
end

-- Spells

local has_spell = function(spellslot, spellname)
	if g_local:get_spell_book():get_spell_slot(spellslot):get_name() == spellname then
		return 1
	end
	return 0
end

-- Items

local Item = {
	CachedItems = {},
	OnTick = function(self)
		self.CachedItems = {}
	end,
	GetItemById = function(self, unit, id)
		local networkID = unit.networkID
		if self.CachedItems[networkID] == nil then
			local t = {}
			for i = 1, #ItemSlots do
				local slot = ItemSlots[i]
				local item = unit:GetItemData(slot)
				if item ~= nil and item.itemID ~= nil and item.itemID > 0 then
					t[item.itemID] = i
				end
			end
			self.CachedItems[networkID] = t
		end
		return self.CachedItems[networkID][id]
	end,
	HasItem = function(self, unit, id)
		return self:GetItemById(unit, id) ~= nil
	end,
}

local GetItemSlot = function(unit, id)
	for i = e_spell_slot.item1, e_spell_slot.item7 do
		if unit:GetItemData(i).itemID == id then return i end
	end
	return 0
end

local DMG_REDUCTION_BUFFS = {
	["Annie"] = { buff = "AnnieE", amount = function(target) return 1 -
		({ 0.10, 0.13, 0.16, 0.19, 0.22 })[target:get_spell_book():get_spell_slot(e_spell_slot.e).level] end },                                                      -- TODO: find right values.
	["Alistar"] = { buff = "FerociousHowl", amount = function(target) return 1 -
		({ 0.55, 0.65, 0.75 })[target:get_spell_book():get_spell_slot(e_spell_slot.r).level] end },
	["Belveth"] = { buff = "BelvethE", amount = function(target) return 1 - 0.7 end },
	["Braum"] = { buff = "BraumShieldRaise", amount = function(target) return 1 -
		({ 0.3, 0.325, 0.35, 0.375, 0.4 })[target:get_spell_book():get_spell_slot(e_spell_slot.e).level] end },
	["Galio"] = { buff = "galiowpassivedefense", DamageType = 2, amount = function(target) return 1 -
		({ 0.2, 0.25, 0.30, 0.35, 0.40 })[target:get_spell_book():get_spell_slot(e_spell_slot.w).level] +
		(0.05 * target:get_ability_power() / 100) + (0.8 * target.bonus_mr / 100) end },
	["Galio"] = { buff = "galiowpassivedefense", DamageType = 1, amount = function(target) return 1 -
		({ 0.1, 0.125, 0.15, 0.175, 0.20 })[target:get_spell_book():get_spell_slot(e_spell_slot.w).level] +
		(0.025 * target:get_ability_power() / 100) + (0.4 * target.bonus_mr / 100) end },
	["Garen"] = { buff = "GarenW", amount = function(target) return 1 - 0.3 end },
	["Gragas"] = { buff = "GragasWSelf", amount = function(target) return 1 -
		({ 0.1, 0.12, 0.14, 0.16, 0.18 })[target:get_spell_book():get_spell_slot(e_spell_slot.w).level] +
		0.04 * target:get_ability_power() / 100 end },
	["KSante"] = { buff = "KSanteW", amount = function(source, target) return 1 - 0.25 +
		(0.10 * math.floor(target.bonus_armor / 100)) + (0.10 * math.floor(target.bonus_mr / 100)) +
		(0.10 * math.floor((target.max_health - get_base_hp(target)) / 100)) end },
	["Malzahar"] = { buff = "malzaharpassiveshield", amount = function(target) return 1 - 0.9 end },
	["MasterYi"] = { buff = "Meditate", amount = function(source, target) return 1 -
		({ 0.45, 0.475, 0.50, 0.525, 0.55 })[target:get_spell_book():get_spell_slot(e_spell_slot.w).level] /
		(source:is_building() and 2 or 1) end },
	["NilahW"] = { buff = "NilahW", DamageType = 2, amount = function(target) return 1 - 0.25 end }, -- TODO
}

local DMG_REDUCTION_ITEMS = {
	["PlatedSteelcaps"] = { IsAA = true, amount = function(source, target, DamageType, amount) -- Plated Steelcaps // 3047
		return 1 - 0.12
	end },
	["FrozenHeart"] = { IsAA = true, amount = function(source, target, DamageType, amount) -- Frozen Heart // 3110
		return math.max(5 + (3.5 * math.floor(target.max_health / 1000)), amount * 0.40)
	end },
	["RanduinsOmen"] = { IsAA = true, amount = function(source, target, DamageType, amount) -- Randuin's Omen // 3143
		return math.max(7 + (3.5 * math.floor(target.max_health / 1000)), amount * 0.40)
	end },
	["WardensMail"] = { IsAA = true, amount = function(source, target, DamageType, amount) -- Warden's Mail // 3082
		return math.max(7 + (3.5 * math.floor(target.max_health / 1000)), amount * 0.40)
	end },
	["ForceOfNature"] = { buff = "4401maxstacked", IsAA = false, DamageType = 2, amount = function(source, target,
																								   DamageType, amount)              -- Force of Nature // 4401
		if DamageType == 2 then
			return (1 - 0.25)
		end
	end },
}

local PENETRATION_ITEM = {}

function PENETRATION_ITEM:new(lethality, armorPenetration, magicPenetration, extraLethality, extraArmorPenetration,
							  extraMagicPenetration)
	local newItem = {
		lethality = lethality or 0,
		armorPenetration = armorPenetration or 0,
		magicPenetration = magicPenetration or 0,
		extraLethality = extraLethality or 0,
		extraArmorPenetration = extraArmorPenetration or 0,
		extraMagicPenetration = extraMagicPenetration or 0
	}
	setmetatable(newItem, self)
	self.__index = self
	return newItem
end

local DMG_MULTIPLIERS_BUFFS = {
                                                                  -- format: lethality (int), armor penetration (percent)
	["6632"] = PENETRATION_ITEM:new(0, 0, 0, 0, 0.03, 0.03),      -- Divine Sunderer // 6632
	["3035"] = PENETRATION_ITEM:new(0, 0.18, 0, 0, 0.00, 0.00),   -- Last Whisper // 3035
	["3033"] = PENETRATION_ITEM:new(0, 0.3, 0, 0, 0.00, 0.00),    -- Mortal Reminder // 3033
	["3036"] = PENETRATION_ITEM:new(0, 0.3, 0, 0, 0.00, 0.00),    -- Lord Dominik's Regards // 3036
	["6694"] = PENETRATION_ITEM:new(0, 0.3, 0, 0, 0.00, 0.00),    -- Serylda's Grudge // 6694
	["3134"] = PENETRATION_ITEM:new(10, 0, 0, 0, 0.00, 0.00),     -- Serrated Dirk // 3134
	["6693Active"] = PENETRATION_ITEM:new(18, 0, 0, 0, 0.00, 0.00), -- Prowler's Claw // 6693
	["6692"] = PENETRATION_ITEM:new(12, 0, 0, 0, 0.04, 0.00),     -- Eclipse // 6692
	["6691"] = PENETRATION_ITEM:new(18, 0, 0, 0, 0.00, 0.00),     -- Duskblade of Draktharr // 6691
	["YoumusBlade"] = PENETRATION_ITEM:new(18, 0, 0, 0, 0.00, 0.00), -- Youmuu's Ghostblade // 3142
	["3179"] = PENETRATION_ITEM:new(10, 0, 0, 0, 0.00, 0.00),     -- Umbrail Glaive // 3179
	["6695"] = PENETRATION_ITEM:new(12, 0, 0, 0, 0.00, 0.00),     -- Serpent's Fang // 6695
	["6696"] = PENETRATION_ITEM:new(18, 0, 0, 0, 0.00, 0.00),     -- Axiom Arc // 6696
	["3814"] = PENETRATION_ITEM:new(10, 0, 0, 0, 0.00, 0.00),     -- Edge of Night // 3814
	["6676"] = PENETRATION_ITEM:new(12, 0, 0, 0, 0.00, 0.00),     -- The Collector // 6676
	-- Black Cleaver every stack up to 6 times adds 0.05 armor pen (ID 3071) TODO: get a way to find the stacks.
	["3071"] = PENETRATION_ITEM:new(0, function(source, target, DamageType, amount)
		local stacks = 0
		if has_buff(target, "TODO") then
			stacks = get_buff_data(target, "TODO"):get_amount()
		end
		return 0.05 * math.min(stacks, 6)
	end, 0, 0, 0.00, 0.00), -- Black Cleaver // 3071
}

--[[ TODO:
  Chemtech damage increase and reduction
  -- Abyssal Mask
  -- Gargoyle Stoneplate
  -- Anathema's Chains
]]
local SPECIAL_AA = {
	--Spell/Skills
	["Blitzcrank"] = function(args) --BlitzcrankW
		if has_buff(args.source, "Overdrive") then
			local unitLevel = args.source.level
			local max_health = (1 / 100 * args.Target.max_health)
			if args.TargetIsMinion then
				args.RawMagical = (max_health) +
					({ 60, 80, 100, 120, 140, 160, 165, 170, 175, 180, 185, 190, 195, 200, 205, 210, 215, 220 })
					[unitLevel]                                                                              -- (60+120, 17*(unitLevel-1))
			else
				args.RawMagical = (max_health)
			end
		end
	end,
	["Kayle"] = function(args) --KayleE
		local level = args.source:get_spell_book():get_spell_slot(e_spell_slot.e).level
		if level > 0 then
			if has_buff(args.source, "JudicatorRighteousFury") then
				args.RawMagical = args.RawMagical + 10 + 10 * level + 0.3 * args.source:get_ability_power()
			else
				args.RawMagical = args.RawMagical + 5 + 5 * level + 0.15 * args.source:get_ability_power()
			end
		end
	end,
	["Nasus"] = function(args) --NasusQ
		if has_buff(args.source, "NasusQ") then
			args.RawPhysical = args.RawPhysical
				+ math.max(get_buff_data(args.source, "NasusQStacks"):get_amount(), 0)
				+ 10
				+ 20 * args.source:get_spell_book():get_spell_slot(e_spell_slot.q).level
		end
	end,
	["Nilah"] = function(args) --NilahQ
		if has_buff(args.source, "NilahQ") then
			args.RawPhysical = args.RawPhysical
				+ 1.0 * args.source.total_damage
		end
	end,
	["Thresh"] = function(args) --ThreshE
		local level = args.source:get_spell_book():get_spell_slot(e_spell_slot.e).level
		if level > 0 then
			local damage = math.max(get_buff_data(args.source, "threshpassivesouls"):get_amount(), 0)
				+ (0.5 + 0.3 * level) * args.source.total_damage
			if has_buff(args.source, "threshqpassive4") then
				damage = damage * 1
			elseif has_buff(args.source, "threshqpassive3") then
				damage = damage * 0.5
			elseif has_buff(args.source, "threshqpassive2") then
				damage = damage * 1 / 3
			else
				damage = damage * 0.25
			end
			args.RawMagical = args.RawMagical + damage
		end
	end,
	["TwistedFate"] = function(args) --TwistedFateW
		if has_buff(args.source, "cardmasterstackparticle") then
			args.RawMagical = args.RawMagical + 30 +
			25 * args.source:get_spell_book():get_spell_slot(e_spell_slot.e).level +
			0.5 * args.source:get_ability_power()
		end
		if has_buff(args.source, "BlueCardPreAttack") then
			args.DamageType = DAMAGE_TYPE_MAGICAL
			args.RawMagical = args.RawMagical + 20 +
			20 * args.source:get_spell_book():get_spell_slot(e_spell_slot.w).level +
			0.5 * args.source:get_ability_power()
		elseif has_buff(args.source, "RedCardPreAttack") then
			args.DamageType = DAMAGE_TYPE_MAGICAL
			args.RawMagical = args.RawMagical + 15 +
			15 * args.source:get_spell_book():get_spell_slot(e_spell_slot.w).level +
			0.5 * args.source:get_ability_power()
		elseif has_buff(args.source, "GoldCardPreAttack") then
			args.DamageType = DAMAGE_TYPE_MAGICAL
			args.RawMagical = args.RawMagical + 7.5 +
			7.5 * args.source:get_spell_book():get_spell_slot(e_spell_slot.w).level +
			0.5 * args.source:get_ability_power()
		end
	end,
	["Udyr"] = function(args) --Udyr Q and R
		if has_buff(args.source, "UdyrPAttackReady") then
			local level = args.source.level
			local qlevel = args.source:get_spell_book():get_spell_slot(e_spell_slot.q).level
			if has_buff(args.source, "UdyrQ") then
				args.DamageType = DAMAGE_TYPE_PHYSICAL
				args.RawPhysical = args.RawPhysical + ({ 5, 13, 21, 29, 37, 45 })[qlevel] +
					(0.20 * args.source:get_bonus_attack_damage()) +
					(
					({ 3.00, 4.40, 5.80, 7.20, 8.60, 10.00 })[qlevel] / 100 +
					(0.06 * math.floor(args.source:get_bonus_attack_damage() / 100)) * args.Target.max_health)
			elseif has_buff(args.source, "UdyrR") then
				args.DamageType = DAMAGE_TYPE_MAGICAL
				args.RawMagical = args.RawMagical + (10 + 20 / 17 * (level - 1)) +
				(0.30 * args.source:get_ability_power())
			end
		end
	end,
	["Varus"] = function(args) --VarusW
		local level = args.source:get_spell_book():get_spell_slot(e_spell_slot.w).level
		if level > 0 then
			args.RawMagical = args.RawMagical + 6 + 4 * level + 0.25 * args.source:get_ability_power()
		end
	end,
	["Viktor"] = function(args) --ViktorQ
		if has_buff(args.source, "ViktorPowerTransferReturn") then
			local level = args.source:get_spell_book():get_spell_slot(e_spell_slot.q).level
			args.DamageType = DAMAGE_TYPE_MAGICAL
			args.RawMagical = args.RawMagical + ({ 20, 45, 70, 95, 120 })[level] + 0.6 * args.source:get_ability_power() +
				1.0 * args.source.total_damage
		end
	end,
	["Vayne"] = function(args) --VayneQ
		if has_buff(args.source, "vaynetumblebonus") then
			args.RawPhysical = args.RawPhysical
				+ (0.25 + 0.05 * args.source:get_spell_book():get_spell_slot(e_spell_slot.q).level) *
				args.source.total_damage
		end
	end,
	["Zac"] = function(args) --ZacQ
		local level = args.source:get_spell_book():get_spell_slot(e_spell_slot.q).level
		args.DamageType = DAMAGE_TYPE_MAGICAL
		args.RawMagical = ({ 40, 55, 70, 85, 100 })[level] + (0.3 * args.source:get_ability_power()) +
		(0.025 * args.source.max_health)
	end,
	["Zeri"] = function(args) --ZeriQ
		args.DamageType = DAMAGE_TYPE_MAGICAL
		args.RawTotal = args.RawTotal * 0
		args.RawPhysical = args.RawTotal
		--local small = { 15, 16, 17, 18, 19, 20, 22, 23, 24, 26, 27, 29, 31, 32, 34, 36, 38, 40 }
		--local big = { 90, 94, 99, 104, 109, 115, 121, 127, 133, 140, 146, 153, 160, 168, 175, 183, 191, 200 }
		if has_buff(g_local, "zeriqpassiveready") then
			args.RawMagical = 90 + (110 / 17)
				* (args.source.level - 1)
				* (0.7025 + 0.0175 * (args.source.level - 1))
				+ args.source:get_ability_power() * 1.10
				+ (1 + (14 / 17) * (args.source.level - 1) * (0.7025 + 0.0175 * (args.source.level - 1)))
			--big[math_max(math_min(args.source.level, 18), 1)] + args.source:get_ability_power() * 0.8
		else
			args.RawMagical = 10 + (15 / 17) * (args.source.level - 1)
				* (0.7025 + 0.0175 * (args.source.level - 1))
				+ args.source:get_ability_power() * 0.03
			--small[math_max(math_min(args.source.level, 18), 1)] + args.source:get_ability_power() * 0.04
		end
	end,
}

local ITEM_DAMAGE = {
	["RecurveBow"] = function(args) --"Recurve Bow"
		args.RawPhysical = args.RawPhysical + 15
	end,
	["KircheisShard"] = function(args) --"Kircheis Shard"
		if get_buff_data(args.source, "itemstatikshankcharge"):get_amount() == 100 then
			args.RawMagical = args.RawMagical + 40
		end
	end,
	["Sheen"] = function(args) --"Sheen"
		if has_buff(args.source, "sheen") > 0 then
			args.RawPhysical = args.RawPhysical + 1 * args.source:get_attack_damage()
		end
	end,
	["SunfireAegis"] = function(args) --"Sunfire Aegis"
		if get_buff_data(args.source, "item3068stack"):get_amount() == 8 then
			--buff.ammo on hit burn * 3 - (args.Target.hpRegen*3) TODO
		end
	end,
	["TrinityForce"] = function(args) --"Trinity Force"
		if has_buff(args.source, "sheen") > 0 then
			args.RawPhysical = args.RawPhysical + 2 * args.source:get_attack_damage()
		end
	end,
	["RunaansHurricane"] = function(args) --"Runaan's Hurricane"
		args.RawPhysical = args.RawPhysical + 15
	end,
	["WitsEnd"] = function(args) --"Wit's End"
		args.RawMagical = args.RawMagical + 40
	end,
	["RapidFirecannon"] = function(args) --"Rapid Firecannon"
		if get_buff_data(args.source, "itemstatikshankcharge"):get_amount() == 100 then
			local t = { 50, 50, 50, 50, 50, 58, 66, 75, 83, 92, 100, 109, 117, 126, 134, 143, 151, 160 }
			args.RawMagical = args.RawMagical + t[math.max(math.min(args.source.level, 18), 1)]
		end
	end,
	["LichBane"] = function(args) --"Lich Bane"
		if has_buff(args.source, "lichbane") > 0 then
			args.RawMagical = args.RawMagical + 0.75 * args.source:get_attack_damage() +
			0.5 * args.source:get_ability_power()
		end
	end,
	["NashorsTooth"] = function(args) --"Nashor's Tooth"
		args.RawMagical = args.RawMagical + 15 + 0.15 * args.source:get_ability_power()
	end,
	["GuinsoosRageblade"] = function(args) --"Guinsoo's Rageblade"
		args.CalculatedMagical = args.CalculatedMagical + 15
	end,
}

local SetSpecialAADamageTable = function(args)
	local s = SPECIAL_AA[args.source.charName]
	if s then
		s(args)
	end
end

local SetItemDamageTable = function(id, args)
	local s = ITEM_DAMAGE[id]
	if s then
		s(args)
	end
end


local PassivePercentMod = function(source, target, DamageType, amount)
	local targetIsHero = target:is_hero();
	local sourceIsHero = source:is_hero();
	if sourceIsHero then
		if has_buff(source, "SRX_DragonSoulBuffChemtech") > 0 and get_percent_hp(source) < 50 then
			amount = amount * (1 + 0.10)
		end
		if targetIsHero then
			if (GetItemSlot(source, 3036) > 0) and source.max_health < target.max_health and DamageType == 1 then -- Lord Dominik's Regards // 3036
				amount = amount * (1 + 0.0075 * (math.min(2000, target.max_health - source.max_health) / 100))
			end
		end
	end
	return amount
end

local DamageReductionMod = function(source, target, DamageType, amount)
	local targetIsHero = target:is_hero();
	local sourceIsHero = source:is_hero();
	if sourceIsHero then
		if has_buff(source, "Exhaust") > 0 then
			amount = amount * (1 - 0.35)
		end
		if has_buff(source, "barontarget") > 0 then
			amount = amount * (1 - 0.50)
		end
		--Dragon Buff/Debuff
		if has_buff(target, "SRX_DragonSoulBuffChemtech") > 0 and get_percent_hp(target) < 50 then
			amount = amount * (1 - 0.10)
		end
		if has_buff(target, "s5_dragonvengeance") > 0 then
			if target.champion_name == "SRU_Dragon_Chemtech" and get_percent_hp(target) < 50 then
				amount = amount * (1 - 0.33)
			end
			local count = has_buff(source, "SRX_DragonBuff") > 0
			amount = amount * (1 - (0.07 * count))
		end
	end
	if targetIsHero then
		for i = 0, target.buffCount do
			if target:GetBuff(i).count > 0 then
				local buff = target:GetBuff(i)

				if DMG_REDUCTION_BUFFS[target.champion_name] then
					if buff.name == DMG_REDUCTION_BUFFS[target.champion_name].buff and (not DMG_REDUCTION_BUFFS[target.champion_name].DamageType or DMG_REDUCTION_BUFFS[target.champion_name].DamageType == DamageType) then
						amount = amount *
						DMG_REDUCTION_BUFFS[target.champion_name].amount(source, target, DamageType, amount)
					end
				end
			end
		end
		for i = 1, #ItemSlots do
			local slot = ItemSlots[i]
			local item = target:GetItemData(slot)
			if item ~= nil and item.itemID > 0 then
				if DMG_REDUCTION_ITEMS[item.itemID] then
					if item.itemID == DMG_REDUCTION_ITEMS[item.itemID] and (not DMG_REDUCTION_ITEMS[item.itemID].DamageType or DMG_REDUCTION_ITEMS[item.itemID].DamageType == DamageType) then
						amount = amount * DMG_REDUCTION_ITEMS[item.itemID].amount(source, target, DamageType, amount)
					end
				end
			end
		end

		if target.champion_name == "Kassadin" and DamageType == 2 then
			amount = amount * (1 - 0.10)
		end
	end
	return amount
end

-- Spell Damage Database, extend it, if you want to add more spells. just copy paste the table and change the values.
DB.SpellDB = {
	["Jinx"] = {                                                                                                                                                                                                                                                                                                                                                                                  -- Last updated on 26.03.2023, patch 13.6 h2
		{ Slot = "Q", Stage = 1, DamageType = 1,
			                                         Damage = function(source, target, level) return 0.1 *
				source:get_attack_damage() end },
		{ Slot = "W", Stage = 1, DamageType = 1,
			                                         Damage = function(source, target, level) return ({ 10, 60, 110, 160, 210 })
				[level] + 1.6 * source:get_attack_damage() end },                                                                                                                                                                                                                                                                                                                                 -- 10 / 60 / 110 / 160 / 210 (+ 160% AD)
		{ Slot = "E", Stage = 1, DamageType = 2,
			                                         Damage = function(source, target, level) return ({ 70, 120, 170, 220, 270 })
				[level] + source:get_ability_power() end },                                                                                                                                                                                                                                                                                                                                       -- 70 / 120 / 170 / 220 / 270 (+ 100% AP)
		{ Slot = "R", Stage = 1, DamageType = 1,
			                                         Damage = function(source, target, level)
				local dmg = (({ 30, 45, 60 })[level] + (0.15 * source:get_bonus_attack_damage()) * (1.10 + (0.06 * math.min(math.floor(source.position:dist_to(target.position) / 100), 15)))) +
				(({ 25, 30, 35 })[level] / 100 * get_missing_hp(target));
				return dmg
			end },                                                                                                                                                                                                                                                                                                                                                                                -- Base damage
		{ Slot = "R", Stage = 2, DamageType = 1,
			                                         Damage = function(source, target, level)
				local dmg = (({ 24, 36, 48 })[level] + (0.12 * source:get_bonus_attack_damage()) * (1.10 + (0.06 * math.min(math.floor(source.position:dist_to(target.position) / 100), 15)))) +
				(({ 20, 24, 28 })[level] / 100 * get_missing_hp(target));
				if target:is_ai() then return math.min(1200, dmg) end
				;
				return dmg
			end },                                                                                                                                                                                                                                                                                                                                                                                -- Splash damage TODO: test if is_ai is the correct function to use.
	},
}



local get_aa_modifiers = function(source, target, targetIsMinion)
	local args = {
		source = source,
		Target = target,
		RawTotal = source.total_damage,
		RawPhysical = 0,
		RawMagical = 0,
		CalculatedTrue = 0,
		CalculatedPhysical = 0,
		CalculatedMagical = 0,
		DamageType = DAMAGE_TYPE_PHYSICAL,
		TargetIsMinion = targetIsMinion,
	}
	SetSpecialAADamageTable(args)
	local HashSet = {}
	for i = 1, #ItemSlots do
		local slot = ItemSlots[i]
		local item = args.source:GetItemData(slot)
		if item ~= nil and item.itemID > 0 then
			if HashSet[item.itemID] == nil then
				SetItemDamageTable(item.itemID, args)
				HashSet[item.itemID] = true
			end
		end
	end
	return args
end

local get_crit_percent = function(source)
	local baseCriticalDamage = 1.75
	local percentMod = 1
	local fixedMod = 0
	if Item:HasItem(source, "InfinityEdge") and source.critChance >= 0.40 then --Infinity Edge
		baseCriticalDamage = baseCriticalDamage + 0.35 or 2.10
	end
	if source.charName == "Akshan" then --TODO: additional shot after AA
		percentMod = 0.70
	elseif source.charName == "Ashe" then
		baseCriticalDamage = 1
	elseif source.charName == "Fiora" then
		baseCriticalDamage = ({ 1.60, 1.70, 1.80, 1.90, 2.00 })
		[source:get_spell_book():get_spell_slot(e_spell_slot.w).level]
	elseif source.charName == "Jhin" then
		percentMod = 0.86
	elseif source.charName == "Kalista" then
		percentMod = 0.90
	elseif source.charName == "Yasuo" then
		percentMod = 0.90
	elseif source.charName == "Yone" then
		percentMod = 0.90
	end
	local modCrit = baseCriticalDamage +
	(((Item:HasItem(source, "InfinityEdge")) and (source.critChance >= 0.40) and 0.35) or 0)                                    --TODO:
	return baseCriticalDamage * percentMod
end

local GetHeroAADamage = function(source, target, SpecialAA)
	local args = {
		source = source,
		Target = target,
		RawTotal = SpecialAA.RawTotal,
		RawPhysical = SpecialAA.RawPhysical,
		RawMagical = SpecialAA.RawMagical,
		CalculatedTrue = SpecialAA.CalculatedTrue,
		CalculatedPhysical = SpecialAA.CalculatedPhysical,
		CalculatedMagical = SpecialAA.CalculatedMagical,
		DamageType = SpecialAA.DamageType,
		TargetIsMinion = target:is_minion(),
		SourceIsMinion = source:is_minion(),
		TargetIsCamp = target:is_neutral_camp(),
		SourceIsCamp = source:is_neutral_camp(),
		TargetIsTurret = target:is_building(),
		SourceIsTurret = source:is_building(),
		TargetIsHero = target:is_hero(),
		SourceIsHero = source:is_hero(),
		CriticalStrike = false,
	}
	if args.TargetIsMinion and args.Target.maxHealth <= 6 then
		return 1
	end
	SetHeroPassiveDamageTable(args)
	if args.DamageType == DAMAGE_TYPE_PHYSICAL then
		args.RawPhysical = args.RawPhysical + args.RawTotal
	elseif args.DamageType == DAMAGE_TYPE_MAGICAL then
		args.RawMagical = args.RawMagical + args.RawTotal
	elseif args.DamageType == DAMAGE_TYPE_TRUE then
		args.CalculatedTrue = args.CalculatedTrue + args.RawTotal
	end
	if args.RawPhysical > 0 then
		args.CalculatedPhysical = args.CalculatedPhysical
			+ X.helper.calculate_damage(
				source,
				target,
				DAMAGE_TYPE_PHYSICAL,
				args.RawPhysical,
				true
			)
	end
	if args.RawMagical > 0 then
		args.CalculatedMagical = args.CalculatedMagical
			+ X.helper.calculate_damage(
				source,
				target,
				DAMAGE_TYPE_MAGICAL,
				args.RawMagical,
				true
			)
	end
	-- Focus passive for Doran items and Tear of the Goddess
	if args.TargetIsMinion then
		if args.Target.maxHealth > 6 then
			if Item:HasItem(source, "DoransRing") or Item:HasItem(source, "DoransShield") or Item:HasItem(source, "TearoftheGoddess") then
				args.CalculatedPhysical = args.CalculatedPhysical + 5
			end
		end
		--Spoils of War passive for Support items
		--TODO: charges? if buff
		if Item:HasItem(source, "RelicShield") or Item:HasItem(source, "SteelShoulderguards") then --Relic Shieldor --Steel Shoulderguards
			if IsMelee(source) then
				if get_percent_hp(target) < 50 then
					args.CalculatedPhysical = target.health + 999
				end
			elseif get_percent_hp(target) < 30 then
				args.CalculatedPhysical = target.health + 999
			end
		elseif Item:HasItem(source, "TargonsBuckler") or Item:HasItem(source, "RunesteelSpaulders") then --Targon's Buckler --Runesteel Spaulders
			if get_percent_hp(target) < 50 then
				args.CalculatedPhysical = target.health + 999
			end
		end
	end
	local percentMod = 1
	if args.source.critChance - 1 == 0 or args.CriticalStrike then
		percentMod = percentMod * get_crit_percent(args.source)
	end
	return percentMod * args.CalculatedPhysical + args.CalculatedMagical + args.CalculatedTrue
end

X.helper.calculate_damage = function(source, target, DamageType, amount, IsAA)
	local base_resist = 0
	local bonus_resist = 0
	local lethality = (0.6222 + 0.3778 / 17 * (source.level - 1))
	local flatPen = 0
	local percentPen = 0
	local bonuspercentPen = 0

	if DamageType == nil then
		local AD = source:get_attack_damage()
		local AP = source:get_ability_power()
		if AD > AP then
			DamageType = DAMAGE_TYPE_PHYSICAL
		elseif AP > AD then
			DamageType = DAMAGE_TYPE_MAGICAL
		end
	end

	if DamageType == DAMAGE_TYPE_PHYSICAL then
		base_resist = math.max(target.total_armor - target.bonus_armor, 0)
		bonus_resist = target.bonus_armor
		flatPen = source.get_lethality * lethality
		percentPen = source.armorPenPercent
		bonuspercentPen = source.bonusArmorPenPercent
	elseif DamageType == DAMAGE_TYPE_MAGICAL then
		-- TODO
		return amount
	elseif DamageType == DAMAGE_TYPE_TRUE then
		return amount
	end

	local resist = base_resist + bonus_resist
	if resist > 0 then
		if percentPen > 0 then
			base_resist = base_resist * percentPen
			bonus_resist = bonus_resist * percentPen
		end
		if bonuspercentPen > 0 then
			bonus_resist = bonus_resist * bonuspercentPen
		end
		resist = base_resist + base_resist
		resist = resist - flatPen
	end

	local post_mitigation = 1
	if resist >= 0 then
		post_mitigation = post_mitigation * (100 / (100 + resist))
	else
		post_mitigation = post_mitigation * (2 - 100 / (100 - resist))
	end

	local flatPassive = 0
	if target:is_hero() then
		if target.champion_name == "Fizz" then
			flatPassive = flatPassive - (4 + 0.01 * source:get_ability_power()) --TODO 50% max reduction
		elseif target.champion_name == "Leona" and get_buff_data(target, "LeonaSolarBarrier") then
			flatPassive = flatPassive -
			(({ 8, 12, 16, 20, 24 })[target:get_spell_book():get_spell_slot(e_spell_slot.w).level or 1])
		elseif target.champion_name == "Amumu" and get_buff_data(target, "Tantrum") then
			flatPassive = flatPassive -
			(({ 5, 7, 9, 11, 13 })[target:get_spell_book():get_spell_slot(e_spell_slot.e).level or 1] + (0.03 * target.bonus_mr) + (0.03 * target.bonus_armor))                 --TODO: max 50%
		end
		if GetItemSlot(target, 2051) > 0 then                                                                                                                                   -- Guardian's Horn // 2051
			flatPassive = flatPassive - 15
		end
	end
	local bonusPercent = 1
	local flatreduction = 0
	if target:is_minion() then
		flatreduction = flatreduction - target.flatDamageReduction
	end

	return math.max(
	math.floor(bonusPercent *
	DamageReductionMod(source, target, DamageType,
	PassivePercentMod(source, target, DamageType, post_mitigation) * (amount + flatPassive)) + flatreduction), 0)
end

X.helper.Slot_to_letter = function(slot)
	local letters = { "Q", "W", "E", "R" }
	local letter = letters[slot + 1]
	print(tostring(slot) .. " --> " .. tostring(letter))
	return letter
end

X.helper.get_aa_damage = function(source, target, respectPassives)
	local targetIsMinion = target:is_minion();
	local sourceIsHero = source:is_hero();
	if respectPassives == nil then
		respectPassives = true
	end
	if source == nil or target == nil then
		return 0
	end
	if respectPassives and sourceIsHero then
		return GetHeroAADamage(source, target, SPECIAL_AA(source, target, targetIsMinion))
	end
	print("can we even see helper???")
	return X.helper.calculate_damage(source, target, DAMAGE_TYPE_PHYSICAL, source.totalDamage, true)
end


X.helper.get_spell_damage = function(spell, target, source, stage, level)
	local source = source or g_local
	local stage = stage or 1

	local dmgtable = {}
	if spell == "Q" or spell == "W" or spell == "E" or spell == "R" or spell == "QM" or spell == "WM" or spell == "EM" and source:is_hero() then
		local level = level or
		source:get_spell_book():get_spell_slot(({ ["Q"] = e_spell_slot.q,["QM"] = e_spell_slot.q,["W"] = e_spell_slot.w,
			["WM"] = e_spell_slot.w,["E"] = e_spell_slot.e,["EM"] = e_spell_slot.e,["R"] = e_spell_slot.r })[spell])
		.level
		if level <= 0 then return 0 end
		if level > 6 then level = 6 end
		if DB.SpellDB[source.champion_name] then
			for i, spells in pairs(DB.SpellDB[source.champion_name]) do
				if spells.Slot == spell then
					table.insert(dmgtable, spells)
				end
			end
			if stage > #dmgtable then stage = #dmgtable end
			for v = #dmgtable, 1, -1 do
				local spells = dmgtable[v]
				if spells.Stage == stage then
					return X.helper.calculate_damage(source, target, spells.DamageType,
					spells.Damage(source, target, level), false)
				end
			end
		end
	end
	if spell == "AA" then
		local aa_mod = get_aa_modifiers(source, target:is_minion()) --and targetIsMinion --target.type == Obj_AI_Minion
		return GetAADamage(source, target, aa_mod)            --(source, target)
	end
	return 0
end

local xCore = { DB = DB, X = X }
return xCore
