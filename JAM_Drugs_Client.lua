local JDGS = JAM.Drugs
local JSC = JAM.SafeCracker

function JDGS:ClientStart()
    if not self then return; end
    if not ESX then
        while not ESX do Citizen.Wait(100); end
        self.ESX = ESX
    end
    
    while not ESX.IsPlayerLoaded() do Citizen.Wait(0); end
    while not JSC or type(JSC) ~= "table" do Citizen.Wait(0); end

    print("JAM_Drugs:Start() - Successful")
    self:ClientUpdate()
end

function JDGS:ClientUpdate()
    while true do
        self.tick = (self.tick or 0) + 1

        if (self.tick % 100 == 0) then
            self:PositionCheck()
            self:GetClosestNPC()
            self:VehicleCheck()
            self:EntityCheck()
        end
        self:InputCheck()

        Citizen.Wait(0)
    end
end

function JDGS:VehicleCheck()
    if not self or not self.SpawnedVehicles or not self.SpawnedPeds then return; end

    local playerPed = GetPlayerPed(PlayerId())
    local lastVeh = GetLastDrivenVehicle(playerPed)

    if lastVeh then
        local inVeh = false
        for k,v in pairs(self.SpawnedVehicles) do
            if lastVeh == v then inVeh = true; end
        end
        if inVeh then 
            self.CanDoAction = false
            for k,v in pairs(self.SpawnedPeds) do
                if not IsPedInCombat(v, playerPed) then
                    self:RequestNetworkControl(v, true)
                    TaskCombatPed(v, playerPed, 0, 16)
                end
            end
        end
    end
end

function JDGS:EntityCheck()
    if self.SpawnedPeds and #self.SpawnedPeds > 0 then
        for k,v in pairs(self.SpawnedPeds) do
            if DoesEntityExist(v) and IsEntityDead(v) then self.CanDoAction = false; end
        end
    end
end



RegisterNetEvent('JDGS:ConsumeDrugs')
AddEventHandler('JDGS:ConsumeDrugs', function(drug)
    if JDGS.UnderTheInfluence then return; end

    local Timer = GetGameTimer()    
    local plyPed = GetPlayerPed(PlayerId())
    local maxHp = GetEntityMaxHealth(plyPed)
    local tick = 0.0

    JDGS.UnderTheInfluence = true

    ShakeGameplayCam('DRUNK_SHAKE', 0.0)  
    SetTimecycleModifierStrength(0)
    SetPedMotionBlur(playerPed, true)

    if drug.Label == "Meth" then  
        SetTimecycleModifier("BeastIntro02")

        while GetGameTimer() - Timer < JDGS.Config.DrugEffectTimer do
            SetTimecycleModifierStrength(tick)
            SetGameplayCamShakeAmplitude(tick)
            tick = tick + 0.001
            tick = math.min(1.0, tick)

            SetPedMoveRateOverride(GetPlayerPed(PlayerId()), math.min(1.4, 1.0 + tick))
            Citizen.Wait(0)
        end
    end

    if drug.Label == "Cocaine" then
        SetTimecycleModifier("drunk")

        SetEntityMaxHealth(plyPed, maxHp * 2)
        SetEntityHealth(plyPed, maxHp * 2)

        while GetGameTimer() - Timer < JDGS.Config.DrugEffectTimer do
            SetTimecycleModifierStrength(tick)
            SetGameplayCamShakeAmplitude(tick)
            tick = tick + 0.001
            tick = math.min(1.0, tick)

            SetPedMoveRateOverride(GetPlayerPed(PlayerId()), math.min(1.2, 1.0 + tick))
            Citizen.Wait(0)
        end
    end

    if drug.Label == "Weed" then     
        SetTimecycleModifier("BikerFilter")

        while GetGameTimer() - Timer < JDGS.Config.DrugEffectTimer do
            SetTimecycleModifierStrength(tick)
            SetGameplayCamShakeAmplitude(tick)
            tick = tick + 0.001
            tick = math.min(1.0, tick)

            SetPedMoveRateOverride(GetPlayerPed(PlayerId()), 0.8)
            Citizen.Wait(0)
        end
    end

    SetEntityMaxHealth(plyPed, maxHp)
    if GetEntityHealth(plyPed) > maxHp then SetEntityHealth(plyPed, maxHp); end


    while tick > 0.0 do
        tick = tick - 0.001   
        SetTimecycleModifierStrength(tick)
        SetGameplayCamShakeAmplitude(tick)
        SetPedMoveRateOverride(playerPed, math.max(1.0, 1.0 + tick))
        Citizen.Wait(0)
    end
    
    SetPlayerMeleeWeaponDamageModifier(plyPed, 1.0)
    ClearTimecycleModifier()
    SetPedMotionBlur(playerPed, false)
    JDGS.UnderTheInfluence = false
end)

