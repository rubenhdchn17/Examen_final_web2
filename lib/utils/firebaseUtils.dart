import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseUtils {
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  static DatabaseReference getDatabaseReference() {
    return FirebaseDatabase.instance.reference();
  }

  static FirebaseAuth getFirebaseAuth() {
    return FirebaseAuth.instance;
  }
}