scriptname __pmg_CapacityTools_MCM extends SKI_ConfigBase

; Modified copy of __pmg_CapacityTools_MCM.psc from Carry That Weight by MrPMG,
; used under CC BY-SA 4.0 by the Carry That Weight Settings Loader. The only change
; is the OnConfigOpen event after OnVersionUpdate, which refreshes the values this
; menu shows from the globals before it draws.

Actor property PlayerRef auto

__pmg_CapacityTools_Manager property manager auto

GlobalVariable property __pmg_TargetCapacityBase auto
GlobalVariable property __pmg_TargetCapacityPerLevel auto
GlobalVariable property __pmg_TargetCapacityPerStamina auto

GlobalVariable[] property __pmg_LimiterMaximumNumber auto
GlobalVariable[] property __pmg_LimiterPenalty auto

bool ForceClearCarryModifiers = False
bool ModEnabled = True

GlobalVariable property __pmg_Capacity_UpdateInterval auto ; should be longish, it's just a safety check in case the event handling gets confused
int UpdateInterval = 300
int UpdateIntervalDefault = 300

GlobalVariable property __pmg_Capacity_PesterInterval auto
int PesterInterval = 150
int PesterIntervalDefault = 150

int MCM_TargetCapacityBase_Default = 250
int MCM_TargetCapacityPerLevel_Default = 0
float MCM_TargetCapacityPerStamina_Default = 0.5

int MCM_TargetCapacityBase = 250
int MCM_TargetCapacityPerLevel = 0
float MCM_TargetCapacityPerStamina = 0.5

; Index info for limiter:
; 0: ammo -- (quiver)
; 1: potions/poisons, food/drink -- (satchel)
; 2: 0 <= W < 0.9 excluding ammo & potions (pouches and satchels: gems, small ingredients, lock-picks)
; 3: 0.9 <= W < 9 excluding shields (bags and belt: ingots, daggers, books, robes, most non-chest armor, most light chest armor)
; 4: 9 <= W and shields (large item straps: non-dagger weapons, most heavy chest armor)
; 5: gold (coin purse)
; -1: other things that should not be counted, e.g., equipped armor

int Amount0_Default = 75
int Amount1_Default = 10
int Amount2_Default = 30
int Amount3_Default = 10
int Amount4_Default = 5
int Amount5_Default = 1000

int Penalty0_Default = 5
int Penalty1_Default = 5
float Penalty2_Default = 0.5
int Penalty3_Default = 10
int Penalty4_Default = 100
float Penalty5_Default = 0.2

int Amount0= 75
int Amount1= 10
int Amount2= 20
int Amount3= 10
int Amount4= 5
int Amount5 = 1000

int Penalty0 = 5
int Penalty1 = 5
float Penalty2 = 0.5
int Penalty3 = 10
int Penalty4 = 100
float Penalty5 = 0.2


GlobalVariable property __pmg_Speed_C1 auto ; the C1,C2 globals are short ints in the range 0-100
GlobalVariable property __pmg_Speed_C2 auto
GlobalVariable property __pmg_Speed_S1 auto ; int = speedmult buff/debuff (CK uses a percentage, not a fraction)
GlobalVariable property __pmg_Speed_S2 auto

int SpeedC1_Default = 0
int SpeedC2_Default = 100
int SpeedS1_Default = 15
int SpeedS2_Default = -15

int SpeedC1 = 0
int SpeedC2 = 100
int SpeedS1 = 15
int SpeedS2 = -15

GlobalVariable property __pmg_Stamina_C1 auto
GlobalVariable property __pmg_Stamina_C2 auto
GlobalVariable property __pmg_Stamina_S1 auto ; int = flat stamina buff/debuff
GlobalVariable property __pmg_Stamina_S2 auto

int StaminaC1_Default = 0
int StaminaC2_Default = 100
int StaminaS1_Default = 15
int StaminaS2_Default = -15

int StaminaC1 = 0
int StaminaC2 = 100
int StaminaS1 = 15
int StaminaS2 = -15

GlobalVariable property __pmg_Stealth_C1 auto
GlobalVariable property __pmg_Stealth_C2 auto
GlobalVariable property __pmg_Stealth_S1 auto ; int = flat sneak skill buff/debuff
GlobalVariable property __pmg_Stealth_S2 auto

int StealthC1_Default = 0
int StealthC2_Default = 100
int StealthS1_Default = 15
int StealthS2_Default = -15

int StealthC1 = 0
int StealthC2 = 100
int StealthS1 = 15
int StealthS2 = -15

int function GetVersion()
   return 5
endFunction

event OnVersionUpdate(Int aiNewVersion)
    manager.Stop()

    if (aiNewVersion > 1)
        Debug.Notification("Updating Carry That Weight . . .")
        manager.Update1()
		manager.Update2()
		manager.Update3()
    endIf

   manager.Start()
   Debug.Notification("Done Updating Carry That Weight.")
endEvent

