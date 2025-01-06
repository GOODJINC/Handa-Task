import 'package:flutter/material.dart';
import 'package:handa/database/database_helper.dart';
import 'package:handa/database/shared_preferences_helper.dart';

// 초성 분리 함수 추가
String extractInitials(String text) {
  const choSung = [
    'ㄱ',
    'ㄲ',
    'ㄴ',
    'ㄷ',
    'ㄸ',
    'ㄹ',
    'ㅁ',
    'ㅂ',
    'ㅃ',
    'ㅅ',
    'ㅆ',
    'ㅇ',
    'ㅈ',
    'ㅉ',
    'ㅊ',
    'ㅋ',
    'ㅌ',
    'ㅍ',
    'ㅎ'
  ];
  StringBuffer initials = StringBuffer();

  for (int i = 0; i < text.length; i++) {
    int charCode = text.codeUnitAt(i);
    if (charCode >= 0xAC00 && charCode <= 0xD7A3) {
      int index = ((charCode - 0xAC00) ~/ 28) ~/ 21;
      initials.write(choSung[index]);
    } else {
      initials.write(text[i]); // 한글이 아니면 그대로 추가
    }
  }
  return initials.toString();
}

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => SearchPageState();
}

class SearchPageState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // 검색창 포커스 노드
  List<Map<String, dynamic>> _searchResults = [];
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusSearchBar();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final recentSearches = await SharedPreferencesHelper.getRecentSearches();
    setState(() {
      _recentSearches = recentSearches;
    });
  }

  Future<void> _saveRecentSearch(String query) async {
    await SharedPreferencesHelper.saveRecentSearch(query);
    await _loadRecentSearches();
  }

  Future<void> _deleteRecentSearch(String query) async {
    await SharedPreferencesHelper.deleteRecentSearch(query);
    await _loadRecentSearches();
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    // 초성 검색 지원 함수 호출
    final todos = await DatabaseHelper.instance.searchTodosWithInitials(query);

    setState(() {
      _searchResults = todos
          .map((todo) => {
                'type': 'TODO',
                'data': todo,
              })
          .toList();
    });
  }

  void _showDetails(Map<String, dynamic> result) {
    final data = result['data'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('TODO 세부 정보'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('제목: ${data.title}'),
                Text('내용: ${data.description}'),
                Row(
                  children: [
                    const Text('완료 상태: '),
                    Icon(
                      data.isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: data.isCompleted ? Colors.green : Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
    });
  }

  void focusSearchBar() {
    FocusScope.of(context).requestFocus(_searchFocusNode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('검색'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _search,
                onSubmitted: (query) async {
                  if (query.isNotEmpty) {
                    await _saveRecentSearch(query);
                  }
                },
                decoration: InputDecoration(
                  labelText: '검색',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            if (_recentSearches.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '최근 검색어',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _recentSearches.length,
                        itemBuilder: (context, index) {
                          final query = _recentSearches[index];
                          return ListTile(
                            title: Text(query),
                            trailing: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _deleteRecentSearch(query);
                              },
                            ),
                            onTap: () {
                              _searchController.text = query;
                              _search(query);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              // flex: 4,
              child: _searchResults.isEmpty
                  ? const Center(
                      child: Text('검색 결과가 없습니다.'),
                    )
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              'TODO',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(result['data'].title),
                          subtitle: Text(
                            result['data'].description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _showDetails(result),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
