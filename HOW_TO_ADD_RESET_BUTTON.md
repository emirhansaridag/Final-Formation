# 🔄 How to Add a Reset Save Button

## Option 1: In Main Menu Scene

### Step 1: Add Button to Scene
1. Open `scenes/main_menu.tscn` in Godot
2. Add a `Button` node
3. Name it: `ResetSaveButton`
4. Set text: "Reset Progress" or "Delete Save"
5. Position it somewhere visible (maybe bottom corner for safety)

### Step 2: Connect the Signal
1. Select the button
2. Go to Node → Signals
3. Double-click `pressed()`
4. Connect to main_menu script
5. The function `_on_reset_save_button_pressed()` **already exists!**

### Step 3: Test
- Click the button → Save resets → Scene reloads ✅

---

## Option 2: Add Confirmation Dialog (Safer)

For a more professional approach with confirmation:

```gdscript
# Add to main_menu.gd

# Create confirmation dialog reference
var reset_confirmation: ConfirmationDialog

func _ready():
	# ... existing code ...
	
	# Create confirmation dialog
	reset_confirmation = ConfirmationDialog.new()
	reset_confirmation.dialog_text = "Are you sure you want to reset all progress?\nThis cannot be undone!"
	reset_confirmation.title = "Reset Progress"
	reset_confirmation.confirmed.connect(_on_reset_confirmed)
	add_child(reset_confirmation)

func _on_reset_save_button_pressed():
	# Show confirmation instead of immediately deleting
	reset_confirmation.popup_centered()

func _on_reset_confirmed():
	print("🗑️ Resetting save data...")
	SaveManager.delete_save()
	await get_tree().create_timer(0.3).timeout
	get_tree().reload_current_scene()
```

---

## Option 3: Add to Settings Menu

If you have a settings menu, you can add it there:

```gdscript
# In your settings_menu.gd

func _on_reset_progress_button_pressed():
	var confirm = ConfirmationDialog.new()
	confirm.dialog_text = "Delete all progress and start fresh?"
	confirm.title = "Reset Game"
	add_child(confirm)
	
	confirm.confirmed.connect(func():
		SaveManager.delete_save()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)
	
	confirm.popup_centered()
```

---

## Option 4: Secret Combo (For Testing)

Add a secret key combo for quick testing:

```gdscript
# Add to any script (like main_menu.gd)

func _input(event):
	if event is InputEventKey and event.pressed:
		# Hold Ctrl+Shift and press R to reset
		if event.ctrl_pressed and event.shift_pressed and event.keycode == KEY_R:
			print("🔄 Secret reset combo triggered!")
			SaveManager.delete_save()
			get_tree().reload_current_scene()
```

---

## Option 5: Debug Menu

Create a dedicated debug panel:

```gdscript
# Create new script: debug_menu.gd

extends Control

func _ready():
	visible = false

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F8:  # Toggle debug menu with F8
			visible = not visible

func _on_delete_save_button_pressed():
	SaveManager.delete_save()
	print("💾 Save deleted!")
	get_tree().reload_current_scene()

func _on_add_1000_coins_button_pressed():
	Global.add_currency(1000)
	print("💰 Added 1000 coins")

func _on_print_save_button_pressed():
	SaveManager.print_save_data()
```

---

## 🎮 What Happens When You Reset

1. Save file is deleted from disk
2. On next game start (or reload):
   - Currency resets to **10,000**
   - All upgrades reset to **level 0**
   - Shooter level resets to **1**
   - All stats reset to **0**

---

## ⚠️ Important Notes

- **Permanent Action**: Cannot be undone!
- **Add Confirmation**: Always confirm with user in production
- **Test Mode Only**: Consider hiding reset button in release builds
- **Cloud Save**: If you add cloud save later, delete both local and cloud

---

## 🚀 Quick Implementation

**Fastest way to add reset functionality right now:**

1. Open `scenes/main_menu.tscn`
2. Add a Button
3. Connect it to the **existing** `_on_reset_save_button_pressed()` function
4. Done! ✅

The function is already in `main_menu.gd` - you just need to connect the UI!

---

## 📝 Example Button Properties

```
Node: Button
Name: ResetSaveButton
Text: "🗑️ Reset Progress"
Position: Bottom-left corner
Modulate: Red tint (to show danger)
```

