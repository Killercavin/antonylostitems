import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graphic/graphic.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int totalReports = 0;
  int verifiedCount = 0;
  int pendingCount = 0;
  int resolvedCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchReportData();
  }

  Future<void> _fetchReportData() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('lost_items').get();

    setState(() {
      totalReports = snapshot.docs.length;
      verifiedCount = snapshot.docs.where((doc) => (doc['status']?.toString() ?? '') == 'verified').length;
      pendingCount = snapshot.docs.where((doc) => (doc['status']?.toString() ?? '') == 'pending').length;
      resolvedCount = snapshot.docs.where((doc) => (doc['status']?.toString() ?? '') == 'resolved').length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Dashboard")),
      body: Column(
        children: [
          Expanded(child: _buildStats()),
          Expanded(child: _buildChart()),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,

      children: [
        _buildStatCard("Total Reports", totalReports.toString(), Colors.blue),
        _buildStatCard("Verified", verifiedCount.toString(), Colors.green),
        _buildStatCard("Pending", pendingCount.toString(), Colors.orange),
        _buildStatCard("Resolved", resolvedCount.toString(), Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(color: Colors.white, fontSize: 18)),
            Text(count, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final List<Map<String, dynamic>> data = [
      {'category': 'Pending', 'count': pendingCount, 'color': Colors.orange},
      {'category': 'Verified', 'count': verifiedCount, 'color': Colors.green},
      {'category': 'Resolved', 'count': resolvedCount, 'color': Colors.purple},
    ];

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Chart(
        data: data,
        variables: {
          'category': Variable(
            accessor: (Map<String, dynamic> map) => (map['category'] as String?) ?? 'Unknown',
          ),
          'count': Variable(
            accessor: (Map<String, dynamic> map) => (map['count'] as num?) ?? 0,
          ),
        },
        marks: [
          IntervalMark(
            position: Varset('category') * Varset('count'),
            color: ColorEncode(
              variable: 'category',
              values: [Colors.orange, Colors.green, Colors.purple],
            ),
            label: LabelEncode(
              encoder: (tuple) => Label(tuple['count'].toString()),
            ),
          ),
        ],
        coord: PolarCoord(transposed: true, startRadius: 0.3),
        selections: {'tap': PointSelection(dim: Dim.x)},
        tooltip: TooltipGuide(),
        axes: [],
      ),
    );
  }
}
