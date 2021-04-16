import 'dart:convert';
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

class MockUDisksBlockDevice extends DBusObject {
  List<UDisksConfigurationItem> configuration;
  final MockUDisksBlockDevice? cryptoBackingDevice;
  final List<int> device;
  final int deviceNumber;
  final MockUDisksDrive? drive;
  final bool hintAuto;
  final String hintIconName;
  final bool hintIgnore;
  final String hintName;
  final bool hintPartitionable;
  final String hintSymbolicIconName;
  final bool hintSystem;
  final String id;
  final String idLabel;
  final String idType;
  final String idUsage;
  final String idUUID;
  final String idVersion;
//final DBusObjectPath mdRaid;
//final DBusObjectPath mdRaidMember;
  final List<int> preferredDevice;
  final bool readOnly;
  final int size;
  final List<List<int>> symlinks;
  final List<String> userspaceMountOptions;

  String? formatType;
  bool? formatTakeOwnership;
  dynamic? formatEncryptPassphrase;
  String? formatErase;
  bool? formatUpdatePartitionType;
  bool? formatNoBlock;
  bool? formatDryRunFirst;
  bool? formatNoDiscard;
  List<UDisksConfigurationItem>? formatConfigItems;
  bool? formatTearDown;

  bool rescanned = false;

