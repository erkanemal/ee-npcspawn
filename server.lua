local function debugLog(message)
    if Config.Debug then
        print(message)
    end
end

local function LoadNPCs()
    debugLog("^2[NPCs] Attempting to load NPCs from database...^7")
    local NPCs = MySQL.query.await('SELECT * FROM npcs')
    
    if not NPCs then
        debugLog("^1[NPCs] Failed to load NPCs from database^7")
        return {}
    end
    
    debugLog("^2[NPCs] Successfully loaded " .. #NPCs .. " NPCs from database^7")
    
    -- Transform the data to match the expected format
    for i, npc in ipairs(NPCs) do
        if npc.anim_dict and npc.anim_name then
            npc.animation = {
                dict = npc.anim_dict,
                name = npc.anim_name
            }
        end
        -- Convert coordinates to vector3 format
        npc.coords = vector3(npc.coords_x, npc.coords_y, npc.coords_z)
        debugLog(string.format("^3[NPCs] Loaded NPC %d: Model=%s, Coords=%s, Heading=%s^7", 
            i, npc.model, 
            vector3(npc.coords_x, npc.coords_y, npc.coords_z), 
            npc.heading))
    end
    return NPCs
end

-- Initialize NPCs on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    
    print("^2[NPCs] Resource starting, loading NPCs...^7")
    local NPCs = LoadNPCs()
    if #NPCs > 0 then
        TriggerClientEvent('npcs:loadNPCs', -1, NPCs)
        print("^2[NPCs] Triggered NPC load for all players^7")
    end
end)

RegisterServerEvent('npcs:addToConfig')
AddEventHandler('npcs:addToConfig', function(npcData)
    local src = source
    if not IsPlayerAceAllowed(src, "command.placenpc") then return end
    
    print("^2[NPCs] Attempting to save new NPC to database...^7")
    -- Insert NPC into database
    local success = MySQL.insert.await('INSERT INTO npcs (model, coords_x, coords_y, coords_z, heading, anim_dict, anim_name) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        npcData.model,
        npcData.coords.x,
        npcData.coords.y,
        npcData.coords.z,
        npcData.heading,
        npcData.animation and npcData.animation.dict or nil,
        npcData.animation and npcData.animation.name or nil
    })
    
    if success then
        print(string.format("^2[NPCs] Successfully saved NPC to database: Model=%s, Coords=%s, Heading=%s^7", 
            npcData.model, 
            json.encode(npcData.coords), 
            npcData.heading))
    else
        print("^1[NPCs] Failed to save NPC to database^7")
    end
end)

-- Send NPCs to player when they join
RegisterNetEvent('npcs:playerJoined')
AddEventHandler('npcs:playerJoined', function()
    local src = source
    print("^2[NPCs] Player joined (ID: " .. src .. "), loading NPCs...^7")
    local NPCs = LoadNPCs()
    if #NPCs > 0 then
        TriggerClientEvent('npcs:loadNPCs', src, NPCs)
        print("^2[NPCs] Sent " .. #NPCs .. " NPCs to player " .. src .. "^7")
    end
end)

-- Add permission check handler
RegisterServerEvent('npcs:checkPermission')
AddEventHandler('npcs:checkPermission', function()
    local src = source
    local hasPermission = IsPlayerAceAllowed(src, "command.placenpc")
    TriggerClientEvent('npcs:permissionResponse', src, hasPermission)
end)
