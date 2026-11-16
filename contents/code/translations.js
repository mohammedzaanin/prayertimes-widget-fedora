.pragma library

var STRINGS = {
    ar: {
        cityGaza: "غزة",
        nextPrayer: "الصلاة القادمة",
        remaining: "باقي",
        todayTimes: "مواقيت اليوم",
        refresh: "تحديث مواقيت الصلاة",
        calculationError: "تعذر حساب المواقيت. تحقق من الإحداثيات والإعدادات.",
        sourceGaza: "المصدر: توقيت غزة المحلي",
        sourceGazaCachedFailed: "توقيت غزة المحلي المحفوظ • تعذر التحديث",
        sourceGazaOffline: "المصدر: توقيت غزة المحلي • حساب دون إنترنت",
        sourceInternet: "المصدر: الإنترنت • %1",
        sourceInternetCachedFailed: "بيانات الإنترنت المحفوظة • تعذر التحديث",
        sourceLocal: "المصدر: حساب محلي",
        sourceLocalUpdating: "حساب محلي • جارٍ تحديث الإنترنت…",
        sourceLocalNoInternet: "حساب محلي • تعذر الاتصال بالإنترنت",
        automaticSource: "المصدر التلقائي",
        reminderTitle: "تذكير بموعد الصلاة",
        prayerTimeTitle: "حان وقت الصلاة",
        reminderText: "متبقي %1 دقيقة على صلاة %2 (%3)",
        prayerTimeText: "حان الآن موعد صلاة %1 (%2)",
        connectionTimeout: "انتهت مهلة الاتصال",
        responseError: "تعذر قراءة استجابة خدمة المواقيت",
        languageLabel: "اللغة:",
        systemLanguage: "لغة النظام",
        arabic: "العربية",
        english: "الإنجليزية",
        appearanceSection: "المظهر",
        themeLabel: "الثيم:",
        systemTheme: "حسب النظام",
        darkTheme: "داكن",
        lightTheme: "فاتح",
        prayerSettingsSection: "إعدادات المواقيت",
        cityLabel: "المدينة:",
        latitudeLabel: "خط العرض:",
        longitudeLabel: "خط الطول:",
        timezoneLabel: "المنطقة الزمنية:",
        calculationMethodLabel: "طريقة الحساب:",
        gazaLocal: "توقيت غزة المحلي (19.5° / 17.5°)",
        automaticByLocation: "تلقائي حسب الموقع",
        onlineTimesLabel: "مواقيت الإنترنت:",
        onlineUpdate: "التحديث تلقائيًا عند الاتصال",
        fajrAngleLabel: "زاوية الفجر:",
        ishaAngleLabel: "زاوية العشاء:",
        asrMethodLabel: "مذهب العصر:",
        shafi: "شافعي",
        hanafi: "حنفي",
        fajrOffsetLabel: "تعديل الفجر (دقيقة):",
        dhuhrOffsetLabel: "تعديل الظهر (دقيقة):",
        asrOffsetLabel: "تعديل العصر (دقيقة):",
        maghribOffsetLabel: "تعديل المغرب (دقيقة):",
        ishaOffsetLabel: "تعديل العشاء (دقيقة):",
        panelIconLabel: "أيقونة اللوحة:",
        showMosqueIcon: "إظهار أيقونة المسجد",
        timeFormatLabel: "تنسيق الوقت:",
        twelveHour: "12 ساعة ص/م",
        twentyFourHour: "24 ساعة",
        panelLayoutLabel: "تنسيق اللوحة:",
        horizontal: "أفقي",
        compact: "مضغوط",
        vertical: "عمودي",
        notificationsSection: "الإشعارات",
        notificationsLabel: "التنبيهات:",
        enablePrayerNotifications: "تفعيل إشعارات الصلاة",
        reminderLabel: "التذكير:",
        notifyBeforePrayer: "إشعار قبل موعد الصلاة",
        reminderMinutesLabel: "قبل الصلاة (دقيقة):",
        prayerTimeLabel: "وقت الصلاة:",
        notifyAtPrayerTime: "إشعار عند دخول وقت الصلاة",
        soundsLabel: "الأصوات:",
        enableNotificationSounds: "تشغيل صوت مع الإشعارات",
        reminderSoundLabel: "صوت التذكير:",
        prayerSoundLabel: "صوت وقت الصلاة:",
        soundReminderOne: "تذكير 1",
        soundReminderTwo: "تذكير 2",
        soundPrayerTime: "وقت الصلاة",
        previewSound: "تجربة الصوت"
    },
    en: {
        cityGaza: "Gaza",
        nextPrayer: "Next prayer",
        remaining: "Remaining",
        todayTimes: "Today's prayer times",
        refresh: "Refresh prayer times",
        calculationError: "Unable to calculate prayer times. Check the coordinates and settings.",
        sourceGaza: "Source: Gaza local time",
        sourceGazaCachedFailed: "Saved Gaza local time • Update failed",
        sourceGazaOffline: "Source: Gaza local time • Offline calculation",
        sourceInternet: "Source: Internet • %1",
        sourceInternetCachedFailed: "Saved online data • Update failed",
        sourceLocal: "Source: Local calculation",
        sourceLocalUpdating: "Local calculation • Updating online data…",
        sourceLocalNoInternet: "Local calculation • Unable to connect",
        automaticSource: "Automatic source",
        reminderTitle: "Prayer time reminder",
        prayerTimeTitle: "It is time to pray",
        reminderText: "%1 minutes remaining until %2 prayer (%3)",
        prayerTimeText: "It is now time for %1 prayer (%2)",
        connectionTimeout: "Connection timed out",
        responseError: "Unable to read the prayer times service response",
        languageLabel: "Language:",
        systemLanguage: "System language",
        arabic: "Arabic",
        english: "English",
        appearanceSection: "Appearance",
        themeLabel: "Theme:",
        systemTheme: "Follow system",
        darkTheme: "Dark",
        lightTheme: "Light",
        prayerSettingsSection: "Prayer-time settings",
        cityLabel: "City:",
        latitudeLabel: "Latitude:",
        longitudeLabel: "Longitude:",
        timezoneLabel: "Timezone:",
        calculationMethodLabel: "Calculation method:",
        gazaLocal: "Gaza local (19.5° / 17.5°)",
        automaticByLocation: "Automatic by location",
        onlineTimesLabel: "Online times:",
        onlineUpdate: "Update automatically when connected",
        fajrAngleLabel: "Fajr angle:",
        ishaAngleLabel: "Isha angle:",
        asrMethodLabel: "Asr method:",
        shafi: "Shafi",
        hanafi: "Hanafi",
        fajrOffsetLabel: "Fajr offset (min):",
        dhuhrOffsetLabel: "Dhuhr offset (min):",
        asrOffsetLabel: "Asr offset (min):",
        maghribOffsetLabel: "Maghrib offset (min):",
        ishaOffsetLabel: "Isha offset (min):",
        panelIconLabel: "Panel icon:",
        showMosqueIcon: "Show mosque icon",
        timeFormatLabel: "Time format:",
        twelveHour: "12-hour AM/PM",
        twentyFourHour: "24-hour",
        panelLayoutLabel: "Panel layout:",
        horizontal: "Horizontal",
        compact: "Compact",
        vertical: "Vertical",
        notificationsSection: "Notifications",
        notificationsLabel: "Notifications:",
        enablePrayerNotifications: "Enable prayer notifications",
        reminderLabel: "Reminder:",
        notifyBeforePrayer: "Notify before prayer time",
        reminderMinutesLabel: "Before prayer (minutes):",
        prayerTimeLabel: "Prayer time:",
        notifyAtPrayerTime: "Notify when prayer time begins",
        soundsLabel: "Sounds:",
        enableNotificationSounds: "Play a sound with notifications",
        reminderSoundLabel: "Reminder sound:",
        prayerSoundLabel: "Prayer-time sound:",
        soundReminderOne: "Reminder 1",
        soundReminderTwo: "Reminder 2",
        soundPrayerTime: "Prayer time",
        previewSound: "Preview sound"
    }
};

