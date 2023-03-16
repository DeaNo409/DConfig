include("autorun/sh_dconfig.lua")
include("autorun/client/cl_arclibrary.lua")

local scrw = ScrW() 
local scrh = ScrH()  
local sidebar 
local background = DCONFIG.Settings.Colors["background"]
local foreground = DCONFIG.Settings.Colors["foreground"] 
local inactiveClr = DCONFIG.Settings.Colors["inactiveClr"] 
local theme = DCONFIG.Settings.Colors["theme"]
surface.CreateFont( "hub_40", { font = "prototype", extended = false, size = 40,weight = 500,antialias = true, } )
surface.CreateFont( "hub_30", { font = "prototype", extended = false, size = 30,weight = 500,antialias = true, } )
surface.CreateFont( "hub_22", { font = "prototype", extended = false, size = 22,weight = 500,antialias = true, } )
surface.CreateFont( "hub_20", { font = "prototype", extended = false, size = 20,weight = 500,antialias = true, } )
surface.CreateFont( "hub_18", { font = "prototype", extended = false, size = 18,weight = 500,antialias = true, } ) 
surface.CreateFont( "hub_16", { font = "prototype", extended = false, size = 16,weight = 500,antialias = true, } )
surface.CreateFont( "hub_14", { font = "prototype", extended = false, size = 14,weight = 500,antialias = true, } )


net.Receive("dconfig_open", function()

	ToggleDConfig()

end)

dconfigMenu = {}
dconfigMenu.Pages = {

	{icon = Material("dconfig/job.png"), callBack = function() JobEditorToggle() end},
	{icon = Material("dconfig/entity.png"), callBack = function() EntityEditorToggle() end},
	{icon = Material("dconfig/shipment.png"), callBack = function() ShipmentEditorToggle() end},
	{icon = Material("dconfig/ammo.png"), callBack = function() AmmoEditorToggle() end},
	{icon = Material("dconfig/category.png"), callBack = function() CategoryEditorToggle() end},
	--{icon = Material("dconfig/vehicle.png"), callBack = function()  end},
	{icon = Material("dconfig/settings.png"), callBack = function()GeneralSettingsEditorToggle() end},
	{icon = Material("dconfig/credits.png"), callBack = function() ViewCreditsToggle() end},
	{icon = Material("dconfig/close.png"), callBack = function() DConfigMenu:Remove() end},

}
dconfigMenu.Elements = {}
 

hook.Add("InitPostEntity", "GetJobTable", function()

	net.Start("dconfig_getData")
	net.SendToServer()

end) 

local cats = {"ammo","shipments","jobs","entities","vehicles", "weapons"} 

 
bignet.receive("sendDarkRPNewData", function(data,ply)
	local gm = (GM or GAMEMODE)
	local jobs = data.jobs
	CustomShipments = data.shipments
	gm.Config = data.config
	gm.AmmoTypes = data.ammo
	local currentCategories = DarkRP.getCategories()
	local newCategories = data.categories

	for k,v in pairs(data.entities) do
		if v.dconfig then 
			DConfigAddCustomEntity(v)
		end 
	end 
	for k, v in pairs(currentCategories) do
		if not newCategories[k] then
		    currentCategories[k] = nil
		end
	end
	for k, v in pairs(newCategories) do
		currentCategories[k] = v
	end
	for k,v in pairs(data.jobs) do
		if v.dconfig then 
			DConfigAddCustomJob(v)
		end
	end 

end)


local function highlight(me,w,h)

	if me:IsHovered() or me.id == dconfigActivePage then
		surface.SetDrawColor(theme)
	end

end


local function ClearPages()

	for k,v in pairs(dconfigMenu.Elements) do
		if IsValid(v) then v:Remove() end
	end

end 


local function PopulateSideBar(sidebar)
	dconfigActivePage = 1
	dconfigSideBarW = DConfigMenu:GetWide() * .08
	local margin = dconfigSideBarW * .265
	sidebar.dconfigbuttons = {}
	local ypos = margin
	for k,v in ipairs(dconfigMenu.Pages) do

		sidebar.dconfigbuttons[k] = vgui.Create("DButton", sidebar)
		sidebar.dconfigbuttons[k]:SetSize(margin, margin)
		sidebar.dconfigbuttons[k]:SetPos(sidebar:GetWide() * .5 - margin * .5, ypos)
		sidebar.dconfigbuttons[k].id = k
		sidebar.dconfigbuttons[k].ypos = ypos
		sidebar.dconfigbuttons[k]:SetText("")
		sidebar.dconfigbuttons[k].Paint = function(me,w,h)
			surface.SetDrawColor(100,100,100)
			surface.SetDrawColor(inactiveClr)
			surface.SetMaterial(dconfigMenu.Pages[k].icon)
			highlight(me,w,h)
			surface.DrawTexturedRect(0,0,w,h)

		end 
		sidebar.dconfigbuttons[k].DoClick = function()
			if dconfigActivePage == k then return end
			dconfigActivePage = k
			sidebar.startpos = sidebar.barpos
			sidebar.nextpos = sidebar.dconfigbuttons[k].ypos 
			if dconfigMenu.Pages[k].callBack then
				ClearPages()
				dconfigMenu.Pages[k].callBack()
			end 
		end

	ypos = ypos + margin * 2

	end

