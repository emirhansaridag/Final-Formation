extends Node

## SaveManager - Handles all save/load operations for the game
## Uses ConfigFile for simple, mobile-optimized storage

const SAVE_PATH = "user://save_game.cfg"

# Save file sections
const SECTION_PLAYER = "player"
const SECTION_PROGRESS = "progress"
const SECTION_UPGRADES = "upgrades"
const SECTION_STATS = "stats"

# Default values
const DEFAULT_CURRENCY = 10000
const DEFAULT_SHOOTER_LEVEL = 1

# ConfigFile instance
var save_file: ConfigFile

func _ready():
	save_file = ConfigFile.new()
	print("💾 SaveManager initialized")
	
	# Load existing save on startup
	load_game()

## Save all game data
func save_game():
	# Player data
	save_file.set_value(SECTION_PLAYER, "currency", Global.currency)
	save_file.set_value(SECTION_PLAYER, "shooter_level", Global.shooter_level)
	save_file.set_value(SECTION_PLAYER, "shooter_starter_level", Global.shooter_starter_level)
	save_file.set_value(SECTION_PLAYER, "max_shooters", Global.max_shooters)
	
	# Upgrade levels
	save_file.set_value(SECTION_UPGRADES, "damage_upgrade_level", Global.damage_upgrade_level)
	save_file.set_value(SECTION_UPGRADES, "attack_speed_upgrade_level", Global.attack_speed_upgrade_level)
	save_file.set_value(SECTION_UPGRADES, "max_level_upgrade_level", Global.max_level_upgrade_level)
	save_file.set_value(SECTION_UPGRADES, "max_shooter_upgrade_level", Global.max_shooter_upgrade_level)
	
	# Stats
	save_file.set_value(SECTION_STATS, "enemies_killed", Global.enemies_killed)
	save_file.set_value(SECTION_STATS, "total_play_time", get_total_play_time())
	
	# Progress tracking (for future level unlocks)
	save_file.set_value(SECTION_PROGRESS, "levels_completed", get_levels_completed())
	save_file.set_value(SECTION_PROGRESS, "highest_level", get_highest_level())
	
	# Save metadata
	save_file.set_value(SECTION_PLAYER, "last_save_time", Time.get_unix_time_from_system())
	save_file.set_value(SECTION_PLAYER, "save_version", "1.0")
	
	# Write to disk
	var error = save_file.save(SAVE_PATH)
	if error == OK:
		print("💾 Game saved successfully to: ", SAVE_PATH)
	else:
		push_error("❌ Failed to save game! Error code: " + str(error))
	
	return error == OK

## Load game data from disk
func load_game():
	var error = save_file.load(SAVE_PATH)
	
	if error != OK:
		if error == ERR_FILE_NOT_FOUND:
			print("📁 No save file found, starting fresh game")
			# First time playing, use defaults
			set_default_values()
		else:
			push_error("❌ Failed to load save file! Error code: " + str(error))
			set_default_values()
		return false
	
	print("💾 Save file loaded successfully!")
	
	# Load player data
	Global.currency = save_file.get_value(SECTION_PLAYER, "currency", DEFAULT_CURRENCY)
	Global.shooter_level = save_file.get_value(SECTION_PLAYER, "shooter_level", DEFAULT_SHOOTER_LEVEL)
	Global.shooter_starter_level = save_file.get_value(SECTION_PLAYER, "shooter_starter_level", DEFAULT_SHOOTER_LEVEL)
	Global.max_shooters = save_file.get_value(SECTION_PLAYER, "max_shooters", 3)
	
	# Load upgrade levels
	Global.damage_upgrade_level = save_file.get_value(SECTION_UPGRADES, "damage_upgrade_level", 0)
	Global.attack_speed_upgrade_level = save_file.get_value(SECTION_UPGRADES, "attack_speed_upgrade_level", 0)
	Global.max_level_upgrade_level = save_file.get_value(SECTION_UPGRADES, "max_level_upgrade_level", 0)
	Global.max_shooter_upgrade_level = save_file.get_value(SECTION_UPGRADES, "max_shooter_upgrade_level", 0)
	
	# Load stats
	Global.enemies_killed = save_file.get_value(SECTION_STATS, "enemies_killed", 0)
	
	# Emit signals to update UI
	Global.currency_changed.emit(Global.currency)
	Global.level_changed.emit(Global.shooter_level)
	Global.stats_updated.emit()
	
	print("✅ Game loaded - Currency: ", Global.currency, " | Level: ", Global.shooter_level)
	return true

