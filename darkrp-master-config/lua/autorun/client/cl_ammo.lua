
local configSettings = DCONFIG.Settings
local scrw = ScrW()
local scrh = ScrH() 
local sidebar
local background = DCONFIG.Settings.Colors["background"]
local foreground = DCONFIG.Settings.Colors["foreground"]
local inactiveClr = DCONFIG.Settings.Colors["inactiveClr"] 
local theme = DCONFIG.Settings.Colors["theme"]
local circle = Material("dconfig/circle.png") 
local circle_stencil = Material("dconfig/circle.png", "alphatest")
local circle_stencil_s = Material("dconfig/circle_s.png", "alphatest")
local checked = Material("dconfig/checked.png") 

function AmmoEditorToggle()  

	if IsValid(AmmoEditor) then
		AmmoEditor:Remove()
	end

	AmmoEditor = vgui.Create("DPanel", DConfigMenu)
	AmmoEditor:SetPos(dconfigSideBarW, 0)
	AmmoEditor:SetSize(DConfigMenu:GetWide() - dconfigSideBarW, DConfigMenu:GetTall())
	AmmoEditor.Paint = function(me,w,h) end 

	local AmmoList = vgui.Create("DPanel", AmmoEditor)
	AmmoList:SetPos(AmmoEditor:GetWide() * .01,AmmoEditor:GetTall() * .01)
	AmmoList:SetSize(AmmoEditor:GetWide() / 4 - (AmmoEditor:GetWide() * .01), AmmoEditor:GetTall()- (AmmoEditor:GetTall() * .01))
	AmmoList.Paint = function(me,w,h)
		draw.SimpleText("Ammo: ", "hub_40", 0, h * .05, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end 

	local AmmoScroll = vgui.Create("DScrollPanel", AmmoList)
	AmmoScroll:SetPos(0, AmmoList:GetTall() * .1)
	AmmoScroll:SetSize(AmmoList:GetWide(), AmmoList:GetTall() * .9)
	paintSbar(AmmoScroll)
	local ypos = 0
	local AmmoPanelH = AmmoList:GetTall() / 10
	local offSet = 5
	local AmmoPanel = vgui.Create("DPanel", AmmoScroll)
	AmmoPanel:SetPos(0, ypos)
	AmmoPanel:SetSize(AmmoList:GetWide(), AmmoPanelH)
	AmmoPanel.Paint = function(me,w,h)
		draw.RoundedBox( 8, 0, 0, w - w * .05, h, foreground )
		surface.SetDrawColor(background)
		surface.SetMaterial(circle)
		surface.DrawTexturedRect(w * .03 ,h / 2 - h / 2.6, h / 1.3,h / 1.3)
		draw.SimpleText("New Ammo", "hub_20", w * .05 + h / 1.2, h * .2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	end
	AmmoPanelNew = vgui.Create("DButton", AmmoPanel) 
	AmmoPanelNew:SetPos(AmmoList:GetWide() * .03, AmmoPanelH / 2 - AmmoPanelH / 2.6)
	AmmoPanelNew:SetSize(AmmoPanelH / 1.3 ,AmmoPanelH / 1.3)
	AmmoPanelNew:SetText("")
	AmmoPanelNew.Paint = function(me,w,h)
		if me:IsHovered() then
			draw.SimpleText("+", "hub_40", w / 2, h / 2, theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else 
			draw.SimpleText("+", "hub_30", w / 2, h / 2, theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end 
	end

	AmmoPanelNew.DoClick = function()
		AmmoSettings(AmmoEditor)
	end

	ypos = ypos + AmmoPanelH + (AmmoList:GetTall() * .01)  
	for k,v in pairs(GAMEMODE.AmmoTypes) do
		if GAMEMODE.AmmoTypes[k].dconfig then 
			local AmmoPanel = vgui.Create("DPanel", AmmoScroll)
			AmmoPanel:SetPos(0, ypos)
			AmmoPanel:SetSize(AmmoList:GetWide(), AmmoPanelH)
			AmmoPanel.Paint = function(me,w,h)
				draw.RoundedBox( 8, 0, 0, w - w * .05, h, foreground )
				surface.SetDrawColor(background)
				surface.SetMaterial(circle)
				draw.SimpleText(v.name, "hub_20", w * .05 + h / 1.2, h * .2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			
			end

			local AmmoEditButton = vgui.Create("DButton", AmmoPanel)
			AmmoEditButton:SetPos(AmmoPanel:GetWide() * .05 + AmmoPanelH / 1.2, AmmoPanelH * .6)  
			AmmoEditButton:SetSize(AmmoPanel:GetWide() * .15, AmmoPanelH * .2)
			AmmoEditButton:SetText("")
			AmmoEditButton.Paint = function(me,w,h)
				if me:IsHovered() then 
					draw.SimpleText("Edit", "hub_18", 0, h / 2, theme, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				else 
					draw.SimpleText("Edit", "hub_16", 0, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end 
			end

			AmmoEditButton.DoClick = function() 
				AmmoSettings(AmmoEditor, GAMEMODE.AmmoTypes[k])
			end 


			local AmmoDeleteButton = vgui.Create("DButton", AmmoPanel)
			AmmoDeleteButton:SetPos(AmmoPanel:GetWide() * .2 + AmmoPanelH / 1.2, AmmoPanelH * .6)  
			AmmoDeleteButton:SetSize(AmmoPanel:GetWide() * .18, AmmoPanelH * .2)
			AmmoDeleteButton:SetText("")
			AmmoDeleteButton.Paint = function(me,w,h)
				if me:IsHovered() then 
					draw.SimpleText("Delete", "hub_18", 0, h / 2, theme, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				else 
					draw.SimpleText("Delete", "hub_16", 0, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end 
			end

			AmmoDeleteButton.DoClick = function()
				
				DConfigConfirm("Do you want to delete ".. v.name .. "?", function()
					net.Start("dconfig_deleteAmmo")
					net.WriteInt(k, 8)
					net.SendToServer() 
					timer.Simple(.2, function()
						AmmoEditorToggle()
					end)
				end )
				

			end 

			local AmmoModel = vgui.Create("DModelPanel", AmmoPanel) 
			AmmoModel:SetPos(0,0)
			AmmoModel:SetPos(AmmoPanel:GetWide() * .03, AmmoPanel:GetTall() / 2 - (AmmoPanel:GetTall() / 2.6))
			AmmoModel:SetSize(AmmoPanel:GetTall() / 1.3, AmmoPanel:GetTall() / 1.3)
			AmmoModel:SetModel(string.lower(GAMEMODE.AmmoTypes[k].model))
			function AmmoModel:LayoutEntity( Entity ) return end 
			local CamPos = Vector( 15, -6, 60 )
			local LookAt = Vector( 0, 0, 60 )
			AmmoModel.Entity:SetPos( AmmoModel.Entity:GetPos() - Vector( 0, 0, 4 ) )
			AmmoModel:SetCamPos( CamPos )
			AmmoModel:SetLookAt( LookAt )
			AmmoModel:SetFOV(50)
			local num = .7
			local min, max = AmmoModel.Entity:GetRenderBounds() 
			AmmoModel:SetCamPos(min:Distance(max) * Vector(num, num, num))
			AmmoModel:SetLookAt((max + min) / 2)
		 
		 	local oldPaint = AmmoModel.Paint

			function AmmoModel:Paint(w, h)

				surface.SetDrawColor(background)
	            surface.SetMaterial(circle)
	            surface.DrawTexturedRect(0, 0, w, h)
				render.ClearStencil()
				render.SetStencilEnable(true)
				render.SetStencilCompareFunction(STENCIL_NEVER)  
				render.SetStencilWriteMask(1)
				render.SetStencilTestMask(1)
				render.SetStencilReferenceValue(1)

				surface.SetMaterial(circle_stencil_s)
				surface.DrawTexturedRect(0, 0, w, h)

				render.SetStencilCompareFunction(STENCIL_EQUAL)
				render.SetStencilPassOperation(STENCIL_KEEP)
				render.SetStencilFailOperation(STENCIL_REPLACE)
				oldPaint(self, w, h)

				render.SetStencilWriteMask(2)
				render.SetStencilTestMask(2)
				render.SetStencilReferenceValue(2)

				surface.SetMaterial(circle_stencil_s)
				surface.DrawTexturedRect(0, 0, w, h)
 
				render.SetStencilCompareFunction(STENCIL_NOTEQUAL)

				surface.SetDrawColor(foreground)
				surface.DrawRect(0, 0, w, h)

				render.SetStencilEnable(false)
			end
			ypos = ypos + AmmoPanelH + (AmmoList:GetTall() * .01)		
		end 
	end

	dconfigMenu.Elements["entityeditor"] = AmmoEditor 
	AmmoSettings(AmmoEditor)

end 

local defaultAmmo = {
{name = "ar2"}, 
{name = "ar2altfire"},
{name = "pistol"},
{name = "smg1"},
{name = "357"},
{name = "xbowbolt"},
{name = "buckshot"},
{name = "rpg_round"},
{name = "smg1_grenade"},
{name = "grenade"},
{name = "slam"},
{name = "alyxgun"},	

}

local ammoModels = {
	"models/Items/BoxMRounds.mdl",
	"models/Items/BoxSRounds.mdl",
	"models/Items/357ammo.mdl",
	"models/Items/BoxBuckshot.mdl",
}

function AmmoSettings(parent, ammo)

	if IsValid(AmmoSettingsEditor) then
		AmmoSettingsEditor:Remove()
	end
	textError = ""
	ammo = ammo or {}
	AmmoSettingsEditor = vgui.Create("DPanel", parent)
	AmmoSettingsEditor:SetPos(parent:GetWide() * .25 , parent:GetTall() * .01)
	AmmoSettingsEditor:SetSize(parent:GetWide() - parent:GetWide() * .25, parent:GetTall())
	local tw, th = 0,0
	AmmoSettingsEditor.Paint = function(me,w,h)
		surface.SetFont("hub_40")
		if not ammo["name"] then
			draw.SimpleText("Settings: New Ammo", "hub_40", 0, h * .05, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			tw,th = surface.GetTextSize("Settings: New Ammo")
		else
			draw.SimpleText("Settings: " .. ammo["name"], "hub_40", 0, h * .05, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			tw,th = surface.GetTextSize("Settings: " .. ammo["name"])
		end
		if string.len(textError) > 0 then 
			draw.SimpleText("*ERROR: " .. textError .. "*", "hub_22",  tw * 1.10, h * .05, theme, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end 
	end
	
	local AmmoSettingsPanel = vgui.Create("DPanel", AmmoSettingsEditor)
	AmmoSettingsPanel:SetPos(AmmoSettingsEditor:GetWide() * .02,AmmoSettingsEditor:GetTall() * .1)
	AmmoSettingsPanel:SetSize(AmmoSettingsEditor:GetWide() , AmmoSettingsEditor:GetTall() * .9)
	AmmoSettingsPanel.Paint = function(me,w,h)

	end 

	local AmmoSettingsSave = vgui.Create("DButton", AmmoSettingsEditor)
	AmmoSettingsSave:SetPos(AmmoSettingsEditor:GetWide() * 0.7, AmmoSettingsEditor:GetTall() * .025)
	AmmoSettingsSave:SetSize(AmmoSettingsEditor:GetWide() * 0.2, AmmoSettingsEditor:GetTall() * .05)
	AmmoSettingsSave:SetText("")
	AmmoSettingsSave.Paint = function(me,w,h) 

		surface.SetDrawColor(foreground)
		surface.DrawRect(0,0,w,h)
		if me:IsHovered() then 
			draw.SimpleText("Save Ammo", "hub_22", w / 2, h / 2, theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText("Save Ammo", "hub_20", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

	end 
 
	AmmoSettingsSave.DoClick = function()
		if ammo then 
			SendAmmoData(ammo)
		end 
	end 

	local AmmoSettingsScroll = vgui.Create("DScrollPanel", AmmoSettingsPanel)
	AmmoSettingsScroll:SetPos(0,0)
	AmmoSettingsScroll:SetSize(AmmoSettingsPanel:GetWide() *.99, AmmoSettingsPanel:GetTall())
	paintSbar(AmmoSettingsScroll)

	local ypos = 0
	local highlightColor = Color(theme.r, theme.g, theme.b, 130)
	for k,v in ipairs(configSettings["ammo"]) do
		if v.default then
		v.input = v.default
		end  

		local configOption = vgui.Create("DPanel", AmmoSettingsScroll)
		configOption:SetPos(0, ypos)
		configOption:SetSize(AmmoSettingsScroll:GetWide() * .9, AmmoSettingsScroll:GetTall() * .05)
		configOption.Paint = function(me,w,h)
			if v.required then
				draw.SimpleText(v.title .. " *", "hub_20", w * .14, h / 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(v.title, "hub_20", w * .14, h / 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			end 
		end 
 
		if v.dataType == "string" and v.tablevalue != "category" or v.dataType == "int" and v.tablevalue != "category" then 
			local configOptionInput = vgui.Create("DTextEntry", configOption)
			configOptionInput:SetPos(configOption:GetWide() * .15, 0)
			configOptionInput:SetFont("hub_20")
			configOptionInput:SetSize(configOption:GetWide() * .85, configOption:GetTall())
			configOptionInput:SetUpdateOnType(true)
			if v.dataType == "int" then
				configOptionInput:SetNumeric(true)
			end
			local jobValue = ammo[v.tablevalue]
			if jobValue and v.tablevalue != "allowed" and v.tablevalue != "customCheck" then
				configOptionInput:SetText(ammo[v.tablevalue])
				v.input = ammo[v.tablevalue]
			elseif jobValue and v.tablevalue == "allowed" and ammo["allowedString"] then
				configOptionInput:SetText(ammo["allowedString"])
				v.input = ammo["allowedString"]
			elseif v.tablevalue == "customCheck" and ammo["customCheckString"] and string.len(ammo["customCheckString"]) > 0 then
				configOptionInput:SetText(ammo["customCheckString"])
				v.input = ammo["customCheckString"]
			end
			
			configOptionInput.Paint = function(me,w,h) 
				surface.SetDrawColor(foreground)
				surface.DrawRect(0,0,w,h)
				me:DrawTextEntryText(color_white, highlightColor, highlightColor)
				if string.len(me:GetText()) <= 0 then
					draw.SimpleText(v.defaultText, "hub_20", 5, h / 2, Color(80, 80, 80, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end  
			end

			function configOptionInput:OnValueChange(value)
				v.input = value
			end 

		elseif v.dataType == "bool" then

			local configOptionInput = vgui.Create("DCheckBox", configOption)
			configOptionInput:SetPos(configOption:GetWide() * .15, 0)
			configOptionInput:SetSize(configOption:GetTall(), configOption:GetTall())
			configOptionInput.Paint = function(me,w,h)
			surface.SetDrawColor(foreground)
			surface.DrawRect(0,0,w,h) 
				if me:GetChecked() then
					surface.SetDrawColor(theme)
					surface.SetMaterial(checked)
					surface.DrawTexturedRect(0,0,w,h)
				elseif me:IsHovered() then
					surface.SetDrawColor(highlightColor)
					surface.SetMaterial(checked)
					surface.DrawTexturedRect(0,0,w,h)
				end 

			end

			if ammo[v.tablevalue] then
				configOptionInput:SetChecked(ammo[v.tablevalue]) 
				v.input = ammo[v.tablevalue]
			else
				v.input = false
			end

			function configOptionInput:OnChange(value)
				v.input = value
			end 

		elseif v.tablevalue == "category" then
			local downArrow = Material("icon16/bullet_arrow_down.png") 
			local configOptionInput = vgui.Create( "DComboBox", configOption ) 
			configOptionInput:SetPos(configOption:GetWide() * .15, 0)
			configOptionInput:SetSize(configOption:GetWide() - configOption:GetWide() * .15, configOption:GetTall())
			configOptionInput:SetFont("hub_20")
			configOptionInput:SetTextColor(Color(80,80,80,255))
			configOptionInput:SetValue("Categories")
			configOptionInput.Paint = function(me,w,h)
				surface.SetDrawColor(foreground) 
				surface.DrawRect(0,0,w,h)
			end 
			for k,v in pairs(DarkRP.getCategories()["ammo"]) do
				local category = DarkRP.getCategories()["ammo"][k] 
				configOptionInput:AddChoice(category.name)
			end
			if ammo[v.tablevalue] then
				configOptionInput:SetValue(ammo[v.tablevalue])
				configOptionInput:SetTextColor(color_white)
				v.input = ammo[v.tablevalue]
			end
			function configOptionInput:OnSelect(index, value, data)

				configOptionInput:SetTextColor(color_white)
				v.input = value

			end 
		elseif v.tablevalue == "ammoType" then 
			if ammo[v.tablevalue] then
				v.input = ammo[v.tablevalue]
			end
			local ammoOptions = ammoOptions or game.BuildAmmoTypes()
			for k,dammo in pairs(defaultAmmo) do
				if not table.HasValue(ammoOptions, dammo) then
					table.insert(ammoOptions, dammo)
				end
			end 

			configOption:SetSize(configOption:GetWide(), AmmoSettingsScroll:GetTall() * .5)

			local configOptionScroll = vgui.Create("DScrollPanel", configOption) 
			configOptionScroll:SetPos(configOption:GetWide() * .15,0)
			configOptionScroll:SetSize(configOption:GetWide() * .85, configOption:GetTall())
			paintSbar(configOptionScroll)

			local configOptionList = vgui.Create("DIconLayout", configOptionScroll)
			configOptionList:SetPos(0,0)
			configOptionList:SetSize(configOptionScroll:GetWide() , configOptionScroll:GetTall())
			configOptionList:SetSpaceY(5)
			configOptionList:SetSpaceX(5)

			for _, ammoType in pairs(ammoOptions) do
				
				local WeaponPanel = configOptionList:Add("DPanel")
				WeaponPanel:SetSize(configOption:GetTall() * .27, configOption:GetTall() * .27)
				WeaponPanel.Paint = function(me,w,h)
				surface.SetDrawColor(foreground)
				surface.DrawRect(0,0,w,h)
				draw.SimpleText(ammoType.name, "hub_14", w / 2, 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					if v.input == ammoType.name then 
						surface.SetDrawColor(theme)
						surface.DrawOutlinedRect(0,0,w,h)
					end 
				end 
				local WeaponModel = vgui.Create("LoadModelPanel", WeaponPanel)
				WeaponModel:SetSize(WeaponPanel:GetWide() , WeaponPanel:GetTall() - 16)
				WeaponModel:SetModel(ammoModels[math.random(1, #ammoModels)] or "models/error.mdl", function()
				function WeaponModel:LayoutEntity( Entity ) return end 
				local CamPos = Vector( 15, -6, 60 )
				local LookAt = Vector( 0, 0, 60 )
				WeaponModel.Entity:SetPos( WeaponModel.Entity:GetPos() - Vector( 0, 0, 4 ) )
				WeaponModel:SetCamPos( CamPos )
				WeaponModel:SetLookAt( LookAt )
				WeaponModel:SetFOV(70)
				local num = .7
				local min, max = WeaponModel.Entity:GetRenderBounds()
				WeaponModel:SetCamPos(min:Distance(max) * Vector(num, num, num))
				WeaponModel:SetLookAt((max + min) / 2)
				end)

				WeaponModel.DoClick = function()
					v.input = ammoType.name
				end
			end 
		end 

			ypos = ypos + configOption:GetTall() + (AmmoSettingsScroll:GetTall() * .02)

	end 

end 

local function ConvertToAllowedTable( str )
    local tbl = string.Explode( ',', str )
    local allowedTbl = {}
    for k,v in pairs(tbl) do
    	allowedTbl[k] = _G[v]
    end 
    return allowedTbl
end


function SendAmmoData(tbl)
	
	local AmmoData = {}  

	for k,v in ipairs(configSettings["ammo"]) do

		if v.tablevalue and string.len(v.tablevalue) > 0 then
			local key = v.tablevalue

			if v.required and v.input == nil then

				textError = v.title .. " is not complete!"
				print("ERROR " .. v.title .. " IS A NIL VALUE")
				return
			end 

			if v.dataType == "int" then
				v.input = tonumber(v.input)
			end 
 
			AmmoData[key] = v.input

			if v.tablevalue == "customCheck" then
				if string.len(v.input) <= 0 or v.input == v.default then 
					AmmoData[key] = nil
					AmmoData["customCheckString"] = nil
				elseif string.len(v.input) > 0 and v.input != v.default then
					AmmoData["customCheckString"] = v.input
				end 
				
			end

			if key == "allowed" then
				if v.input and string.len(v.input) <= 0 or v.input and v.input == v.default or not v.input then
					AmmoData[key] = nil
					AmmoData["allowedString"] = nil

				else
					AmmoData["allowedString"] = v.input
					AmmoData[key] = ConvertToAllowedTable(AmmoData["allowedString"])					
				end 
			end 

		end
 
	end


	AmmoData.dconfig = true
	net.Start("dconfig_sendAmmo")    
	net.WriteTable(AmmoData)
	net.SendToServer()

	for k,v in pairs(GAMEMODE.AmmoTypes) do
		if AmmoData.name == GAMEMODE.AmmoTypes[k].name then
			DarkRP.removeAmmoType(k)
		end 
	end 

	if AmmoData.customCheck and AmmoData.customCheckString then 
		AmmoData.customCheck = CompileString("local ply = select(1,...) " .. AmmoData.customCheckString, "customCheck")
	else
		AmmoData.customCheck = nil
	end 
	DarkRP.createAmmoType(AmmoData.ammoType, AmmoData)
	AmmoEditorToggle()
	print(LocalPlayer():GetName() .. " created ammo: " .. AmmoData.name)
	LocalPlayer():ChatPrint("ANY AMMO CHANGES REQUIRE A RESTART: F4 MAY NOT FUNCTION AS USUAL UNTIL RESTART.")



end 