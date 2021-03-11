import 'package:udisks/udisks.dart';

void main() async {
  var client = UDisksClient();
  await client.connect();

  print('Running UDisks ${client.version}');
  print('Supported filesystems: ${client.supportedFilesystems.join(' ')}');

  await client.close();
}
