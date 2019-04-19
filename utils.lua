-------------------------------------------
--#######################################--
--##                                   ##--
--##      Utils Funcs & Commands       ##--
--##                                   ##--
--#######################################--
-------------------------------------------

function JAM_Drugs:GetXYDist(x1,y1,z1,x2,y2,z2)
  return math.sqrt(  ( (x1 or 0) - (x2 or 0) )*(  (x1 or 0) - (x2 or 0) )+( (y1 or 0) - (y2 or 0) )*( (y1 or 0) - (y2 or 0) )+( (z1 or 0) - (z2 or 0) )*( (z1 or 0) - (z2 or 0) )  )
end

function JAM_Drugs:GetVecDist(v1,v2)
  if not v1 or not v2 or not v1.x or not v2.x then return 0 ; end
  return math.sqrt(  ( (v1.x or 0) - (v2.x or 0) )*(  (v1.x or 0) - (v2.x or 0) )+( (v1.y or 0) - (v2.y or 0) )*( (v1.y or 0) - (v2.y or 0) )+( (v1.z or 0) - (v2.z or 0) )*( (v1.z or 0) - (v2.z or 0) )  )
end

function JAM_Drugs:MarkerHandler(pos, scale)
    --      Type,  posX,  posY,  posZ,    dirX, dirY, dirZ,    rotX, rotY, rotZ,    scaleX,  scaleY,  scaleZ,    colorR, colorG, colorB,    alpha,     bob,    facecam,   p19,    rotate,    textureDict,    textureName,    drawOnEnts   
    DrawMarker(1, pos.x, pos.y, pos.z,     0.0,  0.0,  0.0,     0.0,  0.0,  0.0,   scale.x, scale.y, scale.z,       255,    255,    255,        0,   false,      false,     2,     false,          false,          false,        false)
end

function JAM_Drugs.drawTextTemplate(text,x,y,font,scale1,scale2,colour1,colour2,colour3,colour4,wrap1,wrap2,centre,outline,dropshadow1,dropshadow2,dropshadow3,dropshadow4,dropshadow5,edge1,edge2,edge3,edge4,edge5)
    return
    {
      text         =                    "",
      x            =                    -1,
      y            =                    -1,
      font         =  font         or    6,
      scale1       =  scale1       or  0.5,
      scale2       =  scale2       or  0.5,
      colour1      =  colour1      or  255,
      colour2      =  colour2      or  255,
      colour3      =  colour3      or  255,
      colour4      =  colour4      or  255,
      wrap1        =  wrap1        or  0.0,
      wrap2        =  wrap2        or  1.0,
      centre       =  ( type(centre) ~= "boolean" and true or centre ),
      outline      =  outline      or    1,
      dropshadow1  =  dropshadow1  or    2,
      dropshadow2  =  dropshadow2  or    0,
      dropshadow3  =  dropshadow3  or    0,
      dropshadow4  =  dropshadow4  or    0,
      dropshadow5  =  dropshadow5  or    0,
      edge1        =  edge1        or  255,
      edge2        =  edge2        or  255,
      edge3        =  edge3        or  255,
      edge4        =  edge4        or  255,
      edge5        =  edge5        or  255,
    }
end

function JAM_Drugs.drawText( t )

  if   not t or not t.text  or  t.text == ""  or  t.x == -1   or  t.y == -1
  then return false
  end

  -- Setup Text
  SetTextFont (t.font)
  SetTextScale (t.scale1, t.scale2)
  SetTextColour (t.colour1,t.colour2,t.colour3,t.colour4)
  SetTextWrap (t.wrap1,t.wrap2)
  SetTextCentre (t.centre)
  SetTextOutline (t.outline)
  SetTextDropshadow (t.dropshadow1,t.dropshadow2,t.dropshadow3,t.dropshadow4,t.dropshadow5)
  SetTextEdge (t.edge1,t.edge2,t.edge3,t.edge4,t.edge5)
  SetTextEntry ("STRING")

  -- Draw Text
  AddTextComponentSubstringPlayerName (t.text)
  DrawText (t.x,t.y)

  return true
end


