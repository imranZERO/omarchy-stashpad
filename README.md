# Scratchpad

An Omarchy bar widget for Hyprland special workspaces (the scratchpad).

- A drawn window icon, **dimmed** when the scratchpad is empty and **highlighted** while it is shown
- A **count badge** on the icon corner showing how many windows are inside
- A **right-click menu** with two lists: the windows in the scratchpad, and the windows on the current workspace, each with a `−` / `+` button to take it out or put it in

## Mouse actions

| Action      | Effect                                               |
|-------------|------------------------------------------------------|
| Left click  | Toggle the scratchpad                                |
| Right click | Open the menu (`+` stashes a window, `−` brings it back) |
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
| `showCount`     | `true`         | Show the count badge   |
| `hideWhenEmpty` | `false`        | Hide the widget completely when empty        |
| `activeColor`   | theme accent   | Colour used while the scratchpad is shown    |

You can add the widget more than once, one per special workspace:

```json
{ "id": "imranzero.scratchpad" },
{ "id": "imranzero.scratchpad", "workspace": "music", "hideWhenEmpty": true }
```

## Uninstall

Remove the entry from `shell.json` and delete `~/.config/omarchy/plugins/imranzero.scratchpad`.

## License

MIT
