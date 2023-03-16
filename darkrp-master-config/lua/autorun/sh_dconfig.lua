
local ply = FindMetaTable("Player")
function ply:CanDConfig()

	return self:IsSuperAdmin() --WARNING MAKE SURE TO NOT GIVE DCONFIG ACCESS THAT COULD BE HARMFUL
	--GIVING ACCESS ALLOWS THE USER TO INPUT LUA WHICH COULD BE VERY HARMFUL.

end

local function LoadDoorGroups()

	-- Example: AddDoorGroup("Cops and Mayor only", TEAM_CHIEF, TEAM_POLICE, TEAM_MAYOR)

end 



DCONFIG = {}
DCONFIG.ChatCommand = "!dconfig"

//Do not touch anything below here!
DCONFIG.Settings = {

	["jobs"] = {

	    {required = true, tablevalue = "jobvar", title = "Job Variable", dataType = "string", default = "TEAM_EXAMPLE", defaultText = "TEAM_EXAMPLE"},
	    {required = true, tablevalue = "name", title = "Job Name", dataType = "string", default = "NAME EXAMPLE", defaultText = "NAME EXAMPLE"},
	    {required = true, tablevalue = "description", title = "Description", dataType = "string", default = "Description of the job goes here.", defaultText = "Description of the job goes here."},
	    {required = true, tablevalue = "category", title = "Category", dataType = "string", default = "Citizens", defaultText = "Citizens"},
	    {required = false, tablevalue = "hp", title = "HP", dataType = "int", default = "100", defaultText = "Default: 100"},
	    {required = false, tablevalue = "armor", title = "Armor", dataType = "int", default = "0", defaultText = "Default: 0 Max: 255"},
	    {required = false, tablevalue = "walkspeed", title = "Walk Speed", dataType = "int", default = "160", defaultText = "Default: 160"},
	    {required = false, tablevalue = "runspeed", title = "Run Speed", dataType = "int", default = "240", defaultText = "Default: 240"},
	    {required = false, tablevalue = "jumppower", title = "Jump Power", dataType = "int", default = "200", defaultText = "Default: 200"},
	    {required = false, tablevalue = "nofalldamage", title = "No Fall Damage", dataType = "bool"},
	    {required = false, tablevalue = "damagescale", title = "Damage Scale", dataType = "int", default = "1", defaultText = "Default: 1"},
	    {required = false, tablevalue = "modelscale", title = "Model Scale", dataType = "int", default = "1", defaultText = "Default: 1"},
	    {required = false, tablevalue = "material", title = "Material", dataType = "string", default = "", defaultText = "Default: None"},
	    {required = false, tablevalue = "salary", title = "Salary", dataType = "int", default = "100", defaultText = "100"},
	    {required = false, tablevalue = "max", title = "Max Players", dataType = "int", default = "0", defaultText = "Unlimited: 0"},
	    {required = false, tablevalue = "maxpocket", title = "Max Pocket", dataType = "int", default = "0", defaultText = "Unlimited: 0"}, 
	    {required = false, tablevalue = "admin", title = "Admin", dataType = "int", default = "0", defaultText = "0: Everyone 1: Admin 2: Superadmin"},
	  --  {required = false, tablevalue = "NeedToChangeFrom ", title = "Changes from: ", dataType = "string", default = nil, defaultText = "Requires the user to be this job before gaining access. Example: TEAM_POLICE"},
	    {required = false, tablevalue = "vote", title = "Vote", dataType = "bool"},
	    {required = false, tablevalue = "candemote", title = "Can Demote", dataType = "bool"},
	    {required = false, tablevalue = "demotedeath", title = "Demote on Death", dataType = "bool"},
	    {required = false, tablevalue = "deathmessage", title = "Death Message", dataType = "string", default = "The mayor was killed!", defaultText = "Example: The mayor was killed! ( Only called if Demote on Death is enabled. )"},
	    {required = false, tablevalue = "defaultTeam", title = "Default Job", dataType = "bool"},
	    {required = false, tablevalue = "color", title = "Color", dataType = "color"},
	    {required = true, tablevalue = "command", title = "Command", dataType = "string", default = nil, defaultText = "Unique command to access job"},
	    {required = false, tablevalue = "customCheck", title = "Custom Check", dataType = "string", default = "return true", defaultText = "return ply:GetUserGroup() == 'vip' ply is the player accessing the job."},
	    {required = false, tablevalue = "CustomCheckFailMsg", title = "Fail Message", dataType = "string", default = "You are not able to access this job!", defaultText = "Fail message if the custom check fails."},
	    {required = false, tablevalue = "sortOrder", title = "Sort Order", dataType = "int", default = "1", defaultText = "1-100 the higher the number, lower on the list"},
	    {required = false, tablevalue = "cp", title = "Civil Protection", dataType = "bool"},  
	    {required = false, tablevalue = "hitman", title = "Hitman", dataType = "bool"},  
	    {required = false, tablevalue = "mayor", title = "Mayor", dataType = "bool"},  
	    {required = false, tablevalue = "chief", title = "Chief", dataType = "bool"},
	    {required = false, tablevalue = "medic", title = "Medic", dataType = "bool"},
	    {required = false, tablevalue = "cook", title = "Cook", dataType = "bool"},
	    {required = false, tablevalue = "weapons", title = "Weapons", dataType = "table"},
	    {required = false, tablevalue = "ammo", title = "Ammo", dataType = "string", default = "pistol,", defaultText = "Seperate each value by commas w/out space: 12 Gauge,.30 Carbine,buckshot"},
	    {required = false, tablevalue = "ammocount", title = "Ammo Count", dataType = "int", default = "0", defaultText = "Amount of ammo to give for each type: 30"},
	    {required = false, tablevalue = "hasLicense", title = "License", dataType = "bool"},
	   	{required = true, tablevalue = "model", title = "Player Models", dataType = "table"},
	   	{required = false, tablevalue = "bodygroup0", title = "Body Group 0", dataType = "int", default = nil, defaultText = "(Will apply to all PMs) Number value for body group 0."},
	   	{required = false, tablevalue = "bodygroup1", title = "Body Group 1", dataType = "int", default = nil, defaultText = "(Will apply to all PMs) Number value for body group 1."},
	   	{required = false, tablevalue = "bodygroup2", title = "Body Group 2", dataType = "int", default = nil, defaultText = "(Will apply to all PMs) Number value for body group 2."},
	   	{required = false, tablevalue = "bodygroup3", title = "Body Group 3", dataType = "int", default = nil, defaultText = "(Will apply to all PMs) Number value for body group 3."},
	   	{required = false, tablevalue = "bodygroup4", title = "Body Group 4", dataType = "int", default = nil, defaultText = "(Will apply to all PMs) Number value for body group 4."},
	    {title = "", dataType = ""},
 
		},
	["shipments"] = {

		{required = true, tablevalue = "name", title = "Shipment Name", dataType = "string", default = "NAME EXAMPLE", defaultText = "NAME EXAMPLE"},
		{required = true, tablevalue = "category", title = "Category", dataType = "string", default = "Other", defaultText = "Other"},
		{required = true, tablevalue = "entity", title = "Weapon", dataType = "table"},
		{required = true, tablevalue = "amount", title = "Shipment Amount", dataType = "int", default = "10", defaultText = "10"},
		{required = true, tablevalue = "price", title = "Shipment Price", dataType = "int", default = "500", defaultText = "500"},
		{required = false, tablevalue = "separate", title = "Separate Weapon", dataType = "bool"},
		{required = false, tablevalue = "pricesep", title = "Separate Price", dataType = "int", default = "50", defaultText = "50"},
		{required = false, tablevalue = "shipmodel", title = "Shipment Model", dataType = "string", default = "models/Items/item_item_crate.mdl", defaultText = "models/Items/item_item_crate.mdl"},
		{required = false, tablevalue = "noship", title = "No Shipment", dataType = "bool"},
		{required = false, tablevalue = "allowed", title = "Allowed", dataType = "string", default = nil, defaultText = "Seperate each value by commas w/out space: TEAM_GUN,TEAM_ADMIN,TEAM_MAYOR"},		{required = false, tablevalue = "clip1", title = "Clip1 Ammo", dataType = "int", default = nil, defaultText = "Ammo in Clip 1: default"},
		{required = false, tablevalue = "clip2", title = "Clip2 Ammo", dataType = "int", default = nil, defaultText = "Ammo in Clip 2: default"},
		{required = false, tablevalue = "spareammo", title = "Spare Ammo", dataType = "int", default = nil, defaultText = "Spare Ammo: default"},
		{required = false, tablevalue = "sortOrder", title = "Clip2 Ammo", dataType = "int", default = "1", defaultText = "1-100 the higher the number, lower on the list"},
	   	{required = false, tablevalue = "customCheck", title = "Custom Check", dataType = "string", default = "return true", defaultText = "return ply:GetUserGroup() == 'vip' ply is the player accessing the shipment."},
   		{required = false, tablevalue = "CustomCheckFailMsg", title = "Fail Message", dataType = "string", default = "You are not able to access this shipment!", defaultText = "Fail message if the custom check fails."},
		{title = "", dataType = ""},
	},
	["entities"] = {
		{required = true, tablevalue = "name", title = "Entity Name", dataType = "string", default = "NAME EXAMPLE", defaultText = "NAME EXAMPLE"},
		{required = false, tablevalue = "category", title = "Category", dataType = "string", default = "Other", defaultText = "Other"},
		{required = true, tablevalue = "ent", title = "Entity Class", dataType = "string", default = nil, defaultText = "money_printer"},
		{required = true, tablevalue = "model", title = "Entity Model", dataType = "string", default = "models/props_c17/consolebox01a.mdl", defaultText = "Entity Model: models/props_c17/consolebox01a.mdl"},
		{required = false, tablevalue = "price", title = "Price", dataType = "int", default = "100", defaultText = "100"},
		{required = false, tablevalue = "max", title = "Max Amount", dataType = "int", default = "4", defaultText = "Maxium amount a player can own."},
		{required = true, tablevalue = "cmd", title = "Command", dataType = "string", default = nil, defaultText = "Unique command to access this entity."},
		{required = false, tablevalue = "allowed", title = "Allowed", dataType = "string", default = nil, defaultText = "Seperate each value by commas w/out space: TEAM_GUN,TEAM_ADMIN,TEAM_MAYOR"},
		{title = "", dataType = ""},
	},
	["ammo"] = {
		{required = false, tablevalue = "name", title = "Ammo Name", dataType = "string", default = "NAME EXAMPLE", defaultText = "NAME EXAMPLE"},
		{required = false, tablevalue = "category", title = "Category", dataType = "string", default = "Other", defaultText = "Other"},
		{required = true, tablevalue = "ammoType", title = "Ammo Type", dataType = "table", default = nil, defaultText = "pistol"},
		{required = false, tablevalue = "model", title = "Ammo Model", dataType = "string", default = "models/Items/BoxSRounds.mdl", defaultText = "Ammo Model: models/Items/BoxSRounds.mdl"},
		{required = true, tablevalue = "price", title = "Price", dataType = "int", default = "100", defaultText = "100"},
		{required = true, tablevalue = "amountGiven", title = "Ammo Amount", dataType = "int", default = "30", defaultText = "30"},
		{required = false, tablevalue = "allowed", title = "Allowed", dataType = "string", default = nil, defaultText = "Seperate each value by commas w/out space: TEAM_GUN,TEAM_ADMIN,TEAM_MAYOR"},
		{title = "", dataType = ""},
	},
	["categories"] = {
		{required = false, tablevalue = "name", title = "Category Name", dataType = "string", default = "NAME EXAMPLE", defaultText = "NAME EXAMPLE"},
		{required = false, tablevalue = "sortOrder", title = "Sort Order", dataType = "int", default = "1", defaultText = "1-100 the higher the number, lower on the list"},
		{required = false, tablevalue = "categorises", title = "Categorises", dataType = "string", default = "jobs", defaultText = "What does it categorise: jobs, shipments, vehicles, entities, ammo, weapons"},
	    {required = false, tablevalue = "color", title = "Color", dataType = "color"},
		{required = false, tablevalue = "startExpanded", title = "Start Expanded", dataType = "bool"},
		{title = "", dataType = ""},
	},
	["credits"] ={
		{
			name = "Dan",
			description = "Developed DConfig from front to end.",
			link = "http://steamcommunity.com/profiles/76561198142166948",
			gmodstore = "https://www.gmodstore.com/users/view/76561198122449521",
		},

		{
			name = "CSi. Xavier", 
			description = "Xavier has always been such a great help. With this project specifically he helped crush numerous bugs and provided solutions to what seemed to be impossible. Not only did he provide support with coding he also acted as great motivation to pursue working on the script. He additionally created bignet.lua which is solely why the addon works so well.",
			link = "http://steamcommunity.com/profiles/76561198040907330"
		}, 
		{
			name = "Atticus",
			description = "Atticus provided the original script idea and provided input as the development of DConfig progressed.", 
			link = "http://steamcommunity.com/profiles/76561198073513480",
			gmodstore = "https://www.gmodstore.com/users/view/76561198073513480",
		}, 
		{
			name = "Ted.lua", 
			description = "Ted.lua helped with minor styling within the menu. Additionally he was also another outlet for motivation.", 
			link = "http://steamcommunity.com/profiles/76561198058539108",
			gmodstore = "https://www.gmodstore.com/users/view/76561198058539108",
		}, 
	},
}
DCONFIG.Settings.Colors ={
["background"]= Color(38, 38, 44, 255),
["foreground"]= Color(28, 28, 34, 255),
["inactiveClr"] = Color(68, 68, 68, 255),
["theme"] = Color(200,53,78),
}
local DConfigDir = "darkrpmasterconfig"
local JobsFile = DConfigDir .. "/jobs.txt"

