import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchType = 'Posts';
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _results = [];
  bool _isLoading = false;

  void _search() async {
    setState(() {
      _isLoading = true;
      _results.clear();
    });

    String query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      print('Query is empty');
      return;
    }

    try {
      QuerySnapshot snapshot;
      print('Searching for $_searchType with query: $query');

      if (_searchType == 'Posts') {
        snapshot = await FirebaseFirestore.instance
            .collection('posts')
            .where('title', isGreaterThanOrEqualTo: query)
            .where('title', isLessThanOrEqualTo: query + '\uf8ff')
            .get();
      } else {
        snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isGreaterThanOrEqualTo: query)
            .where('username', isLessThanOrEqualTo: query + '\uf8ff')
            .get();
      }

      print('Documents found: ${snapshot.docs.length}');

      setState(() {
        _results = snapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error during search: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: const Color(0xFF009ADB),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Search for:',
                  style: TextStyle(fontSize: 18.0),
                ),
                DropdownButton<String>(
                  value: _searchType,
                  items: ['Posts', 'Users'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _searchType = newValue!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter $_searchType...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                      ? const Center(
                          child: Text(
                            'No results found.',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final data =
                                _results[index].data() as Map<String, dynamic>;
                            print(
                                'Displaying result: ${data[_searchType == 'Posts' ? 'title' : 'username']}');
                            return ListTile(
                              title: Text(_searchType == 'Posts'
                                  ? data['title']
                                  : data['username']),
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