RegisterNetEvent('JDGS:MethFX')
AddEventHandler('JDGS:MethFX', function() Citizen.CreateThread(function() JDGS:MethEffect(); end); end)

function JDGS:MethEffect()
    if self.OnMeth then return; end

    self.OnMeth = true

    TriggerEvent('esx:showNotification', "~r~ITS PARTY TIME!")     

    local playerPed = PlayerPedId()

    RequestAnimSet("move_m@hurry_butch@a") 
    while not HasAnimSetLoaded("move_m@hurry_butch@a") do
      Citizen.Wait(0)
    end    

    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING_POT", 0, 1)
    Citizen.Wait(5000)
    ClearPedTasksImmediately(playerPed)

    ShakeGameplayCam('DRUNK_SHAKE', 1.0)  
    SetTimecycleModifier("michealspliff","v_sweat","DRUG_gas_huffin","Drug_deadman","Drug_deadman_blend")
    SetPedMotionBlur(playerPed, true)

    SetRunSprintMultiplierForPlayer(GetPlayerPed(PlayerId()), 1.49)

    local tick = 0
    while tick < self.Config.DrugEffectTimer do
        tick = tick + 1
        SetPedMoveRateOverride(GetPlayerPed(PlayerId()), 3.5)
        Citizen.Wait(0)
    end

    SetPedMoveRateOverride(playerPed, 1.0)
    SetRunSprintMultiplierForPlayer(playerPed, 1.0)

    ShakeGameplayCam('DRUNK_SHAKE', 0.0)  
    ClearTimecycleModifier()
    SetPedMotionBlur(playerPed, false)

    self.OnMeth = false
end


function JDGS:RequestNetworkControl(entity,waitForControl)

    if    not entity  or  not DoesEntityExist(entity)  then  return false,0  ; end
    local   netID = NetworkGetNetworkIdFromEntity(entity)%0x100000000
    if    not netID  or  netID < 1  then  return false,0  end
    if    not NetworkDoesEntityExistWithNetworkId(netID)  then return false,0 ; end
    NetworkRequestControlOfNetworkId(netID)
    local tick = 0
    if    waitForControl
    then  
        while not NetworkHasControlOfNetworkId(netID)  and  tick < 300
        do
            Citizen.Wait(0)

            tick = tick + 1
            NetworkRequestControlOfNetworkId(netID)
            if    ( NetworkHasControlOfNetworkId(netID) == false )
            and   ( tick < 300 )
            then  Citizen.Wait(50)
            end
        end
    end
    return NetworkHasControlOfNetworkId(netID),netID
end

function JDGS:InputCheck()
    if not self.ActionData then return; end
    self.Timer = self.Timer or 0
    if nearestDist < self.Config.ActionDist then 
        if self.ActionData.Message then
            SetTextComponentFormat('STRING') 
            AddTextComponentString(self.ActionData.Message)
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)
        end

        if IsControlPressed(0, JUtils.Keys['E']) and (GetGameTimer() - self.Timer) > 1000 then
            self.Timer = GetGameTimer()
            if nearestAction == "ActionPos" then self:OpenSalesMenu(nearestZone)
            elseif nearestAction == "EntryPos" then self:MarkerTeleport(nearestZone, false)
            elseif nearestAction == "ExitPos" then self:MarkerTeleport(nearestZone, true)
            elseif nearestAction == "SafeActionPos" then self:HandleSafeMinigame(nearestZone)
            end
        end
    elseif self.ClosestPed and IsControlPressed(0, JUtils.Keys['E']) and (GetGameTimer() - self.Timer) > 1000 then      
        self.Timer = GetGameTimer()
        self:SellDrugsToPed(self.ClosestPed)
    end 
