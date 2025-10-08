# Scene Transition Setup Instructions

## 🎬 Adding SceneTransition as Autoload

To enable the new fade transition system, you need to add SceneTransition as an autoload in Godot:

### Steps:

1. **Open Project Settings**
   - Go to `Project` → `Project Settings`

2. **Navigate to AutoLoad Tab**
   - Click on the `AutoLoad` tab

3. **Add SceneTransition**
   - **Path**: `res://scrpits/SceneTransition.gd`
   - **Node Name**: `SceneTransition`
   - **Enable**: ✅ (checked)
   - Click `Add`

4. **Verify Setup**
   - You should see `SceneTransition` in the autoload list
   - Make sure it's enabled (checkbox is checked)

### ✅ That's it! 

Now your game will have smooth fade transitions between scenes:
- **Main Menu** → **Level Select** (with fade)
- **Level Select** → **Game Level** (with fade)

### 🎮 How It Works:

- **Fade Duration**: 0.5 seconds (customizable)
- **Automatic Cleanup**: Pool manager is cleaned up during transitions
- **Smooth Transitions**: Professional fade in/out effects
- **Error Handling**: Proper error checking and logging

### 🛠️ Available Functions:

```gdscript
# Standard fade transition (recommended)
SceneTransition.change_scene_with_fade("res://scenes/mainScene.tscn")

# Custom fade duration
SceneTransition.change_scene_with_fade("res://scenes/mainScene.tscn", 1.0)

# Instant transition (no fade)
SceneTransition.change_scene_instant("res://scenes/mainScene.tscn")

# Manual fade control
await SceneTransition.fade_out(0.5)
# Do something...
await SceneTransition.fade_in(0.5)
```

### 🎨 Future Enhancements:
You can easily extend this system to add:
- Loading screens
- Progress bars
- Different transition effects (slide, scale, etc.)
- Sound effects during transitions
- Custom transition animations

---

**Note**: The old scene transition code has been replaced and cleaned up automatically!
