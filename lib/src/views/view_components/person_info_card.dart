import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paws_app/src/models/person.dart';

class PersonInfoCard extends StatefulWidget {
  final String userId;

  PersonInfoCard({Key? key, required this.userId}) : super(key: key);

  @override
  _PersonInfoCardState createState() => _PersonInfoCardState();
}

class _PersonInfoCardState extends State<PersonInfoCard> {
  Person? person;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPersonData();
  }

  Future<void> _fetchPersonData() async {
    try {
      DocumentSnapshot personSnapshot = await FirebaseFirestore.instance
          .collection('persons')
          .doc(widget.userId)
          .get();
      if (personSnapshot.exists) {
        setState(() {
          person = Person.fromMap(
              personSnapshot.data() as Map<String, dynamic>, widget.userId);
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle errors here
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: isLoading
          ? Padding(
              padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: person != null
                    ? _buildPersonInfo()
                    : [Text('Person data not found.')],
              ),
            ),
    );
  }

  List<Widget> _buildPersonInfo() {
    return [
      Text('Personal Information',
          style: Theme.of(context).textTheme.titleLarge),
      SizedBox(height: 10),
      _infoRow(Icons.person, '${person!.name} ${person!.surname}'),
      _infoRow(Icons.location_on, '${person!.region}, ${person!.city}'),
      _infoRow(Icons.local_post_office,
          'Nova Post Branch: ${person!.novaPostBranch}'),
      _infoRow(Icons.phone, 'Phone: ${person!.phone}'),
    ];
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
