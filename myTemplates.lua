MyGrabberButtonMixin = {}

function MyGrabberButtonMixin:GrabDraggedSpell(spellID)
    local info = C_Spell.GetSpellInfo(spellID)
    local name = info.name
    local icon = info.iconID
    local body = "/cast " .. name
    self:GenerateMacro(name, icon, body)
end

function MyGrabberButtonMixin:GrabDraggedItem(itemID)
    local name = C_Item.GetItemNameByID(itemID)
    local icon = C_Item.GetItemIconByID(itemID)
    local body = "/use " .. name
    self:GenerateMacro(name, icon, body)
end

function MyGrabberButtonMixin:GrabDraggedMacro(macroIndex)
    local name, icon, body = GetMacroInfo(macroIndex)
    self:GenerateMacro(name, icon, body)
end

local overlay 
function MyGrabberButtonMixin:GenerateMacro(name, icon, body)
    local index 
    if GetCVar("ActionButtonUseKeyDown") == "1" then
        if self:GetParentKey() == "human" then
            index = CreateMacro(name .. "(Human)", icon, "/click TrueForm_TurnHuman MouseButton 1\n" .. body)
        elseif self:GetParentKey() == "worgen" then
            index = CreateMacro(name .. "(Worgen)", icon, "/click TrueForm_TurnWorgen MouseButton 1\n" .. body)
        end
    elseif GetCVar("ActionButtonUseKeyDown") == "0" then
        if self:GetParentKey() == "human" then
            index = CreateMacro(name .. "(Human)", icon, "/click TrueForm_TurnHuman\n" .. body)
        elseif self:GetParentKey() == "worgen" then
            index = CreateMacro(name .. "(Worgen)", icon, "/click TrueForm_TurnWorgen\n" .. body)
        end
    end
    print("TrueForm: Macro Created Successfully")
    TrueForm_AnimateMacros(index)
end


function MyGrabberButtonMixin:OnReceiveDrag()
    local infoType, arg2, arg3, arg4 = GetCursorInfo()
    if infoType == "item" then
        self:GrabDraggedItem(arg2)
    elseif infoType == "spell" then
        self:GrabDraggedSpell(arg4)
    elseif infoType == "macro" then
        self:GrabDraggedMacro(arg2)
    end
end

function MyGrabberButtonMixin:OnMouseUp(button, upInside)
    if button ~= "LeftButton" or upInside == false then return end
    local infoType, arg2, arg3, arg4 = GetCursorInfo()
    if infoType == "item" then
        self:GrabDraggedItem(arg2)
    elseif infoType == "spell" then
        self:GrabDraggedSpell(arg4)
    elseif infoType == "macro" then
        self:GrabDraggedMacro(arg2)
    end
end




-- Ported from the game

TrueFormPorted_ActionBarButtonSpellActivationAlertMixin = {};
function TrueFormPorted_ActionBarButtonSpellActivationAlertMixin:OnHide()
	if ( self.ProcLoop:IsPlaying() ) then
		self.ProcLoop:Stop();
	end
end

TrueFormPorted_ActionBarButtonSpellActivationAlertProcStartAnimMixin = { }; 
function TrueFormPorted_ActionBarButtonSpellActivationAlertProcStartAnimMixin:OnFinished()
	self:GetParent().ProcLoop:Play();
end