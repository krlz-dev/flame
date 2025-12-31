# Flame - Mobile Job Simulator

A simple 2D mobile game built with **Godot 4** using an **Entity Component System (ECS)** architecture. Developed entirely on Android using the Godot mobile editor.

## Gameplay

- Control a blue square using a virtual joystick
- Approach the brown workstation to interact
- Select jobs to earn money
- Track your earnings in real-time

## Jobs Available

| Job | Duration | Reward |
|-----|----------|--------|
| Heavy Work | 10 seconds | $50 |
| Medium Work | 5 seconds | $3 |
| Quick Task | 3 seconds | $1 |

## Screenshots

*Coming soon*

## Architecture

This project uses a custom **Entity Component System** pattern:

### Components (Data)
- `VelocityComponent` - Movement speed and velocity
- `InputComponent` - Input direction from joystick
- `SpriteComponent` - Visual properties (color, size)
- `CollisionComponent` - Collision shape data
- `MoneyComponent` - Player's money balance
- `WorkComponent` - Current job progress
- `WorkstationComponent` - Interaction radius for job stations

### Systems (Logic)
- `MovementSystem` - Processes velocity and moves entities
- `InputSystem` - Routes joystick input to player
- `InteractionSystem` - Detects player proximity to workstations
- `WorkSystem` - Manages job progress and rewards

### Entities
Created via `EntityFactory`:
- Player (CharacterBody2D)
- Walls (StaticBody2D)
- Workstation (StaticBody2D)

## Project Structure

```
flame/
├── project.godot
├── main.tscn
├── world.gd
├── joystick.gd
├── components/
│   ├── component.gd
│   ├── velocity_component.gd
│   ├── input_component.gd
│   ├── sprite_component.gd
│   ├── collision_component.gd
│   ├── money_component.gd
│   ├── work_component.gd
│   └── workstation_component.gd
├── systems/
│   ├── system.gd
│   ├── movement_system.gd
│   ├── input_system.gd
│   ├── interaction_system.gd
│   └── work_system.gd
├── entities/
│   └── entity_factory.gd
└── ui/
    ├── action_button.gd
    ├── job_menu.gd
    ├── work_progress_bar.gd
    └── money_display.gd
```

## Requirements

- Godot Engine 4.3+ (Android or Desktop)
- For mobile: Android 7.0+

## How to Run

1. Clone this repository
2. Open Godot Engine 4
3. Import the project by selecting `project.godot`
4. Press Play

## Controls

- **Joystick** (bottom-left): Move the player
- **ACT Button** (bottom-right): Interact with workstation (when nearby)

## Development

This game was developed entirely on Android using:
- **Termux** - Terminal environment
- **Claude Code** - AI-assisted development
- **Godot Engine 4 (Android)** - Game engine

## License

MIT License - Feel free to use and modify!
