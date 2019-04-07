TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)	

ESX.RegisterServerCallback('JAM_Drugs:PurchaseDrug', function(source, cb, drug, price, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return; end

	local hasEnough = false
	local msg = ''
	local finalVal = price * amount

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

ESX.RegisterServerCallback('JAM_Drugs:SellDrug', function(source, cb, drug, price, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return; end

	local hasEnough = false
	local playerId = xPlayer.getIdentifier()	
	local drugs = 'jam' .. drug
	local drugInventory = xPlayer.getInventoryItem(drugs)
	local money = xPlayer.getAccount('black_money').money

	if drugInventory and drugInventory.count >= amount then
		xPlayer.removeInventoryItem(drugs, amount)
		xPlayer.addAccountMoney('black_money', (amount * price))
		hasEnough = true
	end
	cb(hasEnough)
end)

function JAM_Drugs.Robbed()	
	local xPlayer
	while not xPlayer do xPlayer = ESX.GetPlayerFromId(source); end
	local meth = xPlayer.getInventoryItem('jammeth')
	local coke = xPlayer.getInventoryItem('jamcocaine')
	local money = xPlayer.getAccount('black_money').money

	if meth and meth.count > 0 then xPlayer.removeInventoryItem('jammeth', math.floor(meth.count / 10)); end
	if coke and coke.count > 0 then xPlayer.removeInventoryItem('jamcocaine', math.floor(coke.count / 10)); end
	if money then xPlayer.removeAccountMoney('black_money', math.floor(money / 10)); end
end

RegisterNetEvent('JAM_Drugs:GotRobbed')
AddEventHandler('JAM_Drugs:GotRobbed', JAM_Drugs.Robbed)

function JAM_Drugs.Startup()
	local data = MySQL.Sync.fetchAll("SELECT * FROM items")	
	for k,v in pairs(JAM_Drugs.Config.Items) do	
		local intable = false
		for key,val in pairs(data) do
			if v.Name == val.name then
				intable = true
				if not v.Limit == val.limit then
					MySQL.Sync.execute("UPDATE items SET limit=@limit",{['@limit'] = v.Limit})
				end
			end
		end

		if not intable then
			MySQL.Async.execute('INSERT INTO `items` (`name`, `label`, `limit`, `rare`, `can_remove`) VALUES (@name, @label, @limit, @rare, @can_remove)',
			{
				['@name']   = v.Name,
				['@label']   = v.Label,
				['@limit'] = v.Limit,
				['@rare']	 = v.Rare,
				['@can_remove']	 = v.CanRemove,
			})
		end
	end
end

RegisterNetEvent('JAM_Drugs:Startup')
AddEventHandler('JAM_Drugs:Startup', JAM_Drugs.Startup)