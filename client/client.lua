local createdNPCs = {}
local isPlayerLoaded = false

local function debugLog(message)
    if Config.Debug then
        print(message)
    end
end

local function loadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
end

local function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end

local function makeNPCInvincible(ped)
    SetEntityInvincible(ped, true)
    SetPedCanRagdoll(ped, false)
    SetPedCanBeTargetted(ped, false)
    SetPedCanBeKnockedOffVehicle(ped, false)
    SetPedDiesWhenInjured(ped, false)
    SetPedConfigFlag(ped, 188, true)
end

local function spawnNPC(npcData)
    debugLog("^2[NPCs] Starting NPC spawn process...^7")
    
    if not npcData.model then
        debugLog("^1[NPCs] Error: No model specified^7")
        return
    end
    
    loadModel(npcData.model)
    
    local coords = type(npcData.coords) == "vector3" and npcData.coords or 
                  vector3(npcData.coords_x, npcData.coords_y, npcData.coords_z)
    
    if not coords then
        debugLog("^1[NPCs] Error: Invalid coordinates^7")
        return
    end
    
    local ped = CreatePed(4, npcData.model, coords.x, coords.y, coords.z - 1.0, npcData.heading, false, true)
    
    if not DoesEntityExist(ped) then
        debugLog("^1[NPCs] Failed to create ped!^7")
        return
    end
    
    SetEntityAsMissionEntity(ped, true, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    makeNPCInvincible(ped)

    if npcData.anim_dict and npcData.anim_name then -- Check database fields directly
        npcData.animation = {
            dict = npcData.anim_dict,
            name = npcData.anim_name
        }
    end

    if npcData.animation and npcData.animation.dict and npcData.animation.name then
        debugLog(string.format("^3[NPCs] Applying animation: dict=%s, name=%s^7", 
            npcData.animation.dict, npcData.animation.name))
        loadAnimDict(npcData.animation.dict)
        TaskPlayAnim(ped, npcData.animation.dict, npcData.animation.name, 8.0, -8.0, -1, 1, 0, false, false, false)
    else
        debugLog("^3[NPCs] No valid animation data for NPC: " .. (npcData.name or "Unnamed") .. "^7")
    end

    table.insert(createdNPCs, ped)
    debugLog("^2[NPCs] NPC spawn complete - Name: " .. (npcData.name or "Unnamed") .. "^7")
end

AddEventHandler('playerSpawned', function()
    isPlayerLoaded = true
    TriggerServerEvent('npcs:playerJoined')
end)

local function cleanupNPCs()
    for _, ped in ipairs(createdNPCs) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
    createdNPCs = {}
end

RegisterNetEvent('npcs:loadNPCs')
AddEventHandler('npcs:loadNPCs', function(npcs)
    debugLog("^2[NPCs] Received " .. #npcs .. " NPCs from server^7")
    
    if not isPlayerLoaded then
        Wait(2000)
    end
    
    cleanupNPCs()
    
    for i, npc in ipairs(npcs) do
        spawnNPC(npc)
        Wait(100)
    end
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    debugLog("^2[NPCs] Resource started, initializing...^7")
    Wait(2000)
    TriggerServerEvent('npcs:playerJoined')
end)

local function saveNPCToConfig(npcData)
    TriggerServerEvent('npcs:addToConfig', npcData)
end

RegisterNUICallback('createNPC', function(data, cb)
    debugLog("^3[NPCs] NUI callback: createNPC received^7")
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)

    local npcData = {
        model = data.model,
        coords = coords,
        heading = heading,
        name = data.name,
        anim_dict = data.animDict, -- Store directly for database
        anim_name = data.animName
    }

    if data.animDict and data.animDict ~= '' and data.animName and data.animName ~= '' then
        npcData.animation = {
            dict = data.animDict,
            name = data.animName
        }
    end

    spawnNPC(npcData)
    saveNPCToConfig(npcData)
    
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName('NPC placed successfully')
    EndTextCommandThefeedPostTicker(true, false)
    
    cb('ok')
end)

RegisterNUICallback('toggleCursor', function(data, cb)
    debugLog("^3[NPCs] NUI callback: toggleCursor - " .. (data.show and "show" or "hide") .. "^7")
    SetNuiFocus(data.show, data.show)
    cb('ok')
end)

local function openNPCUI()
    debugLog("^3[NPCs] Opening NPC UI^7")
    SendNUIMessage({
        type = 'openUI'
    })
    SetNuiFocus(true, true)
end

RegisterCommand('placenpc', function()
    debugLog("^3[NPCs] /placenpc command executed^7")
    TriggerServerEvent('npcs:checkPermission')
end, false)

RegisterNetEvent('npcs:permissionResponse')
AddEventHandler('npcs:permissionResponse', function(hasPermission)
    debugLog("^3[NPCs] Permission response: " .. tostring(hasPermission) .. "^7")
    if hasPermission then
        openNPCUI()
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName('You do not have permission to place NPCs')
        EndTextCommandThefeedPostTicker(true, false)
    end
end)