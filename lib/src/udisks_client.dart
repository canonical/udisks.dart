import 'dart:async';

import 'package:dbus/dbus.dart';

/// Method for erasing data when formatting.
enum UDisksFormatEraseMethod { zero, ataSecureErase, ataSecureEraseEnhanced }

/// A drive on this system.
class UDisksDrive {
  final String _driveInterfaceName = 'org.freedesktop.UDisks2.Drive';

  final _UDisksObject _object;

  UDisksDrive(this._object);

  /// Whether the drive can be safely removed / powered off.
  bool get canPowerOff =>
      _object.getBooleanProperty(_driveInterfaceName, 'CanPowerOff') ?? false;

  /// A set of configuration directives that are applied to the drive when it is connected.
  /// Use [setConfiguration] to change these.
  Map<String, DBusValue> get configuration =>
      _object.getConfigurationProperty(_driveInterfaceName, 'Configuration') ??
      {};

  /// The physical connection bus used for the drive as seen by the user.
  String get connectionBus =>
      _object.getStringProperty(_driveInterfaceName, 'ConnectionBus') ?? '';

  /// True if media can be ejected from the drive.
  /// Use [eject] to perform this.
  bool get ejectable =>
      _object.getBooleanProperty(_driveInterfaceName, 'Ejectable') ?? false;

  ///  A unique and persistent identifier for the device or blank if no such identifier is available.
  String get id => _object.getStringProperty(_driveInterfaceName, 'Id') ?? '';

  /// The kind of media currently in the drive or blank if unknown.
  String get media =>
      _object.getStringProperty(_driveInterfaceName, 'Media') ?? '';

  /// True if there is media in the drive.
  /// This is always true if [mediaChangeDetected] is false.
  bool get mediaAvailable =>
      _object.getBooleanProperty(_driveInterfaceName, 'MediaAvailable') ??
      false;

  /// True if media changes are detected.
  /// The state of the media is reported in [mediaAvailable].
  bool get mediaChangeDetected =>
      _object.getBooleanProperty(_driveInterfaceName, 'MediaChangeDetected') ??
      false;

  /// The physical kind of media the drive uses or the type of the drive or blank if unknown.
  List<String> get mediaCompatibility =>
      _object.getStringArrayProperty(
          _driveInterfaceName, 'MediaCompatibility') ??
      [];

  /// Whether the media can be removed from the drive.
  bool get mediaRemovable =>
      _object.getBooleanProperty(_driveInterfaceName, 'MediaRemovable') ??
      false;

  /// A name for the model of the drive or blank if unknown.
  String get model =>
      _object.getStringProperty(_driveInterfaceName, 'Model') ?? '';

  /// True if the drive uses an optical disc.
  bool get optical =>
      _object.getBooleanProperty(_driveInterfaceName, 'Optical') ?? false;

  bool get opticalBlank =>
      _object.getBooleanProperty(_driveInterfaceName, 'OpticalBlank') ?? false;

  int get opticalNumTracks =>
      _object.getUint32Property(_driveInterfaceName, 'OpticalNumTracks') ?? 0;

  int get opticalNumAudioTracks =>
      _object.getUint32Property(_driveInterfaceName, 'OpticalNumAudioTracks') ??
      0;

  int get opticalNumDataTracks =>
      _object.getUint32Property(_driveInterfaceName, 'OpticalNumDataTracks') ??
      0;

  int get opticalNumSessions =>
      _object.getUint32Property(_driveInterfaceName, 'OpticalNumSessions') ?? 0;

  /// A hint whether the drive and/or its media is considered removable by the user.
  bool get removable =>
      _object.getBooleanProperty(_driveInterfaceName, 'Removable') ?? false;

  /// Firmware Revision or blank if unknown.
  String get revision =>
      _object.getStringProperty(_driveInterfaceName, 'Revision') ?? '';

  /// The rotational rate of the drive in rpm.
  /// Set to -1 for rotating media but rotation rate isn't known and 0 for  non-rotating media.
  int get rotationRate =>
      _object.getInt32Property(_driveInterfaceName, 'RotationRate') ?? 0;

