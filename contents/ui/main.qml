pragma ComponentBehavior: Bound

import QtQuick
import QtMultimedia
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.notification
import "../code/prayerCalc.js" as PrayerCalc
import "../code/translations.js" as Translations

PlasmoidItem {
    id: root

    readonly property var prayerKeys: ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]
    readonly property string uiLanguage: Translations.resolveLanguage(
                                             Plasmoid.configuration.language || "system",
                                             Qt.locale().name)
    readonly property bool isRtl: uiLanguage === "ar"
    property var calculation: null
    property string errorText: ""
    property string sourceText: ""
    property bool onlineBusy: false
    property string onlineError: ""
    property double lastOnlineAttempt: 0
    property int onlineRequestGeneration: 0
    property int pendingOnlineRequests: 0
    property var pendingOnlineToday: null
    property var pendingOnlineTomorrow: null
    property string pendingOnlineMethod: ""
    property var activeRequests: []
    property bool writingInternalConfiguration: false
    property string observedUserConfiguration: ""

    function configNumber(value, fallback) {
        var parsed = Number(value)
        return isFinite(parsed) ? parsed : fallback
    }

    function translate(key) {
        return Translations.text(uiLanguage, key)
    }

    function safeSoundFile(fileName, fallback) {
        var allowed = ["reminder-1.ogg", "reminder-2.ogg", "prayer-time.ogg"]
        return allowed.indexOf(String(fileName)) >= 0 ? String(fileName) : fallback
    }

    function soundUrl(fileName, fallback) {
        return Qt.resolvedUrl("../sounds/" + safeSoundFile(fileName, fallback))
    }

    function playNotificationSound(isReminder) {
        if (!Plasmoid.configuration.notificationSoundsEnabled) {
            return
        }
        var effect = isReminder ? reminderSoundEffect : prayerTimeSoundEffect
        effect.stop()
        effect.play()
    }

    function settingsObject() {
        var cfg = Plasmoid.configuration
        return {
            city: cfg.city || "Gaza",
            latitude: configNumber(cfg.latitude, 31.5017),
            longitude: configNumber(cfg.longitude, 34.4668),
            timezone: cfg.timezone || "Asia/Gaza",
            calculationPreset: cfg.calculationPreset || "gaza",
            fajrAngle: configNumber(cfg.fajrAngle, 18.0),
            ishaAngle: configNumber(cfg.ishaAngle, 17.5),
            asrFactor: configNumber(cfg.asrFactor, 1),
            fajrOffset: configNumber(cfg.fajrOffset, 0),
            dhuhrOffset: configNumber(cfg.dhuhrOffset, 0),
            asrOffset: configNumber(cfg.asrOffset, 0),
            maghribOffset: configNumber(cfg.maghribOffset, 0),
            ishaOffset: configNumber(cfg.ishaOffset, 0)
        }
    }

    function onlineOffsetsObject(settings) {
        var offsets = {
            Fajr: settings.fajrOffset,
            Sunrise: 0,
            Dhuhr: settings.dhuhrOffset,
            Asr: settings.asrOffset,
            Maghrib: settings.maghribOffset,
            Isha: settings.ishaOffset
        }

        if (settings.calculationPreset === "gaza") {
            offsets.Asr -= 1
            offsets.Maghrib += 4
            offsets.Isha += 1
        }
        return offsets
    }

    function offlineSettingsObject(settings) {
        var result = {}
        for (var key in settings) {
            if (settings.hasOwnProperty(key)) {
                result[key] = settings[key]
            }
        }

        if (settings.calculationPreset === "gaza") {
            result.fajrAngle = 19.5
            result.ishaAngle = 17.5
            result.fajrOffset += 1
            result.dhuhrOffset += 1
            result.maghribOffset += 4
            result.ishaOffset += 1
        }
        return result
    }

    function use12HourTime() {
        return Plasmoid.configuration.timeFormat !== "24h"
    }

    function userConfigurationSignature() {
        var cfg = Plasmoid.configuration
        return JSON.stringify([
            cfg.city, cfg.latitude, cfg.longitude, cfg.timezone,
            cfg.fajrAngle, cfg.ishaAngle, cfg.asrFactor,
            cfg.fajrOffset, cfg.dhuhrOffset, cfg.asrOffset,
            cfg.maghribOffset, cfg.ishaOffset,
            cfg.showIcon, cfg.panelMode, cfg.timeFormat, cfg.language, cfg.themeMode,
            cfg.calculationPreset,
            cfg.onlineEnabled, cfg.notificationsEnabled,
            cfg.reminderEnabled, cfg.prayerTimeNotificationEnabled,
            cfg.reminderMinutes, cfg.notificationSoundsEnabled,
            cfg.reminderSound, cfg.prayerTimeSound
        ])
    }

    function onlineSignature(settings) {
        return [
            Number(settings.latitude).toFixed(6),
            Number(settings.longitude).toFixed(6),
            settings.timezone,
            settings.calculationPreset,
            Number(settings.asrFactor) === 2 ? "hanafi" : "standard"
        ].join("|")
    }

    function dateKeyForZone(date, timezone) {
        if (typeof Intl !== "undefined" && Intl.DateTimeFormat) {
            try {
                var parts = new Intl.DateTimeFormat("en-US", {
                    timeZone: timezone,
                    year: "numeric",
                    month: "2-digit",
                    day: "2-digit"
                }).formatToParts(date)
                var values = {}
                for (var i = 0; i < parts.length; ++i) {
                    values[parts[i].type] = parts[i].value
                }
                return values.year + "-" + values.month + "-" + values.day
            } catch (error) {
                console.warn("Prayer Times: invalid timezone", timezone, error)
            }
        }

        function pad(value) {
            return value < 10 ? "0" + value : String(value)
        }
        return date.getFullYear() + "-" + pad(date.getMonth() + 1) + "-" + pad(date.getDate())
    }

    function addDaysToDateKey(dateKey, days) {
        var parts = dateKey.split("-")
        var date = new Date(Date.UTC(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]) + days))
        function pad(value) {
            return value < 10 ? "0" + value : String(value)
        }
        return date.getUTCFullYear() + "-" + pad(date.getUTCMonth() + 1) + "-" + pad(date.getUTCDate())
    }

    function apiDate(dateKey) {
        var parts = dateKey.split("-")
        return parts[2] + "-" + parts[1] + "-" + parts[0]
    }

    function serializeTimings(timings) {
        var result = {}
        var keys = ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"]
        for (var i = 0; i < keys.length; ++i) {
            var key = keys[i]
            result[key] = timings[key].toISOString()
        }
        return JSON.stringify(result)
    }

    function deserializeTimings(serialized) {
        if (!serialized) {
            return null
        }

        try {
            var values = JSON.parse(serialized)
            var result = {}
            var keys = ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"]
            for (var i = 0; i < keys.length; ++i) {
                var key = keys[i]
                var date = new Date(values[key])
                if (!isFinite(date.getTime())) {
                    return null
                }
                result[key] = date
            }
            return result
        } catch (error) {
            console.warn("Prayer Times: invalid cached timings", error)
            return null
        }
    }

    function cachedOnlineCalculation(settings) {
        if (!Plasmoid.configuration.onlineEnabled) {
            return null
        }

        var todayKey = dateKeyForZone(new Date(), settings.timezone)
        var tomorrowKey = addDaysToDateKey(todayKey, 1)
        if (Plasmoid.configuration.cachedOnlineDate !== todayKey
                || Plasmoid.configuration.cachedOnlineTomorrowDate !== tomorrowKey
                || Plasmoid.configuration.cachedOnlineSignature !== onlineSignature(settings)) {
            return null
        }

        var today = deserializeTimings(Plasmoid.configuration.cachedOnlineToday)
        var tomorrow = deserializeTimings(Plasmoid.configuration.cachedOnlineTomorrow)
        if (!today || !tomorrow) {
            return null
        }

        today = PrayerCalc.applyOffsets(today, onlineOffsetsObject(settings))
        tomorrow = PrayerCalc.applyOffsets(tomorrow, onlineOffsetsObject(settings))
        return PrayerCalc.calculateFromTimes(today, tomorrow, new Date())
    }

    function updateSourceText(usingOnline) {
        var isGazaPreset = settingsObject().calculationPreset === "gaza"
        if (usingOnline) {
            var method = Plasmoid.configuration.cachedOnlineMethod || translate("automaticSource")
            sourceText = onlineError.length > 0
                    ? translate(isGazaPreset ? "sourceGazaCachedFailed"
                                             : "sourceInternetCachedFailed")
                    : (isGazaPreset ? translate("sourceGaza")
                                    : Translations.format(uiLanguage, "sourceInternet", [method]))
        } else if (!Plasmoid.configuration.onlineEnabled) {
            sourceText = translate(isGazaPreset ? "sourceGazaOffline" : "sourceLocal")
        } else if (onlineBusy) {
            sourceText = translate("sourceLocalUpdating")
        } else if (onlineError.length > 0) {
            sourceText = translate("sourceLocalNoInternet")
        } else {
            sourceText = translate("sourceLocal")
        }
    }

    function refreshDisplay() {
        var settings = settingsObject()
        try {
            var onlineCalculation = cachedOnlineCalculation(settings)
            calculation = onlineCalculation
                    || PrayerCalc.calculateForTodayAndTomorrow(offlineSettingsObject(settings))
            errorText = ""
            updateSourceText(onlineCalculation !== null)
        } catch (error) {
            calculation = null
            errorText = translate("calculationError")
            updateSourceText(false)
            console.warn("Prayer Times:", error)
        }
    }

    function parseApiTimings(payload, expectedDateKey, timezone) {
        if (!payload || Number(payload.code) !== 200 || !payload.data || !payload.data.timings) {
            throw new Error("The prayer times service returned an invalid response.")
        }

        var apiTimings = payload.data.timings
        var result = {}
        var keys = ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"]
        for (var i = 0; i < keys.length; ++i) {
            var key = keys[i]
            var value = String(apiTimings[key] || "")
            var date = new Date(value)
            if (!isFinite(date.getTime()) || dateKeyForZone(date, timezone) !== expectedDateKey) {
                throw new Error("Invalid " + key + " value received from the prayer times service.")
            }
            result[key] = date
        }
        return result
    }

    function finishOnlineRequest(generation, isTomorrow, payload, errorMessage) {
        if (generation !== onlineRequestGeneration) {
            return
        }

        if (errorMessage.length > 0) {
            onlineRequestGeneration += 1
            onlineRequestTimeout.stop()
            onlineBusy = false
            onlineError = errorMessage
            activeRequests = []
            refreshDisplay()
            return
        }

        var settings = settingsObject()
        var todayKey = dateKeyForZone(new Date(), settings.timezone)
        var expectedDateKey = isTomorrow ? addDaysToDateKey(todayKey, 1) : todayKey
        try {
            var timings = parseApiTimings(payload, expectedDateKey, settings.timezone)
            if (isTomorrow) {
                pendingOnlineTomorrow = timings
            } else {
                pendingOnlineToday = timings
            }
            if (payload.data.meta && payload.data.meta.method && payload.data.meta.method.name) {
                pendingOnlineMethod = String(payload.data.meta.method.name)
            }
        } catch (error) {
            finishOnlineRequest(generation, isTomorrow, null, String(error))
            return
        }

        pendingOnlineRequests -= 1
        if (pendingOnlineRequests > 0) {
            return
        }

        onlineRequestTimeout.stop()
        writingInternalConfiguration = true
        Plasmoid.configuration.cachedOnlineDate = todayKey
        Plasmoid.configuration.cachedOnlineTomorrowDate = addDaysToDateKey(todayKey, 1)
        Plasmoid.configuration.cachedOnlineSignature = onlineSignature(settings)
        Plasmoid.configuration.cachedOnlineToday = serializeTimings(pendingOnlineToday)
        Plasmoid.configuration.cachedOnlineTomorrow = serializeTimings(pendingOnlineTomorrow)
        Plasmoid.configuration.cachedOnlineMethod = pendingOnlineMethod
        Plasmoid.configuration.cachedOnlineUpdatedAt = new Date().toISOString()
        writingInternalConfiguration = false

        onlineBusy = false
        onlineError = ""
        activeRequests = []
        refreshDisplay()
        checkNotifications()
    }

    function requestOnlineDate(dateKey, isTomorrow, generation, settings) {
        var school = Number(settings.asrFactor) === 2 ? 1 : 0
        var methodParameter = settings.calculationPreset === "gaza" ? "&method=5" : ""
        var url = "https://api.aladhan.com/v1/timings/" + apiDate(dateKey)
                + "?latitude=" + encodeURIComponent(settings.latitude)
                + "&longitude=" + encodeURIComponent(settings.longitude)
                + "&school=" + school
                + methodParameter
                + "&timezonestring=" + encodeURIComponent(settings.timezone)
                + "&iso8601=true"
        var request = new XMLHttpRequest()
        activeRequests.push(request)
        request.onreadystatechange = function() {
            if (request.readyState !== XMLHttpRequest.DONE || generation !== onlineRequestGeneration) {
                return
            }
            if (request.status < 200 || request.status >= 300) {
                finishOnlineRequest(generation, isTomorrow, null,
                                    "HTTP " + request.status)
                return
            }
            try {
                finishOnlineRequest(generation, isTomorrow, JSON.parse(request.responseText), "")
            } catch (error) {
                finishOnlineRequest(generation, isTomorrow, null, translate("responseError"))
            }
        }
        request.open("GET", url)
        request.send()
    }

    function fetchOnlineTimes(force) {
        if (!Plasmoid.configuration.onlineEnabled || onlineBusy) {
            return
        }

        var now = Date.now()
        if (!force && now - lastOnlineAttempt < 5 * 60 * 1000) {
            return
        }

        var settings = settingsObject()
        var todayKey = dateKeyForZone(new Date(), settings.timezone)
        if (!force && cachedOnlineCalculation(settings) !== null) {
            return
        }

        lastOnlineAttempt = now
        onlineBusy = true
        onlineError = ""
        pendingOnlineRequests = 2
        pendingOnlineToday = null
        pendingOnlineTomorrow = null
        pendingOnlineMethod = ""
        activeRequests = []
        var generation = ++onlineRequestGeneration
        onlineRequestTimeout.restart()
        updateSourceText(false)
        requestOnlineDate(todayKey, false, generation, settings)
        requestOnlineDate(addDaysToDateKey(todayKey, 1), true, generation, settings)
    }

    function refreshTimes(forceOnline) {
        refreshDisplay()
        checkNotifications()
        fetchOnlineTimes(forceOnline === true)
    }

    function timeForDate(date) {
        return PrayerCalc.formatTimeForZone(date, use12HourTime(),
                                            settingsObject().timezone, uiLanguage)
    }

    function timeFor(key) {
        if (!calculation || !calculation.today || !calculation.today[key]) {
            return "--:--"
        }
        return timeForDate(calculation.today[key])
    }

    function todayTimesObject() {
        return {
            Fajr: timeFor("Fajr"),
            Sunrise: timeFor("Sunrise"),
            Dhuhr: timeFor("Dhuhr"),
            Asr: timeFor("Asr"),
            Maghrib: timeFor("Maghrib"),
            Isha: timeFor("Isha")
        }
    }

    function nextName() {
        return calculation && calculation.next
                ? Translations.prayerName(uiLanguage, calculation.next.key) : "--"
    }

    function nextTime() {
        return calculation && calculation.next ? timeForDate(calculation.next.time) : "--:--"
    }

    function remainingText() {
        return calculation && calculation.next
                ? PrayerCalc.formatRemaining(calculation.next.time.getTime() - Date.now())
                : "--:--"
    }

    function nextKey() {
        return calculation && calculation.next ? calculation.next.key : ""
    }

    function formattedDate() {
        var now = new Date()
        try {
            return now.toLocaleDateString(Qt.locale(uiLanguage === "ar" ? "ar" : "en_US"),
                                          Locale.LongFormat)
        } catch (error) {
            return now.toDateString()
        }
    }

    function notificationKey(prayerKey, prayerTime) {
        return dateKeyForZone(prayerTime, settingsObject().timezone)
                + "|" + prayerKey + "|" + prayerTime.getTime()
    }

    function saveNotificationMarker(isReminder, value) {
        writingInternalConfiguration = true
        if (isReminder) {
            Plasmoid.configuration.lastReminderNotification = value
        } else {
            Plasmoid.configuration.lastPrayerNotification = value
        }
        writingInternalConfiguration = false
    }

    function checkNotifications() {
        var cfg = Plasmoid.configuration
        if (!cfg.notificationsEnabled || !calculation || !calculation.today) {
            return
        }

        var now = Date.now()
        var windowMilliseconds = 2 * 60 * 1000
        var reminderMinutes = Math.max(1, configNumber(cfg.reminderMinutes, 30))
        var reminderMilliseconds = reminderMinutes * 60 * 1000

        for (var i = 0; i < prayerKeys.length; ++i) {
            var prayerKey = prayerKeys[i]
            var prayerTime = calculation.today[prayerKey]
            if (!prayerTime || !isFinite(prayerTime.getTime())) {
                continue
            }

            var difference = prayerTime.getTime() - now
            var marker = notificationKey(prayerKey, prayerTime)
            var prayerName = Translations.prayerName(uiLanguage, prayerKey)

            if (cfg.reminderEnabled && difference > 0
                    && difference <= reminderMilliseconds
                    && difference > Math.max(0, reminderMilliseconds - windowMilliseconds)
                    && cfg.lastReminderNotification !== marker) {
                saveNotificationMarker(true, marker)
                reminderNotification.text = Translations.format(
                            uiLanguage, "reminderText",
                            [reminderMinutes, prayerName, timeForDate(prayerTime)])
                reminderNotification.sendEvent()
                playNotificationSound(true)
            }

            if (cfg.prayerTimeNotificationEnabled && difference <= 0
                    && difference > -windowMilliseconds
                    && cfg.lastPrayerNotification !== marker) {
                saveNotificationMarker(false, marker)
                prayerTimeNotification.text = Translations.format(
                            uiLanguage, "prayerTimeText",
                            [prayerName, timeForDate(prayerTime)])
                prayerTimeNotification.sendEvent()
                playNotificationSound(false)
            }
        }
    }

    preferredRepresentation: compactRepresentation
    switchWidth: Kirigami.Units.gridUnit * 10
    switchHeight: Kirigami.Units.gridUnit * 5

    compactRepresentation: CompactView {
        language: root.uiLanguage
        themeMode: Plasmoid.configuration.themeMode || "system"
        prayerName: root.nextName()
        prayerTime: root.nextTime()
        remaining: root.remainingText()
        showIcon: Plasmoid.configuration.showIcon
        panelMode: Plasmoid.configuration.panelMode || "horizontal"
        onActivated: root.expanded = !root.expanded
    }

    fullRepresentation: FullView {
        language: root.uiLanguage
        themeMode: Plasmoid.configuration.themeMode || "system"
        city: root.uiLanguage === "ar"
              && String(Plasmoid.configuration.city || "Gaza").toLowerCase() === "gaza"
              ? root.translate("cityGaza") : (Plasmoid.configuration.city || "Gaza")
        currentDate: root.formattedDate()
        nextPrayerName: root.nextName()
        nextPrayerTime: root.nextTime()
        remaining: root.remainingText()
        nextKey: root.nextKey()
        times: root.todayTimesObject()
        errorText: root.errorText
        sourceText: root.sourceText
        onlineBusy: root.onlineBusy
        onRefreshRequested: root.refreshTimes(true)
    }

    Notification {
        id: reminderNotification
        componentName: "plasma_workspace"
        eventId: "notification"
        title: root.translate("reminderTitle")
        iconName: "clock"
        hints: ({ "suppress-sound": true })
    }

    Notification {
        id: prayerTimeNotification
        componentName: "plasma_workspace"
        eventId: "notification"
        title: root.translate("prayerTimeTitle")
        iconName: "clock"
        hints: ({ "suppress-sound": true })
    }

    MediaPlayer {
        id: reminderSoundEffect
        source: root.soundUrl(Plasmoid.configuration.reminderSound, "reminder-1.ogg")
        audioOutput: AudioOutput {
            volume: 1.0
        }
    }

    MediaPlayer {
        id: prayerTimeSoundEffect
        source: root.soundUrl(Plasmoid.configuration.prayerTimeSound, "prayer-time.ogg")
        audioOutput: AudioOutput {
            volume: 1.0
        }
    }

    Timer {
        id: onlineRequestTimeout
        interval: 15000
        repeat: false
        onTriggered: {
            for (var i = 0; i < root.activeRequests.length; ++i) {
                try {
                    root.activeRequests[i].abort()
                } catch (error) {
                    // Ignore an already completed request.
                }
            }
            root.onlineRequestGeneration += 1
            root.onlineBusy = false
            root.onlineError = root.translate("connectionTimeout")
            root.activeRequests = []
            root.refreshDisplay()
        }
    }

    Timer {
        interval: 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshTimes(false)
    }

    Connections {
        target: Plasmoid.configuration
        function onValueChanged() {
            if (root.writingInternalConfiguration) {
                return
            }
            var signature = root.userConfigurationSignature()
            if (signature === root.observedUserConfiguration) {
                return
            }
            root.observedUserConfiguration = signature
            root.onlineRequestGeneration += 1
            onlineRequestTimeout.stop()
            root.onlineBusy = false
            root.activeRequests = []
            root.onlineError = ""
            root.lastOnlineAttempt = 0
            root.refreshTimes(true)
        }
    }

    Component.onCompleted: {
        root.observedUserConfiguration = root.userConfigurationSignature()
        root.refreshTimes(true)
    }
}
