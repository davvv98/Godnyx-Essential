# Onyx Essential changelog

## 1.18.5

POCO F7 adaptation revision; current protocol: `onyx.4`. This log describes
the delivered source and does not imply that a release has already been published.

- Disable implicit Rust binary discovery: only onyx_daemon/onyx_ctl are built;
  remove explicitly renamed legacy files before compilation.
- Replace touch choices with OEM (125 Hz observed), game mode (250 Hz observed)
  and disabled 480 Hz pending adaptation. Remove the 1000 Hz option.
- Add Qualcomm KGSL telemetry and profiles based on real OPPs.
- Support CPU policies 0/2/5/7 with exact frequency conversion to kHz.
- Separate saved requests from effective bounds; retain IO and invalid-read errors.
- Remove periodic frequency rewrites triggered by drift.
- Add Xiaomi Sconfig Normal, Game, NoLimits and Performance variants, including
  original-value capture, restoration, persistence and live readback.
- Use package `io.github.davvv98.onyxessential`, `OnyxActivity`,
  `onyx_daemon`/`onyx_ctl`, Onyx JNI and native APIs.
- Add the Onyx logo, launcher/adaptive icons and grouped Sconfig cards.
- Update GitHub Actions, ONYX_* signing variables and Flutter engine symbol
  stripping before APK packaging.
- Update documentation for Onyx hardware and current implementation status.

### Pending adaptation or validation

- Fixed-rate touch and resampling, charging power profiles and bypass.
- Xiaomi DisplayFeature effects on the device port.
- Native ROM integration and SELinux policies.
- Final APK build and visual validation of the new identity and Sconfig panel.

## Origin

Derived from Rodin Essential by NEESCHAL-3 and contributors. This log describes
Onyx changes and does not replace upstream history or authorship.
See [CREDITS.md](CREDITS.md).
