import 'package:flutter/material.dart';
import 'package:paws_app/main.dart';
import 'package:paws_app/src/models/request.dart';
import 'package:paws_app/src/views/boxes/create_box_page.dart';
import 'package:paws_app/src/views/view_components/box_list.dart';
import 'package:paws_app/src/views/view_components/person_info_card.dart';

class RequestDetailsPage extends StatefulWidget {
  final Request request;

  const RequestDetailsPage({super.key, required this.request});

  @override
  State<RequestDetailsPage> createState() => _RequestDetailsPageState();
}

class _RequestDetailsPageState extends State<RequestDetailsPage> {

  void _handleBackNavigation(BuildContext context) {
      Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      pageBuilder: (context, animation1, animation2) => const HomePage(initialTabIndex: 0,),
   transitionsBuilder: (context, animation, secondaryAnimation, child) {
    var begin = const Offset(-1.0, 0.0); // Starts from right
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
      MaterialPageRoute(builder: (context) => CreateBoxPage(requestId: widget.request.id, requesterName: '${widget.request.name} ${widget.request.surname}')),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
        child: const Icon(Icons.add),
      ),
    );
  }


Widget _buildOrganizationInfoCard() {
  return Card(
    margin: const EdgeInsets.all(8.0),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded( // This ensures the content takes up full width
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Organization',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.request.organizationName!,
                  style: const TextStyle(fontSize: 16),
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
              // Urgency and repeated Status
              if (widget.request.isUrgent || widget.request.isRepeat) 
                Wrap(
                  children: [
                    if (widget.request.isUrgent)
                      _buildStatusTag("Urgent", Colors.redAccent),
                    if (widget.request.isRepeat)
                      _buildStatusTag("Repeated", Colors.orangeAccent),
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
    margin: const EdgeInsets.all(8.0),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: summaryItems,
      ),
    ),
  );
}

List<Widget> _buildCommentsSection() {
  return [
    const SizedBox(height: 10),
    const Text(
      "Comments:",
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 4),
    Text(
      widget.request.comments,
      style: const TextStyle(fontSize: 14),
    ),
  ];
}

  Widget _buildStatusTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