local function ConvertToAllowedTable( str )
    local tbl = string.Explode( ',', str )
    local allowedTbl = {}
    for k,v in pairs(tbl) do
    	allowedTbl[k] = _G[v]
    end 
    return allowedTbl
end

local function categoryExists(type, name)
	local found = false
	local catType = DarkRP.getCategories()[type]
	for k,v in pairs(catType) do

		if catType[k].name == name then
			found = true 
			break 
		end 

	end 

	return found

end 

function DConfigAddCustomJob(job)
		if not RPExtraTeams[_G[job.jobvar]] then
			if job.customCheckString and SERVER then 
				job.customCheck = CompileString("local ply = select(1,...) " .. job.customCheckString, "customCheck", false)
			end 
			if not categoryExists("jobs", job.category) then
				DarkRP.createCategory({
					name = job.category,
					sortOrder = 100,
					categorises = "jobs",
					color = Color(0, 107, 0, 255),
					startExpanded = true,
					dconfig = true,
				})
			end 
			_G[job.jobvar] = DarkRP.createJob(job.name, job)
			if job.cp and not (GM or GAMEMODE).CivilProtection[_G[job.var]] then
				(GM or GAMEMODE).CivilProtection[_G[job.jobvar]] = true
			end 
			if job.hitman then
				DarkRP.addHitmanTeam(_G[job.jobvar])
			end 
			if job.defaultTeam then
				(GM or GAMEMODE).DefaultTeam = _G[job.jobvar]
			end 
		end 

