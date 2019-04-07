function JAM_Drugs:GetSharedObject(obj) self.ESX = obj; ESX = obj; end

-------------------------------------------
--#######################################--
--##                                   ##--
--##          Markers & Blips          ##--
--##                                   ##--
--#######################################--
-------------------------------------------

function JAM_Drugs:UpdateBlips()
    if not self or not self.Config or not self.Config.Blips then return; end

    local playerPos = GetEntityCoords(GetPlayerPed())
    for key,val in pairs(self.Config.Blips) do
        local curDist = self:GetVecDist(playerPos, val.Pos)
        if curDist <= val.Radius and not val.blip then
            local blip = AddBlipForCoord(val.Pos)

            SetBlipSprite               (blip, val.Sprite)
            SetBlipDisplay              (blip, val.Display)
            SetBlipScale                (blip, val.Size)
            SetBlipColour               (blip, val.Color)
            SetBlipAsShortRange         (blip, true)

            BeginTextCommandSetBlipName ("STRING")
            AddTextComponentString      (val.Zone)
            EndTextCommandSetBlipName   (blip)

            val.blip = blip

        elseif curDist > val.Radius and val.blip then
            local blip = val.blip            
            val.blip = nil;
            RemoveBlip(blip);
        end
    end
end

function JAM_Drugs:UpdateMarkers()
    if not self or not self.Config or not self.Config.Blips then return; end

    local localCoords = GetEntityCoords(PlayerPedId())

    local nearest,nearestDist,nearestCoords = self:FindNearestMarker(localCoords)
    if nearestDist < self.Config.MarkerDrawDist then
        self:MarkerHandler(nearest.Pos, nearest.Scale)
    end
end

--------------------------------
-- Check Position
--------------------------------

function JAM_Drugs:CheckPosition()
    if not self or not self.Config or not self.Config.TPMarkers then return; end

    self.StandingInMarker = self.StandingInMarker or false

    local standingInMarker = false
    local localCoords = GetEntityCoords(PlayerPedId())

    local nearest,nearestDist,nearestCoords = self:FindNearestMarker(localCoords)

    if nearestDist < nearest.Scale.x then
        standingInMarker = true
    end

    if standingInMarker and not self.StandingInMarker then

        self.StandingInMarker = true
        self.ActionData = ActionData or {};
        if nearest.Zone then
            self.ActionData.Action = nearest  
            self.ActionData.BuyZone = false
            self.ActionData.SalesZone = false     
            self.ActionData.Message = 'Press ~INPUT_PICKUP~ to access the ' .. nearest.Zone
        elseif nearest.BuyZone then
            self.ActionData.Action = false  
            self.ActionData.BuyZone = nearest 
            self.ActionData.SalesZone = false    
            self.ActionData.Message = 'Press ~INPUT_PICKUP~ to purchase ' .. nearest.BuyZone
        elseif nearest.SalesZone then
            self.ActionData.Action = false  
            self.ActionData.BuyZone = false
            self.ActionData.SalesZone = nearest   
            self.ActionData.Message = 'Press ~INPUT_PICKUP~ to sell ' .. nearest.SalesZone
        end
    end

    if not standingInMarker and self.StandingInMarker then
        self.StandingInMarker = false
        self.ActionData.Action = false
        self.ActionData.BuyZone = false
        self.ActionData.SalesZone = false
        self.ESX.UI.Menu.CloseAll()
    end
end

