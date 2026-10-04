import QtQuick
import QtQuick.Shapes
import qs.Commons

// Vector scratchpad icon: a window with a title bar and a drawer handle.
// Drawn from paths so it follows the bar colour at any size. An optional
// badge sits on the top-right corner to show how many windows are stashed.
Item {
  id: root

  property color color: Color.foreground
  property color badgeTextColor: Color.background
  property int badgeCount: 0

  readonly property real size: Math.min(width, height)
  readonly property real stroke: Math.max(1, Math.round(size / 11))
  readonly property real inset: stroke / 2 + 0.5

  Shape {
    anchors.centerIn: parent
    width: root.size
    height: root.size
    antialiasing: true
    layer.enabled: true
    layer.samples: 4

    // Window frame.
    ShapePath {
      id: frame
      strokeColor: root.color
      strokeWidth: root.stroke
      fillColor: "transparent"
      capStyle: ShapePath.RoundCap
      joinStyle: ShapePath.RoundJoin

      readonly property real r: root.size * 0.2
      readonly property real l: root.inset
      readonly property real t: root.size * 0.1 + root.inset
      readonly property real rt: root.size - root.inset
      readonly property real b: root.size * 0.92 - root.inset

      startX: frame.l + frame.r; startY: frame.t
      PathLine { x: frame.rt - frame.r; y: frame.t }
      PathArc { x: frame.rt; y: frame.t + frame.r; radiusX: frame.r; radiusY: frame.r }
      PathLine { x: frame.rt; y: frame.b - frame.r }
      PathArc { x: frame.rt - frame.r; y: frame.b; radiusX: frame.r; radiusY: frame.r }
      PathLine { x: frame.l + frame.r; y: frame.b }
      PathArc { x: frame.l; y: frame.b - frame.r; radiusX: frame.r; radiusY: frame.r }
      PathLine { x: frame.l; y: frame.t + frame.r }
      PathArc { x: frame.l + frame.r; y: frame.t; radiusX: frame.r; radiusY: frame.r }
    }

    // Title bar divider.
    ShapePath {
      strokeColor: root.color
      strokeWidth: root.stroke
      capStyle: ShapePath.RoundCap
      startX: root.inset; startY: root.size * 0.38
      PathLine { x: root.size - root.inset; y: root.size * 0.38 }
    }

    // Drawer handle.
    ShapePath {
      strokeColor: root.color
      strokeWidth: root.stroke
      capStyle: ShapePath.RoundCap
      startX: root.size * 0.36; startY: root.size * 0.64
      PathLine { x: root.size * 0.64; y: root.size * 0.64 }
    }
  }

  Rectangle {
    id: badge
    visible: root.badgeCount > 0
    readonly property real d: Math.round(root.size * 0.58)
    width: Math.max(d, countText.implicitWidth + root.size * 0.22)
    height: d
    radius: height / 2
    color: root.color
    // Pull the badge out past the frame corner.
    x: root.width / 2 + root.size / 2 - width * 0.62
    y: root.height / 2 - root.size / 2 - height * 0.22

    Text {
      id: countText
      anchors.centerIn: parent
      text: root.badgeCount > 9 ? "9+" : String(root.badgeCount)
      color: root.badgeTextColor
      font.pixelSize: Math.round(root.size * 0.4)
      font.bold: true
      renderType: Text.NativeRendering
    }
  }
}
