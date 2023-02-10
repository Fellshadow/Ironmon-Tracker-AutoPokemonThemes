# Ironmon-Tracker Auto Pokémon Themes Extension

[Installation](#installation) | [Usage](#usage)

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
3. Load up Bizhawk and the Tracker, if you don't already have them running
4. Click the gear icon on the tracker to open the settings menu and navigate to `Extensions`
   > ![image](https://user-images.githubusercontent.com/106463662/217632595-80cd058d-7e43-4b3d-bd33-41654530b1aa.png)
5. Click on "Refresh" to check for installed extensions. "Auto Pokémon Themes" should pop up on the page.
   > If it doesn't show up, check that you've placed the files in the right place
   > ![image](https://user-images.githubusercontent.com/106463662/218172864-88ae5fd3-1a95-41cd-a9b0-0288ad69e696.png)
6. Click on the box next to "Allow custom code to run" to enable custom code extensions, then click on "Auto Pokémon Themes" to enable this extension
   > ![image](https://user-images.githubusercontent.com/106463662/217633048-e6e3ee33-1faa-4bbd-9e23-2403d2a0ac2a.png)

## Usage

- Add each theme you want for a Pokémon to the provided `AutoThemeSets.txt` file by adding the Pokémon name and the theme string on a single line
  - The extension provides an example line by default:
  ```
    Bulbasaur 9AE1D3 9AE1D3 37E889 D4979E FFFFFF 309481 76D7C4 309481 76D7C4 309481 76D7C4 0 1
  ```
- You **must** disable and re-enable the extension for changes to take effect
- You can only add one theme per Pokémon (if you include multiple, it will use the one that is furthest down in the file)
- The extension will attempt to find the closest matching Pokémon name, if it fails the lua console output will tell you which names it failed on
