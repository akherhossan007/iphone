import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _users => _db.collection('users');
  CollectionReference get _carts => _db.collection('carts');
  CollectionReference get _wishlists => _db.collection('wishlists');
  CollectionReference get _orders => _db.collection('orders');

  /// 1. Save or Update User Profile
  Future<void> saveUserProfile({
    required String uid,
    required String email,
    required String name,
    required String phone,
    String avatar = '',
    String provider = 'password',
  }) async {
    try {
      await _users.doc(uid).set({
        'uid': uid,
        'email': email,
        'displayName': name,
        'phoneNumber': phone,
        'photoURL': avatar,
        'provider': provider,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore saveUserProfile error: ');
    }
  }

  /// 2. Get User Profile Document
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Firestore getUserProfile error: ');
    }
    return null;
  }

  /// 3. Sync User Cart
  Future<void> saveUserCart(String uid, List<Map<String, dynamic>> items) async {
    try {
      await _carts.doc(uid).set({
        'items': items,
        'itemCount': items.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore saveUserCart error: ');
    }
  }

  /// 4. Sync User Wishlist
  Future<void> saveUserWishlist(String uid, List<int> productIds) async {
    try {
      await _wishlists.doc(uid).set({
        'productIds': productIds,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore saveUserWishlist error: ');
    }
  }

  /// 5. Record Order in Firestore
  Future<void> recordOrder(String uid, Map<String, dynamic> orderData) async {
    try {
      await _orders.add({
        'userId': uid,
        ...orderData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore recordOrder error: ');
    }
  }
}
