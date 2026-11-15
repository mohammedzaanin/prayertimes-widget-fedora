import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    id: root

    property string prayerName: "--"
    property string prayerTime: "--:--"
    property string remaining: "--:--"
    property bool showIcon: true
    property string panelMode: "horizontal"
    property bool hovered: false

    signal activated()

    function prayerClockText() {
        var parts = root.prayerTime.split(" ")
        return parts.length > 1 ? parts[0] : root.prayerTime
    }

    function prayerPeriodText() {
        var parts = root.prayerTime.split(" ")
        return parts.length > 1 ? parts[1] : ""
    }

    implicitWidth: panelMode === "vertical" ? 82 : panelMode === "compact" ? 220 : 230
    implicitHeight: panelMode === "vertical" ? 78 : 36
    Layout.minimumWidth: panelMode === "vertical" ? 74 : 220
    Layout.minimumHeight: panelMode === "vertical" ? 72 : 32
    clip: true

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: root.hovered ? "#243044" : "#1b2433"
        border.color: "#334155"
        border.width: 1
    }

    Rectangle {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - 16, 78)
        height: 3
        radius: 2
        color: "#38bdf8"
        visible: root.panelMode !== "vertical"
    }

    RowLayout {
        anchors.centerIn: parent
        width: Math.max(0, parent.width - 1)
        height: Math.max(24, parent.height - 8)
        spacing: 4
        layoutDirection: Qt.RightToLeft
        visible: root.panelMode !== "vertical"

        Item {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
        }

        Image {
            source: "../images/mosque-svgrepo-com.svg"
            visible: root.showIcon
            sourceSize.width: 16
            sourceSize.height: 16
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            fillMode: Image.PreserveAspectFit
        }

        PlasmaComponents.Label {
            text: root.prayerName
            Layout.minimumWidth: 34
            Layout.maximumWidth: 44
            horizontalAlignment: Text.AlignLeft
            elide: Text.ElideRight
            font.weight: Font.DemiBold
            color: "#f8fafc"
        }

        PlasmaComponents.Label {
            text: root.prayerClockText()
            horizontalAlignment: Text.AlignLeft
            elide: Text.ElideRight
            Layout.preferredWidth: 50
            font.family: "monospace"
            font.weight: Font.DemiBold
            color: "#f8c35d"
            font.pointSize: Math.max(8, Kirigami.Theme.smallFont.pointSize)
        }

        PlasmaComponents.Label {
            text: root.prayerPeriodText()
            visible: text.length > 0
            horizontalAlignment: Text.AlignLeft
            Layout.preferredWidth: 22
            font.family: "monospace"
            font.weight: Font.DemiBold
            color: "#f8c35d"
            font.pointSize: Math.max(8, Kirigami.Theme.smallFont.pointSize)
        }

        PlasmaComponents.Label {
            text: "|"
            horizontalAlignment: Text.AlignHCenter
            Layout.preferredWidth: 6
            color: "#64748b"
            font.weight: Font.DemiBold
            font.pointSize: Math.max(8, Kirigami.Theme.smallFont.pointSize)
        }

        PlasmaComponents.Label {
            text: root.remaining
            horizontalAlignment: Text.AlignLeft
            elide: Text.ElideRight
            Layout.preferredWidth: 44
            color: "#cbd5e1"
            font.pointSize: Math.max(8, Kirigami.Theme.smallFont.pointSize)
        }

        Item {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.max(0, parent.width - 18)
        spacing: 2
        visible: root.panelMode === "vertical"

        Image {
            source: "../images/mosque-svgrepo-com.svg"
            visible: root.showIcon && root.panelMode === "vertical"
            sourceSize.width: 16
            sourceSize.height: 16
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            fillMode: Image.PreserveAspectFit
        }

        PlasmaComponents.Label {
            text: root.prayerName + "  " + root.prayerTime
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            font.weight: Font.DemiBold
            color: "#f8fafc"
        }

        PlasmaComponents.Label {
            text: root.remaining
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            color: "#cbd5e1"
            font.pointSize: Math.max(7, Kirigami.Theme.smallFont.pointSize)
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: root.activated()
    }
}