function JAM_Drugs:FindNearestMarker(pos1) 
    if type(pos1) ~= "vector3" and type(pos1) ~= "table" then 
        return 999999999 
    end

    local nearest,nearestDist,nearestCoords 

    for k,v in pairs(self.Config.TPMarkers) do 
        local curDist = self:GetVecDist(pos1, v.Pos)
        local curDistExit = self:GetVecDist(pos1, v.PosExit)

        if not nearestDist or nearestDist > curDist then
            nearest,nearestDist,nearestCoords = v,curDist,v.Pos 
        end

        if not nearestDist or nearestDist > curDistExit then 
            nearest,nearestDist,nearestCoords = v,curDistExit,v.PosExit
        end
    end

    for k,v in pairs(self.Config.ActionMarkers) do
        local curDist = self:GetVecDist(pos1, v.Pos)
        if not nearestDist or nearestDist > curDist then
            nearest,nearestDist,nearestCoords = v,curDist,v.Pos 
        end
    end

    return nearest,nearestDist,nearestCoords 
end

-- -----------------------------------------
-- #######################################--
-- ##                                   ##--
-- ##   If Inside Marker, Check Input   ##--
-- ##                                   ##--
-- #######################################--
-- -----------------------------------------

function JAM_Drugs:CheckInput()
    if not self or not self.ActionData then return; end

    self.Timer = self.Timer or 0

    if self.ActionData.Action or self.ActionData.BuyZone or self.ActionData.SalesZone then
        SetTextComponentFormat('STRING') 
        AddTextComponentString(self.ActionData.Message)
        DisplayHelpTextFromStringLabel(0, 0, 1, -1)

        if IsControlPressed(0, self.Config.Keys['E']) and (GetGameTimer() - self.Timer) > 150 then
            if self.ActionData.Action then
                self:MarkerTeleport(self.ActionData.Action)
            elseif self.ActionData.BuyZone then
                self:OpenBuyMenu(self.ActionData.BuyZone)
            elseif self.ActionData.SalesZone then
                self:OpenSellMenu(self.ActionData.SalesZone)
            end

            self.ActionData.Action = false
            self.ActionData.BuyZone = false
            self.ActionData.SalesZone = false
            self.StandingInMarker = false
            self.Timer = GetGameTimer()            
        end
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
    local localCoords = GetEntityCoords(ped)
    local nearest,nearestDist,nearestCoords = self:FindNearestMarker(localCoords)

    for k,v in pairs(self.Config.TPMarkers) do
        if(v.Pos.x == nearestCoords.x) and (v.Pos.y == nearestCoords.y) and (v.Pos.z == nearestCoords.z)then
            SetEntityCoords(ped, zone.PosExit.x, zone.PosExit.y, zone.PosExit.z, zone.HeadingExit, false, false, false)
            for key,val in pairs(self.Config.Entities) do          
            end
        elseif(v.PosExit.x == nearestCoords.x) and (v.PosExit.y == nearestCoords.y) and (v.PosExit.z == nearestCoords.z) then
            SetEntityCoords(ped, zone.Pos.x, zone.Pos.y, zone.Pos.z, zone.Heading, false, false, false)    
        end
    end
end

--------------------------------------------
--########################################--
--##                                    ##--
--##  Inside Action Marker Trade Menus  ##--
--##                                    ##--
--########################################--
--------------------------------------------

function JAM_Drugs:OpenBuyMenu(zone)
    if not self or not self.ESX then return; end

    self.ESX.UI.Menu.CloseAll()

    local elements = {}
    local buyzone = zone.BuyZone
    local buyprice = zone.Price
    table.insert(elements,{label = "Purchase : " .. buyzone .. " : $" .. (buyprice) .. " +/- 20%", value = buyzone .. "_List"})

    self.ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), buyzone .. "_Menu",
        {
            title = buyzone,
            align = 'top-left',
            elements = elements,
        },

        function(data, menu)
            menu.close()

            self.keyboardActive = true
            DisplayOnscreenKeyboard( 0,"","", amount, "", "", "", 30 )

            while self.keyboardActive do
                if self.keyboardActive and UpdateOnscreenKeyboard() == 1 then
                    self.keyboardActive = false
                    self.keyboardResult = GetOnscreenKeyboardResult()
                    local num = tonumber(self.keyboardResult)
                    if num ~= nil then 
                        self:PurchaseDrugs(zone, num)
                    else 
                        TriggerEvent('esx:showNotification', "Enter a number.")
                    end
                end
            Citizen.Wait(0)
            end
        end,
        function(data, menu)
            menu.close()
        end
    )
