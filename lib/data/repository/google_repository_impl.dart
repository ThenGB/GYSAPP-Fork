import 'dart:developer';

import 'package:google_sign_in/google_sign_in.dart';

import '../utilities/platform_utils.dart';
import '../../domain/repository/google_repository.dart';

class GoogleRepositoryImpl implements GoogleRepository {
  final GoogleSignIn googleSignIn;

  GoogleRepositoryImpl(this.googleSignIn);
  @override
  Future<GoogleSignInAccount?> signIn() async {
    if (!isGoogleSignInConfiguredForCurrentPlatform) {
      return null;
    }

    GoogleSignInAccount? googleUser;
    try {
      googleUser =
          await googleSignIn.signInSilently() ?? await googleSignIn.signIn();
    } catch (e) {
      log(e.toString());
    }
    return googleUser;
  }

  @override
  Future<void> signOut() async {
    if (!isGoogleSignInConfiguredForCurrentPlatform) {
      return;
    }
    await googleSignIn.signOut();
  }
}
