# Metatext mod features

In addition to implementing metatext, this mod comes with some new words that work with metatext, as well as some other features.

### TEXT_ prefix

<img src="gifs/text prefix.gif" alt="gif is not render :(" width="400"/>

This prefix goes before any word, parsing it as metatext. Make TEXT_ BABA IS YOU to make BABA text YOU!
Simply don't omit the file "text_ prefix.lua" to get this word.
Note: Baba will not send a text message.

### META / UNMETA

<img src="gifs/metaunmeta.gif" alt="gif is not render :(" width="400"/>

These properties change the meta level of text/objects:
- META raises the meta level. ROCK is changed to TEXT_ROCK, TEXT_ROCK is changed to TEXT_TEXT_ROCK, etc.
- UNMETA lowers the meta level. TEXT_TEXT_ROCK becomes TEXT_ROCK and TEXT_ROCK becomes ROCK. Texts that don't have an associated object won't be changed.
**These are considered transformations, so NOUN IS NOUN will disable them.**
Simply don't omit the file "metaunmeta.lua" to get this word.

## defines + misc.lua

This **required** file lets you enable/disable certain features. Here's what each option does, in detail. You can also find some information within the file itself.

### Fix quirks

<img src="gifs/quirks.gif" alt="gif is not render :(" width="400"/>

This option changes some behaviors to match vanilla. TRUE by default. The changes it makes are as follows:
Making TEXT IS TELE specifically links all of the text together. Only text of the same type is linked if METATEXT IS TELE is formed.
Making TEXT IS MORE specifically does not allow text units to ever grow into each other. METATEXT IS MORE will allow it for text units of different types.
Making TEXT IS GROUP specifcally and NOUN HAS/MAKE GROUP will make the NOUN have/make only its own text type rather than every text in the level.

### Overlay style

<img src="gifs/overlay.gif" alt="gif is not render :(" width="400"/>

This option adds a number in the corner of metatext in certain situations:
- Set to "none" to turn this off. Default.
- Set to "withoutsprite" to turn this on if the sprite's filename does not match the name of the object.
- Set to anything else to always enable the overlay.

### Text Is Word

<img src="gifs/textisnotword.gif" alt="gif is not render :(" width="400"/>

Makes all TEXT units WORD by default. Making them NOT WORD or BROKEN will prevent them from parsing. FALSE by default.

### IS TEXT doesn't meta the text and HAS/MAKE TEXT doesn't meta the text

<img src="gifs/textnometa.gif" alt="gif is not render :(" width="400"/>

This is two seperate options. The first makes METATEXT IS TEXT not turn the specified text into it's metatext form. The second makes METATEXT HAS/MAKE TEXT refer to TEXT_TEXT instead of the specified text in its meta form. Both are FALSE by default.

### Metatext auto generates

<img src="gifs/magictrick.gif" alt="gif is not render :(" width="400"/>

If metatext that doesn't exist in the palette tries to be created, it gets added to the pallete automatically. **Can only add to the first 35 slots assuming those slots also aren't filled in the palette. If it tries to create more, a TOO COMPLEX occurs.** Comes with the following options:
- Set to "never" to disable this. Default.
- Set to "trysprite" to have the auto generated text try to use the correct sprites if they exist. Otherwise, use the default sprites.
- Set to "mustsprite" to only generate if the correct sprites exist.
- Set to anything else to always use the default sprites.
**If the text exists in the editor but not in the palette, it will be added instead.**
Report any bugs you find with this, because this kind of thing has the capability to ruin your object list.

### Easter egg

Not telling you what this does, but you can disable it. TRUE by default.

That's everything as of now!
