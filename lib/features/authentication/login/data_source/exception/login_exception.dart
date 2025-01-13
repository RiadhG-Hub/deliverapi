import 'package:deliverapi/api_exception.dart';

/// Exception for authentication failures.
class AuthenticationException extends ApiException {
  AuthenticationException(super.message);
}

/// Exception for user not found scenarios.
class UserNotFoundException extends ApiException {
  UserNotFoundException(super.message);
}