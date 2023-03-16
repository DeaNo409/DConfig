local loadSpeed = .45
loadedModels = {}
loadModelQueue =  {}
loadModelOrder = {} 
loadModelOrderID = {}
isModelLoading = false
function updateModelOrders()
	for k,v in pairs(loadModelOrder) do
		loadModelOrderID[v] = k 
	end

end 
function scheduleLoad(model, f) 
	if loadModelQueue[model] then
		table.insert(loadModelQueue[model], f)
	else
		table.insert(loadModelOrder, model)
		updateModelOrders()
		loadModelQueue[model] = {f}
	end 
	doLoad()
end 

function doLoad(force)

	if (force or not isModelLoading) and #loadModelOrder > 0 then
		isModelLoading = true
		timer.Create("loadtime " ..os.time() , loadSpeed, 1, function()
			local model = table.remove(loadModelOrder, 1)
			updateModelOrders()
			if loadModelQueue[model] then 
				for k,v in pairs(loadModelQueue[model]) do
					v()
				end
			end 
			loadModelQueue[model] = nil
			loadedModels[model] = true 
			doLoad(true)
		end)
	else
		isModelLoading = false
	end 
end 

local PANEL = {}

function PANEL:SetModel(model,cb)
	cb = cb or function() end
	if loadedModels[model] then
		self.BaseClass.SetModel(self, model)
		cb()
	else 
		local paint = self.Paint
		self.Paint = self.LoadingPaint
		self.DesiredModel = model 
		scheduleLoad(model, function()
			if not IsValid(self) then return end 
			self.BaseClass.SetModel(self, model)
			self.Paint = paint
			cb()
		end)
	end


end 

local theme = DCONFIG.Settings.Colors["theme"]
local background = DCONFIG.Settings.Colors["background"]  
local dot = { "  ", ".  ", ".. ", "...", "...", " ..", " ..", "  .", "  .", "   ", "   ", "   " }
local dot = { "  ", ".  ", ".. ", "...", " ..", "  ." }
local dot = { "    ", ".    ", "..   ", "...  ",  " ... ", "  ...", "   ..", "    ." }
local dot = { 
	"",
	"",
	-- "-    ",
	-- "- -  ",
	-- "- - -",
	-- "  - -",
	-- "    -",
	"|",
	"/",
	"—",
	"\\",
	"|",
	"/",
	"—",
	"\\",
	"|",
	"/",
	"—",
	"\\",
	"|",
	"/",
	"—",

	"",
	""
}

local str = "LOADING"
local strlen = #str

local amt = strlen*2-1

for i=1, amt do
	local needed = strlen - i

	if needed == 0 then
		table.insert(dot, str)
	elseif needed > 0 then
		table.insert(dot, str:sub(-i) .. (" "):rep(needed))
	else
		needed = math.abs(needed)
		table.insert(dot, (" "):rep(needed) .. str:sub(1, strlen-needed))
	end
end
local l = #dot

function PANEL:LoadingPaint(w,h)
 
	local themePulse = {}
	local abs = math.abs( math.sin( CurTime() * 1.5 ) )
	for k,v in pairs(theme) do
		themePulse[k] = v * abs
	end 
	local i = math.floor(RealTime() * 6 % l) + 1
	draw.SimpleText(dot[i], "hub_20", w / 2, h / 2, theme, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	surface.SetDrawColor(background)
	local pad = w * .03
	surface.DrawRect(pad, h * .6 + pad, w - pad * 2, h * .1 - pad * 2)

	if loadModelOrderID[self.DesiredModel] <= 10 then 
		surface.SetDrawColor(themePulse)
		surface.DrawRect(pad, h * .6 + pad, w * ( (10 + 1 - loadModelOrderID[self.DesiredModel]) / 10) - pad * 2, h * .1 - pad * 2)
	end
	

end 
derma.DefineControl( "LoadModelPanel", "Loading model panel", PANEL, "DModelPanel" )