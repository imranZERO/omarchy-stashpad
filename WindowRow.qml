import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

// One window in the Stashpad menu: app icon, title and class, then a close
// button and a +/- button. Clicking the row itself focuses the window.
// "+" stashes the window, "-" brings it back.
Item {
  id: root

  property var toplevel: null
  property bool stashed: false
  property color foreground: Color.popups.text
  property color accent: Color.accent
  property string fontFamily: Style.font.family
  property string actionTooltip: ""
  property string closeTooltip: "Close window"

  signal activated()
  signal focusRequested()
  signal closeRequested()

  readonly property var ipc: toplevel ? toplevel.lastIpcObject : null
  readonly property string windowClass: ipc && ipc["class"] ? String(ipc["class"]) : ""
  readonly property string windowTitle: toplevel && toplevel.title ? String(toplevel.title) : (windowClass || "untitled")
  readonly property bool urgent: toplevel ? toplevel.urgent === true : false

  // Referencing the model is what makes Quickshell load desktop entries; it
  // also re-runs iconSource once they arrive.
  readonly property var apps: DesktopEntries.applications

  // Window class -> desktop entry -> themed icon, falling back to a generic one.
  readonly property string iconSource: {
    if (apps.values.length === 0) return Quickshell.iconPath("application-x-executable", true)
    var generic = Quickshell.iconPath("application-x-executable", true)
    if (windowClass === "") return generic
    var entry = DesktopEntries.heuristicLookup(windowClass)
    var name = entry && entry.icon ? String(entry.icon) : windowClass
    if (name.charAt(0) === "/") return "file://" + name
    var themed = Quickshell.iconPath(name, true)
    if (themed.length > 0) return themed
    themed = Quickshell.iconPath(windowClass.toLowerCase(), true)
    return themed.length > 0 ? themed : generic
  }

  // Text colour that stays readable on a given fill.
  function contrastOn(fill) {
    var luminance = 0.299 * fill.r + 0.587 * fill.g + 0.114 * fill.b
    return luminance > 0.55 ? "#101010" : "#ffffff"
  }

  implicitHeight: Style.space(34)
  implicitWidth: Style.space(320)

  Rectangle {
    anchors.fill: parent
    radius: Style.cornerRadius
    color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, rowHover.hovered ? 0.08 : 0)
  }

  HoverHandler { id: rowHover }

  // Declared first so the buttons, declared later, sit on top and win clicks.
  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: root.focusRequested()
  }

  Image {
    id: appIcon
    anchors.left: parent.left
    anchors.leftMargin: Style.space(8)
    anchors.verticalCenter: parent.verticalCenter
    width: Style.space(20)
    height: Style.space(20)
    source: root.iconSource
    // Decode at physical pixels so the icon stays sharp on scaled displays.
    sourceSize: Qt.size(width * 2, height * 2)
    fillMode: Image.PreserveAspectFit
    asynchronous: true
    smooth: true
  }

  // A window asking for attention.
  Rectangle {
    visible: root.urgent
    width: Style.space(8)
    height: width
    radius: width / 2
    color: Color.urgent
    border.width: 1
    border.color: Color.popups.background
    anchors.horizontalCenter: appIcon.right
    anchors.verticalCenter: appIcon.top
  }

  Column {
    anchors.left: appIcon.right
    anchors.leftMargin: Style.space(8)
    anchors.right: rowHover.hovered ? closeButton.left : parent.right
    anchors.rightMargin: Style.space(8)
    anchors.verticalCenter: parent.verticalCenter
    spacing: 0

    Text {
      width: parent.width
      text: root.windowTitle
      color: root.foreground
      elide: Text.ElideRight
      textFormat: Text.PlainText
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
    }

    Text {
      visible: root.windowClass !== "" && root.windowClass !== root.windowTitle
      width: parent.width
      text: root.windowClass
      color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.55)
      elide: Text.ElideRight
      textFormat: Text.PlainText
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
    }
  }

  component RowButton: Rectangle {
    id: btn

    property string glyph: ""
    property string tip: ""
    property color hoverColor: root.accent

    signal clicked()

    // Only shown while the pointer is over the row.
    visible: rowHover.hovered

    width: Style.space(24)
    height: Style.space(24)
    radius: Style.cornerRadius
    color: buttonMouse.containsMouse ? hoverColor : "transparent"
    border.width: 1
    border.color: buttonMouse.containsMouse ? hoverColor
      : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.35)

    Text {
      anchors.centerIn: parent
      text: btn.glyph
      color: buttonMouse.containsMouse ? root.contrastOn(btn.hoverColor) : root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.title
      renderType: Text.NativeRendering
    }

    MouseArea {
      id: buttonMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: btn.clicked()
    }

    PanelToolTip {
      visible: btn.tip !== "" && buttonMouse.containsMouse
      text: btn.tip
      fontFamily: root.fontFamily
    }
  }

  RowButton {
    id: closeButton
    anchors.right: moveButton.left
    anchors.rightMargin: Style.space(4)
    anchors.verticalCenter: parent.verticalCenter
    glyph: "×"
    tip: root.closeTooltip
    hoverColor: Color.urgent
    onClicked: root.closeRequested()
  }

  RowButton {
    id: moveButton
    anchors.right: parent.right
    anchors.rightMargin: Style.space(4)
    anchors.verticalCenter: parent.verticalCenter
    glyph: root.stashed ? "↩" : "+"
    tip: root.actionTooltip
    onClicked: root.activated()
  }
}
