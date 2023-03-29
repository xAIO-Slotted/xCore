x = {}
x.damagelib = {}
x.inventory = {}
x.buffcache = {}
x.math = {}
x.helper = {}
x.database = {}

local myHero = g_local

--------------------------------------
-- LINQ --

local function ParseFunc(func)
	if func == nil then return function(x) return x end end
	if type(func) == "function" then return func end
	local index = string.find(func, "=>")
	local arg = string.sub(func, 1, index - 1)
	local func = string.sub(func, index + 2, #func)
	return load(string.format("return function"
			.. " %s return %s end", arg, func))()
end

local function Linq(tab)
	return setmetatable(tab or {}, {__index = table})
end

function table.Aggregate(source, func, seed)
	local result = seed or 0
	local func = ParseFunc(func)
	for index, value in ipairs(source) do
		result = func(result, value, index)
	end
	return result
end

function table.All(source, func)
	local func = ParseFunc(func)
	for index, value in ipairs(source) do
		if not func(value, index) then
			return false
		end
	end
	return true
end

function table.Any(source, func)
	local func = ParseFunc(func)
	for index, value in ipairs(source) do
		if func(value, index) then
			return true
		end
	end
	return false
end

function table.Concat(first, second)
	local result, index = Linq(), 0
	for _, value in ipairs(first) do
		index = index + 1
		result[index] = value
	end
	for _, value in ipairs(second) do
		index = index + 1
		result[index] = value
	end
	return result
end

function table.Contains(source, element)
	for _, value in ipairs(source) do
		if value == element then
			return true
		end
	end
	return false
end

function table.Distinct(source)
	local result = Linq()
	local hash, index = {}, 0
	for _, value in ipairs(source) do
		if hash[value] == nil then
			index = index + 1
			result[index] = value
			hash[value] = true
		end
	end
	return result
end

function table.Except(first, second)
	return first:Where(function(value)
		return not second:Contains(value) end)
end

function table.First(source, func)
	local func = ParseFunc(func)
	for index, value in ipairs(source) do
		if func(value, index) then
			return value
		end
	end
	return nil
end

function table.ForEach(source, func)
	for index, value in pairs(source) do
		func(value, index)
	end
end

function table.Last(source, func)
	local func = ParseFunc(func)
	for index = #source, 1, -1 do
		local value = source[index]
		if func(value, index) then
			return value
		end
	end
	return nil
end

function table.Max(source, func)
	local result = -math.huge
	local func = ParseFunc(func)
	for index, value in ipairs(source) do
		local num = func(value, index)
		if type(num) == "number" and num >
				result then result = num end
	end
	return result
end

function table.Min(source, func)
	local result = math.huge
	local func = ParseFunc(func)
	for index, value in ipairs(source) do
		local num = func(value, index)
		if type(num) == "number" and num <
				result then result = num end
	end
	return result
end

function table.Select(source, func)
	local result = Linq()
	local func = ParseFunc(func)
	for index, value in ipairs(source) do
		result[index] = func(value, index)
	end
	return result
end

function table.RemoveWhere(source, func)
	local size = #source
	local func = ParseFunc(func)
	for index = size, 1, -1 do
		local value = source[index]
		if func(value, index) then
			source:remove(index)
		end
	end
	return size ~= #source
end

function table.SelectMany(source, selector, collector)
	local result = Linq()
	local selector = ParseFunc(selector)
	local collector = ParseFunc(collector)
	for index, value in ipairs(source) do
		local position = #result
		local values = selector(value, index)
		for iteration, element in ipairs(values) do
			local index = position + iteration
			result[index] = collector(value, element)
		end
	end
	return result
end

function table.Where(source, func)
	local result, iteration = Linq(), 0
	local func = ParseFunc(func)
	for index, value in ipairs(source) do
		if func(value, index) then
			iteration = iteration + 1
			result[iteration] = value
		end
	end
	return result
end

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Functions
-- Usage: x.(feature):(functions)


-- Inventory
--------------------------------------------------------------------------------

local CACHED_ITEMS = {}

-- returns the slot of the item
function x.inventory:get_slot(unit, id)
	local networkID = unit.network_id
	if CACHED_ITEMS[networkID] == nil then
		local t = {}
		for i = 6, 12 do
			local slot = i
			local item = unit:get_spell_book():get_spell_slot(slot)
			if item ~= nil and item:get_name() ~= nil then
				t[item:get_name()] = i
			end
		end
		CACHED_ITEMS[networkID] = t
	end
	return CACHED_ITEMS[networkID][id]
end

-- returns true if the unit has the item
function x.inventory:has_item(unit, id)
	return inventory:get_slot(unit, id) ~= nil
end

--------------------------------------------------------------------------------


-- Buffs
--------------------------------------------------------------------------------

-- returns a c_buff object
function x.buffcache:get_buff(unit, name)
	return features.buff_cache:get_buff(unit.index, name)
end

-- returns the amount of stacks of a buff
function x.buffcache:get_amount(unit, name)
	return features.buff_cache:get_buff(unit.index, name).amount
end

-- returns the duration of a buff
function x.buffcache:get_duration(unit, name)
	local buff = features.buff_cache:get_buff(unit.index, name)
	return buff.end_time - buff.start_time
end

-- returns true if the unit has the buff
function x.buffcache:has_buff(unit, name)
	return features.buff_cache:get_buff(unit.index, name)
end

--------------------------------------------------------------------------------

-- Helper
--------------------------------------------------------------------------------

x.database.HYBRID_RANGED = {"Elise", "Gnar", "Jayce", "Kayle", "Nidalee", "Zeri"}

x.database.INVINCIBILITY_BUFFS= {
	["aatroxpassivedeath"] = true, ["FioraW"] = true,
	["JaxCounterStrike"] = true, ["JudicatorIntervention"] = true,
	["KarthusDeathDefiedBuff"] = true, ["kindredrnodeathbuff"] = false,
	["KogMawIcathianSurprise"] = true, ["SamiraW"] = true, ["ShenWBuff"] = true,
	["TaricR"] = true, ["UndyingRage"] = false, ["VladimirSanguinePool"] = true,
	["ChronoShift"] = false, ["chronorevive"] = true, ["zhonyasringshield"] = true
}

-- returns true if the unit has a "melee" attack range
function x.helper:is_melee(unit)
	return unit.attack_range < 300
			and x.database.HYBRID_RANGED[unit.champion_name] ~= nil
end

function x.helper:get_aa_range(unit)
	local unit = unit or myHero
	return unit.attack_range + unit.bounding_radius
end

function x.helper:is_invincible(unit)
	return Linq(unit.buffs):Any(function(b)
		if not b or x.buffcache:get_duration(b) <= 0 or
				b:get_amount() <= 0 then return false end
		local buff = x.database.INVINCIBILITY_BUFFS[b.name]
		if buff == nil then return false end
		return buff == false and unit.health /
				unit.max_health < 0.05 or buff == true
	end)
end

function x.helper:get_percent_hp(unit)
	return 100 * unit.health / unit.max_health
end

function x.helper:get_percent_missing_hp(unit)
	return (1 - (unit.health / unit.max_health)) * 100
end

function x.helper:get_missing_hp(unit)
	return (unit.max_health - unit.health)
end

-- returns true if the unit is alive and not in sion passive
function x.helper:is_alive(index)
	local obj = features.entity_list:get_by_index(index)
	return (not x.buffcache:has_buff(obj, "sionpassivezombie") and not not x.buffcache:has_buff(obj, "Rebirth")) and obj:is_alive()
end

function x.helper:is_valid(unit)
	return unit and not unit:is_invalid_object() and unit:is_visible()
			and unit:is_alive() and unit:is_targetable()
end

function x.helper:get_latency()
	return features.orbwalker:get_ping() / 1000
end
--------------------------------------------------------------------------------

-- Damage Library
--------------------------------------------------------------------------------

x.database.CHAMP_PASSIVES = {
	["Aatrox"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "aatroxpassiveready") then return end
		args.raw_physical = args.raw_physical + (4.59 + 0.41
				* source.level) * 0.01 * args.unit.max_health
	end,
	["Akali"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "akalishadowstate") then return end
		local mod = ({35, 38, 41, 44, 47, 50, 53, 62, 71, 80,
					  89, 98, 107, 122, 137, 152, 167, 182})[source.level]
		args.raw_magical = args.raw_magical + mod + 0.55 *
				source:get_ability_power() + 0.6 * source:get_bonus_attack_damage()
	end,
	["Akshan"] = function(args) local source = args.source -- 12.20
		local buff = x.buffcache:get_buff(args.unit, "AkshanPassiveDebuff")
		if not buff or buff:get_amount() ~= 2 then return end
		local mod = ({10, 15, 20, 25, 30, 35, 40, 45, 55, 65,
					  75, 85, 95, 105, 120, 135, 150, 165})[source.level]
		args.raw_magical = args.raw_magical + mod
	end,
	["Ashe"] = function(args) local source = args.source -- 12.20
		local totalDmg = source:get_attack_damage()
		local slowed = x.buffcache:has_buff(args.unit, "ashepassiveslow")
		local mod = 0.0075 + (source:has_item(3031) and 0.0035 or 0)
		local percent = slowed and 0.1 + source.crit_chance * mod or 0
		args.raw_physical = args.raw_physical + percent * totalDmg
		if not x.buffcache:has_buff(source, "AsheQAttack") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.q).level
		args.raw_physical = args.raw_physical * (1 + 0.05 * lvl)
	end,
	["Bard"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "bardpspiritammocount") then return end
		local chimes = x.buffcache:get_buff(source, "bardpdisplaychimecount")
		if not chimes or chimes:get_amount() <= 0 then return end
		args.raw_magical = args.raw_magical + (14 * math.floor(
				chimes:get_amount() / 5)) + 35 + 0.3 * source:get_ability_power()
	end,
	["Blitzcrank"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "PowerFist") then return end
		args.raw_physical = args.raw_physical + 1.5 *
				source:get_ability_power() + 2.5 * source:get_attack_damage()
	end,
	["Braum"] = function(args) local source = args.source -- 12.20
		local buff = x.buffcache:get_buff(args.unit, "BraumMark")
		if not buff or buff:get_amount() ~= 3 then return end
		args.raw_magical = args.raw_magical + 16 + 10 * source.level
	end,
	["Caitlyn"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "caitlynpassivedriver") then return end
		local bonus = 1.3125 + (source:has_item(3031) and 0.2625 or 0)
		local mod = ({1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.15, 1.15, 1.15,
					  1.15, 1.15, 1.15, 1.2, 1.2, 1.2, 1.2, 1.2, 1.2})[source.level]
		args.raw_physical = args.raw_physical + (mod + (bonus * 0.01 *
				source.crit_chance)) * source:get_attack_damage()
	end,
	["Camille"] = function(args) local source = args.source -- 12.20
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.q).level
		if x.buffcache:has_buff(source, "CamilleQ") then
			args.raw_physical = args.raw_physical + (0.15 +
					0.05 * lvl) * source:get_attack_damage()
		elseif x.buffcache:has_buff(source, "CamilleQ2") then
			args.true_damage = args.true_damage + math.min(
					0.36 + 0.04 * source.level, 1) * (0.3 +
					0.1 * lvl) * source:get_attack_damage()
		end
	end,
	["Chogath"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "VorpalSpikes") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.e).level
		args.raw_magical = args.raw_magical + 10 + 12 * lvl + 0.3 *
				source:get_ability_power() + 0.03 * args.unit.max_health
	end,
	["Darius"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "DariusNoxianTacticsONH") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.w).level
		args.raw_physical = args.raw_physical + (0.35 +
				0.05 * lvl) * source:get_attack_damage()
	end,
	["Diana"] = function(args) local source = args.source -- 12.20
		local buff = x.buffcache:get_buff(source, "dianapassivemarker")
		if not buff or buff:get_amount() ~= 2 then return end
		local mod = ({20, 25, 30, 35, 40, 45, 55, 65, 75,
					  85, 95, 110, 125, 140, 155, 170, 195, 220})[source.level]
		args.raw_magical = args.raw_magical + mod + 0.5 * source:get_ability_power()
	end,
	["Draven"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "DravenSpinningAttack") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.q).level
		args.raw_physical = args.raw_physical + 35 + 5 * lvl +
				(0.65 + 0.1 * lvl) * source:get_bonus_attack_damage()
	end,
	["DrMundo"] = function(args) local source = args.source
		if not x.buffcache:has_buff(source, "DrMundoE") then return end
		-- TODO
	end,
	["Ekko"] = function(args) local source = args.source -- 12.20
		local buff = x.buffcache:get_buff(args.unit, "ekkostacks")
		if buff ~= nil and buff:get_amount() == 2 then
			local mod = ({30, 40, 50, 60, 70, 80, 85, 90, 95, 100,
						  105, 110, 115, 120, 125, 130, 135, 140})[source.level]
			args.raw_magical = args.raw_magical + mod + 0.9 * source:get_ability_power()
		end
		if x.buffcache:has_buff(source, "ekkoeattackbuff") then
			local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.e).level
			args.raw_magical = args.raw_magical + 25 +
					25 * lvl + 0.4 * source:get_ability_power()
		end
	end,
	["Fizz"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "FizzW") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.w).level
		args.raw_magical = args.raw_magical + 30 +
				20 * lvl + 0.5 * source:get_ability_power()
	end,
	["Galio"] = function(args) local source = args.source
		if not x.buffcache:has_buff(source, "galiopassivebuff") then return end
		-- TODO
	end,
	["Garen"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "GarenQ") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.q).level
		args.raw_physical = args.raw_physical + 30 *
				lvl + 0.5 * source:get_attack_damage()
	end,
	["Gnar"] = function(args) local source = args.source -- 12.20
		local buff = x.buffcache:get_buff(args.unit, "gnarwproc")
		if not buff or buff:get_amount() ~= 2 then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.w).level
		args.raw_magical = args.raw_magical - 10 + 10 * lvl + (0.04 +
				0.02 * lvl) * args.unit.max_health + source:get_ability_power()
	end,
	["Gragas"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "gragaswattackbuff") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.w).level
		args.raw_magical = args.raw_magical - 10 + 30 * lvl + 0.07
				* args.unit.max_health + 0.7 * source:get_ability_power()
	end,
	["Gwen"] = function(args) local source = args.source -- 12.20
		args.raw_magical = args.raw_magical + (0.01 + 0.008 *
				0.01 * source:get_ability_power()) * args.unit.max_health
		if args.unit.health / args.unit.max_health <= 0.4 then
			args.raw_magical = args.raw_magical + 6.71 + 1.29 * source.level
		end
	end,
	["Illaoi"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "IllaoiW") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.w).level
		local damage = math.min(300, math.max(10 + 10 * lvl,
				args.unit.max_health * (0.025 + 0.005 * lvl
						+ 0.0004 * source:get_attack_damage())))
		args.raw_physical = args.raw_physical + damage
	end,
	["Irelia"] = function(args) local source = args.source -- 12.20
		local buff = x.buffcache:get_buff(source, "ireliapassivestacks")
		if not buff or buff:get_amount() ~= 4 then return end
		args.raw_magical = args.raw_magical + 7 + 3 *
				source.level + 0.2 * source:get_bonus_attack_damage()
	end,
	["JarvanIV"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(args.unit, "jarvanivmartialcadencecheck") then return end
		local damage = math.min(400, math.max(20, 0.08 * args.unit.health))
		args.raw_physical = args.raw_physical + damage
	end,
	["Jax"] = function(args) local source = args.source -- 12.20
		if x.buffcache:has_buff(source, "JaxEmpowerTwo") then
			local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.w).level
			args.raw_magical = args.raw_magical + 15 +
					35 * lvl + 0.6 * source:get_ability_power()
		end
		if x.buffcache:has_buff(source, "JaxRelentlessAssault") then
			local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.r).level
			args.raw_magical = args.raw_magical + 60 +
					40 * lvl + 0.7 * source:get_ability_power()
		end
	end,
	["Jayce"] = function(args) local source = args.source -- 12.20
		if x.buffcache:has_buff(source, "JaycePassiveMeleeAttack") then
			local mod = ({25, 25, 25, 25, 25, 65,
						  65, 65, 65, 65, 105, 105, 105, 105,
						  105, 145, 145, 145})[source.level]
			args.raw_magical = args.raw_magical + mod
					+ 0.25 * source:get_bonus_attack_damage()
		end
		if x.buffcache:has_buff(source, "HyperChargeBuff") then
			local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.w).level
			local mod = ({0.7, 0.78, 0.86, 0.94, 1.02, 1.1})[lvl]
			arga.raw_physical = mod * source:get_attack_damage()
		end
	end,
	["Jhin"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "jhinpassiveattackbuff") then return end
		local missingHealth, mod = args.unit.max_health - args.unit.health,
		source.level < 6 and 0.15 or source.level < 11 and 0.2 or 0.25
		args.raw_physical = args.raw_physical + mod * missingHealth
	end,
	["Jinx"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "JinxQ") then return end
		args.raw_physical = args.raw_physical
				+ source:get_attack_damage() * 0.1
	end,
	["Kaisa"] = function(args) local source = args.source -- 12.20
		local buff = x.buffcache:get_buff(args.unit, "kaisapassivemarker")
		local count = buff ~= nil and buff:get_amount() or 0
		local damage = ({5, 5, 8, 8, 8, 11, 11, 11, 14, 14,
						 17, 17, 17, 20, 20, 20, 23, 23})[source.level] +
				({1, 1, 1, 3.75, 3.75, 3.75, 3.75, 6.5, 6.5, 6.5, 6.5,
				  9.25, 9.25, 9.25, 9.25, 12, 12, 12})[source.level] * count
				+ (0.125 + 0.025 * (count + 1)) * source:get_ability_power()
		if count == 4 then damage = damage +
				(0.15 + (0.06 * source:get_ability_power() / 100)) *
						(args.unit.max_health - args.unit.health) end
		args.raw_magical = args.raw_magical + damage
	end,
	["Kassadin"] = function(args) local source = args.source -- 12.20
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.w).level
		if x.buffcache:has_buff(source, "NetherBlade") then
			args.raw_magical = args.raw_magical + 25 +
					25 * lvl + 0.8 * source:get_ability_power()
		elseif lvl > 0 then
			args.raw_magical = args.raw_magical +
					20 + 0.1 * source:get_ability_power()
		end
	end,
	["Kayle"] = function(args) local source = args.source -- 12.20
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.e).level
		if lvl > 0 then args.raw_magical = args.raw_magical
				+ 10 + 5 * lvl + 0.2 * source:get_ability_power()
				+ 0.1 * source:get_bonus_attack_damage() end
		if x.buffcache:has_buff(source, "JudicatorRighteousFury") then
			args.raw_magical = args.raw_magical + (7.5 + 0.5 * lvl
					+ source:get_ability_power() * 0.01 * 1.5) * 0.01 *
					(args.unit.max_health - args.unit.health)
		end
	end,
	["Kennen"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "kennendoublestrikelive") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.w).level
		args.raw_magical = args.raw_magical + 25 + 10 * lvl + (0.7 + 0.1 *
				lvl) * source:get_bonus_attack_damage() + 0.35 * source:get_ability_power()
	end,
	["KogMaw"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "KogMawBioArcaneBarrage") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.w).level
		args.raw_magical = args.raw_magical + math.min(100, (0.0275 + 0.0075
				* lvl + 0.0001 * source:get_ability_power()) * args.unit.max_health)
	end,
	["Leona"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "LeonaSolarFlare") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.q).level
		args.raw_magical = args.raw_magical - 15 +
				25 * lvl + 0.3 * source:get_ability_power()
	end,
	["Lux"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(args.unit, "LuxIlluminatingFraulein") then return end
		args.raw_magical = args.raw_magical + 10 + 10 *
				source.level + 0.2 * source:get_ability_power()
	end,
	["Malphite"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "MalphiteCleave") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.w).level
		args.raw_physical = args.raw_physical + 15 + 15 * lvl
				+ 0.2 * source:get_ability_power() + 0.1 * source.armor
	end,
	["MasterYi"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "wujustylesuperchargedvisual") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.e).level
		args.true_damage = args.true_damage + 25 + 5 *
				lvl + 0.3 * source:get_bonus_attack_damage()
	end,
	-- MissFortune - can't detect buff ??
	["Mordekaiser"] = function(args) local source = args.source -- 12.20
		args.raw_magical = args.raw_magical + 0.4 * source:get_ability_power()
	end,
	["Nami"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "NamiE") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.e).level
		args.raw_magical = args.raw_magical + 10 +
				15 * lvl + 0.2 * source:get_ability_power()
	end,
	["Nasus"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "NasusQ") then return end
		local buff = x.buffcache:get_buff(source, "NasusQStacks")
		local stacks = buff ~= nil and buff:get_amount() or 0
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.q).level
		args.raw_physical = args.raw_physical + 10 + 20 * lvl + stacks
	end,
	["Nautilus"] = function(args) local source = args.source -- 12.20
		if x.buffcache:has_buff(args.unit, "nautiluspassivecheck") then return end
		args.raw_physical = args.raw_physical + 2 + 6 * source.level
	end,
	["Nidalee"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "Takedown") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.q).level
		args.raw_magical = args.raw_magical + (-20 + 25 *
				lvl + 0.75 * source:get_attack_damage() + 0.4 *
				source:get_ability_power()) * ((args.unit.max_health -
				args.unit.health) / args.unit.max_health + 1)
		if x.buffcache:has_buff(args.unit, "NidaleePassiveHunted") then
			args.raw_magical = args.raw_magical * 1.4 end
		args.raw_physical = 0
	end,
	["Neeko"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "neekowpassiveready") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.w).level
		args.raw_magical = args.raw_magical + 20 +
				30 * lvl + 0.6 * source:get_ability_power()
	end,
	["Nocturne"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "nocturneumbrablades") then return end
		args.raw_physical = args.raw_physical + 0.2 * source:get_attack_damage()
	end,
	["Orianna"] = function(args) local source = args.source -- 12.20
		args.raw_magical = args.raw_magical + 2 + math.ceil(
				source.level / 3) * 8 + 0.15 * source:get_ability_power()
		local buff = x.buffcache:get_buff(source, "orianapowerdaggerdisplay")
		if not buff or buff:get_amount() == 0 then return end
		args.raw_magical = raw.raw_magical * (1 + 0.2 * buff:get_amount())
	end,
	["Poppy"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "poppypassivebuff") then return end
		args.raw_magical = args.raw_magical + 10.59 + 9.41 * source.level
	end,
	["Quinn"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(args.unit, "QuinnW") then return end
		args.raw_physical = args.raw_physical + 5 + 5 * source.level +
				(0.14 + 0.02 * source.level) * source:get_attack_damage()
	end,
	["RekSai"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "RekSaiQ") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.q).level
		args.raw_physical = args.raw_physical + 15 + 6 *
				lvl + 0.5 * source:get_bonus_attack_damage()
	end,
	["Rell"] = function(args) local source = args.source -- 12.20
		args.raw_magical = args.raw_magical + 7.53 + 0.47 * source.level
		if not x.buffcache:has_buff(source, "RellWEmpoweredAttack") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.w).level
		args.raw_magical = args.raw_magical - 5 +
				15 * lvl + 0.4 * source:get_ability_power()
	end,
	["Rengar"] = function(args) local source = args.source -- 12.20
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.q).level
		if x.buffcache:has_buff(source, "RengarQ") then
			args.raw_physical = args.raw_physical + 30 * lvl +
					(-0.05 + 0.05 * lvl) * source:get_attack_damage()
		elseif x.buffcache:has_buff(source, "RengarQEmp") then
			local mod = ({30, 45, 60, 75, 90, 105,
						  120, 135, 145, 155, 165, 175, 185,
						  195, 205, 215, 225, 235})[source.level]
			args.raw_physical = args.raw_physical +
					mod + 0.4 * source:get_attack_damage()
		end
	end,
	["Riven"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "RivenPassiveAABoost") then return end
		args.raw_physical = args.raw_physical + (source.level >= 6 and 0.36 + 0.06 *
				math.floor((source.level - 6) / 3) or 0.3) * source:get_attack_damage()
	end,
	["Rumble"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "RumbleOverheat") then return end
		args.raw_magical = args.raw_magical + 2.94 + 2.06 * source.level
				+ 0.25 * source:get_ability_power() + 0.06 * args.unit.max_health
	end,
	["Sett"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "SettQ") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.q).level
		args.raw_physical = args.raw_physical +
				10 * lvl + (0.01 + (0.005 + 0.005 * lvl) * 0.01 *
				source:get_attack_damage()) * args.unit.max_health
	end,
	["Shaco"] = function(args) local source = args.source -- 12.20
		local turned = not Geometry:IsFacing(args.unit, source)
		if turned then args.raw_physical = args.raw_physical + 19.12 +
				0.88 * source.level + 0.15 * source:get_bonus_attack_damage() end
		if not x.buffcache:has_buff(source, "Deceive") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.q).level
		args.raw_physical = args.raw_physical + 15 +
				10 * lvl + 0.5 * source:get_bonus_attack_damage()
		local mod = 0.3 + (source:has_item(3031) and 0.35 or 0)
		if turned then args.raw_physical = args.raw_physical
				+ mod * source:get_attack_damage() end
	end,
	-- Seraphine
	["Shen"] = function(args) local source = args.source -- 12.20
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.q).level
		if x.buffcache:has_buff(source, "shenqbuffweak") then
			args.raw_magical = args.raw_magical + 4 + 6 * math.ceil(
					source.level / 3) + (0.015 + 0.005 * lvl + 0.015 *
					source:get_ability_power() / 100) * args.unit.max_health
		elseif x.buffcache:has_buff(source, "shenqbuffstrong") then
			args.raw_magical = args.raw_magical + 4 + 6 * math.ceil(
					source.level / 3) + (0.035 + 0.005 * lvl + 0.02 *
					source:get_ability_power() / 100) * args.unit.max_health
		end
	end,
	["Shyvana"] = function(args) local source = args.source -- 12.20
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.e).level
		if x.buffcache:has_buff(source, "ShyvanaDoubleAttack") then
			args.raw_physical = args.raw_physical + (0.05 + 0.15 * lvl) *
					source:get_attack_damage() + 0.25 * source:get_ability_power()
		end
		if x.buffcache:has_buff(args.unit, "ShyvanaFireballMissile") then
			args.raw_magical = args.raw_magical + 0.035 * args.unit.max_health
		end
	end,
	["Skarner"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "skarnerpassivebuff") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.e).level
		args.raw_physical = args.raw_physical + 10 + 20 * lvl
	end,
	["Sona"] = function(args) local source = args.source -- 12.20
		if x.buffcache:has_buff(source, "SonaQProcAttacker") then
			local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.q).level
			args.raw_magical = args.raw_magical + 5 +
					5 * lvl + 0.2 * source:get_ability_power()
		end -- SonaPassiveReady
	end,
	["Sylas"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "SylasPassiveAttack") then return end
		args.raw_magical, args.raw_physical = source:get_ability_power()
				* 0.25 + source:get_attack_damage() * 1.3, 0
	end,
	["TahmKench"] = function(args) local source = args.source -- 12.20
		args.raw_magical = args.raw_magical + 4.94 + 3.06 * source.level
				+ 0.03 * (source.max_health - (640 + 109 * source.level))
	end,
	["Taric"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "taricgemcraftbuff") then return end
		args.raw_magical = args.raw_magical + 21 + 4 *
				source.level + 0.15 * source.bonus_armor
	end,
	["Teemo"] = function(args) local source = args.source -- 12.20
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.e).level
		if lvl == 0 then return end
		args.raw_magical = args.raw_magical + 3 +
				11 * lvl + 0.3 * source:get_ability_power()
	end,
	["Trundle"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "TrundleTrollSmash") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.q).level
		args.raw_physical = args.raw_physical + 20 * lvl +
				(0.05 + 0.1 * lvl) * source:get_attack_damage()
	end,
	["TwistedFate"] = function(args) local source = args.source -- 12.20
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.w).level
		if x.buffcache:has_buff(source, "BlueCardPreAttack") then
			args.raw_magical = args.raw_magical + 20 + 20 * lvl +
					source:get_attack_damage() + 0.9 * source:get_ability_power()
		elseif x.buffcache:has_buff(source, "RedCardPreAttack") then
			args.raw_magical = args.raw_magical + 15 + 15 * lvl +
					source:get_attack_damage() + 0.6 * source:get_ability_power()
		elseif x.buffcache:has_buff(source, "GoldCardPreAttack") then
			args.raw_magical = args.raw_magical + 7.5 + 7.5 * lvl +
					source:get_attack_damage() + 0.5 * source:get_ability_power()
		end
		if args.raw_magical > 0 then args.raw_physical = 0 end
		if x.buffcache:has_buff(source, "cardmasterstackparticle") then
			local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.e).level
			args.raw_magical = args.raw_magical + 40 +
					25 * lvl + 0.5 * source:get_ability_power()
		end
	end,
	["Varus"] = function(args) local source = args.source -- 12.20
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.w).level
		if lvl > 0 then args.raw_magical = args.raw_magical +
				2 + 5 * lvl + 0.3 * source:get_ability_power() end
	end,
	["Vayne"] = function(args) local source = args.source -- 12.20
		if x.buffcache:has_buff(source, "vaynetumblebonus") then
			local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.q).level
			local mod = (1.55 + 0.05 * lvl) * source:get_bonus_attack_damage()
			args.raw_physical = args.raw_physical + mod
		end
		local buff = x.buffcache:get_buff(args.unit, "VayneSilveredDebuff")
		if not buff or buff:get_amount() ~= 2 then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.w).level
		args.true_damage = args.true_damage + math.max((0.02 +
				0.02 * lvl) * args.unit.max_health, 35 + 15 * lvl)
	end,
	-- Vex
	["Vi"] = function(args) local source = args.source -- 12.20
		if x.buffcache:has_buff(source, "ViE") then
			local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.e).level
			-- TODO
		end
		local buff = x.buffcache:get_buff(args.unit, "viwproc")
		if not buff or buff:get_amount() ~= 2 then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.w).level
		args.raw_physical = args.raw_physical + (0.025 + 0.015 * lvl + 0.01
				* source:get_bonus_attack_damage() / 35) * args.unit.max_health
	end,
	["Viego"] = function(args) local source = args.source
		-- TODO: Q
	end,
	["Viktor"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "ViktorPowerTransferReturn") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.q).level
		args.raw_magical, args.raw_physical = args.raw_magical - 5 + 25 * lvl
				+ source:get_attack_damage() + 0.6 * source:get_ability_power(), 0
	end,
	["Volibear"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "volibearpapplicator") then return end
		local mod = ({11, 12, 13, 15, 17, 19, 22, 25,
					  28, 31, 34, 37, 40, 44, 48, 52, 56, 60})[source.level]
		args.raw_magical = args.raw_magical + mod + 0.4 * source:get_ability_power()
	end,
	["Warwick"] = function(args) local source = args.source -- 12.20
		args.raw_magical = args.raw_magical + 10 + 2 * source.level + 0.15
				* source:get_bonus_attack_damage() + 0.1 * source:get_ability_power()
	end,
	["MonkeyKing"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "MonkeyKingDoubleAttack") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.q).level
		args.raw_physical = args.raw_physical - 5 +
				25 * lvl + 0.45 * source:get_bonus_attack_damage()
	end,
	["XinZhao"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "XinZhaoQ") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.q).level
		args.raw_physical = args.raw_physical + 7 +
				9 * lvl + 0.4 * source:get_bonus_attack_damage()
	end,
	-- Yone
	["Yorick"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "yorickqbuff") then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.q).level
		args.raw_physical = args.raw_physical + 5 +
				25 * lvl + 0.4 * source:get_attack_damage()
	end,
	["Zed"] = function(args) local source = args.source -- 12.20
		local level, maxHealth = source.level, args.unit.max_health
		if args.unit.health / maxHealth >= 0.5 then return end
		args.raw_magical = args.raw_magical + (level < 7 and
				0.06 or level < 17 and 0.08 or 0.1) * maxHealth
	end,
	["Zeri"] = function(args) local source = args.source -- 12.20
		if not source:get_spell_book():can_cast(e_spell_slot.q) then return end
		local lvl = source:get_spell_book():get_spell_slot(e_spell_slot.q).level
		args.raw_physical = 5 + 3 * lvl + (0.995 +
				0.05 * lvl) * myHero:get_attack_damage()
	end,
	["Ziggs"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "ZiggsShortFuse") then return end
		local mod = ({20, 24, 28, 32, 36, 40, 48, 56, 64,
					  72, 80, 88, 100, 112, 124, 136, 148, 160})[source.level]
		args.raw_magical = args.raw_magical + mod + 0.5 * source:get_ability_power()
	end,
	["Zoe"] = function(args) local source = args.source -- 12.20
		if not x.buffcache:has_buff(source, "zoepassivesheenbuff") then return end
		local mod = ({16, 20, 24, 28, 32, 36, 42, 48, 54,
					  60, 66, 74, 82, 90, 100, 110, 120, 130})[source.level]
		args.raw_magical = args.raw_magical + mod + 0.2 * source:get_ability_power()
	end
}
x.database.ITEM_PASSIVES = {
	[3504] = function(args) local source = args.source -- Ardent Censer
		if not x.buffcache:has_buff(source, "3504Buff") then return end
		args.raw_magical = args.raw_magical + 4.12 + 0.88 * args.unit.level
	end,
	[3153] = function(args) local source = args.source -- Blade of the Ruined King
		local mod = x.functions.helper:is_melee(source) and 0.12 or 0.08
		args.raw_physical = args.raw_physical + math.min(
				60, math.max(15, mod * args.unit.health))
	end,
	[3742] = function(args) local source = args.source -- Dead Man's Plate
		local stacks = math.min(100, 0) -- TODO
		args.raw_physical = args.raw_physical + 0.4 * stacks
				+ 0.01 * stacks * source:get_attack_damage()
	end,
	[6632] = function(args) local source = args.source -- Divine Sunderer
		if not x.buffcache:has_buff(source, "6632buff") then return end
		args.raw_physical = args.raw_physical + 1.25 *
				source:get_attack_damage() + (x.functions.helper:is_melee(source)
				and 0.06 or 0.03) * args.unit.max_health
	end,
	[1056] = function(args) -- Doran's Ring
		args.raw_physical = args.raw_physical + 5
	end,
	[1054] = function(args) -- Doran's Shield
		args.raw_physical = args.raw_physical + 5
	end,
	[3508] = function(args) local source = args.source -- Essence Reaver
		if not x.buffcache:has_buff(source, "3508buff") then return end
		args.raw_physical = args.raw_physical + 0.4 *
				source:get_bonus_attack_damage() + source:get_attack_damage()
	end,
	[3124] = function(args) local source = args.source -- Guinsoo's Rageblade
		args.raw_physical = args.raw_physical +
				math.min(200, source.crit_chance * 200)
	end,
	[2015] = function(args) local source = args.source -- Kircheis Shard
		local buff = x.buffcache:get_buff(source, "itemstatikshankcharge")
		local damage = buff and buff:get_amount() == 100 and 80 or 0
		args.raw_magical = args.raw_magical + damage
	end,
	[6672] = function(args) local source = args.source -- Kraken Slayer
		local buff = x.buffcache:get_buff(source, "6672buff")
		if not buff or buff:get_amount() ~= 2 then return end
		args.true_damage = args.true_damage + 50 +
				0.4 * source:get_bonus_attack_damage()
	end,
	[3100] = function(args) local source = args.source -- Lich Bane
		if not x.buffcache:has_buff(source, "lichbane") then return end
		args.raw_magical = args.raw_magical + 0.75 *
				source:get_attack_damage() + 0.5 * source:get_ability_power()
	end,
	[3004] = function(args) -- Manamune
		args.raw_physical = args.raw_physical
				+ args.source.max_mana * 0.025
	end,
	[3042] = function(args) -- Muramana
		args.raw_physical = args.raw_physical
				+ args.source.max_mana * 0.025
	end,
	[3115] = function(args) -- Nashor's Tooth
		args.raw_magical = args.raw_magical + 15
				+ 0.2 * args.source:get_ability_power()
	end,
	[6670] = function(args) -- Noonquiver
		args.raw_physical = args.raw_physical + 20
	end,
	[6677] = function(args) local source = args.source -- Rageknife
		args.raw_physical = args.raw_physical +
				math.min(175, 175 * source.crit_chance)
	end,
	[3094] = function(args) local source = args.source -- Rapid Firecannon
		local buff = x.buffcache:get_buff(source, "itemstatikshankcharge")
		local damage = buff and buff:get_amount() == 100 and 120 or 0
		args.raw_magical = args.raw_magical + damage
	end,
	[1043] = function(args) -- Recurve Bow
		args.raw_physical = args.raw_physical + 15
	end,
	[3057] = function(args) local source = args.source -- Sheen
		if not x.buffcache:has_buff(source, "sheen") then return end
		args.raw_physical = args.raw_physical + source:get_attack_damage()
	end,
	[3095] = function(args) local source = args.source -- Stormrazor
		local buff = x.buffcache:get_buff(source, "itemstatikshankcharge")
		local damage = buff and buff:get_amount() == 100 and 120 or 0
		args.raw_magical = args.raw_magical + damage
	end,
	[3070] = function(args) -- Tear of the Goddess
		args.raw_physical = args.raw_physical + 5
	end,
	[3748] = function(args) local source = args.source -- Titanic Hydra
		local mod = x.functions.helper:is_melee(args.source) and {4, 0.015} or {3, 0.01125}
		local damage = mod[1] + mod[2] * args.source.max_health
		args.raw_physical = args.raw_physical + damage
	end,
	[3078] = function(args) local source = args.source -- Trinity Force
		if not x.buffcache:has_buff(source, "3078trinityforce") then return end
		args.raw_physical = args.raw_physical + 2 * source:get_attack_damage()
	end,
	[6664] = function(args) local source = args.source -- Turbo Chemtank
		local buff = x.buffcache:get_buff(source, "item6664counter")
		if not buff or buff:get_amount()~= 100 then return end
		local damage = 35.29 + 4.71 * source.level + 0.01 *
				source.max_health + 0.03 * source.movement_speed
		args.raw_magical = args.raw_magical + damage * 1.3
	end,
	[3091] = function(args) local source = args.source -- Wit's End
		local damage = ({15, 15, 15, 15, 15, 15, 15, 15, 25, 35,
						 45, 55, 65, 75, 76.25, 77.5, 78.75, 80})[source.level]
		args.raw_magical = args.raw_magical + damage
	end
}

