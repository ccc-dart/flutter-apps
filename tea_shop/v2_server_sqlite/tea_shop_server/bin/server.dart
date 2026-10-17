import 'dart:io';

import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:tea_shop_server/tea_shop_server.dart';

Future<void> main(List<String> args) async {
  final dbPath = Platform.environment['DB_PATH'] ?? 'tea_shop.db';
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;

  final db = openDatabase(dbPath);
  final repo = OrderRepository(db);
  final handler = createApi(repo);

  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  server.autoCompress = true;

  stdout.writeln('Tea shop server listening on http://localhost:${server.port}');
  stdout.writeln('DB: $dbPath');
}
