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
@export var enemy_scale: Vector3 = Vector3(0.16, 0.16, 0.16)  # Regular enemy size multiplier

# Boss Configuration
@export_group("Boss Settings")
@export var serat_boss_scale: Vector3 = Vector3(2, 2, 2)  # Serat Boss size multiplier
@export var aras_boss_scale: Vector3 = Vector3(2, 2, 2)  # Aras Boss size multiplier
@export var burak_boss_scale: Vector3 = Vector3(2, 2, 2)  # Burak Boss size multiplier (larger)

# Gun Box Configuration
@export_group("Gun Box Settings")
@export var gun_box_health: float = 150.0
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
@export var ground_min_x: float = -11.0
@export var ground_max_x: float = 11.0
@export var min_distance_between_shooters: float = 1.0

# Camera Configuration
@export_group("Camera Settings")
@export var camera_follow_speed: float = 3.0
@export var camera_dead_zone: float = 0.1

# Spawner Positions
@export_group("Spawner Positions")
@export var gun_box_spawn_position: Vector3 = Vector3(8, 1, -50)
@export var shooter_adder_spawn_position: Vector3 = Vector3(-8, 2.2, -50)
@export var enemy_spawn_offset: Vector3 = Vector3(-45, 0, -0.5)

# Level Progression Settings
@export_group("Level Progression Settings")
@export var level_duration: float = 240.0  # 4 minutes (240 seconds)
@export var serat_boss_start_time: float = 120.0  # 2 minutes (120 seconds)
@export var aras_boss_start_time: float = 60.0  # 1 minute (60 seconds)
@export var burak_boss_start_time: float = 180.0  # 3 minutes (180 seconds)
@export var stickman_spawn_rate: float = 0.3  # Spawn every 4 seconds
@export var serat_boss_spawn_rate: float = 4.0  # Spawn every 8 seconds
@export var aras_boss_spawn_rate: float = 5.0  # Spawn every 10 seconds
@export var burak_boss_spawn_rate: float = 7.0  # Spawn every 12 seconds

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
