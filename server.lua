local spawnedNPCs = {}

RegisterNetEvent('npcs:saveNPC')
AddEventHandler('npcs:saveNPC', function(npcData)
    table.insert(spawnedNPCs, npcData)
end)

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    TriggerClientEvent('npcs:loadNPCs', source, spawnedNPCs)
end)
