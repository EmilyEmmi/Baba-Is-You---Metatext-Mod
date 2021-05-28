# Baba Is You - Metatext Mod
A mod that fully implements metatext into Baba Is You on Steam.

Metatext is text that refers to other text. For example, Baba metatext refers to the text that refers to Baba. So it's essentially modifying one kind of text block.

The concept is already partially implemented by default, but has many limitations. This mod removes those limitations. You can control, modify, and transform text using metatext.

To get metatext, name a unit in the level editor text_text_(name), name being the name of the text. You can also go deeper by naming a unit text_text_text_(name), so it refers to text_text_(name). Crazy stuff.

This mod does not include any objects or sprites. You're on your own to get those.

To install, place the Lua folder in your levelpack folder, and write "mods = 1" without quotations inside of world_data.txt (located in the same folder). Alternatively, you can place the Lua folder inside of the game's Data folder and apply it to the whole game.

Note that this may not play nicely with other mods, and this is for version 415.
