import 'package:deliverapi/features/authentication/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A service that manages the login process for users, including
/// authentication and retrieval of user data from the backend.
class LoginService {
  final FirebaseAuth firebaseAuth;
  final AuthenticationService authService;

  /// Constructs a [LoginService] with the necessary Firebase and authentication services.
  ///
  /// - [firebaseAuth]: The Firebase Authentication instance for handling user authentication.
  /// - [authService]: The custom service for fetching user-related data.
  LoginService({
    required this.firebaseAuth,
    required this.authService,
  });

  /// Authenticates a user with their email and password.
  ///
  /// - [email]: The user's email address.
  /// - [password]: The user's password.
  ///
  /// Returns a [UserCredential] if the authentication is successful.
  /// Throws an exception if authentication fails.
  Future<UserCredential> _authenticateUser({
    required String email,
    required String password,
  }) async {
    try {
      return await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves user details by their unique ID.
  ///
  /// - [userId]: The unique identifier of the user.
  ///
  /// Returns a [Map<String, dynamic>] containing the user's details if found.
  /// Throws an exception if the user data is not found or if the backend call fails.
  Future<Map<String, dynamic>> _getUserDetailsById({
    required String userId,
  }) async {
    final userDetails = await authService.fetchDocumentById(docId: userId);
    if (userDetails == null) {
      throw Exception("User not found. Please sign up first.");
    }
    return userDetails;
  }

  /// Logs in a user using their email and password.
  ///
  /// - [email]: The user's email address.
  /// - [password]: The user's password.
  ///
  /// This method handles both authentication and fetching user details:
  /// 1. Authenticates the user using the provided credentials.
  /// 2. Fetches the user's details from the backend based on their ID.
  ///
  /// Returns a [Map<String, dynamic>] containing the user's details if the process is successful.
  /// Throws an exception if authentication fails or the user details cannot be retrieved.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final userCredential = await _authenticateUser(
      email: email,
      password: password,
    );

    if (userCredential.user == null) {
      throw Exception("Authentication failed. Please sign up first.");
    }

    return await _getUserDetailsById(
      userId: userCredential.user!.uid,
    );
  }
}
