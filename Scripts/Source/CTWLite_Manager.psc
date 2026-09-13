Scriptname CTWLite_Manager extends Quest
{CTW Lite - carry weight manager. Recalculates CarryWeight from the three capacity
globals of Carry That Weight, removes the spells the original left on the player,
and keeps the updater effect on the player running this mod's effect script.}

; Formula and floor adapted from Carry That Weight by MrPMG (CC BY-SA 4.0),
; __pmg_CapacityTools_Manager.psc lines 201-202 and 246-248, without the limiter.

Actor Property PlayerRef Auto
GlobalVariable Property TargetCapacityBase Auto
GlobalVariable Property TargetCapacityPerLevel Auto
GlobalVariable Property TargetCapacityPerStamina Auto
Spell Property CapacityUpdaterSpell Auto
{The ability that carries CTWLite_Effect on the player.}
Spell[] Property LeftoverSpells Auto
{The display and buff/debuff spells of the original, which the Lite does not manage.}

; Set once the updater spell was re-added under this script. A save that ran the
; original already has the spell, applied while its effect ran the original script.
bool updaterRefreshed = false

Event OnInit()
	RunMaintenance()
EndEvent

; Both entry paths call this: OnInit on a new game, and CTWLite_MCM.OnGameReload on
; every save load. Every step is safe to repeat.
Function RunMaintenance()
	RemoveLeftoverSpells()
	EnsureUpdaterEffect()
	Recalculate()
EndFunction

Function Recalculate()
	float capacityBase = TargetCapacityBase.GetValue()
	float perLevel = TargetCapacityPerLevel.GetValue()
	float perStamina = TargetCapacityPerStamina.GetValue()
	float baseStamina = PlayerRef.GetBaseActorValue("Stamina")
	int playerLevel = PlayerRef.GetLevel()

	float targetWeight = capacityBase + perLevel * playerLevel + perStamina * baseStamina
	; Offsets the carry weight the engine grants for stamina chosen at level-up.
	targetWeight -= 0.5 * (baseStamina - 100.0)
	If targetWeight <= 1.0
		targetWeight = 1.0
	EndIf

	int newCarryWeight = targetWeight as int
	PlayerRef.SetActorValue("CarryWeight", newCarryWeight)
	Debug.Trace("[CTWLite] base=" + capacityBase + " perLevel=" + perLevel + " perStamina=" + perStamina + " baseStamina=" + baseStamina + " level=" + playerLevel + " carryWeight=" + newCarryWeight)
EndFunction

Function RemoveLeftoverSpells()
	int i = LeftoverSpells.Length
	While i > 0
		i -= 1
		PlayerRef.RemoveSpell(LeftoverSpells[i])
	EndWhile
EndFunction

Function EnsureUpdaterEffect()
	If updaterRefreshed && PlayerRef.HasSpell(CapacityUpdaterSpell)
		Return
	EndIf
	updaterRefreshed = true
	; Removing first makes the effect start again, with CTWLite_Effect.
	PlayerRef.RemoveSpell(CapacityUpdaterSpell)
	PlayerRef.AddSpell(CapacityUpdaterSpell, false)
EndFunction
