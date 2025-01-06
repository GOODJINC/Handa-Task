import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(); // Firebase 초기화
    _updateUser();
  }

  void _updateUser() {
    setState(() {
      _user = FirebaseAuth.instance.currentUser;
    });
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // 로그인 취소

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      _updateUser();
    } catch (e) {
      // 로그인 중 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: $e')),
      );
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      _updateUser();
    } catch (e) {
      // 로그아웃 중 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('계정 관리'),
      ),
      body: _user == null
          ? Center(
              child: ElevatedButton(
                onPressed: _signInWithGoogle,
                child: Text('구글 계정으로 로그인'),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_user!.photoURL != null)
                  CircleAvatar(
                    backgroundImage: NetworkImage(_user!.photoURL!),
                    radius: 50,
                  ),
                SizedBox(height: 16),
                Text('이름: ${_user!.displayName ?? 'N/A'}'),
                Text('이메일: ${_user!.email ?? 'N/A'}'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _signOut,
                  child: Text('로그아웃'),
                ),
              ],
            ),
    );
  }
}
