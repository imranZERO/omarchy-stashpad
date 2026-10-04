import QtQuick
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

// Bar indicator for a Hyprland special workspace (the "scratchpad").
// Dimmed when empty, highlighted while shown, with a count badge that turns
// urgent when a stashed window wants attention. Right click opens a menu to
// stash windows from the current workspace, bring them back, focus or close them.
BarWidget {
  id: root
  moduleName: "imranzero.stashpad"

  readonly property string workspaceName: String(setting("workspace", "scratchpad"))
  readonly property string specialName: "special:" + workspaceName
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

  readonly property var stashedWindows: workspace ? workspace.toplevels.values : []
  readonly property int count: stashedWindows.length

  // The regular workspace under the scratchpad on the focused monitor.
  readonly property var currentWorkspace: {
    var monitor = Hyprland.focusedMonitor
    var active = monitor ? monitor.activeWorkspace : null
    if (active && active.name.indexOf("special:") !== 0) return active
    var focused = Hyprland.focusedWorkspace
    return focused && focused.name.indexOf("special:") !== 0 ? focused : null
  }
  readonly property var currentWindows: currentWorkspace ? currentWorkspace.toplevels.values : []

  readonly property bool shown: {
    var monitors = Hyprland.monitors.values
    for (var i = 0; i < monitors.length; i++) {
      var ipc = monitors[i].lastIpcObject
      if (ipc && ipc.specialWorkspace && ipc.specialWorkspace.name === specialName) return true
    }
    return false
  }

  // A stashed window is asking for attention while the scratchpad is hidden.
  readonly property bool attention: {
    if (shown) return false
    for (var i = 0; i < stashedWindows.length; i++) {
      if (stashedWindows[i].urgent === true) return true
    }
    return false
  }

  property bool menuOpen: false

  function close() { menuOpen = false }

  // Run one or more Hyprland Lua expressions through hyprctl. They are chained
  // as separate commands, since one expression can't hold several dispatches.
  function dispatchAll(expressions) {
    if (!root.bar || expressions.length === 0) return
    var commands = []
    for (var i = 0; i < expressions.length; i++)
      commands.push("hyprctl dispatch_lua_expression '" + expressions[i] + "'")
    root.bar.run(commands.join(" ; "))
  }

  function dispatch(expression) { dispatchAll([expression]) }

  // Hyprland reports addresses without the 0x prefix that dispatchers expect.
  function selector(toplevel) { return "address:0x" + toplevel.address }

  function currentSelector() {
    var target = currentWorkspace
    if (!target) return ""
    return target.id > 0 ? String(target.id) : "name:" + target.name
  }

  function moveExpression(toplevel, workspaceSelector) {
    return 'hl.dsp.window.move({ workspace = "' + workspaceSelector + '", window = "' + selector(toplevel) + '", follow = false })'
  }

  function toggle() {
    dispatch('hl.dsp.workspace.toggle_special("' + workspaceName + '")')
  }

  // Middle click: stash whichever window has focus.
  function stashFocused() {
    dispatch('hl.dsp.window.move({ workspace = "' + specialName + '", follow = false })')
  }

  function stash(toplevel) { dispatch(moveExpression(toplevel, specialName)) }

  function release(toplevel) {
    var target = currentSelector()
    if (target !== "") dispatch(moveExpression(toplevel, target))
  }

  function stashAll() {
    var expressions = []
    for (var i = 0; i < currentWindows.length; i++)
      expressions.push(moveExpression(currentWindows[i], specialName))
    dispatchAll(expressions)
  }

  function releaseAll(windows) {
    var target = currentSelector()
    if (target === "") return
    var expressions = []
    for (var i = 0; i < windows.length; i++)
      expressions.push(moveExpression(windows[i], target))
    dispatchAll(expressions)
  }

  // Focusing a window inside a special workspace also reveals that workspace.
  function focusWindow(toplevel) {
    close()
    dispatch('hl.dsp.focus({ window = "' + selector(toplevel) + '" })')
  }

  function closeWindow(toplevel) {
    dispatch('hl.dsp.window.close({ window = "' + selector(toplevel) + '" })')
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
      if (event.name === "openwindow" || event.name === "windowtitle" || event.name === "windowtitlev2"
          || event.name === "movewindow" || event.name === "movewindowv2")
        Hyprland.refreshToplevels()
    }
  }

  Component.onCompleted: Hyprland.refreshMonitors()

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    dimmed: root.count === 0
    concealed: root.hideWhenEmpty && root.count === 0
    active: root.shown
    activeColor: root.customActiveColor !== "" ? root.customActiveColor
      : (root.bar ? root.bar.urgent : Color.accent)
    tooltipText: root.count === 0 ? "Stashpad — empty"
      : "Stashpad — " + root.count + (root.count === 1 ? " window" : " windows")
        + (root.attention ? " (needs attention)" : "")

    iconComponent: Component {
      StashpadIcon {
        color: button.active ? button.activeColor : button.foreground
        badgeCount: root.showCount ? root.count : 0
        attention: root.attention
        attentionColor: root.bar ? root.bar.urgent : Color.urgent
      }
    }

    onPressed: function(mouseButton) {
      if (mouseButton === Qt.RightButton) root.menuOpen = !root.menuOpen
      else if (mouseButton === Qt.MiddleButton) root.stashFocused()
      else if (mouseButton === Qt.LeftButton) { root.close(); root.toggle() }
    }
  }

  PopupCard {
    id: popup
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.menuOpen
    padding: Style.space(8)
    contentWidth: popup.fittedContentWidth(Style.space(360))
    contentHeight: popup.fittedContentHeight(menuColumn.implicitHeight, Style.space(520))

    Flickable {
      anchors.fill: parent
      contentWidth: width
      contentHeight: menuColumn.implicitHeight
      clip: true
      boundsBehavior: Flickable.StopAtBounds

      Column {
        id: menuColumn
        width: parent.width
        spacing: Style.space(2)

        readonly property color dimText: Qt.rgba(Color.popups.text.r, Color.popups.text.g, Color.popups.text.b, 0.45)
        readonly property color ruleColor: Qt.rgba(Color.popups.text.r, Color.popups.text.g, Color.popups.text.b, 0.15)

        SectionHeader {
          width: menuColumn.width
          title: "In " + root.workspaceName
          actionText: root.count > 1 ? "Restore all" : ""
          actionTooltip: "Bring every stashed window back to this workspace"
          onActionClicked: root.releaseAll(root.stashedWindows)
        }

        Text {
          visible: root.count === 0
          text: "Nothing here yet"
          color: menuColumn.dimText
          font.family: Style.font.family
          font.pixelSize: Style.font.body
          leftPadding: Style.space(8)
          bottomPadding: Style.space(4)
        }

        Repeater {
          model: root.stashedWindows
          delegate: WindowRow {
            required property var modelData
            width: menuColumn.width
            toplevel: modelData
            stashed: true
            actionTooltip: "Bring back to this workspace"
            onActivated: root.release(modelData)
            onFocusRequested: root.focusWindow(modelData)
            onCloseRequested: root.closeWindow(modelData)
          }
        }

        Rectangle {
          width: menuColumn.width
          height: 1
          color: menuColumn.ruleColor
        }

        SectionHeader {
          width: menuColumn.width
          title: "On this workspace"
          actionText: root.currentWindows.length > 1 ? "Stash all" : ""
          actionTooltip: "Send every window on this workspace to " + root.workspaceName
          onActionClicked: root.stashAll()
        }

        Text {
          visible: root.currentWindows.length === 0
          text: "No windows"
          color: menuColumn.dimText
          font.family: Style.font.family
          font.pixelSize: Style.font.body
          leftPadding: Style.space(8)
          bottomPadding: Style.space(4)
        }

        Repeater {
          model: root.currentWindows
          delegate: WindowRow {
            required property var modelData
            width: menuColumn.width
            toplevel: modelData
            stashed: false
            actionTooltip: "Send to " + root.workspaceName
            onActivated: root.stash(modelData)
            onFocusRequested: root.focusWindow(modelData)
            onCloseRequested: root.closeWindow(modelData)
          }
        }
      }
    }
  }
}