  MockUDisksBlockDevice(
    String name, {
    List<UDisksConfigurationItem>? configuration,
    this.cryptoBackingDevice,
    this.device = const [],
    this.deviceNumber = 0,
    this.drive,
    this.id = '',
    this.idLabel = '',
    this.idType = '',
    this.idUsage = '',
    this.idVersion = '',
    this.idUUID = '',
    this.hintAuto = false,
    this.hintIconName = '',
    this.hintIgnore = false,
    this.hintName = '',
    this.hintPartitionable = false,
    this.hintSymbolicIconName = '',
    this.hintSystem = false,
    this.preferredDevice = const [],
    this.readOnly = false,
    this.size = 0,
    this.symlinks = const [],
    this.userspaceMountOptions = const [],
  })  : configuration = configuration ?? [],
        super(DBusObjectPath('/org/freedesktop/UDisks2/block_devices/$name'));

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {
        'org.freedesktop.UDisks2.Block': {
          'Configuration': DBusArray(
              DBusSignature('(sa{sv})'),
              configuration
                  .where((item) => !item.type.startsWith('secret-'))
                  .map((item) => _encodeConfigurationItem(item))),
          'CryptoBackingDevice':
              cryptoBackingDevice?.path ?? DBusObjectPath('/'),
          'Device':
              DBusArray(DBusSignature('y'), device.map((e) => DBusByte(e))),
          'DeviceNumber': DBusUint64(deviceNumber),
          'Drive': drive?.path ?? DBusObjectPath('/'),
          'Id': DBusString(id),
          'IdLabel': DBusString(idLabel),
          'IdType': DBusString(idType),
          'IdUsage': DBusString(idUsage),
          'IdUUID': DBusString(idUUID),
          'IdVersion': DBusString(idVersion),
          'HintAuto': DBusBoolean(hintAuto),
          'HintIconName': DBusString(hintIconName),
          'HintIgnore': DBusBoolean(hintIgnore),
          'HintName': DBusString(hintName),
          'HintPartitionable': DBusBoolean(hintPartitionable),
          'HintSymbolicIconName': DBusString(hintSymbolicIconName),
          'HintSystem': DBusBoolean(hintSystem),
//'MDRaid': DBusObjectPath(MDRaid),
//'MDRaidMember': DBusObjectPath(MDRaidMember),
          'PreferredDevice': DBusArray(
              DBusSignature('y'), preferredDevice.map((e) => DBusByte(e))),
          'ReadOnly': DBusBoolean(readOnly),
          'Size': DBusUint64(size),
          'Symlinks': DBusArray(
              DBusSignature('ay'),
              symlinks.map((link) =>
                  DBusArray(DBusSignature('y'), link.map((e) => DBusByte(e))))),
          'UserspaceMountOptions': DBusArray(DBusSignature('s'),
              userspaceMountOptions.map((option) => DBusString(option)))
        }
      };
  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface != 'org.freedesktop.UDisks2.Block') {
      return DBusMethodErrorResponse.unknownInterface();
    }

    switch (methodCall.name) {
      case 'AddConfigurationItem':
        var item = _parseConfigurationItem(methodCall.values[0] as DBusStruct);
        var options = (methodCall.values[1] as DBusDict).children.map((key,
                value) =>
            MapEntry((key as DBusString).value, (value as DBusVariant).value));
        expect(options, equals({}));
        configuration.add(item);
        return DBusMethodSuccessResponse([]);
      case 'RemoveConfigurationItem':
        var item = _parseConfigurationItem(methodCall.values[0] as DBusStruct);
        var options = (methodCall.values[1] as DBusDict).children.map((key,
                value) =>
            MapEntry((key as DBusString).value, (value as DBusVariant).value));
        expect(options, equals({}));
        configuration.remove(item);
        return DBusMethodSuccessResponse([]);
      case 'UpdateConfigurationItem':
        var oldItem =
            _parseConfigurationItem(methodCall.values[0] as DBusStruct);
        var newItem =
            _parseConfigurationItem(methodCall.values[1] as DBusStruct);
        var options = (methodCall.values[2] as DBusDict).children.map((key,
                value) =>
            MapEntry((key as DBusString).value, (value as DBusVariant).value));
        expect(options, equals({}));
        configuration.remove(oldItem);
        configuration.add(newItem);
        return DBusMethodSuccessResponse([]);
      case 'GetSecretConfiguration':
        var options = (methodCall.values[0] as DBusDict).children.map((key,
                value) =>
            MapEntry((key as DBusString).value, (value as DBusVariant).value));
        expect(options, equals({}));
        return DBusMethodSuccessResponse([
          DBusArray(DBusSignature('(sa{sv})'),
              configuration.map((item) => _encodeConfigurationItem(item)))
        ]);
      case 'Format':
        formatType = (methodCall.values[0] as DBusString).value;
        var options = (methodCall.values[1] as DBusDict).children.map((key,
                value) =>
            MapEntry((key as DBusString).value, (value as DBusVariant).value));
        if (options.containsKey('take-ownership')) {
          formatTakeOwnership =
              (options['take-ownership'] as DBusBoolean).value;
        }
        if (options.containsKey('encrypt.passphrase')) {
          var value = options['encrypt.passphrase'];
          if (value is DBusString) {
            formatEncryptPassphrase = value.value;
          } else {
            formatEncryptPassphrase =
                (value as DBusArray).children.map((v) => (v as DBusByte).value);
          }
        }
        if (options.containsKey('erase')) {
          formatErase = (options['erase'] as DBusString).value;
        }
        if (options.containsKey('update-partition-type')) {
          formatUpdatePartitionType =
              (options['update-partition-type'] as DBusBoolean).value;
        }
        if (options.containsKey('no-block')) {
          formatNoBlock = (options['no-block'] as DBusBoolean).value;
        }
        if (options.containsKey('dry-run-first')) {
          formatDryRunFirst = (options['dry-run-first'] as DBusBoolean).value;
        }
        if (options.containsKey('no-discard')) {
          formatNoDiscard = (options['no-discard'] as DBusBoolean).value;
        }
        if (options.containsKey('config-items')) {
          formatConfigItems = (options['config-items'] as DBusArray)
              .children
              .map((e) => _parseConfigurationItem(e as DBusStruct))
              .toList();
        }
        if (options.containsKey('tear-down')) {
          formatTearDown = (options['tear-down'] as DBusBoolean).value;
        }
        return DBusMethodSuccessResponse([]);
      case 'Rescan':
        rescanned = true;
        return DBusMethodSuccessResponse([]);
      default:
        return DBusMethodErrorResponse.unknownMethod();
    }
  }

  UDisksConfigurationItem _parseConfigurationItem(DBusStruct value) {
    Map<String, DBusValue> parseConfigurationDetails(DBusDict value) =>
        value.children.map((key, value) =>
            MapEntry((key as DBusString).value, (value as DBusVariant).value));
    return UDisksConfigurationItem(
        (value.children.elementAt(0) as DBusString).value,
        parseConfigurationDetails(value.children.elementAt(1) as DBusDict));
  }

  DBusStruct _encodeConfigurationItem(UDisksConfigurationItem item) {
    return DBusStruct([
      DBusString(item.type),
      DBusDict(
          DBusSignature('s'),
          DBusSignature('v'),
          item.details.map(
              (key, value) => MapEntry(DBusString(key), DBusVariant(value))))
    ]);
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

  Future<MockUDisksBlockDevice> addBlockDevice(String name,
      {List<UDisksConfigurationItem>? configuration,
      MockUDisksBlockDevice? cryptoBackingDevice,
      List<int> device = const [],
      int deviceNumber = 0,
      MockUDisksDrive? drive,
      String id = '',
      String idLabel = '',
      String idType = '',
      String idUsage = '',
      String idVersion = '',
      String idUUID = '',
      bool hintAuto = false,
      String hintIconName = '',
      bool hintIgnore = false,
      String hintName = '',
      bool hintPartitionable = false,
      String hintSymbolicIconName = '',
      bool hintSystem = false,
      List<int> preferredDevice = const [],
      bool readOnly = false,
      int size = 0,
      List<List<int>> symlinks = const [],
      List<String> userspaceMountOptions = const []}) async {
    var blockDevice = MockUDisksBlockDevice(name,
        configuration: configuration,
        cryptoBackingDevice: cryptoBackingDevice,
        device: device,
        deviceNumber: deviceNumber,
        drive: drive,
        id: id,
        idLabel: idLabel,
        idType: idType,
        idUsage: idUsage,
        idVersion: idVersion,
        idUUID: idUUID,
        hintAuto: hintAuto,
        hintIconName: hintIconName,
        hintIgnore: hintIgnore,
        hintName: hintName,
        hintPartitionable: hintPartitionable,
        hintSymbolicIconName: hintSymbolicIconName,
        hintSystem: hintSystem,
        preferredDevice: preferredDevice,
        readOnly: readOnly,
        size: size,
        symlinks: symlinks,
        userspaceMountOptions: userspaceMountOptions);
    await registerObject(blockDevice);
    return blockDevice;
  }

  void removeBlockDevice(MockUDisksBlockDevice blockDevice) {
    unregisterObject(blockDevice);
  }
}

