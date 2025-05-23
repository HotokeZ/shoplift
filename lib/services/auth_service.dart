import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../screens/sign_in_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initializeUserBanStatus(String userId) async {
    final userDoc = await _firestore.collection('accounts').doc(userId).get();
    
    if (!userDoc.exists || !userDoc.data()!.containsKey('isBanned')) {
      await _firestore.collection('accounts').doc(userId).set({
        'isBanned': false,
      }, SetOptions(merge: true));
    }
  }

  Future<bool> isUserBanned() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final userDoc = await _firestore
        .collection('accounts')
        .doc(user.uid)
        .get();
        
    // If user document doesn't exist or doesn't have isBanned field
    if (!userDoc.exists || !userDoc.data()!.containsKey('isBanned')) {
      await initializeUserBanStatus(user.uid);
      return false;
    }

    // Check if user is admin - admins cannot be banned
    if (userDoc.data()?['role'] == 'admin') {
      return false;
    }

    return userDoc.data()?['isBanned'] ?? false;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> handleBannedUser(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('accounts').doc(user.uid).get();
    final isBanned = userDoc.data()?['isBanned'] ?? false;

    if (isBanned) {
      await signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SignInScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> cleanupBannedUserProducts(String userId) async {
    // Delete or hide the user's products
    final productsSnapshot = await _firestore
        .collection('products')
        .where('sellerId', isEqualTo: userId)
        .get();

    final batch = _firestore.batch();
    for (final doc in productsSnapshot.docs) {
      batch.update(doc.reference, {'isActive': false, 'bannedSeller': true});
      // Alternative: batch.delete(doc.reference); // If you want to delete instead
    }
    await batch.commit();
  }
}