# Releasing Prayer Times

## Before the first release

1. Create a Plasma 6 widget entry on KDE Store.
2. Upload `prayertimes-widget.plasmoid` as the first downloadable file.
3. Keep the plugin ID `com.mo7ammed.prayertimes` unchanged in every release.

Users should install the widget from KDE's **Get New Widgets** dialog. This
allows KDE's KNewStuff service to associate the installed widget with its store
entry and offer future updates.

## Publish a new version

1. Update `KPlugin.Version` in `metadata.json`, using semantic versioning.
2. Commit and push the change to `main`.
3. Tag that commit with the same version, prefixed with `v`, then push the tag:

   ```bash
   git tag -a v1.5.1 -m "Release 1.5.1"
   git push origin main
   git push origin v1.5.1
   ```

The release workflow validates that the tag matches `metadata.json`, builds the
widget, creates a SHA-256 checksum, and attaches both files to a GitHub Release.

Download the generated `.plasmoid` file from that release and add it as a new
version of the existing KDE Store entry. Set the store version to exactly the
same value, for example `1.5.1`, and include the release notes.

## Local checks

```bash
./scripts/validate.sh
./package.sh
unzip -l prayertimes-widget.plasmoid
```

To check a release tag before pushing it:

```bash
./scripts/validate.sh v1.5.1
```
