-- This is an easter egg. You can delete this if you want.
buttonclick_list["rpg"] = function()
  resetrpgdata()
  MF_playmusic("cave",0,1,0)
  changemenu("rpgstart")
end
buttonclick_list["battle_continue"] = function()
  rpg_passturn()
end
buttonclick_list["battle_back"] = function()
  closemenu()
end
buttonclick_list["battle_basic"] = function()
  ACTION = {"basic",{}}
  submenu("target_select")
end
buttonclick_list["battle_ability"] = function()
  ACTION = {"ability",{}}
  submenu("ability_list")
end
buttonclick_list["battle_item"] = function()
  ACTION = {"item",{}}
  submenu("item_list")
end
buttonclick_list["battle_weapon"] = function()
  ACTION = {"weapon",{}}
  submenu("weapon_list")
end
buttonclick_list["battle_armor"] = function()
  ACTION = {"armor",{}}
  submenu("armor_list")
end
buttonclick_list["battle_move"] = function()
  ACTION = {"move",{}}
  submenu("move_select")
end
buttonclick_list["battle_run"] = function()
  MF_letterclear("rpg_text")
  MF_letterclear("rpg_whatwill")
  MF_letterclear("rpg_menu")
  MF_letterclear("rpg_hud")
  MF_playmusic("editorsong",0,1,0)
  changemenu("metatext_settings")
end
local old = menufuncs.metatext_settings.enter
menufuncs.metatext_settings.enter = function(parent,name,buttonid)
  old(parent,name,buttonid)
  createbutton("rpg",428,1.5 * f_tilesize,1,0.5,0.5,"",name,0,1,buttonid)
end

