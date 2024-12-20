import 'package:flutter/material.dart';
import 'package:girls_grivince/Models/DataProvider.dart';
import 'package:provider/provider.dart';

class Status extends StatefulWidget {
  @override
  _StatusState createState() => _StatusState();
}

class _StatusState extends State<Status> {
  @override
  void initState() {
    super.initState();
    // Fetch data in the background if not already fetched
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    if (dataProvider.complaints.isEmpty) {
      dataProvider.fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header with background image and title
          Stack(
            children: [
              Image.asset(
                'assets/img/home2.png',
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 40,
                left: 20,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Image.asset(
                        'assets/img/arrow2.png',
                        height: 35,
                        width: 43,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Complaint Status',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Title and refresh button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'List of All Complaints',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    dataProvider.fetchData();
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Complaints table
          Expanded(
            child: dataProvider.complaints.isEmpty
                ? Center(child: Text('No complaints available'))
                : Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 20),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Table(
                        border: TableBorder.all(color: Colors.grey.shade300),
                        columnWidths: const <int, TableColumnWidth>{
                          0: FixedColumnWidth(50),
                          1: FlexColumnWidth(),
                          2: FlexColumnWidth(),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: Colors.purple.shade100),
                            children: [
                              tableCell('S.No'),
                              tableCell('Statement'),
                              tableCell('Status'),
                            ],
                          ),
                          ...dataProvider.complaints.asMap().entries.map((entry) {
                            int index = entry.key + 1;
                            var complaint = entry.value;
                            return tableRow(
                              index,
                              complaint.statement,
                              complaint.status,
                              _getStatusColor(complaint.status),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'solved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  TableRow tableRow(int no, String statement, String status, Color statusColor) {
    return TableRow(
      children: [
        tableCell('$no'),
        tableCell(statement),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(Icons.circle, color: statusColor, size: 12),
              SizedBox(width: 8),
              Text(status),
            ],
          ),
        ),
      ],
    );
  }

  Widget tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
