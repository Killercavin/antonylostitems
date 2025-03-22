import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;


import 'package:lostitems/widgets/constantsdata.dart';
import 'package:mailer/mailer.dart' show Message, Address, send;
import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server/gmail.dart';
import 'package:geocoding/geocoding.dart';

import 'mailgun.dart';

class LostItemReportScreen extends StatefulWidget {
  @override
  _LostItemReportScreenState createState() => _LostItemReportScreenState();
}

class _LostItemReportScreenState extends State<LostItemReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  String _status = 'Lost'; // Default value

  Uint8List? _imageData;
  String? _category;
  double? _latitude;
  double? _longitude;
  final ImagePicker _picker = ImagePicker();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<List<String> > fetchEmails() async{
    List<String> emails=[];
    try{
      QuerySnapshot querySnapshot= await FirebaseFirestore.instance.collection("details").get();
      for(var doc in querySnapshot.docs){
        emails.add(doc["email"]);
      }

    }catch(e){
      print("error fetching emails:$e");

    }
    return emails;

  }





  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      } else {
        return "Unknown Location";
      }
    } catch (e) {
      print("Error fetching address: $e");
      return "Unknown Location";
    }
  }

  Future<void> sendEmailNotification(String itemName, String description, String locationAddress) async {
    List<String> recipients = await fetchEmails();
    if (recipients.isEmpty) {
      print("No registered emails found.");
      return;
    }

    String username = 'geokim068@gmail.com';
    String password = 'lhkr nptj nddc bqeu'; // App Password

    final smtpServer = gmail(username, password);

    final emailMessage = mailer.Message()
      ..from = Address(username, "Lost & Found Service")
      ..recipients.addAll(recipients)
      ..subject = "Lost Item Report: $itemName"
      ..text = "Hello,\n\nA new lost item has been reported:\n\n"
          "Item: $itemName\nDescription: $description\nLocation: $locationAddress\n\n"  // ✅ Updated with Address
          "We will notify you when it's found.\n\nBest Regards,\nLost & Found Team";

    try {
      await send(emailMessage, smtpServer);
      print("Lost item notification sent successfully.");
    } catch (e) {
      print("Failed to send email: $e");
    }
  }


  Future<String?> uploadImageToFirebase(Uint8List imageData) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('lost_items/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putData(imageData);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Failed to upload image: $e');
      return null;
    }
  }

  Future<void> _getDeviceLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      debugPrint('Failed to get location: $e');
    }
  }


  Future<void> submitReport() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submitting report...')),
      );

      await _getDeviceLocation();

      String? imageUrl;
      if (_imageData != null) {
        imageUrl = await uploadImageToFirebase(_imageData!);
      }

      String locationAddress = "Unknown Location";
      if (_latitude != null && _longitude != null) {
        locationAddress = await getAddressFromCoordinates(_latitude!, _longitude!);
      }

      final reportData = {
        'item_name': _itemNameController.text,
        'description': _descriptionController.text,
        'contact_email': _contactEmailController.text,
        'contact_phone': _contactPhoneController.text,
        'image_url': imageUrl ?? '',
        'category': _category,
        'status': _status,
        'latitude': _latitude,
        'longitude': _longitude,
        'location_address': locationAddress,
        'submitted_at': Timestamp.now(),
      };

      try {
        await firestore.collection('lost_items').add(reportData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report submitted successfully!')),
        );

        // ✅ Send Email Notification
        await sendEmailNotification(
            _itemNameController.text,
            _descriptionController.text,
          locationAddress,
        );


        // ✅ Send SMS Notification to all users


      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $e')),
        );
      }
    }
  }

  Future<void> pickImageFromGallery() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageData = imageBytes;
      });
    }
  }

  Future<void> captureImageFromCamera() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageData = imageBytes;
      });
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Lost or Recovered Item',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                buildTextField(_itemNameController, 'Item Name'),
                buildTextField(_descriptionController, 'Description'),
                buildTextField(_contactEmailController, 'Contact Email',
                    validator: (value) =>
                    value == null || !value.contains('@')
                        ? 'Enter a valid email'
                        : null),
                buildTextField(_contactPhoneController, 'Contact Phone',
                    keyboardType: TextInputType.phone),
                buildDropdownField(),
                buildStatusDropdown(),
                SizedBox(height: 20),
                _imageData != null
                    ? Image.memory(_imageData!,
                    width: 150, height: 150, fit: BoxFit.cover)
                    : Text('No image selected'),
                SizedBox(height: 10),
                buildImageButtons(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: submitReport,


                  style: ElevatedButton.styleFrom(
                     shape: RoundedRectangleBorder(),
                      fixedSize: const Size(double.maxFinite, 53),
                      backgroundColor: Colors.blue

                  ),

                  child: Text('Submit Report', style: GoogleFonts.poppins(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: validator ??
                (value) => value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  Widget buildDropdownField() {
    final categories = [
      'Electronics',
      'Clothes',
      'Keys',
      'Documents',
      'Accessories',
      'Other',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _category,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Category',
        ),
        items: categories.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _category = value;
          });
        },
        validator: (value) => value == null ? 'Select a category' : null,
      ),
    );
  }

  Widget buildImageButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: SizedBox(
            height: 50, // Ensure both buttons have the same height
            child: ElevatedButton(
              onPressed: pickImageFromGallery,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Pick Image',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10), // Space between buttons
        Expanded(
          child: SizedBox(
            height: 50, // Same height as the first button
            child: ElevatedButton(
              onPressed: captureImageFromCamera,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Capture Image',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildStatusDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _status,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Status',
        ),
        items: ['Lost', 'Found'].map((status) {
          return DropdownMenuItem(
            value: status,
            child: Text(status),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _status = value!;
          });
        },
      ),
    );
  }


}
