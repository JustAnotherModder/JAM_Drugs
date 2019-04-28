AddEventHandler('onMySQLReady', function(...) JAM_Drugs.SQLReady = true; end)

function JAM_Drugs:GetESX(obj) ESX = obj; self.ESX = obj; end
function JAM_Drugs:GetJUtils(obj) JUtils = obj; self.JUtils = obj; end

TriggerEvent('JAM_Utilities:GetSharedObject', function(...) JAM_Drugs:GetJUtils(...); end)
TriggerEvent('esx:getSharedObject', function(...) JAM_Drugs:GetESX(...); end)	

function JAM_Drugs:ServerStart()
	-- Comment this out when testing.
	while not JAM_Drugs.SQLReady do
		Citizen.Wait(0)
	end
	
	self:ResetZones()
end

function JAM_Drugs:ResetZones()
	if not self or not self.Zones then return; end
	for k,v in pairs(self.Zones) do
		TriggerEvent('JAM_Drugs:SetZonePlayers', v.ZoneTitle, 0)
		TriggerEvent('JAM_Drugs:SetZoneSafeLocked', v.ZoneTitle, 0)
	end
end

AddEventHandler('onResourceStart', function(resourceName) if resourceName == 'JAM_Drugs' then JAM_Drugs:ServerStart(); end; end)

ESX.RegisterServerCallback('JAM_Drugs:GetDrugZones', function(source, cb)
	if not JAM_Drugs or not JAM_Drugs.Zones then return; end
	cb(JAM_Drugs.Zones)
end)

ESX.RegisterServerCallback('JAM_Drugs:GetZoneData', function(source, cb, zone)
	local data = MySQL.Sync.fetchAll("SELECT * FROM jam_drugzones WHERE zone=@zone",{['@zone'] = zone})
	if data[1] and type(data[1]) == 'table' then returnData = data[1]; 
	else returnData = false; end
	cb(returnData)
end)

RegisterNetEvent('JAM_Drugs:SetZonePlayers')
AddEventHandler('JAM_Drugs:SetZonePlayers', function(zone, players)
	local data = MySQL.Sync.fetchAll("SELECT * FROM jam_drugzones WHERE zone=@zone",{['@zone'] = zone})
	if not data or not data[1] then return; end
	if players ~= 0 then playerCount = math.max(0, data[1].players + players) else playerCount = 0; end
	MySQL.Sync.execute("UPDATE jam_drugzones SET players=@playercount WHERE zone=@zone",{['@playercount'] = playerCount, ['@zone'] = zone})		
end)

RegisterNetEvent('JAM_Drugs:SetZoneSafeLocked')
AddEventHandler('JAM_Drugs:SetZoneSafeLocked', function(zone, safelock)
	local data = MySQL.Sync.fetchAll("SELECT * FROM jam_drugzones WHERE zone=@zone",{['@zone'] = zone})
	if not data or not data[1] then return; end
	if safelock ~= 0 then safeLocked = data[1].safelockout + safelock else safeLocked = 0; end
	MySQL.Sync.execute("UPDATE jam_drugzones SET safelockout=@safelocked WHERE zone=@zone",{['@safelocked'] = safeLocked, ['@zone'] = zone})		
end)

AddEventHandler('playerDropped', function(reason)
	if not ESX then return; end
	if not JUtils then return; end
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return; end
	local lastPos = xPlayer.getLastPosition()
	if not lastPos then return; end
	local posVec = vector3(lastPos.x, lastPos.y, lastPos.z)

	local nearestZone,nearestAction,nearestDist,nearestCoords = JUtils:FindNearestZone(posVec, JAM_Drugs.Zones)

	if nearestDist and nearestDist < JAM_Drugs.Config.ZoneLoadDist then
		local data = MySQL.Sync.fetchAll("SELECT * FROM jam_drugzones WHERE zone=@zone",{['@zone'] = nearestZone.ZoneTitle})
		if data[1].players <= 1 then 
			TriggerEvent('JAM_Drugs:SetZoneSafeLocked', nearestZone.ZoneTitle, 0)
		end

		TriggerEvent('JAM_Drugs:SetZonePlayers', nearestZone.ZoneTitle, -1)
	end	
end)

ESX.RegisterServerCallback('JAM_Drugs:GetHeat', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return; end

	local heat = 0
	local drugtypes = 0

	for k,v in pairs(JUtils.Weapons) do
		for k,v in pairs(v) do
			if xPlayer.getWeapon(v) then heat = heat + 20; end
		end
	end

	for k,v in pairs(JAM_Drugs.Items) do
		drugtypes = drugtypes + 1
		local drugcount = xPlayer.getInventoryItem(v.Name).count
		heat = heat + drugcount
	end

	local val = heat / drugtypes
	val = math.min(val, 100)
	cb(val)
end)