end 

local speed = 1000
local function updateBar(startPos, curPos, nextPos)
	--speed = ( nextPos / startPos ) * 1000

	if nextPos > curPos then
		curPos = curPos + speed * FrameTime()
		if curPos > nextPos then
			curPos = nextPos
		end 
	elseif curPos > nextPos then
		curPos = curPos - speed * FrameTime()
		if curPos < nextPos then
			curPos = nextPos
		end
	end 
	return curPos
end  

function ToggleDConfig()
	dconfigActivePage = 1
	DConfigMenu = vgui.Create("DFrame")
	DConfigMenu:SetSize(scrw * .8, scrh * .8)
	DConfigMenu:Center()
	DConfigMenu:MakePopup()
	DConfigMenu:SetTitle("")
	DConfigMenu:ShowCloseButton(false)
	dconfigSideBarW = DConfigMenu:GetWide() * .08
	DConfigMenu.Paint = function(me,w,h)

		surface.SetDrawColor(background)
		surface.DrawRect(0,0,w,h)
	end
	local SideBar = vgui.Create("DPanel", DConfigMenu)
	SideBar:SetPos(0,0)
	SideBar:SetSize(dconfigSideBarW, DConfigMenu:GetTall())
	local margin = SideBar:GetWide() * .265
	SideBar.barpos = margin * 2
	SideBar.nextpos = margin
	SideBar.startpos = margin * 2
	SideBar.Paint = function(me,w,h)
		me.barpos = updateBar(me.startpos, me.barpos, me.nextpos)
		surface.SetDrawColor(foreground)
		surface.DrawRect(0, 0, w, h) 
		draw.RoundedBox(5, w * .95, me.barpos - ( h * .04) + margin / 2, w * .05, h * .08, theme) 

	end
	PopulateSideBar(SideBar)
	JobEditorToggle()
end


local barClr = Color(foreground.r, foreground.g, foreground.b, 150)
function paintSbar(sbar)

local bar = sbar:GetVBar()

local buttH = 0
function bar.btnUp:Paint( w, h )
	buttH = h
end

function bar:Paint( w, h )
	draw.RoundedBox( 8, w / 2 - w / 2, buttH, w / 2, h - buttH * 2, barClr )
end

function bar.btnDown:Paint( w, h )
	
end
function bar.btnGrip:Paint( w, h )
	draw.RoundedBox( 8, w / 2 - w / 2, 0, w / 2, h , theme )
end
 
end 

local circle = Material("dconfig/circle.png")
local circle_stencil = Material("dconfig/circle.png", "alphatest")
local circle_stencil_s = Material("dconfig/circle_s.png", "alphatest")





 
  
local configSettings = DCONFIG.Settings


local textError = "" 

function DConfigConfirm(message, doclick)

	if IsValid(dconfirmFrame) then
		dconfirmFrame:Remove()
	end 

	dconfirmFrame = vgui.Create("DFrame")
	dconfirmFrame:SetSize(ScrW() * .2, ScrH() * .2)
	dconfirmFrame:Center()
	dconfirmFrame:MakePopup()
	dconfirmFrame:SetTitle("")
	dconfirmFrame:ShowCloseButton(false)
	dconfirmFrame.Paint = function(me,w,h)
		surface.SetDrawColor(foreground)
		surface.DrawRect(0,0,w,h)
		draw.SimpleText(message, "hub_20", w / 2, h / 3, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end 

	confirmButton = vgui.Create("DButton", dconfirmFrame)
	confirmButton:SetPos(dconfirmFrame:GetWide() * .20,dconfirmFrame:GetTall() * .50)
	confirmButton:SetSize(dconfirmFrame:GetWide() * .25, dconfirmFrame:GetTall() * .25)
	confirmButton:SetText("")
	confirmButton.Paint = function(me,w,h)
		surface.SetDrawColor(background)
		surface.DrawRect(0,0,w,h)
		if me:IsHovered() then 
			draw.SimpleText("Yes", "hub_22", w / 2, h / 2, theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else 
			draw.SimpleText("Yes", "hub_20", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end 
	end 
	closeButton = vgui.Create("DButton", dconfirmFrame)
	closeButton:SetPos(dconfirmFrame:GetWide() * .55,dconfirmFrame:GetTall() * .50)
	closeButton:SetSize(dconfirmFrame:GetWide() * .25, dconfirmFrame:GetTall() * .25)
	closeButton:SetText("")
	closeButton.Paint = function(me,w,h)
		surface.SetDrawColor(background)
		surface.DrawRect(0,0,w,h)
		if me:IsHovered() then 
			draw.SimpleText("No", "hub_22", w / 2, h / 2, theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else 
			draw.SimpleText("No", "hub_20", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end 
	end
	closeButton.DoClick = function()
		dconfirmFrame:Remove()
	end
	confirmButton.DoClick = function()
		if doclick != nil then
			doclick()
		end
		dconfirmFrame:Remove()
	end

	dconfigMenu.Elements["confirm"] = dconfirmFrame

end


