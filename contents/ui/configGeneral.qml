import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtMultimedia
import org.kde.kirigami as Kirigami
import "../code/translations.js" as Translations

Controls.ScrollView {
    id: page

    font.family: "Cairo"

    clip: true
    contentWidth: availableWidth
    topPadding: Kirigami.Units.largeSpacing * 2
    leftPadding: Kirigami.Units.largeSpacing
    rightPadding: Kirigami.Units.largeSpacing
    bottomPadding: Kirigami.Units.largeSpacing
    Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AlwaysOff
    Controls.ScrollBar.vertical.policy: Controls.ScrollBar.AsNeeded
    LayoutMirroring.enabled: uiLanguage === "ar"
    LayoutMirroring.childrenInherit: true

    readonly property string uiLanguage: Translations.resolveLanguage(
                                             languageSelector.mode, Qt.locale().name)

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
    property alias cfg_language: languageSelector.mode
    property alias cfg_themeMode: themeSelector.mode
    property alias cfg_calculationPreset: calculationPreset.mode
    property alias cfg_onlineEnabled: onlineEnabled.checked
    property alias cfg_notificationsEnabled: notificationsEnabled.checked
    property alias cfg_reminderEnabled: reminderEnabled.checked
    property alias cfg_prayerTimeNotificationEnabled: prayerTimeNotificationEnabled.checked
    property alias cfg_reminderMinutes: reminderMinutes.value
    property alias cfg_notificationSoundsEnabled: notificationSoundsEnabled.checked
    property alias cfg_reminderSound: reminderSound.mode
    property alias cfg_prayerTimeSound: prayerTimeSound.mode

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
    property var cfg_languageDefault
    property var cfg_themeModeDefault
    property var cfg_calculationPresetDefault
    property var cfg_onlineEnabledDefault
    property var cfg_notificationsEnabledDefault
    property var cfg_reminderEnabledDefault
    property var cfg_prayerTimeNotificationEnabledDefault
    property var cfg_reminderMinutesDefault
    property var cfg_notificationSoundsEnabledDefault
    property var cfg_reminderSoundDefault
    property var cfg_prayerTimeSoundDefault

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

    function translate(key) {
        return Translations.text(uiLanguage, key);
    }

    function soundChoices() {
        return [
            { text: translate("soundReminderOne"), value: "reminder-1.ogg" },
            { text: translate("soundReminderTwo"), value: "reminder-2.ogg" },
            { text: translate("soundPrayerTime"), value: "prayer-time.ogg" }
        ];
    }

    function soundIndex(fileName) {
        if (fileName === "reminder-2.ogg") {
            return 1;
        }
        if (fileName === "prayer-time.ogg") {
            return 2;
        }
        return 0;
    }

    function previewSound(fileName) {
        previewPlayer.stop();
        previewPlayer.source = Qt.resolvedUrl("../sounds/" + fileName);
        previewPlayer.play();
    }

    MediaPlayer {
        id: previewPlayer
        audioOutput: AudioOutput {
            volume: 1.0
        }
    }

    Kirigami.FormLayout {
        id: form
        width: page.availableWidth

        Kirigami.Heading {
            Kirigami.FormData.isSection: true
            text: page.translate("appearanceSection")
            level: 4
        }

        Controls.ComboBox {
            id: languageSelector
            property string mode: "system"
            Kirigami.FormData.label: page.translate("languageLabel")
            model: [
                { text: page.translate("systemLanguage"), value: "system" },
                { text: page.translate("arabic"), value: "ar" },
                { text: page.translate("english"), value: "en" }
            ]
            textRole: "text"
            valueRole: "value"
            onActivated: mode = currentValue
            onModeChanged: currentIndex = mode === "ar" ? 1 : (mode === "en" ? 2 : 0)
        }

        Controls.ComboBox {
            id: themeSelector
            property string mode: "system"
            Kirigami.FormData.label: page.translate("themeLabel")
            model: [
                { text: page.translate("systemTheme"), value: "system" },
                { text: page.translate("darkTheme"), value: "dark" },
                { text: page.translate("lightTheme"), value: "light" }
            ]
            textRole: "text"
            valueRole: "value"
            onActivated: mode = currentValue
            onModeChanged: currentIndex = mode === "dark" ? 1 : (mode === "light" ? 2 : 0)
        }

        Kirigami.Heading {
            Kirigami.FormData.isSection: true
            text: page.translate("prayerSettingsSection")
            level: 4
        }

        Controls.TextField {
            id: cityField
            Kirigami.FormData.label: page.translate("cityLabel")
            placeholderText: "Gaza"
        }

        Controls.TextField {
            id: latitudeField
            property real value: 31.5017
            Kirigami.FormData.label: page.translate("latitudeLabel")
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
            Kirigami.FormData.label: page.translate("longitudeLabel")
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
            Kirigami.FormData.label: page.translate("timezoneLabel")
            placeholderText: "Asia/Gaza"
        }

        Controls.ComboBox {
            id: calculationPreset
            property string mode: "gaza"
            Kirigami.FormData.label: page.translate("calculationMethodLabel")
            model: [
                { text: page.translate("gazaLocal"), value: "gaza" },
                { text: page.translate("automaticByLocation"), value: "automatic" }
            ]
            textRole: "text"
            valueRole: "value"
            onActivated: mode = currentValue
            onModeChanged: currentIndex = mode === "automatic" ? 1 : 0
        }

        Controls.CheckBox {
            id: onlineEnabled
            Kirigami.FormData.label: page.translate("onlineTimesLabel")
            text: page.translate("onlineUpdate")
        }

        Controls.TextField {
            id: fajrAngleField
            property real value: 18.0
            Kirigami.FormData.label: page.translate("fajrAngleLabel")
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
            Kirigami.FormData.label: page.translate("ishaAngleLabel")
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
            Kirigami.FormData.label: page.translate("asrMethodLabel")
            model: [
                {
                    text: page.translate("shafi"),
                    value: 1
                },
                {
                    text: page.translate("hanafi"),
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
            Kirigami.FormData.label: page.translate("fajrOffsetLabel")
            from: -120
            to: 120
            editable: true
        }

        Controls.SpinBox {
            id: dhuhrOffset
            Kirigami.FormData.label: page.translate("dhuhrOffsetLabel")
            from: -120
            to: 120
            editable: true
        }

        Controls.SpinBox {
            id: asrOffset
            Kirigami.FormData.label: page.translate("asrOffsetLabel")
            from: -120
            to: 120
            editable: true
        }

        Controls.SpinBox {
            id: maghribOffset
            Kirigami.FormData.label: page.translate("maghribOffsetLabel")
            from: -120
            to: 120
            editable: true
        }

        Controls.SpinBox {
            id: ishaOffset
            Kirigami.FormData.label: page.translate("ishaOffsetLabel")
            from: -120
            to: 120
            editable: true
        }

        Controls.CheckBox {
            id: showIcon
            Kirigami.FormData.label: page.translate("panelIconLabel")
            text: page.translate("showMosqueIcon")
        }

        Controls.ComboBox {
            id: timeFormat
            property string mode: "12h"
            Kirigami.FormData.label: page.translate("timeFormatLabel")
            model: [
                {
                    text: page.translate("twelveHour"),
                    value: "12h"
                },
                {
                    text: page.translate("twentyFourHour"),
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
            Kirigami.FormData.label: page.translate("panelLayoutLabel")
            model: [
                {
                    text: page.translate("horizontal"),
                    value: "horizontal"
                },
                {
                    text: page.translate("compact"),
                    value: "compact"
                },
                {
                    text: page.translate("vertical"),
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
            text: page.translate("notificationsSection")
            level: 4
        }

        Controls.CheckBox {
            id: notificationsEnabled
            Kirigami.FormData.label: page.translate("notificationsLabel")
            text: page.translate("enablePrayerNotifications")
        }

        Controls.CheckBox {
            id: reminderEnabled
            Kirigami.FormData.label: page.translate("reminderLabel")
            text: page.translate("notifyBeforePrayer")
            enabled: notificationsEnabled.checked
        }

        Controls.SpinBox {
            id: reminderMinutes
            Kirigami.FormData.label: page.translate("reminderMinutesLabel")
            from: 1
            to: 120
            editable: true
            enabled: notificationsEnabled.checked && reminderEnabled.checked
        }

        Controls.CheckBox {
            id: prayerTimeNotificationEnabled
            Kirigami.FormData.label: page.translate("prayerTimeLabel")
            text: page.translate("notifyAtPrayerTime")
            enabled: notificationsEnabled.checked
        }

        Controls.CheckBox {
            id: notificationSoundsEnabled
            Kirigami.FormData.label: page.translate("soundsLabel")
            text: page.translate("enableNotificationSounds")
            enabled: notificationsEnabled.checked
        }

        RowLayout {
            Kirigami.FormData.label: page.translate("reminderSoundLabel")
            enabled: notificationsEnabled.checked && reminderEnabled.checked
                     && notificationSoundsEnabled.checked

            Controls.ComboBox {
                id: reminderSound
                property string mode: "reminder-1.ogg"
                Layout.fillWidth: true
                model: page.soundChoices()
                textRole: "text"
                valueRole: "value"
                onActivated: mode = currentValue
                onModeChanged: currentIndex = page.soundIndex(mode)
            }

            Controls.Button {
                icon.name: "media-playback-start"
                text: ""
                Accessible.name: page.translate("previewSound")
                Controls.ToolTip.text: page.translate("previewSound")
                Controls.ToolTip.visible: hovered
                onClicked: page.previewSound(reminderSound.mode)
            }
        }

        RowLayout {
            Kirigami.FormData.label: page.translate("prayerSoundLabel")
            enabled: notificationsEnabled.checked && prayerTimeNotificationEnabled.checked
                     && notificationSoundsEnabled.checked

            Controls.ComboBox {
                id: prayerTimeSound
                property string mode: "prayer-time.ogg"
                Layout.fillWidth: true
                model: page.soundChoices()
                textRole: "text"
                valueRole: "value"
                onActivated: mode = currentValue
                onModeChanged: currentIndex = page.soundIndex(mode)
            }

            Controls.Button {
                icon.name: "media-playback-start"
                text: ""
                Accessible.name: page.translate("previewSound")
                Controls.ToolTip.text: page.translate("previewSound")
                Controls.ToolTip.visible: hovered
                onClicked: page.previewSound(prayerTimeSound.mode)
            }
        }
    }
}
