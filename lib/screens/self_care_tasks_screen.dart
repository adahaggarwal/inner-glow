import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:innerglow/screens/bloombuddy.dart';

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
  Map<String, bool> _missedTasks = {};

  // Current task details
  String currentTaskTitle = "Take 5 deep breaths";
  String currentTaskCategory = "Mindfulness & Relaxation";
  String currentTaskDescription = "Find a quiet space, sit comfortably, and take 5 slow, deep breaths. Focus on your breathing.";

  // Progress on the roadmap (0 to 1)
  double progressValue = 0.0;
  int stepsCompleted = 0;
  int totalSteps = 20;
  int journeyCount = 1;
  bool showJourneyCompletedDialog = false;

  // Total lifetime completed tasks for BloomBuddy
  int totalLifetimeCompleted = 0;

  // Primary color from hex code 863668
  final Color primaryColor = const Color(0xFF863668);

  // Animation controller for plant growth
  bool showPlantGrowthAnimation = false;

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
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _journeyCompletedController = ConfettiController(duration: const Duration(seconds: 5));
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

      // Load total lifetime completed tasks for BloomBuddy
      totalLifetimeCompleted = prefs.getInt('totalLifetimeCompleted') ?? 0;

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

    // Save total lifetime completed tasks for BloomBuddy
    await prefs.setInt('totalLifetimeCompleted', totalLifetimeCompleted);

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
      final day = today.subtract(Duration(days: i));
      final dateKey = _formatDateKey(day);

      if (!_completedTasks.containsKey(dateKey)) {
        _missedTasks[dateKey] = true;
      }
    }
  }

  // Assign a new task
  void _assignNewTask() {
    final category = taskCategories.keys.toList()[DateTime.now().day % taskCategories.length];
    final tasks = taskCategories[category]!;
    final randomIndex = DateTime.now().microsecond % tasks.length;

    setState(() {
      currentTaskTitle = tasks[randomIndex];
      currentTaskCategory = category;
      currentTaskDescription = "Complete this task to advance on your self-care journey.";
    });
  }
  // Build calendar section
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
          offset: const Offset(0, 2),
        ),
      ],
    ),
    padding: const EdgeInsets.all(15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your Calendar",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
        ),
        const SizedBox(height: 15),
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            }
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarStyle: CalendarStyle(
            isTodayHighlighted: true,
            selectedDecoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: primaryColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              final dateKey = _formatDateKey(date);
              final isCompleted = _completedTasks[dateKey] == true;
              final isMissed = _missedTasks[dateKey] == true;

              if (isCompleted || isMissed) {
                return Positioned(
                  right: 1,
                  bottom: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? Colors.green : Colors.red,
                    ),
                    width: 8,
                    height: 8,
                  ),
                );
              }
              return null;
            },
            defaultBuilder: (context, day, focusedDay) {
              final dateKey = _formatDateKey(day);
              final isCompleted = _completedTasks[dateKey] == true;
              final isMissed = _missedTasks[dateKey] == true;

              if (isCompleted || isMissed) {
                return Container(
                  margin: const EdgeInsets.all(6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                  ),
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: isCompleted ? Colors.green[700] : Colors.red[700],
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

  // Complete a task
  void _completeTask() {
    final today = _formatDateKey(_selectedDay);

    setState(() {
      _completedTasks[today] = true;
      _missedTasks.remove(today);
      stepsCompleted++;
      totalLifetimeCompleted++;
      progressValue = stepsCompleted / totalSteps;

      if (progressValue >= 1.0) {
        showJourneyCompletedDialog = true;
        _journeyCompletedController.play();
      } else {
        _assignNewTask();
      }

      // Trigger plant growth animation
      showPlantGrowthAnimation = true;
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          showPlantGrowthAnimation = false;
        });
      });

      // Play confetti animation
      _confettiController.play();
    });

    _saveData();
  }

  // Skip a task
  void _skipTask() {
    final today = _formatDateKey(_selectedDay);

    setState(() {
      _missedTasks[today] = true;
      _assignNewTask();
    });

    _saveData();
  }

  // Navigate to BloomBuddy screen
  void _navigateToBloomBuddy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BloomBuddy(completedTasks: totalLifetimeCompleted),
      ),
    );
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
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.spa, color: primaryColor),
            tooltip: 'View your BloomBuddy',
            onPressed: _navigateToBloomBuddy,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(),
                  const SizedBox(height: 20),
                  _buildBloomBuddyPreview(),
                  const SizedBox(height: 20),
                  _buildCalendarSection(),
                  const SizedBox(height: 20),
                  _buildCalendarLegend(),
                  const SizedBox(height: 20),
                  _buildRoadmapSection(),
                  const SizedBox(height: 25),
                  _buildCurrentTaskCard(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          if (showPlantGrowthAnimation) _buildPlantGrowthAnimation(),
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
              colors: [Colors.red, Colors.green, Colors.yellow, Colors.blue, Colors.pink, Colors.purple],
            ),
          ),
          if (showJourneyCompletedDialog) _buildJourneyCompletedOverlay(),
        ],
      ),
    );
  }

  // Build plant growth animation overlay
  Widget _buildPlantGrowthAnimation() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedOpacity(
              opacity: showPlantGrowthAnimation ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 500),
              child: PlantWidget(completedTasks: totalLifetimeCompleted - 1, size: 200),
            ),
            AnimatedOpacity(
              opacity: showPlantGrowthAnimation ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.elasticOut,
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: PlantWidget(completedTasks: totalLifetimeCompleted, size: 200),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Plant Growing!",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Build BloomBuddy preview card
  Widget _buildBloomBuddyPreview() {
    return InkWell(
      onTap: _navigateToBloomBuddy,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              height: 80,
              width: 80,
              child: PlantWidget(completedTasks: totalLifetimeCompleted),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your BloomBuddy",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Growth Stage: ${(totalLifetimeCompleted / 20).floor()}",
                    style: TextStyle(fontSize: 14, color: Colors.green[700], fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Total Tasks: $totalLifetimeCompleted",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Next growth in ${20 - (totalLifetimeCompleted % 20)} tasks",
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: primaryColor),
          ],
        ),
      ),
    );
  }

  // Build journey completed overlay
  Widget _buildJourneyCompletedOverlay() {
    return Stack(
      children: [
        Container(
          color: Colors.black.withOpacity(0.7),
          width: double.infinity,
          height: double.infinity,
        ),
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
            colors: [Colors.red, Colors.green, Colors.yellow, Colors.blue, Colors.pink, Colors.purple, Colors.orange, Colors.teal],
          ),
        ),
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(24),
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
                Icon(Icons.celebration, color: primaryColor, size: 60),
                const SizedBox(height: 20),
                Text(
                  "Congratulations!",
                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 24),
                ),
                const SizedBox(height: 15),
                Text(
                  "You've completed your 20-day self-care journey! Taking small steps each day has made a significant impact on your wellbeing.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
                const SizedBox(height: 10),
                Text(
                  "Your BloomBuddy is growing stronger too!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.green[700], fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 25),
                Container(
                  height: 100,
                  child: PlantWidget(completedTasks: totalLifetimeCompleted),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: _startNewJourney,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  ),
                  child: const Text(
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

  // Start a new journey
  void _startNewJourney() {
    setState(() {
      showJourneyCompletedDialog = false;
      stepsCompleted = 0;
      progressValue = 0.0;
      journeyCount++;
      _assignNewTask();
    });

    _saveData();
  }

  // Build welcome card
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.favorite, color: primaryColor, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  journeyCount > 1 ? "Welcome to Journey #$journeyCount!" : "Welcome to your Self-Care Journey!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            "Complete one self-care task each day to advance on your journey. Each small step contributes to your overall wellbeing and helps your BloomBuddy grow!",
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  
  // Build calendar legend
  Widget _buildCalendarLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.2),
                border: Border.all(color: Colors.green, width: 2),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              "Completed",
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.2),
                border: Border.all(color: Colors.red, width: 2),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              "Missed",
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  // Build roadmap section
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Progress",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
          ),
          const SizedBox(height: 15),
          LinearPercentIndicator(
            lineHeight: 18.0,
            percent: progressValue,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            animation: true,
            animationDuration: 1000,
            backgroundColor: Colors.grey[200],
            progressColor: primaryColor,
            barRadius: const Radius.circular(10),
            center: Text(
              "${(progressValue * 100).toStringAsFixed(0)}%",
              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$stepsCompleted / $totalSteps Tasks Completed",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              Text(
                "${totalSteps - stepsCompleted} more to go",
                style: TextStyle(fontSize: 14, color: primaryColor, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build current task card
  Widget _buildCurrentTaskCard() {
    final isToday = isSameDay(_selectedDay, DateTime.now());
    final dateKey = _formatDateKey(_selectedDay);
    final isCompleted = _completedTasks[dateKey] == true;
    final isMissed = _missedTasks[dateKey] == true;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isToday ? "Today's Task" : "Task for ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.2)
                      : isMissed
                          ? Colors.red.withOpacity(0.2)
                          : Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCompleted ? "Completed" : isMissed ? "Missed" : "Pending",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isCompleted
                        ? Colors.green[700]
                        : isMissed
                            ? Colors.red[700]
                            : Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              currentTaskCategory,
              style: TextStyle(
                fontSize: 12,
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            currentTaskTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            currentTaskDescription,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 25),
          if (isToday && !isCompleted && !isMissed)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _completeTask,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text("Mark as Complete"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _skipTask,
                  icon: const Icon(Icons.skip_next),
                  label: const Text("Skip"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _journeyCompletedController.dispose();
    super.dispose();
  }
}

// Plant widget based on completed tasks
class PlantWidget extends StatelessWidget {
  final int completedTasks;
  final double size;

  const PlantWidget({
    Key? key,
    required this.completedTasks,
    this.size = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate growth stage (0 to 4)
    final stage = (completedTasks / 20).floor();
    
    // Calculate the growth percentage within the current stage (0 to 1)
    final growthInStage = (completedTasks % 20) / 20;

    return Container(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Pot
          Container(
            width: size * 0.8,
            height: size * 0.4,
            decoration: BoxDecoration(
              color: const Color(0xFFBC8F6A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(size * 0.05),
                topRight: Radius.circular(size * 0.05),
                bottomLeft: Radius.circular(size * 0.25),
                bottomRight: Radius.circular(size * 0.25),
              ),
            ),
          ),
          
          // Soil
          Positioned(
            bottom: size * 0.25,
            child: Container(
              width: size * 0.7,
              height: size * 0.1,
              decoration: BoxDecoration(
                color: const Color(0xFF5D4037),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * 0.05),
                  topRight: Radius.circular(size * 0.05),
                ),
              ),
            ),
          ),
          
          // Plant based on stage
          if (stage >= 0) 
            _buildPlantStage(stage, growthInStage),
        ],
      ),
    );
  }

  Widget _buildPlantStage(int stage, double growthInStage) {
    switch (stage) {
      case 0:
        // Seedling
        return Positioned(
          bottom: size * 0.35,
          child: Container(
            width: size * 0.1,
            height: size * 0.2 * (0.2 + growthInStage * 0.8),
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(5),
              ),
            ),
          ),
        );
      case 1:
        // Small plant
        return Positioned(
          bottom: size * 0.35,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: size * 0.6 * growthInStage,
                height: size * 0.15,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: size * 0.1,
                height: size * 0.25,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(2),
                    topRight: Radius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        );
      case 2:
        // Medium plant
        return Positioned(
          bottom: size * 0.35,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: size * 0.7 * growthInStage,
                height: size * 0.3 * growthInStage,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: size * 0.12,
                height: size * 0.3,
                decoration: const BoxDecoration(
                  color: Color(0xFF7CB342),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(3),
                    topRight: Radius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        );
      default:
        // Full bloom
        return Positioned(
          bottom: size * 0.35,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: size * 0.3,
                    height: size * 0.3,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: size * 0.35,
                    height: size * 0.35,
                    decoration: BoxDecoration(
                      color: Color(0xFF66BB6A),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: size * 0.3,
                    height: size * 0.3,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              Container(
                width: size * 0.14,
                height: size * 0.35,
                decoration: const BoxDecoration(
                  color: Color(0xFF7CB342),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}