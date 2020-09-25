minetest.register_tool("mine9:wipe", {
    desription = "Wipe platform",
    inventory_image = "mine9_wipe.png",
    wield_image = "mine9_wipe.png",
    tool_capabilities = {punch_attack_uses = 0, damage_groups = {wipe = 1}}
})

minetest.register_tool("mine9:flip", {
    desription = "Flip platform",
    inventory_image = "mine9_flip.png",
    wield_image = "mine9_flip.png",
    tool_capabilities = {punch_attack_uses = 0, damage_groups = {flip = 1}}
})