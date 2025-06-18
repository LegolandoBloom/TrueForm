--/run SetCVar("ActionButtonUseKeyDown", 0)
--/run SetCVar("ActionButtonUseKeyDown", 1)

--current form: 0 is human, 1 is wolf, 2 is not tracking yet
TrueFormVariables = {
    currentForm,
    calmActive,
    firstInstallDone
}

local function initializeSavedVariables()
    if not TrueFormVariables.currentForm then
        TrueFormVariables.currentForm = 2
    end
    if not TrueFormVariables.calmActive then
        TrueFormVariables.calmActive = false
    end
    if not TrueFormVariables.firstInstallDone then
        TrueFormVariables.firstInstallDone = false
    end
end

local function directClickWarning(self, button, down)
    local colorRed = CreateColor(0.51, 0.05, 0.03)
    local colorYello = CreateColor(1.0, 0.82, 0.0)
    if GetCVar("ActionButtonUseKeyDown") == "1" then
        print(colorRed:WrapTextInColorCode("TrueForm:"), "To always transform into human form, add ", colorYello:WrapTextInColorCode("/click TrueForm_TurnHuman MouseButton 1"), " to your macros.")
        print("To always transform into worgen form, add ", colorYello:WrapTextInColorCode("/click TrueForm_TurnWorgen MouseButton 1"), " instead.")
    elseif GetCVar("ActionButtonUseKeyDown") == "0" then
        print(colorRed:WrapTextInColorCode("TrueForm:"), "To always transform into human form, add ", colorYello:WrapTextInColorCode("/click TrueForm_TurnHuman"), " to your macros.")
        print("To always transform into worgen form, add ", colorYello:WrapTextInColorCode("/click TrueForm_TurnWorgen"), " instead.")
    end
end

local function keyUpOrDownWarning(self, button, down)
    local colorRed = CreateColor(0.51, 0.05, 0.03)
    local colorYello = CreateColor(1.0, 0.82, 0.0)
    if down == false and GetCVar("ActionButtonUseKeyDown") == "1" then
        print(colorRed:WrapTextInColorCode("TrueForm:"),"Your ActionButtonUse console variable is set to KEY DOWN.")
        print("Please use the macro:")
        print(colorYello:WrapTextInColorCode(" /click") , colorYello:WrapTextInColorCode(self:GetDebugName()), colorYello:WrapTextInColorCode("MouseButton 1"))
        print("instead.")
    elseif down and GetCVar("ActionButtonUseKeyDown") == "0" then
        print(colorRed:WrapTextInColorCode("TrueForm:"),"Your ActionButtonUse console variable is set to KEY UP.")
        print("Please use the macro:") 
        print(colorYello:WrapTextInColorCode(" /click") , colorYello:WrapTextInColorCode(self:GetDebugName()))
        print("instead.")
    end
end

function TrueForm_OnLoad(self)
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UNIT_FORM_CHANGED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:SetScript("OnEvent", TrueForm_EventHandler)
    
    self.turnHuman:RegisterForClicks("AnyUp", "AnyDown")
    self.turnHuman:HookScript("OnClick", keyUpOrDownWarning)
    
    self.turnWorgen:RegisterForClicks("AnyUp", "AnyDown")
    self.turnWorgen:HookScript("OnClick", keyUpOrDownWarning)
end

local combatHidden = false
function TrueForm_EventHandler(self, event, unit, ...)
    arg4, arg5, arg6 = ...
    if event == "PLAYER_ENTERING_WORLD" then
        initializeSavedVariables()
        TrueForm.turnHuman:SetAttribute("type", "spell")
        TrueForm.turnWorgen:SetAttribute("type", "spell")
        TrueForm_HandleButtons(TrueFormVariables.currentForm)
        if TrueFormVariables.firstInstallDone ~= true then
            TrueForm_FirstInstall()
            TrueFormVariables.firstInstallDone = true
        end
        enteredWorld = true
        TrueForm_CheckForm()
    elseif event == "UNIT_FORM_CHANGED" and unit == "player" and enteredWorld then
        if InCombatLockdown() then return end
        TrueForm_CheckForm()
    elseif event == "PLAYER_REGEN_DISABLED" then
        if TrueForm:IsShown() then
            TrueForm:Hide()
            combatHidden = true
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        TrueForm_CheckForm()
        if combatHidden == true then
            TrueForm:Show()
            combatHidden = false
        end
    end
