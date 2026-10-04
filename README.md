# Scratchpad

An Omarchy bar widget for Hyprland special workspaces (the scratchpad).

- **Dimmed** when the scratchpad is empty
- **Highlighted** while the scratchpad is shown
- **Window count** next to the glyph once there are two or more windows
- **Tooltip** listing the titles of the windows inside

## Mouse actions

| Action      | Effect                                               |
|-------------|------------------------------------------------------|
| Left click  | Toggle the scratchpad                                |
| Right click | Move the focused window into the scratchpad          |
| Scroll      | Open the scratchpad, then cycle focus between its windows |

## Install

Copy or clone this folder to `~/.config/omarchy/plugins/imranzero.scratchpad`, then enable the widget in the bar settings or add it to a section of `bar.layout` in `~/.config/omarchy/shell.json`:

```json
{ "id": "imranzero.scratchpad" }
```

## Settings

Put settings on the layout entry itself:

| Key             | Default        | Description                                  |
|-----------------|----------------|----------------------------------------------|
| `workspace`     | `"scratchpad"` | Special workspace name (without `special:`)  |
| `glyph`         | `"☷"`          | Text shown in the bar                        |
| `showCount`     | `true`         | Show the window count when it is 2 or more   |
| `hideWhenEmpty` | `false`        | Hide the widget completely when empty        |
| `activeColor`   | theme accent   | Colour used while the scratchpad is shown    |

You can add the widget more than once, one per special workspace:

```json
{ "id": "imranzero.scratchpad" },
{ "id": "imranzero.scratchpad", "workspace": "music", "glyph": "♪", "hideWhenEmpty": true }
```

## Uninstall

Remove the entry from `shell.json` and delete `~/.config/omarchy/plugins/imranzero.scratchpad`.

## License

MIT
