local ITEMS_MENU = 'qbx_itemslist:items'

local itemsCache, sortedKeys
local currentFilterFn = nil
local currentFilterLabel = 'All Items'
local currentPage = 1

local function loadItems()
    if itemsCache and sortedKeys then return end

    itemsCache = exports.ox_inventory:Items()
    sortedKeys = {}

    for name in pairs(itemsCache) do
        sortedKeys[#sortedKeys + 1] = name
    end

    table.sort(sortedKeys, function(a, b)
        return a:lower() < b:lower()
    end)
end

local function openAmountDialog(itemName)
    local data = itemsCache[itemName]
    if not data then return end

    local result = lib.inputDialog(('Give: %s'):format(data.label or itemName), {
        {
            type = 'number',
            label = 'Amount',
            description = 'How many do you want?',
            required = true,
            min = 1,
            max = Config.MaxGiveAmount,
            default = 1
        }
    })

    if not result then return end

    local amount = result[1]
    if not amount then return end

    TriggerServerEvent('qbx_itemslist:server:giveItem', itemName, amount)
end

local function getFilteredList(filterFn)
    local filtered = {}
    for _, name in ipairs(sortedKeys) do
        if not filterFn or filterFn(name, itemsCache[name]) then
            filtered[#filtered + 1] = name
        end
    end
    return filtered
end

local function registerAndShowMenu(filterFn, label, page)
    loadItems()

    currentFilterFn = filterFn
    currentFilterLabel = label or 'All Items'
    currentPage = page or 1

    local filtered = getFilteredList(currentFilterFn)
    local total = #filtered
    local totalPages = math.max(1, math.ceil(total / Config.PageSize))

    if currentPage < 1 then currentPage = 1 end
    if currentPage > totalPages then currentPage = totalPages end

    local startIndex = (currentPage - 1) * Config.PageSize + 1
    local endIndex = math.min(startIndex + Config.PageSize - 1, total)

    local options = {}

    options[#options + 1] = {
        title = 'Search',
        description = 'Search by item name or label',
        icon = 'magnifying-glass',
        onSelect = function()
            local res = lib.inputDialog('Search Items', {
                { type = 'input', label = 'Query', required = true, placeholder = 'e.g. water, bandage...' }
            })
            if not res or not res[1] then return end

            local qRaw = res[1]
            local q = qRaw:lower()

            local newFilter = function(name, data)
                local labelLower = (data.label or ''):lower()
                return name:lower():find(q, 1, true) or labelLower:find(q, 1, true)
            end

            registerAndShowMenu(newFilter, ('Search: "%s"'):format(qRaw), 1)
        end
    }

    if currentFilterFn then
        options[#options + 1] = {
            title = 'Clear Search',
            description = 'Back to all items',
            icon = 'xmark',
            onSelect = function()
                registerAndShowMenu(nil, 'All Items', 1)
            end
        }
    end

    if currentPage > 1 then
        options[#options + 1] = {
            title = ('⬅ Previous (%d/%d)'):format(currentPage - 1, totalPages),
            icon = 'arrow-left',
            onSelect = function()
                registerAndShowMenu(currentFilterFn, currentFilterLabel, currentPage - 1)
            end
        }
    end

    if currentPage < totalPages then
        options[#options + 1] = {
            title = ('Next ➡ (%d/%d)'):format(currentPage + 1, totalPages),
            icon = 'arrow-right',
            onSelect = function()
                registerAndShowMenu(currentFilterFn, currentFilterLabel, currentPage + 1)
            end
        }
    end

    options[#options + 1] = {
        title = ('Showing %d–%d of %d'):format(
            (total == 0 and 0 or startIndex),
            (total == 0 and 0 or endIndex),
            total
        ),
        description = currentFilterLabel,
        disabled = true
    }

    for i = startIndex, endIndex do
        local itemName = filtered[i]
        local item = itemsCache[itemName]
        local labelText = item.label or itemName
        local img = Config.ImageUrl(itemName)

        options[#options + 1] = {
            title = labelText,
            description = itemName,
            icon = img,
            image = img,
            onSelect = function()
                openAmountDialog(itemName)
            end,
            metadata = {
                { label = 'Weight', value = item.weight or 0 },
                { label = 'Stack', value = tostring(item.stack ~= false) },
            }
        }
    end

    if total == 0 then
        options[#options + 1] = { title = 'No items found', disabled = true }
    end

    lib.registerContext({
        id = ITEMS_MENU,
        title = ('Items (%d/%d)'):format(currentPage, totalPages),
        options = options
    })

    lib.showContext(ITEMS_MENU)
end

RegisterNetEvent('qbx_itemslist:client:openItems', function()
    registerAndShowMenu(nil, 'All Items', 1)
end)
