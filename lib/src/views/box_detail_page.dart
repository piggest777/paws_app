import 'package:flutter/material.dart';
import 'package:paws_app/src/models/box.dart';
import 'package:paws_app/src/models/person.dart';
import 'package:paws_app/src/models/request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paws_app/src/services/pdf_manager.dart';
import 'package:paws_app/src/views/request_detatil_page.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

class BoxDetailsPage extends StatefulWidget {
  final Box? box;
  final String? boxId; // ID from QR code
  final Request? request;

  const BoxDetailsPage({super.key, this.box, this.boxId, this.request});

  @override
  _BoxDetailsPageState createState() => _BoxDetailsPageState();
}

class _BoxDetailsPageState extends State<BoxDetailsPage> {
  Request? request;
  Box? box;
  String? boxId;
  bool isLoading = false;
  BoxSize? selectedSize;
  BoxType? selectedType;
  BoxStatus? selectedStatus;
  BoxLocation? selectedLocation;
  final TextEditingController _commentController = TextEditingController();
  final _screenshotController = ScreenshotController();
  bool isEditMode = false;
  String? comment;
  String? requestName;
  Person? person;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.box != null && widget.request != null) {
      // Both Box and Request objects are provided
      box = widget.box;
      request = widget.request;
      selectedSize = widget.box?.size;
      selectedType = widget.box?.type;
      selectedStatus = widget.box?.status ?? BoxStatus.created;
      selectedLocation = widget.box?.location ?? BoxLocation.office;
      comment = widget.box?.comment ?? '';
      requestName = widget.request?.name;
      _commentController.text = widget.box?.comment ?? '';
      fetchPersonDetails(request?.personId);
    } else if (widget.boxId != null) {
      boxId = widget.boxId;
      // Only Box ID is provided, fetch Box and then Request
      fetchBoxAndRequestDetails(boxId!);
    }
  }

  void fetchBoxAndRequestDetails(String boxId) async {
    setState(() => isLoading = true);
    try {
      var boxSnapshot =
          await FirebaseFirestore.instance.collection('boxes').doc(boxId).get();
      if (boxSnapshot.exists) {
        var fetchedBox = Box.fromMap(boxSnapshot.data()!, boxId);
        var requestSnapshot = await FirebaseFirestore.instance
            .collection('requests')
            .doc(fetchedBox.requestId)
            .get();

        if (requestSnapshot.exists) {
          setState(() {
            box = fetchedBox;
            request =
                Request.fromMap(requestSnapshot.data()!, fetchedBox.requestId);
            selectedSize = fetchedBox.size;
            selectedType = fetchedBox.type;
            selectedStatus = fetchedBox.status;
            selectedLocation = fetchedBox.location;
            comment = fetchedBox.comment;
            _commentController.text = fetchedBox.comment;
            requestName = requestSnapshot.data()!['name'];
            fetchPersonDetails(request?.personId);
            isLoading = false;
          });
        } else {
          print('Request not found');
          setState(() => isLoading = false);
        }
      } else {
        print('Box not found');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching box and request details: $e');
      setState(() => isLoading = false);
    }
  }

  void fetchPersonDetails(String? personId) async {
    try {
      var personSnapshot = await FirebaseFirestore.instance
          .collection('persons')
          .doc(personId)
          .get();

      if (personSnapshot.exists) {
        setState(() {
          person = Person.fromMap(personSnapshot.data()!, personSnapshot.id);
        });
      } else {
        print(
            'Person not found'); // Handle the case where the person does not exist
      }
    } catch (e) {
      print('Error fetching person: $e'); // Handle any errors here
    }
  }

  void _navigateToRequestDetails(BuildContext context) {
    if (request != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RequestDetailsPage(request: request!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request details not available')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Box Details')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (box != null || boxId != null)
              Screenshot(
                  controller: _screenshotController,
                  child: _buildQRCode(box?.id ?? boxId!)),
            const SizedBox(height: 10),
            if (requestName != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Text(
                        '${request?.name ?? ''} ${request?.surname ?? ''}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Box #${box?.boxID}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 5),
            _buildBoxDetailsCard(),
            const SizedBox(height: 5),
            _buildStatusCard(),
            const SizedBox(height: 5),
            _buildCommentSection(),
            const SizedBox(height: 5),
            if (box != null &&
                request != null &&
                person != null) // Check if both objects are created
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _createAndSharePdf,
                      child: const Text('Create and Share PDF'),
                    ),
                    if (boxId != null)
                      ElevatedButton(
                        onPressed: () => _navigateToRequestDetails(context),
                        child: const Text('View Request Details'),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _createAndSharePdf() async {
    if (widget.box?.id != null || boxId != null) {
      PDFManager pdfManager =
          PDFManager(box: box, request: request, person: person);
      pdfManager.createAndSharePdf();
    } else {
      print("can't create pdf without box id");
    }
  }

  Widget _buildQRCode(String data) {
    return Center(
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: 200.0,
        gapless: false,
      ),
    );
  }

Widget _buildBoxDetailsCard() {
  return Card(
    margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
    child: Column(
      children: [
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildSizePicker(),
              VerticalDivider(width: 1, thickness: 1),
              _buildTypePicker(),
            ],
          ),
        ),
          _buildLocationPicker(),
      ],
    ),
  );
}

  Widget _buildSizePicker() {
  return Expanded(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Size', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<BoxSize>(
            value: selectedSize,
            onChanged: (BoxSize? newValue) {
              setState(() {
                selectedSize = newValue;
                _updateBoxSizeInFirebase(selectedSize);
              });
            },
            items: BoxSize.values.map<DropdownMenuItem<BoxSize>>((BoxSize value) {
              return DropdownMenuItem<BoxSize>(
                value: value,
                child: Text(value.toString().split('.').last),
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );
}


Widget _buildTypePicker() {
  return Expanded(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<BoxType>(
            value: selectedType,
            onChanged: (BoxType? newValue) {
              setState(() {
                selectedType = newValue;
                _updateBoxTypeInFirebase(selectedType);
              });
            },
            items: BoxType.values.map<DropdownMenuItem<BoxType>>((BoxType value) {
              return DropdownMenuItem<BoxType>(
                value: value,
                child: Text(value.toString().split('.').last),
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );
}

Widget _buildLocationPicker() {
  return Visibility(
    visible: selectedStatus != BoxStatus.sended &&
             selectedStatus != BoxStatus.recived &&
             selectedStatus != BoxStatus.rapported,
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              'Location: ',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(width: 8), // Spacer between text and dropdown
          Expanded(
            flex: 3,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<BoxLocation>(
                value: selectedLocation,
                isExpanded: true,
                onChanged: (BoxLocation? newValue) {
                  setState(() {
                    selectedLocation = newValue;
                    _updateBoxLocationInFirebase(selectedLocation!);
                  });
                },
                items: BoxLocation.values.map<DropdownMenuItem<BoxLocation>>((BoxLocation value) {
                  return DropdownMenuItem<BoxLocation>(
                    value: value,
                    child: Text(value.toString().split('.').last),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  void _updateBoxSizeInFirebase(BoxSize? newSize) {
    if (box?.id != null && newSize != null) {
      String typeAsString = newSize.toString().split('.').last;
      FirebaseFirestore.instance
          .collection('boxes')
          .doc(box!.id)
          .update({'size': typeAsString})
          .then((_) => _showSnackbar('Size updated successfully', Colors.green))
          .catchError((error) =>
              _showSnackbar('Error updating size: $error', Colors.red));
    } else {
      _showSnackbar('Error: Box ID is not available', Colors.red);
    }
  }

  void _updateBoxTypeInFirebase(BoxType? newType) {
    if (box?.id != null && newType != null) {
      String typeAsString = newType.toString().split('.').last;
      FirebaseFirestore.instance
          .collection('boxes')
          .doc(box!.id)
          .update({'type': typeAsString})
          .then((_) => _showSnackbar('Type updated successfully', Colors.green))
          .catchError((error) =>
              _showSnackbar('Error updating type: $error', Colors.red));
    } else {
      _showSnackbar('Error: Box ID is not available', Colors.red);
    }
  }

  void _showSnackbar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed:
                  selectedStatus != null ? () => _changeStatus(-1) : null,
            ),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<BoxStatus>(
                  value: selectedStatus,
                  isExpanded: true,
                  onChanged: selectedStatus != null
                      ? (BoxStatus? newValue) {
                          setState(() {
                            selectedStatus = newValue;
                          });
                          _updateStatusInFirebase(newValue!);
                        }
                      : null,
                  items: BoxStatus.values
                      .map<DropdownMenuItem<BoxStatus>>((BoxStatus value) {
                    return DropdownMenuItem<BoxStatus>(
                      value: value,
                      child:
                          Center(child: Text(value.toString().split('.').last)),
                    );
                  }).toList(),
                  icon: Container(), // To remove the default dropdown icon
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: selectedStatus != null ? () => _changeStatus(1) : null,
            ),
          ],
        ),
      ),
    );
  }

  void _changeStatus(int direction) {
    int currentIndex = BoxStatus.values.indexOf(selectedStatus!);
    int newIndex = (currentIndex + direction) % BoxStatus.values.length;
    if (newIndex < 0) newIndex = BoxStatus.values.length - 1;
    setState(() {
      selectedStatus = BoxStatus.values[newIndex];
    });
    _updateStatusInFirebase(BoxStatus.values[newIndex]);
  }

  void _updateStatusInFirebase(BoxStatus newStatus) {
    if (box?.id != null) {
      String typeAsString = newStatus.toString().split('.').last;
      FirebaseFirestore.instance
          .collection('boxes')
          .doc(box!.id)
          .update({'status': typeAsString}).catchError((error) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $error'),
            backgroundColor: Colors.red,
          ),
        );
      });
    } else {
      // Handle case where box ID is null
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Box ID is not available'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  void _updateBoxLocationInFirebase(BoxLocation newLocation) {
    if (box?.id != null) {
      String typeAsString = newLocation.toString().split('.').last;
      FirebaseFirestore.instance
          .collection('boxes')
          .doc(box!.id)
          .update({'location': typeAsString})
          .then((_) =>
              _showSnackbar('Location updated successfully', Colors.green))
          .catchError((error) =>
              _showSnackbar('Error updating location: $error', Colors.red));
    } else {
      _showSnackbar('Error: Box ID is not available', Colors.red);
    }
  }

  Widget _buildCommentSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Comments',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: isEditMode ? null : _enableEditMode,
                ),
              ],
            ),
            isEditMode
                ? TextFormField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your comment',
                    ),
                    maxLines: null,
                  )
                : Text(comment ?? 'No comment', softWrap: true),
            isEditMode
                ? ElevatedButton(
                    onPressed: _saveComment,
                    child: const Text('Save'),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  void _enableEditMode() {
    setState(() {
      _commentController.text = comment ?? '';
      isEditMode = true;
    });
  }

  void _saveComment() {
  final String commentText = _commentController.text;

  if (box != null) {
    FirebaseFirestore.instance.collection('boxes').doc(box!.id).update({
      'comment': commentText,
    }).then((_) {
      setState(() {
        comment = commentText; // Update the comment state
        isEditMode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating comment: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error: Box ID is not available'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

}
