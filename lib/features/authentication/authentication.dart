import 'package:deliverapi/features/authentication/register/data_source/register_data_source.dart';
import 'package:firebase_facilitator/mixin/auth_service.dart';
import 'package:firebase_facilitator/mixin/crud_repos.dart';
import 'package:firebase_facilitator/mixin/firestore_read_service.dart';
import 'package:firebase_facilitator/mixin/firestore_storage_service.dart';
import 'package:firebase_facilitator/mixin/firestore_write_service.dart';
import 'package:firebase_facilitator/mixin/logger_service.dart';

import 'login/data_source/login_data_source.dart';

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

/// An abstract interface defining the required authentication operations.
abstract class AuthenticationInterface {
  /// Logs in a user using their email and password, returning a map containing authentication details.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  /// Registers a new user with the provided email, password, and additional user data.
  Future<void> registerUser({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  });
}

/// A concrete implementation of the [AuthenticationInterface] that integrates login and registration services.
class AuthenticationApi extends AuthenticationInterface {
  final RegistrationService _registrationService;
  final LoginService _loginService;

  /// Creates an instance of [Authentication] with the required services for login and registration.
  AuthenticationApi({
    required RegistrationService registrationService,
    required LoginService loginService,
  })  : _registrationService = registrationService,
        _loginService = loginService;

  /// Logs in a user by delegating to the [LoginService].
  ///
  /// [email] - The user's email.
  /// [password] - The user's password.
  /// Returns a [Future] containing a map with authentication details.
  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await _loginService.login(email: email, password: password);
    return result;
  }

  /// Registers a new user by delegating to the [RegistrationService].
  ///
  /// [email] - The user's email.
  /// [password] - The user's password.
  /// [userData] - Additional data to associate with the user.
  /// Returns a [Future] that completes when registration is successful.
  @override
  Future<void> registerUser({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    await _registrationService.registerUser(
      email: email,
      password: password,
      userData: userData,
    );
  }
}
