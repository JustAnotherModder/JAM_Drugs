function JAM_Drugs:GetESX(obj) self.ESX = obj; ESX = obj; end
function JAM_Drugs:GetJUtils(obj) self.JUtils = obj; JUtils = obj; end
function JAM_Drugs:GetJSC(obj) self.JSC = obj; JSC = obj; end

-------------------------------------------
--#######################################--
--##                                   ##--
--##       Client Start & Update       ##--
--##                                   ##--
--#######################################--
-------------------------------------------

function JAM_Drugs:ClientStart()
	if not self then return; end
	while not ESX or not self.ESX or not JSC or not self.JSC or not JUtils or not self.JUtils do
		TriggerEvent('esx:getSharedObject', function(...) self:GetESX(...); end)
        TriggerEvent('JAM_Utilities:GetSharedObject', function(...) self:GetJUtils(...); end)
        TriggerEvent('JAM_SafeCracker:GetSharedObject', function(...) self:GetJSC(...); end)
		Citizen.Wait(0)
	end

    self:ClientUpdate()
end

function JAM_Drugs:ClientUpdate()
	if not self then return; end
	while true do
        self.tick = (self.tick or 0) + 1

        if self.tick % 100 == 1 then self:GetNearest(); self:BlipCheck(); end        

        self:InputCheck()
        self:MarkerCheck()                   
        self:PositionCheck()
  
        if self.tick % 200 == 1 then self:EntityCheck() end 

        if self.tick % 200 == 1 then
            if not HasStreamedTextureDictLoaded ("commonmenu") then RequestStreamedTextureDict ("commonmenu", true) ; end
            if not HasStreamedTextureDictLoaded ("timerbars")  then RequestStreamedTextureDict ("timerbars", true)  ; end   
        end
		Citizen.Wait(0)
	end
end

-- AddEventHandler('onResourceStop', function(...) 
--     JAM_Drugs.DespawnPeds(...)    
-- end)

function JAM_Drugs:GetNearest()
    local localCoords = GetEntityCoords(PlayerPedId())
    self.nearest,self.nearestDist,self.nearestCoords = self:FindNearestMarker(localCoords)
end

-------------------------------------------
--#######################################--
--##                                   ##--
--##          Markers & Blips          ##--
--##                                   ##--
--#######################################--
-------------------------------------------

function JAM_Drugs:BlipCheck()
	if not self or not self.Config or not self.Config.EnableBlips or not self.nearest.ZonePos then return; end
    if self.nearestDist < self.nearest.ViewRadius and not self.nearest.blip then
		local blip = AddBlipForCoord(self.nearest.ZonePos)

		SetBlipSprite			(blip, self.nearest.BlipSprite)
		SetBlipColour			(blip, self.nearest.BlipColor)
		SetBlipDisplay			(blip, self.Config.BlipDisplay)
		SetBlipScale			(blip, self.Config.BlipScale)
		SetBlipAsShortRange		(blip, true)

		BeginTextCommandSetBlipName	("STRING")
		AddTextComponentString		(self.nearest.ZoneTitle)
		EndTextCommandSetBlipName	(blip)

		self.nearest.blip = blip

	elseif self.nearestDist > self.nearest.ViewRadius and self.nearest.blip then
		local blip = self.nearest.blip
		self.nearest.blip = nil
		RemoveBlip(blip)
	end
end

function JAM_Drugs:MarkerCheck()
    if not self or not self.Config or not self.Config.EnableMarkers then return; end
    if not self.nearestDist or not self.nearestDist < self.Config.MarkerDrawDist then return; end
    self:MarkerHandler(self.nearestCoords, self.Config.MarkerScale)
end

-------------------------------------------
--#######################################--
--##                                   ##--
--##  Check If Entities Need Spawning  ##--
--##                                   ##--
--#######################################--
-------------------------------------------

function JAM_Drugs:EntityCheck()  
    if self.nearestDist < self.Config.LoadDist then
        ESX.TriggerServerCallback('JAM_Drugs:CheckZonePlayers', function(playerCount) zonePlyCount = playerCount; end, self.nearest.ZoneTitle)

        if zonePlyCount and zonePlyCount == 0 and not self.SpawnedPeds then  
            self.SpawnedPeds = self.SpawnedPeds or {}
            TriggerServerEvent('JAM_Drugs:SetZonePlayers', self.nearest.ZoneTitle, 1)         
            self:BasicSpawn(self.nearest)
        end

        if self.nearest.WorkerEnt then workerModels = self.nearest.WorkerEnt; end
        if self.nearest.GuardEnt then guardModels = self.nearest.GuardEnt; end

    elseif self.nearestDist > (self.Config.LoadDist * 2) and self.SpawnedPeds then 
        self.DespawnPeds()         
    end