function resetrpgdata()
  CURR = nil
  DASHER = "baba"
  LATE_DASHER = nil
  ALLY_DASHER = true
  LATE_ALLY_DASHER = nil
  TURN = 1
  AREA_EFFECTS = {
  }
  ENEMY_STATS = {
    speed = 15,
    order = {
      "red_dragon",
    },
  }
  ENEMIES = {
    red_dragon = {
      name = "The $2,2Red Dragon$0,3",
      hud_name = "$2,2Red Dragon$0,3",
      max_hp = 50000,
      hp = 50000,
      max_sp = 30000,
      sp = 30000,
      max_cn = 10000,
      cn = 0,
      type = "fire",
      level = 50,
      atk = 60,
      def = 20,
      extras = {
        vegan = true,
      },
      movelogic = function(user,x,y)
        local random = fixedrandom(1,10)
        if (TURN == 1 or random == 1) and user.sp >= 100 then
          user.sp = user.sp - 100
          writetext(user.name.." performs the $2,1Fiery Jig$0,3.",0,x,y,"rpg_text",true,2)
          MF_playsound("infinity")
          for num,cid in ipairs(PARTY_STATS.order) do
            y = y + f_tilesize
            local usee = PARTY_MEMBERS[cid]
            local userfront = (PARTY_STATS.order[1] == getindex(PARTY_MEMBERS,user) or ENEMY_STATS.order[1] == getindex(ENEMIES,user))
            local useefront = (PARTY_STATS.order[1] == getindex(PARTY_MEMBERS,usee) or ENEMY_STATS.order[1] == getindex(ENEMIES,usee))
            local hit = damage(user,usee,userfront,useefront,{"spell","dance",4,5})
            if hit then
              writetext(usee.name.." is charmed!",0,x,y,"rpg_text",true,2)
              if usee.extras == nil then
                usee.extras = {}
              end
              usee.extras.charmed = 3
            else
              writetext(usee.name.." is unaffected.",0,x,y,"rpg_text",true,2)
            end
          end
        elseif random == 2 and user.sp >= 200 then
          user.sp = user.sp - 200
          writetext(user.name.." casts $2,3Floor Is Lava$0,3.",0,x,y,"rpg_text",true,2)
          y = y + f_tilesize
          AREA_EFFECTS.lava = 3
          writetext("The floor is now lava!",0,x,y,"rpg_text",true,2)
        elseif user.cn == user.max_cn then
          local usee = selectalive(true)
          local userfront = (PARTY_STATS.order[1] == getindex(PARTY_MEMBERS,user) or ENEMY_STATS.order[1] == getindex(ENEMIES,user))
          local useefront = (PARTY_STATS.order[1] == getindex(PARTY_MEMBERS,usee) or ENEMY_STATS.order[1] == getindex(ENEMIES,usee))
          writetext(user.name.." $2,3slaps$0,3 "..usee.name.."!",0,x,y,"rpg_text",true,2)
          MF_playsound("plop2_short")
          generaldata.values[SHAKE] = 3
          y = y + f_tilesize
          local dmg,death = damage(user,usee,userfront,useefront,{"typeattack","fire",40})
          if dmg == "shield" then
            writetext(usee.name.."'s shield absorbed the attack!",0,x,y,"rpg_text",true,2)
            if usee.extras.shield ~= true then
              if usee.extras.shield > 1 then
                usee.extras.shield = usee.extras.shield - 1
              else
                y = y + f_tilesize
                writetext(usee.name.."'s shield broke.",0,x,y,"rpg_text",true,2)
                usee.extras.shield = nil
              end
            end
          elseif dmg > 0 then
            writetext("Dealt "..dmg.." damage!",0,x,y,"rpg_text",true,2)
          else
            writetext("But nothing happened.",0,x,y,"rpg_text",true,2)
          end
          if death then
            y = y + f_tilesize
            MF_playsound("pop1")
            writetext(usee.name.." collapses.",0,x,y,"rpg_text",true,2)
          end
        else
          local usee = selectalive(true)
          local userfront = (PARTY_STATS.order[1] == getindex(PARTY_MEMBERS,user) or ENEMY_STATS.order[1] == getindex(ENEMIES,user))
          local useefront = (PARTY_STATS.order[1] == getindex(PARTY_MEMBERS,usee) or ENEMY_STATS.order[1] == getindex(ENEMIES,usee))
          writetext(user.name.." $2,2angrily stomps$0,3 "..usee.name.."!",0,x,y,"rpg_text",true,2)
          MF_playsound("plop1")
          generaldata.values[SHAKE] = 6
          y = y + f_tilesize
          local dmg,death = damage(user,usee,userfront,useefront,{"typeattack","fire",100})
          if dmg == "shield" then
            writetext(usee.name.."'s shield absorbed the attack!",0,x,y,"rpg_text",true,2)
            if usee.extras.shield ~= true then
              if usee.extras.shield > 1 then
                usee.extras.shield = usee.extras.shield - 1
              else
                y = y + f_tilesize
                writetext(usee.name.."'s shield broke.",0,x,y,"rpg_text",true,2)
                usee.extras.shield = nil
              end
            end
          elseif dmg > 0 then
            writetext("Dealt "..dmg.." damage!",0,x,y,"rpg_text",true,2)
          else
            writetext("But nothing happened.",0,x,y,"rpg_text",true,2)
          end
          if death then
            y = y + f_tilesize
            MF_playsound("pop1")
            writetext(usee.name.." collapses.",0,x,y,"rpg_text",true,2)
          end
        end
        user.gone = true
        return y
      end,
    },
  }
  PARTY_STATS = {
    speed = 15,
    order = {
      "keke",
      "fofo",
      "baba",
      "jiji",
    },
    weapons = {},
    armor = {
      {
        name = "$2,2Fire Wig$0,3",
        desc = "You just set yourself on fire. Resists Fire type moves.",
        resists = {"fire"},
        user = "baba",
      },
    },
    items = {
      {
        name = "$5,3Greater Tonic$0,3",
        count = 45,
        desc = "Better than Great Tonics! Heals 400 HP.",
        effect = function(user,usee,x,y)
          local healamount = damage(user,usee,false,false,{"heal",400}) or 0
          if user == usee then
            writetext(user.name.." drinks the $5,3Greater Tonic$0,3.",0,x,y,"rpg_text",true,2)
          else
            writetext(user.name.." uses the $5,3Greater Tonic$0,3 on "..usee.name..".",0,x,y,"rpg_text",true,2)
          end
          y = y + f_tilesize
          if healamount > 0 then
            MF_playsound("tele1_short")
            writetext(usee.name.." recovered "..healamount.."HP!",0,x,y,"rpg_text",true,2)
          else
            writetext("But nothing happened.",0,x,y,"rpg_text",true,2)
          end
          return y
        end,
      },
      {
        name = "$0,2Earwig of Shielding$0,3",
        count = 1,
        desc = "Mmm, bugs. Creates a shield that blocks one enemy attack.",
        effect = function(user,usee,x,y)
          if user == usee then
            MF_playsound("move_hi1")
            writetext(user.name.." swallows the $0,2Earwig of Shielding$0,3.",0,x,y,"rpg_text",true,2)
          elseif usee.extras == nil or usee.extras.vegan == nil then
            MF_playsound("move_hi1")
            writetext(user.name.." forces the $0,2Earwig of Shielding$0,3 down "..usee.name.."'s throat.",0,x,y,"rpg_text",true,2)
          else
            writetext(user.name.." tries to force the $0,2Earwig of Shielding$0,3",0,x,y,"rpg_text",true,2)
          end
          y = y + f_tilesize
          if usee.extras == nil or usee.extras.vegan == nil then
            writetext("A shield was created around "..usee.name.."!",0,x,y,"rpg_text",true,2)
            if usee.extras == nil then
              usee.extras = {}
            end
            usee.extras.shield = 1
          else
            writetext("down "..usee.name.."'s throat, but they refuse.",0,x,y,"rpg_text",true,2)
          end
          return y
        end,
      },
      {
        name = "$2,2Fire Hydrant Spellstone$0,3",
        count = 12,
        desc = "Chill out, bad guys! Cools down Fire-type enemies.",
        target = "enemy",
        effect = function(user,usee,x,y)
          if user == usee then
            writetext(user.name.." uses the $2,2Fire Hydrant Spellstone$0,3 on themselves.",0,x,y,"rpg_text",true,2)
          else
            writetext(user.name.." uses the $2,2Fire Hydrant Spellstone$0,3 on "..usee.name..".",0,x,y,"rpg_text",true,2)
          end
          y = y + f_tilesize
          if usee.type == "fire" then
            local userfront = (PARTY_STATS.order[1] == getindex(PARTY_MEMBERS,user) or ENEMY_STATS.order[1] == getindex(ENEMIES,user))
            local useefront = (PARTY_STATS.order[1] == getindex(PARTY_MEMBERS,usee) or ENEMY_STATS.order[1] == getindex(ENEMIES,usee))
            local coolness = damage(user,usee,userfront,useefront,{"cool",300})
            if coolness > 0 then
              MF_playsound("lock2_short")
              writetext(usee.name.." cools off a bit!",0,x,y,"rpg_text",true,2)
            elseif coolness == 0 then
              writetext("But nothing happened.",0,x,y,"rpg_text",true,2)
            else
              writetext(usee.name.." is too cool for school!",0,x,y,"rpg_text",true,2)
            end
          else
            writetext("But nothing happened.",0,x,y,"rpg_text",true,2)
          end
          return y
        end,
      },
      {
        name = "$2,2Habanero$0,3",
        count = 1,
        desc = "Too hot! Heals Fire types 800 HP, hits others for 200 HP.",
        target = "enemy",
        effect = function(user,usee,x,y)
          if user == usee then
            writetext(user.name.." eats the $2,2Habanero$0,3.",0,x,y,"rpg_text",true,2)
          else
            writetext(user.name.." uses the $2,2Habanero$0,3 on "..usee.name..".",0,x,y,"rpg_text",true,2)
          end
          y = y + f_tilesize
          if usee.type == "fire" then
            local healamount = damage(user,usee,false,false,{"heal",800}) or 0
            if healamount > 0 then
              MF_playsound("tele1_short")
              writetext(usee.name.." recovered "..healamount.."HP!",0,x,y,"rpg_text",true,2)
            else
              writetext("But nothing happened.",0,x,y,"rpg_text",true,2)
            end
          else
            local dmg,death = damage(user,usee,false,false,{"damage",200})
            if dmg > 0 then
              MF_playsound("burn1_short")
              writetext(usee.name.." takes "..dmg.." damage!",0,x,y,"rpg_text",true,2)
            else
              writetext("But nothing happened.",0,x,y,"rpg_text",true,2)
            end
            if death then
              y = y + f_tilesize
              MF_playsound("pop1")
              writetext(usee.name.." faints from the spice.",0,x,y,"rpg_text",true,2)
            end
          end
          return y
        end,
      },
      {
        name = "$2,4Gourmet Mushroom Taco$0,3",
        count = 1,
        gourmet = true,
        desc = "Vegan friendly! Heals 1000 HP.",
        target = "both",
        effect = function(user,usee,x,y,spicy)
          if user == usee then
            writetext(user.name.." eats the $2,4Gourmet Mushroom Taco$0,3.",0,x,y,"rpg_text",true,2)
          else
            writetext(user.name.." feeds "..usee.name.." the $2,4Gourmet Mushroom Taco$0,3.",0,x,y,"rpg_text",true,2)
          end
          y = y + f_tilesize
          local healamount = damage(user,usee,false,false,{"heal",1000}) or 0
          if healamount > 0 then
            MF_playsound("tele1_short")
            writetext(usee.name.." recovered "..healamount.."HP!",0,x,y,"rpg_text",true,2)
          else
            writetext("But nothing happened.",0,x,y,"rpg_text",true,2)
          end
          if getindex(ENEMIES,usee) == "red_dragon" and usee.cn == usee.max_cn then
            local userfront = (PARTY_STATS.order[1] == getindex(PARTY_MEMBERS,user) or ENEMY_STATS.order[1] == getindex(ENEMIES,user))
            local useefront = (PARTY_STATS.order[1] == getindex(PARTY_MEMBERS,usee) or ENEMY_STATS.order[1] == getindex(ENEMIES,usee))
            local chance = 6
            if spicy then
              chance = 8
            end
            local hit = damage(user,usee,userfront,useefront,{"spell","food",chance,10})
            if hit then
              y = y + f_tilesize
              writetext(usee.name.." wants to be friends!",0,x,y,"rpg_text",true,2)
              usee.tame = true
            end
          end
          return y
        end,
      },
    },
  }
  PARTY_MEMBERS = {
    baba = {
      name = "$4,1Baba$0,3",
      max_hp = 1300,
      hp = 1300,
      max_sp = 1000,
      sp = 900,
      level = 26,
      atk = 52,
      def = 10,
      weapon = {
        name = "Unlegendary Sword",
        desc = "A sword with no name for itself. 50 ATK, Normal type.",
        type = "normal",
        atk = 50,
        user = "baba",
      },
      armor = {
        name = "$1,2Sneaking Crown$0,3",
        desc = "Distractingly shiny crown. Increases overworld speed.",
        effects = {"ow_boost"},
        user = "baba",
      },
      abilities = {
        {
          name = "$1,4Dash$0,3",
          cost = 100,
          bdesc = "Lets the user move twice next turn.",
          target = "self",
          effect = function(user,usee,x,y)
            if user == usee then
              writetext(user.name.." uses $1,4Dash$0,3!",0,x,y,"rpg_text",true,2)
            else
              writetext(user.name.." uses $1,4Dash$0,3 on "..usee.name.."! By the way, this shouldn't happen.",0,x,y,"rpg_text",true,2)
            end
            y = y + f_tilesize
            MF_playsound("move_hi2")
            writetext(usee.name.." will move twice next turn!",0,x,y,"rpg_text",true,2)
            LATE_DASHER = getindex(PARTY_MEMBERS,usee)
            LATE_ALLY_DASHER = true
            if LATE_DASHER == nil then
              LATE_DASHER = getindex(ENEMIES,usee)
              LATE_ALLY_DASHER = false
            end
            return y
          end,
        },
      },
    },
    keke = {
      name = "$2,2Keke$0,3",
      max_hp = 1250,
      hp = 1250,
      max_sp = 1200,
      sp = 1200,
      level = 25,
      atk = 67,
      weapon = {
        name = "$2,2Rythstone Magiwand$0,3",
        desc = "Forged from Rythstonia's remnants. 30 ATK, Normal type.",
        type = "normal",
        atk = 30,
        user = "keke",
      },
      armor = {
        name = "$4,3Wizard Robe$0,3",
        desc = "No witches allowed! Reduces SP cost of abilities.",
        effects = {"sp_reduce"},
        user = "keke",
      },
      abilities = {
        {
          name = "$4,2Revive$0,3",
          cost = 200,
          bdesc = "50% chance of reviving a fallen party member with 1% of their maximum HP.",
          target = "dead",
          effect = function(user,usee,x,y)
            if user == usee then
              writetext(user.name.." tries reviving themselves. By the way, this shouldn't happen.",0,x,y,"rpg_text",true,2)
            else
              writetext(user.name.." tries to revive "..usee.name.."!",0,x,y,"rpg_text",true,2)
            end
            y = y + f_tilesize
            if fixedrandom(1,2) == 1 then
              local healamount = damage(user,usee,false,false,{"heal",math.ceil(usee.max_hp*0.01)}) or 0
              if healamount > 0 then
                MF_playsound("winnery_fast")
                writetext(usee.name.." rises!",0,x,y,"rpg_text",true,2)
              else
                writetext("But nothing happened.",0,x,y,"rpg_text",true,2)
              end
            else
              writetext("But nothing happened.",0,x,y,"rpg_text",true,2)
            end
            return y
          end,
        },
        {
          name = "$1,3Float$0,3",
          cost = 125,
          bdesc = "Avoids floor effects for 3 turns.",
          target = "party",
          effect = function(user,usee,x,y)
            MF_playsound("whoooooosh")
            if usee == "party" then
              writetext(user.name.." casts $1,3Float$0,3 on the party.",0,x,y,"rpg_text",true,2)
              y = y + f_tilesize
              for num,cid in ipairs(PARTY_STATS.order) do
                local c = PARTY_MEMBERS[cid]
                if c.extras == nil then
                  c.extras = {}
                end
                c.extras.float = 3
              end
              writetext("The party's flyin'!",0,x,y,"rpg_text",true,2)
            else
              writetext(user.name.." casts $1,2Hide$0,3 on the enemies.",0,x,y,"rpg_text",true,2)
              y = y + f_tilesize
              for num,cid in ipairs(ENEMY_STATS.order) do
                local c = ENEMIES[cid]
                if c.extras == nil then
                  c.extras = {}
                end
                c.extras.float = 3
              end
              writetext("The enemies're flyin'!",0,x,y,"rpg_text",true,2)
            end
            return y
          end,
        },
      },
    },
    fofo = {
      name = "$5,2Fofo$0,3",
      max_hp = 1200,
      hp = 1200,
      max_sp = 1300,
      sp = 1100,
      level = 24,
      atk = 47,
      resists = {"dance"},
      weapon = {
        name = "$0,1NES Mouse$0,3",
        desc = "An outdated painting tool. 60 ATK, Normal type.",
        type = "normal",
        atk = 60,
        user = "fofo",
      },
      armor = {
        name = "$2,0Mega Baret$0,3",
        desc = "Makes a better chair than a hat. 10 DEF.",
        def = 10,
        user = "fofo",
      },
      abilities = {
        {
          name = "$5,3Happy Song$0,3",
          cost = 100,
          bdesc = "Makes sparing actions more effective for two turns. More powerful when casted multiple times.",
          target = "self",
          effect = function(user,usee,x,y)
            if AREA_EFFECTS.happy == nil then
              writetext(user.name.." channels the $5,3Happy Song$0,3.",0,x,y,"rpg_text",true,2)
              y = y + f_tilesize
              AREA_EFFECTS.happy = 2
              writetext("Good vibes fill the room!",0,x,y,"rpg_text",true,2)
              MF_playsound("clear")
            elseif AREA_EFFECTS.happy ~= true then
              writetext(user.name.." continues to channel the $5,3Happy Song$0,3.",0,x,y,"rpg_text",true,2)
              y = y + f_tilesize
              AREA_EFFECTS.happy = AREA_EFFECTS.happy + 2
              writetext("The vibes get stronger!",0,x,y,"rpg_text",true,2)
              MF_playsound("clear")
            else
              writetext(user.name.." channels the $5,3Happy Song$0,3.",0,x,y,"rpg_text",true,2)
              y = y + f_tilesize
              writetext("But nothing happened.",0,x,y,"rpg_text",true,2)
            end
            return y
          end,
        },
        {
          name = "$1,2Hide$0,3",
          cost = 200,
          bdesc = "Makes physical enemy attacks miss this turn.",
          target = "party",
          effect = function(user,usee,x,y)
            MF_playsound("done2")
            if usee == "party" then
              writetext(user.name.." casts $1,2Hide$0,3 on the party.",0,x,y,"rpg_text",true,2)
              y = y + f_tilesize
              for num,cid in ipairs(PARTY_STATS.order) do
                local c = PARTY_MEMBERS[cid]
                if c.extras == nil then
                  c.extras = {}
                end
                c.extras.hidden = 1
              end
              writetext("The party turns invisible!",0,x,y,"rpg_text",true,2)
            else
              writetext(user.name.." casts $1,2Hide$0,3 on the enemies.",0,x,y,"rpg_text",true,2)
              y = y + f_tilesize
              for num,cid in ipairs(ENEMY_STATS.order) do
                local c = ENEMIES[cid]
                if c.extras == nil then
                  c.extras = {}
                end
                c.extras.hidden = 1
              end
              writetext("The enemies turn invisible!",0,x,y,"rpg_text",true,2)
            end
            y = y + f_tilesize
            return y
          end,
        },
      },
    },
    jiji = {
      name = "$2,3Jiji$0,3",
      max_hp = 1250,
      hp = 1250,
      max_sp = 1500,
      sp = 1500,
      level = 25,
      speed = 10,
      atk = 32,
      weapon = {
        name = "$2,2P$2,3a$2,4n $5,3o$3,3f $3,1P$2,2r$2,3i$2,4d$5,3e$0,3",
        desc = "A pan with a rainbow pattern. 35 ATK, Normal type.",
        type = "normal",
        atk = 35,
      },
      armor = {
        name = "Paper Plate Mask",
        desc = "A mask made by a young Jiji. Blocks status effects.",
        effects = {"status_block"},
        user = "jiji",
      },
      abilities = {
        {
          name = "$6,2Cook$0,3",
          cost = 200,
          bdesc = "Changes certain items into other items.",
          target = "item",
          effect = function(user,item,x,y)
            MF_playsound("intro_flower_1")
            writetext(user.name.." cooks the "..item.name.."!",0,x,y,"rpg_text",true,2)
            y = y + f_tilesize
            if item.name == "$2,2Habanero$0,3" then
              table.insert(PARTY_STATS.items,{
                name = "$2,4Mango-Habanero Hot Sauce$0,3",
                count = 1,
                desc = "Too hotter! Apply to Gourmet Dishes to make them Spicy.",
                target = "gourmet",
                effect = function(user,item,x,y)
                  writetext(user.name.." applies the $2,4Mango-Habanero Hot Sauce$0,3 to the "..item.name..".",0,x,y,"rpg_text",true,2)
                  y = y + f_tilesize
                  writetext("The "..item.name.." is now SPICY!",0,x,y,"rpg_text",true,2)
                  local oldeffect = item.effect
                  if item.count == 1 then
                    item.spicy = true
                    item.desc = item.desc..".. but hits non-Fire types for 200 HP."
                    item.name = item.name.." $2,2(Spicy!)$0,3"
                    item.target = "enemy"
                    item.effect = function(user,usee,x,y)
                      if usee.type == "fire" then
                        y = oldeffect(user,usee,x,y)
                      else
                        local dmg,death = damage(user,usee,false,false,{"damage",200})
                        if dmg > 0 then
                          MF_playsound("burn1_short")
                          writetext("Spicy! "..usee.name.." takes "..dmg.." damage!",0,x,y,"rpg_text",true,2)
                        else
                          writetext("Spicy! But nothing happened.",0,x,y,"rpg_text",true,2)
                        end
                        if death then
                          y = y + f_tilesize
                          MF_playsound("pop1")
                          writetext(usee.name.." faints from the spice.",0,x,y,"rpg_text",true,2)
                        end
                      end
                      return y
                    end
                  else
                    table.insert(PARTY_STATS.items,{
                      name = item.name.." $2,2(Spicy!)$0,3",
                      spicy = true,
                      count = 1,
                      desc = item.desc..".. but hits non-Fire types for 200 HP.",
                      target = "enemy",
                      gourmet = true,
                      effect = function(user,usee,x,y)
                        if usee.type == "fire" then
                          y = oldeffect(user,usee,x,y)
                        else
                          local dmg,death = damage(user,usee,false,false,{"damage",200})
                          if dmg > 0 then
                            MF_playsound("burn1_short")
                            writetext("Spicy! "..usee.name.." takes "..dmg.." damage!",0,x,y,"rpg_text",true,2)
                          else
                            writetext("Spicy! But nothing happened.",0,x,y,"rpg_text",true,2)
                          end
                          if death then
                            y = y + f_tilesize
                            MF_playsound("pop1")
                            writetext(usee.name.." faints from the spice.",0,x,y,"rpg_text",true,2)
                          end
                        end
                        return y
                      end,
                    })
                    item.count = item.count - 1
                  end
                  return y
                end,
              })
              writetext("Got $2,4Mango-Habanero Hot Sauce$0,3!",0,x,y,"rpg_text",true,2)
              if item.count > 1 then
                item.count = item.count - 1
              else
                table.remove(PARTY_STATS.items,getindex(PARTY_STATS.items,item,true))
              end
            else
              table.insert(PARTY_STATS.items,{
                name = "$1,2Bad Cooking$0,3",
                count = 1,
                desc = "Please, just throw this away.",
                target = "both",
                effect = function(user,usee,x,y)
                  if user == usee then
                    writetext(user.name.." quickly threw it away.",0,x,y,"rpg_text",true,2)
                  else
                    writetext(user.name.." throws the mess at "..usee.name..", who quickly throws it away.",0,x,y,"rpg_text",true,2)
                  end
                  return y
                end,
              })
              writetext("Got $1,2Bad Cooking$0,3!",0,x,y,"rpg_text",true,2)
              if item.count > 1 then
                item.count = item.count - 1
              else
                table.remove(PARTY_STATS.items,getindex(PARTY_STATS.items,item,true))
              end
            end
            return y
          end,
        },
        {
          name = "Pat",
          cost = 50,
          bdesc = "80% chance of de-charming a party member.",
          effect = function(user,usee,x,y)
            if user == usee then
              writetext(user.name.." pats themselves on the head.",0,x,y,"rpg_text",true,2)
            else
              writetext(user.name.." pats "..usee.name.." on the head.",0,x,y,"rpg_text",true,2)
            end
            y = y + f_tilesize
            if usee.extras == nil or usee.extras.charmed == nil or fixedrandom(1,5) == 1 then
              writetext("But nothing happened.",0,x,y,"rpg_text",true,2)
            else
              usee.extras.charmed = nil
              writetext(usee.name.." snaps out of it!",0,x,y,"rpg_text",true,2)
              MF_playsound("bonus")
            end
            return y
          end,
        },
      },
    },
  }
