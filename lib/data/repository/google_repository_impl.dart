import 'dart:developer';

import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/repository/google_repository.dart';

class GoogleRepositoryImpl implements GoogleRepository {
  final GoogleSignIn googleSignIn;

  GoogleRepositoryImpl(this.googleSignIn);
  @override
  Future<GoogleSignInAccount?> signIn() async {
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
  signOut() async {
    await googleSignIn.signOut();
  }
}
