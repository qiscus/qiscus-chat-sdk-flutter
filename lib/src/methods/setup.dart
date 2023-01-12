import 'methods.dart';

class Setup extends Method<Future<void>> {
  @override
  Future<void> run(Param p) async {
    throw UnimplementedError();
  }

  @override
  void validate() {}
}

class SetupParameter extends Param {
  final String appId;

  const SetupParameter({required this.appId});

  void validate() {}
}
