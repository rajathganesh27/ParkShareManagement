import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:v1/emailauth/auth.dart';
import 'package:v1/emailauth/pages/loginpage.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class LandingPage extends StatelessWidget {
  final User? user = Auth().currentUser;

  LandingPage({Key? key});

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
        leading: IconButton(
          icon: const Icon(
            Icons.logout,
            color: Colors.black,
            weight: 30,
          ),
          onPressed: () async {
            await signOut(context);
          },
        ),
        title: const Row(
          children: <Widget>[
            Text(
              'Customer Details',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
            return Center(
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    speed: const Duration(milliseconds: 100),
                    'Error: ${snapshot.error}', // Displaying error message
                    textStyle: const TextStyle(
                      fontSize: 40,
                      color: Color(0xFFBC0063),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    speed: const Duration(milliseconds: 100),
                    'No data found', // Displaying no data message
                    textStyle: const TextStyle(
                      fontSize: 40,
                      color: Color(0xFFBC0063),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          bool verification = data['verification'] ?? false;
          String firstName = data['firstname'] ?? ''; // Extracting first name

          if (verification) {
            return CustomerDetailsPage();
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedTextKit(animatedTexts: [
                    TyperAnimatedText(
                      speed: const Duration(milliseconds: 100),
                      'Welcome $firstName', // Displaying welcome message
                      textStyle: const TextStyle(
                        fontSize: 40,
                        color: Color(0xFFBC0063),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    TyperAnimatedText(
                      speed: const Duration(milliseconds: 100),
                      'Your Account is under review.', // Displaying welcome message
                      textStyle: const TextStyle(
                        fontSize: 40,
                        color: Color(0xFFBC0063),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    TyperAnimatedText(
                      speed: const Duration(milliseconds: 100),
                      'Please Wait...', // Displaying welcome message
                      textStyle: const TextStyle(
                        fontSize: 40,
                        color: Color(0xFFBC0063),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ]),
                ],
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
          .collection('bookings')
          .where('landemail', isEqualTo: user?.email)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  speed: const Duration(milliseconds: 100),
                  'Error: ${snapshot.error}',
                  textStyle: TextStyle(
                    fontSize: 40,
                    color: Color(0xFFBC0063),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Center(
            child: AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  speed: const Duration(milliseconds: 100),
                  'No data Found',
                  textStyle: TextStyle(
                    fontSize: 40,
                    color: Color(0xFFBC0063),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var bookingData =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;

            var userId = bookingData['userId'] ?? '';
            var startTime = bookingData['startTime'] as Timestamp;
            var bookingTime = startTime.toDate();

            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('uid', isEqualTo: userId)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError) {
                  return Center(
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TyperAnimatedText(
                          'Error: ${userSnapshot.error}',
                          textStyle:
                              TextStyle(fontSize: 16, color: Color(0xFFBC0063)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (userSnapshot.data == null ||
                    userSnapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No user data found'));
                }

                var userData = userSnapshot.data!.docs.first.data()
                    as Map<String, dynamic>;

                var firstname = userData['firstname'] ?? 'Unknown';
                var lastname = userData['lastname'] ?? 'Unknown';
                var email = userData['email'] ?? 'Unknown';
                var phoneNumber = userData['phoneNumber'] ?? 'Unknown';

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name: $firstname $lastname',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text('Email: $email'),
                              const SizedBox(height: 5),
                              Text('Phone Number: $phoneNumber'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20), // Adjust spacing
                        Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              BookingDurationTimer(bookingTime),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class BookingDurationTimer extends StatefulWidget {
  final DateTime? bookingTime;

  const BookingDurationTimer(this.bookingTime, {Key? key});

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
      style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 24), // Increased font size
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