; Carry That Weight Settings Loader: the menu shows private copies of the globals,
; so copy the globals in first and show what another script wrote to them.
; __pmg_Capacity_UpdateInterval is left out on purpose: the original plugin does not
; bind that property, so it is None at runtime and reading it would log an error.
event OnConfigOpen()
	MCM_TargetCapacityBase = __pmg_TargetCapacityBase.GetValue() as int
	MCM_TargetCapacityPerLevel = __pmg_TargetCapacityPerLevel.GetValue() as int
	MCM_TargetCapacityPerStamina = __pmg_TargetCapacityPerStamina.GetValue()

	Amount0 = __pmg_LimiterMaximumNumber[0].GetValue() as int
	Amount1 = __pmg_LimiterMaximumNumber[1].GetValue() as int
	Amount2 = __pmg_LimiterMaximumNumber[2].GetValue() as int
	Amount3 = __pmg_LimiterMaximumNumber[3].GetValue() as int
	Amount4 = __pmg_LimiterMaximumNumber[4].GetValue() as int
	Amount5 = __pmg_LimiterMaximumNumber[5].GetValue() as int

	Penalty0 = __pmg_LimiterPenalty[0].GetValue() as int
	Penalty1 = __pmg_LimiterPenalty[1].GetValue() as int
	Penalty2 = __pmg_LimiterPenalty[2].GetValue()
	Penalty3 = __pmg_LimiterPenalty[3].GetValue() as int
	Penalty4 = __pmg_LimiterPenalty[4].GetValue() as int
	Penalty5 = __pmg_LimiterPenalty[5].GetValue()

	SpeedC1 = __pmg_Speed_C1.GetValue() as int
	SpeedC2 = __pmg_Speed_C2.GetValue() as int
	SpeedS1 = __pmg_Speed_S1.GetValue() as int
	SpeedS2 = __pmg_Speed_S2.GetValue() as int

	StaminaC1 = __pmg_Stamina_C1.GetValue() as int
	StaminaC2 = __pmg_Stamina_C2.GetValue() as int
	StaminaS1 = __pmg_Stamina_S1.GetValue() as int
	StaminaS2 = __pmg_Stamina_S2.GetValue() as int

	StealthC1 = __pmg_Stealth_C1.GetValue() as int
	StealthC2 = __pmg_Stealth_C2.GetValue() as int
	StealthS1 = __pmg_Stealth_S1.GetValue() as int
	StealthS2 = __pmg_Stealth_S2.GetValue() as int

	PesterInterval = __pmg_Capacity_PesterInterval.GetValue() as int
endEvent

event OnConfigClose()
	if (ModEnabled)
		if (!manager.IsRunning())
			manager.Start()
		endIf
		manager.EnableMod()
		if (ForceClearCarryModifiers)
			Debug.Notification("Clearing carry weight modifiers.")
			PlayerRef.ForceActorValue("CarryWeight",PlayerRef.GetBaseActorValue("CarryWeight"))
		endIf
		ForceClearCarryModifiers = False ; we don't want to clear these every time because sometimes the player has feather effects
		Debug.Notification("Beginning carry weight update due to MCM access.")
		manager.UpdateCapacity(True,0) ; true means we go through the whole inventory to recalculate
		Debug.Notification("Carry weight update due to MCM access complete.")
	else
		manager.DisableMod()
		manager.Stop()
	endIf
endEvent