  ///  The id of the seat the drive is plugged into, if any.
  String get seat =>
      _object.getStringProperty(_driveInterfaceName, 'Seat') ?? '';

  /// Serial number of the drive or blank if unknown.
  String get serial =>
      _object.getStringProperty(_driveInterfaceName, 'Serial') ?? '';

  /// An opaque token that, if non-blank, is used to group drives that are part of the same physical device.
  String get siblingId =>
      _object.getStringProperty(_driveInterfaceName, 'SiblingId') ?? '';

  /// The size of the drive in bytes.
  int get size => _object.getUint64Property(_driveInterfaceName, 'Size') ?? 0;

  String get sortKey =>
      _object.getStringProperty(_driveInterfaceName, 'SortKey') ?? '';

  int get timeDetected =>
      _object.getUint64Property(_driveInterfaceName, 'TimeDetected') ?? 0;

  int get timeMediaDetected =>
      _object.getUint64Property(_driveInterfaceName, 'TimeMediaDetected') ?? 0;

  /// A name for the vendor of the drive or blank if unknown.
  String get vendor =>
      _object.getStringProperty(_driveInterfaceName, 'Vendor') ?? '';

  String get wwn => _object.getStringProperty(_driveInterfaceName, 'WWN') ?? '';

  /// Sets the configuration for the drive.
  Future<void> setConfiguration(Map<String, DBusValue> values) async {
    await _object.callMethod(_driveInterfaceName, 'SetConfiguration',
        [DBusDict.stringVariant(values), DBusDict.stringVariant({})],
        replySignature: DBusSignature(''));
  }

  /// Ejects media from this drive.
  Future<void> eject() async {
    await _object.callMethod(
        _driveInterfaceName, 'Eject', [DBusDict.stringVariant({})],
        replySignature: DBusSignature(''));
  }

  /// Arranges for the drive to be safely removed and powered off.
  Future<void> powerOff() async {
    await _object.callMethod(
        _driveInterfaceName, 'PowerOff', [DBusDict.stringVariant({})],
        replySignature: DBusSignature(''));
  }
}

/// Block device configuration.
class UDisksConfigurationItem {
  // The type of configuration, e.g. 'fstab'.
  final String type;

  /// Configuration data for [type].
  final Map<String, DBusValue> details;

  const UDisksConfigurationItem(this.type, this.details);

  @override
  String toString() => "UDisksConfigurationItem('$type', $details)";

