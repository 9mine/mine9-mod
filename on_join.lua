minetest.register_on_joinplayer(function(player)
    local inventory = player.get_inventory(player)
    nmine.populate_inventory(inventory, "mine9:wipe", "mine9:flip")
end)
