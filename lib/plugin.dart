library armide.plugin;

import 'dart:async';
import 'dart:js';

import 'package:atom/atom.dart';
import 'package:atom/src/js.dart';
import 'package:atom/node/package.dart';
import 'package:atom/node/process.dart';
import 'package:atom/node/shell.dart';
import 'package:atom/utils/dependencies.dart';
import 'package:atom/utils/disposable.dart';


import 'package:logging/logging.dart';

final String pluginId = 'armide';

final Logger _logger = new Logger('plugin');

class ArmidePackage extends AtomPackage {
  /// List of disposable Objects used by this package
  final Disposables disposables = new Disposables(catchExceptions: true);

  /// List of subscriptions registered by this package
  final StreamSubscriptions subscriptions = new StreamSubscriptions(catchExceptions: true);

  ArmidePackage() : super(pluginId) {
    //TODO
  }

  void activate([dynamic pluginState]) {
    _setupLogging();

    _logger.info("Starting");
    _logger.fine("Running on Chrome version ${process.chromeVersion}.");

    final JsObject moduleExports = context['module']['exports'];

    moduleExports['consumeAutoreload'] = (JsFunction aReloader) {
      aReloader.apply(jsify([{"pkg": "armide", "folders": [], "files": ["package.json", "web/main.dart.js"]}]));
    };
    //TODO
  }

  void deactivate() {
    _logger.info('deactivated');
    //TODO

    disposables.dispose();
    subscriptions.cancel();
  }

  Map config() {
    return {};
  }

  void _setupLogging() {
    disposables.add(atom.config.observe('${pluginId}.logging', null, (val) {
      if (val == null) return;

      for (Level level in Level.LEVELS) {
        if (val.toUpperCase() == level.name) {
          Logger.root.level = level;
          break;
        }
      }

      _logger.info("logging level: ${Logger.root.level}");
    }));
  }
}