end

function drawhud(returntext)
  MF_letterclear("rpg_hud")
  local x = screenw / (#PARTY_STATS.order * 2)
  local y = f_tilesize
  for num,cid in ipairs(PARTY_STATS.order) do
    local c = PARTY_MEMBERS[cid]
    local specials = ""
    if c.extras ~= nil then
      if c.extras.charmed ~= nil then
        specials = specials .. "¤"
      end
      if c.extras.hidden ~= nil then
        specials = specials .. "♏"
      end
      if c.extras.shield ~= nil then
        specials = specials .. "♄"
      end
      if c.extras.float ~= nil then
        specials = specials .. "!"
      end
    end
    y = f_tilesize
    writetext((c.hud_name or c.name) .. specials,0,x,y,"rpg_hud",true,2)
    y = y + f_tilesize
    local hpcolour = "$0,3"
    if c.hp < c.max_hp * 0.05 then
      hpcolour = "$2,1"
    end
    writetext("HP:"..hpcolour..c.hp.."/"..c.max_hp,0,x,y,"rpg_hud",true,2)
    y = y + f_tilesize
    writetext("SP:"..c.sp.."/"..c.max_sp,0,x,y,"rpg_hud",true,2)
    x = x + screenw / #PARTY_STATS.order
  end
  local x = screenw / (#ENEMY_STATS.order * 2)
  local encountertext = "Encountered "
  for num,cid in ipairs(ENEMY_STATS.order) do
    local c = ENEMIES[cid]
    y = 425
    writetext(c.hud_name or c.name,0,x,y,"rpg_hud",true,2)
    y = y + f_tilesize
    local hpcolour = "$0,3"
    if c.hp < c.max_hp * 0.05 then
      hpcolour = "$2,1"
    end
    writetext(hpcolour..c.hp.."/"..c.max_hp,0,x,y,"rpg_hud",true,2)
    x = x + screenw / #ENEMY_STATS.order
    if returntext then
      encountertext = encountertext..c.name
      if #ENEMY_STATS.order ~= 1 and num ~= #ENEMY_STATS.order then
        if #ENEMY_STATS.order == 2 then
          encountertext = encountertext.." and "
        else
          if num == #ENEMY_STATS.order - 1 then
            encountertext = encountertext..", and "
          else
            encountertext = encountertext..", "
          end
        end
      end
    end
  end
  if returntext then
    encountertext = encountertext.."!"
    return encountertext
  end
end

menufuncs.rpgstart = {
  button = "rpg_battlestart",
  escbutton = "battle_continue",
  enter =
    function(parent,name,buttonid)
      local encountertext = drawhud(true)
      local x = screenw * 0.5
      local y = 5 * f_tilesize
      writetext(encountertext,0,x,y,"rpg_text",true,2)
      y = y + f_tilesize
      local dasher = PARTY_MEMBERS[DASHER]
      writetext(dasher.name.."'s $1,4Dash$0,3 ability lets them move twice!",0,x,y,"rpg_text",true,2)
      y = y + f_tilesize
      createbutton("battle_continue",x,y,1,18,1,">>>>>>","rpgstart",3,2,buttonid)
    end,
  leave =
    function(parent,name,buttonid)
      MF_letterclear("rpg_text")
    end,
}
menufuncs.party_select = {
  button = "party_turn",
  escbutton = "battle_run",
  enter =
    function(parent,name,buttonid)
      local x = screenw * 0.5
      local y = 5 * f_tilesize
      local c = PARTY_MEMBERS[CURR]
      if DASHER ~= CURR or ALLY_DASHER == false then
        c.gone = true
      else
        DASHER = nil
        ALLY_DASHER = false
      end
      writetext("What will "..c.name.." do?",0,x,y,"rpg_whatwill",true,2)
      y = y + f_tilesize
      createbutton("battle_basic",x,y,1,18,1,"Basic","party_select",3,2,buttonid,false,false,"Deals damage to one target using equipped weapon.")
      y = y + f_tilesize
      createbutton("battle_ability",x,y,1,18,1,"Ability","party_select",3,2,buttonid,false,false,"Special action that costs SP.")
      y = y + f_tilesize
      createbutton("battle_item",x,y,1,18,1,"Item","party_select",3,2,buttonid,false,false,"Use an item.")
      y = y + f_tilesize
      createbutton("battle_weapon",x,y,1,18,1,"Weapon","party_select",3,2,buttonid,CURR == PARTY_STATS.order[1],false,"Change weapon. Not available at the front.")
      y = y + f_tilesize
      createbutton("battle_armor",x,y,1,18,1,"Armor","party_select",3,2,buttonid,CURR == PARTY_STATS.order[1],false,"Change armor. Not available at the front.")
      y = y + f_tilesize
      createbutton("battle_move",x,y,1,18,1,"Move","party_select",3,2,buttonid,false,false,"Move forward or backward.")
      y = y + f_tilesize
      createbutton("battle_run",x,y,1,18,1,"Run!","party_select",3,2,buttonid,false,false,"Escape battle.")
    end,
  submenu_leave =
    function(parent,name,buttonid)
      MF_letterhide("rpg_whatwill",0)
    end,
  submenu_return =
    function(parent,name,buttonid)
      MF_letterhide("rpg_whatwill",1)
    end,
  leave =
    function(parent,name,buttonid)
      MF_letterclear("rpg_whatwill")
    end,
}
menufuncs.party_do = {
  button = "party_turn",
  escbutton = "battle_continue",
  enter =
    function(parent,name,buttonid)
      local x = screenw * 0.5
      local y = 5 * f_tilesize
      local c = PARTY_MEMBERS[CURR]
      if ACTION[1] == "basic" then
        local e = {}
        if ACTION[2][2] == true then
          e = PARTY_MEMBERS[ACTION[2][1]]
        else
          e = ENEMIES[ACTION[2][1]]
        end
        if c ~= e then
          writetext(c.name.." attacks "..e.name.."!",0,x,y,"rpg_text",true,2)
        else
          writetext(c.name.." attacks themselves!",0,x,y,"rpg_text",true,2)
        end
        MF_playsound("pop2_short")
        generaldata.values[SHAKE] = 3
        y = y + f_tilesize
        local dmg,death = 0,false
        if ACTION[2][2] == true then
          dmg,death = damage(c,e,false,false,ACTION)
        else
          dmg,death = damage(c,e,CURR == PARTY_STATS.order[1],ACTION[2][1] == ENEMY_STATS.order[1],ACTION)
        end
        if dmg == "shield" then
          writetext(e.name.."'s shield absorbed the attack!",0,x,y,"rpg_text",true,2)
          if e.extras.shield ~= true then
            if e.extras.shield > 1 then
              e.extras.shield = e.extras.shield - 1
            else
              y = y + f_tilesize
              writetext(e.name.."'s shield broke.",0,x,y,"rpg_text",true,2)
              e.extras.shield = nil
            end
          end
        elseif dmg > 0 then
          writetext("Dealt "..dmg.." damage!",0,x,y,"rpg_text",true,2)
        else
          writetext("But nothing happened.",0,x,y,"rpg_text",true,2)
        end
        if death then
          y = y + f_tilesize
          MF_playsound("pop1")
          writetext(e.name.." collapses.",0,x,y,"rpg_text",true,2)
        end
      elseif ACTION[1] == "move" then
        local row = ACTION[2][1]
        local pos = getindex(PARTY_STATS.order,CURR,true)
        if row == 1 then
          writetext(c.name.." moves to the front!",0,x,y,"rpg_text",true,2)
        elseif row == #PARTY_STATS.order then
          writetext(c.name.." moves to the back!",0,x,y,"rpg_text",true,2)
        else
          writetext(c.name.." moves to row "..row.."!",0,x,y,"rpg_text",true,2)
        end
        table.remove(PARTY_STATS.order,pos)
        table.insert(PARTY_STATS.order, row, CURR)
      elseif ACTION[1] == "weapon" then
        local changeto = ACTION[2][1]
        local newweapon = PARTY_STATS.weapons[changeto]
        if changeto ~= 0 then
          if c.weapon ~= nil then
            writetext(c.name.." swaps from "..c.weapon.name.." to "..newweapon.name.."!",0,x,y,"rpg_text",true,2)
            table.remove(PARTY_STATS.weapons,changeto)
            table.insert(PARTY_STATS.weapons,c.weapon)
          else
            writetext(c.name.." equips "..newweapon.name.."!",0,x,y,"rpg_text",true,2)
          end
          c.weapon = newweapon
        else
          writetext(c.name.." dequips "..c.weapon.name.."!",0,x,y,"rpg_text",true,2)
          table.insert(PARTY_STATS.weapons,c.weapon)
          c.weapon = nil
        end
      elseif ACTION[1] == "armor" then
        local changeto = ACTION[2][1]
        local newarmor = PARTY_STATS.armor[changeto]
        if changeto ~= 0 then
          if c.armor ~= nil then
            writetext(c.name.." swaps from the "..c.armor.name.." to the "..newarmor.name.."!",0,x,y,"rpg_text",true,2)
            table.remove(PARTY_STATS.armor,changeto)
            table.insert(PARTY_STATS.armor,c.armor)
          else
            writetext(c.name.." dons the "..newarmor.name.."!",0,x,y,"rpg_text",true,2)
          end
          c.armor = newarmor
        else
          writetext(c.name.." takes off the "..c.armor.name.."!",0,x,y,"rpg_text",true,2)
          table.insert(PARTY_STATS.armor,c.armor)
          c.armor = nil
        end
      elseif ACTION[1] == "item" then
        local e = {}
        local item = ACTION[2][1]
        if item.target == "gourmet" then
          e = ACTION[2][2]
        elseif ACTION[2][3] == true then
          e = PARTY_MEMBERS[ACTION[2][2]]
        else
          e = ENEMIES[ACTION[2][2]]
        end
        y = item.effect(c,e,x,y)
        if item.count > 1 then
          item.count = item.count - 1
        else
          table.remove(PARTY_STATS.items,getindex(PARTY_STATS.items,item,true))
        end
      elseif ACTION[1] == "ability" then
        local e = {}
        local ability = ACTION[2][1]
        if ability.target == "party" or ability.target == "enemies" or ability.target == "item" then
          e = ACTION[2][3]
        elseif ACTION[2][4] == true then
          e = PARTY_MEMBERS[ACTION[2][3]]
        else
          e = ENEMIES[ACTION[2][3]]
        end
        y = ability.effect(c,e,x,y)
        c.sp = c.sp - ACTION[2][2]
      end
      y = y + f_tilesize
      createbutton("battle_continue",x,y,1,18,1,">>>>>>","party_do",3,2,buttonid)
    end,
  leave =
    function(parent,name,buttonid)
      MF_letterclear("rpg_text")
    end,
}
menufuncs.enemy_turn = {
  button = "enemy_do",
  escbutton = "battle_continue",
  enter =
    function(parent,name,buttonid)
      local x = screenw * 0.5
      local y = 5 * f_tilesize
      local c = ENEMIES[CURR]
      y = c.movelogic(c,x,y)
      y = y + f_tilesize
      createbutton("battle_continue",x,y,1,18,1,">>>>>>","enemy_turn",3,2,buttonid)
    end,
  leave =
    function(parent,name,buttonid)
      MF_letterclear("rpg_text")
    end,
}
menufuncs.turn_effects = {
  button = "turn_end",
  escbutton = "battle_continue",
  enter =
    function(parent,name,buttonid)
      local x = screenw * 0.5
      local y = 5 * f_tilesize
      for num,cid in ipairs(PARTY_STATS.order) do
        local c = PARTY_MEMBERS[cid]
        y = endturn(c,x,y)
      end
      for num,cid in ipairs(ENEMY_STATS.order) do
        local c = ENEMIES[cid]
        y = endturn(c,x,y)
      end
      DASHER = LATE_DASHER or nil
      LATE_DASHER = nil
      ALLY_DASHER = LATE_ALLY_DASHER or false
      LATE_ALLY_DASHER = nil
      if AREA_EFFECTS.happy ~= nil and AREA_EFFECTS.happy ~= true then
        if AREA_EFFECTS.happy > 1 then
          AREA_EFFECTS.happy = AREA_EFFECTS.happy - 1
        else
          writetext("The good vibes subside.",0,x,y,"rpg_text",true,2)
          y = y + f_tilesize
          AREA_EFFECTS.happy = nil
        end
      end
      if AREA_EFFECTS.lava ~= nil and AREA_EFFECTS.lava ~= true then
        if AREA_EFFECTS.lava > 1 then
          AREA_EFFECTS.lava = AREA_EFFECTS.lava - 1
        else
          writetext("The floor is no longer lava.",0,x,y,"rpg_text",true,2)
          y = y + f_tilesize
          AREA_EFFECTS.lava = nil
        end
      end
      TURN = TURN + 1
      if y == 5 * f_tilesize then
        rpg_passturn()
      else
        createbutton("battle_continue",x,y,1,18,1,">>>>>>","turn_effects",3,2,buttonid)
      end
    end,
  leave =
    function(parent,name,buttonid)
      MF_letterclear("rpg_text")
    end,
}
menufuncs.loss = {
  button = "lose",
  escbutton = "battle_continue",
  enter =
    function(parent,name,buttonid)
      local x = screenw * 0.5
      local y = 5 * f_tilesize
      MF_playsound("done1")
      writetext("You've lost the battle.",0,x,y,"rpg_text",true,2)
      y = y + f_tilesize
      createbutton("battle_run",x,y,1,18,1,"oops","loss",3,2,buttonid)
    end,
  leave =
    function(parent,name,buttonid)
      MF_letterclear("rpg_text")
    end,
}
menufuncs.victory = {
  button = "win",
  escbutton = "battle_continue",
  enter =
    function(parent,name,buttonid)
      -- no actual functionality here.
      local x = screenw * 0.5
      local y = 5 * f_tilesize
      if ENEMIES["red_dragon"].hp > 0 then
        MF_playsound("clear")
        writetext("You won!",0,x,y,"rpg_text",true,2)
      else
        MF_playsound("doneall_c")
        writetext("You won...",0,x,y,"rpg_text",true,2)
      end
      y = y + f_tilesize
      writetext("Got $3,13000 XP$0,3 and $2,4400 G$0,3.",0,x,y,"rpg_text",true,2)
      for num,cid in ipairs(PARTY_STATS.order) do
        local c = PARTY_MEMBERS[cid]
        y = y + f_tilesize
        c.level = c.level + 1
        writetext(c.name.." is now level "..c.level.."!",0,x,y,"rpg_text",true,2)
        if cid == "baba" then
          y = y + f_tilesize
          writetext(c.name.." learned $2,2Charge$0,3!",0,x,y,"rpg_text",true,2)
        end
      end
      if ENEMIES["red_dragon"].hp > 0 then
        y = y + f_tilesize
        writetext("The $2,2Red Dragon$0,3 is now available as a mount!",0,x,y,"rpg_text",true,2)
      end
      if fixedrandom(1,5) ~= 1 then
        y = y + f_tilesize
        writetext("Got $0,1Dragonscale $0,1Gaming Mouse$0,3!",0,x,y,"rpg_text",true,2)
      end
      y = y + f_tilesize
      createbutton("battle_run",x,y,1,18,1,"poggers","victory",3,2,buttonid)
    end,
  leave =
    function(parent,name,buttonid)
      MF_letterclear("rpg_text")
    end,
}
menufuncs.move_select = {
  button = "move_select",
  escbutton = "battle_back",
  enter =
    function(parent,name,buttonid)
      local x = screenw * 0.5
      local y = 5 * f_tilesize
      local c = PARTY_MEMBERS[CURR]
      writetext("Which position?",0,x,y,"rpg_menu",true,2)
      y = y + f_tilesize
      for num,cid in ipairs(PARTY_STATS.order) do
        createbutton("option_"..num,x,y,1,18,1,num,"move_select",3,2,buttonid,cid == CURR,false,"Move to this position.")
        buttonclick_list["option_"..num] = function()
          table.insert(ACTION[2],num)
          closesubmenus()
          changemenu("party_do")
        end
        y = y + f_tilesize
      end
      y = y + f_tilesize
      createbutton("battle_back",x,y,1,18,1,"<<<<<<","move_select",3,2,buttonid,false,false,"Go back.")
    end,
  leave =
    function(parent,name,buttonid)
      MF_letterclear("rpg_menu")
    end,
}
menufuncs.weapon_list = {
  button = "weapon_list",
  escbutton = "battle_back",
  enter =
    function(parent,name,buttonid)
      local x = screenw * 0.5
      local y = 5 * f_tilesize
      local c = PARTY_MEMBERS[CURR]
      writetext("Choose a weapon.",0,x,y,"rpg_menu",true,2)
      y = y + f_tilesize
      if c.weapon ~= nil then
        createbutton("useless",x,y,1,18,1,c.weapon.name,"weapon_list",3,2,buttonid,true,false,c.weapon.desc)
        y = y + f_tilesize
      end
      local num = 0
      for a,weapon in ipairs(PARTY_STATS.weapons) do
        if weapon.user == CURR then
          num = num + 1
          createbutton("option_"..num,x,y,1,18,1,weapon.name,"weapon_list",3,2,buttonid,false,false,weapon.desc)
          buttonclick_list["option_"..num] = function()
            table.insert(ACTION[2],a)
            closesubmenus()
            changemenu("party_do")
          end
          y = y + f_tilesize
        end
      end
      createbutton("option_0",x,y,1,18,1,"dequip weapon","weapon_list",3,2,buttonid,c.weapon == nil,false,"Get rid of your current weapon.")
      buttonclick_list["option_0"] = function()
        table.insert(ACTION[2],0)
        closesubmenus()
        changemenu("party_do")
      end
      y = y + f_tilesize
      y = y + f_tilesize
      createbutton("battle_back",x,y,1,18,1,"<<<<<<","weapon_list",3,2,buttonid,false,false,"Go back.")
    end,
  leave =
    function(parent,name,buttonid)
      MF_letterclear("rpg_menu")
    end,
}
menufuncs.armor_list = {
  button = "armor_list",
  escbutton = "battle_back",
  enter =
    function(parent,name,buttonid)
      local x = screenw * 0.5
      local y = 5 * f_tilesize
      local c = PARTY_MEMBERS[CURR]
      writetext("Choose some armor.",0,x,y,"rpg_menu",true,2)
      y = y + f_tilesize
      if c.armor ~= nil then
        createbutton("useless",x,y,1,18,1,c.armor.name,"armor_list",3,2,buttonid,true,false,c.armor.desc)
        y = y + f_tilesize
      end
      local num = 0
      for a,armor in ipairs(PARTY_STATS.armor) do
        if armor.user == CURR then
          num = num + 1
          createbutton("option_"..num,x,y,1,18,1,armor.name,"armor_list",3,2,buttonid,false,false,armor.desc)
          buttonclick_list["option_"..num] = function()
            table.insert(ACTION[2],a)
            closesubmenus()
            changemenu("party_do")
          end
          y = y + f_tilesize
        end
      end
      createbutton("option_0",x,y,1,18,1,"dequip armor","armor_list",3,2,buttonid,c.armor == nil,false,"Take off your current armor.")
      buttonclick_list["option_0"] = function()
        table.insert(ACTION[2],0)
        closesubmenus()
        changemenu("party_do")
      end
      y = y + f_tilesize
      y = y + f_tilesize
      createbutton("battle_back",x,y,1,18,1,"<<<<<<","armor_list",3,2,buttonid,false,false,"Go back.")
    end,
  leave =
    function(parent,name,buttonid)
      MF_letterclear("rpg_menu")
    end,
}
menufuncs.item_list = {
  button = "item_list",
  escbutton = "battle_back",
  enter =
    function(parent,name,buttonid)
      local x = screenw * 0.5
      local y = 5 * f_tilesize
      local c = PARTY_MEMBERS[CURR]
      writetext("Select an item.",0,x,y,"rpg_imenu",true,2)
      y = y + f_tilesize
      for num,item in ipairs(PARTY_STATS.items) do
        local buttonid = createbutton("option_"..num,x,y,1,18,1,item.name.." x"..item.count,"item_list",3,2,buttonid,false,0,item.desc)
        local button = mmf.newObject(buttonid)
        buttonclick_list["option_"..num] = function()
          if ACTION[2][1] == nil then
            ACTION[2][1] = item
            if item.target ~= "gourmet" then
              submenu("target_select")
            else
              updatebuttoncolour(buttonid,1)
              for snum,sitem in ipairs(PARTY_STATS.items) do
                if snum ~= num and (sitem.gourmet == nil or sitem.spicy ~= nil) then
                  local buttons = MF_getbutton("option_"..snum)
                  if (#buttons > 0) then
                    for i,v in ipairs(buttons) do
                      local sbutton = mmf.newObject(v)
                      sbutton.values[BUTTON_DISABLED] = 1
                    end
                  end
                end
              end
            end
          elseif button.values[BUTTON_SELECTED] == 1 then
            ACTION[2][1] = nil
            updatebuttoncolour(buttonid,0)
            for snum,sitem in ipairs(PARTY_STATS.items) do
              if snum ~= num and (sitem.gourmet == nil or sitem.spicy ~= nil) then
                local buttons = MF_getbutton("option_"..snum)
                if (#buttons > 0) then
              		for i,v in ipairs(buttons) do
                    local sbutton = mmf.newObject(v)
                    sbutton.values[BUTTON_DISABLED] = 0
                    updatebuttoncolour(v,0)
                  end
                end
              end
            end
          else
            table.insert(ACTION[2],item)
            closesubmenus()
            changemenu("party_do")
          end
        end
        y = y + f_tilesize
      end
      y = y + f_tilesize
      createbutton("battle_back",x,y,1,18,1,"<<<<<<","item_list",3,2,buttonid,false,false,"Go back.")
    end,
  submenu_leave =
    function(parent,name,buttonid)
      MF_letterhide("rpg_imenu",0)
    end,
  submenu_return =
    function(parent,name,buttonid)
      if ACTION[2][2] == nil then
        ACTION[2][1] = nil
      end
      MF_letterhide("rpg_imenu",1)
    end,
  leave =
    function(parent,name,buttonid)
      MF_letterclear("rpg_imenu")
    end,
}
menufuncs.ability_list = {
  button = "ability_list",
  escbutton = "battle_back",
  enter =
    function(parent,name,buttonid)
      local x = screenw * 0.5
      local y = 5 * f_tilesize
      local c = PARTY_MEMBERS[CURR]
      writetext("Select an ability.",0,x,y,"rpg_amenu",true,2)
      y = y + f_tilesize
      for num,ability in ipairs(c.abilities) do
        local final_cost = ability.cost or 0
        if c.armor ~= nil and c.armor.effects ~= nil then
          for num,effect in ipairs(c.armor.effects) do
            if effect == "sp_reduce" then
              final_cost = final_cost - (final_cost * 0.2)
            end
          end
        end
        final_cost = math.ceil(final_cost)
        createbutton("aoption_"..num,x,y,1,18,1,ability.name.." - "..final_cost.." SP","ability_list",3,2,buttonid,final_cost > c.sp,false,ability.bdesc)
        buttonclick_list["aoption_"..num] = function()
          ACTION[2][1] = ability
          ACTION[2][2] = final_cost
          if ability.target ~= "self" and ability.target ~= "item" then
            submenu("target_select")
          elseif ability.target == "self" then
            table.insert(ACTION[2],CURR)
            table.insert(ACTION[2],true)
            closesubmenus()
            changemenu("party_do")
          else
            submenu("item_list")
          end
        end
        y = y + f_tilesize
      end
      y = y + f_tilesize
      createbutton("battle_back",x,y,1,18,1,"<<<<<<","ability_list",3,2,buttonid,false,false,"Go back.")
    end,
  submenu_leave =
    function(parent,name,buttonid)
      MF_letterhide("rpg_amenu",0)
    end,
  submenu_return =
    function(parent,name,buttonid)
      MF_letterhide("rpg_amenu",1)
    end,
  leave =
    function(parent,name,buttonid)
      MF_letterclear("rpg_amenu")
    end,
}
menufuncs.target_select = {
  button = "target_select",
  escbutton = "metatext_settings",
  enter =
    function(parent,name,buttonid)
      local x = screenw * 0.5
      local y = 8 * f_tilesize
      local c = PARTY_MEMBERS[CURR]
      writetext("Select a target.",0,x,y,"rpg_menu",true,2)
      local enemyrecommend = false
      local target = nil
      if (ACTION[1] == "item" or ACTION[1] == "ability") then
        target = ACTION[2][1].target
      end
      if ACTION[1] == "basic" or target == "enemy" or target == "enemies" then
        enemyrecommend = true
      end
      if target ~= "party" and target ~= "enemies" then
        x = screenw / (#PARTY_STATS.order * 2)
        y = 4 * f_tilesize
        local colour1,colour2 = 5,3
        if enemyrecommend then
          colour1,colour2 = 2,1
        elseif target == "both" then
          colour1,colour2 = 3,1
        end
        for num,cid in ipairs(PARTY_STATS.order) do
          local c = PARTY_MEMBERS[cid]
          createbutton("poption_"..num,x,y,1,5,1,"^^^","target_select",colour1,colour2,buttonid,(c.hp <= 0) ~= (target == "dead"),false,"Select this target.")
          buttonclick_list["poption_"..num] = function()
            table.insert(ACTION[2],cid)
            table.insert(ACTION[2],true)
            closesubmenus()
            changemenu("party_do")
          end
          x = x + screenw / #PARTY_STATS.order
        end
        x = screenw / (#ENEMY_STATS.order * 2)
        y = 425 - f_tilesize
        colour1,colour2 = 2,1
        if enemyrecommend then
          colour1,colour2 = 5,3
        elseif target == "both" then
          colour1,colour2 = 3,1
        end
        for num,cid in ipairs(ENEMY_STATS.order) do
          local c = ENEMIES[cid]
          createbutton("eoption_"..num,x,y,1,5,1,"vvv","target_select",colour1,colour2,buttonid,(c.hp <= 0) ~= (target == "dead"),false,"Select this target.")
          buttonclick_list["eoption_"..num] = function()
            table.insert(ACTION[2],cid)
            table.insert(ACTION[2],false)
            closesubmenus()
            changemenu("party_do")
          end
          x = x + screenw / #ENEMY_STATS.order
        end
      else
        y = 4 * f_tilesize
        local colour1,colour2 = 5,3
        if enemyrecommend then
          colour1,colour2 = 2,1
        end
        createbutton("poption_1",x,y,1,20,1,"^^^","target_select",colour1,colour2,buttonid,c.hp <= 0,false,"Select the party.")
        buttonclick_list["poption_1"] = function()
          table.insert(ACTION[2],"party")
          closesubmenus()
          changemenu("party_do")
        end
        y = 425 - f_tilesize
        colour1,colour2 = 2,1
        if enemyrecommend then
          colour1,colour2 = 5,3
        end
        createbutton("eoption_1",x,y,1,20,1,"vvv","target_select",colour1,colour2,buttonid,c.hp <= 0,false,"Select the enemies")
        buttonclick_list["eoption_1"] = function()
          table.insert(ACTION[2],"enemies")
          closesubmenus()
          changemenu("party_do")
        end
      end
      x = screenw * 0.5
      y = 9 * f_tilesize
      createbutton("battle_back",x,y,1,18,1,"<<<<<<","target_select",3,2,buttonid,false,false,"Go back.")
    end,
  leave =
    function(parent,name,buttonid)
      MF_letterclear("rpg_menu")
    end,
}

function rpg_passturn()
  drawhud()
  local current = DASHER
  local curr_ally = ALLY_DASHER or false
  local nomoves = false
  if current ~= nil then
    local c = PARTY_MEMBERS[current]
    if curr_ally == false then
      c = ENEMIES[current]
    end
    if (c.gone or c.hp <= 0 or (c.extras ~= nil and c.extras.charmed)) then
      current = nil
      DASHER = nil
      curr_ally = false
      ALLY_DASHER = false
    end
  end
  if current == nil then
    local topspeed = 0
    local alive = false
    for num,cid in ipairs(PARTY_STATS.order) do
      local c = PARTY_MEMBERS[cid]
      if PARTY_STATS.speed > topspeed and not c.still then
        if not (c.gone or c.hp <= 0 or (c.extras ~= nil and c.extras.charmed)) then
          topspeed = PARTY_STATS.speed
          current = cid
          curr_ally = true
          alive = true
        elseif c.hp > 0 then
          alive = true
        end
      elseif c.hp > 0 then
        alive = true
      end
    end
    if not alive then
      changemenu("loss")
      return
    end
    alive = false
    for num,cid in ipairs(ENEMY_STATS.order) do
      local c = ENEMIES[cid]
      if ENEMY_STATS.speed > topspeed and not c.still then
        if not (c.gone or c.tame or c.hp <= 0) then
          topspeed = ENEMY_STATS.speed
          current = cid
          curr_ally = false
          alive = true
        elseif c.hp > 0 and not c.tame then
          alive = true
        end
      elseif c.hp > 0 and not c.tame then
        alive = true
      end
    end
    if current == nil then
      nomoves = true
    end
    if not alive then
      changemenu("victory")
      return
    end
  end
  CURR = current
  if curr_ally then
    changemenu("party_select")
  elseif not nomoves then
    changemenu("enemy_turn")
  else
    changemenu("turn_effects")
  end
end

function endturn(c,x,y)
  c.gone = nil
  if c.extras ~= nil then
    if c.extras.hidden ~= nil and c.extras.hidden ~= true then
      if c.extras.hidden > 1 then
        c.extras.hidden = c.extras.hidden - 1
      else
        writetext(c.name.." appears again.",0,x,y,"rpg_text",true,2)
        y = y + f_tilesize
        c.extras.hidden = nil
      end
    end
    if c.extras.charmed ~= nil and c.extras.charmed ~= true then
      if c.extras.charmed > 1 then
        c.extras.charmed = c.extras.charmed - 1
      else
        writetext(c.name.." snaps back to reality.",0,x,y,"rpg_text",true,2)
        y = y + f_tilesize
        c.extras.charmed = nil
        MF_playsound("bonus")
      end
    end
  end
  if c.extras ~= nil and c.extras.float ~= nil and c.extras.float ~= true then
    if c.extras.float > 1 then
      c.extras.float = c.extras.float - 1
    else
      writetext(c.name.." lands.",0,x,y,"rpg_text",true,2)
      y = y + f_tilesize
      c.extras.float = nil
    end
  elseif c.type ~= "fire" then
    if AREA_EFFECTS.lava ~= nil then
      local dmg,death = damage(nil,c,false,false,{"damage",300})
      if dmg > 0 then
        MF_playsound("burn1_short")
        writetext(c.name.." is burnt for "..dmg.." damage.",0,x,y,"rpg_text",true,2)
        y = y + f_tilesize
      end
      if death then
        writetext(c.name.." is roasted.",0,x,y,"rpg_text",true,2)
        MF_playsound("pop1")
        y = y + f_tilesize
      end
    end
  end
  return y
end

function damage(atkr,atke,atkrfront,atkefront,action)
  if action[1] == "basic" then
    if atke.extras ~= nil then
      if atke.extras.hidden ~= nil then
        return 0,false
      elseif atke.extras.shield ~= nil then
        return "shield"
      end
    end
    local dmg = atkr.atk or 0
    local type = atkr.type or "normal"
    if atkr.weapon ~= nil and atkr.weapon.atk ~= nil then
      dmg = dmg + atkr.weapon.atk
      type = atkr.weapon.type or "normal"
    end
    if atke.resists ~= nil then
      for num,resist in ipairs(atke.resists) do
        if resist == type then
          dmg = dmg - (dmg * 0.5)
        end
      end
    end
    if atke.armor ~= nil and atke.armor.def ~= nil then
      dmg = dmg - atke.armor.def
      if atke.armor.resists ~= nil then
        for num,resist in ipairs(atke.armor.resists) do
          if resist == type then
            dmg = dmg - (dmg * 0.5)
          end
        end
      end
    end
    if atke.def ~= nil then
      dmg = dmg - atke.def
    end
    if atkrfront then
      dmg = dmg + math.ceil(dmg * 0.2)
    end
    if atkefront then
      dmg = dmg + math.ceil(dmg * 0.2)
    end
    local death = false
    if dmg <= 0 then
      return 0
    elseif atke.hp > dmg then
      atke.hp = atke.hp - dmg
    else
      atke.hp = 0
      death = true
    end
    return dmg,death
  elseif action[1] == "heal" then
    local heal = action[2] or 0
    if heal <= 0 then
      return 0
    elseif atke.max_hp - atke.hp > heal then
      atke.hp = atke.hp + heal
    else
      atke.hp = atke.max_hp
    end
    return heal
  elseif action[1] == "cool" then
    local coolness = action[2] or 0
    if atkrfront then
      coolness = coolness + math.ceil(coolness * 0.2)
    end
    if atkefront then
      coolness = coolness + math.ceil(coolness * 0.2)
    end
    if AREA_EFFECTS.happy ~= nil then
      local happiness = 2
      if AREA_EFFECTS.happy ~= true then
        happiness = AREA_EFFECTS.happy
      end
      coolness = coolness + math.ceil(coolness * (happiness/2))
    end
    if coolness <= 0 then
      return 0
    elseif atke.max_cn - atke.cn > coolness then
      atke.cn = atke.cn + coolness
    elseif atke.max_cn == atke.cn then
      return -1
    else
      atke.cn = atke.max_cn
    end
    return coolness
  elseif action[1] == "damage" then
    local dmg = action[2] or 0
    local death = false
    if dmg <= 0 then
      return 0
    elseif atke.hp > dmg then
      atke.hp = atke.hp - dmg
    elseif atke.hp == 0 then
      return 0,false
    else
      atke.hp = 0
      death = true
    end
    return dmg,death
  elseif action[1] == "spell" then
    if atke.hp <= 0 then
      return false
    end
    local success = action[3] or 0
    local failure = action[4] or 0
    local type = action[2] or "normal"
    if atke.resists ~= nil then
      for num,resist in ipairs(atke.resists) do
        if resist == type then
          failure = failure * 2
        end
      end
    end
    if atke.armor ~= nil then
      if atke.armor.effects ~= nil then
        for num,effect in ipairs(atke.armor.effects) do
          if effect == "status_block" then
            return false
          end
        end
      end
      if atke.armor.resists ~= nil then
        for num,resist in ipairs(atke.armor.resists) do
          if resist == type then
            failure = failure * 2
          end
        end
      end
    end
    if atkrfront then
      failure = failure - math.ceil(failure * 0.2)
    end
    if atkefront then
      failure = failure - math.ceil(failure * 0.2)
    end
    if failure > success and fixedrandom((failure-success),failure) > success then
      return false
    end
    return true
  elseif action[1] == "typeattack" then
    if atke.extras ~= nil then
      if atke.extras.hidden ~= nil then
        return 0,false
      elseif atke.extras.shield ~= nil then
        return "shield"
      end
    end
    local dmg = atkr.atk or 0
    dmg = dmg + (action[3] or 0)
    local type = action[2] or "normal"
    if atkr.weapon ~= nil and atkr.weapon.atk ~= nil then
      dmg = dmg + atkr.weapon.atk
    end
    if atke.resists ~= nil then
      for num,resist in ipairs(atke.resists) do
        if resist == type then
          dmg = dmg - (dmg * 0.5)
        end
      end
    end
    if atke.armor ~= nil and atke.armor.def ~= nil then
      dmg = dmg - atke.armor.def
      if atke.armor.resists ~= nil then
        for num,resist in ipairs(atke.armor.resists) do
          if resist == type then
            dmg = dmg - (dmg * 0.5)
          end
        end
      end
    end
    if atke.def ~= nil then
      dmg = dmg - atke.def
    end
    if atkrfront then
      dmg = dmg + math.ceil(dmg * 0.2)
    end
    if atkefront then
      dmg = dmg + math.ceil(dmg * 0.2)
    end
    local death = false
    if dmg <= 0 then
      return 0
    elseif atke.hp > dmg then
      atke.hp = atke.hp - dmg
    else
      atke.hp = 0
      death = true
    end
    return dmg,death
  end
end

function getindex(table,value,integer)
  if integer then
    for index,thisvalue in ipairs(table) do
      if thisvalue == value then
        return index
      end
    end
  else
    for index,thisvalue in pairs(table) do
      if thisvalue == value then
        return index
      end
    end
  end
  return nil
end

function selectalive(isparty)
  local table = ENEMY_STATS.order
  if isparty then
    table = PARTY_STATS.order
  end
  local pick = fixedrandom(1,#table)
  local badnums = {}
  while #badnums < #table do
    for num,cid in ipairs(table) do
      if num == pick then
        local c = ENEMIES[cid]
        if isparty then
          c = PARTY_MEMBERS[cid]
        end
        if c.hp <= 0 then
          if #badnums < #table then
            while badnums[pick] ~= nil do
              pick = fixedrandom(1,#table)
            end
          end
          if badnums[num] == nil then
            badnums[num] = 1
          end
        else
          return c
        end
        break
      end
    end
  end
  return nil
end

function closesubmenus()
  while menu[1] ~= "party_select" do
    closemenu()
  end
end