end

function JAM_Drugs:OpenSellMenu(zone)
    if not self or not self.ESX then return; end

    self.ESX.UI.Menu.CloseAll()

    local elements = {}
    local SalesZone = zone.SalesZone
    local sellprice = zone.Price
    table.insert(elements,{label = "Sell : " .. SalesZone .. " : $" .. sellprice, value = SalesZone .. "_List"})

    self.ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), SalesZone .. "_Menu",
        {
            title = SalesZone,
            align = 'top-left',
            elements = elements,
        },

        function(data, menu)
            menu.close()

            self.keyboardActive = true
            DisplayOnscreenKeyboard( 0,"","", amount, "", "", "", 30 )

            while self.keyboardActive do
            if self.keyboardActive and UpdateOnscreenKeyboard() == 1 then
                self.keyboardActive = false
                self.keyboardResult = GetOnscreenKeyboardResult()
                local num = tonumber(self.keyboardResult)
                if num ~= nil then 
                    self:SellDrugs(zone, num)
                else 
                    TriggerEvent('esx:showNotification', "Enter a number.")
                end
            end
            Citizen.Wait(0)
            end
  
        end,
        function(data, menu)
            menu.close()
        end
    )
end

-------------------------------------------
--#######################################--
--##                                   ##--
--##       Purchase & Sell Drugs       ##--
--##                                   ##--
--#######################################--
-------------------------------------------

function JAM_Drugs:PurchaseDrugs(zone, amount)
    local str = (zone.BuyZone:sub(1,1):lower()..zone.BuyZone:sub(2))

    ESX.TriggerServerCallback('JAM_Drugs:PurchaseDrug', function(valid, msg, finalprice)           
        if valid then    
            TriggerEvent('esx:showNotification', "You purchased " .. amount .. " " .. str .. " for $" .. math.floor(finalprice) .. msg)
            self:HandleSnitching(zone)      
        else 
            TriggerEvent('esx:showNotification', "You can't purchase that much " .. str .. ".")
        end
    end, str, zone.Price, amount)  
end

function JAM_Drugs:SellDrugs(zone, amount)  
    local str = (zone.SalesZone:sub(1,1):lower()..zone.SalesZone:sub(2))

    ESX.TriggerServerCallback('JAM_Drugs:SellDrug', function (valid)
        if not valid then
            TriggerEvent('esx:showNotification', "You don't have enough " .. str .. " to sell.")
        else
            TriggerEvent('esx:showNotification', "You sold " .. amount .. " " .. str .. " for $" .. math.floor(zone.Price * amount) .. " dirty money.")
            self:HandleRobbing(zone)
        end
    end, str, zone.Price, amount)  
end

-------------------------------------------
--#######################################--
--##                                   ##--
--##       Snitching & Robberies       ##--
--##                                   ##--
--#######################################--
-------------------------------------------

function JAM_Drugs:HandleSnitching(zone)
end