  @override
  bool operator ==(other) {
    if (other is! UDisksConfigurationItem ||
        other.type != type ||
        other.details.length != details.length) {
      return false;
    }
    for (var key in details.keys) {
      if (details[key] != other.details[key]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(type, details);
}

/// A block device on this system.
class UDisksBlockDevice {
  final String _blockInterfaceName = 'org.freedesktop.UDisks2.Block';

  final UDisksClient _client;
  final _UDisksObject _object;

  UDisksBlockDevice(this._client, this._object);

  /// The configuration for the device.
  /// Use the [addConfigurationItem], [removeConfigurationItem] and [updateConfigurationItem] methods to add, remove and update configuration items.
  /// Use [getSecretConfiguration] to get the secrets (e.g. passphrases) that may be part of the configuration but isn't exported in this property for security reasons.
  List<UDisksConfigurationItem> get configuration {
    var value = _object.getCachedProperty(_blockInterfaceName, 'Configuration');
    if (value == null) {
      return [];
    }
    if (value.signature != DBusSignature('a(sa{sv})')) {
      return [];
    }

    return (value as DBusArray)
        .children
        .map((e) => _parseConfigurationItem(e as DBusStruct))
        .toList();
  }

  /// The block device that is backing this encrypted device.
  UDisksBlockDevice? get cryptoBackingDevice {
    var objectPath = _object.getObjectPathProperty(
        _blockInterfaceName, 'CryptoBackingDevice');
    return objectPath != null ? _client._getBlockDevice(objectPath) : null;
  }

  /// The special device file for the block device e.g. '/dev/sda2'.
  List<int> get device =>
      _object.getByteArrayProperty(_blockInterfaceName, 'Device') ?? [];

  /// The dev_t of the block device.
  int get deviceNumber =>
      _object.getUint64Property(_blockInterfaceName, 'DeviceNumber') ?? 0;

  /// The drive this block device belongs to.
  UDisksDrive? get drive {
    var objectPath =
        _object.getObjectPathProperty(_blockInterfaceName, 'Drive');
    return objectPath != null ? _client._getDrive(objectPath) : null;
  }

  /// True if the device should be automatically started.
  bool get hintAuto =>
      _object.getBooleanProperty(_blockInterfaceName, 'HintAuto') ?? false;

  /// If not blank, the icon name to use when presenting the device.
  String get hintIconName =>
      _object.getStringProperty(_blockInterfaceName, 'HintIconName') ?? '';

  /// True if the device should be hidden from users.
  bool get hintIgnore =>
      _object.getBooleanProperty(_blockInterfaceName, 'HintIgnore') ?? false;

  /// If not blank, the name to use when presenting the device.
  String get hintName =>
      _object.getStringProperty(_blockInterfaceName, 'HintName') ?? '';

  /// True if the device is normally expected to be partitionable.
  bool get hintPartitionable =>
      _object.getBooleanProperty(_blockInterfaceName, 'HintPartitionable') ??
      false;

  ///  If not blank, the icon name to use when presenting the device using a symbolic icon.
  String get hintSymbolicIconName =>
      _object.getStringProperty(_blockInterfaceName, 'HintSymbolicIconName') ??
      '';

  /// True if this device is considered a *system device*.
  bool get hintSystem =>
      _object.getBooleanProperty(_blockInterfaceName, 'HintSystem') ?? false;

  ///  A unique and persistent identifier for the device or blank if no such identifier is available.
  String get id => _object.getStringProperty(_blockInterfaceName, 'Id') ?? '';

  /// The label of the filesystem or other structured data on the block device.
  /// This property is blank if there is no label or the label is unknown.
  String get idLabel =>
      _object.getStringProperty(_blockInterfaceName, 'IdLabel') ?? '';

  /// More information about the result of probing the block device.
  /// Its value depends of the value the [idUsage] property.
  String get idType =>
      _object.getStringProperty(_blockInterfaceName, 'IdType') ?? '';

  /// A result of probing for signatures on the block device.
  String get idUsage =>
      _object.getStringProperty(_blockInterfaceName, 'IdUsage') ?? '';

  /// The UUID of the filesystem or other structured data on the block device.
  /// This property is blank if there is no UUID or the UUID is unknown.
  String get idUUID =>
      _object.getStringProperty(_blockInterfaceName, 'IdUUID') ?? '';

  /// The version of the filesystem or other structured data on the block device.
  /// This property is blank if there is no version or the version is unknown.
  String get idVersion =>
      _object.getStringProperty(_blockInterfaceName, 'IdVersion') ?? '';

  // FIXME: MDRaid

  // FIXME: MDRaidMember

  /// The special device file to present in the UI instead of the value of the [Device] property.
  List<int> get preferredDevice =>
      _object.getByteArrayProperty(_blockInterfaceName, 'PreferredDevice') ??
      [];

  /// True if the device cannot be written to.
  bool get readOnly =>
      _object.getBooleanProperty(_blockInterfaceName, 'ReadOnly') ?? false;

  /// The size of the block device in bytes.
  int get size => _object.getUint64Property(_blockInterfaceName, 'Size') ?? 0;

  /// Known symlinks in /dev that points to the device file in the [device] property.
  List<List<int>> get symlinks {
    var value = _object.getCachedProperty(_blockInterfaceName, 'Symlinks');
    if (value == null) {
      return [];
    }
    if (value.signature != DBusSignature('aay')) {
      return [];
    }
    List<int> parseByteArray(DBusArray v) =>
        v.children.map((e) => (e as DBusByte).value).toList();
    return (value as DBusArray)
        .children
        .map((e) => parseByteArray(e as DBusArray))
        .toList();
  }

  /// List of userspace mount options..
  List<String> get userspaceMountOptions =>
      _object.getStringArrayProperty(
          _blockInterfaceName, 'UserspaceMountOptions') ??
      [];

  DBusStruct _encodeConfigurationItem(UDisksConfigurationItem item) {
    return DBusStruct(
        [DBusString(item.type), DBusDict.stringVariant(item.details)]);
  }

  UDisksConfigurationItem _parseConfigurationItem(DBusStruct value) {
    Map<String, DBusValue> parseConfigurationDetails(DBusDict value) =>
        value.children.map((key, value) =>
            MapEntry((key as DBusString).value, (value as DBusVariant).value));
    return UDisksConfigurationItem(
        (value.children.elementAt(0) as DBusString).value,
        parseConfigurationDetails(value.children.elementAt(1) as DBusDict));
  }

  /// Adds a new configuration item.
  Future<void> addConfigurationItem(UDisksConfigurationItem item) async {
    var options = <String, DBusValue>{};
    await _object.callMethod(_blockInterfaceName, 'AddConfigurationItem',
        [_encodeConfigurationItem(item), DBusDict.stringVariant(options)],
        replySignature: DBusSignature(''));
  }

  /// Removes an existing configuration item.
  Future<void> removeConfigurationItem(UDisksConfigurationItem item) async {
    var options = <String, DBusValue>{};
    await _object.callMethod(_blockInterfaceName, 'RemoveConfigurationItem',
        [_encodeConfigurationItem(item), DBusDict.stringVariant(options)],
        replySignature: DBusSignature(''));
  }

  /// Removes a configuration item and adds a new one.
  Future<void> updateConfigurationItem(
      UDisksConfigurationItem oldItem, UDisksConfigurationItem newItem) async {
    var options = <String, DBusValue>{};
    await _object.callMethod(
        _blockInterfaceName,
        'UpdateConfigurationItem',
        [
          _encodeConfigurationItem(oldItem),
          _encodeConfigurationItem(newItem),
          DBusDict.stringVariant(options)
        ],
        replySignature: DBusSignature(''));
  }

  /// Returns the same value as in the [configuration] property but without secret information filtered out.
  Future<List<UDisksConfigurationItem>> getSecretConfiguration() async {
    var options = <String, DBusValue>{};
    var result = await _object.callMethod(_blockInterfaceName,
        'GetSecretConfiguration', [DBusDict.stringVariant(options)],
        replySignature: DBusSignature('a(sa{sv})'));
    return (result.returnValues[0] as DBusArray)
        .children
        .map((item) => _parseConfigurationItem(item as DBusStruct))
        .toList();
  }

  /// Formats the device with a file system, partition table or other well-known content.
  Future<void> format(String type,
      {bool takeOwnership = false,
      dynamic encryptPassphrase,
      UDisksFormatEraseMethod? erase,
      bool updatePartitionType = false,
      bool noBlock = false,
      bool dryRunFirst = false,
      bool noDiscard = false,
      Iterable<UDisksConfigurationItem> configItems = const [],
      bool tearDown = false}) async {
    var options = <String, DBusValue>{};
    if (takeOwnership) {
      options['take-ownership'] = DBusBoolean(true);
    }
    if (encryptPassphrase != null) {
      if (encryptPassphrase is String) {
        options['encrypt.passphrase'] = DBusString(encryptPassphrase);
      } else if (encryptPassphrase is List<int>) {
        options['encrypt.passphrase'] = DBusArray.byte(encryptPassphrase);
      } else {
        throw FormatException('encryptPassphrase must be String or List<int>');
      }
    }
    if (erase != null) {
      String value;
      switch (erase) {
        case UDisksFormatEraseMethod.zero:
          value = 'zero';
          break;
        case UDisksFormatEraseMethod.ataSecureErase:
          value = 'ata-secure-erase';
          break;
        case UDisksFormatEraseMethod.ataSecureEraseEnhanced:
          value = 'ata-secure-erase-enhanced';
          break;
      }
      options['erase'] = DBusString(value);
    }
    if (updatePartitionType) {
      options['update-partition-type'] = DBusBoolean(true);
    }
    if (noBlock) {
      options['no-block'] = DBusBoolean(true);
    }
    if (dryRunFirst) {
      options['dry-run-first'] = DBusBoolean(true);
    }
    if (noDiscard) {
      options['no-discard'] = DBusBoolean(true);
    }
    if (configItems.isNotEmpty) {
      options['config-items'] = DBusArray(DBusSignature('(sa{sv})'),
          configItems.map((item) => _encodeConfigurationItem(item)));
    }
    if (tearDown) {
      options['tear-down'] = DBusBoolean(true);
    }
    await _object.callMethod(_blockInterfaceName, 'Format',
        [DBusString(type), DBusDict.stringVariant(options)],
        replySignature: DBusSignature(''));
  }

  /// Request that the kernel and core OS rescans the contents of the device and update their state to reflect this.
  Future<void> rescan() async {
    var options = <String, DBusValue>{};
    await _object.callMethod(
        _blockInterfaceName, 'Rescan', [DBusDict.stringVariant(options)],
        replySignature: DBusSignature(''));
  }
}

class _UDisksManager {
  _UDisksObject object;
  final String _managerInterfaceName = 'org.freedesktop.UDisks2.Manager';

  /// Encryption types supported.
  List<String> get supportedEncryptionTypes =>
      object.getStringArrayProperty(
          _managerInterfaceName, 'SupportedEncryptionTypes') ??
      [];

  /// Default encryption type to use.
  String get defaultEncryptionType =>
      object.getStringProperty(
          _managerInterfaceName, 'DefaultEncryptionType') ??
      '';

  /// Filesystems supported by UDisks.
  List<String> get supportedFilesystems =>
      object.getStringArrayProperty(
          _managerInterfaceName, 'SupportedFilesystems') ??
      [];

  /// The version of the daemon.
  String get version =>
      object.getStringProperty(_managerInterfaceName, 'Version') ?? '';

  _UDisksManager(this.object);
}

class _UDisksInterface {
  final Map<String, DBusValue> properties;
  final propertiesChangedStreamController =
      StreamController<List<String>>.broadcast();

  Stream<List<String>> get propertiesChangedStream =>
      propertiesChangedStreamController.stream;

  _UDisksInterface(this.properties);

  void updateProperties(Map<String, DBusValue> changedProperties) {
    properties.addAll(changedProperties);
    propertiesChangedStreamController.add(changedProperties.keys.toList());
  }
}

class _UDisksObject extends DBusRemoteObject {
  final interfaces = <String, _UDisksInterface>{};

  void updateInterfaces(
      Map<String, Map<String, DBusValue>> interfacesAndProperties) {
    interfacesAndProperties.forEach((interfaceName, properties) {
      interfaces[interfaceName] = _UDisksInterface(properties);
    });
  }

  /// Returns true if removing [interfaceNames] would remove all interfaces on this object.
  bool wouldRemoveAllInterfaces(List<String> interfaceNames) {
    for (var interface in interfaces.keys) {
      if (!interfaceNames.contains(interface)) {
        return false;
      }
    }
    return true;
  }

  void removeInterfaces(List<String> interfaceNames) {
    for (var interfaceName in interfaceNames) {
      interfaces.remove(interfaceName);
    }
  }

  void updateProperties(
      String interfaceName, Map<String, DBusValue> changedProperties) {
    var interface = interfaces[interfaceName];
    if (interface != null) {
      interface.updateProperties(changedProperties);
    }
  }

  /// Gets a cached property.
  DBusValue? getCachedProperty(String interfaceName, String name) {
    var interface = interfaces[interfaceName];
    if (interface == null) {
      return null;
    }
    return interface.properties[name];
  }

  /// Gets a cached byte array property, or returns null if not present or not the correct type.
  List<int>? getByteArrayProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('ay')) {
      return null;
    }
    return (value as DBusArray)
        .children
        .map((e) => (e as DBusByte).value)
        .toList();
  }

  /// Gets a cached boolean property, or returns null if not present or not the correct type.
  bool? getBooleanProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('b')) {
      return null;
    }
    return (value as DBusBoolean).value;
  }

  /// Gets a cached signed 32 bit integer property, or returns null if not present or not the correct type.
  int? getInt32Property(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('i')) {
      return null;
    }
    return (value as DBusInt32).value;
  }

  /// Gets a cached unsigned 32 bit integer property, or returns null if not present or not the correct type.
  int? getUint32Property(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('u')) {
      return null;
    }
    return (value as DBusUint32).value;
  }

  /// Gets a cached unsigned 64 bit integer property, or returns null if not present or not the correct type.
  int? getUint64Property(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('t')) {
      return null;
    }
    return (value as DBusUint64).value;
  }

  /// Gets a cached string property, or returns null if not present or not the correct type.
  String? getStringProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('s')) {
      return null;
    }
    return (value as DBusString).value;
  }

  /// Gets a cached string array property, or returns null if not present or not the correct type.
  List<String>? getStringArrayProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('as')) {
      return null;
    }
    return (value as DBusArray)
        .children
        .map((e) => (e as DBusString).value)
        .toList();
  }

  /// Gets a cached object path property, or returns null if not present or not the correct type.
  DBusObjectPath? getObjectPathProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('o')) {
      return null;
    }
    return (value as DBusObjectPath);
  }

  /// Gets a list of key value pairs, or returns null if not present or not the correct type.
  Map<String, DBusValue>? getConfigurationProperty(
      String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('a{sv}')) {
      return null;
    }
    return (value as DBusDict).children.map((key, value) =>
        MapEntry((key as DBusString).value, (value as DBusVariant).value));
  }

  _UDisksObject(DBusClient client, DBusObjectPath path,
      Map<String, Map<String, DBusValue>> interfacesAndProperties)
      : super(client, name: 'org.freedesktop.UDisks2', path: path) {
    updateInterfaces(interfacesAndProperties);
  }
}

