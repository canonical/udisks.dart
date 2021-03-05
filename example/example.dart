import 'package:dbus/dbus.dart';
import 'package:udisks/udisks.dart';

void main() async {
  var systemBus = DBusClient.system();
  var client = UDisksClient(systemBus);
  await client.connect();
  print('Running UDisks ${client.version}');
  client.close();
  await systemBus.close();
}
