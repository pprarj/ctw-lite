Scriptname CTWPS_Manager extends Quest
{Carry That Weight - Persistent Settings. Keeps the 29 configurable globals of Carry
That Weight in a file outside the save, so a new character starts with the settings
the player already chose.

This script has no menu and no events: it is the store, and CTWPS_Player on the
player alias is what decides when to read and when to write.

It works with the original alone and with CTW Lite, because it only ever touches the
globals and the updater spell of CarryThatWeight_MrPMG.esp - never either mod's own
scripts, quests or menus.}

Actor Property PlayerRef Auto
Spell Property CapacityUpdaterSpell Auto
{The ability whose effect recalculates carry weight when it starts, in both mods.}
GlobalVariable[] Property ShortGlobals Auto
{The short globals, in the order of ShortKeys().}
GlobalVariable[] Property FloatGlobals Auto
{The float globals, in the order of FloatKeys().}

; Under Data\SKSE\Plugins\StorageUtilData\; JsonUtil appends .json. Under MO2 the
; write lands in the overwrite folder, and not in the mod folder - measured 2026-09-20.
string Property SETTINGS_FILE = "CarryThatWeight_PersistentSettings" AutoReadOnly
string Property FORMAT_KEY = "ctwps_format" AutoReadOnly

; A float read back is the same 32-bit value that was written, so an equality would
; work here. It is still not written as one: the file is text a player may edit.
float Property FLOAT_EPSILON = 0.0001 AutoReadOnly

bool Function FileExists()
	Return JsonUtil.JsonExists(SETTINGS_FILE)
EndFunction

; Reads the file from disk. Returns "" when it can be used, or why it cannot.
string Function OpenSettingsFile()
	If !JsonUtil.JsonExists(SETTINGS_FILE)
		Return "no settings file yet"
	EndIf
	JsonUtil.Load(SETTINGS_FILE)
	If !JsonUtil.IsGood(SETTINGS_FILE)
		Return "the settings file could not be read: " + JsonUtil.GetErrors(SETTINGS_FILE)
	EndIf
	Return ""
EndFunction

; Applies every key present in the file; a missing key leaves its global alone.
; Returns how many were applied, or -1 when the file could not be read.
int Function ApplySettings()
	string problem = OpenSettingsFile()
	If problem != ""
		Debug.Trace("[CTWPS] nothing applied: " + problem)
		Return -1
	EndIf

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
	Debug.Trace("[CTWPS] applied " + applied + " settings, updater spell re-added=" + readded)
	Return applied
EndFunction

; Writes every global to the file. Returns how many, or -1 when the write failed.
int Function WriteSettings()
	int saved = 0
	string[] jsonKeys = ShortKeys()
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

	; Written to disk now: an unsaved change is lost when another save is loaded.
	If !JsonUtil.Save(SETTINGS_FILE)
		Debug.Trace("[CTWPS] could not write the settings file: " + JsonUtil.GetErrors(SETTINGS_FILE))
		Return -1
	EndIf
	Debug.Trace("[CTWPS] wrote " + saved + " settings to the settings file")
	Return saved
EndFunction

int[] Function ReadShortValues()
	int[] values = new int[26]
	int i = 0
	While i < values.Length
		values[i] = ShortGlobals[i].GetValue() as int
		i += 1
	EndWhile
	Return values
EndFunction

float[] Function ReadFloatValues()
	float[] values = new float[3]
	int i = 0
	While i < values.Length
		values[i] = FloatGlobals[i].GetValue()
		i += 1
	EndWhile
	Return values
EndFunction

; True when a global no longer holds the value it had in the given snapshot. A
; snapshot of the wrong size answers false: not knowing whether the player changed
; anything is not a reason to overwrite the file.
;
; The caller says whether it has a snapshot at all, because an array cannot be
; compared to None here: the guard that used to live on the next line logged
; "Cannot cast from None to Int[]" on every single call, whether or not the array
; was filled. Measured 2026-09-20 against the vanilla scripts: of the 99 that
; declare an array, none compares one to None.
bool Function ChangedSince(int[] beforeShort, float[] beforeFloat)
	If beforeShort.Length != ShortGlobals.Length || beforeFloat.Length != FloatGlobals.Length
		Return false
	EndIf
	int i = 0
	While i < beforeShort.Length
		If ShortGlobals[i].GetValue() as int != beforeShort[i]
			Return true
		EndIf
		i += 1
	EndWhile
	i = 0
	While i < beforeFloat.Length
		If Math.Abs(FloatGlobals[i].GetValue() - beforeFloat[i]) > FLOAT_EPSILON
			Return true
		EndIf
		i += 1
	EndWhile
	Return false
EndFunction

; JSON keys for ShortGlobals, same index. Fixed literals: never build a key by concatenation.
string[] Function ShortKeys()
	string[] jsonKeys = new string[26]
	jsonKeys[0] = "ctwps_capacity_base"
	jsonKeys[1] = "ctwps_capacity_per_level"
	jsonKeys[2] = "ctwps_limmax0"
	jsonKeys[3] = "ctwps_limmax1"
	jsonKeys[4] = "ctwps_limmax2"
	jsonKeys[5] = "ctwps_limmax3"
	jsonKeys[6] = "ctwps_limmax4"
	jsonKeys[7] = "ctwps_limmax5"
	jsonKeys[8] = "ctwps_limpen0"
	jsonKeys[9] = "ctwps_limpen1"
	jsonKeys[10] = "ctwps_limpen3"
	jsonKeys[11] = "ctwps_limpen4"
	jsonKeys[12] = "ctwps_speed_c1"
	jsonKeys[13] = "ctwps_speed_c2"
	jsonKeys[14] = "ctwps_speed_s1"
	jsonKeys[15] = "ctwps_speed_s2"
	jsonKeys[16] = "ctwps_stamina_c1"
	jsonKeys[17] = "ctwps_stamina_c2"
	jsonKeys[18] = "ctwps_stamina_s1"
	jsonKeys[19] = "ctwps_stamina_s2"
	jsonKeys[20] = "ctwps_stealth_c1"
	jsonKeys[21] = "ctwps_stealth_c2"
	jsonKeys[22] = "ctwps_stealth_s1"
	jsonKeys[23] = "ctwps_stealth_s2"
	jsonKeys[24] = "ctwps_update_interval"
	jsonKeys[25] = "ctwps_pester_interval"
	Return jsonKeys
EndFunction

; JSON keys for FloatGlobals, same index.
string[] Function FloatKeys()
	string[] jsonKeys = new string[3]
	jsonKeys[0] = "ctwps_capacity_per_stamina"
	jsonKeys[1] = "ctwps_limpen2"
	jsonKeys[2] = "ctwps_limpen5"
	Return jsonKeys
EndFunction
