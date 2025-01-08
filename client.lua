local createdNPCs = {}

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
    loadModel(npcData.model)
    local ped = CreatePed(4, npcData.model, npcData.coords.x, npcData.coords.y, npcData.coords.z - 1.0, npcData.heading, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    makeNPCInvincible(ped) 

    if npcData.animation then
        loadAnimDict(npcData.animation.dict)
        TaskPlayAnim(ped, npcData.animation.dict, npcData.animation.name, 8.0, -8.0, -1, 1, 0, false, false, false)
    end

    table.insert(createdNPCs, ped)
end

Citizen.CreateThread(function()
    for _, npc in ipairs(Config.NPCs) do
        spawnNPC(npc)
        TriggerServerEvent('npcs:saveNPC', npc) 
    end
end)

RegisterNetEvent('npcs:loadNPCs')
AddEventHandler('npcs:loadNPCs', function(npcs)
    for _, npc in ipairs(npcs) do
        spawnNPC(npc)
    end
end)
