library client_api;

import 'dart:convert';
import 'dart:async';
import 'dart:html';

// TODO: use Configuration class
// will need to rip out dart:io stuff from it
import 'package:life/configuration.dart';


class ClientApi {

  final String server_host;

  ClientApi(this.server_host);

  /// Call /configurations
  /// Return a list of strings representing all the configurations returned from
  /// the server.
  Future<List<String>> getConfigurations() {

    Completer<List<String>> c = new Completer<List<String>>();

    List<String> configurations = new List<String>();

    var request = new HttpRequest();
    request.open('GET', this._url('/configurations'));
    Stream loadEnd = request.onLoadEnd;

    // Wait for data to finish coming back
    loadEnd.listen((e) {

      var res = JSON.decode(request.responseText);
      if (res['configurations'] == null) {
        throw new StateError('configurations not found in json: ${request.responseText}');
      }
      for (String config in res['configurations']) {
        configurations.add(config);
      }
      c.complete(configurations);
    });
    request.send('');

    return c.future;
  }

  /// Call /configuration/<config_id>
  /// Return a Configuration object
  Future<Configuration> getConfiguration(String name) {

    Completer<Configuration> c = new Completer<Configuration>();

    var request = new HttpRequest();
    request.open('GET', this._url('/configurations/$name'));
    Stream loadEnd = request.onLoadEnd;

    loadEnd.listen((e) {
        var res = JSON.decode(request.responseText);
        c.complete(new Configuration.fromJson(res['configuration']));
      });
    request.send('');

    return c.future;
  }

  String _url(String uri) {
    return "${this.server_host}$uri";
  }
}
