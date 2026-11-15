.pragma library

var PRAYER_ORDER = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];
var DISPLAY_ORDER = ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"];

var ARABIC_NAMES = {
    Fajr: "الفجر",
    Sunrise: "الشروق",
    Dhuhr: "الظهر",
    Asr: "العصر",
    Maghrib: "المغرب",
    Isha: "العشاء"
};

function toNumber(value, fallback) {
    var parsed = Number(value);
    return isFinite(parsed) ? parsed : fallback;
}

function pad(value) {
    return value < 10 ? "0" + value : String(value);
}

function dayStart(date) {
    return new Date(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0, 0);
}

function addDays(date, days) {
    var next = new Date(date.getTime());
    next.setDate(next.getDate() + days);
    return next;
}

function calendarDateForZone(date, settings) {
    var zone = settings && settings.timezone ? String(settings.timezone) : "";
    if (zone && typeof Intl !== "undefined" && Intl.DateTimeFormat) {
        try {
            var parts = new Intl.DateTimeFormat("en-US", {
                timeZone: zone,
                year: "numeric",
                month: "2-digit",
                day: "2-digit"
            }).formatToParts(date);
            var values = {};
            for (var i = 0; i < parts.length; ++i) {
                values[parts[i].type] = parts[i].value;
            }
            return new Date(Number(values.year), Number(values.month) - 1, Number(values.day), 12, 0, 0, 0);
        } catch (e) {
            // Fall through to the device calendar date.
        }
    }
    return new Date(date.getFullYear(), date.getMonth(), date.getDate(), 12, 0, 0, 0);
}

function degToRad(degrees) {
    return degrees * Math.PI / 180.0;
}

function radToDeg(radians) {
    return radians * 180.0 / Math.PI;
}

function fixAngle(angle) {
    var fixed = angle % 360.0;
    return fixed < 0 ? fixed + 360.0 : fixed;
}

function fixHour(hour) {
    var fixed = hour % 24.0;
    return fixed < 0 ? fixed + 24.0 : fixed;
}

function julianDate(date) {
    var year = date.getFullYear();
    var month = date.getMonth() + 1;
    var day = date.getDate();

    if (month <= 2) {
        year -= 1;
        month += 12;
    }

    var a = Math.floor(year / 100);
    var b = 2 - a + Math.floor(a / 4);
    return Math.floor(365.25 * (year + 4716))
            + Math.floor(30.6001 * (month + 1))
            + day + b - 1524.5;
}

function sunPosition(jd) {
    var d = jd - 2451545.0;
    var g = fixAngle(357.529 + 0.98560028 * d);
    var q = fixAngle(280.459 + 0.98564736 * d);
    var l = fixAngle(q + 1.915 * Math.sin(degToRad(g)) + 0.020 * Math.sin(degToRad(2 * g)));
    var e = 23.439 - 0.00000036 * d;

    var rightAscension = radToDeg(Math.atan2(Math.cos(degToRad(e)) * Math.sin(degToRad(l)), Math.cos(degToRad(l)))) / 15.0;
    rightAscension = fixHour(rightAscension);

    var declination = radToDeg(Math.asin(Math.sin(degToRad(e)) * Math.sin(degToRad(l))));
    var equation = q / 15.0 - rightAscension;

    return {
        declination: declination,
        equation: equation
    };
}

function equationOfTime(jd) {
    return sunPosition(jd).equation;
}

function solarDeclination(jd) {
    return sunPosition(jd).declination;
}

function timezoneOffsetHours(date, settings) {
    var zone = settings && settings.timezone ? String(settings.timezone) : "";

    // Uses the JavaScript engine's local timezone database when it is present.
    // This remains offline; no network lookup is involved.
    if (zone && typeof Intl !== "undefined" && Intl.DateTimeFormat) {
        try {
            var parts = new Intl.DateTimeFormat("en-US", {
                timeZone: zone,
                year: "numeric",
                month: "2-digit",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit",
                second: "2-digit",
                hourCycle: "h23"
            }).formatToParts(date);

            var values = {};
            for (var i = 0; i < parts.length; i++) {
                values[parts[i].type] = parts[i].value;
            }

            var asUtc = Date.UTC(Number(values.year), Number(values.month) - 1, Number(values.day),
                                 Number(values.hour), Number(values.minute), Number(values.second));
            return (asUtc - date.getTime()) / 3600000.0;
        } catch (e) {
            // Fall through to system local timezone.
        }
    }

    return -date.getTimezoneOffset() / 60.0;
}

