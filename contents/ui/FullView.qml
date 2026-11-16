pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import "../code/translations.js" as Translations

Item {
    id: root

    property string language: "en"
    property string themeMode: "system"
    property string city: "Gaza"
    property string currentDate: ""
    property string nextPrayerName: "--"
    property string nextPrayerTime: "--:--"
    property string remaining: "--:--"
    property string errorText: ""
    property string sourceText: ""
    property bool onlineBusy: false
    property var times: ({})
    property string nextKey: ""
    readonly property bool isRtl: language === "ar"
    readonly property string fontFamily: "Cairo"
    readonly property int scrollBarBreathingSpace: 16
    readonly property bool followsSystemTheme: themeMode === "system"
    readonly property bool lightPalette: themeMode === "light"
                                         || (followsSystemTheme
                                             && colorLuminance(Kirigami.Theme.backgroundColor) > 0.55)
    readonly property color panelColor: followsSystemTheme
                                        ? Kirigami.Theme.backgroundColor
                                        : (lightPalette ? "#f8fafc" : "#172033")
    readonly property color surfaceColor: followsSystemTheme
                                          ? Kirigami.Theme.alternateBackgroundColor
                                          : (lightPalette ? "#e2e8f0" : "#243044")
    readonly property color surfaceSoftColor: followsSystemTheme
                                              ? alphaColor(Kirigami.Theme.disabledTextColor, 0.28)
                                              : (lightPalette ? "#cbd5e1" : "#334155")
    readonly property color cardTopColor: followsSystemTheme
                                          ? Kirigami.Theme.alternateBackgroundColor
                                          : (lightPalette ? "#f1f5f9" : "#475569")
    readonly property color cardBottomColor: followsSystemTheme
                                             ? Kirigami.Theme.alternateBackgroundColor
                                             : (lightPalette ? "#e2e8f0" : "#334155")
    readonly property color borderColor: followsSystemTheme
                                         ? alphaColor(Kirigami.Theme.disabledTextColor, 0.38)
                                         : (lightPalette ? "#cbd5e1" : "#0f172a")
    readonly property color cardBorderColor: followsSystemTheme
                                             ? alphaColor(Kirigami.Theme.disabledTextColor, 0.45)
                                             : (lightPalette ? "#cbd5e1" : "#536174")
    readonly property color accentColor: followsSystemTheme
                                         ? Kirigami.Theme.highlightColor
                                         : (lightPalette ? "#0284c7" : "#38bdf8")
    readonly property color goldColor: lightPalette ? "#a16207" : "#f8c35d"
    readonly property color textColor: followsSystemTheme
                                       ? Kirigami.Theme.textColor
                                       : (lightPalette ? "#0f172a" : "#f8fafc")
    readonly property color mutedTextColor: followsSystemTheme
                                            ? Kirigami.Theme.disabledTextColor
                                            : (lightPalette ? "#475569" : "#cbd5e1")
    readonly property color highlightedBackground: followsSystemTheme
                                                   ? alphaColor(Kirigami.Theme.highlightColor,
                                                                lightPalette ? 0.18 : 0.28)
                                                   : (lightPalette ? "#dbeafe" : "#4b5563")
    readonly property color errorColor: lightPalette ? "#b91c1c" : "#fca5a5"

    signal refreshRequested()

    function colorLuminance(colorValue) {
        return 0.2126 * colorValue.r + 0.7152 * colorValue.g + 0.0722 * colorValue.b
    }

    function alphaColor(colorValue, opacity) {
        return Qt.rgba(colorValue.r, colorValue.g, colorValue.b, opacity)
    }

    implicitWidth: 430
    implicitHeight: 560
    Layout.minimumWidth: 420
    Layout.preferredWidth: 430
    clip: true

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: root.panelColor
        border.color: root.borderColor
        border.width: 1
    }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 4
        color: root.accentColor
    }

    Controls.ScrollView {
        id: bodyScroll
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: sourceFooter.top
        topPadding: 20
        leftPadding: 20
        rightPadding: 20 + root.scrollBarBreathingSpace
        bottomPadding: 10
        clip: true
        contentWidth: Math.max(0, availableWidth)
        Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AlwaysOff
        Controls.ScrollBar.vertical.policy: Controls.ScrollBar.AsNeeded

        ColumnLayout {
            width: Math.max(0, bodyScroll.availableWidth)
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                layoutDirection: root.isRtl ? Qt.RightToLeft : Qt.LeftToRight
                spacing: 8

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    PlasmaComponents.Label {
                        text: root.city || Translations.text(root.language, "cityGaza")
                        Layout.fillWidth: true
                        horizontalAlignment: root.isRtl ? Text.AlignRight : Text.AlignLeft
                        color: root.textColor
                        font.family: root.fontFamily
                        font.pixelSize: 21
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }

                    PlasmaComponents.Label {
                        text: root.currentDate
                        Layout.fillWidth: true
                        horizontalAlignment: root.isRtl ? Text.AlignRight : Text.AlignLeft
                        color: root.mutedTextColor
                        font.family: root.fontFamily
                        elide: Text.ElideRight
                    }
                }

                PlasmaComponents.Button {
                    icon.name: "view-refresh"
                    text: ""
                    Accessible.name: Translations.text(root.language, "refresh")
                    onClicked: root.refreshRequested()
                }
            }

            Item {
                id: nextPrayerCard
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                Layout.minimumHeight: 150

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: root.cardTopColor }
                        GradientStop { position: 1.0; color: root.cardBottomColor }
                    }
                    border.color: root.cardBorderColor
                    border.width: 1
                }

                PlasmaComponents.Label {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 20
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    text: Translations.text(root.language, "nextPrayer")
                    horizontalAlignment: root.isRtl ? Text.AlignRight : Text.AlignLeft
                    color: root.mutedTextColor
                    font.family: root.fontFamily
                }

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 4
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    layoutDirection: root.isRtl ? Qt.RightToLeft : Qt.LeftToRight
                    spacing: 10

                    PlasmaComponents.Label {
                        text: root.nextPrayerName
                        Layout.fillWidth: true
                        horizontalAlignment: root.isRtl ? Text.AlignRight : Text.AlignLeft
                        color: root.textColor
                        font.family: root.fontFamily
                        font.pixelSize: 29
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }

                    PlasmaComponents.Label {
                        text: root.nextPrayerTime
                        horizontalAlignment: Text.AlignLeft
                        color: root.goldColor
                        font.family: root.fontFamily
                        font.pixelSize: 25
                        font.weight: Font.DemiBold
                        LayoutMirroring.enabled: false
                    }
                }

                RowLayout {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 20
                    layoutDirection: root.isRtl ? Qt.RightToLeft : Qt.LeftToRight
                    spacing: 6

                    PlasmaComponents.Label {
                        text: Translations.text(root.language, "remaining")
                        color: root.textColor
                        font.family: root.fontFamily
                        font.pixelSize: 16
                    }

                    PlasmaComponents.Label {
                        text: root.remaining
                        color: root.textColor
                        font.family: root.fontFamily
                        font.pixelSize: 16
                        LayoutMirroring.enabled: false
                    }
                }
            }

            PlasmaComponents.Label {
                text: Translations.text(root.language, "todayTimes")
                Layout.fillWidth: true
                Layout.topMargin: 2
                horizontalAlignment: root.isRtl ? Text.AlignRight : Text.AlignLeft
                color: root.textColor
                font.family: root.fontFamily
                font.weight: Font.DemiBold
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Repeater {
                    model: ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"]

                    delegate: PrayerTimeRow {
                        required property string modelData

                        rtl: root.isRtl
                        title: Translations.prayerName(root.language, modelData)
                        time: root.times && root.times[modelData] ? root.times[modelData] : "--:--"
                        highlighted: root.nextKey === modelData
                        textColor: root.textColor
                        mutedColor: root.mutedTextColor
                        highlightedBackground: root.highlightedBackground
                        fontFamily: root.fontFamily
                    }
                }
            }

            PlasmaComponents.Label {
                text: root.errorText
                visible: root.errorText.length > 0
                Layout.fillWidth: true
                horizontalAlignment: root.isRtl ? Text.AlignRight : Text.AlignLeft
                wrapMode: Text.WordWrap
                color: root.errorColor
                font.family: root.fontFamily
            }
        }
    }

    Rectangle {
        id: sourceFooter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 40
        color: root.panelColor

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: root.surfaceSoftColor
        }

        PlasmaComponents.Label {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            text: root.sourceText
            horizontalAlignment: root.isRtl ? Text.AlignRight : Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            color: root.onlineBusy ? root.goldColor : root.mutedTextColor
            font.family: root.fontFamily
            font.pixelSize: 12
        }
    }
}