/// A client that connects to UDisks.
class UDisksClient {
  /// The bus this client is connected to.
  final DBusClient _bus;
  final bool _closeBus;

  /// Stream of drives as they are added.
  Stream<UDisksDrive> get driveAdded => _driveAddedStreamController.stream;

  /// Stream of drives as they are removed.
  Stream<UDisksDrive> get driveRemoved => _driveRemovedStreamController.stream;

  /// Stream of block devices as they are added.
  Stream<UDisksBlockDevice> get blockDeviceAdded =>
      _blockDeviceAddedStreamController.stream;

  /// Stream of block devices as they are removed.
  Stream<UDisksBlockDevice> get blockDeviceRemoved =>
      _blockDeviceRemovedStreamController.stream;

  final _driveAddedStreamController = StreamController<UDisksDrive>.broadcast();
  final _driveRemovedStreamController =
      StreamController<UDisksDrive>.broadcast();
  final _blockDeviceAddedStreamController =
      StreamController<UDisksBlockDevice>.broadcast();
  final _blockDeviceRemovedStreamController =
      StreamController<UDisksBlockDevice>.broadcast();

  /// Supported encryption types.
  List<String> get supportedEncryptionTypes =>
      _manager?.supportedEncryptionTypes ?? [];

  /// Supported filesystems.
  List<String> get supportedFilesystems => _manager?.supportedFilesystems ?? [];

