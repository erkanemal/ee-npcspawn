local lib = exports.ox_lib
local isMenuOpen = false

RegisterCommand('admin_menu', function()
    if not isMenuOpen then
        OpenAdminMenu()
    end
end, false)

RegisterKeyMapping('admin_menu', 'Open Admin Menu', 'keyboard', Config.OpenMenuKey)

function OpenAdminMenu()
    isMenuOpen = true

    lib.registerContext({
        id = 'admin_menu',
        title = 'Admin NPC Menu',
        options = {
            { 
                label = 'Spawn NPC', 
                description = 'Select a ped and emote for the NPC', 
                onSelect = function() SpawnNPCMenu() end 
            },
            {
                label = 'Close Menu',
                onSelect = function() isMenuOpen = false end
            },
        }
    })
    lib.showContext('admin_menu')
end

function SpawnNPCMenu()
    lib.inputDialog('Spawn NPC', {
        { type = 'input', label = 'Ped Model', required = true },
        { type = 'input', label = 'Emote (optional)', required = false }
    }, function(data)
        if not data or not data[1] then return end

        local model = data[1]
        local emote = data[2]

        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        TriggerServerEvent('admin_menu:saveNPC', model, coords, emote)
    end)
end

RegisterNetEvent('admin_menu:spawnNPC', function(npcData)
    local model = npcData.model
    local coords = vector3(npcData.x, npcData.y, npcData.z)
    local emote = npcData.emote

    lib.progressBar({
        duration = 3000,
        label = 'Spawning NPC...',
        useWhileDead = false,
        canCancel = false,
    })

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    local ped = CreatePed(0, model, coords, 0.0, true, true)

    if emote then
        TaskStartScenarioInPlace(ped, emote, 0, true)
    end

    FreezeEntityPosition(ped, true)
    SetModelAsNoLongerNeeded(model)
end)
