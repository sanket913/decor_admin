import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential authResult = await _auth.signInWithCredential(credential);
        final User? user = authResult.user;
        return user;
      }
    } catch (e) {
      print("Error signing in with Google: $e");
    }
    return null;
  }

  Future<bool> verifyGoogleSignIn(String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _db.collection('Admin').where('email', isEqualTo: email).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error verifying Google sign-in: $e");
      return false;
    }
  }
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print("Error signing out from Google: $e");
    }
  }


  //email auth

  Future<User?> createUserWithEmailAndPassword(
  String email, String password) async {
  try {
  final cred = await _auth.createUserWithEmailAndPassword(
  email: email, password: password);
  return cred.user;
  } catch (e) {
  log("Something went wrong");
  }
  return null;
  }

  Future<bool?> loginUserWithEmailAndPassword(
  String email, String password) async {
  try {
  final cred = await _auth.signInWithEmailAndPassword(
  email: email, password: password);
  return true;
  } catch (e) {
  log("Something went wrong");
  }
  return false;
  }

  Future<void> signout() async {
  try {
  await _auth.signOut();
  } catch (e) {
  log("Something went wrong");
  }
  }
  }