Function OnPageReset(String page)
	if (page == "Limiter Settings")
		if (ModEnabled)
			AddHeaderOption("Limiter Amounts")
			AddHeaderOption("Capacity Penalties (per item past limit)")

			AddSliderOptionST("Amount0Slider", "Quiver Size (arrows)", Amount0)
			AddSliderOptionST("Penalty0Slider", "Penalty", Penalty0)

			AddSliderOptionST("Amount1Slider", "Satchel Size (potions & poisons)", Amount1)
			AddSliderOptionST("Penalty1Slider", "Penalty", Penalty1)

			AddSliderOptionST("Amount2Slider", "Pouches Size (small items)", Amount2)
			AddSliderOptionST("Penalty2Slider", "Penalty", Penalty2,"{1}")

			AddSliderOptionST("Amount3Slider", "Bags Size (medium items)", Amount3)
			AddSliderOptionST("Penalty3Slider", "Penalty", Penalty3)

			AddSliderOptionST("Amount4Slider", "Affixed Items Capacity (large items)", Amount4)
			AddSliderOptionST("Penalty4Slider", "Penalty", Penalty4)

            AddSliderOptionST("Amount5Slider", "Coin Purse Capacity (money)", Amount5)
            AddSliderOptionST("Penalty5Slider", "Penalty", Penalty5)
		else
			AddToggleOptionST("ModToggle","Enable Mod", ModEnabled)
			AddEmptyOption()
		endIf
	elseif (page == "Stat Modifier Settings")
		if (ModEnabled)
			SetInfoText("When capacity percentage is below the low (high) threshold, the low (high) modifier is applied. Between the thresholds, an interpolated modifier is applied.")
			AddHeaderOption("Stamina Buff/Debuff")
			AddEmptyOption()

			AddSliderOptionST("StaminaC1Slider","Low % capacity threshold",StaminaC1)
			AddSliderOptionST("StaminaS1Slider","Low-weight modifier",StaminaS1)
			AddSliderOptionST("StaminaC2Slider","High % capacity threshold",StaminaC2)
			AddSliderOptionST("StaminaS2Slider","High-weight modifier",StaminaS2)

			AddHeaderOption("Speed Buff/Debuff")
			AddEmptyOption()

			AddSliderOptionST("SpeedC1Slider","Low % capacity threshold",SpeedC1)
			AddSliderOptionST("SpeedS1Slider","Low-weight modifier",SpeedS1)
			AddSliderOptionST("SpeedC2Slider","High % capacity threshold",SpeedC2)
			AddSliderOptionST("SpeedS2Slider","High-weight modifier",SpeedS2)

			AddHeaderOption("Sneak Buff/Debuff")
			AddEmptyOption()

			AddSliderOptionST("StealthC1Slider","Low % capacity threshold",StealthC1)
			AddSliderOptionST("StealthS1Slider","Low-weight modifier",StealthS1)
			AddSliderOptionST("StealthC2Slider","High % capacity threshold",StealthC2)
			AddSliderOptionST("StealthS2Slider","High-weight modifier",StealthS2)
		else
			AddToggleOptionST("ModToggle","Enable Mod", ModEnabled)
			AddEmptyOption()
		endIf
	elseif (page == "Maintenance")
		AddToggleOptionST("ModToggle","Enable Mod", ModEnabled)
		AddEmptyOption()

		if (ModEnabled)
			AddToggleOptionST("ForceValueToggle","Force capacity settings on close", ForceClearCarryModifiers)
			AddEmptyOption()

			AddSliderOptionST("UpdateIntervalSlider","Careful rechecking interval",UpdateInterval)
			AddEmptyOption()

			AddSliderOptionST("PesterIntervalSlider","Over item limit notification interval",PesterInterval)
			AddEmptyOption()
		endIf

	else ; page == "Capacity Settings" is the default
		if (ModEnabled)
			AddSliderOptionST("TargetCapacityBaseSlider", "Base Capacity", MCM_TargetCapacityBase)
			AddEmptyOption()

			AddSliderOptionST("TargetCapacityPerLevelSlider", "Per Level Capacity", MCM_TargetCapacityPerLevel)
			AddEmptyOption()

			AddSliderOptionST("TargetCapacityPerStaminaSlider", "Per Stamina Capacity", MCM_TargetCapacityPerStamina, "{2}")
			AddEmptyOption()
		else
			AddToggleOptionST("ModToggle","Enable Mod", ModEnabled)
			AddEmptyOption()
		endIf
	endif
EndFunction



;__________________;
; OVERVIEW BUTTONS ;
;__________________;

State TargetCapacityBaseSlider
	event OnSliderOpenST()
		SetSliderDialogStartValue(MCM_TargetCapacityBase)
		SetSliderDialogDefaultValue(MCM_TargetCapacityBase_Default)
		SetSliderDialogRange(0, 1000)
		SetSliderDialogInterval(5)
	endEvent

	event OnSliderAcceptST(float value)
		MCM_TargetCapacityBase = value as int
		SetSliderOptionValueST(MCM_TargetCapacityBase)
		__pmg_TargetCapacityBase.SetValue( MCM_TargetCapacityBase as int )
	endEvent

	event OnDefaultST()
		MCM_TargetCapacityBase = MCM_TargetCapacityBase_Default
		SetSliderOptionValueST( MCM_TargetCapacityBase )
		__pmg_TargetCapacityBase.SetValue( MCM_TargetCapacityBase as int )
	endEvent

	event OnHighlightST()
		SetInfoText("Base carrying capacity before level-up bonuses, perks, and penalties (vanilla = 250)")
	endEvent
EndState

State TargetCapacityPerLevelSlider
	event OnSliderOpenST()
		SetSliderDialogStartValue(MCM_TargetCapacityPerLevel)
		SetSliderDialogDefaultValue(MCM_TargetCapacityPerLevel_Default)
		SetSliderDialogRange(0, 20)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		MCM_TargetCapacityPerLevel = value as int
		SetSliderOptionValueST(MCM_TargetCapacityPerLevel)
		__pmg_TargetCapacityPerLevel.SetValue( MCM_TargetCapacityPerLevel as int )
	endEvent

	event OnDefaultST()
		MCM_TargetCapacityPerLevel = MCM_TargetCapacityPerLevel_Default
		SetSliderOptionValueST( MCM_TargetCapacityPerLevel )
		__pmg_TargetCapacityPerLevel.SetValue( MCM_TargetCapacityPerLevel as int )
	endEvent

	event OnHighlightST()
		SetInfoText("Carrying capacity added each level, regardless of level-up stat chosen (vanilla = 0)")
	endEvent
EndState

