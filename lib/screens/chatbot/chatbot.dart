import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:innerglow/constants/colors.dart';
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart'; // Add this package

class Chatbot extends StatefulWidget {
  @override
  _ChatbotState createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  final String apiKey = "AIzaSyA7qiMEe7_1nvs3JOi0UxhUJ5--fS8ZlSY"; // 🔑 Replace with your Gemini API key
  bool _isLoading = false;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechInitialized = false;

  @override
  void initState() {
    super.initState();

    // Initialize speech-to-text
    _speech = stt.SpeechToText();
    _initSpeech();

    // Add welcome message from Lumora
    setState(() {
      _messages.add({
        "role": "bot",
        "text": "Hello, I'm Lumora. I'm here to provide a listening ear. How are you feeling today?"
      });
    });
  }

  // Handle case when permission is denied
  void _handlePermissionDenied() {
    setState(() {
      _speechInitialized = false;
      _messages.add({
        "role": "bot",
        "text": "Voice input isn't available because microphone permission was denied. "
            "You can enable it in your device settings under App Permissions."
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Microphone permission required for voice input"),
        action: SnackBarAction(
          label: "Settings",
          onPressed: () => openAppSettings(),
        ),
      ),
    );
  }

  // New method to handle speech initialization
  Future<void> _initSpeech() async {
    try {
      // Request microphone permission first
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        bool available = await _speech.initialize(
          onStatus: (status) => print('Speech recognition status: $status'),
          onError: (error) => print('Speech recognition error: $error'),
        );

        setState(() {
          _speechInitialized = available;
        });

        if (!available) {
          print("Speech recognition not available on this device");
          // Optionally add a message to the user
          setState(() {
            _messages.add({
              "role": "bot",
              "text": "Voice input is not available on this device. Please type your messages instead."
            });
          });
        }
      } else {
        print("Microphone permission denied");
        // Notify user about permission issue
        setState(() {
          _messages.add({
            "role": "bot",
            "text": "I need microphone permission to use voice input. Please enable it in your device settings."
          });
        });
      }
    } catch (e) {
      print("Error initializing speech: $e");
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": message});
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      // Create the mental health focused prompt
      final promptedMessage = _createMentalHealthPrompt(message);

      final response = await http.post(
        Uri.parse(
            "https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key=$apiKey"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {"parts": [{"text": promptedMessage}]}
          ]
        }),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

         if (responseData.containsKey("candidates") && responseData["candidates"].isNotEmpty) {
          String botReply = responseData["candidates"][0]["content"]["parts"][0]["text"] ?? "I'm here to support you.";

          // Sanitize the bot's response
          botReply = _sanitizeResponse(botReply);

          setState(() {
            _messages.add({"role": "bot", "text": botReply});
            _isLoading = false;
          });
        } else {
          setState(() {
            _messages.add({
              "role": "bot",
              "text":
                  "I'm having trouble processing your message right now. Could we try a different approach to this conversation?"
            });
            _isLoading = false;
          });
        }
      } else {
        final errorMessage = jsonDecode(response.body)["error"]["message"] ??
            "Unknown error.";
        setState(() {
          _messages.add({
            "role": "bot",
            "text":
                "I'm sorry, I'm having some technical difficulties at the moment. Let's try again in a moment."
          });
          _isLoading = false;
        });
        print("API Error: $errorMessage");
      }
    } catch (e) {
      print("Exception Occurred: $e");
      setState(() {
        _messages.add({
          "role": "bot",
          "text":
              "I apologize for the interruption. It seems we're having connection issues. Please try again when you're ready."
        });
        _isLoading = false;
      });
    }

