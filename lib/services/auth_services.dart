import 'package:community_report_app/models/profile.dart';
import 'package:community_report_app/services/profile_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ProfileService _profileService = ProfileService();

  // Sign in with Email & Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Login failed";
    }
  }

  // Register with Email & Password
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        final profile = Profile(
          uid: user.uid,
          email: user.email!,
          username: user.email!.split('@')[0],
          role: "member",
        );
        await _profileService.createUserProfile(profile);
      }
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Register failed";
    }
  }

  // Login dengan Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      User? user = userCredential.user;

      final exists = await _profileService.checkUserExists(user!.uid);
      if (!exists) {
        final profile = Profile(
          uid: user.uid,
          email: user.email!,
          username: user.email!.split('@')[0],
          role: "member",
        );
        await _profileService.createUserProfile(profile);
      }

      if (user != null) {
        await user.updatePhotoURL(googleUser.photoUrl);
        await user.updateDisplayName(googleUser.displayName);
        await user.reload(); // refresh data
      }

      return userCredential.user;
    } catch (e) {
      print('Google Sign-In error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;
}
