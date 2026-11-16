import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    id: root

    property string title: ""
    property string time: "--:--"
    property bool highlighted: false
    property bool rtl: false
    property string fontFamily: "Cairo"
    property color textColor: Kirigami.Theme.textColor
    property color mutedColor: Kirigami.Theme.disabledTextColor
    property color accentColor: Kirigami.Theme.highlightColor
    property color highlightedBackground: Kirigami.Theme.highlightColor

    implicitHeight: 38
    Layout.preferredHeight: 38
    Layout.fillWidth: true

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: root.highlighted ? root.highlightedBackground : "transparent"
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 10
        layoutDirection: root.rtl ? Qt.RightToLeft : Qt.LeftToRight

        PlasmaComponents.Label {
            id: label
            text: root.title
            Layout.fillWidth: true
            horizontalAlignment: root.rtl ? Text.AlignRight : Text.AlignLeft
            elide: Text.ElideRight
            color: root.highlighted ? root.textColor : root.mutedColor
            font.family: root.fontFamily
            font.weight: root.highlighted ? Font.DemiBold : Font.Normal
        }

        PlasmaComponents.Label {
            text: root.time
            horizontalAlignment: Text.AlignLeft
            color: root.highlighted ? root.textColor : root.mutedColor
            font.family: root.fontFamily
            font.weight: root.highlighted ? Font.DemiBold : Font.Normal
            LayoutMirroring.enabled: false
        }
    }
}
