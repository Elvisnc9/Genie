import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      // 🔹 Show loader dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: Colors.black),
        ),
      );

      // Start Google sign-in
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        Navigator.pop(context); // Close loader if user cancels
        return null;
      }

      // Get authentication
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _auth.signInWithCredential(credential);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('loggedIn', true);
      await prefs.setString('userName', userCredential.user?.displayName ?? '');

      // Close loader before showing flushbar or navigating
      Navigator.pop(context);

      // Show welcome message
      Flushbar(
        message: 'Welcome, ${userCredential.user?.displayName ?? "User"}!',
        backgroundColor: Colors.black,
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(8),
      ).show(context);

      // Navigate to Home screen after short delay
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacementNamed(context, '/Home');

      return userCredential;
    } catch (e) {
      // Ensure loader is closed on error
      Navigator.pop(context);

      Flushbar(
        message: 'Google Sign-In Error: $e',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return null;
    }
  }

  Future<void> signOut(BuildContext context) async {
    await GoogleSignIn().signOut();
    await _auth.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacementNamed(context, '/AuthScreen');
  }
}


//   // ----------------- FACEBOOK SIGN-IN -----------------
//   Future<UserCredential?> signInWithFacebook(BuildContext context) async {
//     try {
//       // Start the Facebook login process
//       final LoginResult loginResult = await FacebookAuth.instance.login();

//       if (loginResult.status == LoginStatus.success) {
//         final OAuthCredential credential = FacebookAuthProvider.credential(
//           loginResult.accessToken!.tokenString,
//         );

//         final userCredential = await _auth.signInWithCredential(credential);

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content:
//                 Text('Welcome, ${userCredential.user?.displayName ?? "User"}!'),
//             backgroundColor: Colors.green,
//           ),
//         );

//         return userCredential;
//       } else if (loginResult.status == LoginStatus.cancelled) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Facebook login cancelled')),
//         );
//         return null;
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Facebook login failed: ${loginResult.status}')),
//         );
//         return null;
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Facebook Sign-In Error: $e')),
//       );
//       return null;
//     }
//   }

// }
