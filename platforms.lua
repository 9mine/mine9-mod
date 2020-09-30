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
    platforms.generate_empty_slots(origin, size, orientation)
end

function platforms.wipe(origin, size, orientation)
    platforms.wipe_top(origin, size, orientation)
    platforms.create(origin, size, orientation, "air")
end

function platforms.wipe_top(origin, size, orientation)
    local full = platforms.get_full_slots(origin)
    if full ~= nil then
        for k, v in pairs(full) do
            local objects = minetest.get_objects_inside_radius(v, 2)
            while next(objects) ~= nil do
                local k, v = next(objects)
                v:remove()
                table.remove(objects, k)
            end
        end
    end
end

function platforms.generate_empty_slots(origin, size, orientation)
    local empty_slots = {}
    local x_end = origin.x + size
    local y_end = orientation == "horizontal" and origin.y or origin.y + size
    local z_end = orientation == "horizontal" and origin.z + size or origin.z

    for z = origin.z, z_end do
        for y = origin.y, y_end do
            for x = origin.x, x_end do
                local point = {x = x, y = y, z = z}
                table.insert(empty_slots, point)
            end
        end
    end
    empty_slots = nmine.shuffle(empty_slots)
    platforms.set_meta_origin(origin, "empty_slots", empty_slots)
end

function platforms.set_meta(origin, size, orientation, meta_name, meta_data)

    local meta = meta_data == nil and nil or minetest.serialize(meta_data)
    local x_end = origin.x + size
    local y_end = orientation == "horizontal" and origin.y or origin.y + size
    local z_end = orientation == "horizontal" and origin.z + size or origin.z

    for z = origin.z, z_end do
        for y = origin.y, y_end do
            for x = origin.x, x_end do
                local point = {x = x, y = y, z = z}
                local node = minetest.get_meta(point)
                node:set_string(meta_name, meta)
            end
        end
    end
end

function platforms.set_meta_origin(pos, meta_name, meta_data)
    local meta = minetest.serialize(meta_data)
    local origin = platforms.get_creation_info(pos).origin
    local node = minetest.get_meta(origin)
    node:set_string(meta_name, meta)
end

function platforms.get_meta_origin(pos, meta_name)
    local creation_info = platforms.get_creation_info(pos)
    local node_meta = minetest.get_meta(creation_info.origin)
    return minetest.deserialize(node_meta:get_string(meta_name))
end

function platforms.set_empty_slots(pos, empty_slots)
    local origin = platforms.get_creation_info(pos).origin
    platforms.set_meta_origin(origin, "empty_slots", empty_slots)
end
function platforms.get_empty_slots(pos)
    return platforms.get_meta_origin(pos, "empty_slots")
end

function platforms.set_full_slots(pos, full_slots)
    local origin = platforms.get_creation_info(pos).origin
    platforms.set_meta_origin(origin, "full_slots", full_slots)
end
function platforms.get_full_slots(pos)
    return platforms.get_meta_origin(pos, "full_slots")
end

function platforms.get_creation_info(pos)
    local node_meta = minetest.get_meta(pos)
    return minetest.deserialize(node_meta:get_string("creation_info"))
end

function platforms.get_host_info(pos)
    return platforms.get_meta_origin(pos, "host_info")
end

function platforms.read_cmd(host_info, cmd_path)
    local tcp = socket:tcp()
    local connection, err = tcp:connect(host_info["host"], host_info["port"])
    if (err ~= nil) then
        print("Connection error: " .. dump(err))
        return
    end

    local conn = np.attach(tcp, "root", "")
    local p = conn:newfid()
    np:walk(conn.rootfid, p, cmd_path)
    conn:open(p, 0)
    local buf_size = 4096
    local offset = 0
    local content = ""
    while (true) do
        local dt = conn:read(p, offset, buf_size)
        if (dt == nil) then break end
        content = content .. tostring(dt)
        offset = offset + #dt
    end
    conn:clunk(p)
    conn:clunk(conn.rootfid)
    tcp:close()
    return content ~= "" and nil or content
end

function platforms.write_cmd(host_info, cmd_path, command)
    local tcp = socket:tcp()
    local connection, err = tcp:connect(host_info["host"], host_info["port"])
    if (err ~= nil) then
        print("Connection error: " .. dump(err))
        return
    end

    local conn = np.attach(tcp, "root", "")
    local f = conn:newfid()
    conn:walk(conn.rootfid, f, cmd_path)
    conn:open(f, 1)
    local buf = data.new(command)
    local n = conn:write(f, 0, buf)
    if n ~= #buf then
        error("test: expected to write " .. #buf .. " bytes but wrote " .. n)
    end
    conn:clunk(f)
    conn:clunk(conn.rootfid)
    tcp:close()
end

function platforms.execute_cmd(host_info, cmd_path, command)
    platforms.write_cmd(host_info, cmd_path, command)
    local result = platforms.read_cmd(host_info, cmd_path)
    return result
end