State TargetCapacityPerStaminaSlider
	event OnSliderOpenST()
		SetSliderDialogStartValue(MCM_TargetCapacityPerStamina)
		SetSliderDialogDefaultValue(MCM_TargetCapacityPerStamina_Default)
		SetSliderDialogRange(0, 2)
		SetSliderDialogInterval(0.05)
	endEvent

	event OnSliderAcceptST(float value)
		MCM_TargetCapacityPerStamina = value as float
		SetSliderOptionValueST(MCM_TargetCapacityPerStamina, "{2}")
		__pmg_TargetCapacityPerStamina.SetValue( MCM_TargetCapacityPerStamina as float )
	endEvent

	event OnDefaultST()
		MCM_TargetCapacityPerStamina = MCM_TargetCapacityPerStamina_Default
		SetSliderOptionValueST( MCM_TargetCapacityPerStamina, "{2}" )
		__pmg_TargetCapacityPerStamina.SetValue( MCM_TargetCapacityPerStamina as float )
	endEvent

	event OnHighlightST()
		SetInfoText("Carrying capacity added per point of base stamina (vanilla = 0.5)")
	endEvent
EndState


;_________________;
; LIMITER BUTTONS ;
;_________________;

; AMMO
State Amount0Slider
	event OnSliderOpenST()
		SetSliderDialogStartValue(Amount0)
		SetSliderDialogDefaultValue(Amount0_Default)
		SetSliderDialogRange(0, 500)
		SetSliderDialogInterval(5)
	endEvent

	event OnSliderAcceptST(float value)
		Amount0 = value as int
		SetSliderOptionValueST(Amount0)
		__pmg_LimiterMaximumNumber[0].SetValue( Amount0 as int )
	endEvent

	event OnDefaultST()
		Amount0 = Amount0_Default
		SetSliderOptionValueST( Amount0 )
		__pmg_LimiterMaximumNumber[0].SetValue( Amount0 as int )
	endEvent

	event OnHighlightST()
		SetInfoText("Number of arrows + bolts you can carry before they start to get in the way. Set amount and penalty to zero to disable the limiter for an item type.")
	endEvent
EndState

State Penalty0Slider
	event OnSliderOpenST()
		SetSliderDialogStartValue(Penalty0)
		SetSliderDialogDefaultValue(Penalty0_Default)
		SetSliderDialogRange(0, 500)
		SetSliderDialogInterval(5)
	endEvent

	event OnSliderAcceptST(float value)
		Penalty0 = value as int
		SetSliderOptionValueST(Penalty0)
		__pmg_LimiterPenalty[0].SetValue( Penalty0 as int )
	endEvent

	event OnDefaultST()
		Penalty0 = Penalty0_Default
		SetSliderOptionValueST( Penalty0 )
		__pmg_LimiterPenalty[0].SetValue( Penalty0 as int )
	endEvent

	event OnHighlightST()
		SetInfoText("How much your carrying capacity decreases for each arrow over the limit. Set amount and penalty to zero to disable the limiter for an item type.")
	endEvent
EndState

; ALCH
State Amount1Slider
	event OnSliderOpenST()
		SetSliderDialogStartValue(Amount1)
		SetSliderDialogDefaultValue(Amount1_Default)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		Amount1 = value as int
		SetSliderOptionValueST(Amount1)
		__pmg_LimiterMaximumNumber[1].SetValue( Amount1 as int )
	endEvent

	event OnDefaultST()
		Amount1 = Amount1_Default
		SetSliderOptionValueST( Amount1 )
		__pmg_LimiterMaximumNumber[1].SetValue( Amount1 as int )
	endEvent

	event OnHighlightST()
		SetInfoText("Number of potions and poisons you can carry before they start to get in the way. Set amount and penalty to zero to disable the limiter for an item type.")
	endEvent
EndState

State Penalty1Slider
	event OnSliderOpenST()
		SetSliderDialogStartValue(Penalty1)
		SetSliderDialogDefaultValue(Penalty1_Default)
		SetSliderDialogRange(0, 500)
		SetSliderDialogInterval(5)
	endEvent

	event OnSliderAcceptST(float value)
		Penalty1 = value as int
		SetSliderOptionValueST(Penalty1)
		__pmg_LimiterPenalty[1].SetValue( Penalty1 as int )
	endEvent

	event OnDefaultST()
		Penalty1 = Penalty1_Default
		SetSliderOptionValueST( Penalty1 )
		__pmg_LimiterPenalty[1].SetValue( Penalty1 as int )
	endEvent

	event OnHighlightST()
		SetInfoText("How much your carrying capacity decreases for each potions or poison over the limit. Set amount and penalty to zero to disable the limiter for an item type.")
	endEvent
EndState

