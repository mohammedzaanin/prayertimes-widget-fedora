# Prayer Times

Prayer Times is a KDE Plasma 6 widget that updates daily prayer times from AlAdhan when connected and automatically falls back to local JavaScript/QML calculations when offline.

## Features

- Online prayer time updates based on coordinates, timezone, and Asr school.
- A Gaza local preset based on the Egyptian General Authority of Survey method
  (19.5° Fajr / 17.5° Isha) with local minute corrections.
- Cached online times for continued use during temporary connection problems.
- Offline astronomical prayer time calculations as an automatic fallback.
- A configurable reminder before every obligatory prayer (30 minutes by default).
- A second notification when the prayer time begins.
- Bundled selectable sounds for reminders and prayer-time notifications, with previews in settings.
- Compact panel view with the next prayer, time, and remaining countdown.
- Full popup view with today's Fajr, Sunrise, Dhuhr, Asr, Maghrib, and Isha times.
- Configurable city, latitude, longitude, timezone, Fajr angle, Isha angle, Asr method, and manual minute offsets.
- Supports Shafi and Hanafi Asr calculation factors.
- Optional panel icon and multiple panel display modes.
- 12-hour AM/PM time format by default, with an optional 24-hour format.
- System-following, dark, and light appearance modes with live KDE theme integration.
- Arabic and English interfaces with automatic RTL/LTR layout switching.
- A scrollable popup with an always-visible prayer-time source footer.

## Preview During Development

```bash
plasmoidviewer -a ./com.mo7ammed.prayertimes
```

## Package

```bash
./package.sh
```

This creates:

```bash
prayertimes-widget.plasmoid
```

Every push and pull request is also packaged by GitHub Actions. Pushing a tag
such as `v1.5.1` creates a GitHub Release when the tag matches the version in
`metadata.json`. See [RELEASING.md](RELEASING.md) for the complete release and
KDE Store update process.

## Install from KDE Store

Once the widget is published, install it from Plasma's **Add Widgets** →
**Get New Widgets** dialog. Installing from the store lets KDE offer subsequent
versions without cloning this repository or running the installation commands
again.

## Install

```bash
kpackagetool6 --type Plasma/Applet --install prayertimes-widget.plasmoid
```

## Upgrade

```bash
kpackagetool6 --type Plasma/Applet --upgrade prayertimes-widget.plasmoid
```

## Remove

```bash
kpackagetool6 --type Plasma/Applet --remove com.mo7ammed.prayertimes
```

## Notes

Online times are fetched only at startup, when the date or location settings change, or when the refresh button is pressed. The widget does not send location data other than the configured latitude, longitude, timezone, and Asr school required by the prayer-times request.

Prayer-time calculation methods can differ from a local mosque or an official timetable. Use the offset settings to match your local mosque, ministry, or waqf timetable. When the online service is unavailable, the locally calculated times remain approximate astronomical estimates.

The default configuration is set for Gaza:

- City: Gaza
- Latitude: 31.5017
- Longitude: 34.4668
- Timezone: Asia/Gaza
- Calculation preset: Gaza local
- Gaza preset angles: Fajr 19.5, Isha 17.5
- Gaza local corrections: Asr -1 min, Maghrib +4 min, Isha +1 min
- Asr factor: 1
