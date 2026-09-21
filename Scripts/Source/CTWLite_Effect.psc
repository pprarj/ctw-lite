Scriptname CTWLite_Effect extends ActiveMagicEffect
{CTW Lite - lives on the player through the updater spell and asks the manager to
recalculate on the few events that change the inputs of the formula. It has no
inventory or equip events.}

CTWLite_Manager Property Manager Auto

string Property STATS_MENU = "StatsMenu" AutoReadOnly
string Property LEVELUP_MENU = "LevelUp Menu" AutoReadOnly

; Persistent Settings re-adds the updater spell to apply settings, and relies on
; this event recalculating.
Event OnEffectStart(Actor akTarget, Actor akCaster)
	RegisterMenus()
	Manager.Recalculate()
EndEvent

Event OnPlayerLoadGame()
	; Menu registrations do not survive a load.
	RegisterMenus()
	Manager.Recalculate()
EndEvent

Event OnRaceSwitchComplete()
	Manager.Recalculate()
EndEvent

; Level-up: the stamina choice is made inside these menus.
Event OnMenuClose(string menuName)
	If menuName == STATS_MENU || menuName == LEVELUP_MENU
		Manager.Recalculate()
	EndIf
EndEvent

Function RegisterMenus()
	RegisterForMenu(STATS_MENU)
	RegisterForMenu(LEVELUP_MENU)
EndFunction
