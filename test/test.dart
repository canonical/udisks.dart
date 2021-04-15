import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:test/test.dart';
import 'package:udisks/udisks.dart';

class MockUDisksManager extends DBusObject {
  final MockUDisksServer server;
  MockUDisksManager(this.server)
      : super(DBusObjectPath('/org/freedesktop/UDisks2/Manager'));

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {
        'org.freedesktop.UDisks2.Manager': {
          'DefaultEncryptionType': DBusString(server.defaultEncryptionType),
          'SupportedEncryptionTypes': DBusArray(DBusSignature('s'),
              server.supportedEncryptionTypes.map((type) => DBusString(type))),
          'SupportedFilesystems': DBusArray(DBusSignature('s'),
              server.supportedFilesystems.map((name) => DBusString(name))),
          'Version': DBusString(server.version)
        }
      };
}

class MockUDisksServer extends DBusClient {
  final DBusObject _root = DBusObject(
      DBusObjectPath('/org/freedesktop/UDisks2'),
      isObjectManager: true);
  late final MockUDisksManager _manager;

  final String defaultEncryptionType;
  final List<String> supportedEncryptionTypes;
  final List<String> supportedFilesystems;
  final String version;

  MockUDisksServer(DBusAddress clientAddress,
      {this.defaultEncryptionType = '',
      this.supportedEncryptionTypes = const [],
      this.supportedFilesystems = const [],
      this.version = ''})
      : super(clientAddress);

  Future<void> start() async {
    await requestName('org.freedesktop.UDisks2');
    await registerObject(_root);

    _manager = MockUDisksManager(this);
    await registerObject(_manager);
  }
}

void main() {
  test('daemon version', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var upower = MockUDisksServer(clientAddress, version: '1.2.3');
    await upower.start();

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.version, equals('1.2.3'));

    await client.close();
  });

  test('encryption types', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var upower = MockUDisksServer(clientAddress,
        supportedEncryptionTypes: ['luks1', 'luks2'],
        defaultEncryptionType: 'luks1');
    await upower.start();

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.supportedEncryptionTypes, equals(['luks1', 'luks2']));
    expect(client.defaultEncryptionType, equals('luks1'));

    await client.close();
  });

  test('filesystems', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var upower = MockUDisksServer(clientAddress, supportedFilesystems: [
      'ext2',
      'ext3',
      'ext4',
      'vfat',
      'exfat',
      'brtfs',
      'swap'
    ]);
    await upower.start();

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.supportedFilesystems,
        equals(['ext2', 'ext3', 'ext4', 'vfat', 'exfat', 'brtfs', 'swap']));

    await client.close();
  });
}
