import QtQuick
import Quickshell.Hyprland
import qs.Ui

// Bar indicator for a Hyprland special workspace (the "scratchpad").
// Dimmed when empty, highlighted while shown, with a window count and a
// tooltip listing what is stashed there.
BarWidget {
  id: root
  moduleName: "imranzero.scratchpad"

  // Strip quotes so a user-supplied name can't break the Lua expression.
  readonly property string workspaceName: String(setting("workspace", "scratchpad")).replace(/["'\\]/g, "")
  readonly property string specialName: "special:" + workspaceName
  readonly property string glyph: String(setting("glyph", "☷"))
  readonly property bool showCount: setting("showCount", true) === true
  readonly property bool hideWhenEmpty: setting("hideWhenEmpty", false) === true
  readonly property string customActiveColor: String(setting("activeColor", ""))

  readonly property var workspace: {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].name === specialName) return values[i]
    }
    return null
  }

  readonly property var windows: workspace ? workspace.toplevels.values : []
  readonly property int count: windows.length

  readonly property bool shown: {
    var monitors = Hyprland.monitors.values
    for (var i = 0; i < monitors.length; i++) {
      var ipc = monitors[i].lastIpcObject
      if (ipc && ipc.specialWorkspace && ipc.specialWorkspace.name === specialName) return true
    }
    return false
  }

  readonly property string tooltip: {
    if (count === 0) return "Scratchpad — empty"
    var lines = ["Scratchpad (" + count + ")"]
    for (var i = 0; i < windows.length; i++) {
      var w = windows[i]
      var ipc = w.lastIpcObject
      lines.push("• " + (w.title || (ipc && ipc["class"]) || "untitled"))
    }
    return lines.join("\n")
  }

  function dispatch(expression) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch_lua_expression '" + expression + "'")
  }

  function toggle() {
    dispatch('hl.dsp.workspace.toggle_special("' + workspaceName + '")')
  }

  function stashFocused() {
    dispatch('hl.dsp.window.move({ workspace = "' + specialName + '", follow = false })')
  }

  // Scroll opens the scratchpad first, then cycles focus through its windows.
  property double lastWheel: 0
  function cycle(delta) {
    var now = Date.now()
    if (now - lastWheel < 150) return
    lastWheel = now
    if (count === 0) return
    if (!shown) toggle()
    else dispatch("hl.dsp.window.cycle_next({ next = " + (delta < 0 ? "true" : "false") + " })")
  }

  // Monitor IPC objects (which carry specialWorkspace) aren't pushed on
  // special-workspace changes, so re-query them when one happens.
  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (event.name === "activespecial" || event.name === "activespecialv2"
          || event.name === "focusedmon" || event.name === "closewindow"
          || event.name === "movewindow" || event.name === "movewindowv2")
        Hyprland.refreshMonitors()
      if (event.name === "openwindow" || event.name === "windowtitle" || event.name === "windowtitlev2")
        Hyprland.refreshToplevels()
    }
  }

  Component.onCompleted: Hyprland.refreshMonitors()

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.glyph + (root.showCount && root.count > 1 ? " " + root.count : "")
    dimmed: root.count === 0
    concealed: root.hideWhenEmpty && root.count === 0
    active: root.shown
    activeColor: root.customActiveColor !== "" ? root.customActiveColor
      : (root.bar ? root.bar.urgent : "#ffb454")
    tooltipText: root.tooltip
    horizontalMargin: 7.5
    onPressed: function(mouseButton) {
      if (mouseButton === Qt.RightButton) root.stashFocused()
      else if (mouseButton === Qt.LeftButton) root.toggle()
    }
    onWheelMoved: function(delta) { root.cycle(delta) }
  }
}
