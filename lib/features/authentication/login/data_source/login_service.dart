import 'package:deliverapi/api_exception.dart';
import 'package:deliverapi/features/authentication/authentication_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'exception/login_exception.dart';

abstract class LoginServiceInterface {
  /// Signs in a user with their email and password.
  ///
  /// Throws [AuthenticationException] if sign-in fails.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  });

  /// Fetches user information by their unique ID.
  ///
  /// Throws [UserNotFoundException] if the user data is not found.
  /// Throws [BackendException] if the backend call fails.
  Future<Map<String, dynamic>> fetchUserById({
    required String userId,
  });

  /// Handles the complete login process, including authentication
  /// and fetching user details.
  ///
  /// Throws [AuthenticationException], [UserNotFoundException], or [BackendException].
  Future<Map<String, dynamic>> performLogin({
    required String email,
    required String password,
  });
}

/// A service responsible for managing user authentication and
/// retrieving user data from the backend.
class LoginService extends LoginServiceInterface {
  final FirebaseAuth firebaseAuth;
  final AuthenticationService backendService;

  /// Constructs an [AuthService] with Firebase and backend service dependencies.
  LoginService({
    required this.firebaseAuth,
    required this.backendService,
  });

  /// Signs in a user with their email and password.
  ///
  /// Throws [AuthenticationException] if sign-in fails.
  @override
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
          "Authentication failed: ${e.message ?? 'Unknown error'}");
    } catch (e) {
      throw BackendException("Unexpected error during sign-in: $e");
    }
  }

  /// Fetches user information by their unique ID.
  ///
  /// Throws [UserNotFoundException] if the user data is not found.
  /// Throws [BackendException] if the backend call fails.
  @override
  Future<Map<String, dynamic>> fetchUserById({
    required String userId,
  }) async {
    try {
      final userDetails = await backendService.fetchDocumentById(docId: userId);
      if (userDetails == null) {
        throw UserNotFoundException("User not found. Please sign up first.");
      }
      return userDetails;
    } catch (e) {
      throw BackendException("Error fetching user details: $e");
    }
  }

  /// Handles the complete login process, including authentication
  /// and fetching user details.
  ///
  /// Throws [AuthenticationException], [UserNotFoundException], or [BackendException].
  @override
  Future<Map<String, dynamic>> performLogin({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await signIn(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw AuthenticationException(
            "Authentication failed. User record not found.");
      }

      return await fetchUserById(
        userId: userCredential.user!.uid,
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw BackendException("Unexpected error during login: $e");
    }
  }
}
