import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _showToast(
        message: "Successfully signed up!",
        backgroundColor: Colors.green,
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _showToast(
        message: _getErrorMessage(e),
        backgroundColor: Colors.red,
      );
      return null;
    } catch (e) {
      _showToast(
        message: "Error: $e",
        backgroundColor: Colors.red,
      );
      return null;
    }
  }

  Future<User?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _showToast(
        message: "Successfully signed in!",
        backgroundColor: Colors.green,
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _showToast(
        message: _getErrorMessage(e),
        backgroundColor: Colors.red,
      );
      return null;
    } catch (e) {
      _showToast(
        message: "Error: $e",
        backgroundColor: Colors.red,
      );
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _showToast(
        message: "Logged out successfully",
        backgroundColor: Colors.grey,
      );
    } catch (e) {
      _showToast(
        message: "Error: $e",
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> deleteAccount() async {
    try {
      if (_auth.currentUser != null) {
        await _auth.currentUser!.delete();
        _showToast(
          message: "Account successfully deleted!",
          backgroundColor: Colors.orange,
        );
      } else {
        _showToast(
          message: "No active user found.",
          backgroundColor: Colors.orange,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showToast(
          message: "For security reasons, please re-login before deleting your account.",
          backgroundColor: Colors.red,
        );
      } else {
        _showToast(
          message: "Error: ${_getErrorMessage(e)}",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      _showToast(
        message: "Error: $e",
        backgroundColor: Colors.red,
      );
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak';
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email format';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'user-disabled':
        return 'This user account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled';
      default:
        return 'Error: ${e.message}';
    }
  }

  void _showToast({
    required String message,
    required Color backgroundColor,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}