Scriptname CTWLite_MCM extends SKI_ConfigBase
{CTW Lite - one MCM page with the Enable Mod toggle and the three capacity sliders.
The sliders read and write the globals directly, with no private copy. The toggle
state lives in the manager. ModName and Pages are set in the plugin.}

; Slider ranges, steps, defaults, format and help texts adapted from Carry That
; Weight by MrPMG (CC BY-SA 4.0), __pmg_CapacityTools_MCM.psc lines 226-322.
; The Enable Mod toggle is applied on close, as in that file's OnConfigClose.

CTWLite_Manager Property Manager Auto
GlobalVariable Property TargetCapacityBase Auto
GlobalVariable Property TargetCapacityPerLevel Auto
GlobalVariable Property TargetCapacityPerStamina Auto

; Delivered on every save load by SKI_PlayerLoadGameAlias, on this quest's player alias.
Event OnGameReload()
	Parent.OnGameReload()
	Manager.RunMaintenance()
EndEvent

Event OnConfigClose()
	Manager.ApplyState()
EndEvent

Event OnPageReset(string a_page)
	AddToggleOptionST("EnableToggle", "Enable Mod", Manager.IsEnabled())
	AddEmptyOption()
	AddSliderOptionST("BaseSlider", "Base Capacity", TargetCapacityBase.GetValue())
	AddEmptyOption()
	AddSliderOptionST("PerLevelSlider", "Per Level Capacity", TargetCapacityPerLevel.GetValue())
	AddEmptyOption()
	AddSliderOptionST("PerStaminaSlider", "Per Stamina Capacity", TargetCapacityPerStamina.GetValue(), "{2}")
	AddEmptyOption()
EndEvent

State EnableToggle
	Event OnSelectST()
		Manager.SetEnabled(!Manager.IsEnabled())
		SetToggleOptionValueST(Manager.IsEnabled())
	EndEvent

	Event OnDefaultST()
		Manager.SetEnabled(true)
		SetToggleOptionValueST(Manager.IsEnabled())
	EndEvent

	Event OnHighlightST()
		SetInfoText("Turn off before uninstalling. Applied when the menu closes: stops recalculating and sets carrying capacity back to 300")
	EndEvent
EndState

State BaseSlider
	Event OnSliderOpenST()
		SetSliderDialogStartValue(TargetCapacityBase.GetValue())
		SetSliderDialogDefaultValue(250.0)
		SetSliderDialogRange(0.0, 1000.0)
		SetSliderDialogInterval(5.0)
	EndEvent

	Event OnSliderAcceptST(float a_value)
		TargetCapacityBase.SetValue(a_value as int)
		SetSliderOptionValueST(TargetCapacityBase.GetValue())
	EndEvent

	Event OnDefaultST()
		TargetCapacityBase.SetValue(250.0)
		SetSliderOptionValueST(TargetCapacityBase.GetValue())
	EndEvent

	Event OnHighlightST()
		SetInfoText("Base carrying capacity before level-up bonuses, perks, and penalties (vanilla = 250)")
	EndEvent
EndState

State PerLevelSlider
	Event OnSliderOpenST()
		SetSliderDialogStartValue(TargetCapacityPerLevel.GetValue())
		SetSliderDialogDefaultValue(0.0)
		SetSliderDialogRange(0.0, 20.0)
		SetSliderDialogInterval(1.0)
	EndEvent

	Event OnSliderAcceptST(float a_value)
		TargetCapacityPerLevel.SetValue(a_value as int)
		SetSliderOptionValueST(TargetCapacityPerLevel.GetValue())
	EndEvent

	Event OnDefaultST()
		TargetCapacityPerLevel.SetValue(0.0)
		SetSliderOptionValueST(TargetCapacityPerLevel.GetValue())
	EndEvent

	Event OnHighlightST()
		SetInfoText("Carrying capacity added each level, regardless of level-up stat chosen (vanilla = 0)")
	EndEvent
EndState

State PerStaminaSlider
	Event OnSliderOpenST()
		SetSliderDialogStartValue(TargetCapacityPerStamina.GetValue())
		SetSliderDialogDefaultValue(0.5)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogInterval(0.05)
	EndEvent

	Event OnSliderAcceptST(float a_value)
		TargetCapacityPerStamina.SetValue(a_value)
		SetSliderOptionValueST(TargetCapacityPerStamina.GetValue(), "{2}")
	EndEvent

	Event OnDefaultST()
		TargetCapacityPerStamina.SetValue(0.5)
		SetSliderOptionValueST(TargetCapacityPerStamina.GetValue(), "{2}")
	EndEvent

	Event OnHighlightST()
		SetInfoText("Carrying capacity added per point of base stamina (vanilla = 0.5)")
	EndEvent
EndState
