import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:v1/emailauth/auth.dart';
import 'package:v1/emailauth/pages/loginpage.dart';

class LandingPage extends StatelessWidget {
  // final String email;
  final User? user = Auth().currentUser;

  LandingPage({super.key});

  Future<void> signOut(BuildContext context) async {
    Auth auth = Auth();
    await auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await signOut(
                  context); // Call the signOut function with the context
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('plotowners')
            .where('email', isEqualTo: user?.email)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No data found'));
          }

          var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          bool verification = data['verification'] ?? false;

          if (verification) {
            return CustomerDetailsPage();
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
  final User? user = Auth().currentUser;

  CustomerDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user?.email)
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
            var userData =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;

            var firstname = userData['firstname'] ?? 'Unknown';
            var lastname = userData['lastname'] ?? 'Unknown';
            var email = userData['email'] ?? 'Unknown';
            var phoneNumber = userData['phoneNumber'] ?? 'Unknown';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name: $firstname $lastname',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text('Email: $email'),
                    const SizedBox(height: 5),
                    Text('Phone Number: $phoneNumber'),
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

  const BookingDurationTimer(this.bookingTime, {super.key});

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
      _timer = Timer.periodic(const Duration(seconds: 1), _updateTimer);
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
      formattedElapsedTime,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
