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

class MockUDisksDrive extends DBusObject {
  final bool canPowerOff;
  Map<String, DBusValue> configuration;
  final String connectionBus;
  final bool ejectable;
  final String id;
  final String media;
  final bool mediaAvailable;
  final bool mediaChangeDetected;
  final List<String> mediaCompatibility;
  final bool mediaRemovable;
  final String model;
  final bool optical;
  final bool opticalBlank;
  final int opticalNumTracks;
  final int opticalNumAudioTracks;
  final int opticalNumDataTracks;
  final int opticalNumSessions;
  final bool removable;
  final String revision;
  final int rotationRate;
  final String seat;
  final String serial;
  final String siblingId;
  final int size;
  final String sortKey;
  final int timeDetected;
  final int timeMediaDetected;
  final String vendor;
  final String wwn;

  var ejected = false;
  var poweredOff = false;

  MockUDisksDrive(this.id,
      {this.canPowerOff = false,
      this.configuration = const {},
      this.connectionBus = '',
      this.ejectable = false,
      this.media = '',
      this.mediaAvailable = false,
      this.mediaChangeDetected = false,
      this.mediaCompatibility = const [],
      this.mediaRemovable = false,
      this.model = '',
      this.optical = false,
      this.opticalBlank = false,
      this.opticalNumTracks = 0,
      this.opticalNumAudioTracks = 0,
      this.opticalNumDataTracks = 0,
      this.opticalNumSessions = 0,
      this.removable = false,
      this.revision = '',
      this.rotationRate = 0,
      this.seat = '',
      this.serial = '',
      this.siblingId = '',
      this.size = 0,
      this.sortKey = '',
      this.timeDetected = 0,
      this.timeMediaDetected = 0,
      this.vendor = '',
      this.wwn = ''})
      : super(DBusObjectPath('/org/freedesktop/UDisks2/drives/$id'));

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {
        'org.freedesktop.UDisks2.Drive': {
          'CanPowerOff': DBusBoolean(canPowerOff),
          'Configuration': DBusDict(
              DBusSignature('s'),
              DBusSignature('v'),
              configuration.map((key, value) =>
                  MapEntry(DBusString(key), DBusVariant(value)))),
          'ConnectionBus': DBusString(connectionBus),
          'Ejectable': DBusBoolean(ejectable),
          'Id': DBusString(id),
          'Media': DBusString(media),
          'MediaAvailable': DBusBoolean(mediaAvailable),
          'MediaChangeDetected': DBusBoolean(mediaChangeDetected),
          'MediaCompatibility': DBusArray(DBusSignature('s'),
              mediaCompatibility.map((value) => DBusString(value))),
          'MediaRemovable': DBusBoolean(mediaRemovable),
          'Model': DBusString(model),
          'Optical': DBusBoolean(optical),
          'OpticalBlank': DBusBoolean(opticalBlank),
          'OpticalNumTracks': DBusUint32(opticalNumTracks),
          'OpticalNumAudioTracks': DBusUint32(opticalNumAudioTracks),
          'OpticalNumDataTracks': DBusUint32(opticalNumDataTracks),
          'OpticalNumSessions': DBusUint32(opticalNumSessions),
          'Removable': DBusBoolean(removable),
          'Revision': DBusString(revision),
          'RotationRate': DBusInt32(rotationRate),
          'Seat': DBusString(seat),
          'Serial': DBusString(serial),
          'SiblingId': DBusString(siblingId),
          'Size': DBusUint64(size),
          'SortKey': DBusString(sortKey),
          'TimeDetected': DBusUint64(timeDetected),
          'TimeMediaDetected': DBusUint64(timeMediaDetected),
          'Vendor': DBusString(vendor),
          'WWN': DBusString(wwn)
        }
      };

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface != 'org.freedesktop.UDisks2.Drive') {
      return DBusMethodErrorResponse.unknownInterface();
    }

    switch (methodCall.name) {
      case 'Eject':
        ejected = true;
        return DBusMethodSuccessResponse([]);
      case 'SetConfiguration':
        configuration = (methodCall.values[0] as DBusDict).children.map((key,
                value) =>
            MapEntry((key as DBusString).value, (value as DBusVariant).value));
        return DBusMethodSuccessResponse([]);
      case 'PowerOff':
        poweredOff = true;
        return DBusMethodSuccessResponse([]);
      default:
        return DBusMethodErrorResponse.unknownMethod();
    }
  }
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

  Future<MockUDisksDrive> addDrive(String id,
      {bool canPowerOff = false,
      Map<String, DBusValue> configuration = const {},
      String connectionBus = '',
      bool ejectable = false,
      String media = '',
      bool mediaAvailable = false,
      bool mediaChangeDetected = false,
      List<String> mediaCompatibility = const [],
      bool mediaRemovable = false,
      String model = '',
      bool optical = false,
      bool opticalBlank = false,
      int opticalNumTracks = 0,
      int opticalNumAudioTracks = 0,
      int opticalNumDataTracks = 0,
      int opticalNumSessions = 0,
      bool removable = false,
      String revision = '',
      int rotationRate = 0,
      String seat = '',
      String serial = '',
      String siblingId = '',
      int size = 0,
      String sortKey = '',
      int timeDetected = 0,
      int timeMediaDetected = 0,
      String vendor = '',
      String wwn = ''}) async {
    var drive = MockUDisksDrive(id,
        canPowerOff: canPowerOff,
        configuration: configuration,
        connectionBus: connectionBus,
        ejectable: ejectable,
        media: media,
        mediaAvailable: mediaAvailable,
        mediaChangeDetected: mediaChangeDetected,
        mediaCompatibility: mediaCompatibility,
        mediaRemovable: mediaRemovable,
        model: model,
        optical: optical,
        opticalBlank: opticalBlank,
        opticalNumTracks: opticalNumTracks,
        opticalNumAudioTracks: opticalNumAudioTracks,
        opticalNumDataTracks: opticalNumDataTracks,
        opticalNumSessions: opticalNumSessions,
        removable: removable,
        revision: revision,
        rotationRate: rotationRate,
        seat: seat,
        serial: serial,
        siblingId: siblingId,
        size: size,
        sortKey: sortKey,
        timeDetected: timeDetected,
        timeMediaDetected: timeMediaDetected,
        vendor: vendor,
        wwn: wwn);
    await registerObject(drive);
    return drive;
  }

  void removeDrive(MockUDisksDrive drive) {
    unregisterObject(drive);
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

  test('no drives', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var upower = MockUDisksServer(clientAddress);
    await upower.start();

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.drives, isEmpty);

    await client.close();
  });

  test('drives', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var upower = MockUDisksServer(clientAddress);
    await upower.start();
    await upower.addDrive('drive1');
    await upower.addDrive('drive2');
    await upower.addDrive('drive3');

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.drives, hasLength(3));
    expect(client.drives[0].id, equals('drive1'));
    expect(client.drives[1].id, equals('drive2'));
    expect(client.drives[2].id, equals('drive3'));

    await client.close();
  });

  test('drive added', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var upower = MockUDisksServer(clientAddress);
    await upower.start();

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    client.driveAdded.listen(expectAsync1((drive) {
      expect(drive.id, equals('drive'));
    }));

    await upower.addDrive('drive');
  });

  test('drive removed', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var upower = MockUDisksServer(clientAddress);
    await upower.start();

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();
    var d = await upower.addDrive('drive');

    client.driveRemoved.listen(expectAsync1((drive) {
      expect(drive.id, equals('drive'));
    }));

    upower.removeDrive(d);
  });

  test('drive properties', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var upower = MockUDisksServer(clientAddress);
    await upower.start();
    await upower.addDrive('drive',
        canPowerOff: true,
        configuration: {'key1': DBusString('value1'), 'key2': DBusUint32(2)},
        connectionBus: 'CONNECTION-BUS',
        ejectable: true,
        media: 'thumb',
        mediaAvailable: true,
        mediaChangeDetected: true,
        mediaCompatibility: ['thumb', 'flash_sd'],
        mediaRemovable: true,
        model: 'MODEL',
        optical: true,
        opticalBlank: true,
        opticalNumTracks: 7,
        opticalNumAudioTracks: 6,
        opticalNumDataTracks: 1,
        opticalNumSessions: 3,
        removable: true,
        revision: '1.2.3',
        rotationRate: 300,
        seat: 'seat0',
        serial: 'SERIAL',
        siblingId: 'SIBLING-ID',
        size: 256000000000,
        sortKey: 'SORT-KEY',
        timeDetected: 123456789,
        timeMediaDetected: 135792348,
        vendor: 'VENDOR',
        wwn: 'WWN');

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.drives, hasLength(1));
    var drive = client.drives[0];
    expect(drive.canPowerOff, isTrue);
    expect(drive.configuration,
        equals({'key1': DBusString('value1'), 'key2': DBusUint32(2)}));
    expect(drive.connectionBus, equals('CONNECTION-BUS'));
    expect(drive.ejectable, isTrue);
    expect(drive.id, equals('drive'));
    expect(drive.media, equals('thumb'));
    expect(drive.mediaAvailable, isTrue);
    expect(drive.mediaChangeDetected, isTrue);
    expect(drive.mediaCompatibility, equals(['thumb', 'flash_sd']));
    expect(drive.mediaRemovable, isTrue);
    expect(drive.model, equals('MODEL'));
    expect(drive.optical, isTrue);
    expect(drive.opticalBlank, isTrue);
    expect(drive.opticalNumTracks, equals(7));
    expect(drive.opticalNumAudioTracks, equals(6));
    expect(drive.opticalNumDataTracks, equals(1));
    expect(drive.opticalNumSessions, equals(3));
    expect(drive.removable, isTrue);
    expect(drive.revision, equals('1.2.3'));
    expect(drive.rotationRate, equals(300));
    expect(drive.seat, equals('seat0'));
    expect(drive.serial, equals('SERIAL'));
    expect(drive.siblingId, equals('SIBLING-ID'));
    expect(drive.size, equals(256000000000));
    expect(drive.sortKey, equals('SORT-KEY'));
    expect(drive.timeDetected, equals(123456789));
    expect(drive.timeMediaDetected, equals(135792348));
    expect(drive.vendor, equals('VENDOR'));
    expect(drive.wwn, equals('WWN'));

    await client.close();
  });

  test('configure drive', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var upower = MockUDisksServer(clientAddress);
    await upower.start();
    var d = await upower.addDrive('drive');

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(d.configuration, isEmpty);
    expect(client.drives, hasLength(1));
    var drive = client.drives[0];
    await drive.setConfiguration(
        {'key1': DBusString('value1'), 'key2': DBusUint32(2)});
    expect(d.configuration,
        equals({'key1': DBusString('value1'), 'key2': DBusUint32(2)}));

    await client.close();
  });

  test('eject drive', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var upower = MockUDisksServer(clientAddress);
    await upower.start();
    var d = await upower.addDrive('drive');

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(d.ejected, isFalse);
    expect(client.drives, hasLength(1));
    var drive = client.drives[0];
    await drive.eject();
    expect(d.ejected, isTrue);

    await client.close();
  });

  test('power off drive', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var upower = MockUDisksServer(clientAddress);
    await upower.start();
    var d = await upower.addDrive('drive');

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(d.poweredOff, isFalse);
    expect(client.drives, hasLength(1));
    var drive = client.drives[0];
    await drive.powerOff();
    expect(d.poweredOff, isTrue);

    await client.close();
  });
}
