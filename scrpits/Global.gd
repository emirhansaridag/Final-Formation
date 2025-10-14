extends Node

# Game configuration
var config: GameConfig

# Game state
var shooter_level: int = 1
var shooter_starter_level: int = 1
var shooter_max_level: int = 3
var max_shooters: int = 3

# Upgrade levels (0 = base level, increases with purchases)
var damage_upgrade_level: int = 0
var attack_speed_upgrade_level: int = 0
var max_level_upgrade_level: int = 0
var max_shooter_upgrade_level: int = 0

# Upgrade costs (increase with each level)
var base_damage_upgrade_cost: int = 100
var base_attack_speed_upgrade_cost: int = 150
var base_max_level_upgrade_cost: int = 200
var base_max_shooter_upgrade_cost: int = 300

# Max upgrade levels
var max_damage_upgrades: int = 12
var max_attack_speed_upgrades: int = 12
var max_level_upgrades: int = 12
var max_shooter_upgrades: int = 10

# Stats
var currency: int = 10000  # Start with small amount, earn through time
var enemies_killed: int = 0

# Metro power-up system
var metro_purchased: bool = false
const METRO_COST: int = 500  # One-time purchase cost (free to use after purchase)

# Signals for UI updates
signal currency_changed(new_amount: int)
signal level_changed(new_level: int)
signal stats_updated
signal upgrade_purchased(upgrade_type: String, new_level: int)
signal metro_purchased_signal  # Signal for when metro is first purchased

func _ready():
	# Always create fresh config to pick up script changes
	# (Remove this and uncomment the load section once you're happy with config values)
	config = GameConfig.new()
	print("Config created fresh - projectile speed: ", config.projectile_speed)
	# Save the fresh config
	ResourceSaver.save(config, "res://game_config.tres")
	
	# COMMENTED OUT: Loading existing config (to force refresh)
	# if ResourceLoader.exists("res://game_config.tres"):
	#	config = load("res://game_config.tres")
	#	print("Config loaded - projectile speed: ", config.projectile_speed)
	# else:
	#	config = GameConfig.new()
	#	print("Config created - projectile speed: ", config.projectile_speed)
	#	# Save default config
	#	ResourceSaver.save(config, "res://game_config.tres")
	
	# Use config values
	max_shooters = config.max_shooters_per_area

func get_current_firerate() -> float:
	if not config:
		_ensure_config_loaded()
	# Base multiplier from shooter level
	var level_multiplier = 1.0 + (shooter_level - 1) * 0.2
	# Additional multiplier from attack speed upgrades
	var upgrade_multiplier = 1.0 + attack_speed_upgrade_level * 0.15
	return config.base_firerate / (level_multiplier * upgrade_multiplier)

func get_current_damage() -> float:
	if not config:
		_ensure_config_loaded()
	# Base multiplier from shooter level
	var level_multiplier = 1.0 + (shooter_level - 1) * 0.2
	# Additional multiplier from damage upgrades
	var upgrade_multiplier = 1.0 + damage_upgrade_level * 0.25
	return config.base_damage * level_multiplier * upgrade_multiplier

func get_current_max_shooter_level() -> int:
	# Use base value + upgrades to avoid double-counting
	return 3 + max_level_upgrade_level  # Base max level is 3, each upgrade adds 1

func get_current_max_shooters() -> int:
	# Use base config value + upgrades to avoid double-counting
	if not config:
		_ensure_config_loaded()
	return config.max_shooters_per_area + max_shooter_upgrade_level

func _ensure_config_loaded():
	if not config:
		if ResourceLoader.exists("res://game_config.tres"):
			config = load("res://game_config.tres")
		else:
			config = GameConfig.new()
			# Save default config
			ResourceSaver.save(config, "res://game_config.tres")
		max_shooters = config.max_shooters_per_area

func get_config() -> GameConfig:
	if not config:
		_ensure_config_loaded()
	return config

func add_currency(amount: int):
	currency += amount
	currency_changed.emit(currency)
	# Auto-save when currency changes significantly (every 500 coins)
	if amount >= 100 or amount <= -100:
		_delayed_save()

func can_afford_upgrade(cost: int) -> bool:
	return currency >= cost

func purchase_upgrade(cost: int) -> bool:
	if can_afford_upgrade(cost):
		currency -= cost
		currency_changed.emit(currency)
		# Save after spending currency
		_delayed_save()
		return true
	return false

func upgrade_shooter_level():
	if shooter_level < get_current_max_shooter_level():
		shooter_level += 1
		level_changed.emit(shooter_level)
		stats_updated.emit()

func add_enemy_kill():
	enemies_killed += 1
	stats_updated.emit()

# Delayed save to prevent saving too frequently
var _save_timer: float = 0.0
var _save_pending: bool = false

func _delayed_save():
	_save_pending = true

func _process(delta):
	if _save_pending:
		_save_timer += delta
		if _save_timer >= 2.0:  # Save after 2 seconds of inactivity
			SaveManager.save_game()
			_save_pending = false
			_save_timer = 0.0

# Upgrade system functions
func get_upgrade_cost(upgrade_type: String) -> int:
	match upgrade_type:
		"damage":
			return base_damage_upgrade_cost + (damage_upgrade_level * 50)
		"attack_speed":
			return base_attack_speed_upgrade_cost + (attack_speed_upgrade_level * 75)
		"max_level":
			return base_max_level_upgrade_cost + (max_level_upgrade_level * 100)
		"max_shooter":
			return base_max_shooter_upgrade_cost + (max_shooter_upgrade_level * 150)
		_:
			return 0

func get_upgrade_level(upgrade_type: String) -> int:
	match upgrade_type:
		"damage":
			return damage_upgrade_level
		"attack_speed":
			return attack_speed_upgrade_level
		"max_level":
			return max_level_upgrade_level
		"max_shooter":
			return max_shooter_upgrade_level
		_:
			return 0

func get_max_upgrade_level(upgrade_type: String) -> int:
	match upgrade_type:
		"damage":
			return max_damage_upgrades
		"attack_speed":
			return max_attack_speed_upgrades
		"max_level":
			return max_level_upgrades
		"max_shooter":
			return max_shooter_upgrades
		_:
			return 0

func can_upgrade(upgrade_type: String) -> bool:
	var current_level = get_upgrade_level(upgrade_type)
	var max_level = get_max_upgrade_level(upgrade_type)
	var cost = get_upgrade_cost(upgrade_type)
	return current_level < max_level and can_afford_upgrade(cost)

func purchase_upgrade_type(upgrade_type: String) -> bool:
	if not can_upgrade(upgrade_type):
		return false
	
	var cost = get_upgrade_cost(upgrade_type)
	if purchase_upgrade(cost):
		match upgrade_type:
			"damage":
				damage_upgrade_level += 1
			"attack_speed":
				attack_speed_upgrade_level += 1
			"max_level":
				max_level_upgrade_level += 1
				# No need to update shooter_max_level - get_current_max_shooter_level() handles it
			"max_shooter":
				max_shooter_upgrade_level += 1
				# No need to update max_shooters - get_current_max_shooters() handles it
		
		upgrade_purchased.emit(upgrade_type, get_upgrade_level(upgrade_type))
		stats_updated.emit()
		# Save immediately after upgrade purchase
		SaveManager.save_game()
		return true
	
	return false
