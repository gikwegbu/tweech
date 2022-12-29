import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tweech/models/user_model.dart' as model;
import 'package:tweech/providers/user_provider.dart';
import 'package:tweech/utils/utils.dart';

class AuthMethods {
  final _userRef = FirebaseFirestore.instance.collection('users');
  final _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> getCurrentUser(String? uid) async {
    if (uid != null) {
      final snap = await _userRef.doc(uid).get();
      return snap.data();
    }
    return null;
  }

  Future<bool> signupUser(
    BuildContext context,
    String email,
    String username,
    String password,
  ) async {
    bool res = false;
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (cred.user != null) {
        model.User user = model.User(
          username: username,
          email: email,
          uid: cred.user!.uid,
        );
        await _userRef.doc(cred.user!.uid).set(user.toMap());
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        res = true;
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
    return res;
  }

  Future<bool> signInUser(
    BuildContext context,
    String email,
    String password,
  ) async {
    bool res = false;
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (cred.user != null) {
        Provider.of<UserProvider>(context, listen: false).setUser(
          model.User.fromMap(
            await getCurrentUser(cred.user!.uid) ?? {},
          ),
        );
        res = true;
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
    return res;
  }

  Future<bool> signOutUser(
    BuildContext context,
  ) async {
    bool res = false;
    try {
      await _auth.signOut();
      Provider.of<UserProvider>(context, listen: false).clearUser();
      res = true;
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
    return res;
  }

  Future<bool> updatePassword(
    BuildContext context,
    String currentPassword,
    String newPassword,
  ) async {
    bool res = false;
    try {
      User currentUser = _auth.currentUser!;
      //Must re-authenticate user before updating the password. Otherwise it may fail or user get signed out.

      final cred =  EmailAuthProvider.credential(
          email: currentUser.email!, password: currentPassword);

      await currentUser.reauthenticateWithCredential(cred).then((value) async {
        await currentUser.updatePassword(newPassword).then((_) {
          res = true;
        });
      }).catchError((err) {
        showSnackBar(context, err.message!);
      });
      res = true;
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
    navigateBack(context);
    return res;
  }

  // Future<bool> _changePassword(
  //     String currentPassword, String newPassword) async {
  //   bool success = false;

  //   //Create an instance of the current user.
  //   var user = await FirebaseAuth.instance.currentUser!;
  //   //Must re-authenticate user before updating the password. Otherwise it may fail or user get signed out.

  //   final cred = await EmailAuthProvider.credential(
  //       email: user.email!, password: currentPassword);
  //   await user.reauthenticateWithCredential(cred).then((value) async {
  //     await user.updatePassword(newPassword).then((_) {
  //       success = true;
  //     }).catchError((error) {
  //       print(error);
  //     });
  //   }).catchError((err) {
  //     print(err);
  //   });

  //   return success;
  // }
}
