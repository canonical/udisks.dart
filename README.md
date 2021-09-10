[![Pub Package](https://img.shields.io/pub/v/udisks.svg)](https://pub.dev/packages/udisks)
[![codecov](https://codecov.io/gh/canonical/udisks.dart/branch/main/graph/badge.svg?token=OY0ZQCREQJ)](https://codecov.io/gh/canonical/udisks.dart)

Provides a client to connect to
[UDisks](https://github.com/storaged-project/udisks) - the service that accesses and manipulates disks, storage devices and technologies on Linux.

```dart
import 'package:udisks/udisks.dart';

var client = UDisksClient();
await client.connect();
print('Running UDisks ${client.version}');
print('Supported filesystems: ${client.supportedFilesystems.join(' ')}');
await client.close();
```

## Contributing to udisks.dart

We welcome contributions! See the [contribution guide](CONTRIBUTING.md) for more details.