; Small items
State Amount2Slider
	event OnSliderOpenST()
		SetSliderDialogStartValue(Amount2)
		SetSliderDialogDefaultValue(Amount2_Default)
		SetSliderDialogRange(0, 500)
		SetSliderDialogInterval(5)
	endEvent

	event OnSliderAcceptST(float value)
		Amount2 = value as int
		SetSliderOptionValueST(Amount2)
		__pmg_LimiterMaximumNumber[2].SetValue( Amount2 as int )
	endEvent

	event OnDefaultST()
		Amount2 = Amount2_Default
		SetSliderOptionValueST( Amount2 )
		__pmg_LimiterMaximumNumber[2].SetValue( Amount2 as int )
	endEvent

	event OnHighlightST()
		SetInfoText("Number of small items (weight < 0.9), excluding gold, arrows, potions, and poisons, you can carry before they start to get in the way. Set amount and penalty to zero to disable the limiter for an item type.")
	endEvent
EndState

State Penalty2Slider
	event OnSliderOpenST()
		SetSliderDialogStartValue(Penalty2)
		SetSliderDialogDefaultValue(Penalty2_Default)
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(0.1)
	endEvent

	event OnSliderAcceptST(float value)
		Penalty2 = value as float
		SetSliderOptionValueST(Penalty2,"{1}")
		;__pmg_LimiterPenalty[2].SetValue( Penalty2 as int )
        __pmg_LimiterPenalty[2].SetValue( Penalty2 as float )
	endEvent

	event OnDefaultST()
		Penalty2 = Penalty2_Default
		SetSliderOptionValueST( Penalty2,"{1}" )
		__pmg_LimiterPenalty[2].SetValue( Penalty2 as float )
	endEvent

	event OnHighlightST()
		SetInfoText("How much your carrying capacity decreases for each small item over the limit. Set amount and penalty to zero to disable the limiter for an item type.")
	endEvent
EndState

; Medium items
State Amount3Slider
	event OnSliderOpenST()
		SetSliderDialogStartValue(Amount3)
		SetSliderDialogDefaultValue(Amount3_Default)
		SetSliderDialogRange(0, 500)
		SetSliderDialogInterval(5)
	endEvent

	event OnSliderAcceptST(float value)
		Amount3 = value as int
		SetSliderOptionValueST(Amount3)
		__pmg_LimiterMaximumNumber[3].SetValue( Amount3 as int )
	endEvent

	event OnDefaultST()
		Amount3 = Amount3_Default
		SetSliderOptionValueST( Amount3 )
		__pmg_LimiterMaximumNumber[3].SetValue( Amount3 as int )
	endEvent

	event OnHighlightST()
		SetInfoText("Number of medium items (weight < 9.0), excluding shields, you can carry before they start to get in the way. Set amount and penalty to zero to disable the limiter for an item type.")
	endEvent
EndState

State Penalty3Slider
	event OnSliderOpenST()
		SetSliderDialogStartValue(Penalty3)
		SetSliderDialogDefaultValue(Penalty3_Default)
		SetSliderDialogRange(0, 500)
		SetSliderDialogInterval(5)
	endEvent

	event OnSliderAcceptST(float value)
		Penalty3 = value as int
		SetSliderOptionValueST(Penalty3)
		__pmg_LimiterPenalty[3].SetValue( Penalty3 as int )
	endEvent

	event OnDefaultST()
		Penalty3 = Penalty3_Default
		SetSliderOptionValueST( Penalty3 )
		__pmg_LimiterPenalty[3].SetValue( Penalty3 as int )
	endEvent

	event OnHighlightST()
		SetInfoText("How much your carrying capacity decreases for each medium item over the limit. Set amount and penalty to zero to disable the limiter for an item type.")
	endEvent
EndState

; Large items
State Amount4Slider
	event OnSliderOpenST()
		SetSliderDialogStartValue(Amount4)
		SetSliderDialogDefaultValue(Amount4_Default)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		Amount4 = value as int
		SetSliderOptionValueST(Amount4)
		__pmg_LimiterMaximumNumber[4].SetValue( Amount4 as int )
	endEvent

	event OnDefaultST()
		Amount4 = Amount4_Default
		SetSliderOptionValueST( Amount4 )
		__pmg_LimiterMaximumNumber[4].SetValue( Amount4 as int )
	endEvent

	event OnHighlightST()
		SetInfoText("Number of large items (weight > 9.0) and shields you can carry before they start to get in the way. Set amount and penalty to zero to disable the limiter for an item type.")
	endEvent
EndState

State Penalty4Slider
	event OnSliderOpenST()
		SetSliderDialogStartValue(Penalty4)
		SetSliderDialogDefaultValue(Penalty4_Default)
		SetSliderDialogRange(0, 500)
		SetSliderDialogInterval(5)
	endEvent

	event OnSliderAcceptST(float value)
		Penalty4 = value as int
		SetSliderOptionValueST(Penalty4)
		__pmg_LimiterPenalty[4].SetValue( Penalty4 as int )
	endEvent

	event OnDefaultST()
		Penalty4 = Penalty4_Default
		SetSliderOptionValueST( Penalty4 )
		__pmg_LimiterPenalty[4].SetValue( Penalty4 as int )
	endEvent

	event OnHighlightST()
		SetInfoText("How much your carrying capacity decreases for each large item over the limit. Set amount and penalty to zero to disable the limiter for an item type.")
	endEvent
EndState