  /// Default encryption type.
  String get defaultEncryptionType => _manager?.defaultEncryptionType ?? '';

  /// The version of the UDisks daemon.
  String get version => _manager?.version ?? '';

  // The root D-Bus UDisks object at path '/org/freedesktop/UDisks2'.
  late final DBusRemoteObjectManager _root;

  /// Objects exported on the bus.
  final _objects = <DBusObjectPath, _UDisksObject>{};

  /// Subscription to object manager signals.
  StreamSubscription? _objectManagerSubscription;

  /// Manager object
  _UDisksManager? _manager;

  /// Creates a new UDisks client connected to the system D-Bus.
  UDisksClient({DBusClient? bus})
      : _bus = bus ?? DBusClient.system(),
        _closeBus = bus == null {
    _root = DBusRemoteObjectManager(_bus,
        name: 'org.freedesktop.UDisks2',
        path: DBusObjectPath('/org/freedesktop/UDisks2'));
  }

  /// Connects to the UDisks D-Bus objects.
  /// Must be called before accessing methods and properties.
  Future<void> connect() async {
    // Already connected
    if (_objectManagerSubscription != null) {
      return;
    }

    // Subscribe to changes
    _objectManagerSubscription = _root.signals.listen((signal) {
      if (signal is DBusObjectManagerInterfacesAddedSignal) {
        var object = _objects[signal.changedPath];
        if (object != null) {
          object.updateInterfaces(signal.interfacesAndProperties);
        } else {
          object = _UDisksObject(
              _bus, signal.changedPath, signal.interfacesAndProperties);
          _objects[signal.changedPath] = object;
          if (_isDrive(object)) {
            _driveAddedStreamController.add(UDisksDrive(object));
          } else if (_isBlockDevice(object)) {
            _blockDeviceAddedStreamController
                .add(UDisksBlockDevice(this, object));
          }
        }
      } else if (signal is DBusObjectManagerInterfacesRemovedSignal) {
        var object = _objects[signal.changedPath];
        if (object != null) {
          // If all the interface are removed, then this object has been removed.
          // Keep the previous values around for the client to use.
          if (object.wouldRemoveAllInterfaces(signal.interfaces)) {
            _objects.remove(signal.changedPath);
          } else {
            object.removeInterfaces(signal.interfaces);
          }

          if (signal.interfaces.contains('org.freedesktop.UDisks2.Drive')) {
            _driveRemovedStreamController.add(UDisksDrive(object));
          } else if (signal.interfaces
              .contains('org.freedesktop.UDisks2.Block')) {
            _blockDeviceRemovedStreamController
                .add(UDisksBlockDevice(this, object));
          }
        }
      } else if (signal is DBusPropertiesChangedSignal) {
        var object = _objects[signal.path];
        if (object != null) {
          object.updateProperties(
              signal.propertiesInterface, signal.changedProperties);
        }
      }
    });

    // Find all the objects exported.
    var objects = await _root.getManagedObjects();
    objects.forEach((objectPath, interfacesAndProperties) {
      _objects[objectPath] =
          _UDisksObject(_bus, objectPath, interfacesAndProperties);
    });

    var managerObject =
        _objects[DBusObjectPath('/org/freedesktop/UDisks2/Manager')];
    if (managerObject != null) {
      _manager = _UDisksManager(managerObject);
    }
  }

