# Lanternfall

A 2D roguelike deckbuilder for **Android and PC (Windows, Linux, macOS)**, built with **Godot 4.3 (GDScript)**. You fight turn-based card battles, pick a route through branching maps, draft cards, collect relics, and work through **2 Acts** with **3 heroes**. The game runs in landscape and is built for touch.

Everything is drawn in code with vector shapes: outlined, cel-shaded characters with idle animation, gradient cards with art matched to each card's effect, layered night-sky landscapes, and hit and spark effects. The project has no texture assets. It's light, scales cleanly to any screen density, and builds straight to an `.apk`.

---

## Features

| System | Details |
|---|---|
| **Heroes** | **Clockwright** deploys **Gadgets** (turrets, barrier nodes, tesla coils, repair drones, a siege cannon) into 3 slots; they fire on their own each turn and *Overclock* cards fire them early. **Fatebinder** rolls 3 **Fate Dice** each turn and spends, rerolls and reshapes them. **Duskdancer** builds **Flow** by alternating card types; Flow boosts every hit and every Block, and repeating a type breaks it. Each hero has a 10-card starter deck, a starter relic and **25 cards of their own**: 4 starter, 9 common, 7 uncommon and 5 rare. No card is shared between heroes. |
| **Cards** | 77 cards in total: 75 hero cards and 2 statuses/curses. **Every card has its own hand-made vector illustration** (`scripts/ui/CardArt.gd`), drawn over a hero-themed background: a brass workshop, starry velvet, or a moonlit stage. Each card is a list of effects defined as data. Upgrades are written into the card definition, and card text is generated from the effects, showing live numbers that include Strength, Weak and Vulnerable. |
| **Combat** | Energy, draw/discard/exhaust piles, Block, and enemy intents with damage previews. Statuses: Strength, Dexterity, Vulnerable, Weak, Bleed, Thorns, Charge, Ritual, Regen, plus power effects such as Bulwark, Steadfast, Rising Fury, Serrated, Phantom Blades, Overflow and Ley Line. |
| **Enemies** | 15 enemies: 9 normal, 4 elite, 2 bosses (*The Hollow King* and *The Lantern Wyrm*). Each follows a cycling or weighted-random move pattern. |
| **Map** | Generated per act: 12 floors plus a boss, 7 lanes, 6 paths that never cross. Node types: monster, elite, event, rest, shop, treasure, boss. The map scrolls horizontally to suit landscape screens. |
| **Potions** | You carry up to 3 single-use potions, shown in the top bar. There are 13 in total: 10 for any hero, plus 1 hero-specific potion for each. Examples: Fire Flask, Frost Bomb, Iron Tonic, Ember Brew; Overdrive Oil, Liquid Luck and Rhythm Tonic are the hero ones. They drop after some fights (30% of normal fights and 45% of elites; bosses never drop one, and the chance halves right after a fight that dropped one). Shops sell 3 different potions. Click a potion to drink or discard it. Targeted potions ask you to pick an enemy; healing potions also work outside combat. |
| **Sound & music** | 21 sound effects (cards, hits, Block, gold, gadgets, dice, Flow, potions and more) and 4 looping music tracks (title, map, combat, boss) with crossfades. All of it is original and synthesised by `tools/gen_audio.py` (numpy), with no third-party samples. Music and sound can be switched on and off separately in Settings. |
| **Relics** | 21 relics: starter, common, uncommon, rare and boss. Their effects hook into combat start, turn start/end, card played, enemy death, lethal damage, prices and gold. |
| **Economy / nodes** | Card rewards weighted by rarity, elite relics, a choice of 3 boss relics, a shop (cards, relics, card removal), campfires (rest or upgrade), 5 events and treasure chests. |
| **Persistence** | The run auto-saves after every action, including when Android pauses the app. **Continue** resumes on the exact node you were on. A profile keeps stats and settings (fast combat, screen shake, fullscreen). The top bar has a **Map** button, so you can check the route from events, shops, rest sites and combat. |
| **Mobile UX** | Drag a card upward to play it; drag attacks onto an enemy and a targeting arrow follows. You can also **tap a card, then tap a target**. Tap enemies or relics for tooltips. The Android back button closes overlays or opens the pause menu. |

---

## Project layout

```
lanternfall/
├── project.godot              # landscape, 1280x720 base, canvas_items stretch (aspect: expand)
├── export_presets.cfg         # "Android" preset (arm64-v8a + armeabi-v7a, immersive)
├── icon.svg
├── scenes/Main.tscn           # single root scene; screens are built in code
├── scripts/
│   ├── autoload/              # singletons
│   │   ├── GameManager.gd     # run state, flow between screens, rewards, economy
│   │   ├── MapManager.gd      # branching map generation + navigation
│   │   ├── RelicManager.gd    # relic hooks/modifiers
│   │   └── SaveManager.gd     # JSON run save + profile (atomic writes)
│   ├── core/
│   │   ├── CombatManager.gd   # turn engine, effect resolution, enemy AI (signals → UI)
│   │   ├── DeckManager.gd     # draw / hand / discard / exhaust piles
│   │   └── Combatant.gd       # HP, block, statuses
│   ├── data/                  # CardDatabase, EnemyDatabase, RelicDatabase, CharacterDatabase, EventDatabase
│   └── ui/                    # Palette, IconDraw (shaded vector characters/icons), Scenery (backgrounds), HitFX,
│       │                      # MechanicHUD (gadget bay / dice tray / flow meter), CardView, CombatantView,
│       ├── screens/           # MainMenu, CharacterSelect, Map, Combat, Reward, Rest, Shop, Event, Treasure, End
│       └── overlays/          # DeckViewer (view/upgrade/remove), CardChoice, RelicChoice, PauseMenu
└── tests/
    ├── AutoPlay.tscn          # headless bot plays 36 full runs + save round-trip test
    └── UISmoke.tscn           # drives every screen through the real UI (can save screenshots)
```

