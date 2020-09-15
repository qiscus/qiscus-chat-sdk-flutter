import 'package:grinder/grinder.dart';
import 'package:lcov/lcov.dart' as lc;

void main(List<String> args) => grind(args);

@Task()
Future<String> test() => Pub.runAsync('test', arguments: [
      '--coverage=build/coverage',
      '--timeout=1s',
      '--concurrency=8',
      '--reporter=expanded',
    ]);

@DefaultTask()
@Depends(test)
void build() {
  Pub.run('build_runner', arguments: ['build', '--delete-conflicting-outputs']);
}

@Task()
void clean() => defaultClean();

@Task()
Future<String> coverage() async {
  var report = lc.Report.fromCoverage(
      'D:\\code\\qiscus.work\\flutter\\qiscus-chat-sdk-flutter\\build\\coverage-o');
  var totalLines = 0;
  var executedLine = 0;
  for (var rec in report.records) {
    for (var line in rec.lines.data) {
      totalLines++;
      if (line.executionCount >= 1) executedLine++;
    }
  }

  return ((executedLine / totalLines) * 100).toString();

  // return Pub.runAsync('test_coverage', arguments: [
  //   '--print-test-output',
  //   '--min-coverage 65',
  // ]);
}
