extends Resource
class_name GameConfig

# Shooter Configuration
@export_group("Shooter Settings")
@export var base_firerate: float = 0.8
@export var base_damage: float = 10.0
@export var max_shooters_per_area: int = 3
@export var shooter_move_speed: float = 3.0
@export var shooter_drag_speed: float = 600.0

# Enemy Configuration  
@export_group("Enemy Settings")
@export var enemy_base_health: float = 10.0
@export var enemy_move_speed: float = 2.0
@export var enemy_spawn_interval: float = 3.0

# Gun Box Configuration
@export_group("Gun Box Settings")
@export var gun_box_health: float = 200.0
@export var gun_box_speed: float = 3.0
@export var gun_box_spawn_interval: float = 30.0
@export var shooter_spawner_interval: float = 1.0

# Projectile Configuration
@export_group("Projectile Settings")
@export var projectile_speed: float = 40.0
@export var projectile_lifetime: float = 5.0

# Spawn Area Configuration
@export_group("Spawn Area Settings")
@export var area_bounds: Vector2 = Vector2(2.5, 2.5)
@export var ground_min_x: float = -10.0
@export var ground_max_x: float = 10.0
@export var min_distance_between_shooters: float = 0.6

# Camera Configuration
@export_group("Camera Settings")
@export var camera_follow_speed: float = 3.0
@export var camera_dead_zone: float = 0.1

# Spawner Positions
@export_group("Spawner Positions")
@export var gun_box_spawn_position: Vector3 = Vector3(8, 1, -50)
@export var shooter_adder_spawn_position: Vector3 = Vector3(-8, 2.2, -50)
@export var enemy_spawn_offset: Vector3 = Vector3(-45, 0, -0.5)

# Level 1 Progression Settings
@export_group("Level 1 Progression Settings")
@export var level_duration: float = 240.0  # 4 minutes (240 seconds)
@export var serat_boss_start_time: float = 120.0  # 2 minutes (120 seconds)
@export var aras_boss_start_time: float = 60.0  # 1 minute (60 seconds)
@export var burak_boss_start_time: float = 180.0  # 3 minutes (180 seconds)
@export var stickman_spawn_rate: float = 0.2  # Spawn every 0.2 seconds
@export var serat_boss_spawn_rate: float = 3.0  # Spawn every 3 seconds
@export var aras_boss_spawn_rate: float = 4.0  # Spawn every 4 seconds
@export var burak_boss_spawn_rate: float = 5.0  # Spawn every 5 seconds

# Level 2 Progression Settings
@export_group("Level 2 Progression Settings")
@export var level2_duration: float = 300.0  # 5 minutes (300 seconds)
@export var alien_spawn_rate: float = 0.25  # Regular alien spawn rate (spawn every 0.25 seconds)
@export var alien_animal_start_time: float = 60.0  # 1 minute (60 seconds) - when alien_animal boss starts
@export var alien_animal_spawn_rate: float = 3.5  # Spawn every 3.5 seconds
@export var alien_boss_start_time: float = 150.0  # 2.5 minutes (150 seconds) - when alien_boss starts
@export var alien_boss_spawn_rate: float = 5.0  # Spawn every 5 seconds
@export var sus_boss_start_time: float = 240.0  # 4 minutes (240 seconds) - when sus_boss starts
@export var sus_boss_spawn_rate: float = 6.0  # Spawn every 6 seconds
@export var level2_gun_box_spawn_interval: float = 25.0  # Gun boxes spawn every 25 seconds (faster than Level 1)
@export var level2_shooter_spawner_interval: float = 1  # Shooter adders spawn every 0.8 seconds (faster than Level 1)
@export var level2_currency_per_second: int = 2  # 3 coins per second for Level 2 (more than Level 1)

# Performance Settings - Optimized for mobile
@export_group("Performance Settings")
@export var max_projectiles: int = 1000  # Reduced from 100 for mobile performance
@export var max_enemies: int = 5000     # Reduced from 5000 for mobile performance  
@export var update_frequency_reduction: float = 0.05  # Update every 0.05 seconds (20 times per second)
@export var lod_distance_threshold: float = 30.0  # Reduced threshold for better mobile LOD

# Debug Settings
@export_group("Debug Settings")
@export var debug_mode: bool = false  # Enable for testing boss spawning
@export var debug_serat_boss_start_time: float = 5.0  # 5 seconds for testing
@export var debug_aras_boss_start_time: float = 3.0  # 3 seconds for testing
@export var debug_burak_boss_start_time: float = 10.0  # 10 seconds for testing
