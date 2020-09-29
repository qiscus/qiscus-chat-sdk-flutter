import 'package:grinder/grinder.dart';

void main(List<String> args) => grind(args);

@DefaultTask()
@Task()
Future<String> test() {
  return Pub.runAsync('flutter test', arguments: [
    '--coverage',
    '--coverage-path=build/coverage/lcov.info',
    '--concurrency=8',
  ]);
}

@Depends(test)
@Task()
void build() {
  Pub.run('build_runner', arguments: ['build', '--delete-conflicting-outputs']);
}

@Task()
void clean() => defaultClean();
