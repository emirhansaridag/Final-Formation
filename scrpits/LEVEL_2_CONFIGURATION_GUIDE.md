# Level 2 Configuration Guide

This guide explains how to configure spawn timers and spawn rates for Level 2.

## Overview

Level 2 now has its own independent spawn timing and spawn rate configuration. The system supports:
- **Regular Enemies**: Aliens (spawning continuously)
- **Boss 1**: Alien Animal (spawns after a set time)
- **Boss 2**: Alien Boss (spawns after a set time)
- **Boss 3**: Sus Boss (spawns after a set time)

## Configuration Location

All timing and spawn rate settings are configured in **`GameConfig.gd`** under the **"Level 2 Progression Settings"** group.

### Opening GameConfig in Godot Editor

1. Open Godot Editor
2. Navigate to `res://game_config.tres` in the FileSystem
3. Click on it to view in the Inspector
4. Scroll down to find **"Level 2 Progression Settings"**

## Level 2 Configuration Parameters

### Level Duration
```gdscript
@export var level2_duration: float = 300.0  # 5 minutes (300 seconds)
```
- **What it does**: Sets how long Level 2 lasts
- **Default**: 300 seconds (5 minutes)
- **Tip**: Make it longer than Level 1 for increased difficulty

### Regular Enemy (Alien) Spawn Rate
```gdscript
@export var alien_spawn_rate: float = 0.25  # Spawn every 0.25 seconds
```
- **What it does**: Controls how frequently regular aliens spawn
- **Default**: 0.25 seconds (4 aliens per second)
- **Lower value** = More frequent spawning = Harder
- **Higher value** = Less frequent spawning = Easier

### Boss 1: Alien Animal
```gdscript
@export var alien_animal_start_time: float = 60.0  # Start at 1 minute
@export var alien_animal_spawn_rate: float = 3.5  # Spawn every 3.5 seconds
```
- **alien_animal_start_time**: When the first Alien Animal boss appears
  - Default: 60 seconds (1 minute into the level)
- **alien_animal_spawn_rate**: How often new Alien Animal bosses spawn
  - Default: 3.5 seconds between each boss

### Boss 2: Alien Boss
```gdscript
@export var alien_boss_start_time: float = 150.0  # Start at 2.5 minutes
@export var alien_boss_spawn_rate: float = 5.0  # Spawn every 5 seconds
```
- **alien_boss_start_time**: When the first Alien Boss appears
  - Default: 150 seconds (2.5 minutes into the level)
- **alien_boss_spawn_rate**: How often new Alien Bosses spawn
  - Default: 5 seconds between each boss

### Boss 3: Sus Boss
```gdscript
@export var sus_boss_start_time: float = 240.0  # Start at 4 minutes
@export var sus_boss_spawn_rate: float = 6.0  # Spawn every 6 seconds
```
- **sus_boss_start_time**: When the first Sus Boss appears
  - Default: 240 seconds (4 minutes into the level)
- **sus_boss_spawn_rate**: How often new Sus Bosses spawn
  - Default: 6 seconds between each boss

