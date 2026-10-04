import QtQuick
import qs.Commons
import qs.Ui

// Menu section title with an optional text action on the right
// ("Restore all", "Stash all").
Item {
  id: root

  property string title: ""
  property string actionText: ""
  property string actionTooltip: ""
  property color foreground: Color.popups.text
  property color accent: Color.accent
  property string fontFamily: Style.font.family

  signal actionClicked()

  implicitHeight: Style.space(24)
  implicitWidth: Style.space(280)

  Text {
    anchors.left: parent.left
    anchors.leftMargin: Style.space(8)
    anchors.right: action.visible ? action.left : parent.right
    anchors.rightMargin: Style.space(8)
    anchors.verticalCenter: parent.verticalCenter
    text: root.title
    color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.6)
    elide: Text.ElideRight
    textFormat: Text.PlainText
    font.family: root.fontFamily
    font.pixelSize: Style.font.caption
    font.bold: true
  }

  Text {
    id: action
    visible: root.actionText !== ""
    anchors.right: parent.right
    anchors.rightMargin: Style.space(8)
    anchors.verticalCenter: parent.verticalCenter
    text: root.actionText
    color: actionMouse.containsMouse ? root.accent
      : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.7)
    font.family: root.fontFamily
    font.pixelSize: Style.font.caption
    font.underline: actionMouse.containsMouse

    MouseArea {
      id: actionMouse
      anchors.fill: parent
      anchors.margins: -Style.space(4)
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: root.actionClicked()
    }

    PanelToolTip {
      visible: root.actionTooltip !== "" && actionMouse.containsMouse
      text: root.actionTooltip
      fontFamily: root.fontFamily
    }
  }
}
