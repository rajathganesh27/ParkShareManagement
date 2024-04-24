import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class LandingPage extends StatelessWidget {
  final String email;

  LandingPage({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Details'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('plotowners')
            .where('email', isEqualTo: email)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data found'));
          }

          var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          bool verification = data['verification'] ?? false;

          if (verification) {
            return CustomerDetailsPage(plotId: email);
          } else {
            return const Center(
              child: Text(
                'Your Account is under review.',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class CustomerDetailsPage extends StatelessWidget {
  final String plotId;

  CustomerDetailsPage({required this.plotId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('customers')
          .where('plot_id', isEqualTo: plotId)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No data found'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var customerData =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            var modelName = customerData['model_name'] ?? 'Unknown';
            var name = customerData['name'] ?? 'Unknown';
            var bookingTime = customerData['booking_time'] != null
                ? (customerData['booking_time'] as Timestamp).toDate()
                : null;

            String formattedTime = bookingTime != null
                ? DateFormat.Hms().format(bookingTime)
                : 'Unknown';

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name: $name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text('Model: $modelName'),
                        SizedBox(height: 5),
                        Text('Booking Time: $formattedTime'),
                      ],
                    ),
                    BookingDurationTimer(bookingTime),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class BookingDurationTimer extends StatefulWidget {
  final DateTime? bookingTime;

  BookingDurationTimer(this.bookingTime);

  @override
  _BookingDurationTimerState createState() => _BookingDurationTimerState();
}

class _BookingDurationTimerState extends State<BookingDurationTimer> {
  late Timer _timer;
  Duration _elapsedTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.bookingTime != null) {
      _timer = Timer.periodic(Duration(seconds: 1), _updateTimer);
    }
  }

  void _updateTimer(Timer timer) {
    if (mounted) {
      setState(() {
        _elapsedTime = DateTime.now().difference(widget.bookingTime!);
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedElapsedTime = _formatDuration(_elapsedTime);
    return Text(
      '$formattedElapsedTime',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
