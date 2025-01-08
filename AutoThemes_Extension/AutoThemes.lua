local function AutoThemes()
	local self = {}

	-- ======================= METADATA =======================
    self.name = "Auto Pok" .. Constants.getC("é") .. "mon Themes"
    self.author = "Fellshadow"
    self.description = "Automatically load unique custom themes for each of your lead Pok" .. Constants.getC("é") .. "mon."
	self.version = "1.2"
	self.url = "https://github.com/Fellshadow/Ironmon-Tracker-AutoPokemonThemes"

	-- ===================== SCRIPT VARIABLES =====================
	self.themesFile = "AutoThemeSets.txt" -- The file to load themes from
	self.canRun = false 	-- Is false if emulator is not Bizhawk OR no themes loaded
	self.pokemonThemes = {} -- Maps Pokémon names to their themes
	self.defaultTheme = "" 	-- Stores the initial theme loaded by the tracker
	self.currentTheme = "" 	-- Stores the currently set tracker theme

	-- ===================== PROVIDED FUNCTIONS =====================
	-- Executed when the user clicks the "Options" button while viewing the extension details within the Tracker's UI
	-- function self.configureOptions()
		-- [IMPLEMENT LATER]
	-- end

	-- Executed when the user clicks the "Check for Updates" button while viewing the extension details within the Tracker's UI
	-- Returns [true, downloadUrl] if an update is available (downloadUrl auto opens in browser for user); otherwise returns [false, downloadUrl]
	function self.checkForUpdates()
		-- API URL for fetching the latest version tag
		local versionCheckUrl = "https://api.github.com/repos/Fellshadow/Ironmon-Tracker-AutoPokemonThemes/releases/latest"
		-- Pattern to match tag_name line and retrieve version number
		local versionResponsePattern = '"tag_name":%s+"%w+(%d+%.%d+%.?%d*)"'
		-- URL at which to download the latest version
		local downloadUrl = string.format("%s/releases/latest", self.url)

		-- Returns true if latest version is later than current version
		local function compareFunc(current, latest)
			if current == nil or current == "" or latest == nil or latest == "" then return false end

			-- Get the major/minor/patch version numbers
			local currMajor, currMinor, currPatch = string.match(current, "(%d+)%.(%d+)%.?(%d*)")
			local latestMajor, latestMinor, latestPatch = string.match(latest, "(%d+)%.(%d+)%.?(%d*)")
			-- Default patch number to 0 if it wasn't in the version number
			if currPatch == nil or currPatch == "" then currPatch = "0" end
			if latestPatch == nil or latestPatch == "" then latestPatch = "0" end

			if latestMajor > currMajor then
				return true
			elseif latestMajor == currMajor then
				if latestMinor > currMinor then
					return true
				elseif latestMinor == currMinor and latestPatch > currPatch then
					return true
				end
			end

			return false
		end

		local isUpdateAvailable = Utils.checkForVersionUpdate(versionCheckUrl, self.version, versionResponsePattern, compareFunc)

		return isUpdateAvailable, downloadUrl
	end

	-- Executed only once: when the Tracker finishes starting up and after it loads all other required files and code
	function self.startup()
		-- Extension currently only works on Bizhawk (no themes on mGBA)
		if not Main.IsOnBizhawk() then
			self.logMessage(string.format("This extension only works on Bizhawk (themes not supported on %s)", Main.emulator))
			self.canRun = false
			return
		end

		-- Set default theme to the theme that's loaded initially by the tracker
		self.defaultTheme = Theme.exportThemeToText()
		self.currentTheme = self.defaultTheme

		-- Setup the mappings for later use
		self.setupMappings()

		-- Load up the themes set for each Pokémon defined in the themes file
		self.pokemonThemes, self.canRun = self.loadThemeSets()
	end

	-- Executed only once: when the extension is disabled by the user, necessary to undo any customizations, if able
	function self.unload()
		-- Change the theme back to the default theme, if it is currently not
		if self.defaultTheme ~= "" and self.currentTheme ~= self.defaultTheme then
			self.loadTheme(self.defaultTheme)
		end
		-- Clear variables
		self.canRun = false
		self.pokemonThemes = {}
		self.defaultTheme = ""
		self.currentTheme = ""
		self.namesToIDs = nil
		collectgarbage()
	end

	-- Executed once every 30 frames, after most data from game memory is read in
	function self.afterProgramDataUpdate()
		if not self.canRun then return end

		local leadPokemon = Tracker.getPokemon(1, true)
		if leadPokemon == nil then return end

		local leadPokemonTheme = self.pokemonThemes[leadPokemon.pokemonID]
		if leadPokemonTheme ~= nil then
			-- Attempt to change the theme to the associated lead Pokémon theme
			if leadPokemonTheme ~= self.currentTheme then
				local success = self.loadTheme(leadPokemonTheme)
				if success then
					self.currentTheme = leadPokemonTheme
				end
			end
		elseif self.currentTheme ~= self.defaultTheme then
			-- Attempt to change the theme to the default theme
			local success = self.loadTheme(self.defaultTheme)
			if success then
				self.currentTheme = self.defaultTheme
			end
		end
	end

	-- =========================== CUSTOM FUNCTIONS ===========================
	-- Logs a message to the lua console, formatted as [self.name] > message
	function self.logMessage(message)
		if message == nil or message == "" then return end
		message = string.format("[%s] > %s", self.name, message)
		print(message)
	end

	-- Reads the themes file and creates a table mapping IDs to theme codes
	function self.loadThemeSets()
		local importedThemes = {}

		local customFolder = FileManager.getCustomFolderPath()
		local filepath = FileManager.getPathIfExists(customFolder .. self.themesFile)
		if filepath ~= nil then
			for _, line in ipairs(FileManager.readLinesFromFile(filepath)) do
				local firstHexIndex = line:find("%x%x%x%x%x%x")
				if firstHexIndex ~= nil and firstHexIndex > 2 then
					local themeName = line:sub(1, firstHexIndex - 2)
					local themeCode = line:sub(firstHexIndex)

					-- Get the Pokémon ID from the theme name (Pokémon name)
					local monID = self.namesToIDs[themeName:lower()]
					if PokemonData.isValid(monID) then
						themeCode = Theme.formatAsProperThemeCode(themeCode)
						importedThemes[monID] = themeCode
					else
						self.logMessage(string.format("Failed to load theme (Invalid Name): %s", themeName))
					end

				end
			end
		else
			self.logMessage(string.format("%s not found in Custom folder.", self.themesFile))
			return importedThemes, false
		end

		-- Check if themes have successfully loaded
		local next = next
		if next(importedThemes) == nil then
			self.logMessage(string.format("No themes loaded from %s, file is empty or themes are formatted incorrectly.", self.themesFile))
			return importedThemes, false
		end

		return importedThemes, true
	end

	-- Basically a copy of Theme.importThemeFromText, but does not save to Settings.ini
	function self.loadTheme(themeCode)
		if themeCode == nil or themeCode == "" then return false end

		themeCode = Theme.formatAsProperThemeCode(themeCode)

		-- A valid string has at minimum N total hex codes (7 chars each including spaces) and a two bits for boolean options
		local totalHexCodes = 11
		local themeCodeLen = string.len(themeCode)
		if themeCodeLen < (totalHexCodes * 7) then
			return false
		end

		-- Verify the theme config is correct and can be parsed (each entry should be a numerical value)
		local numHexCodes = 0
		local theme_colors = {}
		for color_text in string.gmatch(themeCode, "[^%s]+") do
			if color_text ~= nil and string.len(color_text) == 6 then
				local color = tonumber(color_text, 16)
				if color == nil or color < 0x000000 or color > 0xFFFFFF then
					return false
				end

				numHexCodes = numHexCodes + 1
				theme_colors[numHexCodes] = color_text
			end
		end

		-- Apply as much of the imported theme config to our Theme as possible, then load it
		local index = 1
		for _, colorkey in ipairs(Constants.OrderedLists.THEMECOLORS) do -- Only use the first [totalHexCodes] hex codes
			if theme_colors[index] ~= nil then
				local colorValue = 0xFF000000 + tonumber(theme_colors[index], 16)
				Theme.COLORS[colorkey] = colorValue
			end
			index = index + 1
		end

		-- Apply as many boolean options as possible, if they're available
		if themeCodeLen >= numHexCodes * 7 + 1 then
			local enableMoveTypes = not (string.sub(themeCode, numHexCodes * 7 + 1, numHexCodes * 7 + 1) == "0")
			Theme.MOVE_TYPES_ENABLED = enableMoveTypes
			Theme.Buttons.MoveTypeEnabled.toggleState = not enableMoveTypes
		end

		if themeCodeLen >= numHexCodes * 7 + 3 then
			local enableTextShadows = not (string.sub(themeCode, numHexCodes * 7 + 3, numHexCodes * 7 + 3) == "0")
			Theme.DRAW_TEXT_SHADOWS = enableTextShadows
			Theme.Buttons.DrawTextShadows.toggleState = enableTextShadows
		end

		-- Redraw the tracker to show the new theme
		Program.redraw(true)

		return true
	end

	-- Maps lower-case Pokémon names to their IDs (copy of the RandomizerLog's mappings)
	-- This is used when loading the themes from the txt file, as current lead mon is defined by ID from the tracker
	function self.setupMappings()
		self.namesToIDs = {
			-- ==================== GEN 1 ====================
			["bulbasaur"] = 1,	["ivysaur"] = 2,	["venusaur"] = 3,
			["charmander"] = 4,	["charmeleon"] = 5,	["charizard"] = 6,
			["squirtle"] = 7,	["wartortle"] = 8,	["blastoise"] = 9,
			["caterpie"] = 10,	["metapod"] = 11,	["butterfree"] = 12,
			["weedle"] = 13,	["kakuna"] = 14,	["beedrill"] = 15,
			["pidgey"] = 16,	["pidgeotto"] = 17,	["pidgeot"] = 18,
			["rattata"] = 19,	["raticate"] = 20,
			["spearow"] = 21,	["fearow"] = 22,
			["ekans"] = 23,		["arbok"] = 24,
			["pikachu"] = 25,	["raichu"] = 26,
			["sandshrew"] = 27,	["sandslash"] = 28,
			["nidoran f"] = 29,	["nidorina"] = 30,	["nidoqueen"] = 31,
			["nidoran m"] = 32,	["nidorino"] = 33,	["nidoking"] = 34,
			["clefairy"] = 35,	["clefable"] = 36,
			["vulpix"] = 37,	["ninetales"] = 38,
			["jigglypuff"] = 39,["wigglytuff"] = 40,
			["zubat"] = 41,		["golbat"] = 42,
			["oddish"] = 43,	["gloom"] = 44,		["vileplume"] = 45,
			["paras"] = 46,		["parasect"] = 47,
			["venonat"] = 48,	["venomoth"] = 49,
			["diglett"] = 50,	["dugtrio"] = 51,
			["meowth"] = 52,	["persian"] = 53,
			["psyduck"] = 54,	["golduck"] = 55,
			["mankey"] = 56,	["primeape"] = 57,
			["growlithe"] = 58,	["arcanine"] = 59,
			["poliwag"] = 60,	["poliwhirl"] = 61,	["poliwrath"] = 62,
			["abra"] = 63,		["kadabra"] = 64,	["alakazam"] = 65,
			["machop"] = 66,	["machoke"] = 67,	["machamp"] = 68,
			["bellsprout"] = 69,["weepinbell"] = 70,["victreebel"] = 71,
			["tentacool"] = 72,	["tentacruel"] = 73,
			["geodude"] = 74,	["graveler"] = 75,	["golem"] = 76,
			["ponyta"] = 77,	["rapidash"] = 78,
			["slowpoke"] = 79,	["slowbro"] = 80,
			["magnemite"] = 81,	["magneton"] = 82,
			["farfetch'd"] = 83,["farfetchd"] = 83,	["farfetch"] = 83,
			["doduo"] = 84,		["dodrio"] = 85,
			["seel"] = 86,		["dewgong"] = 87,
			["grimer"] = 88,	["muk"] = 89,
			["shellder"] = 90,	["cloyster"] = 91,
			["gastly"] = 92,	["haunter"] = 93,	["gengar"] = 94,
			["onix"] = 95,
			["drowzee"] = 96,	["hypno"] = 97,
			["krabby"] = 98,	["kingler"] = 99,
			["voltorb"] = 100,	["electrode"] = 101,
			["exeggcute"] = 102,["exeggutor"] = 103,
			["cubone"] = 104,	["marowak"] = 105,
			["hitmonlee"] = 106,["hitmonchan"] = 107,
			["lickitung"] = 108,
			["koffing"] = 109,	["weezing"] = 110,
			["rhyhorn"] = 111,	["rhydon"] = 112,
			["chansey"] = 113,
			["tangela"] = 114,	["kangaskhan"] = 115,
			["horsea"] = 116,	["seadra"] = 117,
			["goldeen"] = 118,	["seaking"] = 119,
			["staryu"] = 120,	["starmie"] = 121,
			["mr. mime"] = 122,
			["scyther"] = 123,
			["jynx"] = 124,
			["electabuzz"] = 125,
			["magmar"] = 126,
			["pinsir"] = 127,
			["tauros"] = 128,
			["magikarp"] = 129,	["gyarados"] = 130,
			["lapras"] = 131,
			["ditto"] = 132,
			["eevee"] = 133,	["vaporeon"] = 134,	["jolteon"] = 135,	["flareon"] = 136,
			["porygon"] = 137,
			["omanyte"] = 138,	["omastar"] = 139,
			["kabuto"] = 140,	["kabutops"] = 141,
			["aerodactyl"] = 142,
			["snorlax"] = 143,
			["articuno"] = 144,
			["zapdos"] = 145,
			["moltres"] = 146,
			["dratini"] = 147,	["dragonair"] = 148,["dragonite"] = 149,
			["mewtwo"] = 150,	["mew"] = 151,
			-- ==================== GEN 2 ====================
			["chikorita"] = 152,["bayleef"] = 153,	["meganium"] = 154,
			["cyndaquil"] = 155,["quilava"] = 156,	["typhlosion"] = 157,
			["totodile"] = 158,	["croconaw"] = 159,	["feraligatr"] = 160,
			["sentret"] = 161,	["furret"] = 162,
			["hoothoot"] = 163,	["noctowl"] = 164,
			["ledyba"] = 165,	["ledian"] = 166,
			["spinarak"] = 167,	["ariados"] = 168,
			["crobat"] = 169,
			["chinchou"] = 170,	["lanturn"] = 171,
			["pichu"] = 172,
			["cleffa"] = 173,
			["igglybuff"] = 174,
			["togepi"] = 175,	["togetic"] = 176,
			["natu"] = 177,		["xatu"] = 178,
			["mareep"] = 179,	["flaaffy"] = 180,	["ampharos"] = 181,
			["bellossom"] = 182,
			["marill"] = 183,	["azumarill"] = 184,
			["sudowoodo"] = 185,
			["politoed"] = 186,
			["hoppip"] = 187,	["skiploom"] = 188,	["jumpluff"] = 189,
			["aipom"] = 190,
			["sunkern"] = 191,	["sunflora"] = 192,
			["yanma"] = 193,
			["wooper"] = 194,	["quagsire"] = 195,
			["espeon"] = 196,	["umbreon"] = 197,
			["murkrow"] = 198,
			["slowking"] = 199,
			["misdreavus"] = 200,
			["unown"] = 201,
			["wobbuffet"] = 202,
			["girafarig"] = 203,
			["pineco"] = 204,	["forretress"] = 205,
			["dunsparce"] = 206,
			["gligar"] = 207,
			["steelix"] = 208,
			["snubbull"] = 209,	["granbull"] = 210,
			["qwilfish"] = 211,
			["scizor"] = 212,
			["shuckle"] = 213,
			["heracross"] = 214,
			["sneasel"] = 215,
			["teddiursa"] = 216,["ursaring"] = 217,
			["slugma"] = 218,	["magcargo"] = 219,
			["swinub"] = 220,	["piloswine"] = 221,
			["corsola"] = 222,
			["remoraid"] = 223,	["octillery"] = 224,
			["delibird"] = 225,
			["mantine"] = 226,
			["skarmory"] = 227,
			["houndour"] = 228,	["houndoom"] = 229,
			["kingdra"] = 230,
			["phanpy"] = 231,	["donphan"] = 232,
			["porygon2"] = 233,
			["stantler"] = 234,
			["smeargle"] = 235,
			["tyrogue"] = 236,	["hitmontop"] = 237,
			["smoochum"] = 238,
			["elekid"] = 239,
			["magby"] = 240,
			["miltank"] = 241,
			["blissey"] = 242,
			["raikou"] = 243,
			["entei"] = 244,
			["suicune"] = 245,
			["larvitar"] = 246,	["pupitar"] = 247,	["tyranitar"] = 248,
			["lugia"] = 249,
			["ho-oh"] = 250,
			["celebi"] = 251,
			-- ==================== GEN 3 ====================
			["treecko"] = 277,	["grovyle"] = 278,	["sceptile"] = 279,
			["torchic"] = 280,	["combusken"] = 281,["blaziken"] = 282,
			["mudkip"] = 283,	["marshtomp"] = 284,["swampert"] = 285,
			["poochyena"] = 286,["mightyena"] = 287,
			["zigzagoon"] = 288,["linoone"] = 289,
			["wurmple"] = 290,
			["silcoon"] = 291,	["beautifly"] = 292,
			["cascoon"] = 293,	["dustox"] = 294,
			["lotad"] = 295,	["lombre"] = 296,	["ludicolo"] = 297,
			["seedot"] = 298,	["nuzleaf"] = 299,	["shiftry"] = 300,
			["nincada"] = 301,	["ninjask"] = 302,	["shedinja"] = 303,
			["taillow"] = 304,	["swellow"] = 305,
			["shroomish"] = 306,["breloom"] = 307,
			["spinda"] = 308,
			["wingull"] = 309,	["pelipper"] = 310,
			["surskit"] = 311,	["masquerain"] = 312,
			["wailmer"] = 313,	["wailord"] = 314,
			["skitty"] = 315,	["delcatty"] = 316,
			["kecleon"] = 317,
			["baltoy"] = 318,	["claydol"] = 319,
			["nosepass"] = 320,
			["torkoal"] = 321,
			["sableye"] = 322,
			["barboach"] = 323,	["whiscash"] = 324,
			["luvdisc"] = 325,
			["corphish"] = 326,	["crawdaunt"] = 327,
			["feebas"] = 328,	["milotic"] = 329,
			["carvanha"] = 330,	["sharpedo"] = 331,
			["trapinch"] = 332,	["vibrava"] = 333,	["flygon"] = 334,
			["makuhita"] = 335,	["hariyama"] = 336,
			["electrike"] = 337,["manectric"] = 338,
			["numel"] = 339,	["camerupt"] = 340,
			["spheal"] = 341,	["sealeo"] = 342,	["walrein"] = 343,
			["cacnea"] = 344,	["cacturne"] = 345,
			["snorunt"] = 346,	["glalie"] = 347,
			["lunatone"] = 348,
			["solrock"] = 349,
			["azurill"] = 350,
			["spoink"] = 351,	["grumpig"] = 352,
			["plusle"] = 353,
			["minun"] = 354,
			["mawile"] = 355,
			["meditite"] = 356,	["medicham"] = 357,
			["swablu"] = 358,	["altaria"] = 359,
			["wynaut"] = 360,
			["duskull"] = 361,	["dusclops"] = 362,
			["roselia"] = 363,
			["slakoth"] = 364,	["vigoroth"] = 365,	["slaking"] = 366,
			["gulpin"] = 367,	["swalot"] = 368,
			["tropius"] = 369,
			["whismur"] = 370,	["loudred"] = 371,	["exploud"] = 372,
			["clamperl"] = 373,	["huntail"] = 374,	["gorebyss"] = 375,
			["absol"] = 376,
			["shuppet"] = 377,	["banette"] = 378,
			["seviper"] = 379,
			["zangoose"] = 380,
			["relicanth"] = 381,
			["aron"] = 382,		["lairon"] = 383,	["aggron"] = 384,
			["castform"] = 385,
			["volbeat"] = 386,
			["illumise"] = 387,
			["lileep"] = 388,	["cradily"] = 389,
			["anorith"] = 390,	["armaldo"] = 391,
			["ralts"] = 392,	["kirlia"] = 393,	["gardevoir"] = 394,
			["bagon"] = 395,	["shelgon"] = 396,	["salamence"] = 397,
			["beldum"] = 398,	["metang"] = 399,	["metagross"] = 400,
			["regirock"] = 401,
			["regice"] = 402,
			["registeel"] = 403,
			["kyogre"] = 404,
			["groudon"] = 405,
			["rayquaza"] = 406,
			["latias"] = 407,
			["latios"] = 408,
			["jirachi"] = 409,
			["deoxys"] = 410,
			["chimecho"] = 411,
		}
	end

	return self
end
return AutoThemes