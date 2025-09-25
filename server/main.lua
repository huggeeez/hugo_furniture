local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('hugo_furniture:savePropToDB', function(item, model, coords, heading)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    local identifier = player.PlayerData.citizenid

    exports.oxmysql:insert('INSERT INTO furniture_props (item, model, x, y, z, heading, placed_by) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        item, model, coords.x, coords.y, coords.z, heading, identifier
    }, function(insertId)
        TriggerClientEvent('hugo_furniture:confirmPropSaved', src, insertId, item, model, coords, heading)
    end)
end)

RegisterNetEvent('hugo_furniture:deletePropById', function(id)
    local numericId = tonumber(id)
    if not numericId then
        return
    end

    exports.oxmysql:execute('DELETE FROM furniture_props WHERE id = ?', { numericId })
end)

RegisterNetEvent('hugo_furniture:removeItem', function(name, count, slotId, metadata)
    local src = source
    exports.ox_inventory:RemoveItem(src, name, count, metadata, slotId)
end)

RegisterNetEvent('hugo_furniture:returnItem', function(itemName)
    local src = source
    exports.ox_inventory:AddItem(src, itemName, 1)
end)

RegisterNetEvent('hugo_furniture:registerStash', function(stashId, label, slots, weight)
    exports.ox_inventory:RegisterStash(stashId, label, slots, weight, false)
end)

RegisterNetEvent('hugo_furniture:requestProps', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    exports.oxmysql:execute('SELECT * FROM furniture_props WHERE placed_by = ?', { Player.PlayerData.citizenid }, function(result)
        if result and #result > 0 then
            TriggerClientEvent('hugo_furniture:loadProps', src, result)
        end
    end)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
    end
end)

local function validateFurnitureItems()
    local missingItems = {}

    for _, furniture in ipairs(Config.FurnitureItems) do
        local itemName = furniture.item
        local itemData = exports.ox_inventory:Items(itemName)

        if not itemData then
            table.insert(missingItems, itemName)
        end
    end

    if #missingItems > 0 then
        print("^1[HUGO_FURNITURE] Missing items in ox_inventory:^0")
        for _, itemName in ipairs(missingItems) do
            print("  - " .. itemName)
        end
    else
        print("^2[HUGO_FURNITURE] All furniture items are correctly located in ox_inventory.^0")
    end
end

CreateThread(validateFurnitureItems)
