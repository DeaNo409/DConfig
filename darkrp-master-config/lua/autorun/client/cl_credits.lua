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
local creditsText = [[
Throughout the development of DConfig I've had the chance to receive help from many people. Here are a few that really played a significant role in the creation of this tool.
]]
function ViewCreditsToggle()

	if IsValid(CreditsPage) then
		CreditsPage:Remove()
	end

	CreditsPage = vgui.Create("DPanel", DConfigMenu)
	CreditsPage:SetPos(dconfigSideBarW, 0)
	CreditsPage:SetSize(DConfigMenu:GetWide() - dconfigSideBarW, DConfigMenu:GetTall())
	CreditsPage.Paint = function(me,w,h) end 

	local CreditsList = vgui.Create("DPanel", CreditsPage)
	CreditsList:SetPos(CreditsPage:GetWide() * .01,CreditsPage:GetTall() * .01)
	CreditsList:SetSize(CreditsPage:GetWide() * .2 - (CreditsPage:GetWide() * .01), CreditsPage:GetTall()- (CreditsPage:GetTall() * .01))
	local CreditsPanelH = CreditsList:GetTall() / 10
	CreditsList.Paint = function(me,w,h)
		surface.SetDrawColor(foreground)
		surface.DrawRect(0, CreditsPanelH,w,h - CreditsPanelH * 2)
		draw.SimpleText("Credits: ", "hub_40", 0, h * .05, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	local CreditsPanelH = CreditsList:GetTall() / 10
	local richtext = vgui.Create( "RichText", CreditsList )
	richtext:SetPos(5, CreditsPanelH)
	richtext:SetSize(CreditsList:GetWide(), CreditsList:GetTall())
	richtext:InsertColorChange(255,255,255,255)
	richtext:AppendText(creditsText)
		
	richtext.Paint = function()
		richtext.m_FontName = "hub_20"
		richtext:SetFontInternal( "hub_20" )	
		richtext:SetBGColor(Color(0,0,0,0))		
		richtext.Paint = nil
	end

	local GeneralScroll = vgui.Create("DScrollPanel", CreditsList)
	GeneralScroll:SetPos(0, CreditsList:GetTall() * .1)
	GeneralScroll:SetSize(CreditsList:GetWide(), CreditsList:GetTall() * .9)
	paintSbar(GeneralScroll)
	local CreditsPanelH = CreditsList:GetTall() / 10

	ViewCredits(CreditsPage) 

	dconfigMenu.Elements["credits"] = CreditsPage

end 


function ViewCredits(parent, settings)
	if IsValid(ViewCreditsEditor) then
		ViewCreditsEditor:Remove()
	end
	ViewCreditsEditor = vgui.Create("DPanel", parent)
	ViewCreditsEditor:SetPos(parent:GetWide() * .2 , parent:GetTall() * .01)
	ViewCreditsEditor:SetSize(parent:GetWide() - parent:GetWide() * .2, parent:GetTall())
	local tw, th = 0,0
	ViewCreditsEditor.Paint = function(me,w,h)

	end
	
	local ViewCreditsPanel = vgui.Create("DPanel", ViewCreditsEditor)
	ViewCreditsPanel:SetPos(ViewCreditsEditor:GetWide() * .02,ViewCreditsEditor:GetTall() * .1)
	ViewCreditsPanel:SetSize(ViewCreditsEditor:GetWide() , ViewCreditsEditor:GetTall() * .9)
	ViewCreditsPanel.Paint = function(me,w,h)

	end 

	local ViewCreditsScroll = vgui.Create("DScrollPanel", ViewCreditsPanel)
	ViewCreditsScroll:SetPos(0,0)
	ViewCreditsScroll:SetSize(ViewCreditsPanel:GetWide() *.99, ViewCreditsPanel:GetTall())
	paintSbar(ViewCreditsScroll)

	local ypos = 0
	local highlightColor = Color(theme.r, theme.g, theme.b, 130)
	for k,v in ipairs(configSettings["credits"]) do

		local profile = vgui.Create("DPanel", ViewCreditsScroll) 
		profile:SetPos(0,ypos) 
		profile:SetSize(ViewCreditsScroll:GetWide() * .9, ViewCreditsScroll:GetTall() * .15)
		profile.Paint = function(me,w,h)
			surface.SetDrawColor(foreground)
			surface.DrawRect(0,0,w,h)
			draw.SimpleText(v.name, "hub_22", w * .01, h * .15, theme, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end 
		local profileButton = vgui.Create("DButton", profile) 
		profileButton:SetSize(profile:GetWide() * .08, profile:GetTall() * .3)
		profileButton:SetPos(profile:GetWide() * .01, profile:GetTall() / 4 )
		profileButton:SetText("")
		profileButton.Paint = function(me,w,h)
			surface.SetDrawColor(background) 
			surface.DrawRect(0,0,w,h)
			if me:IsHovered() then 
				draw.SimpleText("Steam", "hub_22", w / 2, h / 2, theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else 
				draw.SimpleText("Steam", "hub_20", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
			end 
		end
		profileButton.DoClick = function()
			gui.OpenURL(v.link)
		end

		if v.gmodstore then 
			local gmodstoreButton = vgui.Create("DButton", profile) 
			gmodstoreButton:SetSize(profile:GetWide() * .08, profile:GetTall() * .3)
			gmodstoreButton:SetPos(profile:GetWide() * .01, profile:GetTall() / 1.6 )
			gmodstoreButton:SetText("")
			gmodstoreButton.Paint = function(me,w,h)
				surface.SetDrawColor(background) 
				surface.DrawRect(0,0,w,h)
				if me:IsHovered() then 
					draw.SimpleText("Store", "hub_22", w / 2, h / 2, theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				else 
					draw.SimpleText("Store", "hub_20", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
				end 
			end
			gmodstoreButton.DoClick = function()
				gui.OpenURL(v.gmodstore)
			end
		end 

		local richtext = vgui.Create( "RichText", profile )
		richtext:SetPos(profileButton:GetWide() + profile:GetWide() * .02, profile:GetTall() / 4 )
		richtext:SetSize(profile:GetWide() - profileButton:GetWide(), profile:GetTall() - profile:GetTall() / 4 )
		richtext:InsertColorChange(255,255,255,255)
		richtext:AppendText(v.description)
			  
		richtext.Paint = function()
			richtext.m_FontName = "hub_20"
			richtext:SetFontInternal( "hub_20" )	
			richtext:SetBGColor(Color(0,0,0,0))		
			richtext.Paint = nil
		end 
		ypos = ypos + profile:GetTall() + (ViewCreditsScroll:GetTall() * .02)
	end 

end 

