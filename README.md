[![Pub Package](https://img.shields.io/pub/v/udisks.svg)](https://pub.dev/packages/udisks)

Provides a client to connect to
[UDisks](https://github.com/storaged-project/udisks) - the service that accesses and manipulates disks, storage devices and technologies on Linux.

```dart
import 'package:dbus/dbus.dart';
import 'package:udisks/udisks.dart';

var systemBus = DBusClient.system();
var client = UDisksClient(systemBus);
await client.connect();
print('Running UDisks ${client.version}');
client.close();
await systemBus.close();
```

## Contributing to udisks.dart

We welcome contributions! See the [contribution guide](CONTRIBUTING.md) for more details.
