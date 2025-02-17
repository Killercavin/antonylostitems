import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lostitems/widgets/constantsdata.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _feedbackController = TextEditingController();
  double _rating = 1.0; // Allow half steps, initial rating
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> submitFeedback() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance.collection('feedback').add({
        'rating': _rating,
        'feedback': _feedbackController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Feedback submitted successfully!'),
      ));
      _feedbackController.clear();
      setState(() {
        _isSubmitting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error submitting feedback: $e'),
      ));
    }
  }

  Widget buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        // Full star, half star, or empty star logic
        IconData icon;
        if (_rating >= index + 1) {
          icon = Icons.star; // Full star
        } else if (_rating > index && _rating < index + 1) {
          icon = Icons.star_half; // Half star
        } else {
          icon = Icons.star_border; // Empty star
        }

        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1.0; // Full star
            });
          },
          onHorizontalDragUpdate: (details) {
            // Detect half-star rating
            final box = context.findRenderObject() as RenderBox;
            final localPosition = box.globalToLocal(details.globalPosition);
            final starWidth = box.size.width / 5; // Assuming 5 stars
            final preciseRating = (localPosition.dx / starWidth).clamp(0.0, 5.0);
            setState(() {
              _rating = (preciseRating * 2).round() / 2; // Round to nearest 0.5
            });
          },
          child: Icon(
            icon,
            color: MyColors.kPrimaryColor,
            size: 40,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.kPrimaryColor,
        title: Text('Feedback'),
        
        leading: IconButton(onPressed: (){
          
        }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
        actions: [
          IconButton(onPressed: (){

          }, icon: Icon(Icons.rate_review,color: Colors.white,))
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Please rate your experience:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            buildStarRating(),
            Text(
              'Rating: $_rating',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _feedbackController,
              decoration: InputDecoration(
                labelText: 'Your Feedback/Suggestions',
                border: OutlineInputBorder(),

              ),

              maxLines: 4,
            ),
            SizedBox(height: 20),
            _isSubmitting
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: submitFeedback,
              style: ElevatedButton.styleFrom(backgroundColor: MyColors.kPrimaryColor,
                shape: RoundedRectangleBorder()
              ),
              child: Text('Submit Feedback',style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}
