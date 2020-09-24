platforms = {}
function platforms.create(origin, size, orientation, node_name)
    local pos1 = origin
    local pos2 = origin
    if not node_name then node_name = "default:glass" end
    if orientation == "horizontal" then
        pos2 = {x = pos1.x + size, y = pos1.y, z = pos1.z + size}
    end
    if orientation == "vertical" then
        pos2 = {x = pos1.x + size, y = pos1.y + size, z = pos1.z}
    end
    worldedit.set(pos1, pos2, node_name)
end
