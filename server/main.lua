TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)	

ESX.RegisterServerCallback('JAM_Drugs:PurchaseDrug', function(source, cb, drug, price, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return; end

	local hasEnough = false
	local msg = ''
	local finalVal = math.floor(price * amount)

	local playerId = xPlayer.getIdentifier()	
	local cleanMoney = xPlayer.getMoney()
	local dirtyMoney = xPlayer.getAccount('black_money').money
	local drugs = 'jam' .. drug
	local drugInventory = xPlayer.getInventoryItem(drugs)

	if not drugInventory or (drugInventory.count + amount) <= drugInventory.limit then	
		if dirtyMoney >= (finalVal * 0.8) then
			finalVal = finalVal * 0.8			
			hasEnough = true
			msg = ' dirty money.'	
			xPlayer.removeAccountMoney('black_money', finalVal)
			xPlayer.addInventoryItem(drugs, amount)	
		elseif cleanMoney >= (finalVal * 1.2) then
			finalVal = finalVal * 1.2			
			hasEnough = true
			msg = ' clean money.'
			xPlayer.removeMoney(finalVal)	
			xPlayer.addInventoryItem(drugs, amount)
		end		
	end
	cb(hasEnough, msg, finalVal)
end)

ESX.RegisterServerCallback('JAM_Drugs:GetDrugCount', function(source, cb, drug) 
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return; end

	local jamdrug = 'jam' .. drug
	local count = xPlayer.getInventoryItem(jamdrug).count
	cb(count)
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
AddEventHandler('JAM_Drugs:GetRobbed', JAM_Drugs.Robbed)