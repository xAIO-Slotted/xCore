local std_math = math

--------------------------------------------------------------------------------

local font = 'corbel'
local myHero = g_local

--------------------------------------------------------------------------------

local function class(properties, ...)
	local cls = {}
	cls.__index = cls

	for k, v in pairs(properties) do
		cls[k] = v
	end

	for _, property in ipairs({...}) do
		for k, v in pairs(property) do
			cls[k] = v
		end
	end

	function cls:new(...)
		local instance = setmetatable({}, cls)
		if self.init then
			self:init(...)
		end
		return instance
	end

	return cls
end

--------------------------------------------------------------------------------

-- Math
--------------------------------------------------------------------------------

local math = class({

	xHelper = nil,
	buffcache = nil,

	init = function(self, xHelper, buff_cache)
		self.xHelper = xHelper
		self.buffcache = buff_cache
	end,

	dis = function(self, p1, p2)
		return std_math.sqrt(self:DistanceSqr(p1, p2))
	end,

	dis_sq = function(self, p1, p2)
		local dx, dy = p2.x - p1.x, p2.z - p1.z
		return dx * dx + dy * dy
	end,

	angle_between = function(self, p1, p2, p3)
		local angle = std_math.deg(
				std_math.atan(p3.z - p1.z, p3.x - p1.x) -
						std_math.atan(p2.z - p1.z, p2.x - p1.x))
		if angle < 0 then angle = angle + 360 end
		return angle > 180 and 360 - angle or angle
	end,

	is_facing = function(self, source, unit)
		local dir = source.direction
		local angle = self:angle_between(source, unit, dir)
		return angle < 90
	end,

	in_aa_range = function(self, unit, raw)
		local range = self.xHelper:get_aa_range()
		local hitbox = unit:get_bounding_radius() or 80

		if myHero.champion_name == "Aphelios" and unit:is_hero() and self.buffcache:has_buff(unit, "aphelioscalibrumbonusrangedebuff") then
			range, hitbox = 1800, 0
		elseif myHero.champion_name == "Caitlyn" and (self.buffcache:has_buff(unit, "caitlynwsight") or self.buffcache:has_buff(unit, "CaitlynEMissile")) then
			range = range + 650
		elseif myHero.champ_name == "Zeri" and myHero:get_spell_book():get_spell_slot(e_spell_slot.q):is_ready() then
			range, hitbox = 825, 0
		elseif myHero.champ_name == "Samira" and features.buff_cache:is_immobile(unit.index) then
			range = std_math.min(650 + 77.5 * (myHero.level - 1), 960)
		elseif myHero.champ_name == "Karthus" then
			range = 1035
		end
		if raw and not self.xHelper:is_melee(myHero) then
			hitbox = 0
		end
		local dist = self:dis_sq(myHero.position, unit.position)
		return dist <= (range + hitbox) ^ 2
	end,

})

--------------------------------------------------------------------------------

-- Objects
--------------------------------------------------------------------------------

local objects = class({

	xHelper = nil,
	math = nil,

	init = function(self, xHelper, math)
		self.xHelper = xHelper
		self.math = math
	end,

	get_enemy_champs = function(self, range)
		local enemy_champs = {}
		for i, unit in ipairs(features.entity_list:get_enemies()) do
			if self.xHelper:is_valid(unit) and (range and self.math:dis_sq(myHero.position, unit.position) <= range ^ 2 or self.math:in_aa_range(unit, true)) then
				table.insert(enemy_champs, unit)
			end
		end
		return enemy_champs
	end,


})

--------------------------------------------------------------------------------

-- Buffs
--------------------------------------------------------------------------------
local buffcache = class({

	get_buff = function(self, unit, name)
		return features.buff_cache:get_buff(unit.index, name)
	end,

	get_amount = function(self, unit, name)
		return features.buff_cache:get_buff(unit.index, name).amount
	end,

	get_duration = function(self, unit, name)
		local buff = features.buff_cache:get_buff(unit.index, name)
		return buff.end_time - buff.start_time
	end,

	has_buff = function(self, unit, name)
		return features.buff_cache:get_buff(unit.index, name)
	end,

})

--------------------------------------------------------------------------------

-- Helper
--------------------------------------------------------------------------------

local xHelper = class({

	HYBRID_RANGED = {"Elise", "Gnar", "Jayce", "Kayle", "Nidalee", "Zeri"},
	INVINCIBILITY_BUFFS= {
		["aatroxpassivedeath"] = true, ["FioraW"] = true,
		["JaxCounterStrike"] = true, ["JudicatorIntervention"] = true,
		["KarthusDeathDefiedBuff"] = true, ["kindredrnodeathbuff"] = false,
		["KogMawIcathianSurprise"] = true, ["SamiraW"] = true, ["ShenWBuff"] = true,
		["TaricR"] = true, ["UndyingRage"] = false, ["VladimirSanguinePool"] = true,
		["ChronoShift"] = false, ["chronorevive"] = true, ["zhonyasringshield"] = true
	},

	buffcache = nil,

	init = function(self, buffcache)
		self.buffcache = buffcache
	end,

	is_melee = function(self, unit)
		return unit.attack_range < 300
				and self.HYBRID_RANGED[unit.champion_name] ~= nil
	end,

	get_aa_range = function(self, unit)
		local unit = unit or myHero
		if (unit.champion_name == "Karthus") then
			return 1035 + unit:get_bounding_radius()
		end
		return unit.attack_range + unit:get_bounding_radius()
	end,

	is_invincible = function(self, unit)
		for _, buff in ipairs(features.buff_cache:get_all_buffs(unit.index)) do
			if buff and self.buffcache:get_duration(unit, buff.name) > 0 and buff:get_amount() > 0 then
				local invincibility_buff = self.INVINCIBILITY_BUFFS[buff.name]
				if invincibility_buff ~= nil then
					if invincibility_buff == false and unit.health / unit.max_health < 0.05 then
						return true
					elseif invincibility_buff == true then
						return true
					end
				end
			end
		end
		return false
	end,

	get_percent_hp = function(self, unit)
		return 100 * unit.health / unit.max_health
	end,

	get_percent_missing_hp = function(self, unit)
		return (1 - (unit.health / unit.max_health)) * 100
	end,

	get_missing_hp = function(self, unit)
		return (unit.max_health - unit.health)
	end,

	is_alive = function(self, unit)
		return unit and not unit:is_invalid_object() and unit:is_visible()
				and unit:is_alive() and unit:is_targetable() and not self.buffcache:has_buff(unit, "sionpassivezombie")
	end,

	is_valid = function(self, unit)
		return unit and not unit:is_invalid_object() and unit:is_visible()
				and unit:is_alive() and unit:is_targetable()
	end,

	get_latency = function(self)
		return features.orbwalker:get_ping() / 1000
	end

})

