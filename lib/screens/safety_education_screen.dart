import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SafetyEducationScreen extends StatefulWidget {
  const SafetyEducationScreen({Key? key}) : super(key: key);

  @override
  State<SafetyEducationScreen> createState() => _SafetyEducationScreenState();
}

class _SafetyEducationScreenState extends State<SafetyEducationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  VideoPlayerController? _videoController;
  final bool _isVideoInitialized = false;
  int _selectedAgeGroup = 1; // 0: 3-6, 1: 7-10, 2: 11+

  final List<Map<String, dynamic>> _safetyLessons = [
    {
      'title': 'Stranger Danger',
      'description': 'Learn about staying safe around strangers',
      'thumbnail': 'assets/thumbnails/stranger_danger.jpg',
      'videoUrl': 'https://example.com/videos/stranger_danger.mp4',
      'icon': Icons.person_off,
      'color': Colors.orange,
      'ageGroups': [0, 1, 2],
    },
    {
      'title': 'Household Hazards',
      'description': 'Identify dangerous objects at home',
      'thumbnail': 'assets/thumbnails/household_hazards.jpg',
      'videoUrl': 'https://example.com/videos/household_hazards.mp4',
      'icon': Icons.home,
      'color': Colors.red,
      'ageGroups': [0, 1],
    },
    {
      'title': 'Internet Safety',
      'description': 'Stay safe online',
      'thumbnail': 'assets/thumbnails/internet_safety.jpg',
      'videoUrl': 'https://example.com/videos/internet_safety.mp4',
      'icon': Icons.computer,
      'color': Colors.blue,
      'ageGroups': [1, 2],
    },
    {
      'title': 'Fire Safety',
      'description': 'What to do in case of fire',
      'thumbnail': 'assets/thumbnails/fire_safety.jpg',
      'videoUrl': 'https://example.com/videos/fire_safety.mp4',
      'icon': Icons.local_fire_department,
      'color': Colors.deepOrange,
      'ageGroups': [0, 1, 2],
    },
    {
      'title': 'Road Safety',
      'description': 'Staying safe on the road',
      'thumbnail': 'assets/thumbnails/road_safety.jpg',
      'videoUrl': 'https://example.com/videos/road_safety.mp4',
      'icon': Icons.directions_car,
      'color': Colors.green,
      'ageGroups': [0, 1, 2],
    },
  ];

  final List<String> _ageGroups = ['3-6 Years', '7-10 Years', '11+ Years'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Education'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.auto_stories), text: 'Lessons'),
            Tab(icon: Icon(Icons.videocam), text: 'Videos'),
            Tab(icon: Icon(Icons.quiz), text: 'Quizzes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLessonsTab(),
          _buildVideosTab(),
          _buildQuizzesTab(),
        ],
      ),
    );
  }

  Widget _buildLessonsTab() {
    final filteredLessons = _safetyLessons
        .where((lesson) => lesson['ageGroups'].contains(_selectedAgeGroup))
        .toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text(
                'Age Group: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<int>(
                  value: _selectedAgeGroup,
                  isExpanded: true,
                  items: List.generate(_ageGroups.length, (index) {
                    return DropdownMenuItem<int>(
                      value: index,
                      child: Text(_ageGroups[index]),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedAgeGroup = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: filteredLessons.length,
            itemBuilder: (context, index) {
              final lesson = filteredLessons[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () => _openLesson(lesson),
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lesson image
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: lesson['color'].withOpacity(0.3),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            lesson['icon'],
                            size: 64,
                            color: lesson['color'],
                          ),
                        ),
                      ),
                      // Lesson details
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lesson['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              lesson['description'],
                              style: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  children: (lesson['ageGroups'] as List<int>)
                                      .map((ageGroupIndex) => Chip(
                                            label:
                                                Text(_ageGroups[ageGroupIndex]),
                                            backgroundColor:
                                                Colors.blue.shade100,
                                          ))
                                      .toList(),
                                ),
                                ElevatedButton(
                                  onPressed: () => _openLesson(lesson),
                                  child: const Text('Start Lesson'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideosTab() {
    return _isVideoInitialized && _videoController != null
        ? Column(
            children: [
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
              VideoProgressIndicator(
                _videoController!,
                allowScrubbing: true,
                padding: const EdgeInsets.all(16.0),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _videoController!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        _videoController!.value.isPlaying
                            ? _videoController!.pause()
                            : _videoController!.play();
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.replay_10, size: 32),
                    onPressed: () {
                      _videoController!.seekTo(Duration(
                          seconds:
                              _videoController!.value.position.inSeconds - 10));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.forward_10, size: 32),
                    onPressed: () {
                      _videoController!.seekTo(Duration(
                          seconds:
                              _videoController!.value.position.inSeconds + 10));
                    },
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _safetyLessons.length,
                  itemBuilder: (context, index) {
                    final lesson = _safetyLessons[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: lesson['color'].withOpacity(0.3),
                        child: Icon(lesson['icon'], color: lesson['color']),
                      ),
                      title: Text(lesson['title']),
                      subtitle: Text(lesson['description']),
                      trailing: const Icon(Icons.play_circle_fill),
                      onTap: () => _playVideo(lesson['videoUrl']),
                    );
                  },
                ),
              ),
            ],
          )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.videocam, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Select a video to play',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _safetyLessons.length,
                    itemBuilder: (context, index) {
                      final lesson = _safetyLessons[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: lesson['color'].withOpacity(0.3),
                            child: Icon(lesson['icon'], color: lesson['color']),
                          ),
                          title: Text(lesson['title']),
                          subtitle: Text(lesson['description']),
                          trailing: const Icon(Icons.play_circle_fill),
                          onTap: () => _playVideo(lesson['videoUrl']),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildQuizzesTab() {
    return Center(
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Test Your Knowledge',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Quiz cards
          _buildQuizCard(
            title: 'Stranger Danger Quiz',
            description: '5 questions about stranger safety',
            icon: Icons.person_off,
            color: Colors.orange,
            questionCount: 5,
            completionRate: 0.0,
          ),
          _buildQuizCard(
            title: 'Home Safety Quiz',
            description: '8 questions about home safety',
            icon: Icons.home,
            color: Colors.red,
            questionCount: 8,
            completionRate: 0.75,
          ),
          _buildQuizCard(
            title: 'Fire Safety Quiz',
            description: '6 questions about fire safety',
            icon: Icons.local_fire_department,
            color: Colors.deepOrange,
            questionCount: 6,
            completionRate: 1.0,
          ),
          _buildQuizCard(
            title: 'Internet Safety Quiz',
            description: '10 questions about online safety',
            icon: Icons.computer,
            color: Colors.blue,
            questionCount: 10,
            completionRate: 0.3,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required int questionCount,
    required double completionRate,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _startQuiz(title),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: color.withOpacity(0.3),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: completionRate,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${(completionRate * 100).toInt()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$questionCount questions',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _startQuiz(title),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      completionRate == 1.0 ? 'Retry Quiz' : 'Start Quiz',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openLesson(Map<String, dynamic> lesson) {
    // This would open a detailed lesson view
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(lesson['title']),
          ),
          body: const Center(
            child: Text('Detailed lesson content will be displayed here'),
          ),
        ),
      ),
    );
  }

  Future<void> _playVideo(String videoUrl) async {
    // In a real app, you would initialize and play the video
    // For this example, we'll just show a placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing video: $videoUrl'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _startQuiz(String quizTitle) {
    // This would navigate to a quiz screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(quizTitle),
          ),
          body: const Center(
            child: Text('Quiz questions will be displayed here'),
          ),
        ),
      ),
    );
  }
}
