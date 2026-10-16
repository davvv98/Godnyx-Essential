# System colors and display

These use separate control paths:

- Material You colors are queried/applied through SettingsProvider and system
  capabilities. Results depend on the ROM.
- Panel calibration uses the vendor Xiaomi DisplayFeature AIDL service.

A present service and an accepted call do not prove a visible color change.
Calibration IDs and effects require validation on the device port. Onyx does
not use Oplus Display for this path.

For diagnostics, attempt the change and inspect the snapshot and OnyxEssential
logs. Distinguish Android interface palette changes from panel image calibration.
