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
    local creation_info = {
        origin = origin,
        size = size,
        orientation = orientation
    }
    platforms.set_meta(origin, size, orientation, "creation_info", creation_info)
end

function platforms.wipe(origin, size, orientation)
    platforms.create(origin, size, orientation, "air")
end

function platforms.set_meta(origin, size, orientation, meta_name, meta_data)
    local meta = minetest.serialize(meta_data)
    local pos1 = origin
    local x_st = pos1.x
    local y_st = pos1.y
    local z_st = pos1.z

    local x_end = pos1.x + size
    local y_end = orientation == "horizontal" and pos1.y or pos1.y + size
    local z_end = orientation == "horizontal" and pos1.z + size or pos1.z

    for z = z_st, z_end do
        for y = y_st, y_end do
            for x = x_st, x_end do
                local node = minetest.get_meta({x = x, y = y, z = z})
                node:set_string(meta_name, meta)
            end
        end
    end
end

function platforms.set_meta_origin(origin, meta_name, meta_data)
    local meta = minetest.serialize(meta_data)
    local node = minetest.get_meta({x = x, y = y, z = z})
    node:set_string(meta_name, meta)
end