; Small items
State Amount5Slider
	event OnSliderOpenST()
		SetSliderDialogStartValue(Amount5)
		SetSliderDialogDefaultValue(Amount5_Default)
		SetSliderDialogRange(0, 10000)
		SetSliderDialogInterval(25)
	endEvent

	event OnSliderAcceptST(float value)
		Amount5 = value as int
		SetSliderOptionValueST(Amount5)
		__pmg_LimiterMaximumNumber[5].SetValue( Amount5 as int )
	endEvent

	event OnDefaultST()
		Amount5 = Amount5_Default
		SetSliderOptionValueST( Amount5 )
		__pmg_LimiterMaximumNumber[5].SetValue( Amount5 as int )
	endEvent

	event OnHighlightST()
		SetInfoText("Number of coins you can carry before they start to get in the way. Set amount and penalty to zero to disable the limiter for an item type.")
	endEvent
EndState

State Penalty5Slider
	event OnSliderOpenST()
		SetSliderDialogStartValue(Penalty5)
		SetSliderDialogDefaultValue(Penalty5_Default)
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(0.1)
	endEvent

	event OnSliderAcceptST(float value)
		Penalty5 = value as float
		SetSliderOptionValueST(Penalty5,"{1}")
		;__pmg_LimiterPenalty[2].SetValue( Penalty2 as int )
        __pmg_LimiterPenalty[5].SetValue( Penalty5 as float )
	endEvent

	event OnDefaultST()
		Penalty5 = Penalty5_Default
		SetSliderOptionValueST( Penalty5,"{1}" )
		__pmg_LimiterPenalty[5].SetValue( Penalty5 as float )
	endEvent

	event OnHighlightST()
		SetInfoText("How much your carrying capacity decreases for each coin over the limit. Set amount and penalty to zero to disable the limiter for an item type.")
	endEvent
EndState

;_______________________;
; STAT MODIFIER BUTTONS ;
;_______________________;


State StaminaC1Slider
	event OnSliderOpenST()
		SetSliderDialogStartValue(StaminaC1)
		SetSliderDialogDefaultValue(StaminaC1_Default)
		SetSliderDialogRange(0, 45)
		SetSliderDialogInterval(5)
	endEvent

	event OnSliderAcceptST(float value)
		StaminaC1 = value as int
		SetSliderOptionValueST(StaminaC1)
		__pmg_Stamina_C1.SetValue( StaminaC1 as int )
	endEvent

	event OnDefaultST()
		StaminaC1 = StaminaC1_Default
		SetSliderOptionValueST( StaminaC1 )
		__pmg_Stamina_C1.SetValue( StaminaC1 as int )
	endEvent

    event OnHighlightST()
		SetInfoText("Carrying capacity % below which the low-weight modifier is applied. (Modifiers are linearly interpolated between thresholds.)")
	endEvent
EndState

State StaminaC2Slider
	event OnSliderOpenST()
		SetSliderDialogStartValue(StaminaC2)
		SetSliderDialogDefaultValue(StaminaC2_Default)
		SetSliderDialogRange(50, 100)
		SetSliderDialogInterval(5)
	endEvent

	event OnSliderAcceptST(float value)
		StaminaC2 = value as int
		SetSliderOptionValueST(StaminaC2)
		__pmg_Stamina_C2.SetValue( StaminaC2 as int )
	endEvent

	event OnDefaultST()
		StaminaC2 = StaminaC2_Default
		SetSliderOptionValueST( StaminaC1 )
		__pmg_Stamina_C2.SetValue( StaminaC2 as int )
	endEvent
    event OnHighlightST()
        SetInfoText("Carrying capacity % above which the high-weight modifier is applied. (Modifiers are linearly interpolated between thresholds.)")
    endEvent
EndState

State StaminaS1Slider
	event OnSliderOpenST()
		SetSliderDialogStartValue(StaminaS1)
		SetSliderDialogDefaultValue(StaminaS1_Default)
		SetSliderDialogRange(-1000,1000)
		SetSliderDialogInterval(10)
	endEvent

	event OnSliderAcceptST(float value)
		StaminaS1 = value as int
		SetSliderOptionValueST(StaminaS1)
		__pmg_Stamina_S1.SetValue( StaminaS1 as int )
	endEvent

	event OnDefaultST()
		StaminaS1 = StaminaS1_Default
		SetSliderOptionValueST( StaminaS1 )
		__pmg_Stamina_S1.SetValue( StaminaS1 as int )
	endEvent
    event OnHighlightST()
        SetInfoText("The strength of the buff or debuff applied at or below the low % capacity threshold.")
    endEvent
EndState

State StaminaS2Slider
	event OnSliderOpenST()
		SetSliderDialogStartValue(StaminaS2)
		SetSliderDialogDefaultValue(StaminaS2_Default)
		SetSliderDialogRange(-1000,1000)
		SetSliderDialogInterval(10)
	endEvent

	event OnSliderAcceptST(float value)
		StaminaS2 = value as int
		SetSliderOptionValueST(StaminaS2)
		__pmg_Stamina_S2.SetValue( StaminaS2 as int )
	endEvent

	event OnDefaultST()
		StaminaS2 = StaminaS2_Default
		SetSliderOptionValueST( StaminaS2 )
		__pmg_Stamina_S2.SetValue( StaminaS2 as int )
	endEvent
    event OnHighlightST()
        SetInfoText("The strength of the buff or debuff applied at or above the high % capacity threshold.")
    endEvent
