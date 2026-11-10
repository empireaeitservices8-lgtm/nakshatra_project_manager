// =============================================================================
//  ApiService — Generic JSON-RPC 2.0 HTTP wrapper
// =============================================================================
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/models.dart';

/// Thrown when the server returns a JSON-RPC error block.
class ApiException implements Exception {
  final int code;
  final String message;
  final dynamic data;

  const ApiException({
    required this.code,
    required this.message,
    this.data,
  });

  @override
  String toString() => 'ApiException($code): $message';
}

/// Thrown for network / connectivity issues.
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

// -----------------------------------------------------------------------------

class ApiService {
  final http.Client _client;
  final Duration _timeout;

  /// Default headers applied to every request.
  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  ApiService({
    http.Client? client,
    Duration timeout = const Duration(seconds: 30),
  })  : _client = client ?? http.Client(),
        _timeout = timeout;

  // ---------------------------------------------------------------------------
  //  Session token (set after login, sent as a header on authenticated calls)
  // ---------------------------------------------------------------------------
  String? _sessionToken;

  /// Attach the bearer/session token returned after login.
  void setSessionToken(String token) => _sessionToken = token;

  /// Clear the session (logout).
  void clearSession() => _sessionToken = null;

  bool get isAuthenticated => _sessionToken != null;

  // ---------------------------------------------------------------------------
  //  Core request method
  // ---------------------------------------------------------------------------

  /// Wraps [params] in a JSON-RPC 2.0 envelope and POSTs to [url].
  ///
  /// On success returns the decoded `result` value (as `dynamic`).
  /// Throws [ApiException] if the server returns an `error` block.
  /// Throws [NetworkException] on connectivity problems.
  Future<dynamic> post(String url, {Map<String, dynamic>? params}) async {
    final body = jsonEncode({
      'jsonrpc': '2.0',
      'method': 'call',
      'params': params ?? {},
    });

    final headers = <String, String>{..._defaultHeaders};
    if (_sessionToken != null) {
      headers['Authorization'] = 'Bearer $_sessionToken';
    }

    print('╔════════════════════════════════════════════════════════════════════════');
    print('║ [API REQUEST] ➔ POST $url');
    print('║ [PARAMS]      : ${params ?? {}}');
    if (_sessionToken != null) {
      print('║ [TOKEN]       : Bearer $_sessionToken');
    }
    print('╚════════════════════════════════════════════════════════════════════════');

    try {
      final response = await _client
          .post(Uri.parse(url), headers: headers, body: body)
          .timeout(_timeout);

      print('╔════════════════════════════════════════════════════════════════════════');
      print('║ [API RESPONSE] ➔ Status: ${response.statusCode} | URL: $url');
      print('║ [RESPONSE BODY]:');
      print(response.body);
      print('╚════════════════════════════════════════════════════════════════════════');

      return _handleResponse(response);
    } on SocketException catch (e) {
      print('[API ERROR] SocketException: ${e.message}');
      throw NetworkException('No internet connection: ${e.message}');
    } on HttpException catch (e) {
      print('[API ERROR] HttpException: ${e.message}');
      throw NetworkException('HTTP error: ${e.message}');
    } on FormatException catch (e) {
      print('[API ERROR] FormatException: ${e.message}');
      throw NetworkException('Bad response format: ${e.message}');
    }
  }

  // ---------------------------------------------------------------------------
  //  Response handler
  // ---------------------------------------------------------------------------

  dynamic _handleResponse(http.Response response) {
    late Map<String, dynamic> json;

    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw NetworkException(
          'Could not decode server response (status ${response.statusCode})');
    }

    // -- JSON-RPC error block --------------------------------------------------
    if (json.containsKey('error')) {
      final errMap = json['error'] as Map<String, dynamic>;
      final rpcErr = JsonRpcError.fromJson(errMap);
      print('❌ [JSON-RPC ERROR]: code=${rpcErr.code}, message=${rpcErr.message}');
      throw ApiException(
        code: rpcErr.code,
        message: rpcErr.message,
        data: rpcErr.data,
      );
    }

    // -- HTTP-level errors not wrapped in JSON-RPC ----------------------------
    if (response.statusCode >= 400) {
      final errMsg = json['message'] as String? ??
          'Server error (${response.statusCode})';
      print('❌ [HTTP ERROR $response.statusCode]: $errMsg');
      throw ApiException(
        code: response.statusCode,
        message: errMsg,
      );
    }

    // -- Success: return the `result` value -----------------------------------
    print('✅ [JSON-RPC RESULT]: ${json['result']}');
    return json['result'];
  }

  void dispose() => _client.close();
}
