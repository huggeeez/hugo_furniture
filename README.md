# hugo_furniture  

A simple **furniture & prop placement system** for QBCore.  
Players can place down furniture and equipment from items, interact with them through target menus, and use props as stashes with configurable size/weight.
All placed props are saved in the database.

---

## ✨ Features
- Place furniture/props from ox_inventory items  
- Uses object_gizmo for smooth placement and rotation  
- Persistent saving of props to database (`furniture_props`)  
- Automatic reload of props on player reconnect  
- Configurable stash support (slots + weight) on specific props  
- Pick up props again → item is returned to inventory  

---

## 📦 Dependencies
- qb-core  
- ox_inventory  
- ox_target  
- oxmysql  
- object_gizmo  

---

## ⚙️ Installation
1. Drag **hugo_furniture** into your `resources` folder  
2. Import `furniture_props.sql` into your database  
3. Make sure all items in `Config.FurnitureItems` exist in your `ox_inventory/data/items.lua`  
4. Add the resource to your `server.cfg` after ox_lib, qb-core, inventory and target:  
   ```cfg
   ensure ox_lib
   ensure qb-core
   ensure ox_inventory
   ensure ox_target
   ensure hugo_furniture
5. Done 🎉
