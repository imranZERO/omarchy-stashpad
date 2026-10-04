# Stashpad

An Omarchy bar widget for Hyprland special workspaces (the scratchpad).

- A drawn window icon, **dimmed** when the scratchpad is empty and **highlighted** while it is shown
- A **count badge** on the icon corner showing how many windows are inside. It turns the urgent colour when a stashed window wants attention while the scratchpad is hidden
- A **right-click menu** listing the windows in the scratchpad and the windows on the current workspace

## Mouse actions

| Action       | Effect                                                    |
|--------------|-----------------------------------------------------------|
| Left click   | Toggle the scratchpad                                     |
| Middle click | Stash the focused window                                  |
| Right click  | Open the menu                                             |

## Menu

Each row shows the app icon, the window title and its class. Titles use the full row width until you hover it.

- **Click the row** to focus the window. For a stashed window this also reveals its scratchpad.
- **`+` / `↩`** sends the window to the scratchpad, or brings it back to the current workspace. The `+`, `↩` and `×` buttons only appear while you hover a row.
- **`×`** closes the window.
- A dot on the icon marks a window that is asking for attention.
- **Restore all** brings every stashed window back to the current workspace. **Stash all** sends every window on the current workspace to the scratchpad. Each appears when there are two or more windows.

## Install

Copy or clone this folder to `~/.config/omarchy/plugins/imranzero.stashpad`, then enable the widget in the bar settings or add it to a section of `bar.layout` in `~/.config/omarchy/shell.json`:

```json
{ "id": "imranzero.stashpad" }
```

## Settings

Put settings on the layout entry itself:

| Key             | Default        | Description                                  |
|-----------------|----------------|----------------------------------------------|
| `workspace`     | `"scratchpad"` | Special workspace name (without `special:`)  |
| `showCount`     | `true`         | Show the count badge   |
| `hideWhenEmpty` | `false`        | Hide the widget completely when empty        |
| `activeColor`   | theme accent   | Colour used while the scratchpad is shown    |

You can add the widget more than once, one per special workspace:

```json
{ "id": "imranzero.stashpad" },
{ "id": "imranzero.stashpad", "workspace": "music", "hideWhenEmpty": true }
```

## Uninstall

Remove the entry from `shell.json` and delete `~/.config/omarchy/plugins/imranzero.stashpad`.

## License

MIT
