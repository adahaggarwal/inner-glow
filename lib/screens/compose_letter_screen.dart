import 'package:flutter/material.dart';
import 'package:innerglow/screens/time_capsule.dart';
import 'package:intl/intl.dart';
import 'package:innerglow/constants/colors.dart';
import 'package:innerglow/screens/writing_prompt_card.dart';

class ComposeLetterScreen extends StatefulWidget {
  const ComposeLetterScreen({Key? key}) : super(key: key);

  @override
  _ComposeLetterScreenState createState() => _ComposeLetterScreenState();
}

class _ComposeLetterScreenState extends State<ComposeLetterScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 365));

  // List of dynamic writing prompts
  final List<Map<String, String>> _writingPrompts = [
    {"prompt": "What are your biggest goals right now?", "text": "\n\nMy biggest goals right now are..."},
    {"prompt": "What would you like your future self to remember?", "text": "\n\nI want my future self to remember..."},
    {"prompt": "What are you grateful for today?", "text": "\n\nToday, I'm grateful for..."},
  ];

  // Helper method to pick a date
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF863668)),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF863668),
        title: const Text(
          "Write to Future You",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Letter Created!"),
                  content: const Text(
                    "Your letter has been saved and will be delivered to you on the selected date. Look forward to hearing from your past self!",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Futureletters()));
                      },
                      child: const Text("OK", style: TextStyle(color: Color(0xFF863668))),
                    ),
                  ],
                ),
              );
            },
            child: const Text(
              "Save",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery date picker
            DeliveryDatePicker(
              selectedDate: _selectedDate,
              onPickDate: () => _pickDate(context),
            ),
            const SizedBox(height: 20),

            // Letter title
            TextFieldWithLabel(
              controller: _titleController,
              labelText: "Letter Title",
              hintText: "e.g., 'To Myself on My 30th Birthday'",
            ),
            const SizedBox(height: 20),

            // Letter content
            TextFieldWithLabel(
              controller: _contentController,
              labelText: "Dear Future Me...",
              hintText: "Share your thoughts, feelings, goals, and aspirations...",
              maxLines: 15,
            ),
            const SizedBox(height: 20),

            // Writing prompts
            const Text(
              "Need inspiration?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF863668),
              ),
            ),
            const SizedBox(height: 10),
            ..._writingPrompts.map(
              (prompt) => WritingPromptCard(
                prompt: prompt["prompt"]!,
                onTap: () {
                  _contentController.text += prompt["text"]!;
                },
              ),
            ).toList(),
          ],
        ),
      ),
    );
  }
}

// Reusable Delivery Date Picker Widget
class DeliveryDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPickDate;

  const DeliveryDatePicker({
    Key? key,
    required this.selectedDate,
    required this.onPickDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E6EF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE8C5D9), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "When should this letter arrive?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF863668),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM dd, yyyy').format(selectedDate),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              ElevatedButton(
                onPressed: onPickDate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF863668),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("Change Date"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Reusable TextField Widget
class TextFieldWithLabel extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final int? maxLines;

  const TextFieldWithLabel({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          color: bg,
          fontWeight: FontWeight.bold,
        ),
        hintText: hintText,
        // alignLabelWithHint: maxLines > 1,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF863668)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE8C5D9)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}