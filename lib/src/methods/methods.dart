abstract class Method<Return> {
  void validate();
  Return run(Param params);

  Return call(Param params) {
    validate();
    return run(params);
  }
}

abstract class Param {
  const Param();
  void validate();
}
