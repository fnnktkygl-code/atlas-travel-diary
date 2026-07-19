import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn? _googleSignInInstance;
  
  GoogleSignIn get _googleSignIn {
    _googleSignInInstance ??= GoogleSignIn(scopes: ['email']);
    return _googleSignInInstance!;
  }

  User? _user;
  User? get user => _user;
  String? get uid => _user?.uid;
  bool get isAuthenticated => _user != null;
  String? errorMessage;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
    
    if (kIsWeb) {
      _checkRedirectResult();
    }
  }

  Future<void> _checkRedirectResult() async {
    try {
      await _auth.getRedirectResult();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      debugPrint("Error from redirect result: $e");
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        await _auth.signInWithPopup(authProvider);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return; // User canceled the sign-in

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      debugPrint("Error signing in with Google: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }
}
