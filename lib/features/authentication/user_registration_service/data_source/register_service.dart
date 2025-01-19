import 'dart:io';

import 'package:deliverapi/api_exception.dart';
import 'package:deliverapi/features/authentication/authentication_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mime/mime.dart';

import 'exception/register_exception.dart';

/// Abstract class that defines the contract for user registration services.
abstract class UserRegistrationServiceInterface {
  /// Creates a new user account with the provided email and password.
  ///
  /// Throws [RegistrationException] if the sign-up process fails.
  Future<UserCredential> createUserAccount({
    required String email,
    required String password,
  });

  /// Persists the user data to the backend service.
  ///
  /// Throws [DataSavingException] if the data saving operation fails.
  Future<void> persistUserData({
    required Map<String, dynamic> userData,
  });

  /// Handles the complete user registration process by creating an account
  /// and saving the user's information to the backend.
  ///
  /// Throws [RegistrationException], [DataSavingException], or [BackendException].
  Future<void> signUpUser({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  });

  Future<String> storePicture({required File file});
}

/// Implementation of the [UserRegistrationServiceInterface] that uses Firebase
/// Authentication and a backend service for user registration.
class UserRegistrationService implements UserRegistrationServiceInterface {
  final FirebaseAuth _firebaseAuth;
  final AuthenticationService _backendService;

  /// Constructs a [UserRegistrationService] with required Firebase and backend services.
  UserRegistrationService({
    required FirebaseAuth firebaseAuth,
    required AuthenticationService backendService,
  })  : _firebaseAuth = firebaseAuth,
        _backendService = backendService;

  /// Creates a new user account with the provided email and password.
  ///
  /// Throws [RegistrationException] if the sign-up process fails.
  @override
  Future<UserCredential> createUserAccount({
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
          "Sign-up failed: ${e.message ?? 'Unknown error'}");
    } catch (e) {
      throw BackendException("Unexpected error during sign-up: $e");
    }
  }

  /// Persists the user data to the backend service.
  ///
  /// Throws [DataSavingException] if the data saving operation fails.
  @override
  Future<void> persistUserData({
    required Map<String, dynamic> userData,
  }) async {
    try {
      await _backendService.saveDocument(data: userData);
    } catch (e) {
      throw DataSavingException("Error saving user data: $e");
    }
  }

  /// Handles the complete user registration process by creating an account
  /// and saving the user's information to the backend.
  ///
  /// Throws [RegistrationException], [DataSavingException], or [BackendException].
  @override
  Future<void> signUpUser({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final userCredential = await createUserAccount(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw RegistrationException("Sign-up failed. Please try again.");
      }

      await persistUserData(userData: userData);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw BackendException("Unexpected error during user sign-up: $e");
    }
  }

  /// Stores a picture file in the backend storage.
  ///
  /// This method uploads an image file to the specified storage path.
  /// It validates the file to ensure it is a valid image before uploading.
  ///
  /// Throws:
  /// - [ArgumentError] if the provided file is not a valid image.
  ///
  /// Parameters:
  /// - [file]: The image file to be uploaded. It must be a valid image file with
  ///   an appropriate MIME type (e.g., `image/jpeg`, `image/png`).
  ///
  /// Returns:
  /// A [Future] containing the URL or identifier of the stored picture.
  ///
  /// Example:
  /// ```dart
  /// final file = File('path/to/picture.jpg');
  /// try {
  ///   final url = await storePicture(file: file);
  ///   print('Picture uploaded successfully: $url');
  /// } catch (e) {
  ///   print('Error: $e');
  /// }
  /// ```
  @override
  Future<String> storePicture({required File file}) async {
    // Get the MIME type of the file
    final String? mimeType = lookupMimeType(file.path);

    // Check if the MIME type is an image
    if (mimeType == null || !mimeType.startsWith('image/')) {
      throw ArgumentError('The provided file is not a valid picture.');
    }

    // Upload the file to the backend storage
    final String result = await _backendService.uploadFile(
        filePath: file.path, storagePath: "users/pictures");
    return result;
  }
}
