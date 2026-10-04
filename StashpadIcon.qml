import QtQuick
import QtQuick.Shapes
import qs.Commons

// Vector scratchpad icon: a window with a title bar and a drawer handle.
// Drawn from paths so it follows the bar colour at any size. An optional
// badge sits on the top-right corner to show how many windows are stashed.
Item {
  id: root

  property color color: Color.foreground
  property int badgeCount: 0
  // A stashed window wants attention: the badge takes this colour.
  property bool attention: false
  property color attentionColor: Color.urgent

  readonly property real size: Math.min(width, height)
  // The badge is filled with the icon colour (or the attention colour), so the
  // digit takes whichever of near-black or near-white contrasts with it. Theme
  // colours can't be used: on a transparent bar the icon and the theme
  // background can both be light.
  readonly property color badgeFill: attention ? attentionColor : color
  readonly property real luminance: 0.299 * badgeFill.r + 0.587 * badgeFill.g + 0.114 * badgeFill.b
  readonly property color badgeTextColor: luminance > 0.55 ? "#101010" : "#ffffff"

  readonly property real stroke: Math.max(1, Math.round(size / 11))
  readonly property real inset: stroke / 2 + 0.5
  // Horizontal margin that narrows the frame.
  readonly property real side: size * 0.07

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
      readonly property real l: root.side + root.inset
      readonly property real t: root.size * 0.1 + root.inset
      readonly property real rt: root.size - root.side - root.inset
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
      startX: frame.l; startY: root.size * 0.38
      PathLine { x: frame.rt; y: root.size * 0.38 }
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
    readonly property real d: Math.round(root.size * 0.64)
    width: Math.max(d, countText.implicitWidth + root.size * 0.22)
    height: d
    radius: height / 2
    color: root.badgeFill

    // Pull the badge out past the frame corner.
    x: root.width / 2 + root.size / 2 - root.side - width * 0.55
    y: root.height / 2 - root.size / 2 - height * 0.22

    TextMetrics {
      id: countMetrics
      font: countText.font
      text: countText.text
    }

    // Centre the painted digits, not the line box (which carries ascent and
    // descent space). Font metrics round to whole pixels, so the text is laid
    // out at twice the size and scaled down: the rounding error halves.
    Text {
      id: countText
      readonly property real shrink: 0.5
      readonly property real inkX: countMetrics.tightBoundingRect.x + countMetrics.tightBoundingRect.width / 2
      readonly property real inkY: baselineOffset + countMetrics.tightBoundingRect.y + countMetrics.tightBoundingRect.height / 2
      x: badge.width / 2 - width / 2 - shrink * (inkX - width / 2)
      y: badge.height / 2 - height / 2 - shrink * (inkY - height / 2)
      scale: shrink
      transformOrigin: Item.Center
      text: root.badgeCount > 9 ? "9+" : String(root.badgeCount)
      color: root.badgeTextColor
      font.pixelSize: Math.round(root.size * 0.44) / shrink
      font.bold: true
      renderType: Text.QtRendering
    }
  }
}
