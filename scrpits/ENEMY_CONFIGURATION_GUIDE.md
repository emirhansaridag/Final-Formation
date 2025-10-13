# Universal Enemy Configuration Guide

## How to Use

Instead of creating separate scripts for each enemy type, use `universal_enemy.gd` and configure it in the Godot Inspector for each enemy scene.

## Configuration Settings for Each Enemy Type

### Regular Stickman Enemy
```
Script: universal_enemy.gd

Enemy Stats:
- Health Multiplier: 1.0
- Speed Multiplier: 1.0
- Enemy Scale: Vector3(0.16, 0.16, 0.16)

Enemy Type:
- Is Boss: false
- Enemy Name: "Stickman"

Animation:
- Animation Name: "ArmatureAction"
- Animation Fallbacks: []
```

### Alien Enemy
```
Script: universal_enemy.gd

Enemy Stats:
- Health Multiplier: 2.0
- Speed Multiplier: 3.0
- Enemy Scale: Vector3(0.2, 0.2, 0.2)

Enemy Type:
- Is Boss: false
- Enemy Name: "Alien"

Animation:
- Animation Name: "ArmatureAction"
- Animation Fallbacks: ["Idle", "Walk", "Run", "Action"]
```

### Serat Boss
```
Script: universal_enemy.gd

Enemy Stats:
- Health Multiplier: 7.0
- Speed Multiplier: 0.8
- Enemy Scale: Vector3(2, 2, 2)

Enemy Type:
- Is Boss: true
- Enemy Name: "Serat Boss"

Animation:
- Animation Name: "run"
- Animation Fallbacks: []
```

### Aras Boss
```
Script: universal_enemy.gd

Enemy Stats:
- Health Multiplier: 4.0
- Speed Multiplier: 0.9
- Enemy Scale: Vector3(2, 2, 2)

Enemy Type:
- Is Boss: true
- Enemy Name: "Aras Boss"

Animation:
- Animation Name: "run"
- Animation Fallbacks: []
```

### Burak Boss (Final Boss)
```
Script: universal_enemy.gd

Enemy Stats:
- Health Multiplier: 10.0
- Speed Multiplier: 0.6
- Enemy Scale: Vector3(2, 2, 2)

Enemy Type:
- Is Boss: true
- Enemy Name: "Burak Boss"

Animation:
- Animation Name: "run3"
- Animation Fallbacks: ["run"]
```

## How to Apply

1. Open each enemy scene (.tscn) in Godot
2. Select the root Node3D
3. In the Inspector, change the script from the old one to `universal_enemy.gd`
4. Configure the exported variables according to the settings above
5. Save the scene

## Benefits

✅ Single script to maintain instead of 5+
✅ Easy to add new enemy types - just configure values
✅ All enemies get bug fixes and improvements automatically
✅ Cleaner codebase with less duplication
✅ Easy to tweak balance in the Inspector

## Adding New Enemy Types

To add a new enemy type:
1. Create the enemy scene with the model
2. Attach `universal_enemy.gd` to the root node
3. Add an Area3D node for collision detection
4. Configure the exported variables in the Inspector
5. Done!