function timeDiffForAngle(latitude, declination, angle) {
    var lat = degToRad(latitude);
    var dec = degToRad(declination);
    var a = degToRad(angle);
    var numerator = -Math.sin(a) - Math.sin(lat) * Math.sin(dec);
    var denominator = Math.cos(lat) * Math.cos(dec);
    var value = numerator / denominator;

    if (value < -1 || value > 1 || !isFinite(value)) {
        return NaN;
    }

    return radToDeg(Math.acos(value)) / 15.0;
}

function asrTimeDiff(latitude, declination, factor) {
    var latDiff = Math.abs(latitude - declination);
    var angle = -radToDeg(Math.atan(1.0 / (factor + Math.tan(degToRad(latDiff)))));
    return timeDiffForAngle(latitude, declination, angle);
}

function hourToDate(baseDate, hour, settings) {
    var normalized = fixHour(hour);
    var wholeHours = Math.floor(normalized);
    var totalSeconds = Math.round((normalized - wholeHours) * 3600.0);
    var utcClock = Date.UTC(baseDate.getFullYear(), baseDate.getMonth(), baseDate.getDate(),
                            wholeHours, 0, totalSeconds, 0);

    // Convert the calculated wall-clock time in the configured zone to an instant.
    // A second pass handles daylight-saving transitions around this date.
    var offset = timezoneOffsetHours(new Date(utcClock), settings);
    var instant = utcClock - offset * 3600000.0;
    var correctedOffset = timezoneOffsetHours(new Date(instant), settings);
    if (correctedOffset !== offset) {
        instant = utcClock - correctedOffset * 3600000.0;
    }
    return new Date(instant);
}

function calculatePrayerTimes(date, settings) {
    settings = settings || {};

    var latitude = toNumber(settings.latitude, 31.5017);
    var longitude = toNumber(settings.longitude, 34.4668);
    var fajrAngle = toNumber(settings.fajrAngle, 18.0);
    var ishaAngle = toNumber(settings.ishaAngle, 17.5);
    var asrFactor = toNumber(settings.asrFactor, 1);

    var offsetProbe = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate(), 12, 0, 0));
    var tz = timezoneOffsetHours(offsetProbe, settings);
    var jd = julianDate(date) - longitude / (15.0 * 24.0);
    var position = sunPosition(jd);

    var dhuhr = fixHour(12.0 + tz - longitude / 15.0 - position.equation);
    var sunriseDiff = timeDiffForAngle(latitude, position.declination, 0.833);
    var fajrDiff = timeDiffForAngle(latitude, position.declination, fajrAngle);
    var ishaDiff = timeDiffForAngle(latitude, position.declination, ishaAngle);
    var asrDiff = asrTimeDiff(latitude, position.declination, asrFactor);

    if (!isFinite(sunriseDiff) || !isFinite(fajrDiff) || !isFinite(ishaDiff) || !isFinite(asrDiff)) {
        throw new Error("Unable to calculate prayer times for this location/date.");
    }

    var times = {
        Fajr: hourToDate(date, dhuhr - fajrDiff, settings),
        Sunrise: hourToDate(date, dhuhr - sunriseDiff, settings),
        Dhuhr: hourToDate(date, dhuhr, settings),
        Asr: hourToDate(date, dhuhr + asrDiff, settings),
        Maghrib: hourToDate(date, dhuhr + sunriseDiff, settings),
        Isha: hourToDate(date, dhuhr + ishaDiff, settings)
    };

    return applyOffsets(times, {
        Fajr: settings.fajrOffset,
        Dhuhr: settings.dhuhrOffset,
        Asr: settings.asrOffset,
        Maghrib: settings.maghribOffset,
        Isha: settings.ishaOffset
    });
}

