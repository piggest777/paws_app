import 'package:flutter/material.dart';
import 'package:paws_app/src/models/person.dart'; // Update the path based on your project structure
import 'package:paws_app/src/services/search_service.dart';
import 'package:paws_app/src/views/add_person_page.dart'; // Adjust according to your file structure

class RecipientSelectionPage extends StatefulWidget {
  @override
  _RecipientSelectionPageState createState() => _RecipientSelectionPageState();
}

class _RecipientSelectionPageState extends State<RecipientSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  late SearchService _searchService;
  List<Person> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false; // Added to track if a search has been made

  @override
  void initState() {
    super.initState();
    _searchService = SearchService(); // Initialize your search service
  }

  void _search(String query) async {
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    final results = await _searchService.searchPerson(query);
    final persons =
        results.map((doc) => Person.fromMap(doc.data(), doc.id)).toList();

    setState(() {
      _searchResults = persons;
      _isSearching = false;
    });
  }

Widget _buildInitialSearchScreen() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // To make the content more centered
        children: [
          Text(
            'Start typing to search for a recipient...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18, // Consistent font size for better readability
              color: Colors.grey[600], // Soft color for a friendly UI
            ),
          ),
          SizedBox(height: 10), // Space between text and prompt
          Text(
            'Please enter at least 2 characters to begin search.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16, // Slightly smaller font size for the prompt
              color: Colors.blue[600], // A friendly color for guidance
            ),
          ),
        ],
      ),
    ),
  );
}


Widget _buildNoResultsFound() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off, // An icon indicating no results were found
          size: 60, // A larger icon for better visibility
          color: Colors.grey[400], // A soft color that is gentle on the eyes
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'No results found.',
            style: TextStyle(
              fontSize: 18, // Larger text for emphasis
              color: Colors.black54, // A neutral color for clarity
            ),
          ),
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.add), // Adding an add icon to the button
          label: Text('Create New Person'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor, // Text color
            elevation: 2, // Adds a slight elevation for depth
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Padding for aesthetics
          ),
          onPressed: () {
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (context) => AddPersonPage(),
              ),
            )
                .then((value) {
              if (value != null && value is String) {
                String surname = value;
                _searchController.text = surname;
                _search(surname);
              }
            });
          },
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Recipient'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _search('');
                        },
                      )
                    : null,
              ),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: _isSearching
                ? Center(child: CircularProgressIndicator())
                : _searchResults.isNotEmpty
                    ? ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final person = _searchResults[index];
                          return ListTile(
                            title: Text('${person.name} ${person.surname}'),
                            subtitle: Text('${person.city}, ${person.region}'),
                            onTap: () {
                              Navigator.pop(context, person);
                            },
                          );
                        },
                      )
                    : _hasSearched
                        ? _buildNoResultsFound()
                        : _buildInitialSearchScreen(),
          ),
        ],
      ),
    );
  }
}
