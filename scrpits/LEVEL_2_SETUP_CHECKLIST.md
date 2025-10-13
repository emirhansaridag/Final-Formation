# Level 2 Setup Checklist ✓

Use this checklist to configure Level 2 properly in Godot Editor.

## 📋 Quick Setup Steps

### Open Level 2 Scene
- [ ] Open Godot Editor
- [ ] Open `scenes/level_2.tscn`

### Configure All Nodes

#### Node 1: Root Node (level2)
- [ ] Select the **level2** root node
- [ ] Look in Inspector for **"Level Configuration"** section
- [ ] Set **Current Level** dropdown to **"Level 2"**
- [ ] ✅ Should see it as option "1" in dropdown

#### Node 2: Enemy Spawner
- [ ] Select **enemySpawnerArea** node in scene tree
- [ ] Look in Inspector for **"Level Configuration"** section  
- [ ] Set **Current Level** dropdown to **"Level 2"**
- [ ] ✅ Already has enemy scenes configured (alien, alien_animal, alien_boss, sus_boss)

#### Node 3: Gun Box Spawner
- [ ] Select **boxes** node in scene tree
- [ ] Look in Inspector for **"Level Configuration"** section
- [ ] Set **Current Level** dropdown to **"Level 2"**

#### Node 4: Shooter Adder Spawner
- [ ] Select **adders** node in scene tree
- [ ] Look in Inspector for **"Level Configuration"** section
- [ ] Set **Current Level** dropdown to **"Level 2"**

### Save and Test
- [ ] Save the scene (Ctrl+S)
- [ ] Run Level 2 from the editor
- [ ] Check console output for these messages:
  - [ ] "💰 Currency system initialized for Level 2 - 3 coins/second"
  - [ ] "📦 Gun Box Spawner initialized for Level 2 - Interval: 25s"
  - [ ] "👤 Shooter Adder Spawner initialized for Level 2 - Interval: 0.8s"
  - [ ] "Level 2 started! Duration: 300 seconds"

### Verify Gameplay
- [ ] Aliens spawn frequently
- [ ] Alien Animal boss appears around 1:00
- [ ] Alien Boss appears around 2:30
- [ ] Sus Boss appears around 4:00
- [ ] Gun boxes spawn faster than Level 1
- [ ] Shooter adders spawn faster than Level 1
- [ ] Currency increases at 3 coins/second

## ❌ Troubleshooting

**If console shows "Level 1" messages:**
- Go back and check that ALL 4 nodes are set to "Level 2"
- Make sure you saved the scene after making changes

**If bosses don't spawn:**
- Check that enemy scenes are assigned in enemySpawnerArea:
  - Regular Enemy Scene = alien.tscn
  - Boss 1 Scene = alien_animal.tscn
  - Boss 2 Scene = alien_boss.tscn
  - Boss 3 Scene = sus_boss.tscn

**If it feels exactly like Level 1:**
- Double-check the root node (level2) is set to Level 2
- Verify game_config.tres has all Level 2 settings

## 🎯 Expected Level 2 Behavior

| Feature | Expected Behavior |
|---------|------------------|
| Level Duration | 5 minutes (longer than Level 1) |
| Regular Enemies | Aliens spawn continuously |
| First Boss | Alien Animal at 1:00 |
| Second Boss | Alien Boss at 2:30 |
| Final Boss | Sus Boss at 4:00 |
| Gun Boxes | Every 25 seconds |
| Shooter Adders | Every 0.8 seconds |
| Currency | 3 per second |

## ✅ Completion

Once all checkboxes are checked and gameplay matches expected behavior, Level 2 is properly configured!

---

**Need help?** Check `LEVEL_2_COMPLETE_FIX_SUMMARY.md` for detailed explanation.

