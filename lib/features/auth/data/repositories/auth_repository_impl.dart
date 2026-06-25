import 'package:supabase_flutter/supabase_flutter.dart'
    hide AuthException;
import 'package:supabase_flutter/supabase_flutter.dart' as supa
    show AuthException;

import '../../../../core/error/app_exception.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_source.dart';

/// Concrete implementation of [AuthRepository].
///
/// Wraps [AuthDataSource] and maps raw exceptions to [AppException] subtypes
/// so the presentation layer never has to handle Supabase/Google internals.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource);

  final AuthDataSource _dataSource;

  @override
  Future<User> signInWithGoogle() async {
    try {
      final response = await _dataSource.signInWithGoogle();
      final user = response.user;
      if (user == null) {
        throw const AuthException(message: 'Sign-in succeeded but returned no user.');
      }
      return user;
    } on supa.AuthException catch (e) {
      throw AuthException(message: e.message);
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('cancelled')) {
        throw const AuthException(message: 'Sign-in was cancelled.');
      }
      throw AuthException(message: msg);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _dataSource.signOut();
    } on supa.AuthException catch (e) {
      throw AuthException(message: e.message);
    } on Exception catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Session? getSession() => _dataSource.getSession();

  @override
  Stream<AuthState> authStateStream() => _dataSource.authStateStream();
}