### Gun Box Spawn Interval
```gdscript
@export var level2_gun_box_spawn_interval: float = 25.0  # Spawn every 25 seconds
```
- **What it does**: Controls how often gun boxes spawn
- **Default**: 25 seconds (faster than Level 1's 30 seconds)
- **Lower value** = More frequent gun boxes = More firepower available

### Shooter Adder Spawn Interval
```gdscript
@export var level2_shooter_spawner_interval: float = 0.8  # Spawn every 0.8 seconds
```
- **What it does**: Controls how often shooter adders spawn
- **Default**: 0.8 seconds (faster than Level 1's 1.0 second)
- **Lower value** = More shooter adders available

### Currency Per Second
```gdscript
@export var level2_currency_per_second: int = 3  # 3 coins per second
```
- **What it does**: How many coins the player earns per second during Level 2
- **Default**: 3 coins/second (more than Level 1's 2 coins/second)
- **Higher value** = More rewards for playing harder level

## Scene Configuration

### Level 2 Scene Setup

The Level 2 scene (`scenes/level_2.tscn`) needs to have **ALL spawner nodes** configured properly:

1. Open `scenes/level_2.tscn` in Godot Editor

2. **Configure the root node (level2)**:
   - Select the root **level2** node (which uses mainScene.gd script)
   - In the Inspector, find **"Level Configuration"**
   - Set **Current Level** to **"Level 2"**

3. **Configure enemySpawnerArea**:
   - Select the **enemySpawnerArea** node
   - In the Inspector, find **"Level Configuration"**
   - Set **Current Level** to **"Level 2"**

4. **Configure boxes spawner**:
   - Select the **boxes** node
   - In the Inspector, find **"Level Configuration"**
   - Set **Current Level** to **"Level 2"**

5. **Configure adders spawner**:
   - Select the **adders** node (shooter spawner)
   - In the Inspector, find **"Level Configuration"**
   - Set **Current Level** to **"Level 2"**

**Important**: All four nodes must be set to Level 2 for the level to work correctly with Level 2 timings!

## Example Difficulty Configurations

### Easy Mode
```gdscript
level2_duration = 360.0              # 6 minutes
alien_spawn_rate = 0.5               # Spawn every 0.5 seconds
alien_animal_start_time = 90.0       # Start at 1.5 minutes
alien_animal_spawn_rate = 5.0        # Spawn every 5 seconds
alien_boss_start_time = 180.0        # Start at 3 minutes
alien_boss_spawn_rate = 7.0          # Spawn every 7 seconds
sus_boss_start_time = 270.0          # Start at 4.5 minutes
sus_boss_spawn_rate = 8.0            # Spawn every 8 seconds
```

### Normal Mode (Default)
```gdscript
level2_duration = 300.0              # 5 minutes
alien_spawn_rate = 0.25              # Spawn every 0.25 seconds
alien_animal_start_time = 60.0       # Start at 1 minute
alien_animal_spawn_rate = 3.5        # Spawn every 3.5 seconds
alien_boss_start_time = 150.0        # Start at 2.5 minutes
alien_boss_spawn_rate = 5.0          # Spawn every 5 seconds
sus_boss_start_time = 240.0          # Start at 4 minutes
sus_boss_spawn_rate = 6.0            # Spawn every 6 seconds
```

### Hard Mode
```gdscript
level2_duration = 240.0              # 4 minutes
alien_spawn_rate = 0.15              # Spawn every 0.15 seconds
alien_animal_start_time = 30.0       # Start at 30 seconds
alien_animal_spawn_rate = 2.0        # Spawn every 2 seconds
alien_boss_start_time = 90.0         # Start at 1.5 minutes
alien_boss_spawn_rate = 3.0          # Spawn every 3 seconds
sus_boss_start_time = 150.0          # Start at 2.5 minutes
sus_boss_spawn_rate = 4.0            # Spawn every 4 seconds
```

## Boss Progression Timeline (Default Settings)

```
0:00 - Level starts, Aliens begin spawning
1:00 - Alien Animal bosses start spawning
2:30 - Alien Bosses start spawning
4:00 - Sus Bosses start spawning
5:00 - Level ends (if player survives)
```

## Testing Your Configuration

1. **Save your changes** in `game_config.tres`
2. **Run Level 2** from the editor
3. Watch the console for spawn messages:
   - "⏰ Time to spawn Alien Animal Boss!"
   - "⏰ Time to spawn Alien Boss!"
   - "⏰ Time to spawn Sus Boss!"
4. Adjust values as needed for desired difficulty

## Tips for Balancing

- **Start bosses gradually**: Don't spawn all bosses at once
- **Space out boss types**: Give at least 60-90 seconds between boss introductions
- **Balance spawn rates**: Faster regular enemy spawns means bosses should spawn slower
- **Test thoroughly**: Play through the entire level to ensure it's challenging but fair
- **Consider progression**: Level 2 should be harder than Level 1 but not impossible

## Comparing to Level 1

Level 1 configuration is in the same file under **"Level 1 Progression Settings"**:
- Level 1 Duration: 240 seconds (4 minutes)
- Level 2 Duration: 300 seconds (5 minutes) - 25% longer
- This makes Level 2 feel more epic and challenging

## Additional Notes

- All timing values are in **seconds**
- Spawn rates represent the **delay between spawns** (lower = faster)
- The system automatically handles spawning - you just configure the timings
- Each level can have completely different enemy configurations
- Boss phases are announced in the console for debugging

## Need More Levels?

To add Level 3 or more:
1. Add new configuration section in `GameConfig.gd`
2. Update `EnemyWaveManager.gd` to support the new level
3. Add the level case in `update_enemy_spawning()` function
4. Create the new level scene with appropriate enemy configurations

---

**Happy Level Designing! 🎮**

