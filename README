# Fesmaster's Name Generator

This name generator uses a variation of Wave Function Collapse, simplified, for building names out of syllables.

Names it generates are based on a dictionary of example names. Most of the files in this reposatory are dictionary files, and can be identified by starting with "Dict".

A Dictionary file is a lua code file that returns an array table, with each entry being a string of an example word. the example word is broken into syllables with a dash "`-`".

For an example of a dictionary file, please see `DictGreekMonster.lua` or any other dictionary file.

## Building

This library uses the RayLib library for its visual interface. Its lua bindings can be found standalone here: [raylib-lua](https://github.com/tsnake41/raylib-lua).

Simply run the tool `raylua_e`, pointing at the directory you cloned the reposatory into.

It is not reccomended to use `raylua_r` on Windows. Due to the use of `clip.exe` for copying to the clipboard, it will flash a terminal window for each copy (which looks sketchy).

Also because of the use of `clip.exe`, this program only supports Windows.

## Adding a dictionary

To add a dictionary, you can create a new `DictWhatever.lua` file, then add a reference to that file in main.lua, with a line like:

```lua
NameGen.AddDictionarySource("DictWhatever", "My Awesome Names")
```

Note that the first paramater is the file name of the dictionary *without* the extension. The second paramater is the UI name of the dictionary.