end

function TrueForm_CheckForm()
    if InCombatLockdown() then return end
    if C_UnitAuras.WantsAlteredForm("player") == true then
        TrueFormVariables.currentForm = 1
        TrueForm_HandleButtons(1)
    elseif C_UnitAuras.WantsAlteredForm("player") == false then
        TrueFormVariables.currentForm = 0
        TrueForm_HandleButtons(0)
    else
        TrueForm_HandleButtons(2)
    end
end

function TrueForm_HandleButtons(form)
    if form == 1 then
        TrueForm.visual.human:Hide()
        TrueForm.visual.worgen:Show()
        TrueForm.visual.text:SetText("WORGEN")
        
        TrueForm.turnHuman:SetAttribute("spell", "68996")
        TrueForm.turnWorgen:SetAttribute("spell", " ")

        TrueForm.problems:Hide()
    elseif form == 0 then
        TrueForm.visual.worgen:Hide()
        TrueForm.visual.human:Show()
        TrueForm.visual.text:SetText("HUMAN")
        
        TrueForm.turnHuman:SetAttribute("spell", " ")    
        TrueForm.turnWorgen:SetAttribute("spell", "68996")

        TrueForm.problems:Hide()
    elseif form == 2 then
        TrueForm.visual.human:Hide()
        TrueForm.visual.worgen:Hide()
        TrueForm.visual.text:Hide()
        
        TrueForm.turnHuman:SetAttribute("spell", " ")
        TrueForm.turnWorgen:SetAttribute("spell", " ")

        TrueForm.problems:Show()
    end
end

function TrueForm_GenerateMacros()
    if InCombatLockdown() then return end                                        
    if GetCVar("ActionButtonUseKeyDown") == "1" then
        CreateMacro("TrueForm Human", 236448, "/click TrueForm_TurnHuman MouseButton 1")
        CreateMacro("TrueForm Worgen", 463876, "/click TrueForm_TurnWorgen MouseButton 1")
    elseif GetCVar("ActionButtonUseKeyDown") == "0" then
        CreateMacro("TrueForm Human", 236448, "/click TrueForm_TurnHuman")
        CreateMacro("TrueForm Worgen", 463876, "/click TrueForm_TurnWorgen")
    end
    local colorRed = CreateColor(0.51, 0.05, 0.03)
    print(colorRed:WrapTextInColorCode("TrueForm ") .. "example macros successfully generated")
    if not MacroFrame then
        C_AddOns.LoadAddOn("Blizzard_MacroUI")
        MacroFrame_Show()
    elseif not  MacroFrame:IsShown() then
        MacroFrame_Show()
    end
end

local closeHooked = true
function TrueForm_AnimateMacros(index)
    if not MacroFrame then
        C_AddOns.LoadAddOn("Blizzard_MacroUI")
        MacroFrame_Show()
    elseif not  MacroFrame:IsShown() then
        MacroFrame_Show()
    end
    MacroFrame:SetAccountMacros()
    MacroFrame:SelectMacro(index)

    local frameW, frameH = MacroFrameSelectedMacroButton:GetSize()
    TrueForm_MacroAlertAnim:SetSize(frameW + 6, frameH + 6)
    TrueForm_MacroAlertAnim:ClearAllPoints()
    TrueForm_MacroAlertAnim:SetPoint("CENTER", MacroFrameSelectedMacroButton, "CENTER", 0, -1)
    TrueForm_MacroAlertAnim:Show()
    TrueForm_MacroAlertAnim.ProcStartAnim:Play()
    if not closeHooked then 
        MacroFrame:HookScript("OnHide", function()
            TrueForm_MacroAlertAnim:Hide()
        end)
        closeHooked = true
    end
end

