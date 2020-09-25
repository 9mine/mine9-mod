minetest.register_node("mine9:platform", {
    drawtype = "glasslike",
    visual_scale = 1.0,
    tiles = {
        "default_glass.png", "default_glass.png", "default_glass.png",
        "default_glass.png", "default_glass.png", "default_glass.png"
    },
    use_texture_alpha = true,
    sunlight_propagates = true,
    walkable = true,
    pointable = true,
    diggable = true,
    node_box = {type = "regular"},
    on_punch = function(pos, node, puncher, pointed_thing)
        local capabilities = puncher:get_wielded_item():get_tool_capabilities()
        if capabilities.damage_groups.flip == 1 then
            local node = platforms.get_creation_info(pos)
            platforms.wipe(node.origin, node.size, node.orientation)
            local orientation =
                node.orientation == "horizontal" and "vertical" or "horizontal"
            platforms.create(node.origin, node.size, orientation,
                             "mine9:platform")
        end
        if capabilities.damage_groups.wipe == 1 then
            local node = platforms.get_creation_info(pos)
            platforms.wipe(node.origin, node.size, node.orientation)
        end
    end
})
