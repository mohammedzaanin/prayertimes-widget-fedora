import QtQuick
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

Controls.ScrollView {
    id: page

    clip: true
    contentWidth: availableWidth
    topPadding: Kirigami.Units.largeSpacing * 2
    leftPadding: Kirigami.Units.largeSpacing
    rightPadding: Kirigami.Units.largeSpacing
    bottomPadding: Kirigami.Units.largeSpacing
    Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AlwaysOff
    Controls.ScrollBar.vertical.policy: Controls.ScrollBar.AsNeeded

    property string title: ""
    property alias cfg_city: cityField.text
    property alias cfg_latitude: latitudeField.value
    property alias cfg_longitude: longitudeField.value
    property alias cfg_timezone: timezoneField.text
    property alias cfg_fajrAngle: fajrAngleField.value
    property alias cfg_ishaAngle: ishaAngleField.value
    property alias cfg_asrFactor: asrMethod.factor
    property alias cfg_fajrOffset: fajrOffset.value
    property alias cfg_dhuhrOffset: dhuhrOffset.value
    property alias cfg_asrOffset: asrOffset.value
    property alias cfg_maghribOffset: maghribOffset.value
    property alias cfg_ishaOffset: ishaOffset.value
    property alias cfg_showIcon: showIcon.checked
    property alias cfg_panelMode: panelMode.mode
    property alias cfg_timeFormat: timeFormat.mode
    property alias cfg_calculationPreset: calculationPreset.mode
    property alias cfg_onlineEnabled: onlineEnabled.checked
    property alias cfg_notificationsEnabled: notificationsEnabled.checked
    property alias cfg_reminderEnabled: reminderEnabled.checked
    property alias cfg_prayerTimeNotificationEnabled: prayerTimeNotificationEnabled.checked
    property alias cfg_reminderMinutes: reminderMinutes.value

    // Plasma injects each setting's default value into the configuration page.
    property var cfg_cityDefault
    property var cfg_latitudeDefault
    property var cfg_longitudeDefault
    property var cfg_timezoneDefault
    property var cfg_fajrAngleDefault
    property var cfg_ishaAngleDefault
    property var cfg_asrFactorDefault
    property var cfg_fajrOffsetDefault
    property var cfg_dhuhrOffsetDefault
    property var cfg_asrOffsetDefault
    property var cfg_maghribOffsetDefault
    property var cfg_ishaOffsetDefault
    property var cfg_showIconDefault
    property var cfg_panelModeDefault
    property var cfg_timeFormatDefault
    property var cfg_calculationPresetDefault
    property var cfg_onlineEnabledDefault
    property var cfg_notificationsEnabledDefault
    property var cfg_reminderEnabledDefault
    property var cfg_prayerTimeNotificationEnabledDefault
    property var cfg_reminderMinutesDefault

    // Internal persisted state is not shown, but the configuration loader still
    // provides it when this page is created.
    property string cfg_cachedOnlineDate: ""
    property string cfg_cachedOnlineTomorrowDate: ""
    property string cfg_cachedOnlineSignature: ""
    property string cfg_cachedOnlineToday: ""
    property string cfg_cachedOnlineTomorrow: ""
    property string cfg_cachedOnlineMethod: ""
    property string cfg_cachedOnlineUpdatedAt: ""
    property string cfg_lastReminderNotification: ""
    property string cfg_lastPrayerNotification: ""
    property var cfg_cachedOnlineDateDefault
    property var cfg_cachedOnlineTomorrowDateDefault
    property var cfg_cachedOnlineSignatureDefault
    property var cfg_cachedOnlineTodayDefault
    property var cfg_cachedOnlineTomorrowDefault
    property var cfg_cachedOnlineMethodDefault
    property var cfg_cachedOnlineUpdatedAtDefault
    property var cfg_lastReminderNotificationDefault
    property var cfg_lastPrayerNotificationDefault

    function normalizeNumberText(value) {
        return String(Number(value));
    }

    Kirigami.FormLayout {
        id: form
        width: page.availableWidth

        Controls.TextField {
            id: cityField
            Kirigami.FormData.label: "City:"
            placeholderText: "Gaza"
        }

        Controls.TextField {
            id: latitudeField
            property real value: 31.5017
            Kirigami.FormData.label: "Latitude:"
            text: String(value)
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            validator: DoubleValidator {
                bottom: -90
                top: 90
                decimals: 6
            }
            onEditingFinished: value = Number(text)
            onValueChanged: text = page.normalizeNumberText(value)
        }

        Controls.TextField {
            id: longitudeField
            property real value: 34.4668
            Kirigami.FormData.label: "Longitude:"
            text: String(value)
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            validator: DoubleValidator {
                bottom: -180
                top: 180
                decimals: 6
            }
            onEditingFinished: value = Number(text)
            onValueChanged: text = page.normalizeNumberText(value)
        }

        Controls.TextField {
            id: timezoneField
            Kirigami.FormData.label: "Timezone:"
            placeholderText: "Asia/Gaza"
        }

        Controls.ComboBox {
            id: calculationPreset
            property string mode: "gaza"
            Kirigami.FormData.label: "Calculation method:"
            model: [
                { text: "Gaza local (19.5° / 17.5°)", value: "gaza" },
                { text: "Automatic by location", value: "automatic" }
            ]
            textRole: "text"
            valueRole: "value"
            onActivated: mode = currentValue
            onModeChanged: currentIndex = mode === "automatic" ? 1 : 0
        }

        Controls.CheckBox {
            id: onlineEnabled
            Kirigami.FormData.label: "Online times:"
            text: "Update automatically when connected"
        }

        Controls.TextField {
            id: fajrAngleField
            property real value: 18.0
            Kirigami.FormData.label: "Fajr angle:"
            enabled: calculationPreset.mode !== "gaza"
            text: String(value)
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            validator: DoubleValidator {
                bottom: 10
                top: 25
                decimals: 2
            }
            onEditingFinished: value = Number(text)
            onValueChanged: text = page.normalizeNumberText(value)
        }

        Controls.TextField {
            id: ishaAngleField
            property real value: 17.5
            Kirigami.FormData.label: "Isha angle:"
            enabled: calculationPreset.mode !== "gaza"
            text: String(value)
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            validator: DoubleValidator {
                bottom: 10
                top: 25
                decimals: 2
            }
            onEditingFinished: value = Number(text)
            onValueChanged: text = page.normalizeNumberText(value)
        }

        Controls.ComboBox {
            id: asrMethod
            property int factor: 1
            Kirigami.FormData.label: "Asr method:"
            model: [
                {
                    text: "Shafi",
                    value: 1
                },
                {
                    text: "Hanafi",
                    value: 2
                }
            ]
            textRole: "text"
            valueRole: "value"
            onActivated: factor = currentValue
            onFactorChanged: currentIndex = factor === 2 ? 1 : 0
        }

        Controls.SpinBox {
            id: fajrOffset
            Kirigami.FormData.label: "Fajr offset (min):"
            from: -120
            to: 120
            editable: true
        }

        Controls.SpinBox {
            id: dhuhrOffset
            Kirigami.FormData.label: "Dhuhr offset (min):"
            from: -120
            to: 120
            editable: true
        }

        Controls.SpinBox {
            id: asrOffset
            Kirigami.FormData.label: "Asr offset (min):"
            from: -120
            to: 120
            editable: true
        }

        Controls.SpinBox {
            id: maghribOffset
            Kirigami.FormData.label: "Maghrib offset (min):"
            from: -120
            to: 120
            editable: true
        }

        Controls.SpinBox {
            id: ishaOffset
            Kirigami.FormData.label: "Isha offset (min):"
            from: -120
            to: 120
            editable: true
        }

        Controls.CheckBox {
            id: showIcon
            Kirigami.FormData.label: "Panel icon:"
            text: "Show mosque icon"
        }

        Controls.ComboBox {
            id: timeFormat
            property string mode: "12h"
            Kirigami.FormData.label: "Time format:"
            model: [
                {
                    text: "12-hour AM/PM",
                    value: "12h"
                },
                {
                    text: "24-hour",
                    value: "24h"
                }
            ]
            textRole: "text"
            valueRole: "value"
            onActivated: mode = currentValue
            onModeChanged: currentIndex = mode === "24h" ? 1 : 0
        }

        Controls.ComboBox {
            id: panelMode
            property string mode: "horizontal"
            Kirigami.FormData.label: "Panel layout:"
            model: [
                {
                    text: "Horizontal",
                    value: "horizontal"
                },
                {
                    text: "Compact",
                    value: "compact"
                },
                {
                    text: "Vertical",
                    value: "vertical"
                }
            ]
            textRole: "text"
            valueRole: "value"
            onActivated: mode = currentValue
            onModeChanged: {
                if (mode === "compact") {
                    currentIndex = 1;
                } else if (mode === "vertical") {
                    currentIndex = 2;
                } else {
                    currentIndex = 0;
                }
            }
        }

        Kirigami.Heading {
            Kirigami.FormData.isSection: true
            text: "الإشعارات"
            level: 4
        }

        Controls.CheckBox {
            id: notificationsEnabled
            Kirigami.FormData.label: "التنبيهات:"
            text: "تفعيل إشعارات الصلاة"
        }

        Controls.CheckBox {
            id: reminderEnabled
            Kirigami.FormData.label: "التذكير:"
            text: "إشعار قبل موعد الصلاة"
            enabled: notificationsEnabled.checked
        }

        Controls.SpinBox {
            id: reminderMinutes
            Kirigami.FormData.label: "قبل الصلاة (دقيقة):"
            from: 1
            to: 120
            editable: true
            enabled: notificationsEnabled.checked && reminderEnabled.checked
        }

        Controls.CheckBox {
            id: prayerTimeNotificationEnabled
            Kirigami.FormData.label: "وقت الصلاة:"
            text: "إشعار عند دخول وقت الصلاة"
            enabled: notificationsEnabled.checked
        }
    }
}
