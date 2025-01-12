/// Base exception class for all API-related exceptions.
abstract class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

/// Exception for backend-related issues.
class BackendException extends ApiException {
  BackendException(super.message);
}
