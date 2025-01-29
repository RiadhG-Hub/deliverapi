import 'package:deliverapi/api_exception.dart';

/// Represents an exception that occurs during the user registration process.
///
/// This class serves as a base for specific registration-related exceptions.
class RegistrationException extends ApiException {
  /// Creates a new [RegistrationException] with the specified [message].
  RegistrationException(super.message);
}

/// Represents an exception that occurs when a user registration fails due to an unknown reason.
///
/// This exception is thrown when the specific cause of the registration failure
/// cannot be determined.
class UnknownRegistrationException extends RegistrationException {
  /// Creates a new [UnknownRegistrationException] with the specified [message].
  UnknownRegistrationException(super.message);
}

/// Represents an exception that occurs when there's a failure while saving data during user registration.
///
/// This exception is thrown when the application is unable to persist the user's
/// registration data, such as user details or preferences, to a data store.
class DataSavingException extends ApiException {
  /// Creates a new [DataSavingException] with the specified [message].
  DataSavingException(super.message);
}
