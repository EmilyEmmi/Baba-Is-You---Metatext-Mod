# Baba Is You - Better Metatext
***For game version: 478F (latest, but will work on some earlier versions)**

A mod that fully implements metatext into Baba Is You on Steam.

Metatext is text that refers to other text. For example, Baba metatext refers to the text that refers to Baba. So it's essentially modifying one kind of text block. Here's a gif of it now that I know how to add those:

<img src="gifs/metatext.gif" alt="gif is not render :(" width="400"/>

The concept comes from a side effect of how text works in the base game, but it is very limited. This mod removes these limitations.

# How to use
To install, place the Lua and Sprite folders in your levelpack folder, and write "mods = 1" without quotations inside of world_data.txt (located in the same folder) under [general]. Be sure to restart the game after doing this. Like this:

<img src="gifs/howtoinstall.gif" alt="gif is not render :(" width="800"/>

The file "rpg.lua" is optional. But what does it do???

You can also enable or disable new features with the new mod menu ~~not at all inspired by Plasmaflare's modpack~~. It should appear in the top left in the levelpack menu, as seen here:

<img src="gifs/menu.png" alt="png is not render :(" width="800"/>

Features documented [here](exfeatures.md).

There are multiple ways to get metatext in your level.
- Use [this script](https://cdn.discordapp.com/attachments/560913551586492475/854541928611971086/metatext.zip) by Plasmaflare to add most level 1 metatext to the editor. This also comes with sprites! Install with the rest of the mod.
- Use [this other script](https://cdn.discordapp.com/attachments/560913551586492475/1165756717276086363/add_metatext.zip) by several people to add most level 1, 2, AND 3 metatext to the editor. This comes with sprites, like the one above. Install with the rest of the mod. This is more up-to-date than the one above, but takes up more space.
- Rename an object to "text_text_(name)" without quotations, with (name) being the name of the text you want to refer to. You can go deeper by naming an object "text_text_text_(name)" to refer to "text_text_(name)". **Make sure you set its text type to 0 (Baba)!**
- A new feature with this mod: The TEXT_ prefix. More info [here](exfeatures.md).
- There's also an option for creating additional metatext on the fly. More info [here](exfeatures.md).

**Notes:**
~~- For the TEXT_ prefix to work with letters, the letters need to have their metatext for them in the palette. This isn't required for other text types.~~ This has been fixed!
- This mod changes way too many functions, so it is most likely imcompatible with any mod that overrides functions, such as Plasmaflare's Modpack. Condition mods that don't override functions may also not work correctly.
- If you find any bugs, let me know.

**CREDITS**
- RocketRace#0798's ROBOT IS YOU bot for the former Meta/Unmeta sprites
- Hempuli for making Baba Is You and for... other inspiration
- PlasmaFlare#5648 for reference on how to make readmes like this one, making the
scripts I reference here, inspiration for the mod menu, and for reference on how to make said menu.
- Me for programming and all sprites.
If I forgot anyone, write who I forgot and send a carrier pigeon to me. Or ping me on Discord, whichever's more convenient.
