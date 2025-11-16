// Stub for win32_registry on non-Windows platforms
// This file is used when the app runs on non-Windows platforms

class Registry {
  static final Registry localMachine = Registry._();
  Registry._();
  
  RegistryKey createKey(String path) {
    return RegistryKey._();
  }
}

class RegistryKey {
  RegistryKey._();
  
  void createValue(RegistryValue value) {}
  void deleteValue(String name) {}
  void close() {}
}

class RegistryValue {
  final String name;
  final RegistryValueType type;
  final dynamic data;
  
  RegistryValue(this.name, this.type, this.data);
}

enum RegistryValueType {
  string,
  expandString,
  binary,
  int32,
  int64,
}
