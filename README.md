# xCore
How to use xCore

core = require("xCore")
core:init()

:)


# thanks, how do i get the permashow?
two ways
first give youself a title
```
core.permashow:set_title("put a name here")
```
then register what you want to show up on the perma show
This method ties the hotkey to a menu config so that it's tracked as a toggle
```
core.permashow:register("farm", "farm", "A", true, menu.q_clear_aoe_cgf)
```

or this way the permashow just displays if the key is pressed or not (then you should activate the logic yourself somewhere)
```
core.permashow:register("Semi-Auto Ult", "Semi-Auto Ult", "U")
```

heres my jinx example
```
core.permashow:set_title(name)
-- Clear
core.permashow:register("farm", "farm", "A", true, jmenu.q_clear_aoe_cgf)
core.permashow:register("Fast W", "Fast W", "control")
core.permashow:register("Semi-Auto Ult", "Semi-Auto Ult", "U")
core.permashow:register("Extend AA To Harass", "Extend AA To Harass", "I", true, jmenu.splash_harass_cfg)
```

# thanks, do i get my champion to show the damage visuals

right so all that is handle through core.database.DMG_LIST so we need to get your data in there, either you can make a PR and we'll approve it right quick OR
we did set up a method to add it yourself
```core.database:add_champion_data```
Here is how you would add sion

```
local sion_data = {
  ["sion"] = {
    {
      slot = "Q",
      stage = 1,
      damage_type = 1,
      damage = function(self, source, target, level)
        return ({ 40, 60, 80, 100, 120 })[level] +
            ({ 45, 52, 60, 67, 75 })[level] / 100 * source:get_attack_damage()
      end
    },
    {
      slot = "W",
      stage = 1,
      damage_type = 2,
      damage = function(self, source, target, level)
        return ({ 40, 65, 90, 115, 140 })[level] + 0.4 * source:get_ability_power() +
            ({ 10, 11, 12, 13, 14 })[level] / 100 * target.max_health
      end
    },
    {
      slot = "E",
      stage = 1,
      damage_type = 2,
      damage = function(self, source, target, level)
        return ({ 65, 100, 135, 170, 205 })[level] +
            0.55 * source:get_ability_power()
      end
    },
    {
      slot = "R",
      stage = 1,
      damage_type = 1,
      damage = function(self, source, target, level)
        return ({ 150, 300, 450 })[level] +
            0.4 * source:get_bonus_attack_damage()
      end
    },
  }
}
core.database:add_champion_data(sion_data)
```

this works exactly like if we added it into the core



