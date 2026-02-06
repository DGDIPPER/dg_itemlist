local function hasPerm(src)
    return IsPlayerAceAllowed(src, Config.Ace)
end

RegisterCommand('itemlist', function(source)
    if source == 0 then
        print('[qbx_itemslist] /items cannot be used from console.')
        return
    end

    if not hasPerm(source) then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'No permission.'
        })
        return
    end

    TriggerClientEvent('qbx_itemslist:client:openItems', source)
end, false)

RegisterNetEvent('qbx_itemslist:server:giveItem', function(itemName, amount)
    local src = source
    if not hasPerm(src) then return end

    if type(itemName) ~= 'string' or itemName == '' then return end

    amount = tonumber(amount)
    if not amount or amount < 1 then return end
    if amount > Config.MaxGiveAmount then amount = Config.MaxGiveAmount end

    local itemData = exports.ox_inventory:Items(itemName)
    if not itemData then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Invalid item.' })
        return
    end

    local added = exports.ox_inventory:AddItem(src, itemName, amount)
    if not added then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Could not add item (inventory full?)' })
        return
    end

    TriggerClientEvent('ox_lib:notify', src, {
        type = 'success',
        description = ('Gave %dx %s'):format(amount, itemData.label or itemName)
    })
end)
