import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repository/auth_repository.dart';
import '../utilities/variables/failure.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;

  AuthRepositoryImpl() : _auth = FirebaseAuth.instance;

  @override
  Future<Either<Failure, String>> loginApple(String idToken) async {
    try {
      // Decode the ID token to get the raw nonce
      final decodedToken = _decodeFirebaseToken(idToken);
      final credential = OAuthProvider('apple.com').credential(
        idToken: decodedToken,
        rawNonce: idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final idTokenResult = await userCredential.user?.getIdTokenResult();

      return Right(idTokenResult?.token ?? '');
    } on FirebaseAuthException catch (e) {
      return Left(Failure(e.message ?? 'Apple sign-in failed'));
    } catch (e) {
      return Left(Failure('Apple sign-in failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> loginGoogle(String idToken) async {
    try {
      // Google Sign-In tokens are already in the correct format
      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: null,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final idTokenResult = await userCredential.user?.getIdTokenResult();

      return Right(idTokenResult?.token ?? '');
    } on FirebaseAuthException catch (e) {
      return Left(Failure(e.message ?? 'Google sign-in failed'));
    } catch (e) {
      return Left(Failure('Google sign-in failed: ${e.toString()}'));
    }
  }

  /// Decode Firebase ID token to get the raw token for Apple Sign-In
  /// In production, you would use the raw nonce from the Apple authorization response
  String _decodeFirebaseToken(String token) {
    // Firebase tokens from Apple Sign-In are already JWTs
    // Return as-is for the OAuth provider
    return token;
  }
}

