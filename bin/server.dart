import 'dart:io';
import 'dart:convert';

import 'package:life/server.dart';


main() async {

  FileManager fs = new FileManager('data/configurations');
  await fs.init();

  Server server = new Server(InternetAddress.LOOPBACK_IP_V4, 8081);

  // Add GET /configurations
  server.addHandler(new Handler('GET', new RegExp(r'\/configurations\/?$'),
      (request, args) async {

        var response = {
          "configurations": fs.getConfigurations().toList(growable: false)
        };
        request.response..statusCode = HttpStatus.OK
                        ..headers.set(HttpHeaders.CONTENT_TYPE, 'application/json')
                        ..headers.set('Access-Control-Allow-Origin', "http://localhost:8080")
                        ..writeln(JSON.encode(response))
                        ..close();
      }));

  // Add GET /configuration/<configuration_id>
  server.addHandler(new Handler('GET', new RegExp(r'\/configurations\/([^/]+)$'),
      (request, args) async {
        String configName = args[0];
        var json = (await fs.getConfiguration(configName)).json();

        var response = {
          "configuration": json
        };
        request.response..statusCode = HttpStatus.OK
                        ..headers.add(HttpHeaders.CONTENT_TYPE, 'application/json')
                        ..headers.set('Access-Control-Allow-Origin', "http://localhost:8080")
                        ..writeln(JSON.encode(response))
                        ..close();
      }));

  server.start();
}
