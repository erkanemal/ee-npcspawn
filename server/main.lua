local MySQL = exports.oxmysql

-- Event to trigger NPC loading on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    MySQL.query('SELECT * FROM persistent_npcs', function(rows)
        if rows then
            for _, row in ipairs(rows) do
                TriggerClientEvent('admin_menu:spawnNPC', -1, row)
            end
        else
            print('^1[ee-npcspawn] No NPCs found in the database!^7')
        end
    end)
end)

-- Event to save NPC data
RegisterNetEvent('admin_menu:saveNPC', function(model, coords, emote)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer or xPlayer.getGroup() ~= 'admin' then return end

    MySQL.insert('INSERT INTO persistent_npcs (model, x, y, z, emote) VALUES (?, ?, ?, ?, ?)', {
        model, coords.x, coords.y, coords.z, emote
    }, function(id)
        TriggerClientEvent('admin_menu:spawnNPC', -1, { id = id, model = model, x = coords.x, y = coords.y, z = coords.z, emote = emote })
    end)
end)
