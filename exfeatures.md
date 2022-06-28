# Metatext mod features

In addition to implementing metatext, this mod comes with some new words that work with metatext, as well as some other features.

### TEXT_ prefix

<img src="gifs/text prefix.gif" alt="gif is not render :(" width="400"/>

This prefix goes before any word, parsing it as metatext. Make TEXT_ BABA IS YOU to make BABA text YOU!
Note: Baba will not send a text message.

### META / UNMETA

<img src="gifs/metaunmeta.gif" alt="gif is not render :(" width="400"/>

These properties change the meta level of text/objects:
- META raises the meta level. ROCK is changed to TEXT_ROCK, TEXT_ROCK is changed to TEXT_TEXT_ROCK, etc.
- UNMETA lowers the meta level. TEXT_TEXT_ROCK becomes TEXT_ROCK and TEXT_ROCK becomes ROCK. Texts that don't have an associated object won't be changed.
**These are considered transformations, so NOUN IS NOUN will disable them.**

### META(Number)

<img src="gifs/metanum.gif" alt="gif is not render :(" width="400"/>

These special nouns refer to a specific level of metatext:
- META-1 refers to objects such as 'baba' and 'rock'
- META0 refers to text such as 'text_baba' and 'text_is'
- META1 refers to level 1 metatext such as 'text_text_baba'
- ...and so on.
While this only adds up to META3 to the editor, upper levels such as META4 should work as intended.

## Settings menu

This lets you enable or disable certain features. It should appear in the top left in the levelpack menu, as seen here:

<img src="gifs/menu.png" alt="png is not render :(" width="800"/>

This is saved with your levelpack, so when you send it, it should be ready to go!
Here are the options available.

# Force vanilla behavior

<img src="gifs/quirks.gif" alt="gif is not render :(" width="400"/>

This option changes some behaviors to match vanilla. YES by default. The changes it makes are as follows:
Making TEXT/META# IS TELE links all of the included text together. Only text of the same type is linked if METATEXT IS TELE is formed.
Making TEXT/META# IS GROUP and NOUN HAS/MAKE/BECOME GROUP will make the NOUN have/make/become only its own text type rather than every text in the level.
Making TEXT/META# IS GROUP, NOUN NEAR GROUP IS X forces the noun to be near every text included to be X.

# Metatext Overlay

<img src="gifs/overlay.gif" alt="gif is not render :(" width="400"/>

This option adds a number in the corner of metatext in certain situations:
- Set to "None" to turn this off. Default.
- Set to "Wrong sprite" to turn this on if the sprite's meta-ness does not match that of the object. More specifically, the amount of time "text_" appears in the name, minus one if the name ends with "text_".
- Set to "Always" to always enable the overlay.
Note that this is disabled in the editor now because of issues.

# Text Is Word

<img src="gifs/textisnotword.gif" alt="gif is not render :(" width="400"/>

Makes all TEXT units WORD by default. Making them NOT WORD or BROKEN will prevent them from parsing. NO by default.

# 'Metatext is text' disables transform
# + 'Metatext has/make text' refers to text word

<img src="gifs/textnometa.gif" alt="gif is not render :(" width="400"/>

These are two seperate options. The first makes METATEXT IS TEXT not turn the specified text into it's metatext form. The second makes METATEXT HAS/MAKE TEXT refer to TEXT_TEXT instead of the specified text in its meta form. Both are NO by default.

# Automatically generate metatext

<img src="gifs/magictrick.gif" alt="gif is not render :(" width="400"/>

If metatext that doesn't exist in the palette tries to be created, it gets added to the pallete automatically. Doesn't work with level.**Can only add to the last 35 slots assuming those slots also aren't filled in the palette. If it tries to create more, nothing happens.** Comes with the following options:
- Set to "Never" to disable this. Default.
- Set to "Try correct sprite" to have the auto generated text try to use the correct sprites if they exist. Otherwise, use the default sprites.
- Set to "Force correct sprite" to only generate if the correct sprites exist.
- Set to "Always same sprite" to always use the default sprites.
**If the text exists in the editor but not in the palette, it will be added instead.**
Report any bugs you find with this, because this kind of thing has the capability to ruin your object list.

# NOT META# includes META-1 

<img src="gifs/includenoun.gif" alt="gif is not render :(" width="400"/>

Includes META-1 when NOT META# is written (except in NOT META-1, of course). NO by default.

# Easter egg

Not telling you what this does, but you can disable it. YES by default.

That's everything as of now!
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
...?<br/>
<img src="gifs/nothing.png" alt="png is not render :(" width="800"/>
