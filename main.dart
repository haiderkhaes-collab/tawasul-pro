import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(TawasulApp());
}

class TawasulApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تواصل',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Cairo', brightness: Brightness.dark),
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('تواصل PRO', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            ElevatedButton.icon(
              icon: Icon(Icons.login),
              label: Text('متابعة باستخدام Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () async {
                final user = await signInWithGoogle();
                if (user != null) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
                }
              },
            ),
            SizedBox(height: 20),
            Text('راح تطلعلك حسابات الجيميل الموجودة بتلفونك', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('أهلاً، ${user?.displayName ?? 'صديقي'}')),
      body: _index == 0 ? ChatsTab() : PostsTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'الدردشات'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'المنشورات'),
        ],
      ),
      floatingActionButton: _index == 0 ? FloatingActionButton(
        child: Icon(Icons.group_add),
        onPressed: () => _createGroup(context),
      ) : null,
    );
  }

  void _createGroup(BuildContext context) {
    // هنا تنشئ كروب جديد في Firestore
    FirebaseFirestore.instance.collection('groups').add({
      'name': 'كروب جديد',
      'members': [user?.uid],
      'createdAt': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إنشاء الكروب')));
  }
}

class ChatsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('الدردشات والكروبات الخاصة - جاهزة للربط مع Firestore'));
  }
}

class PostsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('المنشورات والستوري - جاهزة للربط مع Firestore'));
  }
}
