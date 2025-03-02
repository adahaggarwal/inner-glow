import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SelfCareTasksScreen extends StatefulWidget {
  @override
  _SelfCareTasksScreenState createState() => _SelfCareTasksScreenState();
}

class _SelfCareTasksScreenState extends State<SelfCareTasksScreen> {
  late ConfettiController _confettiController;
  late ConfettiController _journeyCompletedController;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  
  // Track task completion status
  Map<String, bool> _completedTasks = {};
  
  // Track missed tasks
  Map<String, bool> _missedTasks = {};
  
  // Current task details
  String currentTaskTitle = "Take 5 deep breaths";
  String currentTaskCategory = "Mindfulness & Relaxation";
  String currentTaskDescription = "Find a quiet space, sit comfortably, and take 5 slow, deep breaths. Focus on your breathing.";
  
  // Progress on the roadmap (0 to 1)
  double progressValue = 0.0;
  int stepsCompleted = 0;
  int totalSteps = 25;
  int journeyCount = 1;
  bool showJourneyCompletedDialog = false;
  
  // Primary color from hex code 863668
  final Color primaryColor = Color(0xFF863668);
  
  // List of task categories with tasks
  final Map<String, List<String>> taskCategories = {
    "Mindfulness & Relaxation": [
      "Take 5 deep breaths",
      "Do a quick 2-minute meditation",
      "Stretch for 3 minutes",
      "Light a scented candle or use essential oils",
      "Sit in silence for a few minutes",
      "Listen to calming music"
    ],
    "Physical Well-being": [
      "Drink a glass of water",
      "Eat a piece of fruit",
      "Take a 5-minute walk",
      "Do 10 jumping jacks",
      "Take a power nap",
      "Give yourself a mini hand or face massage"
    ],
    "Mental Health": [
      "Write down 3 things you're grateful for",
      "Say something kind to yourself",
      "Journal for 2 minutes",
      "Doodle or color for 5 minutes",
      "Write a letter to \"future you\"",
      "Read a short poem or inspiring quote"
    ],
    "Digital Detox & Productivity": [
      "Put your phone on silent for 10 minutes",
      "Organize one small area (desk, bag, etc.)",
      "Unsubscribe from an email you don't need",
      "Delete 5 unnecessary photos from your phone",
      "Set a 5-minute timer to just breathe and reset"
    ],
    "Social & Emotional Care": [
      "Send a kind text to a friend",
      "Give someone a compliment",
      "Hug yourself for a few seconds",
      "Watch a short funny video",
      "Smile at yourself in the mirror"
    ]
  };

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    _journeyCompletedController = ConfettiController(duration: Duration(seconds: 5));
    _loadSavedData();
  }

  // Format date to string for use as map key
  String _formatDateKey(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  // Load saved data from SharedPreferences
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      // Load completed tasks
      final completedTasksJson = prefs.getString('completedTasks');
      if (completedTasksJson != null) {
        _completedTasks = Map<String, bool>.from(jsonDecode(completedTasksJson));
      }
      
      // Load missed tasks
      final missedTasksJson = prefs.getString('missedTasks');
      if (missedTasksJson != null) {
        _missedTasks = Map<String, bool>.from(jsonDecode(missedTasksJson));
      }
      
      // Load progress
      stepsCompleted = prefs.getInt('stepsCompleted') ?? 0;
      journeyCount = prefs.getInt('journeyCount') ?? 1;
      progressValue = stepsCompleted / totalSteps;
      
      // Load current task
      currentTaskTitle = prefs.getString('currentTaskTitle') ?? currentTaskTitle;
      currentTaskCategory = prefs.getString('currentTaskCategory') ?? currentTaskCategory;
      currentTaskDescription = prefs.getString('currentTaskDescription') ?? currentTaskDescription;
    });
    
    _initializeMissedTasks();
  }

  // Save data to SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save completed tasks
    await prefs.setString('completedTasks', jsonEncode(_completedTasks));
    
    // Save missed tasks
    await prefs.setString('missedTasks', jsonEncode(_missedTasks));
    
    // Save progress
    await prefs.setInt('stepsCompleted', stepsCompleted);
    await prefs.setInt('journeyCount', journeyCount);
    
    // Save current task
    await prefs.setString('currentTaskTitle', currentTaskTitle);
    await prefs.setString('currentTaskCategory', currentTaskCategory);
    await prefs.setString('currentTaskDescription', currentTaskDescription);
  }

  // Initialize missed tasks for past days
  void _initializeMissedTasks() {
    final today = DateTime.now();
    
    // Check for the last 30 days
    for (int i = 1; i <= 30; i++) {
      final day = DateTime(today.year, today.month, today.day).subtract(Duration(days: i));
      final dayKey = _formatDateKey(day);
      
      // If there's no completed task for that day, mark it as missed
      if (_completedTasks[dayKey] == null) {
        _missedTasks[dayKey] = true;
      }
    }
    
    // Save the updated missed tasks
    _saveData();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _journeyCompletedController.dispose();
    super.dispose();
  }

  void _startNewJourney() {
    setState(() {
      // Reset steps but keep history
      stepsCompleted = 0;
      progressValue = 0.0;
      journeyCount++;
      showJourneyCompletedDialog = false;
      
      // Assign a new task
      _assignNewTask();
    });
    
    // Save the updated data
    _saveData();
  }

  void _assignNewTask() {
    // Assign next task - pick a random category and task
    final categories = taskCategories.keys.toList();
    final randomCategory = categories[DateTime.now().millisecond % categories.length];
    final tasks = taskCategories[randomCategory]!;
    final randomTask = tasks[DateTime.now().second % tasks.length];
    
    currentTaskTitle = randomTask;
    currentTaskCategory = randomCategory;
    currentTaskDescription = "Complete this simple self-care activity to advance on your journey.";
  }

  void _markTaskComplete() {
    final today = _formatDateKey(_selectedDay);
    
    setState(() {
      _completedTasks[today] = true;
      
      // Remove from missed tasks if it was there
      _missedTasks.remove(today);
      
      // Increment progress
      stepsCompleted++;
      progressValue = stepsCompleted / totalSteps;
      
      // Check if journey is completed
      if (stepsCompleted >= totalSteps) {
        // Show journey completed dialog
        showJourneyCompletedDialog = true;
        _journeyCompletedController.play();
      } else {
        // Assign next task
        _assignNewTask();
      }
    });
    
    // Save the updated data
    _saveData();
    
    // Show confetti effect
    _confettiController.play();
  }

  void _skipTask() {
    final today = _formatDateKey(_selectedDay);
    
    setState(() {
      // Mark as missed
      _missedTasks[today] = true;
      
      // Assign next task
      _assignNewTask();
    });
    
    // Save the updated data
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Self-Care Journey ${journeyCount > 1 ? '- #$journeyCount' : ''}",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First time welcome card
                  _buildWelcomeCard(),
                  
                  SizedBox(height: 20),
                  
                  // Calendar section
                  _buildCalendarSection(),
                  
                  SizedBox(height: 20),
                  
                  // Calendar legend
                  _buildCalendarLegend(),
                  
                  SizedBox(height: 20),
                  
                  // Progress roadmap
                  _buildRoadmapSection(),
                  
                  SizedBox(height: 25),
                  
                  // Current task card
                  _buildCurrentTaskCard(),
                  
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
          
          // Confetti overlay for task completion
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14 / 2,
              maxBlastForce: 5,
              minBlastForce: 1,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              colors: [
                Colors.red,
                Colors.green,
                Colors.yellow,
                Colors.blue,
                Colors.pink,
                Colors.purple,
              ],
            ),
          ),
          
          // Journey completed overlay
          if (showJourneyCompletedDialog)
            _buildJourneyCompletedOverlay(),
        ],
      ),
    );
  }

  Widget _buildJourneyCompletedOverlay() {
    return Stack(
      children: [
        // Semi-transparent backdrop
        Container(
          color: Colors.black.withOpacity(0.7),
          width: double.infinity,
          height: double.infinity,
        ),
        
        // Confetti
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _journeyCompletedController,
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 7,
            minBlastForce: 3,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.1,
            colors: [
              Colors.red,
              Colors.green,
              Colors.yellow,
              Colors.blue,
              Colors.pink,
              Colors.purple,
              Colors.orange,
              Colors.teal,
            ],
          ),
        ),
        
        // Congratulations dialog
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.celebration,
                  color: primaryColor,
                  size: 60,
                ),
                SizedBox(height: 20),
                Text(
                  "Congratulations!",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "You've completed your 25-day self-care journey! Taking small steps each day has made a significant impact on your wellbeing.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: _startNewJourney,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  ),
                  child: Text(
                    "Start New Journey",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  journeyCount > 1 
                    ? "Welcome to Journey #$journeyCount!" 
                    : "Welcome to your Self-Care Journey!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            "Complete one self-care task each day to advance on your journey. Each small step contributes to your overall wellbeing.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 15),
          
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Calendar",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 15),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              selectedDecoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: primaryColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: Icon(Icons.chevron_left, color: primaryColor),
              rightChevronIcon: Icon(Icons.chevron_right, color: primaryColor),
            ),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                final dateKey = _formatDateKey(date);
                final completed = _completedTasks[dateKey] ?? false;
                final missed = _missedTasks[dateKey] ?? false;
                
                if (!completed && !missed) return null;
                
                return Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: completed ? primaryColor : Colors.red[300],
                  ),
                );
              },
              // Customize day cells
              defaultBuilder: (context, day, focusedDay) {
                final dateKey = _formatDateKey(day);
                final completed = _completedTasks[dateKey] ?? false;
                final missed = _missedTasks[dateKey] ?? false;
                
                if (completed) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                  );
                } else if (missed) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red[300]!, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: Colors.red[300]),
                      ),
                    ),
                  );
                }
                
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor,
          ),
        ),
        SizedBox(width: 5),
        Text(
          "Completed",
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 12,
          ),
        ),
        SizedBox(width: 20),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red[300],
          ),
        ),
        SizedBox(width: 5),
        Text(
          "Missed",
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRoadmapSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Your Progress",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              if (journeyCount > 1)
                Text(
                  "Journey #$journeyCount",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: primaryColor.withOpacity(0.7),
                  ),
                ),
            ],
          ),
          SizedBox(height: 15),
          LinearPercentIndicator(
            percent: progressValue,
            lineHeight: 14.0,
            barRadius: Radius.circular(7),
            progressColor: primaryColor,
            backgroundColor: primaryColor.withOpacity(0.2),
            animation: true,
            animationDuration: 1000,
            padding: EdgeInsets.zero,
          ),
          SizedBox(height: 10),
          Center(
            child: Text(
              "$stepsCompleted of $totalSteps steps completed",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTaskCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor.withOpacity(0.9), primaryColor],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              currentTaskCategory,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 15),
          Text(
            currentTaskTitle,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          SizedBox(height: 10),
          Text(
            currentTaskDescription,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: _skipTask,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Skip Today",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: _markTaskComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  "Mark Complete",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}