EndState

State StealthC1Slider
	event OnSliderOpenST()
		SetSliderDialogStartValue(StealthC1)
		SetSliderDialogDefaultValue(StealthC1_Default)
		SetSliderDialogRange(0, 45)
		SetSliderDialogInterval(5)
	endEvent

	event OnSliderAcceptST(float value)
		StealthC1 = value as int
		SetSliderOptionValueST(StealthC1)
		__pmg_Stealth_C1.SetValue( StealthC1 as int )
	endEvent

	event OnDefaultST()
		StealthC1 = StealthC1_Default
		SetSliderOptionValueST( StealthC1 )
		__pmg_Stealth_C1.SetValue( StealthC1 as int )
	endEvent
    event OnHighlightST()
		SetInfoText("Carrying capacity % below which the low-weight modifier is applied. (Modifiers are linearly interpolated between thresholds.)")
	endEvent
EndState

State StealthC2Slider
	event OnSliderOpenST()
		SetSliderDialogStartValue(StealthC2)
		SetSliderDialogDefaultValue(StealthC2_Default)
		SetSliderDialogRange(50, 100)
		SetSliderDialogInterval(5)
	endEvent

	event OnSliderAcceptST(float value)
		StealthC2 = value as int
		SetSliderOptionValueST(StealthC2)
		__pmg_Stealth_C2.SetValue( StealthC2 as int )
	endEvent

	event OnDefaultST()
		StealthC2 = StealthC2_Default
		SetSliderOptionValueST( StealthC2 )
		__pmg_Stealth_C2.SetValue( StealthC2 as int )
	endEvent
    event OnHighlightST()
        SetInfoText("Carrying capacity % above which the high-weight modifier is applied. (Modifiers are linearly interpolated between thresholds.)")
    endEvent
EndState

State StealthS1Slider
	event OnSliderOpenST()
		SetSliderDialogStartValue(StealthS1)
		SetSliderDialogDefaultValue(StealthS1_Default)
		SetSliderDialogRange(-1000,1000)
		SetSliderDialogInterval(10)
	endEvent

	event OnSliderAcceptST(float value)
		StealthS1 = value as int
		SetSliderOptionValueST(StealthS1)
		__pmg_Stealth_S1.SetValue( StealthS1 as int )
	endEvent

	event OnDefaultST()
		StealthS1 = StealthS1_Default
		SetSliderOptionValueST( StealthS1 )
		__pmg_Stealth_S1.SetValue( StealthS1 as int )
	endEvent
    event OnHighlightST()
        SetInfoText("The strength of the buff or debuff applied at or below the low % capacity threshold.")
    endEvent
EndState

State StealthS2Slider
	event OnSliderOpenST()
		SetSliderDialogStartValue(StealthS2)
		SetSliderDialogDefaultValue(StealthS2_Default)
		SetSliderDialogRange(-1000,1000)
		SetSliderDialogInterval(10)
	endEvent

	event OnSliderAcceptST(float value)
		StealthS2 = value as int
		SetSliderOptionValueST(StealthS2)
		__pmg_Stealth_S2.SetValue( StealthS2 as int )
	endEvent

	event OnDefaultST()
		StealthS2 = StealthS2_Default
		SetSliderOptionValueST( StealthS2 )
		__pmg_Stealth_S2.SetValue( StealthS2 as int )
	endEvent
    event OnHighlightST()
        SetInfoText("The strength of the buff or debuff applied at or above the high % capacity threshold.")
    endEvent
EndState

State SpeedC1Slider
	event OnSliderOpenST()
		SetSliderDialogStartValue(SpeedC1)
		SetSliderDialogDefaultValue(SpeedC1_Default)
		SetSliderDialogRange(0, 45)
		SetSliderDialogInterval(5)
	endEvent

	event OnSliderAcceptST(float value)
		SpeedC1 = value as int
		SetSliderOptionValueST(SpeedC1)
		__pmg_Speed_C1.SetValue( SpeedC1 as int )
	endEvent

	event OnDefaultST()
		SpeedC1 = SpeedC1_Default
		SetSliderOptionValueST( SpeedC1 )
		__pmg_Speed_C1.SetValue( SpeedC1 as int )
	endEvent
    event OnHighlightST()
        SetInfoText("Carrying capacity % below which the low-weight modifier is applied. (Modifiers are linearly interpolated between thresholds.)")
    endEvent
EndState