end

-------------------------------------------
--#######################################--
--##                                   ##--
--##  If Zone Unoccupied, Spawn These  ##--
--##                                   ##--
--#######################################--
-------------------------------------------

function JAM_Drugs:BasicSpawn(nearest)
    if nearest.SalesEnt then self:LoadSalesEnts(nearest); end
    if nearest.WorkerEnt then self:LoadWorkerEnts(nearest); end
    if nearest.GuardEnt then self:LoadGuardEnts(nearest); end
    if nearest.SafePos then self:LoadSafe(nearest); end
end

function JAM_Drugs:LoadSafe(nearest)
    self.SpawnedObjs = self.SpawnedeObjs or {}
    local safePos = nearest.SafePos
    local safeObj = JSC:SpawnSafeObject(JSC.SafeObjects, safePos, 0.0)
    for k,v in pairs(safeObj) do table.insert(self.SpawnedObjs, v); end
end

-------------------------------------------
--#######################################--
--##                                   ##--
--##     Load Specific Entity Funcs    ##--
--##                                   ##--
--#######################################--
-------------------------------------------

function JAM_Drugs:LoadSalesEnts(nearest)
    local sellers = nearest.SalesEnt
    local randModel = self.GetHashKey(sellers.Models[math.random(1, #sellers.Models)])
    local randPos = sellers.Positions[math.random(1, #sellers.Positions)]
      
    local weaponHash = self.GetHashKey('WEAPON_COMBATPISTOL')
    self:LoadWeapons(self.Config.Weapons.Pistol)
    self:LoadModels(sellers.Models)  

    local newPed = CreatePed(sellers.Type, randModel, randPos.xyz, randPos.w, true, false)
    SetPedRelationshipGroupHash(newPed, self.GetHashKey(nearest.EntSettings.Relationship))
    SetPedRelationshipGroupDefaultHash(newPed, self.GetHashKey(nearest.EntSettings.Relationship))

    GiveWeaponToPed(newPed, weaponHash, 1000, false, false)
    if sellers.FreezeEnt then
        FreezeEntityPosition(newPed, true)
    end

    self:UnloadModels(sellers.Models)
    self:UnloadWeapons(self.Config.Weapons.Pistol)

    table.insert(self.SpawnedPeds, newPed)
end

function JAM_Drugs:LoadWorkerEnts(nearest)
    local workers = nearest.WorkerEnt

    self:LoadModels(workers.Models)  
    self:LoadAnim(workers.AnimDict)

    local weaponHash = self.GetHashKey('WEAPON_KNIFE')
    self:LoadWeapons(self.Config.Weapons.Melee)

    for k,v in pairs(workers.Positions) do
        local randModel = self.GetHashKey(workers.Models[math.random(1, #workers.Models)])             
        local newPed = CreatePed(workers.Type, randModel, v.xyz, v.w, true, false)

        if type(k) == 'string' then
            TaskPlayAnim(newPed, workers.AnimDict, k, 8.0, 1.0, -1, 1, 1.0, 0, 0, 0)
        else
            TaskPlayAnim(newPed, workers.AnimDict, workers.AnimName, 8.0, 1.0, -1, 1, 1.0, 0, 0, 0)
        end

        SetPedRelationshipGroupHash(newPed, self.GetHashKey(nearest.EntSettings.Relationship))
        SetPedRelationshipGroupDefaultHash(newPed, self.GetHashKey(nearest.EntSettings.Relationship))
        GiveWeaponToPed(newPed, weaponHash, 1, false, false)

        table.insert(self.SpawnedPeds, newPed)
    end

    self:UnloadModels(workers.Models)
    self:UnloadAnim(workers.AnimDict)
    self:UnloadWeapons(self.Config.Weapons.Melee)
end

function JAM_Drugs:LoadGuardEnts(nearest)
    ESX.TriggerServerCallback('JAM_Drugs:GetHeat', function(heat)
        local guards = nearest.GuardEnt
        local weapons = self:GetEntWeaponTier(heat)

        for key,val in pairs(weapons) do
            for k,v in pairs(self.Config.Weapons) do
                if val == k then self:LoadWeapons(v) end
            end
        end

        self:LoadModels(guards.Models)
        local count = 0
        if heat > 75 then count = -10; end
        local attempt = 0
        local takenpos = {}
        while count == 0 or count < heat / 20 do
            local randomPos = guards.Positions[math.random(1, #guards.Positions)] 
            local posTaken = false
            for k,v in pairs(takenpos) do 
                attempt = attempt + 1
                if v.x == randomPos.x and v.y == randomPos.y and v.z == randomPos.z then 
                    posTaken = true 
                end
            end

            if attempt > count + 1000 then
                return
            end

            if not posTaken then
                count = count + 1

                local randModel = self.GetHashKey(guards.Models[math.random(1, #guards.Models)])
                local newPed = CreatePed(guards.Type, randModel, randomPos.xyz, randomPos.w, true, false)             

                local weaponCategory = math.random(1, #weapons)
                local randomWeapon
                for k,v in pairs(self.Config.Weapons) do
                    if k == weapons[weaponCategory] then 
                        randomWeapon = v[math.random(1, #v)]
                    end 
                end       

                SetPedRelationshipGroupHash(newPed, self.GetHashKey(nearest.EntSettings.Relationship))
                SetPedRelationshipGroupDefaultHash(newPed, self.GetHashKey(nearest.EntSettings.Relationship))

                GiveWeaponToPed(newPed, randomWeapon, 1000, true, true)

                table.insert(takenpos, randomPos)
                table.insert(self.SpawnedPeds, newPed)  
            end

            Citizen.Wait(0)
        end

        for key,val in pairs(weapons) do
            for k,v in pairs(self.Config.Weapons) do
                if val == k then
                    self:UnloadWeapons(v)
                end
            end
        end

        self:UnloadModels(guards.Models)
    end) 
end

-------------------------------------------
--#######################################--
--##                                   ##--
--##  If Away From Zone, Despawn Peds  ##--
--##                                   ##--
--#######################################--
-------------------------------------------

function JAM_Drugs.DespawnPeds() 
    if not self then self = JAM_Drugs; end

    local playerPos = GetEntityCoords(GetPlayerPed())

    if self.nearest then
        TriggerServerEvent('JAM_Drugs:SetZonePlayers', self.nearest.ZoneTitle, -1)   
        TriggerServerEvent('JAM_Drugs:SetSafeLocked', self.nearest.ZoneTitle, 0)   
    end

    if self.SpawnedPeds then
        for k,v in pairs(self.SpawnedPeds) do
            SetEntityCoords(v, playerPos.x, playerPos.y, playerPos.z + 50, false, false, false, false)
            DeletePed(v)
        end   
        self.SpawnedPeds = false
    end

    if self.SpawnedObjs then
        for k,v in pairs(self.SpawnedObjs) do
            DeleteObject(v)
        end
        self.SafeActive = false
        self.SpawnedeObjs = false
    end

    if self.RobberPeds then
        for k,v in pairs(self.RobberPeds) do
            DeletePed(v)
        end
        self.RobberPeds = false
    end
end

function JAM_Drugs.DespawnRobbers()
    if JAM_Drugs.RobberPeds then
        for k,v in pairs(JAM_Drugs.RobberPeds) do
            DeleteEntity(v)
        end
        JAM_Drugs.RobberPeds = false
    end
end

-------------------------------------------
--#######################################--
--##                                   ##--
--##       Check If Near Markers       ##--
--##                                   ##--
--#######################################--
-------------------------------------------

function JAM_Drugs:PositionCheck()
    if not self or not self.Config then return; end
    self.StandingInMarker = self.StandingInMarker or false
    local inMarker = false  

    local localCoords = GetEntityCoords(PlayerPedId())
    local nearest, nearestDist, nearestCoords = self:FindNearestMarker(localCoords)

    if nearestDist < self.Config.MarkerScale.x then inMarker = true; end
    if inMarker and not self.StandingInMarker then
    	self.StandingInMarker = true
    	self.ActionData = ActionData or {}
        for k,v in pairs(nearest) do
        	if (type(v) == 'vector4' or type(v) == 'vector3') and (v.x == nearestCoords.x) and (v.y == nearestCoords.y) and ( v.z == nearestCoords.z) then
        		if k == 'ZonePos' then
		            action,sales,safe,msg = nearest,false,false,"enter the ~y~" .. nearest.ZoneTitle .. "."  
        		elseif k == 'ExitPos' then
                    action,sales,safe,msg = nearest,false,false,"leave the ~y~" .. nearest.ZoneTitle .. "."
        		elseif k == 'ActionPos' then
                    action,sales,safe,msg = false,nearest,false,(nearest.ActionType:sub(1,1):lower()..nearest.ActionType:sub(2)) .. " ~y~" .. nearest.DrugTitle
                elseif k == 'SafeActionPos' then 
                    action,sales,safe,msg = false,false,nearest,"~y~attempt ~r~to ~y~crack ~r~ the ~y~safe."
        		end

                self.ActionData.Action = action                
                self.ActionData.SalesZone = sales 
                self.ActionData.SafeZone = safe
                self.ActionData.Message = "~y~Press ~INPUT_PICKUP~ ~r~to " .. msg
        	end
        end
    end

    if not inMarker and self.StandingInMarker then
        self.StandingInMarker = false
        self.ActionData.Action = false
        self.ActionData.SalesZone = false
        self.ActionData.SafeZone = false
        TriggerEvent('JAM_SafeCracker:EndMinigame', false, false)
        self.ESX.UI.Menu.CloseAll()
    end
end

-- -----------------------------------------
-- #######################################--
-- ##                                   ##--
-- ##   If Inside Marker, Check Input   ##--
-- ##                                   ##--
-- #######################################--
-- -----------------------------------------

function JAM_Drugs:InputCheck()
    if not self or not self.ActionData then return; end
    if not self.ActionData.Action and not self.ActionData.SalesZone and not self.ActionData.SafeZone then return; end
    self.Timer = self.Timer or 0

    SetTextComponentFormat('STRING') 
    AddTextComponentString(self.ActionData.Message)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)

    if IsControlPressed(0, self.Config.Keys['E']) and (GetGameTimer() - self.Timer) > 150 then
        if self.ActionData.Action then
            self:MarkerTeleport(self.ActionData.Action)
        elseif self.ActionData.SalesZone and self.SpawnedPeds and not self.BeingRobbed then
            self:SalesMenu(self.ActionData.SalesZone)
        elseif self.ActionData.SafeZone and self.SpawnedPeds and not self.SafeActive then
            --self.SafeActive = true
            ESX.TriggerServerCallback('JAM_Drugs:CheckSafeLocked', function(locked) 
                if locked == 1 then
                    TriggerEvent('esx:showNotification', "~r~Somebody is already attempting to crack this safe.")
                    return
                end

                if locked == 2 then 
                    TriggerEvent('esx:showNotification', "~r~The failsafe for this vault has already been triggered.")
                    return
                end

                if locked == 3 then
                    TriggerEvent('esx:showNotification', "~r~Somebody has already cracked this safe.")
                    return
                end

                TriggerServerEvent('JAM_Drugs:SetSafeLocked', self.ActionData.SafeZone.ZoneTitle, 1)

                TriggerEvent('JAM_SafeCracker:StartMinigame', self.ActionData.SafeZone.SafeRewards)
                local playerPed = PlayerPedId()
                if self.SpawnedPeds and #self.SpawnedPeds > 0 then
                    for k,v in pairs(self.SpawnedPeds) do
                        if not IsPedInCombat(v, playerPed) then
                            TaskCombatPed(v, playerPed, 0, 16)
                        end
                    end
                end 

            end, self.ActionData.SafeZone.ZoneTitle)

        end

        self.StandingInMarker = false
        self.Timer = GetGameTimer()            
    end
end

-------------------------------------------
--#######################################--
--##                                   ##--
--##    If Inside TPMarker, Teleport   ##--
--##                                   ##--
--#######################################--
-------------------------------------------

function JAM_Drugs:MarkerTeleport(zone)
    local ped = PlayerPedId()
    for k,v in pairs(self.Config.Zones) do
        if v.ZonePos then
            if (v.ZonePos.x == self.nearestCoords.x) and (v.ZonePos.y == self.nearestCoords.y) and (v.ZonePos.z == self.nearestCoords.z) then
                SetEntityCoords(ped, v.ExitPos, v.ExitHeading, false, false, false)
            elseif(v.ExitPos.x == self.nearestCoords.x) and (v.ExitPos.y == self.nearestCoords.y) and (v.ExitPos.z == self.nearestCoords.z) then
                SetEntityCoords(ped, v.ZonePos, v.ZoneHeading, false, false, false)    
            end
        end
    end
end

--------------------------------------------
--########################################--
--##                                    ##--
--##  Inside Action Marker Trade Menu   ##--
--##                                    ##--
--########################################--
--------------------------------------------

function JAM_Drugs:SalesMenu(zone)
    if not self or not zone or not self.ESX then return; end
    local drugTitle = (zone.DrugTitle:sub(1,1):lower()..zone.DrugTitle:sub(2))
    local actionType = zone.ActionType:sub(1,1):lower()..zone.ActionType:sub(2)

    self.ESX.UI.Menu.CloseAll()
    ESX.TriggerServerCallback('JAM_Drugs:GetDrugCount', function(userDrugAmount)
        local maxAmount 
        local salesData
        local profitMargin

        if zone.ZoneLimit then 
            maxAmount = zone.ZoneLimit 
            profitMargin = zone.ZonePrice / self.Config.SalesProfit
            if userDrugAmount and userDrugAmount > 0 then 
                maxAmount = maxAmount - userDrugAmount
            end
        end

        if maxAmount and maxAmount > 0 then salesData = "Clean: ~y~$" .. (zone.ZonePrice + profitMargin) .. "~r~ / Dirty: ~y~$" .. (zone.ZonePrice - profitMargin)
        else salesData = "Dirty: ~y~$" .. zone.ZonePrice; end

        local c = self.drawTextTemplate()
        c.font = 4
        c.x = 0.5
        c.y = 0.36
        c.text = "~r~How much ~y~" .. drugTitle .. " ~r~do you want to ~y~" .. actionType .. "~r~? ( " .. salesData .."~r~ )"

        self.keyboardActive = true

        DisplayOnscreenKeyboard( 0, "","", (maxAmount or userDrugAmount), "", "", "", 30 )
   
        while self.keyboardActive do    
            self.drawText(c)
            DrawSprite("commonmenu", "gradient_nav", 0.5, 0.375, 0.32, 0.047, 0.0, 0, 0, 0, 210)

            if self.keyboardActive and UpdateOnscreenKeyboard() == 1 then
                self.keyboardActive = false
                self.keyboardResult = GetOnscreenKeyboardResult()
                local num = tonumber(self.keyboardResult)
                if num ~= nil and num > 0 then
                    if maxAmount then self:PurchaseDrugs(zone, num)
                    else self:SellDrugs(zone, num)
                    end
                else 
                    TriggerEvent('esx:showNotification', "~r~Enter a number next time.")
                end
            elseif self.keyboardActive and UpdateOnscreenKeyboard() ~= 0 then
                self.keyboardActive = false
            end            
            Citizen.Wait(0)
        end
    end, drugTitle) 
end

-------------------------------------------
--#######################################--
--##                                   ##--
--##    Purchase & Sell Drugs Menus    ##--
--##                                   ##--
--#######################################--
-------------------------------------------

function JAM_Drugs:PurchaseDrugs(zone, amount)
    local str = (zone.DrugTitle:sub(1,1):lower()..zone.DrugTitle:sub(2))

    ESX.TriggerServerCallback('JAM_Drugs:PurchaseDrug', function(valid, msg, finalprice)           
        if valid == 1 then    
            TriggerEvent('esx:showNotification', "~r~You purchased~y~ " .. amount .. " " .. str .. "~r~ for ~y~$" .. math.floor(finalprice) .. "~r~" ..msg)
            --self:HandleSnitching(zone, amount)      
        elseif valid == 2 then
            TriggerEvent('esx:showNotification', "~r~You can only carry ~y~" .. zone.ZoneLimit .. " " .. str .. "~r~ at a time.")
        elseif valid == false then
            TriggerEvent('esx:showNotification', "~r~You can't afford that much ~y" .. str .. ".")
        end
    end, str, zone.ZonePrice, amount)  
end

function JAM_Drugs:SellDrugs(zone, amount)  
    local str = (zone.DrugTitle:sub(1,1):lower()..zone.DrugTitle:sub(2))

    ESX.TriggerServerCallback('JAM_Drugs:SellDrug', function (valid)
        if not valid then
            TriggerEvent('esx:showNotification', "~r~You don't have enough ~y~" .. str .. " ~r~to sell.")
        else
            TriggerEvent('esx:showNotification', "~r~You sold ~y~" .. amount .. " " .. str .. " ~r~for ~y~$" .. math.floor(zone.ZonePrice * amount) .. " ~r~dirty money.")
            self:HandleRobbing(zone, amount)
        end
    end, str, zone.ZonePrice, amount)  
end

--function JAM_Drugs:SellToPed(amount)


-------------------------------------------
--#######################################--
--##                                   ##--
--##       Snitching & Robberies       ##--
--##                                   ##--
--#######################################--
-------------------------------------------

function JAM_Drugs:HandleSnitching(zone)
end

function JAM_Drugs:HandleRobbing(zone, amount)
    if not zone or not ESX then return; end
    self.BeingRobbed = self.BeingRobbed or false
    if not self.BeingRobbed then
        local r = math.random(0, 100)
        if r <= self.Config.RobberyChance then         
            if not zone.RobberEnt then return; end
            self.BeingRobbed = true


            self:LoadModels(zone.RobberEnt.Models)

            self.RobberPeds = self.RobberPeds or {}

            local drugTitle = (zone.DrugTitle:sub(1,1):lower()..zone.DrugTitle:sub(2))
            local playerPed = PlayerPedId()

            ESX.TriggerServerCallback('JAM_Drugs:GetHeat', function(heat)
                local robbers = zone.RobberEnt
                local weapons = self:GetEntWeaponTier(heat)

                for key,val in pairs(weapons) do
                    for k,v in pairs(self.Config.Weapons) do
                        if val == k then self:LoadWeapons(v) end
                    end
                end

                self:LoadModels(robbers.Models)

                local count = 0
                local attempt = 0
                if heat > 75 then count = -10; end

                local takenpos = {}

                while count == 0 or count < heat / 20 do
                    local randomPos = robbers.Positions[math.random(1, #robbers.Positions)] 
                    local posTaken = false
                    for k,v in pairs(takenpos) do 
                        attempt = attempt + 1
                        if self:GetVecDist(randomPos.xyz, zone.ActionPos) < 50 then
                            if v.x == randomPos.x and v.y == randomPos.y and v.z == randomPos.z then 
                                posTaken = true 
                            end
                        end
                    end

                    if attempt > count + 1000 then
                        return
                    end

                    if not posTaken then
                        count = count + 1

                        local randModel = self.GetHashKey(robbers.Models[math.random(1, #robbers.Models)])
                        local newPed = CreatePed(robbers.Type, randModel, randomPos.xyz, randomPos.w, true, false)             

                        local weaponCategory = math.random(1, #weapons)
                        local randomWeapon
                        for k,v in pairs(self.Config.Weapons) do
                            if k == weapons[weaponCategory] then 
                                randomWeapon = v[math.random(1, #v)]
                            end 
                        end       

                        SetPedRelationshipGroupHash(newPed, self.GetHashKey(zone.EntSettings.Relationship))
                        SetPedRelationshipGroupDefaultHash(newPed, self.GetHashKey(zone.EntSettings.Relationship))

                        GiveWeaponToPed(newPed, randomWeapon, 1000, true, true)

                        local playerPed = PlayerPedId()
                        if not IsPedInCombat(newPed, playerPed) then
                            TaskCombatPed(newPed, playerPed, 0, 16)
                        end

                        table.insert(takenpos, randomPos)
                        table.insert(self.RobberPeds, newPed )  
                    end

                    Citizen.Wait(100)
                end

                for key,val in pairs(weapons) do
                    for k,v in pairs(self.Config.Weapons) do
                        if val == k then
                            self:UnloadWeapons(v)
                        end
                    end
                end

                self:UnloadModels(robbers.Models)

                Citizen.Wait(60000)
                self.BeingRobbed = false 
                self:DespawnRobbers()
            end, drugTitle)
        end
    end
end

-------------------------------------------
--#######################################--
--##                                   ##--
--##            Death Checks           ##--
--##                                   ##--
--#######################################--
-------------------------------------------

AddEventHandler('esx:onPlayerDeath', function(data)
	if not JAM_Drugs then return; end
	if JAM_Drugs.BeingRobbed then 
		JAM_Drugs.BeingRobbed = false; 
		TriggerServerEvent('JAM_Drugs:GetRobbed')
        Citizen.Wait(0)
        JAM_Drugs.DespawnRobbers()
	end
end)

-------------------------------------------
--#######################################--
--##                                   ##--
--##           Start 'Er Up            ##--
--##                                   ##--
--#######################################--
-------------------------------------------

Citizen.CreateThread(function(...) JAM_Drugs:ClientStart(...); end)