function JAM_Drugs:FindNearestMarker(pos) 
  if not self or not self.Config then return; end
    if type(pos) ~= "vector3" and type(pos) ~= "table" then 
        return 999999999 
    end

    local nearest,nearestDist,nearestCoords 

    for k,v in pairs(self.Config.Zones) do 
      local distZone = nil
      local distExit = nil
      local distAction = nil
      local distSafe = nil
      
        if v.ZonePos ~= nil then distZone = self:GetVecDist(pos, v.ZonePos.xyz); end
        if v.ExitPos ~= nil then distExit = self:GetVecDist(pos, v.ExitPos.xyz); end
        if v.ActionPos ~= nil then distAction = self:GetVecDist(pos, v.ActionPos); end
        if v.SafeActionPos ~= nil then distSafe = self:GetVecDist(pos, v.SafeActionPos); end

        if distZone ~= nil and (not nearestDist or nearestDist > distZone) then
            nearest,nearestDist,nearestCoords = v,distZone,v.ZonePos.xyz 
        end

        if distExit ~= nil and (not nearestDist or nearestDist > distExit) then
            nearest,nearestDist,nearestCoords = v,distExit,v.ExitPos.xyz
        end

        if distAction ~= nil and (not nearestDist or nearestDist > distAction) then
            nearest,nearestDist,nearestCoords = v,distAction,v.ActionPos
        end

        if distSafe ~= nil and (not nearestDist or nearestDist > distSafe) then
            nearest,nearestDist,nearestCoords = v,distSafe,v.SafeActionPos
        end
    end
    return nearest,nearestDist,nearestCoords 
end

function JAM_Drugs.GetHashKey(strToHash)
  if type(strToHash) == "number" then return strToHash; end;
  return GetHashKeyPrev(tostring(strToHash or "") or "")%0x100000000;
end;
GetHashKeyPrev = GetHashKeyPrev or GetHashKey
GetHashKey     = JAM_Drugs.GetHashKey

function JAM_Drugs.GetEntityModel(ent) return GetEntityModelPrev(tonumber(ent or 0) or 0)%0x100000000; end;
GetEntityModelPrev = GetEntityModelPrev or GetEntityModel
GetEntityModel     = JAM_Drugs.GetEntityModel

function JAM_Drugs:LoadWeapons(table)
    for k,v in pairs(table) do
        local hashKey = self.GetHashKey(v)
        while not HasWeaponAssetLoaded(hashKey) do
            RequestWeaponAsset(hashKey, 31, 0)
            Citizen.Wait(0)
        end
    end
end

function JAM_Drugs:UnloadWeapons(table)
    for k,v in pairs(table) do
        local hashKey = self.GetHashKey(v)
        if HasWeaponAssetLoaded(hashKey) then
            SetModelAsNoLongerNeeded(hashKey)
        end
    end
end

function JAM_Drugs:LoadModels(table)
    for k,v in pairs(table) do
        local hashKey = self.GetHashKey(v)
        while not HasModelLoaded(hashKey) do
            RequestModel(hashKey)
            Citizen.Wait(0)
        end
    end
end

function JAM_Drugs:UnloadModels(table)
    for k,v in pairs(table) do
        local hashKey = self.GetHashKey(v)
        if HasModelLoaded(hashKey) then
            SetModelAsNoLongerNeeded(hashKey)
        end
    end
end

function JAM_Drugs:LoadAnim(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(0)
    end
end

function JAM_Drugs:UnloadAnim(dict)
    local hashKey = self.GetHashKey(v)
    if HasAnimDictLoaded(hashKey) then
        RemoveAnimDict(hashKey)
    end
end

function JAM_Drugs:GetEntWeaponTier(heat)
    local weapons = {}
    if heat >= 75 then
        table.insert(weapons, 'Shotgun') 
        table.insert(weapons, 'MG')
    elseif heat >= 50 then
        table.insert(weapons, 'SMG')        
        table.insert(weapons, 'Assault') 
    elseif heat >= 25 then
        table.insert(weapons, 'Pistol')
        table.insert(weapons, 'SMG')  
    else   
        table.insert(weapons, 'Pistol')     
        table.insert(weapons, 'Melee')
    end

    return weapons
end