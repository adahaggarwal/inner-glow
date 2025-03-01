import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/services.dart';

class SleepCrisisScreen extends StatefulWidget {
  @override
  _SleepCrisisScreenState createState() => _SleepCrisisScreenState();
}

class _SleepCrisisScreenState extends State<SleepCrisisScreen> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _selectedMood;
  int _currentTrackIndex = 0;
  double _volume = 0.8;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  late AnimationController _animationController;
  
  // Define mood-based music with multiple tracks per mood
  final Map<String, MoodMusic> moodMusic = {
    "Calm": MoodMusic(
      tracks: [
        Track(
          url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
          title: "Gentle Piano",
        ),
        Track(
          url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3",
          title: "Ocean Waves",
        ),
        Track(
          url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3",
          title: "Night Forest",
        ),
      ],
      color: Color(0xFF4A78E6),
      icon: Icons.nightlight_round,
      description: "Gentle melodies to help you relax and drift to sleep",
    ),
    "Anxious": MoodMusic(
      tracks: [
        Track(
          url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
          title: "Ambient Flow",
        ),
        Track(
          url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3",
          title: "Deep Breathing",
        ),
        Track(
          url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-13.mp3",
          title: "Calm Meditation",
        ),
      ],
      color: Color(0xFF8E74BF),
      icon: Icons.healing,
      description: "Soothing ambient sounds to reduce anxiety and worry",
    ),
    "Sad": MoodMusic(
      tracks: [
        Track(
          url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
          title: "Gentle Rain",
        ),
        Track(
          url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3",
          title: "Distant Thunder",
        ),
        Track(
          url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-16.mp3",
          title: "Comforting Strings",
        ),
      ],
      color: Color(0xFF40A0D0),
      icon: Icons.water_drop,
      description: "Comforting melodies with gentle rainfall in the background",
    ),
    "Restless": MoodMusic(
      tracks: [
        Track(
          url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3",
          title: "White Noise",
        ),
        Track(
          url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3",
          title: "Forest Night",
        ),
        Track(
          url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-14.mp3",
          title: "Steady Beats",
        ),
      ],
      color: Color(0xFF6AA687),
      icon: Icons.waves,
      description: "Rhythmic white noise with subtle forest ambience",
    ),
    "Lonely": MoodMusic(
      tracks: [
        Track(
          url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3",
          title: "Warm Soundscape",
        ),
        Track(
          url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3",
          title: "Celestial Tones",
        ),
        Track(
          url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-15.mp3",
          title: "Companionship",
        ),
      ],
      color: Color(0xFFE67C4A),
      icon: Icons.stars,
      description: "Warm, embracing soundscape with distant celestial tones",
    ),
  };

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat();
  }

  Future<void> _initAudioPlayer() async {
    // Configure the audio session for background playback
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
    
    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _audioPlayer.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration ?? Duration.zero;
        });
      }
    });

    _audioPlayer.playerStateStream.listen((playerState) {
      if (mounted) {
        setState(() {
          _isPlaying = playerState.playing;
        });
      }
    });
  }

  Future<void> _playMusic(String mood, {int trackIndex = 0}) async {
    try {
      HapticFeedback.mediumImpact();
      
      setState(() {
        _selectedMood = mood;
        _currentTrackIndex = trackIndex;
      });
      
      await _audioPlayer.stop();
      await _audioPlayer.setUrl(moodMusic[mood]!.tracks[trackIndex].url);
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.play();
    } catch (e) {
      print("Error playing music: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to play music for $mood")),
      );
    }
  }

  Future<void> _changeTrack(int direction) async {
    if (_selectedMood == null) return;
    
    final tracks = moodMusic[_selectedMood!]!.tracks;
    int newIndex = (_currentTrackIndex + direction) % tracks.length;
    if (newIndex < 0) newIndex = tracks.length - 1;
    
    await _playMusic(_selectedMood!, trackIndex: newIndex);
  }

  void _togglePlayPause() {
    if (_selectedMood == null) return;
    
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212), 
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Sleep Crisis Mode", 
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _selectedMood != null 
              ? [moodMusic[_selectedMood]!.color.withOpacity(0.8), Color(0xFF121212)]
              : [Color(0xFF2A2A2A), Color(0xFF121212)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Card(
                    color: Colors.black.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            "How are you feeling tonight?",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                          SizedBox(height: 24),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: moodMusic.keys.map((mood) {
                              final isSelected = _selectedMood == mood;
                              return AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _playMusic(mood),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16, 
                                        vertical: 12
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                          ? moodMusic[mood]!.color 
                                          : moodMusic[mood]!.color.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected 
                                            ? Colors.white 
                                            : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            moodMusic[mood]!.icon,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            mood,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  _selectedMood != null
                    ? _buildMusicPlayerCard()
                    : _buildWelcomeMessage(),
                    
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildWelcomeMessage() {
    return Container(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.nightlight_round, 
              size: 80, 
              color: Colors.white.withOpacity(0.5),
            ),
            SizedBox(height: 24),
            Text(
              "Select a mood to play calming music\nthat helps you sleep better",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicPlayerCard() {
    if (_selectedMood == null) return Container();
    
    final currentMood = moodMusic[_selectedMood]!;
    final currentTrack = currentMood.tracks[_currentTrackIndex];
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  center: Alignment.center,
                  startAngle: 0,
                  endAngle: 3.14 * 2,
                  colors: [
                    currentMood.color,
                    currentMood.color.withOpacity(0.3),
                    currentMood.color,
                  ],
                  transform: GradientRotation(_animationController.value * 3.14 * 2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: currentMood.color.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    currentMood.icon,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }
        ),
        SizedBox(height: 32),
        Text(
          _selectedMood!,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          currentMood.description,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 16),
        
        // Track selection
        Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous, color: Colors.white70),
                onPressed: () => _changeTrack(-1),
                iconSize: 24,
              ),
              SizedBox(width: 8),
              Text(
                currentTrack.title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.skip_next, color: Colors.white70),
                onPressed: () => _changeTrack(1),
                iconSize: 24,
              ),
            ],
          ),
        ),
        
        SizedBox(height: 24),
        
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
                  activeTrackColor: currentMood.color,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: Colors.white,
                  overlayColor: currentMood.color.withOpacity(0.3),
                ),
                child: Slider(
                  min: 0.0,
                  max: _duration.inMilliseconds.toDouble() > 0 
                    ? _duration.inMilliseconds.toDouble() 
                    : 1.0,
                  value: _position.inMilliseconds.toDouble().clamp(
                    0, _duration.inMilliseconds.toDouble() > 0 
                      ? _duration.inMilliseconds.toDouble() 
                      : 1.0
                  ),
                  onChanged: (value) {
                    _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 16),
        
        // Player controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.volume_down),
              color: Colors.white70,
              iconSize: 28,
              onPressed: () {
                setState(() {
                  _volume = (_volume - 0.1).clamp(0.0, 1.0);
                  _audioPlayer.setVolume(_volume);
                });
              },
            ),
            SizedBox(width: 16),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentMood.color,
              ),
              child: IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                color: Colors.white,
                iconSize: 36,
                onPressed: _togglePlayPause,
              ),
            ),
            SizedBox(width: 16),
            IconButton(
              icon: Icon(Icons.volume_up),
              color: Colors.white70,
              iconSize: 28,
              onPressed: () {
                setState(() {
                  _volume = (_volume + 0.1).clamp(0.0, 1.0);
                  _audioPlayer.setVolume(_volume);
                });
              },
            ),
          ],
        ),
        
        SizedBox(height: 24),
        
        // Volume indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Row(
            children: [
              Icon(
                Icons.volume_mute, 
                color: Colors.white54, 
                size: 16
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                    activeTrackColor: currentMood.color,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    min: 0.0,
                    max: 1.0,
                    value: _volume,
                    onChanged: (value) {
                      setState(() {
                        _volume = value;
                        _audioPlayer.setVolume(_volume);
                      });
                    },
                  ),
                ),
              ),
              Icon(
                Icons.volume_up, 
                color: Colors.white54, 
                size: 16
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

// Track class to store information about each audio track
class Track {
  final String url;
  final String title;
  
  Track({
    required this.url,
    required this.title,
  });
}

// Class to store mood-related information
class MoodMusic {
  final List<Track> tracks;
  final Color color;
  final IconData icon;
  final String description;
  
  MoodMusic({
    required this.tracks,
    required this.color,
    required this.icon,
    required this.description,
  });
}