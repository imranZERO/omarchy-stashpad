import QtQuick
import qs.Commons

// One window in the scratchpad menu: title and class on the left, a +/- button
// on the right. "+" stashes the window, "-" brings it back.
Item {
  id: root

  property var toplevel: null
  property bool stashed: false
  property color foreground: Color.popups.text
  property color accent: Color.accent
  property string fontFamily: Style.font.family

  signal activated()

  readonly property var ipc: toplevel ? toplevel.lastIpcObject : null
  readonly property string windowClass: ipc && ipc["class"] ? String(ipc["class"]) : ""
  readonly property string windowTitle: toplevel && toplevel.title ? String(toplevel.title) : (windowClass || "untitled")

  implicitHeight: Style.space(34)
  implicitWidth: Style.space(280)

  Rectangle {
    anchors.fill: parent
    radius: Style.cornerRadius
    color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, rowHover.hovered ? 0.08 : 0)
  }

  HoverHandler { id: rowHover }

  Column {
    anchors.left: parent.left
    anchors.leftMargin: Style.space(8)
    anchors.right: button.left
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

  Rectangle {
    id: button
    anchors.right: parent.right
    anchors.rightMargin: Style.space(4)
    anchors.verticalCenter: parent.verticalCenter
    width: Style.space(24)
    height: Style.space(24)
    radius: Style.cornerRadius
    color: buttonMouse.containsMouse ? root.accent : "transparent"
    border.width: 1
    border.color: buttonMouse.containsMouse ? root.accent
      : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.35)

    Text {
      anchors.centerIn: parent
      text: root.stashed ? "−" : "+"
      color: buttonMouse.containsMouse ? Color.background : root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.title
      renderType: Text.NativeRendering
    }

    MouseArea {
      id: buttonMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: root.activated()
    }
  }
}
