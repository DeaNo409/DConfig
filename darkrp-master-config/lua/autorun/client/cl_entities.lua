
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
local textError = ""
function EntityEditorToggle()

	if IsValid(EntityEditor) then
		EntityEditor:Remove()
	end

	EntityEditor = vgui.Create("DPanel", DConfigMenu)
	EntityEditor:SetPos(dconfigSideBarW, 0)
	EntityEditor:SetSize(DConfigMenu:GetWide() - dconfigSideBarW, DConfigMenu:GetTall())
	EntityEditor.Paint = function(me,w,h) end 

	local EntityList = vgui.Create("DPanel", EntityEditor)
	EntityList:SetPos(EntityEditor:GetWide() * .01,EntityEditor:GetTall() * .01)
	EntityList:SetSize(EntityEditor:GetWide() / 4 - (EntityEditor:GetWide() * .01), EntityEditor:GetTall()- (EntityEditor:GetTall() * .01))
	EntityList.Paint = function(me,w,h)
		draw.SimpleText("Entities: ", "hub_40", 0, h * .05, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end 

	local EntityScroll = vgui.Create("DScrollPanel", EntityList)
	EntityScroll:SetPos(0, EntityList:GetTall() * .1)
	EntityScroll:SetSize(EntityList:GetWide(), EntityList:GetTall() * .9)
	paintSbar(EntityScroll)
	local ypos = 0
	local EntityPanelH = EntityList:GetTall() / 10
	local offSet = 5
	local EntityPanel = vgui.Create("DPanel", EntityScroll)
	EntityPanel:SetPos(0, ypos)
	EntityPanel:SetSize(EntityList:GetWide(), EntityPanelH)
	EntityPanel.Paint = function(me,w,h)
		draw.RoundedBox( 8, 0, 0, w - w * .05, h, foreground )
		surface.SetDrawColor(background)
		surface.SetMaterial(circle)
		surface.DrawTexturedRect(w * .03 ,h / 2 - h / 2.6, h / 1.3,h / 1.3)
		draw.SimpleText("New Entity", "hub_20", w * .05 + h / 1.2, h * .2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	end
	EntityPanelNew = vgui.Create("DButton", EntityPanel)
	EntityPanelNew:SetPos(EntityList:GetWide() * .03, EntityPanelH / 2 - EntityPanelH / 2.6)
	EntityPanelNew:SetSize(EntityPanelH / 1.3 ,EntityPanelH / 1.3)
	EntityPanelNew:SetText("")
	EntityPanelNew.Paint = function(me,w,h)
		if me:IsHovered() then
			draw.SimpleText("+", "hub_40", w / 2, h / 2, theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else 
			draw.SimpleText("+", "hub_30", w / 2, h / 2, theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end 
	end

	EntityPanelNew.DoClick = function()
		EntitySettings(EntityEditor)
	end

	ypos = ypos + EntityPanelH + (EntityList:GetTall() * .01)
	for k,v in pairs(DarkRPEntities) do
		if DarkRPEntities[k].dconfig then 
			local EntityPanel = vgui.Create("DPanel", EntityScroll)
			EntityPanel:SetPos(0, ypos)
			EntityPanel:SetSize(EntityList:GetWide(), EntityPanelH)
			EntityPanel.Paint = function(me,w,h)
				draw.RoundedBox( 8, 0, 0, w - w * .05, h, foreground )
				surface.SetDrawColor(background)
				surface.SetMaterial(circle)
				draw.SimpleText(v.name, "hub_20", w * .05 + h / 1.2, h * .2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			
			end

			local EntityEditButton = vgui.Create("DButton", EntityPanel)
			EntityEditButton:SetPos(EntityPanel:GetWide() * .05 + EntityPanelH / 1.2, EntityPanelH * .6)  
			EntityEditButton:SetSize(EntityPanel:GetWide() * .15, EntityPanelH * .2)
			EntityEditButton:SetText("")
			EntityEditButton.Paint = function(me,w,h)
				if me:IsHovered() then 
					draw.SimpleText("Edit", "hub_18", 0, h / 2, theme, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				else 
					draw.SimpleText("Edit", "hub_16", 0, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end 
			end

			EntityEditButton.DoClick = function() 
				EntitySettings(EntityEditor, DarkRPEntities[k])
			end 


			local EntityDeleteButton = vgui.Create("DButton", EntityPanel)
			EntityDeleteButton:SetPos(EntityPanel:GetWide() * .2 + EntityPanelH / 1.2, EntityPanelH * .6)  
			EntityDeleteButton:SetSize(EntityPanel:GetWide() * .18, EntityPanelH * .2)
			EntityDeleteButton:SetText("")
			EntityDeleteButton.Paint = function(me,w,h)
				if me:IsHovered() then 
					draw.SimpleText("Delete", "hub_18", 0, h / 2, theme, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				else 
					draw.SimpleText("Delete", "hub_16", 0, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end 
			end

			EntityDeleteButton.DoClick = function()

				DConfigConfirm("Do you want to delete ".. v.name .. "?", function()
					net.Start("dconfig_deleteEntity")
					net.WriteString(v.name)
					net.SendToServer()
					LocalPlayer():ChatPrint("Removed entity: " .. v.name)
					DarkRP.removeEntity(k)
					EntityEditorToggle()
				end )

			end 

			local EntityModel = vgui.Create("DModelPanel", EntityPanel) 
			EntityModel:SetPos(0,0)
			EntityModel:SetPos(EntityPanel:GetWide() * .03, EntityPanel:GetTall() / 2 - (EntityPanel:GetTall() / 2.6))
			EntityModel:SetSize(EntityPanel:GetTall() / 1.3, EntityPanel:GetTall() / 1.3)
			EntityModel:SetModel(string.lower(DarkRPEntities[k].model) or "models/props_c17/consolebox01a.mdl")
			function EntityModel:LayoutEntity( Entity ) return end 
			local CamPos = Vector( 15, -6, 60 )
			local LookAt = Vector( 0, 0, 60 )
			EntityModel.Entity:SetPos( EntityModel.Entity:GetPos() - Vector( 0, 0, 4 ) )
			EntityModel:SetCamPos( CamPos )
			EntityModel:SetLookAt( LookAt )
			EntityModel:SetFOV(50)
			local num = .7
			local min, max = EntityModel.Entity:GetRenderBounds() 
			EntityModel:SetCamPos(min:Distance(max) * Vector(num, num, num))
			EntityModel:SetLookAt((max + min) / 2)
		 
		 	local oldPaint = EntityModel.Paint

			function EntityModel:Paint(w, h)

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
			ypos = ypos + EntityPanelH + (EntityList:GetTall() * .01)
		end
	end

	dconfigMenu.Elements["entityeditor"] = EntityEditor
	EntitySettings(EntityEditor)

end 


function EntitySettings(parent, entity)

	if IsValid(EntitySettingsEditor) then
		EntitySettingsEditor:Remove()
	end
	textError = ""
	entity = entity or {}
	EntitySettingsEditor = vgui.Create("DPanel", parent)
	EntitySettingsEditor:SetPos(parent:GetWide() * .25 , parent:GetTall() * .01)
	EntitySettingsEditor:SetSize(parent:GetWide() - parent:GetWide() * .25, parent:GetTall())
	local tw, th = 0,0
	EntitySettingsEditor.Paint = function(me,w,h)
		surface.SetFont("hub_40")
		if not entity["name"] then
			draw.SimpleText("Settings: New Entity", "hub_40", 0, h * .05, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			tw,th = surface.GetTextSize("Settings: New Entity")
		else
			draw.SimpleText("Settings: " .. entity["name"], "hub_40", 0, h * .05, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			tw,th = surface.GetTextSize("Settings: " .. entity["name"])
		end
		if string.len(textError) > 0 then 
			draw.SimpleText("*ERROR: " .. textError .. "*", "hub_22",  tw * 1.10, h * .05, theme, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end 
	end
	
	local EntitySettingsPanel = vgui.Create("DPanel", EntitySettingsEditor)
	EntitySettingsPanel:SetPos(EntitySettingsEditor:GetWide() * .02,EntitySettingsEditor:GetTall() * .1)
	EntitySettingsPanel:SetSize(EntitySettingsEditor:GetWide() , EntitySettingsEditor:GetTall() * .9)
	EntitySettingsPanel.Paint = function(me,w,h)

	end 

	local EntitySettingsSave = vgui.Create("DButton", EntitySettingsEditor)
	EntitySettingsSave:SetPos(EntitySettingsEditor:GetWide() * 0.7, EntitySettingsEditor:GetTall() * .025)
	EntitySettingsSave:SetSize(EntitySettingsEditor:GetWide() * 0.2, EntitySettingsEditor:GetTall() * .05)
	EntitySettingsSave:SetText("")
	EntitySettingsSave.Paint = function(me,w,h)

		surface.SetDrawColor(foreground)
		surface.DrawRect(0,0,w,h)
		if me:IsHovered() then 
			draw.SimpleText("Save Entity", "hub_22", w / 2, h / 2, theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText("Save Entity", "hub_20", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

	end 
 
	EntitySettingsSave.DoClick = function()
		SendEntityData(entity)
	end 

	local EntitySettingsScroll = vgui.Create("DScrollPanel", EntitySettingsPanel)
	EntitySettingsScroll:SetPos(0,0)
	EntitySettingsScroll:SetSize(EntitySettingsPanel:GetWide() *.99, EntitySettingsPanel:GetTall())
	paintSbar(EntitySettingsScroll)

	local ypos = 0
	local highlightColor = Color(theme.r, theme.g, theme.b, 130)
	for k,v in ipairs(configSettings["entities"]) do
		if v.default then
		v.input = v.default
		end  

		local configOption = vgui.Create("DPanel", EntitySettingsScroll)
		configOption:SetPos(0, ypos)
		configOption:SetSize(EntitySettingsScroll:GetWide() * .9, EntitySettingsScroll:GetTall() * .05)
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
			local jobValue = entity[v.tablevalue]
			if jobValue and v.tablevalue != "customCheck" and v.tablevalue != "allowed" then
				configOptionInput:SetText(entity[v.tablevalue])
				v.input = entity[v.tablevalue]
			elseif jobValue and v.tablevalue == "allowed" and entity["allowedString"] then
				configOptionInput:SetText(entity["allowedString"])
				v.input = entity["allowedString"]
			elseif v.tablevalue == "customCheck" and entity["customCheckString"] and string.len(entity["customCheckString"]) > 0 then
				configOptionInput:SetText(entity["customCheckString"])
				v.input = entity["customCheckString"]
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

			if entity[v.tablevalue] then
				configOptionInput:SetChecked(entity[v.tablevalue]) 
				v.input = entity[v.tablevalue]
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
			for k,v in pairs(DarkRP.getCategories()["entities"]) do
				local category = DarkRP.getCategories()["entities"][k] 
				configOptionInput:AddChoice(category.name)
			end
			if entity[v.tablevalue] then
				configOptionInput:SetValue(entity[v.tablevalue])
				configOptionInput:SetTextColor(color_white)
				v.input = entity[v.tablevalue]
			end
			function configOptionInput:OnSelect(index, value, data)

				configOptionInput:SetTextColor(color_white)
				v.input = value

			end 
		end 

			ypos = ypos + configOption:GetTall() + (EntitySettingsScroll:GetTall() * .02)

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

function SendEntityData(tbl)
	
	local EntityData = {}

	for k,v in pairs(configSettings["entities"]) do

		if v.tablevalue and string.len(v.tablevalue) > 0 then
			local key = v.tablevalue

 
			if v.required and v.input == nil or v.input and string.len(v.input) <= 0 and v.required then

				textError = v.title .. " is not complete!"
				print("ERROR " .. v.title .. " IS A NIL VALUE")
				return
			end 

			if v.dataType == "int" then
				v.input = tonumber(v.input)
			end 

			EntityData[key] = v.input 

			if key == "allowed" then
				if v.input and string.len(v.input) <= 0 or v.input and v.input == v.default or not v.input then
					EntityData[key] = nil
					EntityData["allowedString"] = nil

				else
					EntityData["allowedString"] = v.input
					EntityData[key] = ConvertToAllowedTable(EntityData["allowedString"])					
				end 
			end 



			if v.tablevalue == "customCheck" then
				if string.len(v.input) <= 0 or v.input == v.default then 
					EntityData[key] = nil
					EntityData["customCheckString"] = nil
				elseif string.len(v.input) > 0 and v.input != v.default then
					EntityData["customCheckString"] = v.input
				end 
				
			end

		end 
 
	end


	EntityData.dconfig = true
	net.Start("dconfig_sendEntity")    
	net.WriteTable(EntityData)
	net.SendToServer()

	for k,v in pairs(DarkRPEntities) do
		if EntityData.name == DarkRPEntities[k].name then
			DarkRP.removeEntity(k) 
		end 
	end 

	if EntityData.customCheck and EntityData.customCheckString then 
		EntityData.customCheck = CompileString("local ply = select(1,...) " .. EntityData.customCheckString, "customCheck")
	else
		EntityData.customCheck = nil
	end 
	DarkRP.createEntity(EntityData.name, EntityData)
	EntityEditorToggle()
	print(LocalPlayer():GetName() .. " created entity: " .. EntityData.name)
	LocalPlayer():ChatPrint("ANY ENTITY CHANGES REQUIRE A RESTART: F4 MAY NOT FUNCTION AS USUAL UNTIL RESTART.")



end 