end

function JDGS:SellDrugsToPed(buyerPed)
    if not self or not self.Config or not ESX or not self.ESX then return; end
    self.PedsThatPurchased = self.PedsThatPurchased or {}
    for k,v in pairs(self.PedsThatPurchased) do
        if buyerPed == v then return; end
    end

    if self.SpawnedPeds then
        for k,v in pairs(self.SpawnedPeds) do
            if buyerPed == v then return; end
        end
    end

    for k,v in pairs(ESX.Game.GetPlayers()) do
        if GetPlayerPed(v) == buyerPed then return; end
    end

    table.insert(self.PedsThatPurchased, buyerPed)

    if IsEntityDead(buyerPed) then return; end

    if math.random(1, 100) > self.Config.NPCSalesChance then 
        if math.random(1, 100) < self.Config.SnitchingChance then
            self:HandleSnitching(GetEntityCoords(PlayerPedId()))
        elseif math.random(1,100) < self.Config.NPCAgroChance then
            local playerPed = PlayerPedId()
            if not IsPedInCombat(v, playerPed) then
                TaskCombatPed(v, playerPed, 0, 16)
            end
        end
        return 
    end

    local playerDrugs = {}

    self.ESX.UI.Menu.CloseAll()
    ESX.TriggerServerCallback('JDGS:GetAllDrugCount', function(userDrugInventory)
        local randomDrug
        if userDrugInventory then
            randomDrug = math.random(1, #userDrugInventory)
        else return; end

        local maxAmount = math.random(1,self.Config.NPCSalesMax)
        local salesData
        local drugLabel = (userDrugInventory[randomDrug].label:sub(1,1):lower()..userDrugInventory[randomDrug].label:sub(2))
        local drugValue = userDrugInventory[randomDrug].value
        local drugAmount = userDrugInventory[randomDrug].count
        local profitMargin = (drugValue * self.Config.NPCSalesProfit) / 100

        local plyPed = GetPlayerPed(PlayerId())
        TaskTurnPedToFaceEntity(buyerPed, plyPed, 100)
    end)
end

function JDGS:HandleSafeMinigame(zone)
    ESX.TriggerServerCallback('JDGS:GetZoneData', function(zoneData) 
        if zoneData.safelockout == 1 then TriggerEvent('esx:showNotification', "~r~Somebody is already attempting to crack this safe."); return; end
        if zoneData.safelockout == 2 then TriggerEvent('esx:showNotification', "~r~The failsafe for this vault has already been triggered."); return; end
        if zoneData.safelockout >= 3 then TriggerEvent('esx:showNotification', "~r~Somebody has already cracked this safe."); return; end
        TriggerServerEvent('JDGS:SetZoneSafeLocked', zone.ZoneTitle, 1)
        self.CanDoAction = false
        self.SafeActive = true

        TriggerEvent('JSC:StartMinigame', zone.SafeRewards)

        local playerPed = GetPlayerPed(PlayerId())

        for k,v in pairs(self.SpawnedPeds) do 
            if not IsPedInCombat(v, playerPed) then
                TaskCombatPed(v, playerPed, 0, 16)
            end 
        end
    end, zone.ZoneTitle)
end

function JDGS:PositionCheck()
    local playerPos = GetEntityCoords(PlayerPedId())
    nearestZone,nearestAction,nearestDist,nearestPos = JUtils:FindNearestZone(playerPos, self.Zones)
    if not nearestDist then return; end

    if nearestDist < self.Config.ZoneLoadDist * (math.random(50, 150) / 100) and not self.ZoneLoaded then
        self.ZoneLoaded = nearestZone
        Citizen.CreateThread(function() self:HandleZoneSpawn(nearestZone); end)
    elseif nearestDist > self.Config.ZoneLoadDist * (math.random(250, 350) / 100) and self.ZoneLoaded then
        Citizen.CreateThread(function() self:HandleZoneDespawn(self.ZoneLoaded); end)
    end 

    self.ActionData = self.ActionData or {}

    if nearestDist < self.Config.ActionDist then
        self.ActionData.Action = nearestAction
        self.ActionData.Zone = nearestZone

        local str = "~r~Press ~INPUT_PICKUP~ to "
        if nearestAction == "ActionPos" and self.CanDoAction then self.ActionData.Message = str .. (nearestZone.ActionType:sub(1,1):lower() .. nearestZone.ActionType:sub(2)) .. " ~y~" .. nearestZone.DrugTitle .. "~r~."
        elseif nearestAction == "EntryPos" then self.ActionData.Message = str .. "enter the ~y~" .. nearestZone.ZoneTitle .. "~r~."
        elseif nearestAction == "ExitPos" then self.ActionData.Message = str .. "exit the ~y~" .. nearestZone.ZoneTitle .. "~r~."
        elseif nearestAction == "SafeActionPos" and not self.SafeActive then self.ActionData.Message = str .. "attempt to ~y~crack ~r~the ~y~safe."
        end
    else
        self.ActionData.Action = false
        self.ActionData.Zone = false
        self.ActionData.Message = false
        if self.SafeActive then TriggerEvent('JSC:EndGame'); end
    end

    if self.Config.EnableBlips and nearestDist < nearestZone.ViewRadius and not self.ActiveBlip then
        if nearestZone.Positions.EntryPos then blip = AddBlipForCoord(nearestZone.Positions.EntryPos)
        else blip = AddBlipForCoord(nearestZone.Positions.ActionPos); end

        SetBlipSprite           (blip, nearestZone.BlipSprite)
        SetBlipColour           (blip, nearestZone.BlipColor)
        SetBlipDisplay          (blip, nearestZone.BlipDisplay)
        SetBlipScale            (blip, nearestZone.BlipScale)
        SetBlipAsShortRange     (blip, true)

        BeginTextCommandSetBlipName ("STRING")
        AddTextComponentString      (nearestZone.ZoneTitle)
        EndTextCommandSetBlipName   (blip)

        self.ActiveBlip = blip

    elseif self.Config.EnableBlips and nearestDist > nearestZone.ViewRadius and self.ActiveBlip then
        local blip = self.ActiveBlip
        self.ActiveBlip = nil
        RemoveBlip(blip)
    end     
end

function JDGS:OpenSalesMenu(zone)
    local drugTitle = (zone.DrugTitle:sub(1,1):lower()..zone.DrugTitle:sub(2))
    local actionType = zone.ActionType:sub(1,1):lower()..zone.ActionType:sub(2)

    self.ESX.UI.Menu.CloseAll()
    ESX.TriggerServerCallback('JDGS:GetDrugCount', function(userDrugAmount)
        local maxAmount 
        local salesData
        local profitMargin

        if zone.DrugLimit then 
            maxAmount = zone.DrugLimit 
            profitMargin = zone.DrugPrice / self.Config.SalesProfit
            if userDrugAmount and userDrugAmount > 0 then 
                maxAmount = maxAmount - userDrugAmount
            end
        end

        if maxAmount and maxAmount > 0 then salesData = "Clean: ~y~$" .. (zone.DrugPrice + profitMargin) .. "~r~ / Dirty: ~y~$" .. (zone.DrugPrice - profitMargin)
        else salesData = "Dirty: ~y~$" .. zone.DrugPrice; end

        local c = JUtils.DrawTextTemplate()
        c.font = 4
        c.x = 0.5
        c.y = 0.36
        c.text = "~r~How much ~y~" .. drugTitle .. " ~r~do you want to ~y~" .. actionType .. "~r~? ( " .. salesData .."~r~ )"

        self.keyboardActive = true

        DisplayOnscreenKeyboard( 0, "","", (maxAmount or userDrugAmount), "", "", "", 30 )
   
        while self.keyboardActive do    
            JUtils:DrawText(c)
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

function JDGS:PurchaseDrugs(zone, amount)
    local str = (zone.DrugTitle:sub(1,1):lower()..zone.DrugTitle:sub(2))

    ESX.TriggerServerCallback('JDGS:PurchaseDrug', function(valid, msg, finalprice)           
        if valid == 1 then    
            TriggerEvent('esx:showNotification', "~r~You purchased~y~ " .. amount .. " " .. str .. "~r~ for ~y~$" .. math.floor(finalprice) .. "~r~" ..msg)
            if math.random(1, 100) < self.Config.SnitchingChance then self:HandleSnitching(zone.ZonePos); end 
        elseif valid == 2 then
            TriggerEvent('esx:showNotification', "~r~You can only carry ~y~" .. zone.DrugLimit .. " " .. str .. "~r~ at a time.")
        elseif valid == false then
            TriggerEvent('esx:showNotification', "~r~You can't afford that much ~y" .. str .. ".")
        end
    end, str, zone.DrugPrice, amount)  
end

function JDGS:SellDrugs(zone, amount)  
    local str = (zone.DrugTitle:sub(1,1):lower()..zone.DrugTitle:sub(2))

    ESX.TriggerServerCallback('JDGS:SellDrug', function (valid)
        if not valid then
            TriggerEvent('esx:showNotification', "~r~You don't have enough ~y~" .. str .. " ~r~to sell.")
        else
            TriggerEvent('esx:showNotification', "~r~You sold ~y~" .. amount .. " " .. str .. " ~r~for ~y~$" .. math.floor(zone.DrugPrice * amount) .. " ~r~dirty money.")
            Citizen.CreateThread(function() self:HandleRobbing(zone, amount); end)
        end
    end, str, zone.DrugPrice, amount)  
end

function JDGS:HandleSnitching(alertPosition)
    local plyPed = PlayerPedId()
    local plyPos = GetEntityCoords(plyPed)
    local alertMsg = 'Someone has snitched on a drug deal.'
    if self.ZoneLoaded and self.ZoneLoaded.Positions.EntryPos then
        plyPos = self.ZoneLoaded.Positions.EntryPos
    end

    TriggerServerEvent('esx_addons_gcphone:startCall', 'police', alertMsg, plyPos)
end

function JDGS:HandleRobbing(zone, amount)      
    if not zone.RobberEnt then return; end
    self.BeingRobbed = self.BeingRobbed or false
    if not self.BeingRobbed then
        if math.random(0, 100) <= self.Config.RobberyChance then   
            self.RobberPeds = self.RobberPeds or {}
            self.BeingRobbed = true 
            self.CanDoAction = false           

            local playerPed = PlayerPedId()
            local drugTitle = (zone.DrugTitle:sub(1,1):lower()..zone.DrugTitle:sub(2))

            ESX.TriggerServerCallback('JDGS:GetHeat', function(heat)
                local robbers = zone.RobberEnt
                local weapons = self:GetEntWeaponTier(heat)

                JUtils:LoadModelTable(robbers.Models)

                local count = 0
                local attempt = 0
                local takenpos = {}

                --if heat > 75 then count = -5; end

                while count == 0 or count < (heat / 20) do
                    local randomPos = robbers.Positions[math.random(1, #robbers.Positions)] 
                    local posTaken = false
                    for k,v in pairs(takenpos) do 
                        attempt = attempt + 1
                        if JUtils:GetVecDist(randomPos.xyz, zone.Positions.ActionPos) < 50 then
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

                        local randModel = JUtils.GetHashKey(robbers.Models[math.random(1, #robbers.Models)])
                        local newPed = CreatePed(robbers.Type, randModel, randomPos.xyz, randomPos.w, true, false)         
                        Citizen.Wait(1)
                        self:RequestNetworkControl(newPed, true) 
                        SetEntityLoadCollisionFlag(newPed, true)

                        local weaponCategory = math.random(1, #weapons)
                        local randomWeapon
                        for k,v in pairs(JUtils.Weapons) do
                            if k == weapons[weaponCategory] then 
                                randomWeapon = v[math.random(1, #v)]
                            end 
                        end       

                        SetPedRelationshipGroupHash(newPed, JUtils.GetHashKey(zone.EntSettings.Relationship))
                        SetPedRelationshipGroupDefaultHash(newPed, JUtils.GetHashKey(zone.EntSettings.Relationship))

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

                JUtils:ReleaseModelTable(robbers.Models)

                Citizen.Wait(60000)
                self.BeingRobbed = false 
                self:DespawnRobbers()
            end, drugTitle)
        end
    end
end

function JDGS:GetClosestNPC()
    local NPCIgnoreList = { PlayerPedId(), }
    local playerPos = GetEntityCoords(GetPlayerPed(PlayerId()))

    local closestPed,closestDist = ESX.Game.GetClosestPed(playerPos, NPCIgnoreList)

    if closestDist < self.Config.NPCSalesDist then 
        self.ClosestPed = closestPed
    else 
        self.ClosestPed = false; 
    end
end

function JDGS:DespawnRobbers()
    if not self.RobberPeds then return; end
    self.BeingRobbed = false
    for k,v in pairs(self.RobberPeds) do
        DeletePed(v)
    end
end

function JDGS:MarkerTeleport(zone, exiting)
    Citizen.CreateThread(function()     
        local playerPed = GetPlayerPed(PlayerId())
        if exiting then
            DoScreenFadeOut(500)
            Citizen.Wait(600)
            SetEntityCoords(playerPed, zone.Positions.EntryPos, zone.Positions.EntryHeading, false, false, false)
            Citizen.Wait(600)
            DoScreenFadeIn(500)
        else 
            DoScreenFadeOut(500)
            Citizen.Wait(600)
            SetEntityCoords(playerPed, zone.Positions.ExitPos, zone.Positions.ExitHeading, false, false, false)
            Citizen.Wait(600)
            if self.SpawnedPeds and type(self.SpawnedPeds) == "table" then 
                for k,v in pairs(self.SpawnedPeds) do 
                    FreezeEntityPosition(v, false)
                end
            end
            DoScreenFadeIn(500)
        end
    end)
end

function JDGS:HandleZoneSpawn(zone)
    if self.SpawnedPeds then return; end
    self.SpawnedPeds = {}
    ESX.TriggerServerCallback('JDGS:GetZoneData', function(zoneData) 
        if not zoneData then return; end
        self.CanDoAction = true
        if zoneData.players > 0 then
            self:SpawnZoneHeat(zone)
            print("JDGS:HandleZoneHeat("..zone.ZoneTitle..")")
        else
            self:SpawnZoneBasic(zone)
            print("JDGS:HandleZoneSpawn("..zone.ZoneTitle..")")
        end
    end, zone.ZoneTitle)    
    TriggerServerEvent('JDGS:SetZonePlayers', zone.ZoneTitle, 1)
end

function JDGS:HandleZoneDespawn(zone)
    self.ZoneLoaded = false
    self.SafeActive = false
    print("JDGS:HandleZoneDespawn("..zone.ZoneTitle..")")
    TriggerServerEvent('JDGS:SetZonePlayers', zone.ZoneTitle, -1)
    Citizen.CreateThread(function(...) 
        while self.SpawnedPeds do
            ESX.TriggerServerCallback('JDGS:GetZoneData', function(zoneData) 
                if zoneData then
                    if zoneData.players == 0 then
                        self.CanDoAction = true
                        TriggerServerEvent('JDGS:SetZoneSafeLocked', zone.ZoneTitle, 0)
                        self:DespawnPeds()
                        self:DespawnObjs()
                        self:DespawnVehicles()
                    end
                end
            end, zone.ZoneTitle)
            Citizen.Wait(5000)
        end
    end)
end

function JDGS:DespawnPeds()
    if not self or not self.SpawnedPeds then return; end
    if type(self.SpawnedPeds) == "table" then 
        for k,v in pairs(self.SpawnedPeds) do       
            DeletePed(v)
        end
    end
    self.SpawnedPeds = false    
end

function JDGS:DespawnObjs()
    if not self.SpawnedObjs then return; end
    for k,v in pairs(self.SpawnedObjs) do
        DeleteObject(v)
    end
    self.SpawnedObjs = false
end

function JDGS:DespawnVehicles()
    if not self.SpawnedVehicles then return; end
    for k,v in pairs(self.SpawnedVehicles) do
        DeleteVehicle(v)
    end
    self.SpawnedVehicles = false
end

function JDGS:SpawnZoneHeat(zone)
    if zone.GuardEnt then self:LoadGuardEnts(zone, 0.5); end
end

function JDGS:SpawnZoneBasic(zone)
    if zone.SalesEnt then self:LoadSalesEnts(zone); end
    if zone.WorkerEnt then self:LoadWorkerEnts(zone); end
    if zone.GuardEnt then self:LoadGuardEnts(zone, 1); end
    if zone.Positions.SafePos then self:LoadSafe(zone); end
    if zone.Vehicles then self:LoadVehicles(zone); end
end

function JDGS:LoadVehicles(zone)
    if not ESX or not JUtils then return; end
    self.SpawnedVehicles = self.SpawnedVehicles or {}
    JUtils:LoadModelTable(zone.Vehicles.Models) 
    for k,v in pairs(zone.Vehicles.Positions) do
        ESX.Game.SpawnVehicle(zone.Vehicles.Models[math.random(1,#zone.Vehicles.Models)], v.xyz, v.w, function (vehicle)
            FreezeEntityPosition(vehicle, false)
            table.insert(JDGS.SpawnedVehicles, vehicle)
        end)
    end
end

function JDGS:LoadSafe(zone)
    self.SpawnedObjs = self.SpawnedObjs or {}
    local safePos = zone.Positions.SafePos
    local safeObj = JSC:SpawnSafeObject(JSC.SafeObjects, safePos, 0.0)
    for k,v in pairs(safeObj) do table.insert(self.SpawnedObjs, v); end
end

function JDGS:LoadSalesEnts(zone)
    local sellers = zone.SalesEnt

    JUtils:LoadModelTable(sellers.Models)  

    local randModel = JUtils.GetHashKey(sellers.Models[math.random(1, #sellers.Models)])
    local randPos = sellers.Positions[math.random(1, #sellers.Positions)]   
    local weaponHash = JUtils.GetHashKey('WEAPON_COMBATPISTOL')
    local newPed = CreatePed(sellers.Type, randModel, randPos.xyz, randPos.w, true, false)
    Citizen.Wait(1)
    self:RequestNetworkControl(newPed, true)
    SetEntityLoadCollisionFlag(newPed, true)

    table.insert(self.SpawnedPeds, newPed)

    SetPedRelationshipGroupHash(newPed, JUtils.GetHashKey(zone.EntSettings.Relationship))
    SetPedRelationshipGroupDefaultHash(newPed, JUtils.GetHashKey(zone.EntSettings.Relationship))
    GiveWeaponToPed(newPed, weaponHash, 1000, false, false)

    if sellers.FreezeEnt then
        FreezeEntityPosition(newPed, true)
    end

    JUtils:ReleaseModelTable(sellers.Models)
end

function JDGS:LoadWorkerEnts(zone)
    local workers = zone.WorkerEnt
    local weaponHash = JUtils.GetHashKey('WEAPON_KNIFE')

    JUtils:LoadModelTable(workers.Models)  
    JUtils:LoadAnimDict(workers.AnimDict)

    for k,v in pairs(workers.Positions) do
        local randModel = JUtils.GetHashKey(workers.Models[math.random(1, #workers.Models)])             
        local newPed = CreatePed(workers.Type, randModel, v.xyz, v.w, true, false)
        Citizen.Wait(1)
        self:RequestNetworkControl(newPed, true)

        if workers.FreezeEnt then
            FreezeEntityPosition(newPed, workers.FreezeEnt)
        elseif zone.EntSettings.FreezeEnt then
            FreezeEntityPosition(newPed, zone.EntSettings.FreezeEnt)
        end

        local relHash = JUtils.GetHashKey(zone.EntSettings.Relationship)
        table.insert(self.SpawnedPeds, newPed)

        if type(k) == 'string' then TaskPlayAnim(newPed, workers.AnimDict, k, 8.0, 1.0, -1, 1, 1.0, 0, 0, 0)
        else TaskPlayAnim(newPed, workers.AnimDict, workers.AnimName, 8.0, 1.0, -1, 1, 1.0, 0, 0, 0); end

        SetPedRelationshipGroupHash(newPed, relHash)
        SetPedRelationshipGroupDefaultHash(newPed, relHash)
        GiveWeaponToPed(newPed, weaponHash, 1, false, false)
    end

    JUtils:ReleaseModelTable(workers.Models)
    JUtils:ReleaseAnimDict(workers.AnimDict)
end

function JDGS:LoadGuardEnts(zone, modifier)
    ESX.TriggerServerCallback('JDGS:GetHeat', function(heat)
        local guards = zone.GuardEnt

        JUtils:LoadModelTable(guards.Models)

        local weapons = self:GetEntWeaponTier(heat)
        local count = 0
        --if heat > 75 then count = -10; end

        local attempt = 0
        local takenpos = {}

        while count == 0 or count < ((heat / 20) * modifier) and count < 3 do
            local randomPos = guards.Positions[math.random(1, #guards.Positions)] 
            local posTaken = false
            for k,v in pairs(takenpos) do 
                attempt = attempt + 1
                
                if v.x == randomPos.x and v.y == randomPos.y and v.z == randomPos.z then 
                    posTaken = true 
                else
                    local closestPed = ESX.Game.GetClosestPed(randomPos.xyz)
                    local closestCoords = GetEntityCoords(closestPed)
                    local dist = JUtils:GetVecDist(randomPos.xyz, closestCoords)
                    if dist < 2.0 then posTaken = true; end
                end
            end

            if attempt > count + 1000 then
                if not self.SpawnedPeds then self.SpawnedPeds = true; end
                return
            end

            if not posTaken then
                count = count + 1

                local randModel = JUtils.GetHashKey(guards.Models[math.random(1, #guards.Models)])
                local newPed = CreatePed(guards.Type, randModel, randomPos.xyz, randomPos.w, true, false)  
                Citizen.Wait(1)
                self:RequestNetworkControl(newPed, true) 
                SetEntityLoadCollisionFlag(newPed, true)

                local relHash = JUtils.GetHashKey(zone.EntSettings.Relationship)  
                table.insert(self.SpawnedPeds, newPed)        

                local weaponCategory = math.random(1, #weapons)
                local randomWeapon
                for k,v in pairs(JUtils.Weapons) do
                    if k == weapons[weaponCategory] then 
                        randomWeapon = v[math.random(1, #v)]
                    end 
                end 

                GiveWeaponToPed(newPed, randomWeapon, 1000, true, true)    

                SetPedRelationshipGroupHash(newPed, relHash)
                SetPedRelationshipGroupDefaultHash(newPed, relHash)

                table.insert(takenpos, randomPos)  
            end

            Citizen.Wait(0)
        end

        JUtils:ReleaseModelTable(guards.Models)
    end) 
end

function JDGS:GetEntWeaponTier(heat)
    local weapons = {}
    if heat >= 75 then
        table.insert(weapons, 'Shotgun') 
        table.insert(weapons, 'MG')      
    elseif heat >= 50 then
        table.insert(weapons, 'Shotgun')        
        table.insert(weapons, 'Assault') 
    elseif heat >= 25 then
        table.insert(weapons, 'Shotgun')
        table.insert(weapons, 'SMG')  
    else   
        table.insert(weapons, 'SMG')     
        table.insert(weapons, 'Pistol')
    end

    return weapons
end

AddEventHandler('esx:onPlayerDeath', function(data)
    if not JDGS then return; end
    if JDGS.BeingRobbed then 
        JDGS:DespawnRobbers()
        TriggerServerEvent('JDGS:GetRobbed')        
    end

    if JDGS.SafeActive then JDGS.SafeActive = false; end
end)

RegisterCommand('KillPeds', function(source, args)
    local playerPed = GetPlayerPed(PlayerId())
    local playerPos = GetEntityCoords(playerPed)
    local weaponHash = JUtils.GetHashKey('WEAPON_STUNGUN')

    if JDGS.SpawnedPeds then
        for k,v in pairs(JDGS.SpawnedPeds) do
            if not IsEntityDead(v) then
                local targetPos = GetEntityCoords(v)
                ShootSingleBulletBetweenCoords(targetPos.x, targetPos.y, targetPos.z + 0.5, targetPos, 1000, false, weaponHash, targetPed, true, true, 100)
            end
        end

        Citizen.Wait(2000)
        JDGS:DespawnPeds()
    end
end, false)

Citizen.CreateThread(function() JDGS:ClientStart(); end)