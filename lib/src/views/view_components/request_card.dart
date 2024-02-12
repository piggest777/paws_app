import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/request.dart';
import '../request_detatil_page.dart';

class RequestCard extends StatelessWidget {
  final Request request;

  const RequestCard({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    Color cardBackgroundColor = _determineCardColor();
    bool hasOrganization = request.isProxy && request.organizationName != null;

    return Card(
      margin: const EdgeInsets.all(8.0),
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 4.0,
      child: InkWell(
        onTap: () => _navigateToRequestDetails(context, request),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRequestInfo(hasOrganization),
              const Divider(),
              _buildDateAndRegion(),
              _buildBoxStatusSummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestInfo(bool hasOrganization) {
    if (hasOrganization) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            request.organizationName!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            '${request.name} ${request.surname}',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      );
    } else {
      return Text(
        '${request.name} ${request.surname}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      );
    }
  }

  Widget _buildHeader(bool hasOrganization) {
    return Row(
      children: [
        Expanded(
          child: Text(
            hasOrganization ? request.organizationName! : '${request.name} ${request.surname}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (request.isUrgent)
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Icon(Icons.priority_high, color: Colors.red),
          ),
      ],
    );
  }

  Widget _buildDetails() {
    return Text(
      '${request.name} ${request.surname}',
      style: const TextStyle(fontSize: 14),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDateAndRegion() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _formatTimestamp(request.timestamp),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          '${request.region}, ${request.city}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

    Widget _buildBoxStatusSummary() {
    Map<String, int> boxStatusCounts = request.boxStatusCounts;

    return boxStatusCounts.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: boxStatusCounts.entries
                  .where((entry) => entry.value > 0)
                  .map((entry) => _buildStatusCount(entry.key, entry.value))
                  .toList(),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildStatusCount(String status, int count) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        children: <Widget>[
          _statusIcon(status),
          const SizedBox(width: 4),
          Text('$count'),
        ],
      ),
    );
  }
Widget _statusIcon(String status) {
  switch (status) {
    case 'created':
      return const Icon(Icons.create, color: Colors.lightBlue, size: 16);
    case 'packing':
      return const Icon(Icons.work, color: Colors.lightGreen, size: 16);
    case 'packed':
      return const Icon(Icons.inventory, color: Colors.amber, size: 16);
    case 'storage':
      return const Icon(Icons.store, color: Colors.deepPurple, size: 16);
    case 'sended':
      return const Icon(Icons.local_shipping, color: Colors.teal, size: 16);
    case 'recived':
      return const Icon(Icons.home_filled, color: Colors.brown, size: 16);
    case 'rapported':
      return const Icon(Icons.check_circle, color: Colors.pinkAccent, size: 16);
    default:
      return const Icon(Icons.help_outline, color: Colors.grey, size: 16);
  }
}

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Date not available';
    }
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  Color _determineCardColor() {
    if (request.isUrgent) {
      return Colors.red.shade50;
    } else if (request.isRepeat) {
      return Colors.grey.shade300;
    } else {
      return Colors.white;
    }
  }

  void _navigateToRequestDetails(BuildContext context, Request request) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RequestDetailsPage(request: request),
      ),
    );
  }
}
