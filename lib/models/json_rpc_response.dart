// =============================================================================
//  JsonRpcResponse<T> — Generic JSON-RPC 2.0 response wrapper
// =============================================================================

/// Represents the top-level envelope for every JSON-RPC 2.0 response.
///
/// On success: [result] is non-null, [error] is null.
/// On failure: [error] is non-null, [result] is null.
class JsonRpcResponse<T> {
  final String jsonrpc;
  final int? id;
  final T? result;
  final JsonRpcError? error;

  const JsonRpcResponse({
    required this.jsonrpc,
    this.id,
    this.result,
    this.error,
  });

  bool get isSuccess => error == null && result != null;
  bool get isError => error != null;
}

// -----------------------------------------------------------------------------

/// Represents the `error` block inside a JSON-RPC 2.0 error response.
class JsonRpcError {
  final int code;
  final String message;
  final dynamic data;

  const JsonRpcError({
    required this.code,
    required this.message,
    this.data,
  });

  factory JsonRpcError.fromJson(Map<String, dynamic> json) {
    return JsonRpcError(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String? ?? 'Unknown error',
      data: json['data'],
    );
  }

  @override
  String toString() => 'JsonRpcError($code): $message';
}
