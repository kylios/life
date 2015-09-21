library configuration;


class Configuration {

  String _name;
  String _description;
  Map<String, List<int>> _cells;

  String get name => this._name;
  String get description => this._description;
  Map<String, List<int>> get cells => this._cells;

  Configuration(this._name, this._description, this._cells);

  Configuration.fromJson(Map json) {
    this._name = json['name'];
    this._description = json['description'];
    this._cells = json['cells'];
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

