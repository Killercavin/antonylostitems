import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemListScreen extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Function to launch phone call
  Future<void> _makeCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print('Could not launch $phoneNumber');
    }
  }

  // Function to claim an item and update its status in Firestore
  Future<void> _claimItem(String itemId) async {
    try {
      await firestore.collection('lost_items').doc(itemId).update({
        'status': 'claimed',
      });
      print('Item marked as claimed.');
    } catch (e) {
      print('Error updating item status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lost Items List',
          style: TextStyle(fontSize: screenWidth * 0.05),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: firestore.collection('lost_items').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final items = snapshot.data?.docs ?? [];

            if (items.isEmpty) {
              return Center(
                child: Text(
                  'No items available.',
                  style: TextStyle(fontSize: screenWidth * 0.05),
                ),
              );
            }

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final itemId = item.id;
                final data = item.data() as Map<String, dynamic>? ?? {}; // Ensure it's a map
                final itemName = data['item_name'] ?? 'Unnamed item';
                final description = data['description'] ?? 'No description';
                final contactPhone = data['contact_phone'] ?? 'No contact';
                final imageUrl = data['image_url'] ?? '';
                final status = data.containsKey('status') ? data['status'] : 'unclaimed';

                return Card(
                  margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ?? 1)
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.broken_image, size: 100, color: Colors.grey),
                            ),
                          ),
                        SizedBox(height: 10),
                        Text(
                          itemName,
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          'Contact: $contactPhone',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.call),
                              color: Colors.green,
                              onPressed: () => _makeCall(contactPhone),
                            ),
                            ElevatedButton(
                              onPressed: status == 'claimed'
                                  ? null
                                  : () async {
                                await _claimItem(itemId);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                status == 'claimed' ? Colors.grey : Colors.blue,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                              child: Text(
                                status == 'claimed' ? 'Claimed' : 'Claim Item',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
