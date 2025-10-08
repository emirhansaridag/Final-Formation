# 🧪 How to Test the Save System

## Quick Test (3 Minutes)

### Step 1: First Launch
1. Run the game
2. Check the console - you should see:
   ```
   💾 SaveManager initialized
   📁 No save file found, starting fresh game
   🆕 Default values set for new game
   🆕 No save file found - Starting fresh game
   ```
3. Note your starting currency: **10,000 coins**

### Step 2: Earn Some Currency
1. Play a level for 10-20 seconds
2. You'll earn 2 coins per second
3. Quit the level (or complete it)
4. Check your currency increased

### Step 3: Buy an Upgrade
1. Go to the Shop menu
2. Buy any upgrade (damage, attack speed, etc.)
3. Console should show:
   ```
   💾 Game saved successfully to: user://save_game.cfg
   ```

### Step 4: Test Save Persistence
1. **Close the game completely** (don't just restart)
2. **Reopen the game**
3. Check the console - you should see:
   ```
   💾 Save file loaded successfully!
   ✅ Game loaded - Currency: [your amount] | Level: [your level]
   💾 Save loaded - Currency: [your amount] | Shooter Level: [your level]
   ```
4. Verify your currency and upgrades are still there! ✅

## Advanced Testing

### Test Auto-Save on Level Complete
1. Play and complete a full level
2. Console should show:
   ```
   🎉 LEVEL COMPLETED! Great job!
   💰 Level completion bonus: +400 coins!
   💾 Game saved successfully
   💾 Game progress saved!
   ```
3. Close and reopen - bonus should be saved

### Test Auto-Save on Game Over
1. Let an enemy reach the end
2. Console should show saves happening
3. Close and reopen - earned currency should persist

### Test Currency Auto-Save
1. Earn 500+ coins (wait ~4 minutes in a level)
2. The game will auto-save after earning large amounts
3. Close forcefully (Alt+F4)
4. Reopen - progress should be saved

## Debug Functions

### View Save Data
Add this to any script and run:
```gdscript
func _input(event):
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_F5:  # Press F5
            SaveManager.print_save_data()
```

Output will show:
```
=== SAVE DATA ===
Currency: 12500
Shooter Level: 2
Damage Upgrades: 3
Attack Speed Upgrades: 2
...
=================
```

### Reset Save (For Testing)
Add a button to your main menu or use:
```gdscript
func _input(event):
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_F9:  # Press F9
            SaveManager.delete_save()
            get_tree().reload_current_scene()
```

### Force Save
```gdscript
func _input(event):
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_F6:  # Press F6
            SaveManager.save_game()
            print("Manual save triggered!")
```

## Where to Find Your Save File

### Windows
```
C:\Users\[YourUsername]\AppData\Roaming\Godot\app_userdata\mobileGame\save_game.cfg
```

Or type in Windows Explorer:
```
%APPDATA%\Godot\app_userdata\mobileGame\
```

### You can open it with Notepad!
The file is human-readable:
```ini
[player]
currency=15000
shooter_level=2
...
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Save not loading | Check console for errors, verify game closed properly |
| Save resets on restart | Ensure SaveManager is in project.godot autoloads |
| No save file created | Check if game has write permissions to user:// directory |
| Currency doesn't save | Verify auto-save triggers are working (check console logs) |

## Expected Console Output

### On Game Start (First Time)
```
💾 SaveManager initialized
📁 No save file found, starting fresh game
🆕 Default values set for new game
Config created fresh - projectile speed: 40
🆕 No save file found - Starting fresh game
```

### On Game Start (With Save)
```
💾 SaveManager initialized
💾 Save file loaded successfully!
✅ Game loaded - Currency: 12500 | Level: 2
Config created fresh - projectile speed: 40
💾 Save loaded - Currency: 12500 | Shooter Level: 2
```

### During Gameplay
```
💰 Time reward: +2 coins (Total: 10234)
💾 Game saved successfully to: user://save_game.cfg
```

### On Upgrade Purchase
```
💾 Game saved successfully to: user://save_game.cfg
```

### On Level Complete
```
🎉 LEVEL COMPLETED! Great job!
💰 Level completion bonus: +400 coins!
💾 Game saved successfully to: user://save_game.cfg
💾 Game progress saved!
```

---

## ✅ Success Criteria

Your save system is working correctly if:
- [x] Currency persists between game sessions
- [x] Upgrades are saved and restored
- [x] Console shows save confirmations
- [x] Save file exists in user:// directory
- [x] No errors in console related to saving/loading

**If all checkboxes pass, your save system is working perfectly!** 🎉

