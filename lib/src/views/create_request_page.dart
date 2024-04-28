import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paws_app/src/views/request_detatil_page.dart';
import '../models/person.dart';
import '../models/request.dart';

class RequestCreationPage extends StatefulWidget {
  final Person person;

  const RequestCreationPage({super.key, required this.person});

  @override
  _RequestCreationPageState createState() => _RequestCreationPageState();
}

class _RequestCreationPageState extends State<RequestCreationPage> {
  bool isRepeat = false;
  bool isProxy = false;
  bool isUrgent = false;
  bool isMedical = false;
  String organizationName = '';
  String comments = '';
  String? organizationNameError;

  Future<void> saveRequestToFirebase() async {

  setState(() {
    organizationNameError = null;
  });
    // Create a Request object
    Request newRequest = Request(
      id: '',
      personId: widget.person.id,
      name: widget.person.name,
      surname: widget.person.surname,
      region: widget.person.region,
      city: widget.person.city,
      isUrgent: isUrgent,
      isRepeat: isRepeat,
      isProxy: isProxy,
      isMedical: isMedical,
      organizationName: isProxy ? organizationName : null,
      comments: comments,
      timestamp: null,
    );

    if (isProxy) {
  if (organizationName.isNotEmpty) {
    _saveRequest(newRequest);
  } else {
    setState(() {
      organizationNameError = 'Please enter the organization name';
    });
  }
} else {
  _saveRequest(newRequest);
}

}

void _saveRequest(Request newRequest) async {
  try {

    // Initialize boxCounts with all statuses set to 0
    Map<String, int> initialBoxCounts = {
      'created': 0,
      'packing': 0,
      'packed': 0,
      'storage': 0,
      'sended': 0,
      'recived': 0,
      'rapported': 0,
    };

    newRequest = Request(
      id: newRequest.id, // keep existing ID
      personId: newRequest.personId,
      name: newRequest.name,
      surname: newRequest.surname,
      region: newRequest.region,
      city: newRequest.city,
      isUrgent: newRequest.isUrgent,
      isRepeat: newRequest.isRepeat,
      isProxy: newRequest.isProxy,
      isMedical: newRequest.isMedical,
      organizationName: newRequest.organizationName,
      comments: newRequest.comments,
      timestamp: newRequest.timestamp,
      boxStatusCounts: initialBoxCounts, // set initial boxCounts
    );

    DocumentReference docRef = await FirebaseFirestore.instance.collection('requests').add(newRequest.toMap());
    
        String requestId = docRef.id;

    // Create a complete Request object with the ID
    Request completeRequest = Request(
      id: requestId, // Set the retrieved ID
      personId: newRequest.personId,
      name: newRequest.name,
      surname: newRequest.surname,
      region: newRequest.region,
      city: newRequest.city,
      isUrgent: newRequest.isUrgent,
      isRepeat: newRequest.isRepeat,
      isProxy: newRequest.isProxy,
      isMedical: newRequest.isMedical,
      organizationName: newRequest.organizationName,
      comments: newRequest.comments,
      boxStatusCounts: initialBoxCounts,
    );
      Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RequestDetailsPage(request: completeRequest),
      ),
    );

  } catch (e) {
    // Handle errors
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Request'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPersonInfoSection(),
            const SizedBox(height: 10),
            _buildRequestDetailsSection(),
            const SizedBox(height: 10),
            _buildCommentsSection(),
            const SizedBox(height: 10),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonInfoSection() {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Icon(Icons.person, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  '${widget.person.name} ${widget.person.surname}',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on,
                '${widget.person.region}, ${widget.person.city}'),
            _buildInfoRow(Icons.local_post_office,
                'Nova Post Branch: ${widget.person.novaPostBranch}'),
            _buildInfoRow(Icons.phone, 'Phone: ${widget.person.phone}'),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestDetailsSection() {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Request Details',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 5),
            _buildToggleSwitch(
              title: 'Repeated Request',
              value: isRepeat,
              onChanged: (value) => setState(() => isRepeat = value),
            ),
            _buildToggleSwitch(
              title: 'Urgent Request',
              value: isUrgent,
              onChanged: (value) => setState(() => isUrgent = value),
            ),
            _buildToggleSwitch(
              title: 'Medical Request',
              value: isMedical,
              onChanged: (value) => setState(() => isMedical = value)
            ),
            _buildToggleSwitch(
              title: 'Acting as Proxy',
              value: isProxy,
              onChanged: (value) {
                setState(() => isProxy = value);
              },
            ),
            if (isProxy)
              _buildTextField(
                labelText: 'Organization Name',
                onChanged: (value) => organizationName = value,
                errorText: organizationNameError,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Comments',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              maxLines: 3, // Multi-line text field for longer comments
              decoration: const InputDecoration(
                labelText: 'Add your comments here',
                hintText: 'Enter any additional information or comments',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => comments = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          saveRequestToFirebase();
        },
        child: const Text('Submit New Request'),
      ),
    );
  }


//Elements widgets
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: <Widget>[
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 16.0)),
      ],
    );
  }

  Widget _buildToggleSwitch(
      {required String title,
      required bool value,
      required Function(bool) onChanged}) {
    return _buildCustomToggleSwitch(title: title, value: value, onChanged: onChanged);
  }

  Widget _buildCustomToggleSwitch({required String title, required bool value, required Function(bool) onChanged}) {
  return Row(
    children: <Widget>[
      Expanded(child: Text(title)),
      Switch(
        value: value,
        onChanged: onChanged,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduces tap target size
      ),
    ],
  );
}

  Widget _buildTextField(
      {required String labelText, required Function(String) onChanged, String? errorText}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        errorText: errorText,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}
