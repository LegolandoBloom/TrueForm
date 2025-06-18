local function resetCurrentForm()
    TrueFormVariables.currentForm = 2
    TrueForm_HandleButtons(2)
    print("form tracker reset")
end

local function printCurrentForm()
    print(TrueFormVariables.currentForm)
end

local function toggleTrueForm()
    if InCombatLockdown() then
        local colorRed = CreateColor(0.51, 0.05, 0.03)
        print(colorRed:WrapTextInColorCode("TrueForm:")," Can't open visual menu in combat, try again after combat ends.")
        return
    end
    if TrueForm:IsShown() then
        TrueForm:Hide()
    else
        TrueForm:Show()
    end
end

SLASH_TRUFORMRES1 = "/tfres"
SLASH_TRUFORMTOG1 = "/trueform"
SLASH_TRUFORMTOG2 = "/tftf"
SLASH_TRUFORMPR1 = "/tfpr"
SlashCmdList["TRUFORMRES"] = resetCurrentForm
SlashCmdList["TRUFORMTOG"] = toggleTrueForm
SlashCmdList["TRUFORMPR"] = printCurrentForm


local function resetFirstInstall()
    TrueFormVariables.firstInstallDone = false
end

SLASH_TRUFORMREINSTALL1 = "/tfreins"
SlashCmdList["TRUFORMREINSTALL"] = resetFirstInstall

SLASH_TRUFORMGEN1 = "/tfgen"
SlashCmdList["TRUFORMGEN"] = TrueForm_GenerateMacros