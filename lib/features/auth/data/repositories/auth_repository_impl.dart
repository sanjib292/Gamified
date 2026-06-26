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
  Future<void> signInWithGoogle() async {
    try {
      await _dataSource.signInWithGoogle();
    } on supa.AuthException catch (e) {
      throw AuthException(message: e.message);
    } on Exception catch (e) {
      throw AuthException(message: e.toString());
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
