extends Node

## SaveDebugHelper - Optional debug tool for testing save system
## Add this as an autoload if you want easy keyboard shortcuts for save testing

func _ready():
	print("💾 SaveDebugHelper loaded - F5: Print Save | F6: Force Save | F9: Delete Save")

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F5:  # Print save data
				print("\n" + "=".repeat(50))
				SaveManager.print_save_data()
				var info = SaveManager.get_save_info()
				if info.size() > 0:
					print("\n📅 Last saved: ", Time.get_datetime_string_from_unix_time(info.last_save_time))
					print("📦 Save version: ", info.save_version)
				print("=".repeat(50) + "\n")
			
			KEY_F6:  # Force save
				SaveManager.save_game()
				print("🔹 Manual save triggered via F6")
			
			KEY_F9:  # Delete save and reload
				print("🔸 Deleting save file and reloading scene...")
				SaveManager.delete_save()
				await get_tree().create_timer(0.5).timeout
				get_tree().reload_current_scene()
			
			KEY_F10:  # Add test currency
				Global.add_currency(1000)
				print("💰 Added 1000 test currency (Total: ", Global.currency, ")")
			
			KEY_F11:  # Subtract test currency
				Global.add_currency(-500)
				print("💸 Removed 500 test currency (Total: ", Global.currency, ")")
			
			KEY_F12:  # Show save location
				var save_path = ProjectSettings.globalize_path("user://save_game.cfg")
				print("\n📂 Save file location:")
				print("   ", save_path)
				print("   Exists: ", SaveManager.save_exists())
				if SaveManager.save_exists():
					var file_access = FileAccess.open("user://save_game.cfg", FileAccess.READ)
					if file_access:
						var size = file_access.get_length()
						file_access.close()
						print("   Size: ", size, " bytes\n")
