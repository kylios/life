part of server;


class ConfigurationMalformed extends StateError {
  ConfigurationMalformed(String name, String message) : 
    super("Configuration $name malformed: $message");
}


class Configuration {

  final String name;
  final String description;
  final Map cells;

  Configuration(this.name, this.description, this.cells);

  /// Asynchronously return a new configuration, loaded from a file
  /// maybe someday they'll add async factory constructors
  static Future<Configuration> fromFile(String name, File file) async {
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

  /// json-serialize the configuration
  Map json() {
    return {
      'name': this.name,
      'description': this.description,
      'cells': this.cells
    };
  }
}


class ConfigurationNotFound extends StateError {
  ConfigurationNotFound(String name) : super("Configuration $name not found");
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
    return Configuration.fromFile(name, entry);
  }
}