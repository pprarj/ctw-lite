Scriptname CTWSL_MCM extends SKI_ConfigBase
{Carry That Weight Settings Loader - saves the 29 configurable globals of Carry That
Weight to a JSON file and loads them back, from a button or automatically once per
save. Works with the original and with CTW Lite: it only touches the globals and the
updater spell of CarryThatWeight_MrPMG.esp. ModName and Pages are set in the plugin.}

Actor Property PlayerRef Auto
Spell Property CapacityUpdaterSpell Auto
{The ability whose effect recalculates carry weight when it starts, in both mods.}
GlobalVariable[] Property ShortGlobals Auto
{The short globals, in the order of ShortKeys().}
GlobalVariable[] Property FloatGlobals Auto
{The float globals, in the order of FloatKeys().}

; Under Data\SKSE\Plugins\StorageUtilData\; JsonUtil appends .json.
string Property SETTINGS_FILE = "CarryThatWeight_SettingsLoader" AutoReadOnly
string Property AUTOLOAD_KEY = "ctwsl_autoload" AutoReadOnly
string Property FORMAT_KEY = "ctwsl_format" AutoReadOnly

; Set the first time the automatic load is decided in this save, whatever the outcome.
bool autoloadDecided = false

; SkyUI calls this when it sets up this menu, which happens once per save: on a new
; game, or on the first load after the Settings Loader is installed.
Event OnConfigInit()
	If autoloadDecided
		Return
	EndIf
	autoloadDecided = true
	string problem = OpenSettingsFile()
	If problem != ""
		Debug.Trace("[CTWSL] automatic load skipped: " + problem)
	ElseIf !AutoloadEnabled()
		Debug.Trace("[CTWSL] automatic load skipped: turned off")
	Else
		ApplySettings()
	EndIf
EndEvent

Event OnPageReset(string a_page)
	AddTextOptionST("SaveSettings", "Save settings", "")
	AddTextOptionST("LoadSettings", "Load settings", "")
	AddToggleOptionST("AutoloadToggle", "Load automatically on new game", AutoloadEnabled())
EndEvent

State SaveSettings
	Event OnSelectST()
		If JsonUtil.JsonExists(SETTINGS_FILE)
			; Keeps the automatic load choice already in the file.
			JsonUtil.Load(SETTINGS_FILE)
		EndIf
		string[] jsonKeys = ShortKeys()
		int saved = 0
		int i = 0
		While i < jsonKeys.Length
			JsonUtil.SetIntValue(SETTINGS_FILE, jsonKeys[i], ShortGlobals[i].GetValue() as int)
			saved += 1
			i += 1
		EndWhile
		jsonKeys = FloatKeys()
		i = 0
		While i < jsonKeys.Length
			JsonUtil.SetFloatValue(SETTINGS_FILE, jsonKeys[i], FloatGlobals[i].GetValue())
			saved += 1
			i += 1
		EndWhile
		JsonUtil.SetIntValue(SETTINGS_FILE, FORMAT_KEY, 1)
		; Written now: an unsaved change is dropped if another save is loaded first.
		If JsonUtil.Save(SETTINGS_FILE)
			ShowMessage("Saved " + saved + " settings to Data/SKSE/Plugins/StorageUtilData/CarryThatWeight_SettingsLoader.json", false)
		Else
			ShowMessage("Could not save the settings file. " + JsonUtil.GetErrors(SETTINGS_FILE), false)
		EndIf
	EndEvent

	Event OnHighlightST()
		SetInfoText("Write the current Carry That Weight settings to the settings file. The automatic load choice is kept.")
	EndEvent
EndState

State LoadSettings
	Event OnSelectST()
		string problem = OpenSettingsFile()
		If problem != ""
			ShowMessage(problem, false)
			Return
		EndIf
		If !ShowMessage("Load the settings file? The current Carry That Weight settings are replaced by the ones in the file.", true)
			Return
		EndIf
		int applied = ApplySettings()
		ShowMessage("Loaded " + applied + " settings from the settings file.", false)
	EndEvent

	Event OnHighlightST()
		SetInfoText("Apply the settings file now. Settings missing from the file are left as they are.")
	EndEvent
EndState

State AutoloadToggle
	Event OnSelectST()
		If JsonUtil.JsonExists(SETTINGS_FILE)
			JsonUtil.Load(SETTINGS_FILE)
		EndIf
		bool enable = !AutoloadEnabled()
		int value = 0
		If enable
			value = 1
		EndIf
		JsonUtil.SetIntValue(SETTINGS_FILE, AUTOLOAD_KEY, value)
		; Written now, so the choice holds for a new game started without saving this one.
		If JsonUtil.Save(SETTINGS_FILE)
			SetToggleOptionValueST(enable)
		Else
			ShowMessage("Could not save the settings file. " + JsonUtil.GetErrors(SETTINGS_FILE), false)
		EndIf
	EndEvent

	Event OnHighlightST()
		SetInfoText("Apply the settings file once in each save, the first time this menu is set up there: a new game, or an ongoing save where the Settings Loader was just installed. It is never applied again by itself.")
	EndEvent
