# 💾 Save System Documentation

## Overview
The game now has a complete save system implemented using Godot's `ConfigFile` API. This system automatically saves player progress, currency, upgrades, and stats.

## What Gets Saved
- **Currency**: Total coins earned
- **Shooter Level**: Current shooter level
- **Upgrades**: 
  - Damage upgrade level
  - Attack speed upgrade level
  - Max level upgrade level
  - Max shooter upgrade level
- **Stats**:
  - Enemies killed
  - Total play time
- **Progress**:
  - Levels completed (for future level unlock system)
  - Highest level reached

## Save Location
- **Desktop/Development**: `%APPDATA%/Godot/app_userdata/mobileGame/save_game.cfg`
- **Android**: `/data/data/com.yourcompany.mobilegame/files/save_game.cfg`
- **iOS**: App's Documents directory (sandboxed)

## Auto-Save Triggers
The game automatically saves in the following situations:

1. ✅ **On Level Completion**: Immediately saves when you win
2. ✅ **On Game Over**: Saves earned currency even on loss
3. ✅ **After Upgrade Purchase**: Instant save when buying upgrades
4. ✅ **Currency Changes**: Delayed save (2 seconds) when earning large amounts
5. ✅ **On Game Start**: Loads saved data automatically

## Manual Save/Load Functions

### In Code
```gdscript
# Save game manually
SaveManager.save_game()

# Load game manually
SaveManager.load_game()

# Check if save exists
if SaveManager.save_exists():
	print("Save file found!")

# Get save info
var info = SaveManager.get_save_info()
print("Last saved: ", info.last_save_time)
print("Currency: ", info.currency)

# Delete save (for testing)
SaveManager.delete_save()

# Mark level as completed
SaveManager.mark_level_completed(1)

# Check if level is unlocked
if SaveManager.is_level_unlocked(2):
	print("Level 2 is unlocked!")
```

## Debug Console Commands

You can add these to your debug console or main menu:

```gdscript
# Print all save data
SaveManager.print_save_data()

# Delete save and reset
SaveManager.delete_save()

# Force save
SaveManager.save_game()
```

## Testing the Save System

### Test 1: Basic Save/Load
1. Start the game (should show default currency: 10,000)
2. Earn some currency by playing
3. Buy an upgrade
4. Close the game
5. Restart - your currency and upgrades should be restored

### Test 2: Level Completion
1. Complete a level
2. Check console for "💾 Game progress saved!"
3. Close and restart
4. Your currency should include the completion bonus

### Test 3: Data Persistence
1. Play and earn 5,000 coins
2. Close the game forcefully (Alt+F4 or task manager)
3. Restart - should still have the coins (auto-saved)

## Save File Format Example

The save file is a human-readable INI format:

```ini
[player]
currency=15000
shooter_level=2
last_save_time=1696608000
save_version="1.0"

[upgrades]
damage_upgrade_level=3
attack_speed_upgrade_level=2
max_level_upgrade_level=1
max_shooter_upgrade_level=0

[stats]
enemies_killed=150
total_play_time=600.5

[progress]
levels_completed=[1, 2]
highest_level=2
```

## Performance Notes

- ✅ **Mobile Optimized**: ConfigFile is fast and lightweight
- ✅ **Delayed Saves**: Currency changes are batched to prevent lag
- ✅ **Instant Saves**: Critical events (upgrades, level completion) save immediately
- ✅ **Small File Size**: Typically < 1KB

## Future Enhancements

You can easily extend this system:

1. **Cloud Save**: Add Google Play Games / Game Center integration
2. **Multiple Save Slots**: Modify `SAVE_PATH` to support multiple files
3. **Save Encryption**: Add encryption for security
4. **Auto-Backup**: Create backup saves periodically
5. **Save Migration**: Handle version upgrades in `load_game()`

## Troubleshooting

### Save Not Loading
- Check console for load errors
- Verify file path: `user://save_game.cfg`
- Try deleting save and starting fresh

### Save Not Persisting
- Ensure auto-save triggers are firing (check console logs)
- Verify the game isn't crashing before save completes
- Check file permissions (rare on mobile)

### Corrupted Save
- The system will automatically reset to defaults
- You can add save validation in `load_game()` if needed

## Implementation Files

- **SaveManager.gd**: Core save system (singleton)
- **Global.gd**: Integrates auto-save triggers
- **mainScene.gd**: Saves on level complete/game over
- **project.godot**: SaveManager added to autoload

---

**Note**: The save system is ready to use! No additional setup required.
