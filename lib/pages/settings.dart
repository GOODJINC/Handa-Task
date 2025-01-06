import 'package:flutter/material.dart';
import 'package:handa/pages/subpages/account_page.dart';
import 'package:handa/database/firebase_sync_helper.dart'; // 추가된 파일 import

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          _buildSection([
            _buildListTile(
              'Firebase 동기화',
              Icons.cloud_sync,
              () async {
                // 1. Firebase로 로컬 데이터 업로드
                await FirebaseSyncHelper.syncLocalToFirestore();

                // 2. Firebase에서 변경된 데이터 가져오기
                await FirebaseSyncHelper.syncFirestoreToLocal();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('동기화 완료!')),
                );
              },
            ),
          ]),
          _buildSection([
            _buildListTile('계정', Icons.account_circle_outlined, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountPage()),
              );
            }),
          ]),
          _buildSection([
            _buildListTile('설정관리', Icons.settings),
            _buildListTile('잠금설정', Icons.lock_outline),
            _buildListTile('백업/복원', Icons.backup_outlined),
          ]),
          _buildSection([
            _buildListTile('도움말', Icons.help_outline),
            _buildListTile('앱정보', Icons.info_outline),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(List<Widget> tiles) {
    return Column(
      children: [
        ...tiles,
        const Divider(), // 섹션 구분선
      ],
    );
  }

  Widget _buildListTile(String title, IconData icon, [VoidCallback? action]) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(title),
      onTap: action,
    );
  }
}
