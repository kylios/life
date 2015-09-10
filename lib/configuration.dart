library configuration;


class Configuration {

  final String name;
  final String description;
  final Map cells;

  Configuration(this.name, this.description, this.cells);

  /// json-serialize the configuration
  Map json() {
    return {
      'name': this.name,
      'description': this.description,
      'cells': this.cells
    };
  }
}