State SpeedC2Slider
	event OnSliderOpenST()
		SetSliderDialogStartValue(SpeedC2)
		SetSliderDialogDefaultValue(SpeedC2_Default)
		SetSliderDialogRange(50, 100)
		SetSliderDialogInterval(5)
	endEvent

	event OnSliderAcceptST(float value)
		SpeedC2 = value as int
		SetSliderOptionValueST(SpeedC2)
		__pmg_Speed_C2.SetValue( SpeedC2 as int )
	endEvent

	event OnDefaultST()
		SpeedC2 = SpeedC2_Default
		SetSliderOptionValueST( SpeedC2 )
		__pmg_Speed_C2.SetValue( SpeedC2 as int )
	endEvent
    event OnHighlightST()
        SetInfoText("Carrying capacity % above which the high-weight modifier is applied. (Modifiers are linearly interpolated between thresholds.)")
    endEvent
EndState

State SpeedS1Slider
	event OnSliderOpenST()
		SetSliderDialogStartValue(SpeedS1)
		SetSliderDialogDefaultValue(SpeedS1_Default)
		SetSliderDialogRange(-1000,1000)
		SetSliderDialogInterval(10)
	endEvent

	event OnSliderAcceptST(float value)
		SpeedS1 = value as int
		SetSliderOptionValueST(SpeedS1)
		__pmg_Speed_S1.SetValue( SpeedS1 as int )
	endEvent

	event OnDefaultST()
		SpeedS1 = SpeedS1_Default
		SetSliderOptionValueST( SpeedS1 )
		__pmg_Speed_S1.SetValue( SpeedS1 as int )
	endEvent
    event OnHighlightST()
        SetInfoText("The strength of the buff or debuff applied at or below the low % capacity threshold.")
    endEvent
EndState

State SpeedS2Slider
	event OnSliderOpenST()
		SetSliderDialogStartValue(SpeedS2)
		SetSliderDialogDefaultValue(SpeedS2_Default)
		SetSliderDialogRange(-1000,1000)
		SetSliderDialogInterval(10)
	endEvent

	event OnSliderAcceptST(float value)
		SpeedS2 = value as int
		SetSliderOptionValueST(SpeedS2)
		__pmg_Speed_S2.SetValue( SpeedS2 as int )
	endEvent

	event OnDefaultST()
		SpeedS2 = SpeedS2_Default
		SetSliderOptionValueST( SpeedS2 )
		__pmg_Speed_S2.SetValue( SpeedS2 as int )
	endEvent
    event OnHighlightST()
        SetInfoText("The strength of the buff or debuff applied at or above the high % capacity threshold.")
    endEvent
EndState


;______________;
; MISC BUTTONS ;
;______________;
State ForceValueToggle
	event OnSelectST()
		ForceClearCarryModifiers = !ForceClearCarryModifiers
		ForcePageReset()
	endEvent
	event OnHighlightST()
		SetInfoText("Remove extra carry weight modifiers. For example, those left over from other mods. Select this if the carry weight in your inventory looks like it's wrong and you don't have any active effects that could explain the difference.")
	endEvent
endState

State ModToggle
	event OnSelectST()
		ModEnabled = !ModEnabled
		ForcePageReset()
	endEvent
	event OnHighlightST()
		SetInfoText("Toggle the activity of the mod. Close menu for activation/deactivation to take effect.")
	endEvent
endState

State UpdateIntervalSlider
	event OnSliderOpenST()
		SetSliderDialogStartValue(UpdateInterval)
		SetSliderDialogDefaultValue(UpdateIntervalDefault)
		SetSliderDialogRange(0,3600)
		SetSliderDialogInterval(10)
	endEvent

	event OnSliderAcceptST(float value)
		UpdateInterval = value as int
		SetSliderOptionValueST(UpdateInterval)
		__pmg_Capacity_UpdateInterval.SetValue( UpdateInterval as int )
	endEvent

	event OnDefaultST()
		UpdateInterval = UpdateIntervalDefault
		SetSliderOptionValueST( UpdateInterval )
		__pmg_Capacity_UpdateInterval.SetValue( UpdateInterval as int )
	endEvent
		event OnHighlightST()
		SetInfoText("How often (in seconds) to rebuild capacity effects and limits from scratch (fixes miscounting due to fast taking/dropping items). This is a CPU-intensive task. Set to 0 to disable (this may cause inaccurate counts).")
	endEvent

EndState

State PesterIntervalSlider
	event OnSliderOpenST()
		SetSliderDialogStartValue(PesterInterval)
		SetSliderDialogDefaultValue(PesterIntervalDefault)
		SetSliderDialogRange(0,300)
		SetSliderDialogInterval(5)
	endEvent

	event OnSliderAcceptST(float value)
		PesterInterval = value as int
		SetSliderOptionValueST(PesterInterval)
		__pmg_Capacity_PesterInterval.SetValue( PesterInterval as int )
	endEvent

	event OnDefaultST()
		PesterInterval = PesterIntervalDefault
		SetSliderOptionValueST( PesterInterval )
		__pmg_Capacity_PesterInterval.SetValue( PesterInterval as int )
	endEvent
		event OnHighlightST()
		SetInfoText("How often (in seconds) to notify you when you have exceeded your item limits. Set to zero to disable these notifications.")
	endEvent

EndState
