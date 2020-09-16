--On GitHUb
local overlays = {}
local buffs = {}

local prioritySpellList = { --The higher on the list, the higher priority the buff has.

264760, --War-Scroll of Intellect
1459, --Arcane Brilliance

}

for k, v in ipairs(prioritySpellList) do
	buffs[v] = k
end

hooksecurefunc("CompactUnitFrame_UpdateAuras", function(self)
	if self:IsForbidden() or not self:IsVisible() or not self.buffFrames then
		return
	end

	local unit, index, buff = self.displayedUnit, index, buff
	for i = 1, 32 do --BUFF_MAX_DISPLAY
		local buffName, _, _, _, _, _, _, _, _, spellId = UnitBuff(unit, i,"HELPFUL")

		if spellId then
			if buffs[buffName] then
				buffs[spellId] = buffs[buffName]
			end

			if buffs[spellId] then
				if not buff or buffs[spellId] < buffs[buff] then
					buff = spellId
					index = i
				end
			end
		else
			break
		end
	end

	local overlay = overlays[self]
	if not overlay then
		if not index then
			return
		end
		overlay = CreateFrame("Button", "$parentBuffOverlayInt", self, "CompactAuraTemplate")
		overlay:ClearAllPoints()
		overlay:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -15, 43)
		--overlay:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -6, 40) --Triangle
		overlay:SetAlpha(1)
		overlay:SetFrameLevel(3)
		overlay:SetFrameStrata("TOOLTIP")
		overlay:EnableMouse(false)
		overlay:RegisterForClicks()
		overlays[self] = overlay
	end

	if index then
		overlay:SetSize(self.buffFrames[1]:GetSize())
		overlay:SetScale(.265)
		--overlay:SetScale(.5) --Triangle
		--CompactUnitFrame_UtilSetBuff(overlay, index, UnitBuff(unit, index))
		local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura = UnitBuff(unit, index);
		SetPortraitToTexture(overlay.icon, icon);
		overlay.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93);
		--overlay.icon:SetTexCoord(0.75, 1, 0, 0.25); --Triangle
		--overlay.icon:SetRotation(3.1415926536); --Triangle
		--overlay.icon:SetVertexColor(0.5,1,0.5); --Triangle
		--overlay.icon:SetVertexColor(0.25,	0.78,	0.92);
		if ( count > 1 ) then
		local countText = count;
		if ( count >= 100 ) then
			countText = BUFF_STACKS_OVERFLOW;
		end
		overlay.count:Show();
		overlay.count:SetText(countText);
		else
		overlay.count:Hide();
		end
		overlay:SetID(index);
		local enabled = expirationTime and expirationTime ~= 0;
		if enabled then
		local startTime = expirationTime - duration;
		CooldownFrame_Set(overlay.cooldown, startTime, duration, false);
		else
		CooldownFrame_Clear(overlay.cooldown);
		end
		overlay:Show();
	end
	overlay:SetShown(index and true or false)
end)
