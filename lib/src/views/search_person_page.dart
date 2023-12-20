import 'package:flutter/material.dart';
import 'package:paws_app/src/models/person.dart';
import 'package:paws_app/src/services/search_service.dart';
import 'package:paws_app/src/views/add_person_page.dart';
import 'package:paws_app/src/views/create_request_page.dart';
import 'package:paws_app/src/views/view_components/person_card.dart';

class SearchPersonPage extends StatefulWidget {
  const SearchPersonPage({super.key});

  @override
  State<SearchPersonPage> createState() => _SearchPersonPageState();
}

class _SearchPersonPageState extends State<SearchPersonPage> {
  List<Person> _searchResults = [];
  final SearchService _searchService = SearchService();

  void _performSearch(String query) async {
    var results = await _searchService.searchPerson(query);
    setState(() {
      _searchResults =
          results.map((doc) => Person.fromMap(doc.data(), doc.id)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search People"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search Person',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: _performSearch,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RequestCreationPage(
                              person: _searchResults[index]),
                        ),
                      );
                    },
                    child: PersonCard(person: _searchResults[index]),
                  );
                },
              ),
            ),
            ElevatedButton(
              child: const Text('Add New Person'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddPersonPage()),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
