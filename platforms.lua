platforms = {}
function platforms.create(storage, size, orientation, node_name, count)
    if not node_name then node_name = "default:glass" end
    local pos1 = storage

    local x = pos1.x + size
    local y = orientation == "horizontal" and pos1.y or pos1.y + size
    local z = orientation == "horizontal" and pos1.z + size or pos1.z
    local pos2 = {x = x, y = y, z = z}

    worldedit.set(pos1, pos2, node_name)
    local creation_info = {
        storage = storage,
        size = size,
        orientation = orientation,
        count = count
    }

    platforms.set_creation_info(storage, size, orientation, creation_info)
    platforms.generate_empty_slots(storage, size, orientation)
    return creation_info
end

function platforms.wipe(storage, size, orientation)
    platforms.wipe_top(storage, size, orientation)
    platforms.create(storage, size, orientation, "air")
end

function platforms.wipe_top(storage, size, orientation)
    local listing = platforms.storage_get(storage, "listing")
    if listing ~= nil then
        for k, v in pairs(listing) do
            v.pos.y = v.pos.y + 1.5
            local objects = minetest.get_objects_inside_radius(v.pos, 1)
            while next(objects) ~= nil do
                local k, v = next(objects)
                if v:is_player() then
                else
                    v:remove()
                end
                table.remove(objects, k)
            end
        end
    end
end

function platforms.generate_empty_slots(storage, size, orientation)
    local empty_slots = {}
    local x_end = storage.x + size
    local y_end = orientation == "horizontal" and storage.y or storage.y + size
    local z_end = orientation == "horizontal" and storage.z + size or storage.z

    for z = storage.z, z_end do
        for y = storage.y, y_end do
            for x = storage.x, x_end do
                local point = {x = x, y = y, z = z}
                table.insert(empty_slots, point)
            end
        end
    end
    empty_slots = nmine.shuffle(empty_slots)
    platforms.storage_set(storage, "empty_slots", empty_slots)
end

function platforms.set_creation_info(storage, size, orientation, meta_data)

    local meta = meta_data == nil and nil or minetest.serialize(meta_data)
    local x_end = storage.x + size
    local y_end = orientation == "horizontal" and storage.y or storage.y + size
    local z_end = orientation == "horizontal" and storage.z + size or storage.z

    for z = storage.z, z_end do
        for y = storage.y, y_end do
            for x = storage.x, x_end do
                local point = {x = x, y = y, z = z}
                local node = minetest.get_meta(point)
                node:set_string("creation_info", meta)
            end
        end
    end
end

function platforms.storage_set(pos, meta_name, meta_data)
    local node = minetest.get_meta(platforms.get_creation_info(pos).storage)
    node:set_string(meta_name, minetest.serialize(meta_data))
end

function platforms.storage_get(pos, meta_name)
    local node_meta =
        minetest.get_meta(platforms.get_creation_info(pos).storage)
    return minetest.deserialize(node_meta:get_string(meta_name))
end

function platforms.get_creation_info(pos)
    local node_meta = minetest.get_meta(pos)
    return minetest.deserialize(node_meta:get_string("creation_info"))
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

function platforms.get_size_by_dir(dir_size)
    local platform_size =
        math.ceil(math.sqrt((dir_size / 15) * 100)) < 3 and 3 or
            math.ceil(math.sqrt((dir_size / 15) * 100))
    return platform_size
end
