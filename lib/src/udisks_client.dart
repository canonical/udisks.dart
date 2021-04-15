import 'dart:async';

import 'package:dbus/dbus.dart';

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
    await _object.callMethod(_driveInterfaceName, 'SetConfiguration', [
      DBusDict(
          DBusSignature('s'),
          DBusSignature('v'),
          values.map(
              (key, value) => MapEntry(DBusString(key), DBusVariant(value)))),
      DBusDict(DBusSignature('s'), DBusSignature('v'), {})
    ]);
  }

  /// Ejects media from this drive.
  Future<void> eject() async {
    await _object.callMethod(_driveInterfaceName, 'Eject',
        [DBusDict(DBusSignature('s'), DBusSignature('v'), {})]);
  }

  /// Arranges for the drive to be safely removed and powered off.
  Future<void> powerOff() async {
    await _object.callMethod(_driveInterfaceName, 'PowerOff',
        [DBusDict(DBusSignature('s'), DBusSignature('v'), {})]);
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
      : super(client, 'org.freedesktop.UDisks2', path) {
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

  final _driveAddedStreamController = StreamController<UDisksDrive>.broadcast();
  final _driveRemovedStreamController =
      StreamController<UDisksDrive>.broadcast();

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
    _root = DBusRemoteObjectManager(_bus, 'org.freedesktop.UDisks2',
        DBusObjectPath('/org/freedesktop/UDisks2'));
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
          }
        }
      } else if (signal is DBusObjectManagerInterfacesRemovedSignal) {
        var object = _objects[signal.changedPath];
        if (object != null) {
          if (signal.interfaces.contains('org.freedesktop.UDisks2.Drive')) {
            _driveRemovedStreamController.add(UDisksDrive(object));
          }
          // Note that if not all the interfaces were removed then the object still exists.
          // But in the case of UDisks the only objects we care about only drop interfaces
          // when they are completely removed.
          // Since we don't take a copy of the existing object we don't remove the interfaces
          // as the UDisksClient consumer will want the last values when they read the object
          // from the stream.
          _objects.remove(object);
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

  bool _isDrive(_UDisksObject object) =>
      object.interfaces.containsKey('org.freedesktop.UDisks2.Drive');

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