Game logic (`core/`, `autoload/`, `data/`) never touches nodes from the UI layer. `CombatManager` sends signals (`hand_changed`, `state_changed`, `floating_text`, `was_hit`, `combat_ended`, …) and the UI responds to them. That separation is what lets the headless bot play complete runs.

To add content, edit the data files:

```gdscript
# CardDatabase.gd: "up" gives the upgraded value (or a dictionary of overrides)
"w_hack": {"name": "Hack", "cost": 1, "type": "attack", "rarity": "starter", "owner": "warden",
	"target": "enemy", "effects": [{"type": "damage", "value": 6, "up": 9}]},
```

---

## Running

1. Install **Godot 4.3** (standard build, not .NET).
2. Open `lanternfall/project.godot` and press **F5**. On desktop the mouse stands in for touch.

Headless tests:

```bash
godot --headless --path lanternfall res://tests/AutoPlay.tscn            # logic + save tests
godot --path lanternfall res://tests/UISmoke.tscn -- --shots=/tmp/shots  # UI walkthrough + screenshots
```

---

## Building the Android APK

### Option A: Godot editor
1. **Editor → Manage Export Templates → Download** (4.3).
2. **Editor Settings → Export → Android**: set the *Android SDK Path* and *Java SDK Path* (JDK 17). Godot creates a debug keystore automatically, or you can point it at your own.
3. **Project → Export → Android → Export Project** and pick `build/Lanternfall.apk`.
   With a device connected over USB, the **Remote Debug / one-click deploy** button installs it straight away.

### Option B: command line
```bash
export GODOT_ANDROID_KEYSTORE_DEBUG_PATH=$PWD/debug.keystore
export GODOT_ANDROID_KEYSTORE_DEBUG_USER=androiddebugkey
export GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD=android
keytool -genkeypair -keystore debug.keystore -storepass android -alias androiddebugkey \
        -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
godot --headless --path lanternfall --export-debug "Android" ../build/Lanternfall-debug.apk
adb install -r build/Lanternfall-debug.apk
```

### Option C: GitHub Actions (no local setup)
`.github/workflows/lanternfall-android.yml` runs the headless tests, then exports a signed **debug APK** and uploads it as the `Lanternfall-android` build artifact. It runs on every push that touches `lanternfall/`, and you can also start it manually (*Actions → Lanternfall – Android APK → Run workflow*).
For a **release** APK, add these repository secrets: `ANDROID_RELEASE_KEYSTORE_BASE64`, `ANDROID_RELEASE_KEYSTORE_USER` and `ANDROID_RELEASE_KEYSTORE_PASSWORD`.

**Preset notes:** the preset uses the standard (non-Gradle) template, so no Android build template has to be installed. Package name is `com.lanternfall.deckbuilder` and min SDK is Godot's default (21). It renders with the **Compatibility (GLES3)** renderer so it runs on the widest range of devices. Orientation is **sensor landscape** (`orientation=4`): always landscape, and it rotates between the two landscape directions.

---

## PC builds (Windows / Linux / macOS)

The same project exports to desktop with the presets **Windows**, **Linux** and **macOS** in `export_presets.cfg`. Each build is a single file with the game data embedded in it.

```bash
godot --headless --path lanternfall --export-release "Windows" build/windows/Lanternfall.exe
godot --headless --path lanternfall --export-release "Linux"   build/linux/Lanternfall.x86_64
godot --headless --path lanternfall --export-release "macOS"   build/macos/Lanternfall.zip
```

GitHub Actions builds all three on every push and uploads them as the artifacts `Lanternfall-windows`, `Lanternfall-linux` and `Lanternfall-macos`.

**PC controls**
| Input | Action |
|---|---|
| Hover a card | Lifts it so you can read it |
| Drag a card | Play it (drag attacks onto an enemy) |
| Click a card, then an enemy | Play it on that enemy |
| `1`–`9`, `0` | Select a card in your hand (press again to play non-targeted cards) |
| `E` / `Space` | End turn |
| Right-click | Cancel the selected card |
| `Esc` | Pause menu / close overlay |
| `F11` / `Alt+Enter` | Toggle fullscreen (remembered between sessions) |

**Unsigned builds:** the desktop builds aren't code-signed. Windows SmartScreen may show "Windows protected your PC"; click **More info → Run anyway**. On macOS, unzip the file, then right-click **Lanternfall.app → Open** the first time. On Linux, run `chmod +x Lanternfall.x86_64` first.

---

## Regenerating the audio

```bash
pip install numpy
python3 lanternfall/tools/gen_audio.py   # writes lanternfall/audio/*.wav
```
