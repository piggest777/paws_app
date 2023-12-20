import 'package:flutter/material.dart';
import 'package:paws_app/src/models/person.dart';

class PersonCard extends StatelessWidget {
  final Person person;

  const PersonCard({super.key, required this.person});

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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
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
