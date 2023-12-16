import 'package:flutter/material.dart';
import 'package:paws_app/src/models/request.dart';
import 'package:paws_app/src/views/create_box_page.dart';
import 'package:paws_app/src/views/request_view.dart';
import 'package:paws_app/src/views/view_components/box_list.dart';
import 'package:paws_app/src/views/view_components/person_info_card.dart';

class RequestDetailsPage extends StatefulWidget {
  final Request request;

  RequestDetailsPage({Key? key, required this.request}) : super(key: key);

  @override
  State<RequestDetailsPage> createState() => _RequestDetailsPageState();
}

class _RequestDetailsPageState extends State<RequestDetailsPage> {

  void _handleBackNavigation(BuildContext context) {
      Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      pageBuilder: (context, animation1, animation2) => RequestsPage(),
   transitionsBuilder: (context, animation, secondaryAnimation, child) {
    var begin = Offset(-1.0, 0.0); // Starts from right
    var end = Offset.zero;
    var curve = Curves.ease;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);

    return SlideTransition(position: offsetAnimation, child: child);
  },
    ),
  ); 
  }

  void _navigateToCreateBoxPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CreateBoxPage(requestId: widget.request.id)),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _handleBackNavigation(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            PersonInfoCard(userId: widget.request.personId),
            if (widget.request.isProxy && widget.request.organizationName != null)
              _buildOrganizationInfoCard(),
              if (widget.request.isUrgent == true || widget.request.isRepeat == true || widget.request.comments.isNotEmpty)
                _buildRequestSummary(),
            BoxListWidget(requestId: widget.request.id, request: widget.request),
          ],
        ),
      ),
        floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateBoxPage(context),
        child: Icon(Icons.add),
      ),
    );
  }


Widget _buildOrganizationInfoCard() {
  return Card(
    margin: EdgeInsets.all(8.0),
    child: Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded( // This ensures the content takes up full width
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Organization',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.request.organizationName!,
                  style: TextStyle(fontSize: 16),
                ),
                // You can add more information about the organization here if available
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildRequestSummary() {
  List<Widget> summaryItems = [];

  // Add a Row with Expanded to ensure consistent width
  summaryItems.add(
    Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Urgency and Secondary Status
              if (widget.request.isUrgent || widget.request.isRepeat) 
                Wrap(
                  children: [
                    if (widget.request.isUrgent)
                      _buildStatusTag("Urgent", Colors.redAccent),
                    if (widget.request.isRepeat)
                      _buildStatusTag("Secondary", Colors.orangeAccent),
                  ],
                ),
              // Comments
              if (widget.request.comments.isNotEmpty) 
                ..._buildCommentsSection(),
            ],
          ),
        ),
      ],
    ),
  );

  return Card(
    margin: EdgeInsets.all(8.0),
    child: Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: summaryItems,
      ),
    ),
  );
}

List<Widget> _buildCommentsSection() {
  return [
    SizedBox(height: 10),
    Text(
      "Comments:",
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    SizedBox(height: 4),
    Text(
      widget.request.comments,
      style: TextStyle(fontSize: 14),
    ),
  ];
}

  Widget _buildStatusTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
