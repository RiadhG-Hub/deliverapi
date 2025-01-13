import 'package:deliverapi/features/authentication/user_registration_service/data_source/register_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_facilitator/mixin/auth_service.dart';
import 'package:firebase_facilitator/mixin/crud_repos.dart';
import 'package:firebase_facilitator/mixin/firestore_read_service.dart';
import 'package:firebase_facilitator/mixin/firestore_storage_service.dart';
import 'package:firebase_facilitator/mixin/firestore_write_service.dart';
import 'package:firebase_facilitator/mixin/logger_service.dart';
import 'login/data_source/login_service.dart';

/// Base exception class for all authentication-related exceptions.
abstract class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

/// Exception for login failures.
class LoginException extends AuthException {
  LoginException(super.message);
}

/// Exception for Firestore interaction failures.
class FirestoreException extends AuthException {
  FirestoreException(super.message);
}

/// A service that provides authentication-related operations, combining multiple Firebase mixins
/// for seamless Firestore interaction and authentication handling.
class AuthenticationService
    with
        FirestoreReadRepository,
        FirestoreWriteRepository,
        AuthRepository,
        FirebaseStorageService {
  /// Returns the Firestore read service implementation responsible for fetching data from Firestore.
  @override
  FirestoreReadService get firestoreReadService => FirestoreServiceImpl();

  /// Returns the Firestore write service implementation responsible for saving and deleting data in Firestore.
  @override
  FirestoreWriteService get firestoreWriteService =>
      FirestoreWriteServiceImpl();

  /// Configures the logger service to track operations. Logging is enabled in this case.
  @override
  LoggerService? get loggerService => LoggerServiceImpl(true);

  /// Specifies the Firestore collection name that this service operates on.
  @override
  String get collection => "users";

  /// Returns the authentication service implementation for handling user authentication.
  @override
  AuthService get authService => FirebaseAuthService();
}

/// A concrete implementation of the [AuthenticationInterface] that integrates login and registration services.
class AuthenticationApi
    implements LoginServiceInterface, UserRegistrationServiceInterface {
  final UserRegistrationService _registrationService;
  final LoginService _loginService;

  /// Creates an instance of [AuthenticationApi] with the required services for login and registration.
  AuthenticationApi({
    required UserRegistrationService registrationService,
    required LoginService loginService,
  })  : _registrationService = registrationService,
        _loginService = loginService;

  @override
  Future<Map<String, dynamic>> fetchUserById({required String userId}) =>
      _loginService.fetchUserById(userId: userId);

  @override
  Future<Map<String, dynamic>> performLogin(
          {required String email, required String password}) =>
      _loginService.performLogin(email: email, password: password);

  @override
  Future<UserCredential> createUserAccount(
          {required String email, required String password}) =>
      _registrationService.createUserAccount(email: email, password: password);

  @override
  Future<void> persistUserData({required Map<String, dynamic> userData}) =>
      _registrationService.persistUserData(userData: userData);

  @override
  Future<void> signUpUser(
          {required String email,
          required String password,
          required Map<String, dynamic> userData}) =>
      _registrationService.signUpUser(
          email: email, password: password, userData: userData);

  @override
  Future<UserCredential> signIn(
          {required String email, required String password}) =>
      _loginService.signIn(email: email, password: password);
}
