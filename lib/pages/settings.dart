import 'package:flutter/material.dart';
import 'package:handa/pages/subpages/account_page.dart';

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
              '계정',
              Icons.account_circle_outlined,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountPage()),
                );
              },
            ),
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
