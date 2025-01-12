import 'package:deliverapi/api_exception.dart';
import 'package:deliverapi/features/authentication/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';


/// Exception for registration failures.
class RegistrationException extends ApiException {
  RegistrationException(super.message);
}

/// Exception for data saving failures.
class DataSavingException extends ApiException {
  DataSavingException(super.message);
}


/// A service that handles user registration, including authentication and saving user data.
class RegistrationService {
  final FirebaseAuth _firebaseAuth;
  final AuthenticationService _authService;

  /// Constructs a [RegistrationService] with the required Firebase and authentication services.
  RegistrationService({
    required FirebaseAuth firebaseAuth,
    required AuthenticationService authService,
  })  : _firebaseAuth = firebaseAuth,
        _authService = authService;

  /// Registers a new user with an email and password.
  ///
  /// Throws [RegistrationException] if the registration process fails.
  Future<UserCredential> _registerUser({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw RegistrationException(
          "Registration failed: ${e.message ?? 'Unknown error'}");
    } catch (e) {
      throw BackendException("Unexpected error during registration: $e");
    }
  }

  /// Saves user data to the backend.
  ///
  /// Throws [DataSavingException] if the data saving process fails.
  Future<void> _storeUserData({
    required Map<String, dynamic> userData,
  }) async {
    try {
      await _authService.saveDocument(data: userData);
    } catch (e) {
      throw DataSavingException("Error saving user data: $e");
    }
  }

  /// Registers a new user by authenticating them and saving their details to the backend.
  ///
  /// Throws [RegistrationException], [DataSavingException], or [BackendException].
  Future<void> registerUser({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final userCredential = await _registerUser(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw RegistrationException("Registration failed. Please try again.");
      }

      await _storeUserData(userData: userData);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw BackendException("Unexpected error during user registration: $e");
    }
  }
}
