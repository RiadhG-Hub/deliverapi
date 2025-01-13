import 'package:deliverapi/api_exception.dart';

/// Exception for registration failures.
class RegistrationException extends ApiException {
  RegistrationException(super.message);
}

/// Exception for data saving failures.
class DataSavingException extends ApiException {
  DataSavingException(super.message);
}
