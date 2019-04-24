TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)	

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

AddEventHandler('playerDropped', function(reason)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return; end
	local lastPos = xPlayer.getLastPosition()
	local nearest,nearestDist,nearestCoords = JAM_Drugs:FindNearestMarker(lastPos)
	if not nearest or not JAM_Drugs or not JAM_Drugs.Config then return; end
	if nearestDist < JAM_Drugs.Config.LoadDist then 
		TriggerEvent('JAM_Drugs:SetZonePlayers', nearest.ZoneTitle, -1)
		TriggerEvent('JAM_Drugs:SetSafeLocked', nearest.ZoneTitle, false)
	end	
end)

AddEventHandler('onMySQLReady', function(...)
	for k,v in pairs(JAM_Drugs.Config.Zones) do
		TriggerEvent('JAM_Drugs:SetZonePlayers', v.ZoneTitle, 0)
		TriggerEvent('JAM_Drugs:SetSafeLocked', v.ZoneTitle, false)
	end
end)

ESX.RegisterServerCallback('JAM_Drugs:GetConfig', function(source, cb)
	if not JAM_Drugs then return; end
	cb(JAM_Drugs.Config)
end)

ESX.RegisterServerCallback('JAM_Drugs:GetDrugCount', function(source, cb, drug) 
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return; end

	local jamdrug = 'jam' .. drug
	local count = xPlayer.getInventoryItem(jamdrug).count
	cb(count)
end)

ESX.RegisterServerCallback('JAM_Drugs:GetAllDrugCount', function(source, cb) 
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return; end
	local playerDrugs = {}
	local didFill = false
	for k,v in pairs(JAM_Drugs.Config.Items) do 
		if (xPlayer.getInventoryItem(v.Name).count) > 0 then
			table.insert(playerDrugs, { name = v.Name, label = v.Label, count = xPlayer.getInventoryItem(v.Name).count, value = v.Value } ); 
			didFill = true
		end
	end

	if didFill then	cb(playerDrugs)
	else cb(false); end
end)

ESX.RegisterServerCallback('JAM_Drugs:CheckZonePlayers', function(source, cb, zone) 
	local returnData = false
	local data = MySQL.Sync.fetchAll("SELECT * FROM jam_drugzones WHERE zone=@zone",{['@zone'] = zone})	
	if data[1] and data[1].players ~= nil then returnData = data[1].players; end
	cb(returnData)
end)

RegisterNetEvent('JAM_Drugs:SetZonePlayers')
AddEventHandler('JAM_Drugs:SetZonePlayers', function(zone, val)
	local data = MySQL.Sync.fetchAll("SELECT * FROM jam_drugzones WHERE zone=@zone",{['@zone'] = zone})	
	if val ~= 0 then playerCount = data[1].players + val
	else playerCount = val; end
	if playerCount < 0 then playerCount = 0; end
	MySQL.Sync.execute("UPDATE jam_drugzones SET players=@playercount WHERE zone=@zone",{['@playercount'] = playerCount, ['@zone'] = zone})	
end)

ESX.RegisterServerCallback('JAM_Drugs:CheckSafeLocked', function(source, cb, zone) 
	local returnData = false
	local data = MySQL.Sync.fetchAll("SELECT * FROM jam_drugzones WHERE zone=@zone",{['@zone'] = zone})		
	if data[1] and data[1].safelockout ~= nil then returnData = data[1].safelockout; end
	cb(returnData)
end)

RegisterNetEvent('JAM_Drugs:SetSafeLocked')
AddEventHandler('JAM_Drugs:SetSafeLocked', function(zone, locked) 
	local data = MySQL.Sync.fetchAll("SELECT * FROM jam_drugzones WHERE zone=@zone",{['@zone'] = zone})		
	if zone ~= nil and locked ~= nil and data[1] then
		MySQL.Sync.execute("UPDATE jam_drugzones SET safelockout=@safelockout WHERE zone=@zone",{['@safelockout'] = locked, ['@zone'] = zone})	
	end
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

ESX.RegisterServerCallback('JAM_Drugs:GetHeat', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return; end

	local heat = 0
	local drugtypes = 0

	for k,v in pairs(JAM_Drugs.Config.Weapons) do
		for k,v in pairs(v) do
			if xPlayer.getWeapon(v) then heat = heat + 50; end
		end
	end

	for k,v in pairs(JAM_Drugs.Config.Items) do
		drugtypes = drugtypes + 1
		local drugcount = xPlayer.getInventoryItem(v.Name).count
		heat = heat + drugcount
	end

	local val = heat / drugtypes
	val = math.min(val, 100)
	cb(val)
end)

function JAM_Drugs.Robbed(source)
	if not JAM_Drugs or not JAM_Drugs.Config or not JAM_Drugs.Config.Items then return; end
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return; end

	local stealableItems = {}

	for k,v in pairs(JAM_Drugs.Config.Items) do
		if xPlayer.getInventoryItem(v.Name) and xPlayer.getInventoryItem(v.Name).count > 0 then
			local itemCount = xPlayer.getInventoryItem(v.Name).count
			table.insert(stealableItems, { item = v.Name, count = itemCount })
		end
	end

	for k,v in pairs(stealableItems) do
	local stolenAmount = math.floor(v.count / JAM_Drugs.Config.RobberAmount)
		xPlayer.removeInventoryItem(v.item, stolenAmount)
	end

	local money = xPlayer.getAccount('black_money').money
	local stolenAmount = math.floor(money / JAM_Drugs.Config.RobberAmount)
	if money then xPlayer.removeAccountMoney('black_money', stolenAmount); end
end

RegisterNetEvent('JAM_Drugs:GetRobbed')
AddEventHandler('JAM_Drugs:GetRobbed', function() JAM_Drugs.Robbed(source); end)