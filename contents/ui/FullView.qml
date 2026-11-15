import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents

Item {
    id: root

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
    readonly property color panelColor: "#172033"
    readonly property color surfaceColor: "#243044"
    readonly property color surfaceSoftColor: "#334155"
    readonly property color accentColor: "#38bdf8"
    readonly property color goldColor: "#f8c35d"
    readonly property color textColor: "#f8fafc"
    readonly property color mutedTextColor: "#cbd5e1"

    signal refreshRequested()

    implicitWidth: 380
    implicitHeight: 565
    LayoutMirroring.enabled: true
    LayoutMirroring.childrenInherit: true
    clip: true

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: root.panelColor
        border.color: "#0f172a"
        border.width: 1
    }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 4
        color: root.accentColor
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                PlasmaComponents.Label {
                    text: root.city || "Gaza"
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignRight
                    color: root.textColor
                    font.pixelSize: 21
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }

                PlasmaComponents.Label {
                    text: root.currentDate
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignRight
                    color: root.mutedTextColor
                    elide: Text.ElideRight
                }
            }

            PlasmaComponents.Button {
                icon.name: "view-refresh"
                text: ""
                Accessible.name: "Refresh prayer times"
                onClicked: root.refreshRequested()
            }
        }

        Item {
            id: nextPrayerCard
            Layout.fillWidth: true
            Layout.preferredHeight: 138
            Layout.minimumHeight: 138

            Rectangle {
                anchors.fill: parent
                radius: 8
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#475569" }
                    GradientStop { position: 1.0; color: "#334155" }
                }
                border.color: "#536174"
                border.width: 1
            }

            PlasmaComponents.Label {
                id: nextPrayerCaption
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 18
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                text: "الصلاة القادمة"
                horizontalAlignment: Text.AlignRight
                color: root.mutedTextColor
            }

            RowLayout {
                id: nextPrayerMain
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 4
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 10

                PlasmaComponents.Label {
                    text: root.nextPrayerName
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignRight
                    color: root.textColor
                    font.pixelSize: 29
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }

                PlasmaComponents.Label {
                    text: root.nextPrayerTime
                    horizontalAlignment: Text.AlignLeft
                    color: root.goldColor
                    font.pixelSize: 25
                    font.family: "monospace"
                    font.weight: Font.DemiBold
                }
            }

            PlasmaComponents.Label {
                id: remainingLabel
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                anchors.bottomMargin: 18
                text: "باقي " + root.remaining
                horizontalAlignment: Text.AlignRight
                color: root.textColor
                font.pixelSize: 16
                elide: Text.ElideRight
            }
        }

        PlasmaComponents.Label {
            text: "مواقيت اليوم"
            Layout.fillWidth: true
            Layout.topMargin: 2
            horizontalAlignment: Text.AlignRight
            color: root.textColor
            font.weight: Font.DemiBold
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Repeater {
                model: [
                    { key: "Fajr", title: "الفجر" },
                    { key: "Sunrise", title: "الشروق" },
                    { key: "Dhuhr", title: "الظهر" },
                    { key: "Asr", title: "العصر" },
                    { key: "Maghrib", title: "المغرب" },
                    { key: "Isha", title: "العشاء" }
                ]

                delegate: PrayerTimeRow {
                    title: modelData.title
                    time: root.times && root.times[modelData.key] ? root.times[modelData.key] : "--:--"
                    highlighted: root.nextKey === modelData.key
                    textColor: root.textColor
                    mutedColor: root.mutedTextColor
                    highlightedBackground: "#4b5563"
                }
            }
        }

        PlasmaComponents.Label {
            text: root.errorText
            visible: root.errorText.length > 0
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            wrapMode: Text.WordWrap
            color: "#fca5a5"
        }

        PlasmaComponents.Label {
            text: root.sourceText
            visible: text.length > 0
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
            color: root.onlineBusy ? root.goldColor : root.mutedTextColor
            font.pixelSize: 12
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