--------------------------------------------------------------------------------

-- Damage Library
--------------------------------------------------------------------------------

local damagelib = class({

	xHelper = nil,
	math = nil,
	database = nil,
	buffcache = nil,

	CHAMP_PASSIVES = {
		Jinx = function(self, args) local source = args.source -- 13.7
			if not self.buffcache:has_buff(source, "JinxQ") then return end
			args.raw_physical = args.raw_physical
					+ source:get_attack_damage() * 0.1
		end,
	},
	ITEM_PASSIVES = { -- TODO: wait for inventory api to be added.
		[3153] = function(self, args) local source = args.source -- Blade of the Ruined King
			local mod = self.functions.xHelper:is_melee(source) and 0.12 or 0.08
			args.raw_physical = args.raw_physical + std_math.min(
					60, std_math.max(15, mod * args.unit.health))
		end,
		[3742] = function(self, args) local source = args.source -- Dead Man's Plate
			local stacks = std_math.min(100, 0) -- TODO
			args.raw_physical = args.raw_physical + 0.4 * stacks
					+ 0.01 * stacks * source:get_attack_damage()
		end,
		[1056] = function(self, args) -- Doran's Ring
			args.raw_physical = args.raw_physical + 5
		end,
		[1054] = function(self, args) -- Doran's Shield
			args.raw_physical = args.raw_physical + 5
		end,
		[3124] = function(self, args) local source = args.source -- Guinsoo's Rageblade
			args.raw_physical = args.raw_physical +
					std_math.min(200, source.crit_chance * 200)
		end,
		[3004] = function(self, args) -- Manamune
			args.raw_physical = args.raw_physical
					+ args.source.max_mana * 0.025
		end,
		[3042] = function(self, args) -- Muramana
			args.raw_physical = args.raw_physical
					+ args.source.max_mana * 0.025
		end,
		[3115] = function(self, args) -- Nashor's Tooth
			args.raw_magical = args.raw_magical + 15
					+ 0.2 * args.source:get_ability_power()
		end,
		[6670] = function(self, args) -- Noonquiver
			args.raw_physical = args.raw_physical + 20
		end,
		[6677] = function(self, args) local source = args.source -- Rageknife
			args.raw_physical = args.raw_physical +
					std_math.min(175, 175 * source.crit_chance)
		end,
		[1043] = function(self, args) -- Recurve Bow
			args.raw_physical = args.raw_physical + 15
		end,
		[3070] = function(self, args) -- Tear of the Goddess
			args.raw_physical = args.raw_physical + 5
		end,
		[3748] = function(self, args) local source = args.source -- Titanic Hydra
			local mod = self.functions.xHelper:is_melee(args.source) and {4, 0.015} or {3, 0.01125}
			local damage = mod[1] + mod[2] * args.source.max_health
			args.raw_physical = args.raw_physical + damage
		end,
		[3091] = function(self, args) local source = args.source -- Wit's End
			local damage = ({15, 15, 15, 15, 15, 15, 15, 15, 25, 35,
							 45, 55, 65, 75, 76.25, 77.5, 78.75, 80})[source.level]
			args.raw_magical = args.raw_magical + damage
		end
	},


	init = function(self, xHelper, math, database, buffcache)
		self.xHelper = xHelper
		self.math = math
		self.database = database
		self.buffcache = buffcache
	end,

	check_for_passives = function(self, args)
		local source = args.source
		local buff = self.buffcache:get_buff(source, "6672buff") -- Kraken Slayer
		if buff and buff:get_amount() == 3 then
			args.true_damage = args.true_damage + 50 +
					0.4 * source:get_bonus_attack_damage()
		end
		if self.buffcache:has_buff(source, "3504Buff") then -- Ardent Censer
			args.raw_magical = args.raw_magical + 4.12 + 0.88 * args.unit.level
		end
		if self.buffcache:has_buff(source, "6632buff") then -- Divine Sunderer
			args.raw_physical = args.raw_physical + 1.25 *
					source:get_attack_damage() + (self.functions.xHelper:is_melee(source)
					and 0.06 or 0.03) * args.unit.max_health
		end

		if self.buffcache:has_buff(source, "3508buff") then -- Essence Reaver
			args.raw_physical = args.raw_physical + 0.4 *
					source:get_bonus_attack_damage() + source:get_attack_damage()
		end

		if self.buffcache:has_buff(source, "lichbane") then -- Lich Bane
			args.raw_magical = args.raw_magical + 0.75 *
					source:get_attack_damage() + 0.5 * source:get_ability_power()
		end

		if self.buffcache:has_buff(source, "sheen") then
			args.raw_physical = args.raw_physical + source:get_attack_damage()
		end

		if self.buffcache:has_buff(source, "3078trinityforce") then -- Trinity Force
			args.raw_physical = args.raw_physical + 2 * source:get_attack_damage()
		end

		if self.buffcache:get_buff(source, "item6664counter") then 
			if self.buffcache:get_buff(source, "item6664counter"):get_amount() == 100 then -- Turbo Chemtank -- line 350
				local damage = 35.29 + 4.71 * source.level + 0.01 *
						source.max_health + 0.03 * source.movement_speed
				args.raw_magical = args.raw_magical + damage * 1.3
			end
		end

		local buff = self.buffcache:get_buff(source, "itemstatikshankcharge")
		local damage = buff and buff:get_amount() == 100 and 0 or 0

		if buff then -- Kircheis Shard, Rapid Firecannon, Stormrazor
			damage = buff:get_amount() == 100 and 80 or 0
		end

		args.raw_magical = args.raw_magical + damage
	end,

	calc_aa_dmg = function(self, source, target)
		local idx = target.index
		local name = source.champion_name.text
		local physical = source:get_attack_damage()
		local args = {raw_magical = 0, raw_physical = physical,true_damage = 0, source = source, unit = features.entity_list:get_by_index(idx)}
		if name == "Corki" and physical > 0 then return
			self:calc_mixed_dmg(source, features.entity_list:get_by_index(idx), physical) end
			local items = {}
			for i = 6, 12 do
				local slot = i
				local item = source:get_spell_book():get_spell_slot(slot)
				items[#items + 1] = item
		end

		self:check_for_passives(args) -- TODO: check if this is correct
		if self.CHAMP_PASSIVES[name] then self.CHAMP_PASSIVES[name](self, args) end

		local magical = self:calc_ap_dmg(source, features.entity_list:get_by_index(idx), args.raw_magical)
		local physical = self:calc_ad_dmg(source, features.entity_list:get_by_index(idx), args.raw_physical)

		return magical + physical + args.true_damage
	end,

	calc_dmg = function(self, source, target, amount)
		return source:get_ability_power() > source:get_attack_damage()
				and self:calc_ap_dmg(source, target, amount)
				or self:calc_ad_dmg(source, target, amount)
	end,

	calc_ap_dmg = function(self, source, target, amount)
		return helper.calculate_damage(amount, target.index, false)
	end,

	calc_ad_dmg = function(self, source, target, amount)
		return helper.calculate_damage(amount, target.index, true)
	end,

	calc_spell_dmg = function(self, spell, source, target, stage, level)
		local source = source or myHero
		local stage = stage or 1
		local cache = {}

		if stage > 4 then stage = 4 end

		if spell == "Q" or spell == "W" or spell == "E" or spell == "R" or spell == "QM" or spell == "WM" or spell == "EM" then
			local level = level or
					source:get_spell_book():get_spell_slot((
							{ ["Q"] = e_spell_slot.q, ["QM"] = e_spell_slot.q, ["W"] = e_spell_slot.w, ["WM"] = e_spell_slot.w, ["E"] = e_spell_slot.e, ["EM"] = e_spell_slot.e, ["R"] = e_spell_slot.r }
					)[spell]).level

			if level <= 0 then return 0 end
			if level > 5 then level = 5 end
			
					
					
			if self.database.DMG_LIST[source.champion_name.text:lower()] then
				for _, spells in ipairs(self.database.DMG_LIST[source.champion_name.text:lower()]) do
					if spells.slot == spell then
						table.insert(cache, spells)
					end
				end
				
				if stage > #cache then stage = #cache end
				
				for v = #cache, 1, -1 do
					local spells = cache[v]
					if spells.stage == stage then
						local dmg = spells.damage(self, source, target, level)
						return self:calc_dmg(source, target, dmg)
					end
				end
			end
		end

		if spell == "AA" then
			return self:calc_aa_dmg(source, target)
		end

		if spell == "IGNITE" then
			return 50 + 20 * source.level - (target.total_health_regen * 3)
		end

		if spell == "SMITE" then

			if stage == 1 then
				if target:is_hero() then
					return 0
				end
				return 600 -- Smite
			end

			if stage == 2 then
				if target:is_hero() then
					return 80 + 80 / 17 * (source.level - 1)
				end
				return 900
			end

			if stage == 3 then
				if target:is_hero() then
					return 80 + 80 / 17 * (source.level - 1)
				end
				return 1200
			end
		end

		return 0
	end,

})

--------------------------------------------------------------------------------

-- Database
--------------------------------------------------------------------------------

local database = class({

	xHelper = nil,

	init = function(self, xHelper)
		self.xHelper = xHelper
	end,

	DASH_LIST = {
		Rakan = {e_spell_slot.w, e_spell_slot.e},
		Renekton = {e_spell_slot.e},
		Nocturne = {e_spell_slot.r},
		Caitlyn = {e_spell_slot.e},
		Poppy = {e_spell_slot.e},
		Zeri = {e_spell_slot.e},
		Samira = {e_spell_slot.e},
		Talon = {e_spell_slot.q, e_spell_slot.e},
		Thresh = {e_spell_slot.q},
		Tristana = {e_spell_slot.w},
		Tryndamere = {e_spell_slot.e},
		Riven = {e_spell_slot.q1, e_spell_slot.q2, e_spell_slot.q3, e_spell_slot.e},
		Urgot = {e_spell_slot.e},
		Shaco = {e_spell_slot.q},
		Xinzhao = {e_spell_slot.e},
		Yasuo = {e_spell_slot.e},
		Gnar = {e_spell_slot.e},
		Jayce = {e_spell_slot.q},
		Shen = {e_spell_slot.e},
		Aatrox = {e_spell_slot.e},
		Shyvana = {e_spell_slot.r},
		Akali = {e_spell_slot.e, e_spell_slot.r},
		Sylas = {e_spell_slot.e},
		Monkeyking = {e_spell_slot.w, e_spell_slot.e},
		Vayne = {e_spell_slot.q},
		Vex = {e_spell_slot.r},
		Vi = {e_spell_slot.q},
		Viego = {e_spell_slot.w},
		Zac = {e_spell_slot.e},
		Volibear = {e_spell_slot.r},
		Diana = {e_spell_slot.e},
		Warwick = {e_spell_slot.q, e_spell_slot.r},
		Rell = {e_spell_slot.w},
		Elise = {e_spell_slot.q},
		Ekko = {e_spell_slot.e},
		Corki = {e_spell_slot.w},
		Yone = {e_spell_slot.q, e_spell_slot.r},
		Fiddlesticks = {e_spell_slot.r},
		Camille = {e_spell_slot.e},
		Zed = {e_spell_slot.w, e_spell_slot.r},
		Fizz = {e_spell_slot.q},
		Galio = {e_spell_slot.e},
		Amumu = {e_spell_slot.q},
		Garen = {e_spell_slot.q},
		Alistar = {e_spell_slot.w},
		Malphite = {e_spell_slot.r},
		Gragas = {e_spell_slot.e},
		Ahri = {e_spell_slot.r},
		Gwen = {e_spell_slot.e},
		Illaoi = {e_spell_slot.w},
		Sejuani = {e_spell_slot.q},
		Irelia = {e_spell_slot.q},
		Ziggs = {e_spell_slot.w},
		Azir = {e_spell_slot.e},
		Belveth = {e_spell_slot.q},
		Jax = {e_spell_slot.q},
		Yuumi = {e_spell_slot.w},
		Evelynn = {e_spell_slot.e},
		Ezreal = {e_spell_slot.e},
		Nidalee = {e_spell_slot.w},
		Fiora = {e_spell_slot.q},
		Quinn = {e_spell_slot.e},
		Jarvaniv = {e_spell_slot.q, e_spell_slot.r},
		Kaisa = {e_spell_slot.r},
		Ksante = {e_spell_slot.w, e_spell_slot.e, e_spell_slot.r},
		Ivern = {e_spell_slot.q},
		Kassadin = {e_spell_slot.r},
		Kalista  = {e_spell_slot.q},
		Braum = {e_spell_slot.w},
		Katarina = {e_spell_slot.e},
		Kayn = {e_spell_slot.q},
		KhaZix = {e_spell_slot.e},
		Kindred = {e_spell_slot.q},
		Leona = {e_spell_slot.e},
		MasterYi = {e_spell_slot.q},
		Leblanc = {e_spell_slot.w, e_spell_slot.r},
		LeeSin = {e_spell_slot.q, e_spell_slot.w},
		Lillia = {e_spell_slot.w},
		Lissandra = {e_spell_slot.e},
		Lucian = {e_spell_slot.e},
		Graves = {e_spell_slot.e},
		Pyke = {e_spell_slot.e},
		Maokai = {e_spell_slot.w},
		Kled = {e_spell_slot.e},
		Hecarim = {e_spell_slot.e, e_spell_slot.r},
		Nilah = {e_spell_slot.e},
		RekSai = {e_spell_slot.e, e_spell_slot.r},
		-- Rengar? passive TODO
		Orrn = {e_spell_slot.e},
		Pantheon = {e_spell_slot.w},
		Nautilus = {e_spell_slot.q},
		Qiyana = {e_spell_slot.w, e_spell_slot.e},
		Sion = {e_spell_slot.e},
	},

	DMG_LIST = {
		jinx = { -- 13.6
			{ slot = "Q", stage = 1, damage_type = 1,
			  damage = function(self, source, target, level) return 0.1 * source:get_attack_damage() end },
			{ slot = "W", stage = 1, damage_type = 1, damage = function(self, source, target, level) return ({ 10, 60, 110, 160, 210 })[level] + 1.6 * source:get_attack_damage() end },
			{ slot = "E", stage = 1, damage_type = 2,
			  damage = function(self, source, target, level) return ({ 70, 120, 170, 220, 270 })[level] + source:get_ability_power() end },
			{ slot = "R", stage = 1, damage_type = 1,
			  damage = function(self, source, target, level)
				  local dmg = (({ 30, 45, 60 })[level] + (0.15 * source:get_bonus_attack_damage()) * (1.10 + (0.06 * std_math.min(std_math.floor(source.position:dist_to(target.position) / 100), 15)))) +
						  (({ 25, 30, 35 })[level] / 100 * self.xHelper:get_missing_hp(target));
				  return dmg
			  end },
			{ slot = "R", stage = 2, damage_type = 1,
			  damage = function(self, source, target, level)
				  local dmg = (({ 24, 36, 48 })[level] + (0.12 * source:get_bonus_attack_damage()) * (1.10 + (0.06 * std_math.min(std_math.floor(source.position:dist_to(target.position) / 100), 15)))) +
						  (({ 20, 24, 28 })[level] / 100 * self.xHelper:get_missing_hp(target));
				  if target:is_ai() then return std_math.min(1200, dmg) end
				  ;
				  return dmg
			  end },
		},

		sion = { -- 13.6
			{ slot = "Q", stage = 1, damage_type = 1,
			  damage = function(self, source, target, level) return ({ 40, 60, 80, 100, 120 })[level] +
					  ({ 45, 52, 60, 67, 75 })[level] / 100 * source:get_attack_damage()
			  end },
			{ slot = "W", stage = 1, damage_type = 2,
			  damage = function(self, source, target, level) return ({ 40, 65, 90, 115, 140 })[level] + 0.4 * source:get_ability_power() +
					  ({ 10, 11, 12, 13, 14 })[level] / 100 * target.max_health
			  end },
			{ slot = "E", stage = 1, damage_type = 2,
			  damage = function(self, source, target, level) return ({ 65, 100, 135, 170, 205 })[level] + 0.55 * source:get_ability_power() end },
			{ slot = "R", stage = 1, damage_type = 1,
			  damage = function(self, source, target, level) return ({ 150, 300, 450 })[level] + 0.4 * source:get_bonus_attack_damage() end },
		},
	},

	has_dash = function(self, unit)
		if self.DASH_LIST[unit.champion_name.text] == nil then return false end
		return true
	end,

	has_dash_available = function(self, unit)
		local champion = unit.champion_name.text
		local dash_spells = self.DASH_LIST[champion]

		if not dash_spells then
			return false
		end

		for _, slot in ipairs(dash_spells) do
			if unit:get_spell_book():get_spell_slot(slot):is_ready() then
				return true
			end
		end

		return false
	end,

})

--------------------------------------------------------------------------------

-- Target Selector // very experimental and wip. needs to be improved.
--------------------------------------------------------------------------------

local Weight = {}
Weight.__index = Weight

function Weight.new(distance, damage, priority, health)
	local self = setmetatable({}, Weight)
	self.distance = distance
	self.damage = damage
	self.priority = priority
	self.health = health
	self.total = 0
	return self
end

local Target = {}
Target.__index = Target

function Target.new(unit, weight)
	local self = setmetatable({}, Target)
	self.unit = unit
	self.weight = weight
	return self
end

local target_selector = class({

	xHelper = nil,
	math = nil,
	objects = nil,
	damagelib = nil,

	add = menu.get_main_window():push_navigation("target selector", 10000) ,
	nav = menu.get_main_window():find_navigation("target selector"),

	ts_sec = nil,
	ts_enabled = false,
	drawings_sec = nil,
	debug_sec = nil,
	weight_sec = nil,

	focus_target = true,
	draw_target = true,
	draw_weight = false,
	weight_mode = true,

	weight_dis = 0,
	weight_dmg = 0,
	weight_prio = 0,
	weight_hp = 0,

	

	init = function(self, xHelper, math, objects, damagelib)

		self.xHelper = xHelper
		self.math = math
		self.objects = objects
		self.damagelib = damagelib

		self.ts_sec = self.nav:add_section("target selector")
		self.drawings_sec = self.nav:add_section("drawings")
		self.debug_sec = self.nav:add_section("debug")
		self.weight_sec = self.nav:add_section("weight")

		self.ts_enabled = self.ts_sec:checkbox("enabled", g_config:add_bool(true, "ts_enabled"))
		print("inti: ts_enabled: " .. tostring(self.ts_enabled))
		self.focus_target = self.ts_sec:checkbox("click to focus", g_config:add_bool(true, "focus_target"))

		self.draw_target = self.drawings_sec:checkbox("visualize targets", g_config:add_bool(true, "draw_targets"))

		self.draw_weight = self.debug_sec:checkbox("draw weight", g_config:add_bool(false, "draw_weight"))

		self.weight_mode = self.weight_sec:checkbox("use weight mode", g_config:add_bool(true, "weight_mode"))

		self.debug_sec:button("made w/ love by ampx", function() end)

		self.weight_dis = self.weight_sec:slider_int("distance", g_config:add_int(10, "weight_distance"), 0, 100, 1)
		self.weight_dmg = self.weight_sec:slider_int("damage", g_config:add_int(10, "weight_damage"), 0, 100, 1)
		self.weight_prio = self.weight_sec:slider_int("priority", g_config:add_int(10, "weight_priority"), 0, 100, 1)
		self.weight_hp = self.weight_sec:slider_int("health", g_config:add_int(15, "weight_health"), 0, 100, 1)

	end,
	GET_STATUS = function(self)
		return self.ts_enabled:get_value()
	end,
	FORCED_TARGET = nil,
	PRIORITY_LIST = {
		Aatrox = 3, Ahri = 4, Akali = 4, Akshan = 5, Alistar = 1,
		Amumu = 1, Anivia = 4, Annie = 4, Aphelios = 5, Ashe = 5,
		AurelionSol = 4, Azir = 4, Bard = 3, Belveth = 3, Blitzcrank = 1,
		Brand = 4, Braum = 1, Caitlyn = 5, Camille = 4, Cassiopeia = 4,
		Chogath = 1, Corki = 5, Darius = 2, Diana = 4, DrMundo = 1,
		Draven = 5, Ekko = 4, Elise = 3, Evelynn = 4, Ezreal = 5,
		FiddleSticks = 3, Fiora = 4, Fizz = 4, Galio = 1, Gangplank = 4,
		Garen = 1, Gnar = 1, Gragas = 2, Graves = 4, Gwen = 3,
		Hecarim = 2, Heimerdinger = 3, Illaoi = 3, Irelia = 3,
		Ivern = 1, Janna = 2, JarvanIV = 3, Jax = 3, Jayce = 4,
		Jhin = 5, Jinx = 5, Kaisa = 5, Kalista = 5, Karma = 4,
		Karthus = 4, Kassadin = 4, Katarina = 4, Kayle = 4, Kayn = 4,
		Kennen = 4, Khazix = 4, Kindred = 4, Kled = 2, KogMaw = 5, KSante = 2,
		Leblanc = 4, LeeSin = 3, Leona = 1, Lillia = 4, Lissandra = 4,
		Lucian = 5, Lulu = 3, Lux = 4, Malphite = 1, Malzahar = 3,
		Maokai = 2, MasterYi = 5, Milio = 3, MissFortune = 5, MonkeyKing = 3,
		Mordekaiser = 4, Morgana = 3, Nami = 3, Nasus = 2, Nautilus = 1,
		Neeko = 4, Nidalee = 4, Nilah = 5, Nocturne = 4, Nunu = 2,
		Olaf = 2, Orianna = 4, Ornn = 2, Pantheon = 3, Poppy = 2,
		Pyke = 4, Qiyana = 4, Quinn = 5, Rakan = 3, Rammus = 1,
		RekSai = 2, Rell = 5, Renata = 3, Renekton = 2, Rengar = 4,
		Riven = 4, Rumble = 4, Ryze = 4, Samira = 5, Sejuani = 2,
		Senna = 5, Seraphine = 4, Sett = 2, Shaco = 4, Shen = 1,
		Shyvana = 2, Singed = 1, Sion = 1, Sivir = 5, Skarner = 2,
		Sona = 3, Soraka = 4, Swain = 3, Sylas = 4, Syndra = 4,
		TahmKench = 1, Taliyah = 4, Talon = 4, Taric = 1, Teemo = 4,
		Thresh = 1, Tristana = 5, Trundle = 2, Tryndamere = 4,
		TwistedFate = 4, Twitch = 5, Udyr = 2, Urgot = 2, Varus = 5,
		Vayne = 5, Veigar = 4, Velkoz = 4, Vex = 4, Vi = 2,
		Viego = 4, Viktor = 4, Vladimir = 3, Volibear = 2, Warwick = 2,
		Xayah = 5, Xerath = 4, Xinzhao = 3, Yasuo = 4, Yone = 4,
		Yorick = 2, Yuumi = 2, Zac = 1, Zed = 4, Zeri = 5,
		Ziggs = 4, Zilean = 3, Zoe = 4, Zyra = 3
	},
	TARGET_CACHE = {},
	WEIGHT_CACHE = {
		function(self,a, b)
			return b.health / a.health
		end
	},

	get_cache = function(self, range)
		return self.TARGET_CACHE[range]
	end,
	refresh_targets = function(self, range)
		if not self.TARGET_CACHE[range] then
			self.TARGET_CACHE[range] = {enemies = {}}
		end
	
		local all_enemies = self.objects:get_enemy_champs(range)
		local enemies = {}
	
		for _, enemy in ipairs(all_enemies) do
			if not self.xHelper:is_invincible(enemy) then
				table.insert(enemies, enemy)
			end
		end
	
		for i = 1, #enemies do
			local weight = {total = 0}
			for j = 1, #enemies do
				if i ~= j then
					for k, func in ipairs(self.WEIGHT_CACHE) do
						weight[k] = (weight[k] or 0) + func(self, enemies[i], enemies[j])
					end
				end
			end
	
			local target = self.TARGET_CACHE[range].enemies[i] or {}
			local new_weight = {}
	
			local d = self.math:dis_sq(myHero.position, enemies[i].position)
			local w = 10000 / (1 + std_math.sqrt(d))
			if not self.xHelper:is_melee(enemies[i]) then w = w * self.weight_dis:get_value() / 10 else w = w * (self.weight_dis:get_value() / 10 + 1) end
	
			local factor = { damage = self.weight_dmg:get_value(), prio = self.weight_prio:get_value() / 10, health = self.weight_hp:get_value() / 10 }
			new_weight.damage = (self.damagelib:calc_dmg(myHero, enemies[i], 100) / (1 + enemies[i].health) * 20) * factor.damage
			local mod = {1, 1.5, 1.75, 2, 2.5}
			new_weight.priority = mod[self.PRIORITY_LIST[enemies[i].champion_name] or 3] * factor.prio
			new_weight.health = (weight[2] or 0) * factor.health * factor.health
			new_weight.total = w + new_weight.damage + new_weight.priority + new_weight.health
			if not target.target or new_weight.total ~= target.weight.total then
				target.target = enemies[i]
				target.weight = new_weight
				self.TARGET_CACHE[range].enemies[i] = target
			end
		end
	
		table.sort(self.TARGET_CACHE[range].enemies, function(a, b) return a.weight.total > b.weight.total end)
	
		if not self.FORCED_TARGET == nil then
			local target = self.FORCED_TARGET
			local new_weight = {}
			new_weight.distance = 1000000
			new_weight.damage = 1000000
			new_weight.priority = 1000000
			new_weight.health = 1000000
			new_weight.total = 1000000
			target.weight = new_weight
			self.TARGET_CACHE[range].enemies[1] = target
		end
	end,

	get_main_target = function(self, range)
		range = range or 9999999
		self:refresh_targets(range)
		return self.TARGET_CACHE[range].enemies[1].target
	end,

	get_second_target = function(self, range)
		self:refresh_targets(range)
		return self.TARGET_CACHE[range].enemies[2].target
	end,

	get_forced_target = function(self, range)
		return self.FORCED_TARGET
	end,

	get_targets = function(self, range)
		self:refresh_targets(range)
		return self.TARGET_CACHE[range].enemies
	end,

	force_target = function(self)
		if g_input:is_key_pressed(1) then
			local target = nil
			local mousePos = g_input:get_cursor_position()
			local lowestDistance = std_math.huge
			local maxDistance = 70
			for i, enemy in ipairs(features.entity_list:get_enemies()) do
				if self.xHelper:is_valid(enemy) then
					local enemyVec2 = enemy.position:to_screen()
					if enemyVec2 ~= nil and enemyVec2.y > 25 then
						enemyVec2.y = enemyVec2.y - 25
						local dist = enemyVec2:dist_to(mousePos)
						if dist < maxDistance and dist < lowestDistance then
							target = enemy
							lowestDistance = dist
						end
					end
				end
			end
			self.FORCED_TARGET = target
		end
	end;

	draw = function(self)
		if not self.ts_enabled:get_value() then return end
		local cache = self:get_cache(9999999)
		local forced = self:get_forced_target()

		if forced and self.draw_target:get_value() and forced:is_visible()then
			g_render:circle_3d(forced.position, color:new(255, 0, 255, 55), 100, 3, 55, 1)
		end
		if cache and cache.enemies then
			for i, data in ipairs(cache.enemies) do
				if self.draw_target:get_value() and data.target:is_visible() then
					if i == 1 and not forced then
						g_render:circle_3d(data.target.position, color:new(255, 0, 0, 55), 100, 3, 55, 1)
					end
				end

				if self.draw_weight:get_value() then
					if data.target.position:to_screen()~= nil then
						g_render:text(
								vec2:new(data.target.position:to_screen().x + 60,
										data.target.position:to_screen().y - 10),
								color:new(255, 255, 255),
								data.weight.total .. "",
								nil,
								15
						)
					end
				end
			end
		end
	end,

	tick = function(self)
		if not self.ts_enabled:get_value() then return end
		self:force_target()
		local forced = self:get_forced_target()
		local target = self:get_main_target()
		if forced then
			target = forced
		end
		if target ~= nil then
			-- features.target_selector:force_target(target.index)
		else
			-- features.target_selector:force_target(-1)
		end
	end

})

--------------------------------------------------------------------------------

-- Permashow
--------------------------------------------------------------------------------

local debug = class({
	add = menu.get_main_window():push_navigation("debug", 10000),
	nav = menu.get_main_window():find_navigation("debug"),

	Colors = {
		solid = {
			white = color:new(255, 255, 255),
			red = color:new(255, 0, 0),
			orange = color:new(255, 127, 0),
			yellow = color:new(255, 255, 0),
			green = color:new(0, 255, 0),
			cyan = color:new(0, 255, 255),
			blue = color:new(0, 0, 255),
			purple = color:new(143, 0, 255)
		},
		transparent = {
			white = color:new(255, 255, 255, 130),
			red = color:new(255, 0, 0, 130),
			orange = color:new(255, 127, 0, 130),
			yellow = color:new(255, 255, 0, 130),
			green = color:new(0, 255, 0, 130),
			cyan = color:new(0, 255, 255, 130),
			blue = color:new(0, 0, 255, 130),
			purple = color:new(143, 0, 255, 200)
		}
	},


	init = function(self)
		
		self.Last_dbg_msg_time = g_time
		self.LastMsg = "init"
		self.LastMsg1 = "init"
		self.LastMsg2 = "init"

		self.dbg_sec = self.nav:add_section("debug")
		self.draw_sec = self.nav:add_section("color settings")
		self.dbg_enable = self.dbg_sec:checkbox("enabled", g_config:add_bool(true, "dbg_enable"))

		Res = g_render:get_screensize()
		local dbg_lvl = 0
		local posX = (Res.x / 2) - 100
		local posY = Res.y - 260

		self.Debug_level = g_config:add_int(dbg_lvl, "dbglvl")

		self.x = g_config:add_int(posX, "ps_x")
		self.y = g_config:add_int(posY, "ps_y")

		g_config:add_int(dbg_lvl, "dbglvl")self.dbg_sec:slider_int("Debuglvl", self.Debug_level, 0, 6)
		g_config:add_int(posX, "ps_x")self.dbg_sec:slider_int("x", self.x, 0, Res.x)
		g_config:add_int(posY, "ps_y")self.dbg_sec:slider_int("y", self.y, 0, Res.y)

	end,

	Print = function(self, str, level)
		level = level or 1
		str = tostring(str)

		if level <= self.Debug_level:get_int() then
		  print("log: " .. " " .. str)
		  if str ~= self.LastMsg then 
			self.LastMsg2 = self.LastMsg1
			self.LastMsg1 = self.LastMsg 
			self.LastMsg = str
		  end
		end
	end,

	draw = function(self)
		if self.Last_dbg_msg_time == -1 then return false end -- skip bad time
		if g_time - self.Last_dbg_msg_time >= 10 then return end -- fade out

		
		local pos = vec2:new((Res.x / 2) - 100, Res.y - 260)
		local pos1 = vec2:new((Res.x / 2) - 100, Res.y - 290)
		local pos2 = vec2:new((Res.x / 2) - 100, Res.y - 320)
	
		g_render:text(pos, self.Colors.solid.white, self.LastMsg, font, 30)
		g_render:text(pos1, self.Colors.solid.white, self.LastMsg1, font, 30)
		g_render:text(pos2, self.Colors.solid.white, self.LastMsg2, font, 30)
	
	end
	
})



--------------------------------------------------------------------------------

-- Permashow
--------------------------------------------------------------------------------

local permashow = class({
	hotkeys_ordered = {},
	hotkeys_id = {},
	title = "PERMASHOW",
	width = 100,
	height = 100,
	dragging = false,
	drag_x = 0,
	drag_y = 0,

	add = menu.get_main_window():push_navigation("permashow", 10000),
	nav = menu.get_main_window():find_navigation("permashow"),

	ps_sec = nil,
	draw_sec = nil,

	ps_enable = false,

	x = 0,
	y = 0,
	  
	ps_color_bg_r = 0,
	ps_color_bg_g = 0,
	ps_color_bg_b = 0,
	ps_color_bg_a = 0,

	ps_color_text_r = 0,
	ps_color_text_g = 0,
	ps_color_text_b = 0,
	ps_color_text_a = 0,

	init = function(self)

		self.ps_sec = self.nav:add_section("permashow")
		self.draw_sec = self.nav:add_section("color settings")

		self.ps_enable = self.ps_sec:checkbox("enabled", g_config:add_bool(true, "ps_enable"))

		self.x = g_config:add_int(0, "ps_x")
		self.y = g_config:add_int(0, "ps_y")
		g_config:add_int(0, "ps_x")self.ps_sec:slider_int("x", self.x, 0, g_render:get_screensize().x)
		g_config:add_int(0, "ps_y")self.ps_sec:slider_int("y", self.y, 0, g_render:get_screensize().y)

		self.ps_color_bg_r = self.draw_sec:slider_int("bg r", g_config:add_int(0, "ps_color_bg_r"), 0, 255)
		self.ps_color_bg_g = self.draw_sec:slider_int("bg g", g_config:add_int(0, "ps_color_bg_g"), 0, 255)
		self.ps_color_bg_b = self.draw_sec:slider_int("bg b", g_config:add_int(0, "ps_color_bg_b"), 0, 255)
		self.ps_color_bg_a = self.draw_sec:slider_int("bg a", g_config:add_int(180, "ps_color_bg_a"), 0, 255)

		self.ps_color_text_r = self.draw_sec:slider_int("text r", g_config:add_int(255, "ps_color_text_r"), 0, 255)
		self.ps_color_text_g = self.draw_sec:slider_int("text g", g_config:add_int(255, "ps_color_text_g"), 0, 255)
		self.ps_color_text_b = self.draw_sec:slider_int("text b", g_config:add_int(255, "ps_color_text_b"), 0, 255)
		self.ps_color_text_a = self.draw_sec:slider_int("text a", g_config:add_int(255, "ps_color_text_a"), 0, 255)

	end,

	rect = function(self, x, y, width, height)
		return {
			x = x,
			y = y,
			width = width,
			height = height
		}
	end,
	update_keys = function(self)
		local key = -1
		for _, hotkey in ipairs(self.hotkeys_ordered) do
			if #hotkey.key == 1 then key = e_key[string.upper(hotkey.key)]
			else key = e_key[hotkey.key] end
			local key_pressed = g_input:is_key_pressed(key)
			
			if hotkey.isToggle then
				if key_pressed ~= hotkey.prev_key_pressed and key_pressed then
					local time_diff = g_time - hotkey.last_update
					if time_diff >= 0.3 then
						hotkey.state = not hotkey.state
						hotkey.last_update = g_time

					-- Toggle the associated config_var
						if hotkey.config_var then
							hotkey.config_var:set_bool(not hotkey.config_var:get_bool())
						end
					end
				end
			else
				hotkey.state = key_pressed
			end
			hotkey.prev_key_pressed = key_pressed
		end
	end,

	get_state_text_and_color = function(self, hotkey)
		local state_text = hotkey.state and "[ON]" or "[OFF]"
		local state_color = hotkey.state and color:new(55, 255, 55, 255) or color:new(255, 55, 55, 255)
		return state_text, state_color
	end,

	draw = function(self)
		if not self.ps_enable:get_value() then return end

		if self.dragging then
			local pos = g_input:get_cursor_position()
			self.x:set_int(pos.x - self.drag_x)
			self.y:set_int(pos.y - self.drag_y)
		end

		local x = self.x:get_int()
		local y = self.y:get_int()

		local text_size = g_render:get_text_size(self.title, font, 15)
		local text_width = text_size.x + 20
		local tx = x + (self.width - text_width) / 2
		local bg_color = color:new(self.ps_color_bg_r:get_value(), self.ps_color_bg_g:get_value(), self.ps_color_bg_b:get_value(), self.ps_color_bg_a:get_value())
		local tx_color = color:new(self.ps_color_text_r:get_value(), self.ps_color_text_g:get_value(), self.ps_color_text_b:get_value(), self.ps_color_text_a:get_value())
		local count, height = 0, 0

		g_render:filled_box(vec2:new(x, self.y:get_int()), vec2:new(self.width, self.height), bg_color, 10)

		for _, hotkey in pairs(self.hotkeys_ordered) do
			if hotkey.name then
				count = count + 1
				local text = hotkey.name.." ["..hotkey.key.."] "
				local size = g_render:get_text_size(text, font, 15)
				local state_size = vec2:new(40, 20)

				g_render:text(vec2:new(x + 10, y + 30 + (count - 1) * 20), tx_color, text, font, 15)

				hotkey.state_rect = self:rect(x + 10 + size.x, y + 28 + (height - 1) * 20, state_size.x, state_size.y)

				local state_text, state_color = self:get_state_text_and_color(hotkey)
				local state_x = x + 10 + size.x + (state_size.x - g_render:get_text_size(state_text, font, 15).x) / 2
				local state_y = y + 28 + (count - 1) * 20 + (state_size.y - g_render:get_text_size(state_text, font, 15).y) / 2
				g_render:text(vec2:new(state_x, state_y), state_color, state_text, font, 15)

				height = std_math.max(height, size.x + state_size.x)
			end
		end

		local content_height = count * 20 + 30
		if content_height > self.height then self.height = height end

		self.width = std_math.max(text_width, height + 20)

		g_render:filled_box(vec2:new(x, self.y:get_int()), vec2:new(self.width, 25), color:new(bg_color.r, bg_color.g, bg_color.b, 255), 10)

		g_render:text(vec2:new(tx + 10, y + 5), tx_color, self.title, font, 15)
	end,

	set_title = function(self, title)
		self.title = title -- line 1161
	end,

	tick = function(self)
		if not self.ps_enable:get_value() then
			return
		end
		local pos = g_input:get_cursor_position()
		if g_input:is_key_pressed(e_key.lbutton) then
			if self:is_point_inside(pos) then
				self.dragging = true
				self.drag_x = pos.x - self.x:get_int()
				self.drag_y = pos.y - self.y:get_int()
				return true
			end
			for i, hotkey in ipairs(self.hotkeys_ordered) do
				local state_text, _ = self:get_state_text_and_color(hotkey)
				local state_x = hotkey.state_rect.x + 5
				local state_y = hotkey.state_rect.y + 3
				if self:is_cursor_inside_text(pos, state_text, state_x, state_y, font, 15) then
					hotkey.state = not hotkey.state
					g_input:send_mouse_key_event(e_mouse_button.left, e_key_state.key_up)
					break
				end
			end
		else
			self.dragging = false
		end
		self:update_keys()
	end,

	is_point_inside = function(self, point)
		return point.x >= self.x:get_int() and point.x <= self.x:get_int() + self.width and point.y >= self.y:get_int() and point.y <= self.y:get_int() + 25
	end,

	is_cursor_inside_text = function(self, cursorPos, text, x, y, font, fontSize)
		local textSize = g_render:get_text_size(text, font, fontSize)
		return cursorPos.x >= x and cursorPos.x <= x + textSize.x and cursorPos.y >= y and cursorPos.y <= y + textSize.y
	end,

	register = function(self, identifier, name, key, is_toggle, cfg)
		local cgf = cfg or nil
		local is_toggle = is_toggle or false
		print("enterting register")
		if self.hotkeys_id[identifier] then
			print("we already have identifier " .. identifier)
			self.hotkeys_id[identifier].name = name
			self.hotkeys_id[identifier].key = key
			self.hotkeys_id[identifier].isToggle = true
		else
			print("registering " .. identifier)
			local newHotkey = {
				identifier = identifier,
				name = name,
				key = key,
				state = false,
				labels = {},
                isToggle = is_toggle,
				config_var = cfg,
				last_update = g_time
			}
			print("inserting " .. identifier)
			table.insert(self.hotkeys_ordered, newHotkey)
			print("setting " .. identifier)
			self.hotkeys_id[identifier] = newHotkey
		end
	end,
	update = function(self, identifier, options)
		print("updating " .. identifier)
		if self.hotkeys_id[identifier] then
			if options.name then
				self.hotkeys_id[identifier].name = options.name
			end
			if options.key then
				self.hotkeys_id[identifier].key = options.key
			end
		end
	end,

})




--------------------------------------------------------------------------------

-- Callbacks
--------------------------------------------------------------------------------

local x = class({
	VERSION = "1.0",
	permashow = permashow:new(),
	buffcache = buffcache:new(),
	helper = xHelper:new(buffcache),
	math = math:new(xHelper, buffcache),
	objects = objects:new(xHelper, math),
	debug = debug:new(),
	database = database:new(xHelper),
	damagelib = damagelib:new(xHelper, math, database, buffcache),
	target_selector = target_selector:new(xHelper, math, objects, damagelib),

	init = function(self)

		cheat.on("features.pre_run", function()
			self.target_selector:tick()
		end)

		cheat.on("renderer.draw", function()
			self.permashow:draw()
			self.debug:draw()
			self.target_selector:draw()
		end)

		cheat.on("features.run", function()
			self.permashow:tick()
		end)

	end,

})


return x
