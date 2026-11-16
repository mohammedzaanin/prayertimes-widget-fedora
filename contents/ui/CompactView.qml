import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    id: root

    property string prayerName: "--"
    property string prayerTime: "--:--"
    property string remaining: "--:--"
    property string language: "en"
    property string themeMode: "system"
    readonly property bool isRtl: language === "ar"
    readonly property string fontFamily: "Cairo"
    readonly property bool followsSystemTheme: themeMode === "system"
    readonly property bool lightPalette: themeMode === "light"
                                         || (followsSystemTheme
                                             && colorLuminance(Kirigami.Theme.backgroundColor) > 0.55)
    readonly property color panelColor: followsSystemTheme
                                        ? Kirigami.Theme.backgroundColor
                                        : (lightPalette ? "#f8fafc" : "#1b2433")
    readonly property color hoverColor: followsSystemTheme
                                        ? Kirigami.Theme.alternateBackgroundColor
                                        : (lightPalette ? "#e2e8f0" : "#243044")
    readonly property color borderColor: followsSystemTheme
                                         ? alphaColor(Kirigami.Theme.disabledTextColor, 0.38)
                                         : (lightPalette ? "#cbd5e1" : "#334155")
    readonly property color accentColor: followsSystemTheme
                                         ? Kirigami.Theme.highlightColor
                                         : (lightPalette ? "#0284c7" : "#38bdf8")
    readonly property color textColor: followsSystemTheme
                                       ? Kirigami.Theme.textColor
                                       : (lightPalette ? "#0f172a" : "#f8fafc")
    readonly property color mutedTextColor: followsSystemTheme
                                            ? Kirigami.Theme.disabledTextColor
                                            : (lightPalette ? "#475569" : "#cbd5e1")
    readonly property color goldColor: lightPalette ? "#a16207" : "#f8c35d"
    readonly property color separatorColor: lightPalette ? "#64748b" : "#64748b"
    property bool showIcon: true
    property string panelMode: "horizontal"
    property bool hovered: false

    signal activated()

    function colorLuminance(colorValue) {
        return 0.2126 * colorValue.r + 0.7152 * colorValue.g + 0.0722 * colorValue.b
    }

    function alphaColor(colorValue, opacity) {
        return Qt.rgba(colorValue.r, colorValue.g, colorValue.b, opacity)
    }

    function prayerClockText() {
        var parts = root.prayerTime.trim().split(/\s+/)
        return parts.length > 0 ? parts[0] : root.prayerTime
    }

    function prayerPeriodText() {
        var parts = root.prayerTime.trim().split(/\s+/)
        return parts.length > 1 ? parts.slice(1).join(" ") : ""
    }

    implicitWidth: panelMode === "vertical" ? 82 : panelMode === "compact" ? 220 : 230
    implicitHeight: panelMode === "vertical" ? 78 : 36
    Layout.minimumWidth: panelMode === "vertical" ? 74 : 220
    Layout.minimumHeight: panelMode === "vertical" ? 72 : 32
    clip: true

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: root.hovered ? root.hoverColor : root.panelColor
        border.color: root.borderColor
        border.width: 1
    }

    Rectangle {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - 16, 78)
        height: 3
        radius: 2
        color: root.accentColor
        visible: root.panelMode !== "vertical"
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        spacing: 6
        layoutDirection: root.isRtl ? Qt.RightToLeft : Qt.LeftToRight
        visible: root.panelMode !== "vertical"

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
            Layout.minimumWidth: 44
            Layout.fillWidth: true
            horizontalAlignment: root.isRtl ? Text.AlignRight : Text.AlignLeft
            elide: Text.ElideRight
            font.family: root.fontFamily
            font.pixelSize: 14
            font.weight: Font.DemiBold
            color: root.textColor
        }

        RowLayout {
            spacing: 2
            layoutDirection: Qt.LeftToRight
            LayoutMirroring.enabled: false

            PlasmaComponents.Label {
                text: root.isRtl ? root.prayerPeriodText() : root.prayerClockText()
                visible: text.length > 0
                font.family: root.fontFamily
                font.pixelSize: 14
                font.weight: Font.DemiBold
                color: root.goldColor
                LayoutMirroring.enabled: false
            }

            PlasmaComponents.Label {
                text: root.isRtl ? root.prayerClockText() : root.prayerPeriodText()
                visible: text.length > 0
                font.family: root.fontFamily
                font.pixelSize: 14
                font.weight: Font.DemiBold
                color: root.goldColor
                LayoutMirroring.enabled: false
            }
        }

        PlasmaComponents.Label {
            text: "|"
            horizontalAlignment: Text.AlignHCenter
            Layout.preferredWidth: 6
            color: root.separatorColor
            font.family: root.fontFamily
            font.weight: Font.DemiBold
            font.pixelSize: 13
        }

        PlasmaComponents.Label {
            text: root.remaining
            horizontalAlignment: Text.AlignLeft
            elide: Text.ElideRight
            Layout.preferredWidth: 44
            color: root.mutedTextColor
            font.family: root.fontFamily
            font.pixelSize: 13
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
            text: root.isRtl
                  ? root.prayerName + "  \u2066" + root.prayerTime + "\u2069"
                  : root.prayerName + "  " + root.prayerTime
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            font.family: root.fontFamily
            font.weight: Font.DemiBold
            color: root.textColor
        }

        PlasmaComponents.Label {
            text: root.remaining
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            color: root.mutedTextColor
            font.family: root.fontFamily
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
