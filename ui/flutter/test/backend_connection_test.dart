import 'package:flutter_test/flutter_test.dart';
import 'package:onyx_essential_ui/backend/backend_connection.dart';

void main() {
  test('paused controls are Disabled, not Live or a fake Offline', () {
    expect(
      OnyxConnectionState.online.serviceLabel(enabled: false),
      'Disabled',
    );
    expect(OnyxConnectionState.online.serviceLabel(enabled: true), 'Live');
    expect(
      OnyxConnectionState.offline.serviceLabel(enabled: false),
      'Offline',
    );
    expect(
      OnyxConnectionState.connecting.serviceLabel(enabled: false),
      'Connecting',
    );
  });
  test('only a successful handshake is Live', () {
    expect(OnyxConnectionState.fromNative(1), OnyxConnectionState.online);
    expect(OnyxConnectionState.fromNative(1).badgeLabel, 'LIVE');
  });

  test('startup and a confirmed connection failure remain distinct', () {
    expect(
      OnyxConnectionState.fromNative(-1),
      OnyxConnectionState.connecting,
    );
    expect(OnyxConnectionState.fromNative(-1).badgeLabel, 'CONNECTING');
    expect(OnyxConnectionState.fromNative(0), OnyxConnectionState.offline);
    expect(OnyxConnectionState.fromNative(0).badgeLabel, 'OFFLINE');
  });
}
