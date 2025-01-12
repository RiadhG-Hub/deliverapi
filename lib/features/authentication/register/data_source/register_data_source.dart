import 'package:deliverapi/features/authentication/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A service that handles user registration, including authentication and saving user data.
class RegistrationService {
  final FirebaseAuth _firebaseAuth;
  final AuthenticationService _authService;

  /// Constructs a [RegistrationService] with the required Firebase and authentication services.
  ///
  /// - [_firebaseAuth]: The Firebase Authentication instance for managing user authentication.
  /// - [_authService]: The custom service for saving user-related data to the backend.
  RegistrationService({
    required FirebaseAuth firebaseAuth,
    required AuthenticationService authService,
  })  : _firebaseAuth = firebaseAuth,
        _authService = authService;

  /// Registers a new user with an email and password.
  ///
  /// - [email]: The email address of the user.
  /// - [password]: The password for the user.
  ///
  /// Returns a [UserCredential] upon successful registration.
  /// Throws an exception if the registration process fails.
  Future<UserCredential> _registerUser({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Saves user data to the backend.
  ///
  /// - [userData]: A map containing the user data to be saved.
  ///
  /// Throws an exception if the data saving process fails.
  Future<void> _storeUserData({
    required Map<String, dynamic> userData,
  }) async {
    try {
      await _authService.saveDocument(data: userData);
    } catch (e) {
      rethrow;
    }
  }

  /// Registers a new user by authenticating them and saving their details to the backend.
  ///
  /// - [email]: The email address of the user.
  /// - [password]: The password for the user.
  /// - [userData]: A map containing additional user details to be saved.
  ///
  /// This method performs the following steps:
  /// 1. Registers the user with the provided credentials.
  /// 2. Saves the user's details to the backend.
  ///
  /// Throws an exception if the registration or data saving process fails.
  Future<void> registerUser({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    final userCredential = await _registerUser(
      email: email,
      password: password,
    );

    if (userCredential.user == null) {
      throw Exception("Registration failed. Please try again.");
    }

    await _storeUserData(userData: userData);
  }
}
