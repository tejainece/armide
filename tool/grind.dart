// Grinder tasks

library atom.grind;

import 'dart:io';

import 'package:grinder/grinder.dart';

import 'package:atom/build/publish.dart';

main(List<String> args) => grind(args);

@Task()
analyze() => new PubApp.global('tuneup').runAsync(['check']);

@DefaultTask()
build() async {
  File inputFile = getFile('web/main.dart');
  File outputFile = getFile('web/main.dart.js');

  // --trust-type-annotations? --trust-primitives?
  await Dart2js.compileAsync(inputFile, csp: true);
  outputFile.writeAsStringSync(_patchJSFile(outputFile.readAsStringSync()));
}

@Task()
clean() {
  delete(getFile('main.dart.js'));
  delete(getFile('main.dart.js.deps'));
  delete(getFile('main.dart.js.map'));
}

@Task()
publish() => publishAtomPlugin();

/* TODO
@Task('Build the Atom tests')
buildAtomTests() async {
  final String base = 'spec/all-spec';
  File inputFile = getFile('${base}.dart');
  File outputFile = getFile('${base}.js');
  await Dart2js.compileAsync(inputFile, csp: true, outFile: outputFile);
  delete(getFile('${base}.js.deps'));
  //outputFile.writeAsStringSync(_patchJSFile(outputFile.readAsStringSync()));
}

@Task('Run the Atom tests')
@Depends(buildAtomTests)
runAtomTests() async {
  String apmPath = whichSync('apm', orElse: () => null);

  if (apmPath != null) {
    await runAsync('apm', arguments: ['test']);
  } else {
    log("warning: command 'apm' not found");
  }
}
*/

/*
@Task()
test() => Dart.runAsync('test/all.dart');

@Task()
@Depends(analyze, build, test, runAtomTests)
bot() => null;
*/



final String _jsPrefix = """
var self = Object.create(this);
self.require = require;
self.module = module;
self.window = window;
self.atom = atom;
self.exports = exports;
self.Object = Object;
self.Promise = Promise;
self.setTimeout = function(f, millis) { return window.setTimeout(f, millis); };
self.clearTimeout = function(id) { window.clearTimeout(id); };
self.setInterval = function(f, millis) { return window.setInterval(f, millis); };
self.clearInterval = function(id) { window.clearInterval(id); };
// Work around interop issues.
self.getTextEditorForElement = function(element) { return element.o.getModel(); };
self.uncrackDart2js = function(obj) { return obj.o; };
self._domHoist = function(element, targetQuery) {
  var target = document.querySelector(targetQuery);
  target.appendChild(element);
};
self._domRemove = function(element) {
  element.parentNode.removeChild(element);
};
""";

String _patchJSFile(String input) {
  final String from_1 = 'if (document.currentScript) {';
  final String from_2 = "if (typeof document.currentScript != 'undefined') {";
  final String to = 'if (true) {';

  int index = input.lastIndexOf(from_1);
  if (index != -1) {
    input =
        input.substring(0, index) + to + input.substring(index + from_1.length);
  } else {
    index = input.lastIndexOf(from_2);
    input =
        input.substring(0, index) + to + input.substring(index + from_2.length);
  }
  return _jsPrefix + input;
}
