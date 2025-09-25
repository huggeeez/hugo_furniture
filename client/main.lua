local QBCore = exports['qb-core']:GetCoreObject()
local spawnedProps = {}

-- Hjälpfunktion för stash-ID (baserat på DB-id)
local function generateStashId(id)
    return "furniture_stash_" .. id
end

-- Registrera prop i ox_target
local function registerPropWithTarget(prop, itemName, id)
    local furnitureData
    for _, furniture in ipairs(Config.FurnitureItems) do
        if furniture.item == itemName then
            furnitureData = furniture
            break
        end
    end

    local options = {
        {
            name = "pick_up_furniture",
            label = "Pick up",
            onSelect = function(data)
                if DoesEntityExist(data.entity) then
                    exports.ox_target:removeLocalEntity(data.entity)
                    DeleteEntity(data.entity)

                    -- Skicka till servern för DB-rensning + item return
                    TriggerServerEvent('hugo_furniture:deletePropById', id)
                    TriggerServerEvent('hugo_furniture:returnItem', itemName)
                end
            end
        }
    }

    -- Lägg till stash-funktion om möbeln stödjer det
    if furnitureData and furnitureData.allowStash and furnitureData.stashSize then
        table.insert(options, {
            name = "open_furniture_stash",
            label = "Open storage",
            onSelect = function()
                local stashId = generateStashId(id)
                TriggerServerEvent(
                    'hugo_furniture:registerStash',
                    stashId,
                    furnitureData.label or "Storage",
                    furnitureData.stashSize.slots,
                    furnitureData.stashSize.weight
                )
                exports.ox_inventory:openInventory('stash', { id = stashId })
            end
        })
    end

    exports.ox_target:addLocalEntity(prop, options)
end

-- När ett furniture-item används
AddEventHandler('ox_inventory:usedItem', function(name, slotId, metadata)
    for _, furniture in ipairs(Config.FurnitureItems) do
        if furniture.item == name then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local forwardVector = GetEntityForwardVector(playerPed)
            local spawnCoords = playerCoords + forwardVector * 1.5
            local propHash = furniture.model

            RequestModel(propHash)
            while not HasModelLoaded(propHash) do
                Wait(10)
            end

            if not HasModelLoaded(propHash) then
                QBCore.Functions.Notify("Model could not be loaded.", "error")
                return
            end

            local prop = CreateObject(propHash, spawnCoords.x, spawnCoords.y, spawnCoords.z + 1.0, true, true, false)
            SetEntityAsMissionEntity(prop, true, true)
            SetEntityInvincible(prop, true)

            Wait(200)
            local result = exports.object_gizmo:useGizmo(prop)

            if result then
                TriggerServerEvent('hugo_furniture:removeItem', name, 1, slotId, metadata)

                SetEntityCoords(prop, result.position.x, result.position.y, result.position.z)
                SetEntityRotation(prop, result.rotation.x, result.rotation.y, result.rotation.z, 2, true)
                FreezeEntityPosition(prop, true)

                -- Spara till DB
                TriggerServerEvent('hugo_furniture:savePropToDB', name, furniture.model, result.position, result.rotation.z)

                table.insert(spawnedProps, {
                    prop = prop,
                    item = name,
                    coords = result.position
                })
            else
                DeleteEntity(prop)
            end

            SetModelAsNoLongerNeeded(propHash)
            break
        end
    end
end)

-- Ladda props från DB vid inlogg
RegisterNetEvent('hugo_furniture:loadProps', function(props)
    for _, propData in ipairs(props) do
        local model = GetHashKey(propData.model)
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(0) end

        local prop = CreateObject(model, propData.x, propData.y, propData.z, true, true, false)
        SetEntityHeading(prop, propData.heading)
        SetEntityAsMissionEntity(prop, true, true)
        SetEntityInvincible(prop, true)
        FreezeEntityPosition(prop, true)

        registerPropWithTarget(prop, propData.item, propData.id)
        SetModelAsNoLongerNeeded(model)
    end
end)

-- Bekräftelse från servern efter DB-insert → koppla ID till prop
RegisterNetEvent('hugo_furniture:confirmPropSaved', function(id, item, model, coords, heading)
    local prop = nil
    for _, entry in ipairs(spawnedProps) do
        if entry.coords.x == coords.x and entry.coords.y == coords.y and entry.coords.z == coords.z and entry.item == item then
            prop = entry.prop
            break
        end
    end

    if prop then
        registerPropWithTarget(prop, item, id)
    else
        print("^1[HUGO_FURNITURE] Could not match prop for ID:^0", id)
    end
end)

-- Rensa props när resursen stoppas
AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        for _, propData in ipairs(spawnedProps) do
            if DoesEntityExist(propData.prop) then
                DeleteEntity(propData.prop)
            end
        end
    end
end)

-- Ladda props efter att spelaren loggat in
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(5000)
    TriggerServerEvent('hugo_furniture:requestProps')
end)