function JAM_Drugs:HandleRobbing(zone)
    local playerPos = GetEntityCoords(GetPlayerPed())
    self.BeingRobbed = self.BeingRobbed or false
    if not self.BeingRobbed then
        local plyped = PlayerPedId()
        local r = math.random(0, 100)
        if r <= self.Config.RobberyChance then         
            if not zone.Robbers then return; end
            self.BeingRobbed = true
            self:RequestModels(zone.Robbers)

            self.robberpeds = self.robberpeds or {}

            for k,v in pairs(zone.Robbers) do
                
                local newPed = CreatePed(v.Type, v.ModelHash, v.Pos, v.Heading, true, false) 

                v.ped = newPed

                RemoveAllPedWeapons(newPed, true)
                GiveWeaponToPed(newPed, v.WeaponModel, 1000, true, true)
                SetCurrentPedWeapon(newPed, v.WeaponModel, true)
                SetPedCurrentWeaponVisible(newPed, true, true, true, true)

                SetPedRelationshipGroupHash(newPed, v.RelHash)

                SetPedCombatRange(newPed, 2)

                SetPedMoveRateOverride(newPed, 1.15)
                SetPedDesiredMoveBlendRatio(newPed, 3.0)

                if not IsPedInCombat(newPed, plyped) then 
                    TaskCombatPed(newPed, plyPed, 0, 16)
                end

                table.insert(self.robberpeds,{ped = newPed})
            end

            self:FreeModels(zone.Robbers)

            Citizen.Wait(60000)

            for k,v in pairs(zone.Robbers) do
                SetPedAsNoLongerNeeded(v.ped)
            end
        end
    end
end

function JAM_Drugs:DeathCheck()
    local plyped = GetPlayerPed()
    if self.BeingRobbed and IsEntityDead(plyped) then
        TriggerServerEvent('JAM_Drugs:GotRobbed')

        self.BeingRobbed = false 
        Citizen.Wait(1000)
        for k,v in pairs(self.robberpeds) do 
            DeletePed(v.ped)
        end
    end
end

-------------------------------------------
--#######################################--
--##                                   ##--
--##          Entity Handling          ##--
--##                                   ##--
--#######################################--
-------------------------------------------

function JAM_Drugs:SpawnHandler()  
    for _k,_v in pairs(self.Config.Entities) do
        self:RequestModels( _v )  
        self:SpawnEntities( _v )
        self:FreeModels( _v )
    end
end

function JAM_Drugs:SpawnEntities(table)
    if type(table) ~= 'table' then return; end
    for k,v in pairs(table) do            
        local newPed = CreatePed(v.Type, v.ModelHash, v.Pos, v.Heading, false, false) 

        SetEntityInvincible(newPed, v.Invincible)
        FreezeEntityPosition(newPed, v.FreezeEnt)
        SetBlockingOfNonTemporaryEvents(newPed, v.BlockEvents)

        if v.AnimDict then
            TaskPlayAnim(newPed, v.AnimDict, v.AnimName, 8.0, 1.0, -1, 1, 1.0, 0, 0, 0)      
        end

        if v.WeaponModel then
            RemoveAllPedWeapons(newPed, true)
            GiveWeaponToPed(newPed, v.WeaponModel, 1000, true, true)
            SetCurrentPedWeapon(newPed, v.WeaponModel, true)
            SetPedCurrentWeaponVisible(newPed, true, true, true, true)
            SetPedRelationshipGroupHash(newPed, v.RelHash)
        end

        if v.BoneIndex then
            local joint = GetPedBoneIndex(newPed, v.BoneIndex)
            local obj = CreateObject(v.AttachedModel, v.Pos, v.Heading, false, false, false)
            AttachEntityToEntity(obj, newPed, joint, v.Offset, v.Rot, false, false, false, false, 0, false)
        end
    end
end

-------------------------------------------
--#######################################--
--##                                   ##--
--##       Load & Unload Models        ##--
--##                                   ##--
--#######################################--
-------------------------------------------

function JAM_Drugs:RequestModels(table)
    if type(table) ~= 'table' then return; end
    for k,v in pairs(table) do
        if not HasModelLoaded(v.ModelHash) then
            while not HasModelLoaded(v.ModelHash) do
                RequestModel(v.ModelHash)
                Citizen.Wait(0)
            end
        end    

        if v.BoneIndex and not HasModelLoaded(v.AttachedModel) then
            while not HasModelLoaded(v.AttachedModel) do
                RequestModel(v.AttachedModel)
                Citizen.Wait(0)
            end
        end        

        if v.WeaponModel and not HasWeaponAssetLoaded(v.WeaponModel) then
            while not HasWeaponAssetLoaded(v.WeaponModel) do
                RequestWeaponAsset(v.WeaponModel, 31, 0)
                Citizen.Wait(0)
            end
        end

        self:RequestAnimations(v)
    end
