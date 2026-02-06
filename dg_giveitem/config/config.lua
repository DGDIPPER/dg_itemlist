Config = {}

-- ACE permission required to open /items and to receive items
Config.Ace = 'qbx_itemslist.items'

-- How many items per page
Config.PageSize = 100

-- Maximum amount player can request
Config.MaxGiveAmount = 5000

-- ox_inventory item images default path
-- If your images are .webp change .png to .webp
Config.ImageUrl = function(itemName)
    return ('nui://ox_inventory/web/images/%s.png'):format(itemName)
end
