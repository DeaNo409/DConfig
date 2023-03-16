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
local pmodels = pmodels or player_manager.AllValidModels()

function JobEditorToggle()	
	if IsValid(JobEditor) then
		JobEditor:Remove()
	end 
 
	JobEditor = vgui.Create("DPanel", DConfigMenu)
	JobEditor:SetPos(dconfigSideBarW, 0)
	JobEditor:SetSize(DConfigMenu:GetWide() - dconfigSideBarW, DConfigMenu:GetTall())
	JobEditor.Paint = function(me,w,h) end 

	local JobList = vgui.Create("DPanel", JobEditor)
	JobList:SetPos(JobEditor:GetWide() * .01,JobEditor:GetTall() * .01)
	JobList:SetSize(JobEditor:GetWide() / 4 - (JobEditor:GetWide() * .01), JobEditor:GetTall()- (JobEditor:GetTall() * .01))
	JobList.Paint = function(me,w,h)
		draw.SimpleText("Jobs: ", "hub_40", 0, h * .05, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end 

	local JobScroll = vgui.Create("DScrollPanel", JobList)
	JobScroll:SetPos(0, JobList:GetTall() * .1)
	JobScroll:SetSize(JobList:GetWide(), JobList:GetTall() * .9)
	paintSbar(JobScroll)
	local ypos = 0
	local JobPanelH = JobList:GetTall() / 10
	local offSet = 5
	local JobPanel = vgui.Create("DPanel", JobScroll)
	JobPanel:SetPos(0, ypos)
	JobPanel:SetSize(JobList:GetWide(), JobPanelH)
	JobPanel.Paint = function(me,w,h)
		draw.RoundedBox( 8, 0, 0, w - w * .05, h, foreground )
		surface.SetDrawColor(background)
		surface.SetMaterial(circle)
		surface.DrawTexturedRect(w * .03 ,h / 2 - h / 2.6, h / 1.3,h / 1.3)
		draw.SimpleText("New Job", "hub_20", w * .05 + h / 1.2, h * .2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	end
	JobPanelNew = vgui.Create("DButton", JobPanel)
	JobPanelNew:SetPos(JobList:GetWide() * .03, JobPanelH / 2 - JobPanelH / 2.6)
	JobPanelNew:SetSize(JobPanelH / 1.3 ,JobPanelH / 1.3)
	JobPanelNew:SetText("")
	JobPanelNew.Paint = function(me,w,h)
		if me:IsHovered() then
			draw.SimpleText("+", "hub_40", w / 2, h / 2, theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else 
			draw.SimpleText("+", "hub_30", w / 2, h / 2, theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end 
	end

	JobPanelNew.DoClick = function()
		JobSettings(JobEditor)
	end 

	ypos = ypos + JobPanelH + (JobList:GetTall() * .01)
	for k,v in pairs(RPExtraTeams) do

		if RPExtraTeams[k].dconfig then 
			local JobPanel = vgui.Create("DPanel", JobScroll)
			JobPanel:SetPos(0, ypos)
			JobPanel:SetSize(JobList:GetWide(), JobPanelH)
			JobPanel.Paint = function(me,w,h)
				draw.RoundedBox( 8, 0, 0, w - w * .05, h, foreground )
				surface.SetDrawColor(background)
				surface.SetMaterial(circle)
				draw.SimpleText(v.name, "hub_20", w * .05 + h / 1.2, h * .2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			
			end

			local JobEditButton = vgui.Create("DButton", JobPanel)  
			JobEditButton:SetPos(JobPanel:GetWide() * .05 + JobPanelH / 1.2, JobPanelH * .6)  
			JobEditButton:SetSize(JobPanel:GetWide() * .15, JobPanelH * .2)
			JobEditButton:SetText("")
			JobEditButton.Paint = function(me,w,h)
				if me:IsHovered() then 
					draw.SimpleText("Edit", "hub_18", 0, h / 2, theme, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				else 
					draw.SimpleText("Edit", "hub_16", 0, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end 
			end 


			JobEditButton.DoClick = function()
				JobSettings(JobEditor, RPExtraTeams[k])
			end 

			local JobDeleteButton = vgui.Create("DButton", JobPanel)
			JobDeleteButton:SetPos(JobPanel:GetWide() * .2 + JobPanelH / 1.2, JobPanelH * .6)  
			JobDeleteButton:SetSize(JobPanel:GetWide() * .18, JobPanelH * .2)
			JobDeleteButton:SetText("")
			JobDeleteButton.Paint = function(me,w,h)
				if me:IsHovered() then 
					draw.SimpleText("Delete", "hub_18", 0, h / 2, theme, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				else 
					draw.SimpleText("Delete", "hub_16", 0, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end 
			end

			JobDeleteButton.DoClick = function()

				DConfigConfirm("Do you want to delete ".. v.name .. "?", function()
					net.Start("dconfig_deleteJob")
					net.WriteInt(k, 8)
					net.SendToServer()
					DarkRP.removeJob(k)
					JobEditorToggle()
				end )
	
			end 


			local JobModel = vgui.Create("DModelPanel", JobPanel)
			if type(v.model) == "string" then 
				JobModel:SetModel(v.model)
			else
				JobModel:SetModel(v.model[1])
			end


			JobModel.LayoutEntity = function() end

			JobModel:SetAnimated(false)
			JobModel:SetPos(JobPanel:GetWide() * .03, JobPanel:GetTall() / 2 - (JobPanel:GetTall() / 2.6))
			JobModel:SetSize(JobPanel:GetTall() / 1.3, JobPanel:GetTall() / 1.3)
			JobModel:SetCamPos(Vector( 50, -4, 65))

			local bone = JobModel.Entity:LookupBone("ValveBiped.Bip01_Head1")
			if bone then
				local pos, ang = JobModel.Entity:GetBonePosition(bone)
				JobModel:SetLookAt(pos)
			else
				JobModel:SetLookAt( Vector( 0, 0, 66.5 ) )
			end

			JobModel:SetFOV(20)

	 
	 		local oldPaint = JobModel.Paint

			function JobModel:Paint(w, h)

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
		ypos = ypos + JobPanelH + (JobList:GetTall() * .01)
		end 
			 
 
	end

	dconfigMenu.Elements["jobeditor"] = JobEditor
	JobSettings(JobEditor)
end

local configSettings = DCONFIG.Settings

function JobSettings(parent, job)


	if IsValid(JobSettingsEditor) then
		JobSettingsEditor:Remove()
	end
	textError = ""
	job = job or {}
	local weaponOptions = {}
	JobSettingsEditor = vgui.Create("DPanel", parent)
	JobSettingsEditor:SetPos(parent:GetWide() * .25 , parent:GetTall() * .01)
	JobSettingsEditor:SetSize(parent:GetWide() - parent:GetWide() * .25, parent:GetTall())
	local tw, th = 0,0
	JobSettingsEditor.Paint = function(me,w,h)
		surface.SetFont("hub_40")
		if not job["name"] then
			draw.SimpleText("Settings: New Job", "hub_40", 0, h * .05, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			tw,th = surface.GetTextSize("Settings: New Job")
		else
			draw.SimpleText("Settings: " .. job["name"], "hub_40", 0, h * .05, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			tw,th = surface.GetTextSize("Settings: " .. job["name"])
		end
		if string.len(textError) > 0 then 
			draw.SimpleText("*ERROR: " .. textError .. "*", "hub_22",  tw * 1.10, h * .05, theme, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end 
	end
	
	local JobSettingsPanel = vgui.Create("DPanel", JobSettingsEditor)
	JobSettingsPanel:SetPos(JobSettingsEditor:GetWide() * .02,JobSettingsEditor:GetTall() * .1)
	JobSettingsPanel:SetSize(JobSettingsEditor:GetWide() , JobSettingsEditor:GetTall() * .9)
	JobSettingsPanel.Paint = function(me,w,h)

	end 

	local JobSettingsSave = vgui.Create("DButton", JobSettingsEditor)
	JobSettingsSave:SetPos(JobSettingsEditor:GetWide() * 0.8, JobSettingsEditor:GetTall() * .025)
	JobSettingsSave:SetSize(JobSettingsEditor:GetWide() * 0.1, JobSettingsEditor:GetTall() * .05)
	JobSettingsSave:SetText("")
	JobSettingsSave.Paint = function(me,w,h)

		surface.SetDrawColor(foreground)
		surface.DrawRect(0,0,w,h)
		if me:IsHovered() then 
			draw.SimpleText("Save Job", "hub_22", w / 2, h / 2, theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText("Save Job", "hub_20", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

	end 

	JobSettingsSave.DoClick = function()
		SendJobData(job)
	end 

	local JobSettingsScroll = vgui.Create("DScrollPanel", JobSettingsPanel)
	JobSettingsScroll:SetPos(0,0)
	JobSettingsScroll:SetSize(JobSettingsPanel:GetWide() *.99, JobSettingsPanel:GetTall())
	paintSbar(JobSettingsScroll)
	local ypos = 0
	local highlightColor = Color(theme.r, theme.g, theme.b, 130)
	for k,v in ipairs(configSettings["jobs"]) do
		if v.default then
		v.input = v.default
		end  

		local configOption = vgui.Create("DPanel", JobSettingsScroll)
		configOption:SetPos(0, ypos)
		configOption:SetSize(JobSettingsScroll:GetWide() * .9, JobSettingsScroll:GetTall() * .05)
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
			local jobValue = job[v.tablevalue]
			if jobValue and v.tablevalue != "ammo" and v.tablevalue != "customCheck" then
				configOptionInput:SetText(job[v.tablevalue])
				v.input = job[v.tablevalue]
			elseif jobValue and v.tablevalue == "ammo" then
				local ammo = ""

				for x, o in pairs(jobValue) do
					if string.len(x) > 0 then 
						ammo = ammo .. x  ..","
					end 
				end 
				configOptionInput:SetText(ammo)
				v.input = job[v.tablevalue]

			elseif v.tablevalue == "customCheck" and job["customCheckString"] and string.len(job["customCheckString"]) > 0 then
				configOptionInput:SetText(job["customCheckString"])
				v.input = job["customCheckString"]
				print("CUSTOM CHECK EXISTS: " .. v.input)
			elseif v.tablevalue == "jobvar" and job["jobvar"] then
				configOptionInput:SetText(job["jovar"])
				v.input = job["jobvar"]	
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

			if job[v.tablevalue] then
				configOptionInput:SetChecked(job[v.tablevalue])
				v.input = job[v.tablevalue]
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
			for k,v in pairs(DarkRP.getCategories()["jobs"]) do
				local category = DarkRP.getCategories()["jobs"][k]
				configOptionInput:AddChoice(category.name)
			end
			if job[v.tablevalue] then
				configOptionInput:SetValue(job[v.tablevalue])
				configOptionInput:SetTextColor(color_white)
				v.input = job[v.tablevalue]
			end
			function configOptionInput:OnSelect(index, value, data)

				configOptionInput:SetTextColor(color_white)
				v.input = value

			end 

		elseif v.dataType == "color" then

			local configOptionInput = vgui.Create("DColorMixer", configOption)
			configOptionInput:SetPos(configOption:GetWide() * .15, 0)
			configOption:SetSize(configOption:GetWide(), JobSettingsScroll:GetTall() * .2)
			configOptionInput:SetSize(configOption:GetWide() * .85, configOption:GetTall())
			configOptionInput:SetAlphaBar(false)
			configOptionInput:SetWangs(true)
			configOptionInput:SetPalette(false)
			configOptionInput:SetColor(theme)
			v.input = theme 
			function configOptionInput:ValueChanged(value)
				v.input = value 
			end

			if job[v.tablevalue] then
				configOptionInput:SetColor(job[v.tablevalue])
				v.input = job[v.tablevalue]
			end

		elseif v.dataType == "table" and v.title == "Weapons" then
			local selectedWeps = {}
			if job.weapons and type(job.weapons) == "string" then
				table.insert(selectedWeps, job.weapons[1])
			elseif job.weapons then
				for x, o in pairs(job.weapons) do
					table.insert(selectedWeps, o)
				end 
			end 
			for key, weapon in pairs(weapons.GetList()) do
				if not weapon.WorldModel or string.len(weapon.WorldModel) == 0 then 
				weaponOptions[key] = {class = weapon.ClassName}
				else 
				weaponOptions[key] = {class = weapon.ClassName, model = weapon.WorldModel}
			    end
			end
			configOption:SetSize(configOption:GetWide(), JobSettingsScroll:GetTall() * .5)

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
				function WeaponPanel:Paint(w,h)
					surface.SetDrawColor(foreground)
					surface.DrawRect(0,0,w,h)
				end 
				local WeaponModel = vgui.Create("LoadModelPanel", WeaponPanel)
				WeaponModel:SetSize(WeaponPanel:GetWide() , WeaponPanel:GetTall())
				WeaponModel:SetModel(wep.model or "models/weapons/w_crowbar.mdl", function()
					WeaponModel.Entity:SetPos(WeaponModel.Entity:GetPos() - Vector(0,0,4))
					function WeaponModel:LayoutEntity( Entity ) return end 
					local CamPos = Vector( 15, -6, 60 )
					local LookAt = Vector( 0, 0, 60 )
					
					WeaponModel:SetCamPos( CamPos )
					WeaponModel:SetLookAt( LookAt )
					WeaponModel:SetFOV(50)
					local num = .7
					
					local min, max = WeaponModel.Entity:GetRenderBounds()
					WeaponModel:SetCamPos(min:Distance(max) * Vector(num, num, num))
					WeaponModel:SetLookAt((max + min) / 2)
				end )
				WeaponModel.DoClick = function()
					if !table.HasValue(selectedWeps, wep.class) then 
						table.insert(selectedWeps, wep.class)
					else
						table.RemoveByValue(selectedWeps, wep.class)
					end 
						v.input = selectedWeps
				end
				function WeaponModel:PaintOver(w,h)
					draw.SimpleText(wep.class, "hub_14", w / 2, 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					if ammo != "none" and ammo != nil then 
						draw.SimpleText(ammo, "hub_14", w / 2, h - 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					end
					if table.HasValue(selectedWeps, wep.class) then
						surface.SetDrawColor(theme)
						surface.DrawOutlinedRect(0,0,w,h)
					end 
				end 
			end 
				v.input = selectedWeps
		elseif v.title == "Player Models" and v.dataType == "table" then 
			configOption:SetSize(configOption:GetWide(), JobSettingsScroll:GetTall() * .5)
			local configOptionScroll = vgui.Create("DScrollPanel", configOption) 
			configOptionScroll:SetPos(configOption:GetWide() * .15,0)
			configOptionScroll:SetSize(configOption:GetWide() * .85, configOption:GetTall())
			paintSbar(configOptionScroll)

			local configOptionList = vgui.Create("DIconLayout", configOptionScroll)
			configOptionList:SetPos(0,0)
			configOptionList:SetSize(configOptionScroll:GetWide() , configOptionScroll:GetTall())
			configOptionList:SetSpaceY(5)
			configOptionList:SetSpaceX(5)
				local selectedModels = {}
				if job.model and type(job.model) == "string" then
					table.insert(selectedModels, string.lower(job.model[1]))
				elseif job.model then
					for x, o in pairs(job.model) do
						table.insert(selectedModels, string.lower(job.model[x]))
					end 
				end
			for name, model in pairs(pmodels) do

				model = string.lower(model)
				local PMPanel = configOptionList:Add("DPanel")
				PMPanel:SetSize(configOption:GetTall() * .27, configOption:GetTall() * .27)
				PMPanel.Paint = function(me,w,h)
					surface.SetDrawColor(foreground)
					surface.DrawRect(0,0,w,h)
					if table.HasValue(selectedModels, model) then
						surface.SetDrawColor(theme)
						surface.DrawOutlinedRect(0,0,w,h)
					end 
				end
			
				local PM = vgui.Create("LoadModelPanel", PMPanel)
					PM.LayoutEntity = function() end
					PM:SetAnimated(false)
					PM:SetPos(0,0)
					PM:SetSize(PMPanel:GetWide(), PMPanel:GetTall())
					PM:SetCamPos(Vector( 50, -4, 65))
					PM:SetModel(model, function() 
						local bone = PM.Entity:LookupBone("ValveBiped.Bip01_Head1")
						if bone then
							local pos, ang = PM.Entity:GetBonePosition(bone)
							PM:SetLookAt(pos)
						else
							PM:SetLookAt( Vector( 0, 0, 66.5 ) )
						end
					end)
					PM:SetFOV(20)

					PM.DoClick = function()

						if !table.HasValue(selectedModels, model) then 
							table.insert(selectedModels, model)
						else
							table.RemoveByValue(selectedModels, model)
						end 
						v.input = selectedModels
					end 
			end
				
				v.input = selectedModels 
		end 

			ypos = ypos + configOption:GetTall() + (JobSettingsScroll:GetTall() * .02)

	end 
	

end


local function ConvertToAmmoTable( str, amount )
    local tbl = string.Explode( ',', str )

    local ammoTbl = {}
    for k,v in pairs(tbl) do
    	if string.len(tbl[k]) > 0 then 
    		ammoTbl[v] = amount
    	end
    end 
   	return ammoTbl
end

function SendJobData(tbl)
	
	local JobData = {}
	local ammo 
	local ammocount
	for k,v in pairs(configSettings["jobs"]) do

		if v.tablevalue and string.len(v.tablevalue) > 0 then
			local key = v.tablevalue

 
			if v.required and v.input == nil then

				textError = v.title .. " is not complete!"
				print("ERROR " .. v.title .. " IS A NIL VALUE")
				return
			end 

			if key == "model" and #v.input <= 0 then
				textError = "Player model is not complete!"
				return 
			end 
			if v.dataType == "int" then
				v.input = tonumber(v.input)
			end 

			JobData[key] = v.input

			if key == "ammo" then
				ammo = v.input
			elseif key == "ammocount" then 
				ammocount = v.input
			end 

			if key == "customCheck" then
				if string.len(v.input) <= 0 or v.input == v.default then
					JobData[key] = nil
					JobData["customCheckString"] = nil
				elseif string.len(v.input) > 0 and v.input != v.default then
					JobData["customCheckString"] = v.input
				end 
				
			end

		end 
 
	end
	
	-- if true then return end 
	if type(ammo) == "string" and ammocount then 
		JobData["ammo"] = ConvertToAmmoTable( ammo, ammocount )
	end 
	JobData.dconfig = true
	net.Start("dconfig_sendJob")    
	net.WriteTable(JobData)
	net.SendToServer()

	if RPExtraTeams[_G[JobData.jobvar]] then
		DarkRP.removeJob(_G[JobData.jobvar])
	end 
	if JobData.customCheck and JobData.customCheckString then 
		JobData.customCheck = CompileString("local ply = select(1,...) " .. JobData.customCheckString, "customCheck")
	else
		JobData.customCheck = nil
	end 
	_G[JobData.jobvar] = DarkRP.createJob(JobData.name, JobData)
	JobEditorToggle()
	print(LocalPlayer():GetName() .. " created job: " .. JobData.name)
	LocalPlayer():ChatPrint("ANY JOB CHANGES REQUIRE A RESTART: F4 MAY NOT FUNCTION AS USUAL UNTIL RESTART.")



end 