    _scrollToBottom();
    _controller.clear(); // Clear the input box
  }

  String _createMentalHealthPrompt(String userMessage) {
    return '''
You are Lumora, a compassionate mental health support chatbot designed to help people struggling with various mental health challenges. Your responses should be warm, empathetic, and non-judgmental.

CORE GUIDELINES:
1. SAFETY FIRST: If someone expresses thoughts of self-harm or suicide, compassionately encourage them to contact crisis services immediately. Provide the number for a mental health crisis line for india and emphasize that help is available.

2. BE EMPATHETIC: Acknowledge and validate the person's feelings without minimizing their experience. Use phrases like "I hear you," "That sounds really difficult," and "Your feelings are valid."

3. AVOID CLINICAL DIAGNOSIS: Never attempt to diagnose conditions. Instead, discuss symptoms and experiences in supportive ways.

4. PROVIDE PRACTICAL SUPPORT: Offer evidence-based coping strategies for common issues like:
   - Anxiety: Deep breathing, grounding techniques, mindfulness
   - Depression: Behavioral activation, gratitude practices, social connection
   - Stress: Progressive muscle relaxation, time management, boundary setting
   - Sleep issues: Sleep hygiene tips, relaxation techniques
   - Motivation: Small steps approach, self-compassion, reward systems

5. ENCOURAGE PROFESSIONAL HELP: Gently suggest professional support for persistent or severe issues. Frame therapy and psychiatry positively as valuable resources.

6. PROMOTE SELF-CARE: Encourage basic self-care like adequate sleep, balanced nutrition, physical activity, and social connection.

7. STRENGTHS-BASED APPROACH: Help people identify their strengths and past successes in overcoming challenges.

8. AVOID TOXIC POSITIVITY: Don't dismiss negative emotions with platitudes like "just think positive." Instead, acknowledge difficulties while offering hope.

9. MAINTAIN BOUNDARIES: You are not a replacement for professional help. Be clear about your limitations.

10. CULTURAL SENSITIVITY: Be respectful and inclusive toward diverse experiences and backgrounds.

11. Add emojis to make the texts more user centric

12. Keep your responses short, unless required.


USER MESSAGE: ${userMessage}

Respond as Lumora in a compassionate, helpful, and concise manner. Focus on emotional support while offering practical strategies when appropriate.
''';
  }

  // Improved speech recognition function
  void _listen() async {
    if (!_speechInitialized) {
      // Try to initialize again if it failed before
      await _initSpeech();
      if (!_speechInitialized) {
        // Show a message to the user that speech recognition isn't available
        setState(() {
          _messages.add({
            "role": "bot",
            "text": "Voice input isn't available right now. Please check your microphone permissions and try again."
          });
        });
        return;
      }
    }

    if (!_isListening) {
      try {
        setState(() {
          _isListening = true;
        });
        
        // Add visual feedback for listening state
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Listening... Speak now"),
            backgroundColor: bg,
            duration: Duration(seconds: 30),
          ),
        );
        
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
              // If we have a final result, stop listening
              if (result.finalResult) {
                _isListening = false;
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                // Optionally auto-send the message if it's a final result
                // sendMessage(_controller.text);
              }
            });
          },
          listenFor: Duration(seconds: 30),
          pauseFor: Duration(seconds: 5),
          partialResults: true,
          localeId: "en_US", // Set to your preferred language
          onSoundLevelChange: (level) {
            // You could use this to show a visual mic level indicator
            print("Sound level: $level");
          },
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
        );
      } catch (e) {
        print("Error listening: $e");
        setState(() {
          _isListening = false;
        });
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Voice recognition error. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      setState(() {
        _isListening = false;
      });
      _speech.stop();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }
  //remove **
  String _sanitizeResponse(String text) {
    // Remove '**' and any other unwanted patterns
    return text.replaceAll('**', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lumora", style: TextStyle(color: Colors.white)),
        backgroundColor: bg,
        leading: Icon(Icons.arrow_back,color: Colors.white,),
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                itemBuilder: (context, index) {
                  if (_isLoading && index == _messages.length) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple[100],
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 80,
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.purple[200],
                                valueColor: AlwaysStoppedAnimation(Colors.purple[800]!),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text("Thinking...", style: TextStyle(color: Colors.purple[800])),
                          ],
                        ),
                      ),
                    );
                  }

                  final message = _messages[index];
                  final isUser = message["role"] == "user";

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser)
                          Padding(
                            padding: const EdgeInsets.only(right: 5.0),
                            child: CircleAvatar(
                              backgroundImage: AssetImage('lib/assets/images/logo.png'), // Add your chatbot image here
                            ),
                          ),
                        Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.purple[400] : Colors.purple[100],
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            message["text"]!,
                            style: TextStyle(
                              fontSize: 16,
                              color: isUser ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: "Share how you're feeling...",
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _isListening ? Colors.red : bg,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(_isListening ? Icons.mic_off : Icons.mic, color: Colors.white),
                      onPressed: _listen,
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: bg,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(_isLoading ? Icons.hourglass_top : Icons.send, color: Colors.white),
                      onPressed: _isLoading ? null : () => sendMessage(_controller.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
}