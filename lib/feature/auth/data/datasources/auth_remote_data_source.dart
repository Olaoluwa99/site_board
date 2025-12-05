import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Session? get currentUserSession;
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<UserModel?> getCurrentUserData();

  Future<bool> logout();

  Future<void> deleteAccount();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        password: password,
        email: email,
      );
      if (response.user == null) throw const ServerException('User is null');
      return UserModel.fromJson(
        response.user!.toJson(),
      ).copyWith(email: currentUserSession!.user.email);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        password: password,
        email: email,
        data: {'name': name},
      );
      if (response.user == null) throw const ServerException('User is null');
      return UserModel.fromJson(
        response.user!.toJson(),
      ).copyWith(email: currentUserSession!.user.email);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Session? get currentUserSession => supabaseClient.auth.currentSession;

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUserSession != null) {
        final response = await supabaseClient
            .from('profiles')
            .select()
            .eq('id', currentUserSession!.user.id);
        return UserModel.fromJson(
          response.first,
        ).copyWith(email: currentUserSession!.user.email);
      }
      return null;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await supabaseClient.auth.signOut();
      return true;
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final userId = currentUserSession?.user.id;
      if (userId == null) throw ServerException("User not found");

      // Note: Standard Supabase users cannot delete themselves without an RPC or Edge Function
      // calling auth.admin.deleteUser.
      // However, usually client-side deletion removes the public 'profiles' row if cascade is set up,
      // but 'auth.users' remains.
      // For this implementation, we will assume an RPC function 'delete_user' exists
      // OR we just use the Dart SDK method which might rely on backend config.

      // Attempting standard RPC method if available, else falling back to profile deletion
      // which triggers cascade.
      try {
        await supabaseClient.rpc('delete_user');
      } catch(_) {
        // Fallback: This only works if your DB allows deleting profiles
        // and doesn't fully clean up Auth.
        // await supabaseClient.from('profiles').delete().eq('id', userId);
        throw ServerException("Account deletion requires admin privileges or an RPC function 'delete_user'.");
      }

      await supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}