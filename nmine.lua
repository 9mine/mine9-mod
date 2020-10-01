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

function nmine.node_pos_near(player_name, radius, node_name)
    radius = radius or 6
    node_name = node_name or "mine9:platform"
    local player = minetest.get_player_by_name(player_name)
    local pos = player:get_pos()
    local node_pos = minetest.find_node_near(pos, radius, {node_name})
    return node_pos, player
end

