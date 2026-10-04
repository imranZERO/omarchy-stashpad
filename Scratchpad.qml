import QtQuick
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

// Bar indicator for a Hyprland special workspace (the "scratchpad").
// Dimmed when empty, highlighted while shown, with a count badge. Right click
// opens a menu to stash windows from the current workspace or bring them back.
BarWidget {
  id: root
  moduleName: "imranzero.scratchpad"

  // Strip quotes so a user-supplied name can't break the Lua expression.
  readonly property string workspaceName: String(setting("workspace", "scratchpad")).replace(/["'\\]/g, "")
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

  property bool menuOpen: false

  function open() { menuOpen = true }
  function close() { menuOpen = false }

  function dispatch(expression) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch_lua_expression '" + expression + "'")
  }

  function toggle() {
    dispatch('hl.dsp.workspace.toggle_special("' + workspaceName + '")')
  }

  function selector(toplevel) {
    var address = String(toplevel.address).replace(/[^0-9a-fA-Fx]/g, "")
    return "address:" + (address.indexOf("0x") === 0 ? address : "0x" + address)
  }

  function stash(toplevel) {
    dispatch('hl.dsp.window.move({ workspace = "' + specialName + '", window = "' + selector(toplevel) + '", follow = false })')
  }

  function release(toplevel) {
    var target = currentWorkspace
    if (!target) return
    var id = target.id > 0 ? String(target.id) : "name:" + String(target.name).replace(/["'\\]/g, "")
    dispatch('hl.dsp.window.move({ workspace = "' + id + '", window = "' + selector(toplevel) + '", follow = false })')
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

  onMenuOpenChanged: if (menuOpen) { Hyprland.refreshToplevels(); Hyprland.refreshWorkspaces() }

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
    tooltipText: root.count === 0 ? "Scratchpad — empty"
      : "Scratchpad — " + root.count + (root.count === 1 ? " window" : " windows")

    iconComponent: Component {
      ScratchpadIcon {
        color: button.active ? button.activeColor : button.foreground
        badgeCount: root.showCount ? root.count : 0
      }
    }

    onPressed: function(mouseButton) {
      if (mouseButton === Qt.RightButton) root.menuOpen = !root.menuOpen
      else if (mouseButton === Qt.LeftButton) { root.close(); root.toggle() }
    }
    onWheelMoved: function(delta) { root.cycle(delta) }
  }

  PopupCard {
    id: popup
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.menuOpen
    padding: Style.space(8)
    contentWidth: popup.fittedContentWidth(Style.space(300))
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

        Text {
          text: "In scratchpad"
          color: Qt.rgba(Color.popups.text.r, Color.popups.text.g, Color.popups.text.b, 0.6)
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
          font.bold: true
          leftPadding: Style.space(8)
          topPadding: Style.space(2)
          bottomPadding: Style.space(2)
        }

        Text {
          visible: root.count === 0
          text: "Nothing here yet"
          color: Qt.rgba(Color.popups.text.r, Color.popups.text.g, Color.popups.text.b, 0.45)
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
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
            fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
            onActivated: root.release(modelData)
          }
        }

        Rectangle {
          width: menuColumn.width
          height: 1
          color: Qt.rgba(Color.popups.text.r, Color.popups.text.g, Color.popups.text.b, 0.15)
        }

        Text {
          text: "On this workspace"
          color: Qt.rgba(Color.popups.text.r, Color.popups.text.g, Color.popups.text.b, 0.6)
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
          font.bold: true
          leftPadding: Style.space(8)
          topPadding: Style.space(6)
          bottomPadding: Style.space(2)
        }

        Text {
          visible: root.currentWindows.length === 0
          text: "No windows"
          color: Qt.rgba(Color.popups.text.r, Color.popups.text.g, Color.popups.text.b, 0.45)
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
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
            fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
            onActivated: root.stash(modelData)
          }
        }
      }
    }
  }
}