function x.damagelib:calc_aa_dmg(source, target)
	local name = source.champion_name
	local physical = source:get_attack_damage()
	if name == "Corki" and physical > 0 then return
	self:CalcMixedDamage(source, target, physical) end
	local args = {raw_magical = 0, raw_physical = physical,
				  true_damage = 0, source = source, unit = target}

	local items = {}
	for i = 6, 12 do
		local slot = i
		local item = source:get_spell_book():get_spell_slot(slot)
		items[#items + 1] = item
	end

	local ids = Linq(items):Where("(i) => i ~= nil")
						   :Select("(i) => i:get_name()"):Distinct():ForEach(function(i)
		if x.database.ITEM_PASSIVES[i] then x.database.ITEM_PASSIVES[i](args) end end)
	if x.database.CHAMP_PASSIVES[name] then x.database.CHAMP_PASSIVES[name](args) end

	local magical = self:calc_ap_dmg(source, target, args.raw_magical)
	local physical = self:calc_ad_dmg(source, target, args.raw_physical)

	return magical + physical + args.true_damage
end

function x.damagelib:calc_dmg(source, target, amount)
	return source:get_ability_power() > source:get_attack_damage()
			and self:calc_ap_dmg(source, target, amount)
			or self:calc_ad_dmg(source, target, amount)
end

function x.damagelib:calc_ap_dmg(source, target, amount)
	return helper.calculate_damage(amount, target.index, false)
end

function x.damagelib:calc_ad_dmg(source, target, amount)
	return helper.calculate_damage(amount, target.index, true)
end

-- Corki needs this...
function x.damagelib:calc_mixed_dmg(source, target, amount)
	return self:calc_ap_dmg(source, target, amount * 0.8)
			+ self:calc_ad_dmg(source, target, amount * 0.2)
end

function x.damagelib:calc_spell_dmg(spell, source, target, stage, level)
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

		if x.database.DMG_LIST[source.champion_name.text:lower()] then
			for _, spells in ipairs(x.database.DMG_LIST[source.champion_name.text:lower()]) do
				if spells.slot == spell then
					table.insert(cache, spells)
				end
			end

			if stage > #cache then stage = #cache end

			for v = #cache, 1, -1 do
				local spells = cache[v]
				if spells.stage == stage then
					return x.damagelib:calc_dmg(source, target, spells.damage(source, target, level))
				end
			end
		end
	end

	if spell == "AA" then
		return x.damagelib:calc_aa_dmg(source, target)
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
end

--------------------------------------------------------------------------------


-- Database
--------------------------------------------------------------------------------

x.database.DASH_LIST = {
	{
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
}

x.database.DMG_LIST = {
	jinx = { -- 13.6
		{ slot = "Q", stage = 1, damage_type = 1,
		  damage = function(source, target, level) return 0.1 * source:get_attack_damage() end },
		{ slot = "W", stage = 1, damage_type = 1,
		  damage = function(source, target, level) return ({ 10, 60, 110, 160, 210 })[level] + 1.6 * source:get_attack_damage() end },
		{ slot = "E", stage = 1, damage_type = 2,
		  damage = function(source, target, level) return ({ 70, 120, 170, 220, 270 })[level] + source:get_ability_power() end },
		{ slot = "R", stage = 1, damage_type = 1,
		  damage = function(source, target, level)
			  local dmg = (({ 30, 45, 60 })[level] + (0.15 * source:get_bonus_attack_damage()) * (1.10 + (0.06 * math.min(math.floor(source.position:dist_to(target.position) / 100), 15)))) +
					  (({ 25, 30, 35 })[level] / 100 * x.features.helper:get_missing_hp(target));
			  return dmg
		  end },
		{ slot = "R", stage = 2, damage_type = 1,
		  damage = function(source, target, level)
			  local dmg = (({ 24, 36, 48 })[level] + (0.12 * source:get_bonus_attack_damage()) * (1.10 + (0.06 * math.min(math.floor(source.position:dist_to(target.position) / 100), 15)))) +
					  (({ 20, 24, 28 })[level] / 100 * x.features.helper:get_missing_hp(target));
			  if target:is_ai() then return math.min(1200, dmg) end
			  ;
			  return dmg
		  end },
	},

	sion = { -- 13.6
		{ slot = "Q", stage = 1, damage_type = 1,
		  damage = function(source, target, level) return ({ 40, 60, 80, 100, 120 })[level] +
				  ({ 45, 52, 60, 67, 75 })[level] / 100 * source:get_attack_damage()
		  end },
		{ slot = "W", stage = 1, damage_type = 2,
		  damage = function(source, target, level) return ({ 40, 65, 90, 115, 140 })[level] + 0.4 * source:get_ability_power() +
				  ({ 10, 11, 12, 13, 14 })[level] / 100 * target.max_health
		  end },
		{ slot = "E", stage = 1, damage_type = 2,
		  damage = function(source, target, level) return ({ 65, 100, 135, 170, 205 })[level] + 0.55 * source:get_ability_power() end },
		{ slot = "R", stage = 1, damage_type = 1,
		  damage = function(source, target, level) return ({ 150, 300, 450 })[level] + 0.4 * source:get_bonus_attack_damage() end },
	},
}



--------------------------------------------------------------------------------


-- Callbacks
--------------------------------------------------------------------------------

cheat.on("features.run", function()

	-- clear caches
	CACHED_ITEMS = {}

end)