end 

hook.Add("loadCustomDarkRPItems", "LoadCustomDataDconfig", function()

	if SERVER then
	 	LoadCategories()
		LoadJobs()
		LoadShipments()
		LoadEntities()
		LoadAmmo()
		LoadDarkRPSettings()
	end 

	LoadDoorGroups()

end ) 

function DConfigAddCustomAmmo(ammo)
		if not categoryExists("ammo", ammo.category) then
			DarkRP.createCategory({
				name = ammo.category,
				sortOrder = 100,
				categorises = "ammo",
				color = Color(0, 107, 0, 255),
				startExpanded = true,
				dconfig = true,
			})
		end
		local exists = false
		local ammoTypes = (GM or GAMEMODE).AmmoTypes 
		for k,v in pairs(ammoTypes) do
			if ammo.name == ammoTypes[k].name then
				exists = true
			end 
		end
		if not exists then
			if ammo.customCheck then
				ammo.customCheck = CompileString("local ply = select(1,...) " .. ammo.customCheckString, "customCheck", false)
			end 
			if ammo.allowed and ammo.allowedString then
				ammo.allowed = ConvertToAllowedTable(ammo.allowedString) or nil
			end 
			if ammo.model == "nil" then
				ammo.model = "models/Items/BoxSRounds.mdl"
			end 
			DarkRP.createAmmoType(ammo.ammoType, ammo)
		end 

