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
function ShipmentEditorToggle()

	if IsValid(ShipmentEditor) then
		ShipmentEditor:Remove()
	end

	ShipmentEditor = vgui.Create("DPanel", DConfigMenu)
	ShipmentEditor:SetPos(dconfigSideBarW, 0)
	ShipmentEditor:SetSize(DConfigMenu:GetWide() - dconfigSideBarW, DConfigMenu:GetTall())
	ShipmentEditor.Paint = function(me,w,h) end 

	local ShipmentList = vgui.Create("DPanel", ShipmentEditor)
	ShipmentList:SetPos(ShipmentEditor:GetWide() * .01,ShipmentEditor:GetTall() * .01)
	ShipmentList:SetSize(ShipmentEditor:GetWide() / 4 - (ShipmentEditor:GetWide() * .01), ShipmentEditor:GetTall()- (ShipmentEditor:GetTall() * .01))
	ShipmentList.Paint = function(me,w,h)
		draw.SimpleText("Shipments: ", "hub_40", 0, h * .05, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end 

	local ShipmentScroll = vgui.Create("DScrollPanel", ShipmentList)
	ShipmentScroll:SetPos(0, ShipmentList:GetTall() * .1)
	ShipmentScroll:SetSize(ShipmentList:GetWide(), ShipmentList:GetTall() * .9)
	paintSbar(ShipmentScroll)
	local ypos = 0
	local ShipmentPanelH = ShipmentList:GetTall() / 10
	local offSet = 5
	local ShipmentPanel = vgui.Create("DPanel", ShipmentScroll)
	ShipmentPanel:SetPos(0, ypos)
	ShipmentPanel:SetSize(ShipmentList:GetWide(), ShipmentPanelH)
	ShipmentPanel.Paint = function(me,w,h)
		draw.RoundedBox( 8, 0, 0, w - w * .05, h, foreground )
		surface.SetDrawColor(background)
		surface.SetMaterial(circle)
		surface.DrawTexturedRect(w * .03 ,h / 2 - h / 2.6, h / 1.3,h / 1.3)
		draw.SimpleText("New Shipment", "hub_20", w * .05 + h / 1.2, h * .2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	end
	ShipmentPanelNew = vgui.Create("DButton", ShipmentPanel)
	ShipmentPanelNew:SetPos(ShipmentList:GetWide() * .03, ShipmentPanelH / 2 - ShipmentPanelH / 2.6)
	ShipmentPanelNew:SetSize(ShipmentPanelH / 1.3 ,ShipmentPanelH / 1.3)
	ShipmentPanelNew:SetText("")
	ShipmentPanelNew.Paint = function(me,w,h)
		if me:IsHovered() then
			draw.SimpleText("+", "hub_40", w / 2, h / 2, theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else 
			draw.SimpleText("+", "hub_30", w / 2, h / 2, theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end 
	end

	ShipmentPanelNew.DoClick = function()
		ShipmentSettings(ShipmentEditor)
	end

	ypos = ypos + ShipmentPanelH + (ShipmentList:GetTall() * .01)
	for k,v in pairs(CustomShipments) do
		if CustomShipments[k].dconfig then 
			local ShipmentPanel = vgui.Create("DPanel", ShipmentScroll)
			ShipmentPanel:SetPos(0, ypos)
			ShipmentPanel:SetSize(ShipmentList:GetWide(), ShipmentPanelH)
			ShipmentPanel.Paint = function(me,w,h)
				draw.RoundedBox( 8, 0, 0, w - w * .05, h, foreground )
				surface.SetDrawColor(background)
				surface.SetMaterial(circle)
				draw.SimpleText(v.name, "hub_20", w * .05 + h / 1.2, h * .2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			
			end

			local ShipmentEditButton = vgui.Create("DButton", ShipmentPanel)
			ShipmentEditButton:SetPos(ShipmentPanel:GetWide() * .05 + ShipmentPanelH / 1.2, ShipmentPanelH * .6)  
			ShipmentEditButton:SetSize(ShipmentPanel:GetWide() * .15, ShipmentPanelH * .2)
			ShipmentEditButton:SetText("")
			ShipmentEditButton.Paint = function(me,w,h)
				if me:IsHovered() then 
					draw.SimpleText("Edit", "hub_18", 0, h / 2, theme, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				else 
					draw.SimpleText("Edit", "hub_16", 0, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end 
			end

			ShipmentEditButton.DoClick = function()
				ShipmentSettings(ShipmentEditor, CustomShipments[k])
			end 


			local ShipmentDeleteButton = vgui.Create("DButton", ShipmentPanel)
			ShipmentDeleteButton:SetPos(ShipmentPanel:GetWide() * .2 + ShipmentPanelH / 1.2, ShipmentPanelH * .6)  
			ShipmentDeleteButton:SetSize(ShipmentPanel:GetWide() * .18, ShipmentPanelH * .2)
			ShipmentDeleteButton:SetText("")
			ShipmentDeleteButton.Paint = function(me,w,h)
				if me:IsHovered() then 
					draw.SimpleText("Delete", "hub_18", 0, h / 2, theme, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				else 
					draw.SimpleText("Delete", "hub_16", 0, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end 
			end

			ShipmentDeleteButton.DoClick = function()

				DConfigConfirm("Do you want to delete ".. v.name .. "?", function()
					net.Start("dconfig_deleteShipment")
					net.WriteInt(k, 8)
					net.SendToServer()
					DarkRP.removeShipment(k)
					ShipmentEditorToggle()
				end )

			end 

			local ShipmentModel = vgui.Create("DModelPanel", ShipmentPanel)
			ShipmentModel:SetPos(0,0)
			ShipmentModel:SetPos(ShipmentPanel:GetWide() * .03, ShipmentPanel:GetTall() / 2 - (ShipmentPanel:GetTall() / 2.6))
			ShipmentModel:SetSize(ShipmentPanel:GetTall() / 1.3, ShipmentPanel:GetTall() / 1.3)
			ShipmentModel:SetModel(string.lower(CustomShipments[k].model))
			function ShipmentModel:LayoutEntity( Entity ) return end 
			local CamPos = Vector( 15, -6, 60 )
			local LookAt = Vector( 0, 0, 60 )
			ShipmentModel.Entity:SetPos( ShipmentModel.Entity:GetPos() - Vector( 0, 0, 4 ) )
			ShipmentModel:SetCamPos( CamPos )
			ShipmentModel:SetLookAt( LookAt )
			ShipmentModel:SetFOV(50)
			local num = .7
			local min, max = ShipmentModel.Entity:GetRenderBounds() 
			ShipmentModel:SetCamPos(min:Distance(max) * Vector(num, num, num))
			ShipmentModel:SetLookAt((max + min) / 2)
		 
		 	local oldPaint = ShipmentModel.Paint

			function ShipmentModel:Paint(w, h)

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
		ypos = ypos + ShipmentPanelH + (ShipmentList:GetTall() * .01)
		end 
	end

	dconfigMenu.Elements["shipmenteditor"] = ShipmentEditor
	ShipmentSettings(ShipmentEditor)

end 


function ShipmentSettings(parent, shipment)

	if IsValid(ShipmentSettingsEditor) then
		ShipmentSettingsEditor:Remove()
	end
	textError = ""
	shipment = shipment or {}
	local weaponOptions = {}
	ShipmentSettingsEditor = vgui.Create("DPanel", parent)
	ShipmentSettingsEditor:SetPos(parent:GetWide() * .25 , parent:GetTall() * .01)
	ShipmentSettingsEditor:SetSize(parent:GetWide() - parent:GetWide() * .25, parent:GetTall())
	local tw, th = 0,0
	ShipmentSettingsEditor.Paint = function(me,w,h)
		surface.SetFont("hub_40")
		if not shipment["name"] then
			draw.SimpleText("Settings: New Shipment", "hub_40", 0, h * .05, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			tw,th = surface.GetTextSize("Settings: New Shipment")
		else
			draw.SimpleText("Settings: " .. shipment["name"], "hub_40", 0, h * .05, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			tw,th = surface.GetTextSize("Settings: " .. shipment["name"])
		end
		if string.len(textError) > 0 then 
			draw.SimpleText("*ERROR: " .. textError .. "*", "hub_22",  tw * 1.10, h * .05, theme, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end 
	end
	
	local ShipmentSettingsPanel = vgui.Create("DPanel", ShipmentSettingsEditor)
	ShipmentSettingsPanel:SetPos(ShipmentSettingsEditor:GetWide() * .02,ShipmentSettingsEditor:GetTall() * .1)
	ShipmentSettingsPanel:SetSize(ShipmentSettingsEditor:GetWide() , ShipmentSettingsEditor:GetTall() * .9)
	ShipmentSettingsPanel.Paint = function(me,w,h)

	end 

	local ShipmentSettingsSave = vgui.Create("DButton", ShipmentSettingsEditor)
	ShipmentSettingsSave:SetPos(ShipmentSettingsEditor:GetWide() * 0.7, ShipmentSettingsEditor:GetTall() * .025)
	ShipmentSettingsSave:SetSize(ShipmentSettingsEditor:GetWide() * 0.2, ShipmentSettingsEditor:GetTall() * .05)
	ShipmentSettingsSave:SetText("")
	ShipmentSettingsSave.Paint = function(me,w,h)

		surface.SetDrawColor(foreground)
		surface.DrawRect(0,0,w,h)
		if me:IsHovered() then 
			draw.SimpleText("Save Shipment", "hub_22", w / 2, h / 2, theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText("Save Shipment", "hub_20", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

	end 
 
	ShipmentSettingsSave.DoClick = function()
		SendShipmentData(shipment)
	end 

	local ShipmentSettingScroll = vgui.Create("DScrollPanel", ShipmentSettingsPanel)
	ShipmentSettingScroll:SetPos(0,0)
	ShipmentSettingScroll:SetSize(ShipmentSettingsPanel:GetWide() *.99, ShipmentSettingsPanel:GetTall())
	paintSbar(ShipmentSettingScroll)

	local ypos = 0
	local highlightColor = Color(theme.r, theme.g, theme.b, 130)
	for k,v in ipairs(configSettings["shipments"]) do
		if v.default then
		v.input = v.default
		end  

		local configOption = vgui.Create("DPanel", ShipmentSettingScroll)
		configOption:SetPos(0, ypos)
		configOption:SetSize(ShipmentSettingScroll:GetWide() * .9, ShipmentSettingScroll:GetTall() * .05)
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
			local jobValue = shipment[v.tablevalue]
			if jobValue and v.tablevalue != "allowed" and v.tablevalue != "customCheck" then
				configOptionInput:SetText(shipment[v.tablevalue])
				v.input = shipment[v.tablevalue]
			elseif jobValue and v.tablevalue == "allowed" and shipment["allowedString"] then
				configOptionInput:SetText(shipment["allowedString"])
				v.input = shipment["allowedString"]
			elseif v.tablevalue == "customCheck" and shipment["customCheckString"] and string.len(shipment["customCheckString"]) > 0 then
				configOptionInput:SetText(shipment["customCheckString"])
				v.input = shipment["customCheckString"]
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
				--LocalPlayer():ChatPrint("asdds")
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

			if shipment[v.tablevalue] then
				configOptionInput:SetChecked(shipment[v.tablevalue]) 
				v.input = shipment[v.tablevalue]
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
			for k,v in pairs(DarkRP.getCategories()["shipments"]) do
				local category = DarkRP.getCategories()["shipments"][k]
				configOptionInput:AddChoice(category.name)
			end
			if shipment[v.tablevalue] then
				configOptionInput:SetValue(shipment[v.tablevalue])
				configOptionInput:SetTextColor(color_white)
				v.input = shipment[v.tablevalue]
			end
			function configOptionInput:OnSelect(index, value, data)

				configOptionInput:SetTextColor(color_white)
				v.input = value

			end 

		elseif v.dataType == "table" and v.title == "Weapon" then 
			if shipment[v.tablevalue] then
				v.input = shipment[v.tablevalue]
			end
			for key, weapon in pairs(weapons.GetList()) do
				if not weapon.WorldModel or string.len(weapon.WorldModel) == 0 then 
				weaponOptions[key] = {class = weapon.ClassName}
				else 
				weaponOptions[key] = {class = weapon.ClassName, model = weapon.WorldModel}
			    end
			end
			configOption:SetSize(configOption:GetWide(), ShipmentSettingScroll:GetTall() * .5)

			local configOptionScroll = vgui.Create("DScrollPanel", configOption) 
			configOptionScroll:SetPos(configOption:GetWide() * .15,0)
			configOptionScroll:SetSize(configOption:GetWide() * .85, configOption:GetTall())
			paintSbar(configOptionScroll)

			local configOptionList = vgui.Create("DIconLayout", configOptionScroll)
			configOptionList:SetPos(0,0)
			configOptionList:SetSize(configOptionScroll:GetWide() , configOptionScroll:GetTall())
			configOptionList:SetSpaceY(5)
			configOptionList:SetSpaceX(5)

			for _, wep in pairs(weaponOptions) do
				
					local WeaponPanel = configOptionList:Add("DPanel")
					WeaponPanel:SetSize(configOption:GetTall() * .27, configOption:GetTall() * .27)
					local ammo = weapons.GetStored(wep.class).Primary.Ammo
					WeaponPanel.Paint = function(me,w,h)
					surface.SetDrawColor(foreground)
					surface.DrawRect(0,0,w,h)
					draw.SimpleText(wep.class, "hub_14", w / 2, 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

						if  v.input and v.input == wep.class then
							surface.SetDrawColor(theme)
							surface.DrawOutlinedRect(0,0,w,h)
						end 
					
					end 
					local WeaponModel = vgui.Create("LoadModelPanel", WeaponPanel)
					WeaponModel:SetSize(WeaponPanel:GetWide() , WeaponPanel:GetTall() - 16)
					WeaponModel:SetModel(wep.model or "models/weapons/w_crowbar.mdl", function()
					function WeaponModel:LayoutEntity( Entity ) return end 
					local CamPos = Vector( 15, -6, 60 )
					local LookAt = Vector( 0, 0, 60 )
					WeaponModel.Entity:SetPos( WeaponModel.Entity:GetPos() - Vector( 0, 0, 4 ) )
					WeaponModel:SetCamPos( CamPos )
					WeaponModel:SetLookAt( LookAt )
					WeaponModel:SetFOV(50)
					local num = .7
					local min, max = WeaponModel.Entity:GetRenderBounds()
					WeaponModel:SetCamPos(min:Distance(max) * Vector(num, num, num))
					WeaponModel:SetLookAt((max + min) / 2)

					end)
					
					WeaponModel.DoClick = function()
							if not v.input then 
								v.input = wep.class
							elseif v.input and v.input == wep.class then
								v.input = nil
							else 
								v.input = wep.class
							end 
					end
			end 
		end 

			ypos = ypos + configOption:GetTall() + (ShipmentSettingScroll:GetTall() * .02)

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


function SendShipmentData(tbl)
	
	local ShipmentData = {}
	for k,v in pairs(configSettings["shipments"]) do

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

			ShipmentData[key] = v.input

			if v.tablevalue == "customCheck" then
				if string.len(v.input) <= 0 or v.input == v.default then 
					ShipmentData[key] = nil
					ShipmentData["customCheckString"] = nil
				elseif string.len(v.input) > 0 and v.input != v.default then
					ShipmentData["customCheckString"] = v.input
				end 
				
			end

			if key == "allowed" then
				if v.input and string.len(v.input) <= 0 or v.input and v.input == v.default or not v.input then
					ShipmentData[key] = nil
					ShipmentData["allowedString"] = nil
				else
					ShipmentData["allowedString"] = v.input
					ShipmentData[key] = ConvertToAllowedTable(ShipmentData["allowedString"])					

				end 
			end 

		end 
 
	end

	local class = ShipmentData["entity"]

	if weapons.GetStored(ShipmentData["entity"]) then
		ShipmentData["model"] = weapons.GetStored(ShipmentData["entity"]).WorldModel
	else
		for _, wep in pairs(weapons.GetList()) do

			if class == wep.ClassName then
				ShipmentData["model"] = wep.WorldModel
				break
			end 
		end 
	end 

	ShipmentData.dconfig = true
	net.Start("dconfig_sendShipment")    
	net.WriteTable(ShipmentData)
	net.SendToServer()

	for k,v in pairs(CustomShipments) do
		if ShipmentData.name == CustomShipments[k].name then
			DarkRP.removeShipment(k)
		end 
	end 

	if ShipmentData.customCheck and ShipmentData.customCheckString then 
		ShipmentData.customCheck = CompileString("local ply = select(1,...) " .. ShipmentData.customCheckString, "customCheck")
	else
		ShipmentData.customCheck = nil
	end 
	DarkRP.createShipment(ShipmentData.name, ShipmentData)
	ShipmentEditorToggle()
	print(LocalPlayer():GetName() .. " created shipment: " .. ShipmentData.name)
	LocalPlayer():ChatPrint("ANY SHIPMENT CHANGES REQUIRE A RESTART: F4 MAY NOT FUNCTION AS USUAL UNTIL RESTART.")



end 