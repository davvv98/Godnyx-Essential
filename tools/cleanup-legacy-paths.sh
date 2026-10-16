#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# Explicitly renamed paths only. A replacement must exist before removing a
# stale source; licenses, notices, credits and author history are untouched.
while IFS='|' read -r old replacement; do
    [ -n "$old" ] || continue
    if [ -f "$ROOT/$old" ]; then
        if [ ! -f "$ROOT/$replacement" ]; then
            echo "Refusing cleanup: replacement missing: $replacement" >&2
            exit 1
        fi
        rm -- "$ROOT/$old"
        echo "Removed stale renamed source: $old"
    fi
done <<'PATHS'
runtime/daemon-rust/src/bin/rodin_essentiald.rs|runtime/daemon-rust/src/bin/onyx_daemon.rs
runtime/daemon-rust/src/bin/rodin_essentialctl.rs|runtime/daemon-rust/src/bin/onyx_ctl.rs
android/platform/io/github/neeschal/rodinessential/RodinActivity.java|android/platform/io/github/davvv98/onyxessential/OnyxActivity.java
android/platform/io/github/neeschal/rodinessential/BypassTileService.java|android/platform/io/github/davvv98/onyxessential/BypassTileService.java
ui/flutter/lib/backend/rodin_backend.dart|ui/flutter/lib/backend/onyx_backend.dart
android/aosp/BoardConfigRodinEssential.mk|android/aosp/BoardConfigOnyxEssential.mk
android/aosp/rodin-essential.mk|android/aosp/onyx-essential.mk
android/aosp/rodin_daemon.rc|android/aosp/onyx_daemon.rc
android/aosp/sepolicy/product/private/rodin_app.te|android/aosp/sepolicy/product/private/onyx_app.te
android/aosp/sepolicy/product/private/rodin_daemon.te|android/aosp/sepolicy/product/private/onyx_daemon.te
android/aosp/sepolicy/product/public/rodin_daemon.te|android/aosp/sepolicy/product/public/onyx_daemon.te
android/aosp/sepolicy/vendor/rodin_daemon.te|android/aosp/sepolicy/vendor/onyx_daemon.te
android/unpacked/rodin-native.cil|android/unpacked/onyx-native.cil
PATHS
