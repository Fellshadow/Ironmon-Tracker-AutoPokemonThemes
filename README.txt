Auto Pokémon Themes for the gen 3 Ironmon Tracker by Fellshadow

Requirements:
- Ironmon-Tracker v7.3.0 or higher
- Bizhawk 2.8 or higher (themes are not possible on the mGBA tracker)

To Install:
1. Copy the contents of the "AutoThemes_Extension" folder into the "extensions" folder of your tracker.
2. On the tracker settings menu (click the gear icon on the tracker window), navigate to "Extensions" and enable "Allow custom code t run" (if it is currently disabled).
3. On the Extensions menu, click on the "Install New" button at the bottom to check for installed extensions.
   - "Auto Pokémon Themes" should now appear on the extensions list.
   - If it doesn't show up, double-check the extension files are installed in the right location.
4. Click on the "Auto Pokémon Themes" button to go to the extension's page.
5. From here, you can enable the extension, view it online, or check for updates.


Usage:
- As of v1.2, the AutoThemeSets.txt file that comes with the extension has a theme for every Pokémon (from the NDS tracker).
  - If you wish to edit / remove any, simply change the theme string next to the Pokémon's name (or remove the line entirely).
  - Each line should be the Pokémon name (in English) followed by the theme string, e.g.
    Bulbasaur 9AE1D3 9AE1D3 37E889 D4979E FFFFFF 309481 76D7C4 309481 76D7C4 309481 76D7C4 0 1
- If the tracker is running, you must disable and re-enable the extension for changes to take effect.
- You can only add one theme per Pokémon (if you include multiple, it will use the one that is furthest down in the file).
- If the extension fails to load a particular theme, it will output an error message to the lua console to inform you.

As you play the game the "AutoThemes.lua" script will automatically load the associated theme for your lead Pokémon, if there is one.
It will default back to the theme you have saved in your tracker Settings.ini file whenever there isn't a matching lead Pokémon.

This script is written to try and avoid overwriting the theme in your Settings.ini file.
However, the tracker will show an auto-theme as a custom theme if you open the theme settings while one is loaded.
If you then make any changes on that menu then it *will* save the theme to your Settings.ini.