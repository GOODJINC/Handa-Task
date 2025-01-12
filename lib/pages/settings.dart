import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:handa/database/database_helper.dart';
import 'package:handa/pages/subpages/backup_restore.dart';
import 'package:provider/provider.dart';
import 'package:handa/theme/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  // StatefulWidget으로 변경
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isLoggedIn = false;
  String? userEmail;
  String? userName;
  String? userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // 로그인 상태 확인
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('userEmail');
    final savedName = prefs.getString('userName');
    final savedPhotoUrl = prefs.getString('userPhotoUrl');

    if (savedEmail != null && savedName != null) {
      setState(() {
        isLoggedIn = true;
        userEmail = savedEmail;
        userName = savedName;
        userPhotoUrl = savedPhotoUrl;
      });
    }
  }

  // 구글 로그인 처리
  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // 로그인 정보 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userEmail', userCredential.user?.email ?? '');
      await prefs.setString('userName', userCredential.user?.displayName ?? '');
      await prefs.setString(
          'userPhotoUrl', userCredential.user?.photoURL ?? '');

      setState(() {
        isLoggedIn = true;
        userEmail = userCredential.user?.email;
        userName = userCredential.user?.displayName;
        userPhotoUrl = userCredential.user?.photoURL;
      });
    } catch (e) {
      print('Google sign in error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  // 로그아웃 처리
  Future<void> _handleSignOut() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userEmail');
      await prefs.remove('userName');

      setState(() {
        isLoggedIn = false;
        userEmail = null;
        userName = null;
      });
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  Widget _buildAvatar() {
    if (userPhotoUrl != null && userPhotoUrl!.isNotEmpty) {
      return CircleAvatar(
        backgroundColor: Colors.grey[200],
        backgroundImage: NetworkImage(userPhotoUrl!),
      );
    } else {
      return CircleAvatar(
        backgroundColor: Colors.blue[700],
        child: Text(
          userName?.substring(0, 1).toUpperCase() ?? '?',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        children: [
          // 로그인/계정 섹션
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isLoggedIn
                ? Column(
                    children: [
                      ListTile(
                        leading: _buildAvatar(),
                        title: Text(userName ?? ''),
                        subtitle: Text(userEmail ?? ''),
                        trailing: TextButton(
                          onPressed: _handleSignOut,
                          child: Text('로그아웃'),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '마지막 동기화: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                // 동기화 기능 구현
                              },
                              icon: Icon(Icons.sync),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                fixedSize: Size(100, 20),
                                backgroundColor: Colors.grey[200],
                                elevation: 0,
                              ),
                              label: Text('동기화',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black87)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListTile(
                    title: const Text('로그인 시 동기화 서비스 이용이 가능합니다.',
                        style: TextStyle(fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _handleGoogleSignIn,
                  ),
          ),

          // 앱 설정 섹션
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '앱 설정',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          _buildSettingItem('다크 모드', ''),
          _buildSettingItem('테마', '기본'),
          _buildSettingItem('날짜 형식', 'MM-DD'),
          _buildSettingItem('주 시작일', '월요일'),
          _buildSettingItem('언어', '한국어'),

          // 백업/복원 섹션
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('백업/복원',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                )),
          ),
          _buildSettingItemWithArrow('클라우드에 백업'),
          _buildSettingItemWithArrow('장치에 백업/복원'),
          _buildSettingItemWithArrow('데이터 초기화'),

          // 지원 섹션
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('지원',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                )),
          ),
          _buildSettingItemWithArrow('도움말'),

          // 앱 버전
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '앱 버전 V1.0.0',
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, String value) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge,
      ),
      trailing: title == '다크 모드'
          ? Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Transform.scale(
                  scale: 0.8,
                  child: CupertinoSwitch(
                    activeTrackColor: Theme.of(context).primaryColor,
                    value: themeProvider.isDarkMode,
                    onChanged: (bool value) {
                      themeProvider.toggleTheme();
                    },
                  ),
                );
              },
            )
          : Text(
              value,
              style: Theme.of(context).textTheme.labelMedium,
            ),
      onTap: title == '다크 모드'
          ? () {
              final themeProvider = Provider.of<ThemeProvider>(
                context,
                listen: false,
              );
              themeProvider.toggleTheme();
            }
          : null,
    );
  }

  Widget _buildSettingItemWithArrow(String title) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        if (title == '도움말') {
          final Uri url = Uri.parse('https://handatask.com');
          try {
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('웹사이트를 열 수 없습니다.')),
                );
              }
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('오류가 발생했습니다: $e')),
              );
            }
          }
        } else if (title == '데이터 초기화') {
          // 경고 다이얼로그 표시
          bool shouldDelete = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0), // 둥근 모서리
                      side: BorderSide(
                        color: Colors.white, // 외곽선 색상
                        width: 1, // 외곽선 두께
                      ),
                    ),
                    title: Text('데이터 초기화',
                        style: Theme.of(context).textTheme.titleLarge),
                    content: Text(
                      '모든 할 일 데이터가 영구적으로 삭제됩니다.\n계속하시겠습니까?',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // 취소
                        },
                        child: Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true); // 확인
                        },
                        child: Text(
                          '초기화',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              ) ??
              false;

          // 사용자가 확인을 선택한 경우
          if (shouldDelete) {
            try {
              await DatabaseHelper.instance.deleteAllTodos();

              // Todos 화면 갱신을 위해 이전 화면으로 결과 전달
              Navigator.pop(context, true); // true를 반환하여 데이터가 변경되었음을 알림

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('모든 데이터가 초기화되었습니다.')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('데이터 초기화 중 오류가 발생했습니다.')),
              );
            }
          }
        } else if (title == '장치에 백업/복원') {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BackupRestorePage(),
            ),
          );

          // 데이터가 변경되었다면 이전 화면으로 결과 전달
          if (result == true) {
            Navigator.pop(context, true);
          }
        }
      },
    );
  }
}
