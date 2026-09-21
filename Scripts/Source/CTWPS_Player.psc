Scriptname CTWPS_Player extends ReferenceAlias
{The player alias of the Persistent Settings quest, and the only place the mod
decides anything.

Two moments, and no menu. The settings file is applied ONCE per save, the first time
the quest runs there - a new character, or an ongoing save where the mod was just
installed. It is written back when the player leaves the mod menu having changed a
Carry That Weight setting in it.}

; The globals as they were when the mod menu was opened. The write is decided against
; this, and not against the file: an older character whose settings differ from the
; file would otherwise push its own values back into it just by opening the journal.
int[] beforeShort
float[] beforeFloat
; Whether the two above hold a snapshot from the open that this close belongs to.
; They cannot answer that themselves - an array does not compare to None in Papyrus.
bool hasSnapshot

Event OnInit()
	HookMenu()
	; On a new game this runs while the game is still starting up. The delay costs
	; nothing here and keeps the apply away from that moment.
	RegisterForSingleUpdate(2.0)
EndEvent

Event OnPlayerLoadGame()
	HookMenu()
	; The snapshot belongs to the session that took it.
	hasSnapshot = false
EndEvent

; The apply, once per save.
Event OnUpdate()
	CTWPS_Manager manager = GetOwningQuest() as CTWPS_Manager
	If manager == None
		Debug.Trace("[CTWPS] the owning quest is not a CTWPS_Manager; nothing applied")
		Return
	EndIf
	If !manager.FileExists()
		Debug.Trace("[CTWPS] no settings file yet; it is written the first time the mod menu closes")
		Return
	EndIf
	If manager.ApplySettings() > 0
		Debug.Notification("Carry That Weight settings restored.")
	EndIf
EndEvent

Function HookMenu()
	; The mod menu is a page of the Journal Menu: SkyUI drives it from these same two
	; events, through its own JOURNAL_MENU constant. Measured in SkyUI_SE.bsa,
	; 2026-09-20, and not taken from memory.
	RegisterForMenu("Journal Menu")
EndFunction

Event OnMenuOpen(string a_menu)
	CTWPS_Manager manager = GetOwningQuest() as CTWPS_Manager
	If manager
		beforeShort = manager.ReadShortValues()
		beforeFloat = manager.ReadFloatValues()
		hasSnapshot = true
	EndIf
EndEvent

Event OnMenuClose(string a_menu)
	CTWPS_Manager manager = GetOwningQuest() as CTWPS_Manager
	If manager == None
		Return
	EndIf
	; A snapshot is good for the one close that follows its open. Loading a save
	; with the journal already open - its System page is where people save - would
	; otherwise close against a snapshot taken in another session.
	bool haveSnapshot = hasSnapshot
	hasSnapshot = false
	; The first write bootstraps the file, so that a player who never changes a
	; setting still gets one holding what this character is playing with.
	bool bootstrap = !manager.FileExists()
	If !bootstrap
		If !haveSnapshot
			Return
		EndIf
		If !manager.ChangedSince(beforeShort, beforeFloat)
			Return
		EndIf
	EndIf
	If manager.WriteSettings() >= 0 && !bootstrap
		Debug.Notification("Carry That Weight settings saved.")
	EndIf
EndEvent
