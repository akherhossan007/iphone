import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firestore_service.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final FirestoreService _firestore = FirestoreService();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// 1. Email & Password Registration
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
    String? phone,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (credential.user != null) {
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user!.updateDisplayName(displayName);
      }
      await _firestore.saveUserProfile(
        uid: credential.user!.uid,
        email: email.trim(),
        name: displayName ?? '',
        phone: phone ?? '',
        provider: 'password',
      );
    }
    return credential;
  }

  /// 2. Email & Password Sign In
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (credential.user != null) {
      await _firestore.saveUserProfile(
        uid: credential.user!.uid,
        email: credential.user!.email ?? email,
        name: credential.user!.displayName ?? '',
        phone: credential.user!.phoneNumber ?? '',
        provider: 'password',
      );
    }
    return credential;
  }

  /// 3. Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        await _firestore.saveUserProfile(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? googleUser.email,
          name: userCredential.user!.displayName ?? googleUser.displayName ?? '',
          phone: userCredential.user!.phoneNumber ?? '',
          avatar: userCredential.user!.photoURL ?? googleUser.photoUrl ?? '',
          provider: 'google',
        );
      }
      return userCredential;
    } catch (e) {
      debugPrint('FirebaseAuthService Google Sign-In Error: ');
      rethrow;
    }
  }

  /// 4. Phone Number Verification (SMS OTP)
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(String verificationId) codeAutoRetrievalTimeout,
    int? resendToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber.trim(),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      forceResendingToken: resendToken,
      timeout: const Duration(seconds: 60),
    );
  }

  /// 5. Sign In with Phone SMS Code
  Future<UserCredential> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
    String? name,
  }) async {
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode.trim(),
    );
    final userCredential = await _auth.signInWithCredential(credential);

    if (userCredential.user != null) {
      await _firestore.saveUserProfile(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
        name: name ?? userCredential.user!.displayName ?? '',
        phone: userCredential.user!.phoneNumber ?? '',
        provider: 'phone',
      );
    }
    return userCredential;
  }

  /// 6. Password Reset
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// 7. Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }
}
