# Ironmon-Tracker Auto Pokémon Themes Extension

### [Installation](#installation) | [Usage](#usage) | [Changelog](#changelog)

An extension for the [Gen 3 Ironmon-Tracker](https://github.com/besteon/Ironmon-Tracker) that automatically loads custom unique themes for each of your lead Pokémon

This extension only works on the Bizhawk version of the tracker (as we don't have themes on the mGBA tracker)

As you play the game the extension will automatically load the associated theme for your lead Pokémon, defaulting back to the theme saved in your tracker Settings.ini if no associated theme is set

The tracker has a wiki page for information about using [Custom Code Extensions](https://github.com/besteon/Ironmon-Tracker/wiki/Tracker-Add-ons#custom-code-extensions)

Any issues feel free to let me know here or in the Ironmon discord server :) 

![Demo](https://user-images.githubusercontent.com/106463662/217630370-ebc1c5c7-23de-4d4a-99f5-5304ac3c163f.gif)

## Installation

1. Download the `AutoPokemonThemes_v#.#.zip` file from the [latest release](https://github.com/Fellshadow/Ironmon-Tracker-AutoPokemonThemes/releases/latest), extract ALL the files from the zip
   > ![image](https://user-images.githubusercontent.com/106463662/217638699-62103922-83a3-4b7e-8e5f-9c9c83bac97c.png)
2. Copy the contents of the `AutoThemes_Extension` folder into the `extensions` folder of your tracker
   > ![image](https://user-images.githubusercontent.com/106463662/217638418-134923c8-2fb3-4f3f-b85b-cd5c8a3325c0.png)
   > ![image](https://user-images.githubusercontent.com/106463662/217638515-57e0c672-9da4-447c-aaaa-4fc3788a9f09.png)
3. Click the gear icon on the tracker to open the settings menu and navigate to `Extensions`
   > ![image](https://user-images.githubusercontent.com/106463662/217632595-80cd058d-7e43-4b3d-bd33-41654530b1aa.png)
4. Enable "Allow custom code to run", if it is currently disabled, then click on "Refresh" to check for installed extensions
   > If "Auto Pokémon Themes" doesn't show up, check that you've placed the files in the right place
   > ![image](https://user-images.githubusercontent.com/106463662/219774930-48234814-5265-4cc0-8d54-548216a94a90.png)
   > ![image](https://github.com/Fellshadow/Ironmon-Tracker-AutoPokemonThemes/assets/106463662/396cb33c-20c4-4696-85c6-a11e82727b3b)
5. Click on the "Auto Pokémon Themes" button to go to the extension's page, where you can enable the extension as well as check for updates

## Usage

- As of v1.2, the provided `AutoThemeSets.txt` file now has a theme for every Pokémon (exported from the NDS tracker).
   - If you wish to edit / remove any, simply change the theme string next to the Pokémon's name (or remove the line entirely).
   - Each line should be the Pokémon name (in English) followed by the theme string, e.g.
     ```
     Bulbasaur 9AE1D3 9AE1D3 37E889 D4979E FFFFFF 309481 76D7C4 309481 76D7C4 309481 76D7C4 0 1
     ```
- If the tracker is running, you **must** disable and re-enable the extension for changes to take effect
- You can only add one theme per Pokémon (if you include multiple, it will use the one that is furthest down in the file)
- The extension will attempt to find the closest matching Pokémon name, if it fails the lua console output will tell you which names it failed on

## Changelog

- v1.2:
   - Changed the provided `AutoThemeSets.txt` file to include themes for all Pokémon exported from the NDS tracker's autothemes
- v1.1:
   - Added URL to view online from tracker menus
   - Added update-checking functionality 
- v1.0a:
   - Fixed an issue where large `AutoThemeSets.txt` files took a while to load
- v1.0: Initial Release
