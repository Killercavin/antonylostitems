import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lostitems/feedback.dart';

class LostItemSearchScreen extends StatefulWidget {
  @override
  _LostItemSearchScreenState createState() => _LostItemSearchScreenState();
}

class _LostItemSearchScreenState extends State<LostItemSearchScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String _searchKeyword = '';
  List<DocumentSnapshot> _items = [];
  List<DocumentSnapshot> _filteredItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      final snapshot = await _firestore.collection('lost_items').get();
      setState(() {
        _items = snapshot.docs;
        _filteredItems = _items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching items: $e')),
      );
    }
  }

  void filterItems() {
    final keyword = _searchKeyword.toLowerCase();
    setState(() {
      _filteredItems = _items.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final itemName = (data['item_name'] ?? '').toLowerCase();
        final description = (data['description'] ?? '').toLowerCase();
        return itemName.contains(keyword) || description.contains(keyword);
      }).toList();
    });
  }

  Future<String> getImageUrl(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return ''; // Return an empty string if no image path is provided
    }
    try {
      String url = await _storage.ref('lost_items/$imagePath').getDownloadURL(); // Adjusted to reference the correct path
      return url;
    } catch (e) {
      print("Error fetching image URL: $e");
      return ''; // Return empty string if fetching fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Lost & Found Items'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) {
                _searchKeyword = value;
                filterItems();
              },
              decoration: InputDecoration(
                labelText: 'Search by keyword',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                prefixIcon: Icon(Icons.search, color: Colors.black),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 100, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'No items found.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final data = _filteredItems[index].data() as Map<String, dynamic>;
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String>(
                          future: getImageUrl(data['image_url']), // Ensure correct field name
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Container(
                                width: 100,
                                height: 100,
                                child: Center(child: CircularProgressIndicator()),
                              );
                            } else if (snapshot.hasError || snapshot.data!.isEmpty) {
                              return Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                              );
                            } else {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  snapshot.data!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }
                          },
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['item_name'] ?? 'Unknown Item',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                data['description'] ?? 'No description available',
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 5),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  data['category'] ?? 'Miscellaneous',
                                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FeedbackScreen()),
          );
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.star_rate, color: Colors.white),
      ),
    );
  }
}
