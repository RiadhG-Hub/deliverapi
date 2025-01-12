import 'package:deliverapi/api_exception.dart';
import 'package:deliverapi/features/authentication/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';



/// Exception for authentication failures.
class AuthenticationException extends ApiException {
  AuthenticationException(super.message);
}

/// Exception for user not found scenarios.
class UserNotFoundException extends ApiException {
  UserNotFoundException(super.message);
}


/// A service that manages the login process for users, including
/// authentication and retrieval of user data from the backend.
class LoginService {
  final FirebaseAuth firebaseAuth;
  final AuthenticationService authService;

  /// Constructs a [LoginService] with the necessary Firebase and authentication services.
  LoginService({
    required this.firebaseAuth,
    required this.authService,
  });

  /// Authenticates a user with their email and password.
  ///
  /// Throws [AuthenticationException] if authentication fails.
  Future<UserCredential> _authenticateUser({
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
      throw BackendException("Unexpected error during authentication: $e");
    }
  }

  /// Retrieves user details by their unique ID.
  ///
  /// Throws [UserNotFoundException] if the user data is not found.
  /// Throws [BackendException] if the backend call fails.
  Future<Map<String, dynamic>> _getUserDetailsById({
    required String userId,
  }) async {
    try {
      final userDetails = await authService.fetchDocumentById(docId: userId);
      if (userDetails == null) {
        throw UserNotFoundException("User not found. Please sign up first.");
      }
      return userDetails;
    } catch (e) {
      throw BackendException("Error fetching user details: $e");
    }
  }

  /// Logs in a user using their email and password.
  ///
  /// Throws [AuthenticationException], [UserNotFoundException], or [BackendException].
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _authenticateUser(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw AuthenticationException(
            "Authentication failed. User record not found.");
      }

      return await _getUserDetailsById(
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
