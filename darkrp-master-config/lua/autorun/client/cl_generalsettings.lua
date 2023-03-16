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
local GeneralSettingsText = 
[[

Here you can edit your general settings. It is recommended that you edit the settings in the settings.lua, for in that file you will 
find comments that give a better explaination of what each option does. Additionally you will find configuration options that include tables that this editor does not 
currently support.]]
function GeneralSettingsEditorToggle()

	if IsValid(GeneralEditor) then
		GeneralEditor:Remove()
	end

	GeneralEditor = vgui.Create("DPanel", DConfigMenu)
	GeneralEditor:SetPos(dconfigSideBarW, 0)
	GeneralEditor:SetSize(DConfigMenu:GetWide() - dconfigSideBarW, DConfigMenu:GetTall())
	GeneralEditor.Paint = function(me,w,h) end 

	local GeneralList = vgui.Create("DPanel", GeneralEditor)
	GeneralList:SetPos(GeneralEditor:GetWide() * .01,GeneralEditor:GetTall() * .01)
	GeneralList:SetSize(GeneralEditor:GetWide() * .2 - (GeneralEditor:GetWide() * .01), GeneralEditor:GetTall()- (GeneralEditor:GetTall() * .01))
	local GeneralPanelH = GeneralList:GetTall() / 10
	GeneralList.Paint = function(me,w,h)
		surface.SetDrawColor(foreground)
		surface.DrawRect(0, GeneralPanelH,w,h - GeneralPanelH * 2)
		draw.SimpleText("General Settings: ", "hub_40", 0, h * .05, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	local GeneralPanelH = GeneralList:GetTall() / 10
	local richtext = vgui.Create( "RichText", GeneralList )
	richtext:SetPos(5, GeneralPanelH)
	richtext:SetSize(GeneralList:GetWide(), GeneralList:GetTall())
	richtext:InsertColorChange(255,255,255,255)
	--richtext:SetFont("hub_20")
	richtext:AppendText(GeneralSettingsText)
		
	richtext.Paint = function()
		richtext.m_FontName = "hub_20"
		richtext:SetFontInternal( "hub_20" )	
		richtext:SetBGColor(Color(0,0,0,0))		
		richtext.Paint = nil
	end

	local GeneralScroll = vgui.Create("DScrollPanel", GeneralList)
	GeneralScroll:SetPos(0, GeneralList:GetTall() * .1)
	GeneralScroll:SetSize(GeneralList:GetWide(), GeneralList:GetTall() * .9)
	paintSbar(GeneralScroll)
	local GeneralPanelH = GeneralList:GetTall() / 10

	GeneralSettings(GeneralEditor) 

	dconfigMenu.Elements["generalsettingseditor"] = GeneralEditor

end 

local settingsTable = {}


local function createSettings()

	local count = 1
	local ty
	local gm = (GM or GAMEMODE)
	for k,v in pairs(gm.Config) do 
		if type(v) != "table" then 
			if k == "doorcost" then
				ty = "number"
			else
				ty = type(v)
			end 
			settingsTable[count] = {required = false, tablevalue = k, title = k, dataType = ty or type(v), default = v, defaultText = v}
			count = count + 1
		end  
	end
	table.sort( settingsTable, function( a, b ) return a.dataType > b.dataType end )

end 



function GeneralSettings(parent, settings)
	createSettings()
	if IsValid(GeneralSettingsEditor) then
		GeneralSettingsEditor:Remove()
	end
	textError = ""
	settings = settings or {}
	local weaponOptions = {}
	GeneralSettingsEditor = vgui.Create("DPanel", parent)
	GeneralSettingsEditor:SetPos(parent:GetWide() * .2 , parent:GetTall() * .01)
	GeneralSettingsEditor:SetSize(parent:GetWide() - parent:GetWide() * .2, parent:GetTall())
	local tw, th = 0,0
	GeneralSettingsEditor.Paint = function(me,w,h)
		--draw.SimpleText("Settings", "hub_40", 0, h * .05, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		if string.len(textError) > 0 then 
			draw.SimpleText("*ERROR: " .. textError .. "*", "hub_22",  tw * 1.10, h * .05, theme, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end 
	end
	
	local GeneralSettingsPanel = vgui.Create("DPanel", GeneralSettingsEditor)
	GeneralSettingsPanel:SetPos(GeneralSettingsEditor:GetWide() * .02,GeneralSettingsEditor:GetTall() * .1)
	GeneralSettingsPanel:SetSize(GeneralSettingsEditor:GetWide() , GeneralSettingsEditor:GetTall() * .9)
	GeneralSettingsPanel.Paint = function(me,w,h)

	end 

	local GeneralSettingsSave = vgui.Create("DButton", GeneralSettingsEditor)
	GeneralSettingsSave:SetPos(GeneralSettingsEditor:GetWide() * 0.7, GeneralSettingsEditor:GetTall() * .025)
	GeneralSettingsSave:SetSize(GeneralSettingsEditor:GetWide() * 0.2, GeneralSettingsEditor:GetTall() * .05)
	GeneralSettingsSave:SetText("") 
	GeneralSettingsSave.Paint = function(me,w,h)

		surface.SetDrawColor(foreground)
		surface.DrawRect(0,0,w,h)
		if me:IsHovered() then 
			draw.SimpleText("Save Settings", "hub_22", w / 2, h / 2, theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText("Save Settings", "hub_20", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

	end 
 
	GeneralSettingsSave.DoClick = function()
		SendGeneralSettings(settingsTable)
	end 

	local GeneralSettingsScroll = vgui.Create("DScrollPanel", GeneralSettingsPanel)
	GeneralSettingsScroll:SetPos(0,0)
	GeneralSettingsScroll:SetSize(GeneralSettingsPanel:GetWide() *.99, GeneralSettingsPanel:GetTall())
	paintSbar(GeneralSettingsScroll)

	local ypos = 0
	local highlightColor = Color(theme.r, theme.g, theme.b, 130)
	for k,v in ipairs(settingsTable) do

		if v.default then
			v.input = v.default
		end  
		local configOption = vgui.Create("DPanel", GeneralSettingsScroll)
		configOption:SetPos(0, ypos)
		configOption:SetSize(GeneralSettingsScroll:GetWide() * .9, GeneralSettingsScroll:GetTall() * .05)
		configOption.Paint = function(me,w,h)
			if v.required then
				draw.SimpleText(v.title .. " *", "hub_16", w * .14, h / 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(v.title, "hub_16", w * .14, h / 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			end 
		end 

		if v.dataType == "string" or v.dataType == "number" then 
			local configOptionInput = vgui.Create("DTextEntry", configOption)
			configOptionInput:SetPos(configOption:GetWide() * .15, 0)
			configOptionInput:SetFont("hub_20")
			configOptionInput:SetSize(configOption:GetWide() * .85, configOption:GetTall())
			configOptionInput:SetUpdateOnType(true)
			if v.dataType == "number" then
				configOptionInput:SetNumeric(true)
			end
			if v.input then
				configOptionInput:SetValue(v.input)
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

		elseif v.dataType == "boolean" then

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

			
			if v.default then
				configOptionInput:SetChecked(v.default) 
				v.input = v.default
			else
				v.input = false
			end

			function configOptionInput:OnChange(value) 
				v.input = value
			end
			

		end 
		ypos = ypos + configOption:GetTall() + (GeneralSettingsScroll:GetTall() * .02)
	end 

end 

local cats = {"ammo","shipments","jobs","entities","vehicles", "weapons"}
function SendGeneralSettings(settings)
	

	for k,v in pairs(settings) do

		if v.tablevalue and string.len(v.tablevalue) > 0 then
			local key = v.tablevalue
 
			if v.required and v.input == nil then

				textError = v.title .. " is not complete!"
				print("ERROR " .. v.title .. " IS A NIL VALUE")
				return
			end 

			if v.dataType == "number" then
				v.input = tonumber(v.input)
			end 


		end 
		GAMEMODE.Config[v.tablevalue] = v.input or v.default
 
	end

	net.Start("dconfig_sendSettings")
	net.WriteTable(settings)
	net.SendToServer()


end 