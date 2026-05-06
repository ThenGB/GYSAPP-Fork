import 'package:google_sign_in/google_sign_in.dart';

abstract class GoogleRepository {
  Future<GoogleSignInAccount?> signIn();
  Future<void> signOut();
}
