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
    SetEntityInvincible(ped, true)             -- Prevent all damage
    SetPedCanRagdoll(ped, false)              -- Prevent ragdoll physics
    SetPedCanBeTargetted(ped, false)          -- Prevent targeting by players
    SetPedCanBeKnockedOffVehicle(ped, false) -- Prevent being knocked off vehicles
    SetPedDiesWhenInjured(ped, false)         -- Prevent death when injured
    SetPedConfigFlag(ped, 188, true)          -- Disable "Critical Damage"
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
    
    debugLog(string.format("^3[NPCs] Creating ped at coords: %s^7", json.encode(coords)))
    local ped = CreatePed(4, npcData.model, coords.x, coords.y, coords.z - 1.0, npcData.heading, false, true)
    
    if not DoesEntityExist(ped) then
        debugLog("^1[NPCs] Failed to create ped!^7")
        return
    end
    
    debugLog("^2[NPCs] Ped created successfully, configuring...^7")
    SetEntityAsMissionEntity(ped, true, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    makeNPCInvincible(ped)

    local animation = npcData.animation or 
                     (npcData.anim_dict and npcData.anim_name and {dict = npcData.anim_dict, name = npcData.anim_name})
    
    if animation then
        debugLog(string.format("^3[NPCs] Applying animation: dict=%s, name=%s^7", animation.dict, animation.name))
        loadAnimDict(animation.dict)
        TaskPlayAnim(ped, animation.dict, animation.name, 8.0, -8.0, -1, 1, 0, false, false, false)
    end

    table.insert(createdNPCs, ped)
    debugLog("^2[NPCs] NPC spawn complete^7")
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
        debugLog("^3[NPCs] Player not loaded yet, waiting...^7")
        Wait(2000)
    end
    
    cleanupNPCs()
    
    for i, npc in ipairs(npcs) do
        debugLog(string.format("^3[NPCs] Spawning NPC %d: Model=%s, Coords=%s, Heading=%s^7", 
            i, npc.model, 
            json.encode(npc.coords), 
            npc.heading))
        spawnNPC(npc)
        Wait(100)
    end
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    
    Wait(2000)
    TriggerServerEvent('npcs:playerJoined')
end)

local function saveNPCToConfig(npcData)
    TriggerServerEvent('npcs:addToConfig', npcData)
end

local function placeNPC()
    local input = lib.inputDialog('Create NPC', {
        {type = 'input', label = 'Model Name', description = 'Enter the NPC model name (e.g., a_m_m_bevhills_01)', required = true},
        {type = 'input', label = 'Animation Dictionary', description = 'Enter animation dictionary (optional)'},
        {type = 'input', label = 'Animation Name', description = 'Enter animation name (optional)'}
    })

    if not input then return end -- User cancelled

    local model = input[1]
    local animDict = input[2]
    local animName = input[3]

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)

    local npcData = {
        model = model,
        coords = coords,
        heading = heading
    }

    if animDict ~= "" and animName ~= "" then
        npcData.animation = {
            dict = animDict,
            name = animName
        }
    end

    spawnNPC(npcData)
    
    saveNPCToConfig(npcData)
    
    lib.notify({
        title = 'Success',
        description = 'NPC placed successfully',
        type = 'success'
    })
end

RegisterCommand('placenpc', function()
    TriggerServerEvent('npcs:checkPermission')
end)

RegisterNetEvent('npcs:permissionResponse')
AddEventHandler('npcs:permissionResponse', function(hasPermission)
    if hasPermission then
        placeNPC()
    else
        lib.notify({
            title = 'Error',
            description = 'You do not have permission to place NPCs',
            type = 'error'
        })
    end
end)