end

function JAM_Drugs:RequestAnimations(table)
    if table.AnimDict and not HasAnimDictLoaded(table.AnimDict) then
        while not HasAnimDictLoaded(table.AnimDict) do
            RequestAnimDict(table.AnimDict)
            Citizen.Wait(0)
        end
    end 
end

function JAM_Drugs:FreeModels(table)
    if type(table) ~= 'table' then return; end
    for k,v in pairs(table) do            
        SetModelAsNoLongerNeeded(v.ModelHash)
        if v.AnimDict then RemoveAnimDict(v.AnimDict); end
        if v.BoneIndex then SetModelAsNoLongerNeeded(v.AttachedModel); end
        if v.WeaponModel then SetModelAsNoLongerNeeded(v.WeaponModel); end
    end
end

-------------------------------------------
--#######################################--
--##                                   ##--
--##      Utils Funcs & Commands       ##--
--##                                   ##--
--#######################################--
-------------------------------------------

function JAM_Drugs:GetVecDist(v1,v2)
  if not v1 or not v2 or not v1.x or not v2.x then return 0 ; end
  return math.sqrt(  ( (v1.x or 0) - (v2.x or 0) )*(  (v1.x or 0) - (v2.x or 0) )+( (v1.y or 0) - (v2.y or 0) )*( (v1.y or 0) - (v2.y or 0) )+( (v1.z or 0) - (v2.z or 0) )*( (v1.z or 0) - (v2.z or 0) )  )
end

function JAM_Drugs:GetXYDist(x1,y1,z1,x2,y2,z2)
  return math.sqrt(  ( (x1 or 0) - (x2 or 0) )*(  (x1 or 0) - (x2 or 0) )+( (y1 or 0) - (y2 or 0) )*( (y1 or 0) - (y2 or 0) )+( (z1 or 0) - (z2 or 0) )*( (z1 or 0) - (z2 or 0) )  )
end

function JAM_Drugs:MarkerHandler(pos, scale)
    --      Type,  posX,  posY,  posZ,    dirX, dirY, dirZ,    rotX, rotY, rotZ,    scaleX,  scaleY,  scaleZ,    colorR, colorG, colorB,    alpha,     bob,    facecam,   p19,    rotate,    textureDict,    textureName,    drawOnEnts   
    DrawMarker(1, pos.x, pos.y, pos.z,     0.0,  0.0,  0.0,     0.0,  0.0,  0.0,   scale.x, scale.y, scale.z,       255,    255,    255,        0,   false,      false,     2,     false,          false,          false,        false)
end

RegisterCommand('hk', function(source, args)
    local var = ''
    for i = 1,#args do
        var = var .. " " .. args[i]
    end
    print(GetHashKey(var))
end, false)

-------------------------------------------
--#######################################--
--##                                   ##--
--##           Update Thread           ##--
--##                                   ##--
--#######################################--
-------------------------------------------

function JAM_Drugs:Update()
    Citizen.Wait(1000)
    TriggerEvent('esx:getSharedObject', function(...) self:GetSharedObject(...); end);
    Citizen.Wait(1000)
    TriggerServerEvent('JAM_Drugs:Startup')
    Citizen.Wait(1000)
    self:SpawnHandler()

    local ped = PlayerPedId()
    while true do
        self.tick = ( self.tick or 0 ) + 1

        self:UpdateBlips()
        self:UpdateMarkers()  
        self:CheckPosition()
        self:CheckInput()
        self:DeathCheck()
        Citizen.Wait(0)
    end
end

Citizen.CreateThread(function(...) JAM_Drugs:Update(...); end)