ESX.RegisterServerCallback('JAM_Drugs:GetDrugCount', function(source, cb, drug) 
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return; end

	local jamdrug = 'jam' .. drug
	local count = xPlayer.getInventoryItem(jamdrug).count
	cb(count)
end)

ESX.RegisterServerCallback('JAM_Drugs:PurchaseDrug', function(source, cb, drug, price, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return; end

	local hasEnough = false
	local msg = ''
	local finalVal

	local playerId = xPlayer.getIdentifier()	
	local cleanMoney = xPlayer.getMoney()
	local dirtyMoney = xPlayer.getAccount('black_money').money
	local drugs = 'jam' .. drug
	local drugInventory = xPlayer.getInventoryItem(drugs)
	local profitMargin = (price * JAM_Drugs.Config.SalesProfit) / 100

	if not drugInventory or (drugInventory.count + amount) <= drugInventory.limit then	
		if dirtyMoney >= (price - profitMargin) * amount then
			finalVal = (price - profitMargin) * amount		
			hasEnough = 1
			msg = ' dirty money.'	
			xPlayer.removeAccountMoney('black_money', finalVal)
			xPlayer.addInventoryItem(drugs, amount)	
		elseif cleanMoney >= (price + profitMargin) * amount then
			finalVal = (price + profitMargin) * amount		
			hasEnough = 1
			msg = ' clean money.'
			xPlayer.removeMoney(finalVal)	
			xPlayer.addInventoryItem(drugs, amount)
		end	
	else hasEnough = 2	
	end
	cb(hasEnough, msg, finalVal)
end)

ESX.RegisterServerCallback('JAM_Drugs:SellDrug', function(source, cb, drug, price, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return; end

	local hasEnough = false
	local playerId = xPlayer.getIdentifier()	
	local drugs = 'jam' .. drug
	local drugInventory = xPlayer.getInventoryItem(drugs)
	local money = xPlayer.getAccount('black_money').money
	local finalVal = math.floor(price * amount)

	if drugInventory and drugInventory.count >= amount then
		xPlayer.removeInventoryItem(drugs, amount)
		xPlayer.addAccountMoney('black_money', finalVal)
		hasEnough = true
	end
	cb(hasEnough)
end)

function JAM_Drugs.Robbed(source)
	if not JAM_Drugs or not JAM_Drugs.Items then return; end
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return; end

	local stealableItems = {}

	for k,v in pairs(JAM_Drugs.Items) do
		if xPlayer.getInventoryItem(v.Name) and xPlayer.getInventoryItem(v.Name).count > 0 then
			local itemCount = xPlayer.getInventoryItem(v.Name).count
			table.insert(stealableItems, { item = v.Name, count = itemCount })
		end
	end

	for k,v in pairs(stealableItems) do
	local stolenAmount = math.floor(v.count / JAM_Drugs.Config.RobberyAmount)
		xPlayer.removeInventoryItem(v.item, stolenAmount)
	end

	local money = xPlayer.getAccount('black_money').money
	local stolenAmount = math.floor(money / JAM_Drugs.Config.RobberyAmount)
	if money then xPlayer.removeAccountMoney('black_money', stolenAmount); end
end

RegisterNetEvent('JAM_Drugs:GetRobbed')
AddEventHandler('JAM_Drugs:GetRobbed', function() JAM_Drugs.Robbed(source); end)

ESX.RegisterServerCallback('JAM_Drugs:GetAllDrugCount', function(source, cb) 
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return; end
	local playerDrugs = {}
	local didFill = false
	for k,v in pairs(JAM_Drugs.Items) do 
		if (xPlayer.getInventoryItem(v.Name).count) > 0 then
			table.insert(playerDrugs, { name = v.Name, label = v.Label, count = xPlayer.getInventoryItem(v.Name).count, value = v.Price } ); 
			didFill = true
		end
	end
	if didFill then	cb(playerDrugs)
	else cb(false); end
end)

ESX.RegisterUsableItem('jammeth', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
 	TriggerClientEvent('JAM_Drugs:ConsumeDrugs', source, JAM_Drugs.Items.Meth)
end)

ESX.RegisterUsableItem('jamcocaine', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
 	TriggerClientEvent('JAM_Drugs:ConsumeDrugs', source, JAM_Drugs.Items.Cocaine)
end)