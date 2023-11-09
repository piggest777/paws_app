import 'package:flutter/material.dart';

class RequestCard extends StatelessWidget {
  final Map<String, dynamic> requestData;

  const RequestCard({
    Key? key,
    required this.requestData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Assuming 'title' is a field in the requestData map
    String title = requestData['title'] ?? 'Untitled';
    // You can add more fields as necessary

    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(title),
        // Here you might want to add subtitle, leading, trailing widgets, and onTap action
        // Example:
        // subtitle: Text(requestData['description'] ?? ''),
        // leading: Icon(Icons.description),
        // onTap: () => _navigateToRequestDetails(context, requestData),
      ),
    );
  }
}