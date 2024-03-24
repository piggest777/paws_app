import 'package:flutter/material.dart';
import 'package:paws_app/src/models/box.dart';
import 'package:paws_app/src/models/fond.dart';
import 'package:paws_app/src/models/person.dart';
import 'package:paws_app/src/models/request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paws_app/src/services/firebase_service.dart';
import 'package:paws_app/src/services/pdf_manager.dart';
import 'package:paws_app/src/utils/box_status_util.dart';
import 'package:paws_app/src/views/boxes/box_item_page.dart';
import 'package:paws_app/src/views/boxes/fond_input_view.dart';
import 'package:paws_app/src/views/request_detatil_page.dart';
import 'package:paws_app/src/views/view_components/box_weight.dart';
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
  String? organizationName;
  Fond? selectedFond;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    box = widget.box;
    boxId = box?.id ?? widget.boxId;
    isLoading = true;

    if (box != null) {
      // When a box is directly passed to the widget
      initializeBoxDetails();
    } else if (boxId != null) {
      // If only the boxId is provided, fetch box details first
      fetchBoxDetails(boxId!);
    } else {
      // Handle the case where no box or boxId is provided (error state or blank slate)
      isLoading = false;
    }
  }

  void initializeBoxDetails() {
    selectedSize = box?.size;
    selectedType = box?.type;
    selectedStatus = box?.status ?? BoxStatus.created;
    selectedLocation = box?.location ?? BoxLocation.office;
    comment = box?.comment ?? '';
    _commentController.text = box?.comment ?? '';
    organizationName = box?.organizationName;

    if (widget.request != null) {
      // Use the request object passed to the widget, if available
      request = widget.request;
      requestName = '${request?.name} ${request?.surname}';
      organizationName = request?.organizationName;
      if (person == null) {
        // Fetch person details if necessary
        fetchPersonDetails(request!.personId);
      } else {
        isLoading = false;
      }
    } else if (box!.isDirectToPerson) {
      organizationName = box?.organizationName;
      // If the box is directly connected to a person, fetch the person's details
      fetchPersonDetails(box!.requestId); // Here requestId is personId
    } else {
      // Otherwise, fetch the related request
      fetchRequestDetails(box!.requestId);
    }
  }

  void fetchBoxDetails(String boxId) async {
    try {
      var boxSnapshot =
          await FirebaseFirestore.instance.collection('boxes').doc(boxId).get();
      if (boxSnapshot.exists) {
        setState(() {
          box = Box.fromMap(boxSnapshot.data()!, boxId);
          selectedSize = box?.size;
          selectedType = box?.type;
          selectedStatus = box?.status ?? BoxStatus.created;
          selectedLocation = box?.location ?? BoxLocation.office;
          comment = box?.comment ?? '';
          _commentController.text = box?.comment ?? '';
          organizationName = box?.organizationName;

          requestName = box?.requesterName ?? '';

          if (box!.isDirectToPerson) {
            fetchPersonDetails(box!.requestId); // Here requestId is personId
          } else {
            fetchRequestDetails(box!.requestId);
          }
        });
      } else {
        print('Box not found');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching box details: $e');
      setState(() => isLoading = false);
    }
  }

  void fetchRequestDetails(String requestId) async {
    setState(() => isLoading = true); // Start loading

    try {
      var requestSnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .get();
      if (requestSnapshot.exists) {
        var fetchedRequest =
            Request.fromMap(requestSnapshot.data()!, requestId);

        setState(() {
          request = fetchedRequest;
          requestName = '${fetchedRequest.name} ${fetchedRequest.surname}';
          organizationName = request?.organizationName;
          // No need to set isLoading = false here as we might be fetching person details next
        });

        // Check if person details are already available or not
        if (person == null) {
          fetchPersonDetails(fetchedRequest
              .personId); // Fetch person details using the personId from fetchedRequest
        } else {
          setState(() => isLoading =
              false); // If person details are already available or no personId, stop loading
        }
      } else {
        print('Request not found');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching request details: $e');
      setState(() => isLoading = false);
    }
  }

  void fetchPersonDetails(String personId) async {
    try {
      var personSnapshot = await FirebaseFirestore.instance
          .collection('persons')
          .doc(personId)
          .get();
      if (personSnapshot.exists) {
        setState(() {
          person = Person.fromMap(personSnapshot.data()!, personSnapshot.id);
          requestName = '${person?.name} ${person?.surname}';
          isLoading = false;
        });
      } else {
        print('Person not found');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching person details: $e');
      setState(() => isLoading = false);
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
      appBar: AppBar(
        title: const Text('Box Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box),
            onPressed: () {
              if (boxId != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => BoxItemsPage(
                            boxId: boxId!,
                            organizationName: organizationName,
                            person: person,
                          )),
                );
              }
            },
          ), // Place the delete button in the AppBar
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
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
                            requestName ?? '',
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
                WeightInputWidget(
                  key: ValueKey(box?.weight),
                  initialWeight: box?.weight ?? 0.0,
                  onWeightChanged: (newWeight) {
                    setState(() {
                      box?.weight = newWeight;
                    });
                    // Optionally, update the weight in your database
                    _updateBoxWeightInFirebase(newWeight);
                  },
                ),
                const SizedBox(height: 5),
                _buildStatusCard(),
                const SizedBox(height: 5),
                _buildCommentSection(),
                const SizedBox(height: 5),
                if (box != null &&
                    person != null) // Check if necessary objects are created
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _showFondSelectionModal(context),
                          child: const Text('Create and Share PDF'),
                        ),
                        const SizedBox(height: 10),
                        if (request != null && boxId != null) ...[
                          ElevatedButton(
                            onPressed: () => _navigateToRequestDetails(context),
                            child: const Text('View Request Details'),
                          ),
                          const SizedBox(height: 10),
                        ],
                        // Add spacing for visual separation
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 16.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: _showDeleteConfirmationDialog,
                            child: const Text('Delete Box'),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateBoxWeightInFirebase(double newWeight) {
    if (box?.id != null) {
      FirebaseFirestore.instance
          .collection('boxes')
          .doc(box!.id)
          .update({'weight': newWeight})
          .then(
              (_) => _showSnackbar('Weight updated successfully', Colors.green))
          .catchError((error) =>
              _showSnackbar('Error updating weight: $error', Colors.red));
    } else {
      _showSnackbar('Error: Box ID is not available', Colors.red);
    }
  }

void _showFondSelectionModal(BuildContext context) async {
  final List<Fond> fonds = await FirebaseService().getFonds();
  
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return ListView.builder(
        itemCount: fonds.length + 1,
        itemBuilder: (context, index) {
          if (index == fonds.length) {
            return ListTile(
              leading: Icon(Icons.add),
              title: Text('Add New Fond'),
              onTap: () async {
                Navigator.pop(context); // Ensure to close the current modal first
                // Navigate to a new screen for adding a fond instead of opening a modal
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FondInputView()), // Placeholder for your add new fond screen
                );
                
                // Optional: Check the result if needed and refresh fonds list
                if (result == true) {
                  // Refresh your fonds list or perform any other actions as needed
                }
              },
            );
          } else {
            return ListTile(
              title: Text(fonds[index].name),
              onTap: () {
                setState(() {
                  selectedFond = fonds[index];
                });
                Navigator.pop(context); // Close the modal after selection
                _createAndSharePdf(); // Proceed to create and share PDF
              },
            );
          }
        },
      );
    },
  );
}



  void _createAndSharePdf() async {
    if (selectedFond != null) {
      PDFManager pdfManager = PDFManager(
        box: box,
        organizationName: organizationName,
        person: person,
        fond: selectedFond,
      );
      pdfManager.createAndSharePdf();
    } else {
      print("Can't create PDF without fond selection.");
    }
  }

