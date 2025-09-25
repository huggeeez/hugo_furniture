# hugo_furniture

hugo_furniture
A simple furniture & prop placement system for QBCore.
Players can place down furniture and equipment from items, interact with them through target menus, and (optionally) use props as stashes with configurable size/weight.
All placed props are saved in the database.

✨ Features
Place furniture/props from ox_inventory items
Uses object_gizmo for smooth placement and rotation
Persistent saving of props to database (furniture_props)
Automatic reload of props on player reconnect
Configurable stash support (slots + weight) on specific props
Pick up props again → item is returned to inventory
📦 Dependencies
qb-core
ox_inventory
ox_target
oxmysql
object_gizmo
⚙️ Installation
Drag hugo_furniture into your resources folder
Import furniture_props.sql into your database
Make sure all items in Config.FurnitureItems exist in your ox_inventory/data/items.lua
Add the resource to your server.cfg after ox_lib, qb-core, inventory and target:
ensure ox_lib
ensure ox_inventory
ensure ox_target
ensure hugo_furniture
Done 🎉
