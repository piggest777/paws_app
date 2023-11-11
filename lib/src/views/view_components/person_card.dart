import 'package:flutter/material.dart';
import 'package:paws_app/src/models/person.dart';

class PersonCard extends StatelessWidget {
  final Person person;

  const PersonCard({Key? key, required this.person}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${person.name} ${person.surname}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text('Region: ${person.region}'),
            Text('City: ${person.city}'),
            Text('Nova Post Branch: ${person.novaPostBranch}'),
            Text('Phone: ${person.phone}'),
          ],
        ),
      ),
    );
  }
}