  /// The drives present on this system.
  /// Use [driveAdded] and [driveRemoved] to detect when this list changes.
  List<UDisksDrive> get drives {
    var drives = <UDisksDrive>[];
    for (var object in _objects.values) {
      if (_isDrive(object)) {
        drives.add(UDisksDrive(object));
      }
    }
    return drives;
  }

  UDisksDrive? _getDrive(DBusObjectPath objectPath) {
    var object = _objects[objectPath];
    return object != null ? UDisksDrive(object) : null;
  }

  bool _isDrive(_UDisksObject object) =>
      object.interfaces.containsKey('org.freedesktop.UDisks2.Drive');

  /// The block devices present on this system.
  /// Use [blockDeviceAdded] and [blockDeviceRemoved] to detect when this list changes.
  List<UDisksBlockDevice> get blockDevices {
    var blockDevices = <UDisksBlockDevice>[];
    for (var object in _objects.values) {
      if (_isBlockDevice(object)) {
        blockDevices.add(UDisksBlockDevice(this, object));
      }
    }
    return blockDevices;
  }

  UDisksBlockDevice? _getBlockDevice(DBusObjectPath objectPath) {
    var object = _objects[objectPath];
    return object != null ? UDisksBlockDevice(this, object) : null;
  }

  bool _isBlockDevice(_UDisksObject object) =>
      object.interfaces.containsKey('org.freedesktop.UDisks2.Block');

  /// Terminates all active connections. If a client remains unclosed, the Dart process may not terminate.
  Future<void> close() async {
    if (_objectManagerSubscription != null) {
      await _objectManagerSubscription!.cancel();
      _objectManagerSubscription = null;
    }
    if (_closeBus) {
      await _bus.close();
    }
  }
}