EndState

; Reads the file from disk. Returns "" when it can be used, or why it cannot.
string Function OpenSettingsFile()
	If !JsonUtil.JsonExists(SETTINGS_FILE)
		Return "No settings file yet. Use Save settings first."
	EndIf
	JsonUtil.Load(SETTINGS_FILE)
	If !JsonUtil.IsGood(SETTINGS_FILE)
		Return "The settings file could not be read. " + JsonUtil.GetErrors(SETTINGS_FILE)
	EndIf
	Return ""
EndFunction

bool Function AutoloadEnabled()
	Return JsonUtil.GetIntValue(SETTINGS_FILE, AUTOLOAD_KEY) == 1
EndFunction

; Applies every key present in the file; a missing key leaves its global alone.
int Function ApplySettings()
	int applied = 0
	string[] jsonKeys = ShortKeys()
	int i = 0
	While i < jsonKeys.Length
		If JsonUtil.HasIntValue(SETTINGS_FILE, jsonKeys[i])
			ShortGlobals[i].SetValue(JsonUtil.GetIntValue(SETTINGS_FILE, jsonKeys[i]))
			applied += 1
		EndIf
		i += 1
	EndWhile
	jsonKeys = FloatKeys()
	i = 0
	While i < jsonKeys.Length
		If JsonUtil.HasFloatValue(SETTINGS_FILE, jsonKeys[i])
			FloatGlobals[i].SetValue(JsonUtil.GetFloatValue(SETTINGS_FILE, jsonKeys[i]))
			applied += 1
		EndIf
		i += 1
	EndWhile

	; The effect of both mods recalculates when it starts. Without the spell, the
	; original was turned off in its own menu, and re-adding it would turn it back on.
	bool readded = false
	If PlayerRef.HasSpell(CapacityUpdaterSpell)
		PlayerRef.RemoveSpell(CapacityUpdaterSpell)
		PlayerRef.AddSpell(CapacityUpdaterSpell, false)
		readded = true
	EndIf
	Debug.Trace("[CTWSL] applied " + applied + " settings, updater spell re-added=" + readded)
	Return applied
EndFunction

; JSON keys for ShortGlobals, same index. Fixed literals: never build a key by concatenation.
string[] Function ShortKeys()
	string[] jsonKeys = new string[26]
	jsonKeys[0] = "ctwsl_capacity_base"
	jsonKeys[1] = "ctwsl_capacity_per_level"
	jsonKeys[2] = "ctwsl_limmax0"
	jsonKeys[3] = "ctwsl_limmax1"
	jsonKeys[4] = "ctwsl_limmax2"
	jsonKeys[5] = "ctwsl_limmax3"
	jsonKeys[6] = "ctwsl_limmax4"
	jsonKeys[7] = "ctwsl_limmax5"
	jsonKeys[8] = "ctwsl_limpen0"
	jsonKeys[9] = "ctwsl_limpen1"
	jsonKeys[10] = "ctwsl_limpen3"
	jsonKeys[11] = "ctwsl_limpen4"
	jsonKeys[12] = "ctwsl_speed_c1"
	jsonKeys[13] = "ctwsl_speed_c2"
	jsonKeys[14] = "ctwsl_speed_s1"
	jsonKeys[15] = "ctwsl_speed_s2"
	jsonKeys[16] = "ctwsl_stamina_c1"
	jsonKeys[17] = "ctwsl_stamina_c2"
	jsonKeys[18] = "ctwsl_stamina_s1"
	jsonKeys[19] = "ctwsl_stamina_s2"
	jsonKeys[20] = "ctwsl_stealth_c1"
	jsonKeys[21] = "ctwsl_stealth_c2"
	jsonKeys[22] = "ctwsl_stealth_s1"
	jsonKeys[23] = "ctwsl_stealth_s2"
	jsonKeys[24] = "ctwsl_update_interval"
	jsonKeys[25] = "ctwsl_pester_interval"
	Return jsonKeys
EndFunction

; JSON keys for FloatGlobals, same index.
string[] Function FloatKeys()
	string[] jsonKeys = new string[3]
	jsonKeys[0] = "ctwsl_capacity_per_stamina"
	jsonKeys[1] = "ctwsl_limpen2"
	jsonKeys[2] = "ctwsl_limpen5"
	Return jsonKeys
EndFunction
