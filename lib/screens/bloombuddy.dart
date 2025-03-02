import 'package:flutter/material.dart';

class BloomBuddy extends StatefulWidget {
  final int completedTasks;
  
  const BloomBuddy({Key? key, required this.completedTasks}) : super(key: key);

  @override
  _BloomBuddyState createState() => _BloomBuddyState();
}

class _BloomBuddyState extends State<BloomBuddy> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _growAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _growAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut)
    );
    
    // Run animation when a new task is completed
    if (widget.completedTasks > 0) {
      _controller.forward(from: 0.0);
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(BloomBuddy oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animate when task count increases
    if (widget.completedTasks > oldWidget.completedTasks) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int growthStage = (widget.completedTasks / 20).floor();
    // Calculate next growth threshold
    final int nextGrowthAt = (growthStage + 1) * 20;
    // Tasks remaining for next stage
    final int tasksRemaining = nextGrowthAt - widget.completedTasks;
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Bloom Buddy', style: TextStyle(color: Colors.white),),
        leading: Icon(Icons.arrow_back, color: Colors.white,),
        backgroundColor: Color(0xFF863668),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightBlue[100]!, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tasks Completed: ${widget.completedTasks}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Growth Stage: $growthStage',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF863668),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _growAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _growAnimation.value,
                    child: PlantWidget(completedTasks: widget.completedTasks),
                  );
                }
              ),
              const SizedBox(height: 40),
              Text(
                'Next growth in: $tasksRemaining tasks',
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 10),
              // Progress indicator for current stage
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: LinearProgressIndicator(
                  value: (widget.completedTasks % 25) / 25,
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF863668)),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 20),
              _buildPlantCareMessage(growthStage),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPlantCareMessage(int stage) {
    String message = "";
    
    switch (stage) {
      case 0:
        message = "Your seed is just beginning its journey. Keep nurturing it!";
        break;
      case 1:
        message = "A tiny sprout is emerging! Keep up the good work!";
        break;
      case 2:
        message = "The first leaves are appearing. Your care is making a difference!";
        break;
      case 3:
        message = "Your plant is growing taller. It's thriving with your attention!";
        break;
      case 4:
        message = "More leaves are appearing. Your plant is flourishing!";
        break;
      default:
        message = "Your plant is in full bloom! Your dedication has created something beautiful!";
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFF863668).withOpacity(0.3)),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF863668),
          ),
        ),
      ),
    );
  }
}

class PlantWidget extends StatelessWidget {
  final int completedTasks;
  final double size;

  const PlantWidget({
    Key? key,
    required this.completedTasks,
    this.size = 350,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get image number from 6 to 25 based on completed tasks
    int imageNumber = getImageNumberForTasks(completedTasks);

    // Load the image asset
    String imagePath = 'lib/assets/images/$imageNumber.png';

    return Container(
      width: size,
      height: size,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
      ),
    );
  }

  int getImageNumberForTasks(int tasks) {
    if (tasks == 0) return 6; // Starting seed image
    if (tasks == 1) return 7;

    // Cap at 20 tasks for image selection purposes
    int capped = tasks > 20 ? 20 : tasks;

    // Calculate which image to show based on tasks completed
    int imageOffset = ((capped - 1) * 19 / 19).floor(); // Scale tasks to 0–19 range
    int imageNumber = 6 + imageOffset;

    // Ensure we don't exceed image 25
    return imageNumber > 25 ? 25 : imageNumber;
  }
}