end

function DConfigAddCustomShipment(shipment)
		if not categoryExists("shipments", shipment.name) then
			DarkRP.createCategory({
				name = shipment.category,
				sortOrder = 100,
				categorises = "shipments",
				color = Color(0, 107, 0, 255),
				startExpanded = true,
				dconfig = true,
			})
		end
		if not categoryExists("weapons", shipment.name) then
			DarkRP.createCategory({
				name = shipment.category,
				sortOrder = 100,
				categorises = "weapons",
				color = Color(0, 107, 0, 255),
				startExpanded = true,
				dconfig = true,
			})
		end 

		local exists = false 
		for k,v in pairs(CustomShipments) do
			if shipment.name == CustomShipments[k].name then
				exists = true
			end 
		end
		if not exists then
			if shipment.customCheck then
				shipment.customCheck = CompileString("local ply = select(1,...) " .. shipment.customCheckString, "customCheck", false)
			end 
			if shipment.allowed and shipment.allowedString then
				shipment.allowed = ConvertToAllowedTable(shipment.allowedString) or nil
			end 
			DarkRP.createShipment(shipment.name, shipment)
		end 

end 

function DConfigAddCustomEntity(entity)
		if not categoryExists("entities", entity.name) then
			DarkRP.createCategory({
				name = entity.category,
				sortOrder = 100,
				categorises = "entities",
				color = Color(0, 107, 0, 255),
				startExpanded = true,
				dconfig = true,
			})
		end
		local exists = false 
		for k,v in pairs(DarkRPEntities) do
			if entity.name == DarkRPEntities[k].name then
				exists = true
			end 
		end
		if not exists then
			if entity.customCheck then
				entity.customCheck = CompileString("local ply = select(1,...) " .. entity.customCheckString, "customCheck", false)
			end 
			if entity.allowed and entity.allowedString then
				entity.allowed = ConvertToAllowedTable(entity.allowedString) or nil
			end

			DarkRP.createEntity(entity.name, entity)
		end 

end
local cats = {"ammo","shipments","jobs","entities","vehicles"}
function DConfigAddCustomCategory(category)
	DarkRP.createCategory(category)
	if category.categorises == "shipments" or category.categorises == "weapons" then
		category.categorises = "weapons"
		DarkRP.createCategory(category)
		category.categorises = "shipments"
		DarkRP.createCategory(category)
	end 
end