var PRAYER_NAMES = {
    ar: {
        Fajr: "الفجر",
        Sunrise: "الشروق",
        Dhuhr: "الظهر",
        Asr: "العصر",
        Maghrib: "المغرب",
        Isha: "العشاء"
    },
    en: {
        Fajr: "Fajr",
        Sunrise: "Sunrise",
        Dhuhr: "Dhuhr",
        Asr: "Asr",
        Maghrib: "Maghrib",
        Isha: "Isha"
    }
};

function resolveLanguage(configuredLanguage, localeName) {
    if (configuredLanguage === "ar" || configuredLanguage === "en") {
        return configuredLanguage;
    }
    return String(localeName || "").toLowerCase().indexOf("ar") === 0 ? "ar" : "en";
}

function text(language, key) {
    var dictionary = STRINGS[language] || STRINGS.en;
    return dictionary[key] !== undefined ? dictionary[key] : (STRINGS.en[key] || key);
}

function format(language, key, values) {
    var result = text(language, key);
    values = values || [];
    for (var i = 0; i < values.length; ++i) {
        result = result.split("%" + (i + 1)).join(String(values[i]));
    }
    return result;
}

function prayerName(language, key) {
    var names = PRAYER_NAMES[language] || PRAYER_NAMES.en;
    return names[key] || key;
}
