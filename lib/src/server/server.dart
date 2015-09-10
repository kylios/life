part of server;


typedef void HandlerFn(HttpRequest request, List<String> pathArgs);
typedef void _HandlerFn();


class Handler {
  final String method;
  final RegExp uriPattern;
  final HandlerFn _handler;

  Handler(this.method, this.uriPattern, this._handler);

  /// Evaluate this handler for a match and return a _HandlerFn instance that
  /// can be immediately invoked.  The returned instance closes over the given
  /// request variable and the arguments to the defined handler function.
  _HandlerFn evaluate(HttpRequest request) {
    if (this.method == request.method) {

      // Try to match the URI
      Match match = this.uriPattern.firstMatch(request.uri.path);
      if (match != null) {
        var fn = this._handler;
        List<String> args = [];

        // Pull match arguments out of the URI
        for (int i = 1; i < match.groupCount + 1; i++) {
          args.add(match.group(i));
        }
        // Returns a closure with the request and arguments in scope.
        // This function does not get called immediately, but is returned to the
        // caller to be executed at a later time.
        return () async {
          // First try to run the handled function
          try {
            await fn(request, args);

          } catch (e, st) {
            // Catch errors and return a 500
            var response = {
              "exception": {
                "type": "${reflect(e).type.reflectedType}",
                "message": e.toString(),
                "stacktrace": st.toString()
              }
            };
            print(response);
            request.response..statusCode = HttpStatus.INTERNAL_SERVER_ERROR
                        ..headers.set(HttpHeaders.CONTENT_TYPE, 'application/json')
                        ..headers.set('Access-Control-Allow-Origin', "http://localhost:8080")
                        ..writeln(JSON.encode(response))
                        ..close(); 
          }
        };
      }
    }

    return null;
  }
}


class HandlerNotFoundException implements Exception {
  String _message;
  String get message => this._message;
  HandlerNotFoundException(HttpRequest req) {
    this._message = "No handler found for request ${req.method} ${req.uri}";
  }
}


void notFoundHandler(HttpRequest request, List<String> _ /* ignored */) {
  request.response..statusCode = HttpStatus.NOT_FOUND
                        ..write('Not found')
                        ..close();
}

class Server {

  List<Handler> _handlers = new List<Handler>();

  final int port;
  final InternetAddress address;

  Server(this.address, this.port);

  /// Start the server.  This binds the server to the given port and begins 
  /// handling requests.
  dynamic start() async {

    HttpServer requestServer =
        await HttpServer.bind(this.address, this.port);

    // Handle the requests
    await for (var request in requestServer) {
      this._handleRequest(request);
    }

    return null;
  }

  /// Add a request handler
  void addHandler(Handler handler) {
    this._handlers.add(handler);
  }

  /// Find and return the function to handle the given http request.  This
  /// method always returns a handler function, meaning if no matches were
  /// found, the 404 handler is returned.
  _HandlerFn _findHandler(HttpRequest request) {
    for (Handler h in this._handlers) {
      _HandlerFn fn = h.evaluate(request);
      if (fn != null) {
        return fn;
      }
    }
    return () => notFoundHandler(request, []);
  }

  /// Handle an http request by searching the list of handlers for the suitable
  /// handler for this request, and then invoking the function assigned to that
  /// handler.
  dynamic _handleRequest(HttpRequest request) async {
    _HandlerFn fn = this._findHandler(request);
    return await fn();
  }
}
