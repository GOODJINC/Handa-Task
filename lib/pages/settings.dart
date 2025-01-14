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
import 'package:handa/providers/date_format_provider.dart';
import 'package:handa/providers/week_start_provider.dart';
import 'package:handa/providers/locale_provider.dart';
import 'package:handa/l10n/app_localizations.dart';

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
        title: Text(AppLocalizations.of(context).translate('settings')),
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
                                '${AppLocalizations.of(context).translate('lastSync')}${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
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
                              label: Text(
                                  AppLocalizations.of(context)
                                      .translate('sync'),
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black87)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListTile(
                    title: Text(
                        AppLocalizations.of(context).translate('loginForSync'),
                        style: TextStyle(fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _handleGoogleSignIn,
                  ),
          ),

          // 앱 설정 섹션
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              AppLocalizations.of(context).translate('appSettings'),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          _buildSettingItem(
              AppLocalizations.of(context).translate('darkMode'), ''),
          // _buildSettingItem('테마', '기본'),
          _buildSettingItem(
              AppLocalizations.of(context).translate('dateFormat'), 'MM-DD'),
          _buildSettingItem(AppLocalizations.of(context).translate('weekStart'),
              AppLocalizations.of(context).translate('monday')),
          _buildSettingItem(AppLocalizations.of(context).translate('language'),
              AppLocalizations.of(context).translate('korean')),

          // 백업/복원 섹션
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(AppLocalizations.of(context).translate('backupRestore'),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                )),
          ),
          _buildSettingItemWithArrow(
              AppLocalizations.of(context).translate('cloudBackup')),
          _buildSettingItemWithArrow(
              AppLocalizations.of(context).translate('deviceBackup')),
          _buildSettingItemWithArrow(
              AppLocalizations.of(context).translate('dataReset')),

          // 지원 섹션
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(AppLocalizations.of(context).translate('support'),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                )),
          ),
          _buildSettingItemWithArrow(
              AppLocalizations.of(context).translate('help')),

          // 앱 버전
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${AppLocalizations.of(context).translate('appVersion')} V1.0.0',
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
        AppLocalizations.of(context)
            .translate(title.toLowerCase().replaceAll(' ', '')),
        style: Theme.of(context).textTheme.labelLarge,
      ),
      trailing: title == AppLocalizations.of(context).translate('darkMode')
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
          : title == AppLocalizations.of(context).translate('dateFormat')
              ? Consumer<DateFormatProvider>(
                  builder: (context, dateFormatProvider, child) {
                    return Text(
                      dateFormatProvider.dateFormat,
                      style: Theme.of(context).textTheme.labelMedium,
                    );
                  },
                )
              : title == AppLocalizations.of(context).translate('weekStart')
                  ? Consumer<WeekStartProvider>(
                      builder: (context, weekStartProvider, child) {
                        return Text(
                          AppLocalizations.of(context)
                              .translate(weekStartProvider.startDayString),
                          style: Theme.of(context).textTheme.labelMedium,
                        );
                      },
                    )
                  : title == AppLocalizations.of(context).translate('language')
                      ? Consumer<LocaleProvider>(
                          builder: (context, localeProvider, child) {
                            return Text(
                              localeProvider.currentLanguageName,
                              style: Theme.of(context).textTheme.labelMedium,
                            );
                          },
                        )
                      : Text(
                          value,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
      onTap: title == AppLocalizations.of(context).translate('dateFormat')
          ? () => _showDateFormatPicker()
          : title == AppLocalizations.of(context).translate('darkMode')
              ? () {
                  final themeProvider =
                      Provider.of<ThemeProvider>(context, listen: false);
                  themeProvider.toggleTheme();
                }
              : title == AppLocalizations.of(context).translate('weekStart')
                  ? () => _showWeekStartPicker()
                  : title == AppLocalizations.of(context).translate('language')
                      ? () => _showLanguagePicker()
                      : null,
    );
  }

  void _showDateFormatPicker() {
    final dateFormatProvider =
        Provider.of<DateFormatProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('selectDateFormat')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('MM월 DD일'),
              onTap: () {
                dateFormatProvider.setDateFormat('MM월 DD일');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('MM-DD'),
              onTap: () {
                dateFormatProvider.setDateFormat('MM-DD');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('MM/DD'),
              onTap: () {
                dateFormatProvider.setDateFormat('MM/DD');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWeekStartPicker() {
    final weekStartProvider =
        Provider.of<WeekStartProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('selectWeekStart')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(AppLocalizations.of(context).translate('monday')),
              onTap: () {
                weekStartProvider.setStartDay(DateTime.monday);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context).translate('sunday')),
              onTap: () {
                weekStartProvider.setStartDay(DateTime.sunday);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker() {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('selectLanguage')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(AppLocalizations.of(context).translate('korean')),
              onTap: () {
                localeProvider.setLocale('ko');
                Navigator.pop(context);
                // 설정 화면 갱신
                setState(() {});
                // 또는 전체 화면을 다시 빌드하기 위해 Navigator.pushReplacement 사용
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context).translate('english')),
              onTap: () {
                localeProvider.setLocale('en');
                Navigator.pop(context);
                setState(() {});
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
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
        if (title == AppLocalizations.of(context).translate('help')) {
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
        } else if (title ==
            AppLocalizations.of(context).translate('dataReset')) {
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
        } else if (title ==
            AppLocalizations.of(context).translate('deviceBackup')) {
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
