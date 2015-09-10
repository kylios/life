part of server;


class ConfigurationNotFound extends StateError {
  ConfigurationNotFound(String name) : super("Configuration $name not found");
}


class ConfigurationMalformed extends StateError {
  ConfigurationMalformed(String name, String message) : 
    super("Configuration $name malformed: $message");
}


class ConfigurationFactory {

  static Future<Configuration> loadFromFile(String name, File file) async {

    String contents = await file.readAsString(encoding: UTF8);
    Map c = JSON.decode(contents);

    if (c['description'] == null) {
      throw new ConfigurationMalformed(name, 'missing description field');
    }
    if (c['cells'] == null) {
      throw new ConfigurationMalformed(name, 'missing cells field');
    }
    return new Configuration(name, c['description'], c['cells']);
  }
}


class FileManager {

  final Directory dir;

  Map<String, FileSystemEntity> _contents = new Map<String, FileSystemEntity>();

  FileManager(String path) : this.dir = new Directory(path);

  /// Initialize this file manager
  dynamic init() async {
    await for (FileSystemEntity entry in this.dir.list(recursive: false, followLinks: true)) {
      // Get the basename from the path, minus .json
      // i.e. convert '/path/to/spec.json' into 'spec'
      List<String> components = entry.path.split(Platform.pathSeparator);
      String name = components[components.length - 1];
      this._contents[name.substring(0, name.lastIndexOf('.json'))] = entry;
    }
    return null;
  }

  /// Get a list of all possible configurations
  Iterable<String> getConfigurations() {

    Iterable<String> configurations = this._contents.keys;
    return configurations;
  }

  /// Find a single configuration from the filesystem and return it
  Future<Configuration> getConfiguration(String name) async {
    FileSystemEntity entry = this._contents[name];
    if (entry == null) {
      throw new ConfigurationNotFound(name);
    }
    return ConfigurationFactory.loadFromFile(name, entry);
  }
}