Future<void> _handleNewFondAddition(BuildContext context) async {
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  // Use showModalBottomSheet directly without wrapping in an async function
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true, // Allow the modal to be scrollable to accommodate the keyboard
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20, // Adjust for keyboard
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Fit content in the viewport
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Fond Name'),
            ),
            TextField(
              controller: numberController,
              decoration: InputDecoration(labelText: 'Fond Number'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: Text('Add Fond'),
              onPressed: () async {
                // Construct the new Fond object
                Fond newFond = Fond(
                  name: nameController.text,
                  fondNumber: numberController.text,
                  address: addressController.text,
                );
                // Save the new fond to Firebase
                await FirebaseService().saveFond(newFond); // Ensure this method is defined to handle asynchronous operations
                Navigator.pop(context); // Close the modal after saving
              },
            ),
          ],
        ),
      );
    },
  );
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
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildSizePicker(),
                const VerticalDivider(width: 1, thickness: 1),
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
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Size', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<BoxSize>(
              value: selectedSize,
              onChanged: (BoxSize? newValue) {
                setState(() {
                  selectedSize = newValue;
                  _updateBoxSizeInFirebase(selectedSize);
                });
              },
              items: BoxSize.values
                  .map<DropdownMenuItem<BoxSize>>((BoxSize value) {
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
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<BoxType>(
              value: selectedType,
              onChanged: (BoxType? newValue) {
                setState(() {
                  selectedType = newValue;
                  _updateBoxTypeInFirebase(selectedType);
                });
              },
              items: BoxType.values
                  .map<DropdownMenuItem<BoxType>>((BoxType value) {
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
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the Row content
          children: <Widget>[
            const Text(
              'Location: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8), // Spacer between text and dropdown
            // Limit the width of the dropdown list
            SizedBox(
              width: 120, // Adjust the width as needed
              child: DropdownButtonHideUnderline(
                child: DropdownButton<BoxLocation>(
                  value: selectedLocation,
                  onChanged: (BoxLocation? newValue) {
                    setState(() {
                      selectedLocation = newValue;
                      _updateBoxLocationInFirebase(selectedLocation!);
                    });
                  },
                  items: BoxLocation.values
                      .map<DropdownMenuItem<BoxLocation>>((BoxLocation value) {
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
                          BoxStatus? oldStatus = selectedStatus;
                          setState(() {
                            selectedStatus = newValue;
                          });
                          _updateStatusInFirebase(newValue!, oldStatus);
                        }
                      : null,
                  items: BoxStatus.values
                      .map<DropdownMenuItem<BoxStatus>>((BoxStatus value) {
                    // Using the _getIconForStatus method to get the corresponding icon
                    Icon statusIcon = BoxStatusUtil.getIconForStatus(value);
                    String statusText = _trimEnumName(value.toString());
                    return DropdownMenuItem<BoxStatus>(
                      value: value,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            statusIcon, // Status icon
                            const SizedBox(width: 8),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 18, // Increased font size
                                fontWeight: FontWeight.bold, // Bold text
                                color: Theme.of(context)
                                    .primaryColor, // Accent color
                              ),
                            ),
                          ],
                        ),
                      ),
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

  String _trimEnumName(String enumString) {
    return enumString.split('.').last;
  }

  void _changeStatus(int direction) {
    BoxStatus? oldStatus = selectedStatus;
    int currentIndex = BoxStatus.values.indexOf(selectedStatus!);
    int newIndex = (currentIndex + direction) % BoxStatus.values.length;
    if (newIndex < 0) newIndex = BoxStatus.values.length - 1;
    setState(() {
      selectedStatus = BoxStatus.values[newIndex];
    });
    _updateStatusInFirebase(BoxStatus.values[newIndex], oldStatus);
  }

  void _updateStatusInFirebase(
      BoxStatus newStatus, BoxStatus? oldStatus) async {
    if (box?.id != null) {
      DateTime now = DateTime.now();
      Map<String, dynamic> updates = {
        'status': newStatus.toString().split('.').last
      };

      // Check for packing date update
      if (newStatus == BoxStatus.packed && box?.packingDate == null) {
        updates['packingDate'] = now;
        box!.packingDate = now; // Update local box object
      } else if (newStatus == BoxStatus.packed && box?.packingDate != null) {
        bool overwrite = await _showOverrideDateDialog('Packing Date');
        if (overwrite) {
          updates['packingDate'] = now;
          box!.packingDate = now; // Update local box object
        }
      }

      // Check for sending date update
      if (newStatus == BoxStatus.sended && box?.sendingDate == null) {
        updates['sendingDate'] = now;
        box!.sendingDate = now; // Update local box object
      } else if (newStatus == BoxStatus.sended && box?.sendingDate != null) {
        bool overwrite = await _showOverrideDateDialog('Sending Date');
        if (overwrite) {
          updates['sendingDate'] = now;
          box!.sendingDate = now; // Update local box object
        }
      }

      FirebaseFirestore.instance
          .collection('boxes')
          .doc(box!.id)
          .update(updates)
          .then(
              (_) => _showSnackbar('Status updated successfully', Colors.green))
          .catchError((error) =>
              _showSnackbar('Error updating status: $error', Colors.red));

      await _updateBoxCountsInRequestDocument(newStatus, oldStatus);
    } else {
      _showSnackbar('Error: Box ID is not available', Colors.red);
    }
  }

  Future<bool> _showOverrideDateDialog(String dateType) async {
    bool overwrite = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Override $dateType?'),
          content: Text(
              'This box already has a $dateType. Do you want to override it with the current date?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                overwrite = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return overwrite;
  }

  Future<void> _updateBoxCountsInRequestDocument(
      BoxStatus newStatus, BoxStatus? oldStatus) async {
    if (box?.requestId != null && oldStatus != null) {
      DocumentReference requestDocRef =
          FirebaseFirestore.instance.collection('requests').doc(box!.requestId);

      // Fetch the current box counts from the request document
      var requestSnapshot = await requestDocRef.get();
      var requestData =
          requestSnapshot.data() as Map<String, dynamic>; // Explicit cast
      Map<String, int> boxCounts = requestData.containsKey('boxStatusCounts')
          ? Map<String, int>.from(requestData['boxStatusCounts'])
          : {};

      // Update the count for the old and new status
      String newStatusKey = newStatus.toString().split('.').last;
      String oldStatusKey = oldStatus.toString().split('.').last;

      boxCounts[newStatusKey] = (boxCounts[newStatusKey] ?? 0) + 1;
      boxCounts[oldStatusKey] = (boxCounts[oldStatusKey] ?? 1) - 1;

      // Ensure counts do not go below zero
      boxCounts[oldStatusKey] =
          boxCounts[oldStatusKey]!.isNegative ? 0 : boxCounts[oldStatusKey]!;

      // Write back the updated counts to the request document
      await requestDocRef.update({'boxStatusCounts': boxCounts});
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

//delete section

  Widget _buildDeleteButton() {
    return IconButton(
      icon: const Icon(Icons.delete),
      color: Colors.white,
      onPressed: _showDeleteConfirmationDialog,
    );
  }

  Future<void> _deleteBox() async {
    if (box?.id == null || (!box!.isDirectToPerson && box?.requestId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Error: Box ID is not available or Box is not linked to a direct request'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    FirebaseFirestore.instance.runTransaction((transaction) async {
      if (!box!.isDirectToPerson) {
        final DocumentReference requestDocRef = FirebaseFirestore.instance
            .collection('requests')
            .doc(box!.requestId);

        // Fetch the current request document
        final DocumentSnapshot requestSnapshot =
            await transaction.get(requestDocRef);

        if (!requestSnapshot.exists) {
          throw Exception('Request does not exist!');
        }

        // Get the current box status counts
        final Map<String, dynamic> requestData =
            requestSnapshot.data() as Map<String, dynamic>;
        final Map<String, dynamic> boxStatusCounts =
            requestData['boxStatusCounts'] as Map<String, dynamic>? ?? {};

        // Decrease the count for the box's status
        final String statusKey = _trimEnumName(box!.status.toString());
        final int currentCount = boxStatusCounts[statusKey] ?? 0;
        boxStatusCounts[statusKey] = currentCount > 0 ? currentCount - 1 : 0;

        // Update the request document with the new box status counts
        transaction.update(requestDocRef, {'boxStatusCounts': boxStatusCounts});
      }

      // Archive the box document
      final DocumentReference boxDocRef =
          FirebaseFirestore.instance.collection('boxes').doc(box!.id);
      transaction.update(boxDocRef, {'archived': true});
    }).then((_) {
      // Navigate back after successful update
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Box archived successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      // Handle any errors here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error archiving box: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Box'),
          content: const Text(
              'Are you sure you want to delete this box? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                _deleteBox(); // Call the delete method
              },
            ),
          ],
        );
      },
    );
  }
}
