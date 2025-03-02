import 'package:flutter/material.dart';
import 'package:innerglow/constants/colors.dart';
import 'package:innerglow/screens/compose_letter_screen.dart';
import 'package:innerglow/widgets/onbaording_screen.dart';
import 'package:innerglow/widgets/welcome_screen.dart';
import 'package:intl/intl.dart';

class TimeCapsule extends StatelessWidget {
  const TimeCapsule({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF863668),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF863668),
          brightness: Brightness.light,
        ),
        fontFamily: 'epilogue',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF863668),
          ),
          bodyLarge: TextStyle(
            fontSize: 16.0,
            color: Colors.black87,
          ),
        ),
      ),
      home: OnboardingScreen(),
    );
  }
}





class Futureletters extends StatefulWidget {
  const Futureletters({Key? key}) : super(key: key);

  @override
  _FuturelettersState createState() => _FuturelettersState();
}

class _FuturelettersState extends State<Futureletters> {
  // Variables to store the letter data
  String? _letterTitle;
  DateTime? _letterDeliveryDate;

  // Method to update the letter data
  void _updateLetterData(String title, DateTime deliveryDate) {
    setState(() {
      _letterTitle = title;
      _letterDeliveryDate = deliveryDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header section with curved bottom
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            decoration: const BoxDecoration(
              color: Color(0xFF863668),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome to Future You Letters",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "Today is ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                const WelcomeCard(),
              ],
            ),
          ),

          // Dynamic content based on whether a letter exists
          Expanded(
            child: Center(
              child: _letterTitle == null
                  ? _buildEmptyState()
                  : _buildLetterPreview(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ComposeLetterScreen(),
            ),
          );

          if (result != null) {
            _updateLetterData(result['title'], result['date']);
          }
        },
        backgroundColor: const Color(0xFF863668),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  // Build the empty state UI
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: const Color(0xFFF5E6EF),
            borderRadius: BorderRadius.circular(75),
          ),
          child: const Icon(
            Icons.mail_outline,
            size: 50,
            color: Color(0xFF863668),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "No Letters Yet",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF863668),
          ),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "Write your first letter to your future self and begin your journey of self-reflection.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ComposeLetterScreen(),
              ),
            );
          },
          icon: const Icon(Icons.edit_outlined),
          label: const Text("Write Your First Letter"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF863668),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }

  // Build the letter preview UI
  Widget _buildLetterPreview() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: const Color(0xFFF5E6EF),
            borderRadius: BorderRadius.circular(75),
          ),
          child: const Icon(
            Icons.mail_outline,
            size: 50,
            color: Color(0xFF863668),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _letterTitle!,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF863668),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Arriving on ${DateFormat('MMMM dd, yyyy').format(_letterDeliveryDate!)}",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ComposeLetterScreen(),
              ),
            );
          },
          icon: const Icon(Icons.edit_outlined),
          label: const Text("Write Another Letter"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF863668),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }
}