import 'package:flutter/material.dart';
import 'package:paws_app/src/models/person.dart';

class PersonCard extends StatelessWidget {
  final Person person;

  const PersonCard({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate width based on constraints, with a max width of 600
        double cardWidth = constraints.maxWidth > 600 ? 600 : constraints.maxWidth;

        return Center(
          child: Container(
            width: cardWidth, // Use calculated width
            child: Card(
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
            ),
          ),
        );
      },
    );
  }
}
