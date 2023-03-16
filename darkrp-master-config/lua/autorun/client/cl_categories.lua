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
PrintTable(theme)
PrintTable(DCONFIG.Settings.Colors["theme"]) 
local function DrawCategoryList(name,categoryList, ypos, parent, listpanel, height)

	local CategoryTitle = vgui.Create("DPanel", parent)
	CategoryTitle:SetPos(0, ypos)
	CategoryTitle:SetSize(listpanel:GetWide(), height / 3)
	CategoryTitle.Paint = function(me,w,h)
		draw.RoundedBox( 8, 0, 0, w - w * .05, h, foreground )
		draw.SimpleText(name, "hub_20", w * .05, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	ypos = ypos + height / 3 + (listpanel:GetTall() * .01)

	for k,v in pairs(categoryList) do
		if categoryList[k].dconfig then 
			local CategoryPanel = vgui.Create("DPanel", parent)
			CategoryPanel:SetPos(0, ypos)
			CategoryPanel:SetSize(listpanel:GetWide(), height)
			CategoryPanel.Paint = function(me,w,h)
				draw.RoundedBox( 8, 0, 0, w - w * .05, h, foreground )
				surface.SetDrawColor(background)
				surface.SetMaterial(circle)
				surface.DrawTexturedRect(w * .03 ,h / 2 - h / 2.6, h / 1.3,h / 1.3)
				draw.SimpleText(v.name, "hub_20", w * .05 + h / 1.2, h * .2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				draw.SimpleText("CATEGORY", "hub_16", w * .12, h /2 , theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			local CategoryEditButton = vgui.Create("DButton", CategoryPanel)
			CategoryEditButton:SetPos(CategoryPanel:GetWide() * .05 + height / 1.2, height * .6)  
			CategoryEditButton:SetSize(CategoryPanel:GetWide() * .15, height * .2)
			CategoryEditButton:SetText("")
			CategoryEditButton.Paint = function(me,w,h)
				if me:IsHovered() then 
					draw.SimpleText("Edit", "hub_18", 0, h / 2, theme, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				else 
					draw.SimpleText("Edit", "hub_16", 0, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end 
			end

			CategoryEditButton.DoClick = function()
				CategorySettings(CategoryEditor, categoryList[k])
			end 


			local CategoryDeleteButton = vgui.Create("DButton", CategoryPanel)
			CategoryDeleteButton:SetPos(CategoryPanel:GetWide() * .2 + height / 1.2, height * .6)  
			CategoryDeleteButton:SetSize(CategoryPanel:GetWide() * .18, height * .2)
			CategoryDeleteButton:SetText("")
			CategoryDeleteButton.Paint = function(me,w,h)
				if me:IsHovered() then 
					draw.SimpleText("Delete", "hub_18", 0, h / 2, theme, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				else 
					draw.SimpleText("Delete", "hub_16", 0, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end 
			end

			CategoryDeleteButton.DoClick = function()

				DConfigConfirm("Do you want to delete ".. v.name .. "?", function()
					net.Start("dconfig_deleteCategory")
					net.WriteString(v.name)
					net.WriteString(v.categorises)
					net.SendToServer()
					for k,_ in pairs(DarkRP.getCategories()[v.categorises]) do
					local cat = DarkRP.getCategories()[v.categorises][k] 
						if cat.name == v.name then
							DarkRP.getCategories()[v.categorises][k] = nil
						end 
					end
					CategoryEditorToggle()
				end )

			end 
		ypos = ypos + height + (listpanel:GetTall() * .01)
		end 
	end
	return ypos 
end  


function CategoryEditorToggle()

	if IsValid(CategoryEditor) then
		CategoryEditor:Remove()
	end

	CategoryEditor = vgui.Create("DPanel", DConfigMenu)
	CategoryEditor:SetPos(dconfigSideBarW, 0)
	CategoryEditor:SetSize(DConfigMenu:GetWide() - dconfigSideBarW, DConfigMenu:GetTall())
	CategoryEditor.Paint = function(me,w,h) end 

	local CategoryList = vgui.Create("DPanel", CategoryEditor)
	CategoryList:SetPos(CategoryEditor:GetWide() * .01,CategoryEditor:GetTall() * .01)
	CategoryList:SetSize(CategoryEditor:GetWide() / 4 - (CategoryEditor:GetWide() * .01), CategoryEditor:GetTall()- (CategoryEditor:GetTall() * .01))
	CategoryList.Paint = function(me,w,h)
		draw.SimpleText("Categories: ", "hub_40", 0, h * .05, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end 

	local CategoryScroll = vgui.Create("DScrollPanel", CategoryList)
	CategoryScroll:SetPos(0, CategoryList:GetTall() * .1)
	CategoryScroll:SetSize(CategoryList:GetWide(), CategoryList:GetTall() * .9)
	paintSbar(CategoryScroll)
	local ypos = 0
	local CategoryPanelH = CategoryList:GetTall() / 10
	local offSet = 5
	local CategoryPanel = vgui.Create("DPanel", CategoryScroll)
	CategoryPanel:SetPos(0, ypos) 
	CategoryPanel:SetSize(CategoryList:GetWide(), CategoryPanelH)
	CategoryPanel.Paint = function(me,w,h)
		draw.RoundedBox( 8, 0, 0, w - w * .05, h, foreground )
		surface.SetDrawColor(background)
		surface.SetMaterial(circle)
		surface.DrawTexturedRect(w * .03 ,h / 2 - h / 2.6, h / 1.3,h / 1.3)
		draw.SimpleText("New Category", "hub_20", w * .05 + h / 1.2, h * .2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	end
	CategoryPanelNew = vgui.Create("DButton", CategoryPanel)
	CategoryPanelNew:SetPos(CategoryList:GetWide() * .03, CategoryPanelH / 2 - CategoryPanelH / 2.6)
	CategoryPanelNew:SetSize(CategoryPanelH / 1.3 ,CategoryPanelH / 1.3)
	CategoryPanelNew:SetText("")
	CategoryPanelNew.Paint = function(me,w,h)
		if me:IsHovered() then
			draw.SimpleText("+", "hub_40", w / 2, h / 2, theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else 
			draw.SimpleText("+", "hub_30", w / 2, h / 2, theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end 
	end

	CategoryPanelNew.DoClick = function()
		CategorySettings(CategoryEditor)
	end

	ypos = ypos + CategoryPanelH + (CategoryList:GetTall() * .01)

	ypos = DrawCategoryList("Jobs", DarkRP.getCategories()["jobs"], ypos, CategoryScroll, CategoryList, CategoryPanelH)
	ypos = DrawCategoryList("Shipments",DarkRP.getCategories()["shipments"], ypos, CategoryScroll, CategoryList, CategoryPanelH) 
	ypos = DrawCategoryList("Weapons",DarkRP.getCategories()["weapons"], ypos, CategoryScroll, CategoryList, CategoryPanelH) 
	ypos = DrawCategoryList("Entities",DarkRP.getCategories()["entities"], ypos, CategoryScroll, CategoryList, CategoryPanelH)
	ypos = DrawCategoryList("Ammo",DarkRP.getCategories()["ammo"], ypos, CategoryScroll, CategoryList, CategoryPanelH)
	ypos = DrawCategoryList("Vehicles",DarkRP.getCategories()["vehicles"], ypos, CategoryScroll, CategoryList, CategoryPanelH)
	dconfigMenu.Elements["categoryeditor"] = CategoryEditor
	CategorySettings(CategoryEditor)
end 


function CategorySettings(parent, category)

	if IsValid(CategorySettingsEditor) then
		CategorySettingsEditor:Remove()
	end
	textError = ""
	category = category or {}
	local weaponOptions = {}
	CategorySettingsEditor = vgui.Create("DPanel", parent)
	CategorySettingsEditor:SetPos(parent:GetWide() * .25 , parent:GetTall() * .01)
	CategorySettingsEditor:SetSize(parent:GetWide() - parent:GetWide() * .25, parent:GetTall())
	local tw, th = 0,0
	CategorySettingsEditor.Paint = function(me,w,h)
		surface.SetFont("hub_40")
		if not category["name"] then
			draw.SimpleText("Settings: New Category", "hub_40", 0, h * .05, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			tw,th = surface.GetTextSize("Settings: New Category")
		else
			draw.SimpleText("Settings: " .. category["name"], "hub_40", 0, h * .05, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			tw,th = surface.GetTextSize("Settings: " .. category["name"])
		end
		if string.len(textError) > 0 then 
			draw.SimpleText("*ERROR: " .. textError .. "*", "hub_22",  tw * 1.10, h * .05, theme, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end 
	end
	
	local CategorySettingsPanel = vgui.Create("DPanel", CategorySettingsEditor)
	CategorySettingsPanel:SetPos(CategorySettingsEditor:GetWide() * .02,CategorySettingsEditor:GetTall() * .1)
	CategorySettingsPanel:SetSize(CategorySettingsEditor:GetWide() , CategorySettingsEditor:GetTall() * .9)
	CategorySettingsPanel.Paint = function(me,w,h)

	end 

	local CategorySettingsSave = vgui.Create("DButton", CategorySettingsEditor)
	CategorySettingsSave:SetPos(CategorySettingsEditor:GetWide() * 0.7, CategorySettingsEditor:GetTall() * .025)
	CategorySettingsSave:SetSize(CategorySettingsEditor:GetWide() * 0.2, CategorySettingsEditor:GetTall() * .05)
	CategorySettingsSave:SetText("") 
	CategorySettingsSave.Paint = function(me,w,h)

		surface.SetDrawColor(foreground)
		surface.DrawRect(0,0,w,h)
		if me:IsHovered() then 
			draw.SimpleText("Save Category", "hub_22", w / 2, h / 2, theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText("Save Category", "hub_20", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

	end 
 
	CategorySettingsSave.DoClick = function()
		SendCategoryData(category)
	end 

	local CategorySettingsScroll = vgui.Create("DScrollPanel", CategorySettingsPanel)
	CategorySettingsScroll:SetPos(0,0)
	CategorySettingsScroll:SetSize(CategorySettingsPanel:GetWide() *.99, CategorySettingsPanel:GetTall())
	paintSbar(CategorySettingsScroll)

	local ypos = 0
	local highlightColor = Color(theme.r, theme.g, theme.b, 130)
	for k,v in ipairs(configSettings["categories"]) do
		if v.default then
		v.input = v.default
		end  

		local configOption = vgui.Create("DPanel", CategorySettingsScroll)
		configOption:SetPos(0, ypos)
		configOption:SetSize(CategorySettingsScroll:GetWide() * .9, CategorySettingsScroll:GetTall() * .05)
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
			local jobValue = category[v.tablevalue]
			if jobValue then 
				configOptionInput:SetText(category[v.tablevalue])
				v.input = category[v.tablevalue]
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

			if category[v.tablevalue] then
				configOptionInput:SetChecked(category[v.tablevalue]) 
				v.input = category[v.tablevalue]
			else
				v.input = false
			end

			function configOptionInput:OnChange(value) 
				v.input = value
			end

		elseif v.dataType == "color" then

			local configOptionInput = vgui.Create("DColorMixer", configOption)
			configOptionInput:SetPos(configOption:GetWide() * .15, 0)
			configOption:SetSize(configOption:GetWide(), CategorySettingsScroll:GetTall() * .2)
			configOptionInput:SetSize(configOption:GetWide() * .85, configOption:GetTall())
			configOptionInput:SetAlphaBar(false)
			configOptionInput:SetWangs(true)
			configOptionInput:SetPalette(false)
			configOptionInput:SetColor(Color(0, 107, 0, 255))
			v.input = Color(0, 107, 0, 255)
			function configOptionInput:ValueChanged(value)
				v.input = value 
			end

			if category[v.tablevalue] then
				configOptionInput:SetColor(category[v.tablevalue])
				v.input = category[v.tablevalue]
			end
		end 
			ypos = ypos + configOption:GetTall() + (CategorySettingsScroll:GetTall() * .02)

	end 

end 

local cats = {"ammo","shipments","jobs","entities","vehicles"}
function SendCategoryData(tbl)
	
	local CategoryData = {}

	for k,v in pairs(configSettings["categories"]) do

		if v.tablevalue and string.len(v.tablevalue) > 0 then
			local key = v.tablevalue

 
			if v.required and v.input == nil then

				textError = v.title .. " is not complete!"
				print("ERROR " .. v.title .. " IS A NIL VALUE")
				return
			end
			if key == "categorises" and !table.HasValue(cats, v.input) then
				textError = v.title .. " is invalid."
				return
			end 

			if v.dataType == "int" then
				v.input = tonumber(v.input)
			end 

			CategoryData[key] = v.input


		end 
 
	end

	CategoryData.dconfig = true
	net.Start("dconfig_sendCategory")    
	net.WriteTable(CategoryData)
	net.SendToServer()

	local destination = CategoryData.categorises
	for k,v in pairs(DarkRP.getCategories()[destination]) do
		local cat = DarkRP.getCategories()[destination][k] 
		if cat.name == CategoryData.name then
			cat = nil
		end 
	end 

	DarkRP.createCategory(CategoryData)
	CategoryEditorToggle()
	print(LocalPlayer():GetName() .. " created category: " .. CategoryData.name)
	LocalPlayer():ChatPrint("ANY CATEGORY CHANGES REQUIRE A RESTART: F4 MAY NOT FUNCTION AS USUAL UNTIL RESTART.")



end 