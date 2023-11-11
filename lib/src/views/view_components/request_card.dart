import 'package:flutter/material.dart';
import '../../models/request.dart';

class RequestCard extends StatelessWidget {
  final Request request;

  const RequestCard({
    Key? key,
    required this.request,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color cardBackgroundColor = _determineCardColor();
    bool hasOrganization = request.isProxy && request.organizationName != null;

    return Card(
      margin: EdgeInsets.all(8.0),
      color: cardBackgroundColor,
      child: InkWell(
        onTap: () => _navigateToRequestDetails(context, request),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Row(
            children: [
              _buildStatusIcon(),
              SizedBox(width: 10),
              Expanded(
                child: _buildRequestInfo(hasOrganization),
              ),
              Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    return Icon(Icons.pending_actions, size: 24); // Placeholder for status tracker
  }

  Widget _buildRequestInfo(bool hasOrganization) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (hasOrganization) ...[
          Text(
            request.organizationName!,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 4),
        ],
        Text(
          '${request.name} ${request.surname}',
          style: TextStyle(
            fontWeight: hasOrganization ? FontWeight.normal : FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text('${request.region}, ${request.city}'),
      ],
    );
  }

  Color _determineCardColor() {
    if (request.isUrgent) {
      return Colors.red.shade100;
    } else if (request.isRepeat) {
      return Colors.grey.shade300;
    } else {
      return Colors.white;
    }
  }

  void _navigateToRequestDetails(BuildContext context, Request request) {
    // Navigation logic to request details page, passing the Request object
  }
}
