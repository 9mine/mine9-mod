platforms = {}
function platforms.create(origin, size, orientation, node_name)
    if not node_name then node_name = "default:glass" end
    local pos1 = origin

    local x = pos1.x + size
    local y = orientation == "horizontal" and pos1.y or pos1.y + size
    local z = orientation == "horizontal" and pos1.z + size or pos1.z
    local pos2 = {x = x, y = y, z = z}

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
    platforms.set_meta(origin, size, orientation, "creation_info", nil)
end

function platforms.set_meta(origin, size, orientation, meta_name, meta_data)
    local meta = minetest.serialize(meta_data)
    local x_end = origin.x + size
    local y_end = orientation == "horizontal" and origin.y or origin.y + size
    local z_end = orientation == "horizontal" and origin.z + size or origin.z

    for z = origin.z, z_end do
        for y = origin.y, y_end do
            for x = origin.x, x_end do
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

function platforms.get_creation_info(pos)
    local node_meta = minetest.get_meta(pos)
    return minetest.deserialize(node_meta:get_string("creation_info"))
end