function applyOffsets(prayerTimes, offsets) {
    offsets = offsets || {};
    var result = {};
    for (var key in prayerTimes) {
        if (!prayerTimes.hasOwnProperty(key)) {
            continue;
        }
        var minutes = toNumber(offsets[key], 0);
        result[key] = new Date(prayerTimes[key].getTime() + minutes * 60000);
    }
    return result;
}

function getNextPrayer(prayerTimes, now) {
    now = now || new Date();

    for (var i = 0; i < PRAYER_ORDER.length; i++) {
        var key = PRAYER_ORDER[i];
        var time = prayerTimes[key];
        if (time && time.getTime() > now.getTime()) {
            return {
                key: key,
                name: ARABIC_NAMES[key] || key,
                time: time,
                remaining: time.getTime() - now.getTime(),
                isTomorrow: false
            };
        }
    }

    return null;
}

function formatTime(date, use12Hour) {
    if (!date || !isFinite(date.getTime())) {
        return "--:--";
    }
    var hours = date.getHours();
    var minutes = pad(date.getMinutes());

    if (use12Hour) {
        var suffix = hours >= 12 ? "PM" : "AM";
        var hour12 = hours % 12;
        if (hour12 === 0) {
            hour12 = 12;
        }
        return hour12 + ":" + minutes + " " + suffix;
    }

    return pad(hours) + ":" + minutes;
}

function formatTimeForZone(date, use12Hour, timezone) {
    if (!date || !isFinite(date.getTime())) {
        return "--:--";
    }

    if (timezone && typeof Intl !== "undefined" && Intl.DateTimeFormat) {
        try {
            var parts = new Intl.DateTimeFormat("en-US", {
                timeZone: timezone,
                hour: "2-digit",
                minute: "2-digit",
                hourCycle: use12Hour ? "h12" : "h23"
            }).formatToParts(date);
            var values = {};
            for (var i = 0; i < parts.length; ++i) {
                values[parts[i].type] = parts[i].value;
            }

            var hour = values.hour || "--";
            if (use12Hour && hour.length > 1 && hour.charAt(0) === "0") {
                hour = hour.substring(1);
            }
            var result = hour + ":" + (values.minute || "--");
            if (use12Hour && values.dayPeriod) {
                result += " " + values.dayPeriod;
            }
            return result;
        } catch (e) {
            // Fall back to the device timezone.
        }
    }

    return formatTime(date, use12Hour);
}

function formatRemaining(milliseconds) {
    if (!isFinite(milliseconds) || milliseconds < 0) {
        milliseconds = 0;
    }
    var totalMinutes = Math.ceil(milliseconds / 60000);
    var hours = Math.floor(totalMinutes / 60);
    var minutes = totalMinutes % 60;
    return pad(hours) + ":" + pad(minutes);
}

function arabicName(key) {
    return ARABIC_NAMES[key] || key;
}

function calculateFromTimes(today, tomorrow, now) {
    now = now || new Date();
    var next = getNextPrayer(today, now);

    if (!next && tomorrow && tomorrow.Fajr) {
        next = {
            key: "Fajr",
            name: ARABIC_NAMES.Fajr,
            time: tomorrow.Fajr,
            remaining: tomorrow.Fajr.getTime() - now.getTime(),
            isTomorrow: true
        };
    }

    return {
        now: now,
        today: today,
        tomorrow: tomorrow,
        next: next
    };
}

function calculateForTodayAndTomorrow(settings) {
    var now = new Date();
    var todayDate = calendarDateForZone(now, settings);
    var today = calculatePrayerTimes(todayDate, settings);
    var tomorrowDate = addDays(todayDate, 1);
    var tomorrow = calculatePrayerTimes(tomorrowDate, settings);
    return calculateFromTimes(today, tomorrow, now);
}