void main() {
  test('daemon version', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var udisks = MockUDisksServer(clientAddress, version: '1.2.3');
    await udisks.start();

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.version, equals('1.2.3'));

    await client.close();
  });

  test('encryption types', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var udisks = MockUDisksServer(clientAddress,
        supportedEncryptionTypes: ['luks1', 'luks2'],
        defaultEncryptionType: 'luks1');
    await udisks.start();

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

    var udisks = MockUDisksServer(clientAddress, supportedFilesystems: [
      'ext2',
      'ext3',
      'ext4',
      'vfat',
      'exfat',
      'brtfs',
      'swap'
    ]);
    await udisks.start();

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

    var udisks = MockUDisksServer(clientAddress);
    await udisks.start();

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.drives, isEmpty);

    await client.close();
  });

  test('drives', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var udisks = MockUDisksServer(clientAddress);
    await udisks.start();
    await udisks.addDrive('drive1');
    await udisks.addDrive('drive2');
    await udisks.addDrive('drive3');

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

    var udisks = MockUDisksServer(clientAddress);
    await udisks.start();

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    client.driveAdded.listen(expectAsync1((drive) {
      expect(drive.id, equals('drive'));
    }));

    await udisks.addDrive('drive');
  });

  test('drive removed', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var udisks = MockUDisksServer(clientAddress);
    await udisks.start();

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();
    var d = await udisks.addDrive('drive');

    client.driveRemoved.listen(expectAsync1((drive) {
      expect(drive.id, equals('drive'));
    }));

    udisks.removeDrive(d);
  });

  test('drive properties', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var udisks = MockUDisksServer(clientAddress);
    await udisks.start();
    await udisks.addDrive('drive',
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

    var udisks = MockUDisksServer(clientAddress);
    await udisks.start();
    var d = await udisks.addDrive('drive');

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

    var udisks = MockUDisksServer(clientAddress);
    await udisks.start();
    var d = await udisks.addDrive('drive');

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

    var udisks = MockUDisksServer(clientAddress);
    await udisks.start();
    var d = await udisks.addDrive('drive');

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(d.poweredOff, isFalse);
    expect(client.drives, hasLength(1));
    var drive = client.drives[0];
    await drive.powerOff();
    expect(d.poweredOff, isTrue);

    await client.close();
  });

  test('no block devices', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var udisks = MockUDisksServer(clientAddress);
    await udisks.start();

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.blockDevices, isEmpty);

    await client.close();
  });

  test('block devices', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var udisks = MockUDisksServer(clientAddress);
    await udisks.start();
    await udisks.addBlockDevice('device1', id: 'device1');
    await udisks.addBlockDevice('device2', id: 'device2');
    await udisks.addBlockDevice('device3', id: 'device3');

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.blockDevices, hasLength(3));
    expect(client.blockDevices[0].id, equals('device1'));
    expect(client.blockDevices[1].id, equals('device2'));
    expect(client.blockDevices[2].id, equals('device3'));

    await client.close();
  });

  test('block device added', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var udisks = MockUDisksServer(clientAddress);
    await udisks.start();

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    client.blockDeviceAdded.listen(expectAsync1((blockDevice) {
      expect(blockDevice.id, equals('device'));
    }));

    await udisks.addBlockDevice('device', id: 'device');
  });

  test('block device removed', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var udisks = MockUDisksServer(clientAddress);
    await udisks.start();

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();
    var d = await udisks.addBlockDevice('device', id: 'device');

    client.blockDeviceRemoved.listen(expectAsync1((blockDevice) {
      expect(blockDevice.id, equals('device'));
    }));

    udisks.removeBlockDevice(d);
  });

  test('block device properties', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var udisks = MockUDisksServer(clientAddress);
    await udisks.start();
    var d = await udisks.addDrive('parent_drive');
    var cryptoDevice = await udisks.addBlockDevice('crypto_device',
        id: 'parent-crypto-device');
    await udisks.addBlockDevice('device',
        configuration: [
          UDisksConfigurationItem(
              'type1', {'key1': DBusString('value1'), 'key2': DBusUint32(42)}),
          UDisksConfigurationItem('type2', {})
        ],
        cryptoBackingDevice: cryptoDevice,
        device: utf8.encode('/dev/device1'),
        deviceNumber: 42,
        drive: d,
        id: 'ID',
        idLabel: 'ID-LABEL',
        idType: 'ID-TYPE',
        idUsage: 'ID-USAGE',
        idVersion: 'ID-VERSION',
        idUUID: 'ID-UUID',
        hintAuto: true,
        hintIconName: 'HINT-ICON-NAME',
        hintIgnore: true,
        hintName: 'HINT-NAME',
        hintPartitionable: true,
        hintSymbolicIconName: 'HINT-SYMBOLIC-ICON-NAME',
        hintSystem: true,
        preferredDevice: utf8.encode('/dev/preferred-device'),
        readOnly: true,
        size: 256000000000,
        symlinks: [utf8.encode('/dev/link1'), utf8.encode('/dev/link2')],
        userspaceMountOptions: ['option1', 'option2']);

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.blockDevices, hasLength(2));
    var blockDevice = client.blockDevices[1];
    expect(
        blockDevice.configuration,
        equals([
          UDisksConfigurationItem(
              'type1', {'key1': DBusString('value1'), 'key2': DBusUint32(42)}),
          UDisksConfigurationItem('type2', {})
        ]));
    expect(blockDevice.cryptoBackingDevice, isNotNull);
    expect(blockDevice.cryptoBackingDevice!.id, equals('parent-crypto-device'));
    expect(blockDevice.device, equals(utf8.encode('/dev/device1')));
    expect(blockDevice.deviceNumber, equals(42));
    expect(blockDevice.drive, isNotNull);
    expect(blockDevice.drive!.id, equals('parent_drive'));
    expect(blockDevice.id, equals('ID'));
    expect(blockDevice.idLabel, equals('ID-LABEL'));
    expect(blockDevice.idType, equals('ID-TYPE'));
    expect(blockDevice.idUsage, equals('ID-USAGE'));
    expect(blockDevice.idVersion, equals('ID-VERSION'));
    expect(blockDevice.idUUID, equals('ID-UUID'));
    expect(blockDevice.hintAuto, equals(true));
    expect(blockDevice.hintIconName, equals('HINT-ICON-NAME'));
    expect(blockDevice.hintIgnore, equals(true));
    expect(blockDevice.hintName, equals('HINT-NAME'));
    expect(blockDevice.hintPartitionable, equals(true));
    expect(blockDevice.hintSymbolicIconName, equals('HINT-SYMBOLIC-ICON-NAME'));
    expect(blockDevice.hintSystem, equals(true));
    expect(blockDevice.preferredDevice,
        equals(utf8.encode('/dev/preferred-device')));
    expect(blockDevice.readOnly, equals(true));
    expect(blockDevice.size, equals(256000000000));
    expect(blockDevice.symlinks,
        equals([utf8.encode('/dev/link1'), utf8.encode('/dev/link2')]));
    expect(blockDevice.userspaceMountOptions, equals(['option1', 'option2']));

    await client.close();
  });

  test('block device add configuration item', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var udisks = MockUDisksServer(clientAddress);
    await udisks.start();
    var d = await udisks.addBlockDevice('device', configuration: [
      UDisksConfigurationItem('type1', {'key': DBusString('value')})
    ]);

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.blockDevices, hasLength(1));
    var blockDevice = client.blockDevices[0];
    await blockDevice.addConfigurationItem(
        UDisksConfigurationItem('type2', {'key': DBusUint32(42)}));
    expect(
        d.configuration,
        equals([
          UDisksConfigurationItem('type1', {'key': DBusString('value')}),
          UDisksConfigurationItem('type2', {'key': DBusUint32(42)})
        ]));

    await client.close();
  });

  test('block device remove configuration item', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var udisks = MockUDisksServer(clientAddress);
    await udisks.start();
    var d = await udisks.addBlockDevice('device', configuration: [
      UDisksConfigurationItem('type1', {'key': DBusString('value')}),
      UDisksConfigurationItem('type2', {'key': DBusUint32(42)})
    ]);

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.blockDevices, hasLength(1));
    var blockDevice = client.blockDevices[0];
    await blockDevice.removeConfigurationItem(
        UDisksConfigurationItem('type2', {'key': DBusUint32(42)}));
    expect(
        d.configuration,
        equals([
          UDisksConfigurationItem('type1', {'key': DBusString('value')})
        ]));

    await client.close();
  });

  test('block device update configuration item', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var udisks = MockUDisksServer(clientAddress);
    await udisks.start();
    var d = await udisks.addBlockDevice('device', configuration: [
      UDisksConfigurationItem('type1', {'key': DBusString('value')}),
      UDisksConfigurationItem('type2', {'key': DBusUint32(42)})
    ]);

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.blockDevices, hasLength(1));
    var blockDevice = client.blockDevices[0];
    await blockDevice.updateConfigurationItem(
        UDisksConfigurationItem('type2', {'key': DBusUint32(42)}),
        UDisksConfigurationItem('type2', {'key': DBusDouble(3.14159)}));
    expect(
        d.configuration,
        equals([
          UDisksConfigurationItem('type1', {'key': DBusString('value')}),
          UDisksConfigurationItem('type2', {'key': DBusDouble(3.14159)})
        ]));

    await client.close();
  });

  test('block device get secret configuration', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var udisks = MockUDisksServer(clientAddress);
    await udisks.start();
    await udisks.addBlockDevice('device', configuration: [
      UDisksConfigurationItem('secret-type', {'key': DBusString('value')}),
      UDisksConfigurationItem('type', {'key': DBusUint32(42)})
    ]);

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.blockDevices, hasLength(1));
    var blockDevice = client.blockDevices[0];
    expect(
        blockDevice.configuration,
        equals([
          UDisksConfigurationItem('type', {'key': DBusUint32(42)})
        ]));
    expect(
        await blockDevice.getSecretConfiguration(),
        equals([
          UDisksConfigurationItem('secret-type', {'key': DBusString('value')}),
          UDisksConfigurationItem('type', {'key': DBusUint32(42)})
        ]));

    await client.close();
  });

  test('block device format', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var udisks = MockUDisksServer(clientAddress);
    await udisks.start();
    var d = await udisks.addBlockDevice('device');

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.blockDevices, hasLength(1));
    var blockDevice = client.blockDevices[0];
    expect(d.formatType, isNull);
    await blockDevice.format('format',
        takeOwnership: true,
        encryptPassphrase: 'passphrase',
        erase: UDisksFormatEraseMethod.zero,
        updatePartitionType: true,
        noBlock: true,
        dryRunFirst: true,
        noDiscard: true,
        configItems: [
          UDisksConfigurationItem(
              'type1', {'key1': DBusString('value1'), 'key2': DBusUint32(42)}),
          UDisksConfigurationItem('type2', {})
        ],
        tearDown: true);
    expect(d.formatType, equals('format'));
    expect(d.formatTakeOwnership, isTrue);
    expect(d.formatEncryptPassphrase, equals('passphrase'));
    expect(d.formatErase, equals('zero'));
    expect(d.formatUpdatePartitionType, isTrue);
    expect(d.formatNoBlock, isTrue);
    expect(d.formatDryRunFirst, isTrue);
    expect(d.formatNoDiscard, isTrue);
    expect(
        d.formatConfigItems,
        equals([
          UDisksConfigurationItem(
              'type1', {'key1': DBusString('value1'), 'key2': DBusUint32(42)}),
          UDisksConfigurationItem('type2', {})
        ]));
    expect(d.formatTearDown, isTrue);

    await client.close();
  });

  test('block device format binary passphrase', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var udisks = MockUDisksServer(clientAddress);
    await udisks.start();
    var d = await udisks.addBlockDevice('device');

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.blockDevices, hasLength(1));
    var blockDevice = client.blockDevices[0];
    expect(d.formatType, isNull);
    await blockDevice.format('format', encryptPassphrase: [1, 2, 3, 4, 5]);
    expect(d.formatEncryptPassphrase, equals([1, 2, 3, 4, 5]));

    await client.close();
  });

  test('block device rescan', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var udisks = MockUDisksServer(clientAddress);
    await udisks.start();
    var d = await udisks.addBlockDevice('device');

    var client = UDisksClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.blockDevices, hasLength(1));
    var blockDevice = client.blockDevices[0];
    expect(d.rescanned, isFalse);
    await blockDevice.rescan();
    expect(d.rescanned, isTrue);

    await client.close();
  });
}
