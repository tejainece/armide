// Main file for ArmIDE

library main;

import 'package:atom/node/package.dart';
import 'package:logging/logging.dart';

import 'package:armide/plugin.dart';

main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord r) {
    String tag = 'ArmIDE: ${r.level.name.toLowerCase()} • ${r.loggerName}:';
    print('${tag} ${r.message}');

    if (r.error != null) print('${tag}   ${r.error}');
    if (r.stackTrace != null) print('${tag}   ${r.stackTrace}');
  });

  registerPackage(new ArmidePackage());
}
