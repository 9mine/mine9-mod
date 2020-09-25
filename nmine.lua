nmine = {}
function nmine.populate_inventory(inventory, ...)
    for i, v in ipairs {...} do
        if inventory:contains_item("main", v) then
        else
            inventory:add_item("main", v)
        end
    end
end


function nmine.shuffle(content)
    local shuffled = {}
    for i, v in ipairs(content) do
        local pos = math.random(1, #shuffled + 1)
        table.insert(shuffled, pos, v)
    end
    return shuffled
end