## Set default values for new game
func set_default_values():
	Global.currency = DEFAULT_CURRENCY
	Global.shooter_level = DEFAULT_SHOOTER_LEVEL
	Global.shooter_starter_level = DEFAULT_SHOOTER_LEVEL
	Global.max_shooters = 3
	
	Global.damage_upgrade_level = 0
	Global.attack_speed_upgrade_level = 0
	Global.max_level_upgrade_level = 0
	Global.max_shooter_upgrade_level = 0
	
	Global.enemies_killed = 0
	
	print("🆕 Default values set for new game")

## Quick save (call this frequently)
func quick_save():
	save_game()

## Auto-save on important events
func auto_save_on_currency_change():
	# Connect this to Global.currency_changed signal
	save_game()

func auto_save_on_upgrade():
	# Save immediately after purchases
	save_game()

## Delete save file (for testing or reset)
func delete_save():
	var dir = DirAccess.open("user://")
	if dir:
		if dir.file_exists("save_game.cfg"):
			dir.remove("save_game.cfg")
			print("🗑️ Save file deleted")
			set_default_values()
			return true
	return false

## Check if save file exists
func save_exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

## Get save file info
func get_save_info() -> Dictionary:
	if not save_exists():
		return {}
	
	return {
		"last_save_time": save_file.get_value(SECTION_PLAYER, "last_save_time", 0),
		"save_version": save_file.get_value(SECTION_PLAYER, "save_version", "1.0"),
		"currency": save_file.get_value(SECTION_PLAYER, "currency", 0),
		"shooter_level": save_file.get_value(SECTION_PLAYER, "shooter_level", 1),
		"enemies_killed": save_file.get_value(SECTION_STATS, "enemies_killed", 0)
	}

## Level progress tracking (for future features)
func mark_level_completed(level_number: int):
	var completed_levels = get_levels_completed()
	if not completed_levels.has(level_number):
		completed_levels.append(level_number)
		save_file.set_value(SECTION_PROGRESS, "levels_completed", completed_levels)
		
		# Update highest level
		var highest = get_highest_level()
		if level_number > highest:
			save_file.set_value(SECTION_PROGRESS, "highest_level", level_number)
		
		save_game()
		print("🏆 Level ", level_number, " marked as completed!")

func get_levels_completed() -> Array:
	return save_file.get_value(SECTION_PROGRESS, "levels_completed", [])

func is_level_unlocked(level_number: int) -> bool:
	# Level 1 is always unlocked
	if level_number <= 1:
		return true
	
	# Other levels unlock when previous level is completed
	var completed = get_levels_completed()
	return completed.has(level_number - 1)

func get_highest_level() -> int:
	return save_file.get_value(SECTION_PROGRESS, "highest_level", 1)

func get_total_play_time() -> float:
	return save_file.get_value(SECTION_STATS, "total_play_time", 0.0)

## Debug functions
func print_save_data():
	print("=== SAVE DATA ===")
	print("Currency: ", Global.currency)
	print("Shooter Level: ", Global.shooter_level)
	print("Damage Upgrades: ", Global.damage_upgrade_level)
	print("Attack Speed Upgrades: ", Global.attack_speed_upgrade_level)
	print("Max Level Upgrades: ", Global.max_level_upgrade_level)
	print("Max Shooter Upgrades: ", Global.max_shooter_upgrade_level)
	print("Enemies Killed: ", Global.enemies_killed)
	print("Levels Completed: ", get_levels_completed())
	print("=================")

