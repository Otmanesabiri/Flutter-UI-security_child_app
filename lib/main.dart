import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path_package;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math'; // Add this import for min function

// Import our new screens
import 'screens/alert_details_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/community_screen.dart';
import 'screens/safety_education_screen.dart';

// Global variables
List<CameraDescription> cameras = [];
Database? database;
SharedPreferences? prefs;
bool isInitialized = false;
String? initError;

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Request camera permission - simplified for web
    if (!kIsWeb) {
      var status = await Permission.camera.request();
      if (status.isGranted) {
        try {
          cameras = await availableCameras();
          if (kDebugMode) {
            print('Found ${cameras.length} cameras');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error initializing cameras: $e');
          }
          initError = 'Camera error: $e';
        }
      } else {
        if (kDebugMode) {
          print('Camera permission denied');
        }
        initError = 'Camera permission denied';
      }
    } else {
      // Web - try to get cameras without permission request
      try {
        cameras = await availableCameras();
      } catch (e) {
        if (kDebugMode) {
          print('Error initializing cameras on web: $e');
        }
      }
    }

    // Initialize shared preferences
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (e) {
      if (kDebugMode) {
        print('Shared preferences error: $e');
      }
      initError = 'Shared preferences error: $e';
    }

    // Initialize database - skip for web
    if (!kIsWeb) {
      try {
        database = await openDatabase(
          path_package.join(await getDatabasesPath(), 'security_database.db'),
          onCreate: (db, version) {
            return db.execute(
              'CREATE TABLE alerts(id INTEGER PRIMARY KEY, object TEXT, timestamp TEXT, confidence REAL, location TEXT)',
            );
          },
          version: 1,
        );
      } catch (e) {
        if (kDebugMode) {
          print('Database error: $e');
        }
        initError = 'Database error: $e';
      }
    }

    isInitialized = true;
  } catch (e) {
    if (kDebugMode) {
      print('Initialization error: $e');
    }
    initError = 'Initialization error: $e';
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Child Security',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: isInitialized ? const SecurityApp() : const InitializingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Add a loading screen
class InitializingScreen extends StatelessWidget {
  const InitializingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              initError ?? 'Initializing app...',
              style: TextStyle(
                color: initError != null ? Colors.red : Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 5,
            ),
            if (initError != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SecurityApp()),
                    );
                  },
                  child: const Text('Continue Anyway'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SecurityApp extends StatefulWidget {
  const SecurityApp({super.key});

  @override
  State<SecurityApp> createState() => _SecurityAppState();
}

class _SecurityAppState extends State<SecurityApp>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _detectionActive = false;
  bool _isRecording = false;
  final Set<String> _dangerousObjects = {
    "knife",
    "scissors",
    "gun",
    "bottle",
    "cell phone"
  };
  double _confidenceThreshold = 0.5;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  String? _cameraError;
  List<Map<String, dynamic>> _alerts = [];
  int _selectedCameraIndex = 0; // Add this variable for camera selection

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Changed from 3 to 4
    _loadSettings();
    _loadAlerts();
    // Don't block UI thread with camera initialization
    Future.delayed(Duration.zero, _initCamera);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Security'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.videocam), text: 'Caméra'),
            Tab(icon: Icon(Icons.warning), text: 'Alertes'),
            Tab(icon: Icon(Icons.people), text: 'Communauté'),
            Tab(icon: Icon(Icons.cast_for_education), text: 'Education'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Camera Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(child: _buildCameraPreview()),
                const SizedBox(height: 16),
                // Display confidence threshold value
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Seuil de confiance: ${(_confidenceThreshold * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _toggleDetection,
                      icon: Icon(_detectionActive
                          ? Icons.visibility_off
                          : Icons.visibility),
                      label: Text(_detectionActive
                          ? 'Arrêter détection'
                          : 'Démarrer détection'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _toggleRecording,
                      icon: Icon(_isRecording
                          ? Icons.stop
                          : Icons.fiber_manual_record),
                      label: Text(_isRecording
                          ? 'Arrêter enregistrement'
                          : 'Enregistrer'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _showCameraSelectionDialog(context),
                  icon: const Icon(Icons.cameraswitch),
                  label: const Text('Changer de caméra'),
                ),
              ],
            ),
          ),
          // Alerts Tab
          _buildAlertsTab(),
          // Community Tab (placeholder)
          const CommunityScreen(),
          // Education Tab
          const SafetyEducationScreen(),
        ],
      ),
    );
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) {
      setState(() {
        _cameraError = "No cameras available";
      });
      return;
    }

    try {
      // Use the selected camera index (with bounds checking)
      final cameraIndex =
          _selectedCameraIndex < cameras.length ? _selectedCameraIndex : 0;

      _cameraController = CameraController(
        cameras[cameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _cameraError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cameraError = "Camera error: $e";
        });
      }
      if (kDebugMode) {
        print('Error initializing camera: $e');
      }
    }
  }

  Future<void> _switchCamera(int index) async {
    if (index == _selectedCameraIndex || index >= cameras.length) {
      return;
    }

    // Save the new camera index
    setState(() {
      _selectedCameraIndex = index;
      _isCameraInitialized = false;
    });

    // Dispose of current camera controller
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
    }

    // Initialize with new camera
    await _initCamera();

    // Save selection to preferences
    if (prefs != null) {
      await prefs!.setInt('selectedCameraIndex', index);
    }
  }

  Future<void> _loadSettings() async {
    if (prefs == null) {
      if (kDebugMode) {
        print('SharedPreferences not initialized');
      }
      return;
    }

    _confidenceThreshold = prefs!.getDouble('confidenceThreshold') ?? 0.5;
    _selectedCameraIndex =
        prefs!.getInt('selectedCameraIndex') ?? 0; // Load camera selection
    final dangerList = prefs!.getStringList('dangerousObjects');
    if (dangerList != null && dangerList.isNotEmpty) {
      _dangerousObjects.clear();
      _dangerousObjects.addAll(dangerList);
    }
  }

  Future<void> _loadAlerts() async {
    if (database == null) {
      if (kDebugMode) {
        print('Database not initialized');
      }
      setState(() {
        _alerts = [];
      });
      return;
    }

    try {
      final List<Map<String, dynamic>> alertsList =
          await database!.query('alerts');
      setState(() {
        _alerts = alertsList;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading alerts: $e');
      }
      setState(() {
        _alerts = [];
      });
    }
  }

  void _toggleDetection() {
    setState(() {
      _detectionActive = !_detectionActive;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Detection: ${_detectionActive ? 'ON' : 'OFF'}')),
    );
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${_isRecording ? 'Started' : 'Stopped'} recording')),
    );
  }

  // New method to handle camera preview with better error states
  Widget _buildCameraPreview() {
    if (_cameraError != null) {
      // Show error message if camera failed
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _cameraError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _initCamera,
                  child: const Text("Retry Camera"),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showCameraSelectionDialog(context),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Select Camera"),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (!_isCameraInitialized) {
      // Show loading indicator while initializing
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Initializing camera..."),
          ],
        ),
      );
    } else {
      // Show camera preview when ready
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CameraPreview(_cameraController!),
      );
    }
  }

  // New method to show camera selection dialog
  void _showCameraSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Camera'),
        content: SizedBox(
          width: double.maxFinite,
          height: 200, // Fixed height
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: cameras.length,
            itemBuilder: (context, index) {
              final camera = cameras[index];
              final isSelected = index == _selectedCameraIndex;
              String cameraName = 'Camera ${index + 1}';

              // Add more descriptive names based on lens direction
              if (camera.lensDirection == CameraLensDirection.front) {
                cameraName += ' (Front)';
              } else if (camera.lensDirection == CameraLensDirection.back) {
                cameraName += ' (Back)';
              } else if (camera.lensDirection == CameraLensDirection.external) {
                cameraName += ' (External)';
              }

              return ListTile(
                title: Text(cameraName),
                subtitle: Text('${camera.sensorOrientation}° - ${camera.name}'),
                leading: Icon(
                  camera.lensDirection == CameraLensDirection.front
                      ? Icons.person
                      : camera.lensDirection == CameraLensDirection.back
                          ? Icons.camera_rear
                          : Icons.camera_alt,
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                selected: isSelected,
                onTap: () {
                  Navigator.pop(context);
                  _switchCamera(index);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsTab() {
    // Premium subscription simulation - in a real app, this would come from a user account
    final bool isPremiumUser = prefs?.getBool('isPremiumUser') ?? false;
    final String subscriptionTier =
        prefs?.getString('subscriptionTier') ?? 'Free';

    return Column(
      children: [
        // Premium status indicator
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: isPremiumUser ? Colors.amber.shade100 : Colors.grey.shade100,
          child: Row(
            children: [
              Icon(
                isPremiumUser ? Icons.workspace_premium : Icons.info_outline,
                color: isPremiumUser ? Colors.amber.shade800 : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isPremiumUser
                    ? 'Plan $subscriptionTier - Alertes et analyses avancées'
                    : 'Version gratuite - Alertes basiques',
                style: TextStyle(
                  color: isPremiumUser
                      ? Colors.amber.shade800
                      : Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (!isPremiumUser)
                TextButton(
                  onPressed: _showSubscriptionOptions,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Passer Premium'),
                ),
            ],
          ),
        ),

        // Alert analytics for premium users
        if (isPremiumUser)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Analyse des alertes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAnalyticItem(
                        'Alertes', '${_alerts.length}', Icons.warning),
                    _buildAnalyticItem('Aujourd\'hui', '3', Icons.today),
                    _buildAnalyticItem('Cette semaine', '12', Icons.date_range),
                    _buildAnalyticItem('Objets', '${_dangerousObjects.length}',
                        Icons.category),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _showDetailedAnalytics,
                    icon: const Icon(Icons.analytics, size: 16),
                    label: const Text('Analyses détaillées'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Alert settings button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text(
                'Historique des alertes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: _showAlertPreferences,
                tooltip: 'Préférences d\'alertes',
              ),
            ],
          ),
        ),

        // Existing alerts list with enriched information
        Expanded(
          child: _alerts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications_off,
                          color: Colors.grey, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucune alerte enregistrée',
                        style: TextStyle(color: Colors.grey),
                      ),
                      if (!isPremiumUser)
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: ElevatedButton.icon(
                            onPressed: _showSubscriptionOptions,
                            icon: const Icon(Icons.workspace_premium),
                            label: const Text('Débloquer historique illimité'),
                          ),
                        ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount:
                      isPremiumUser ? _alerts.length : min(_alerts.length, 5),
                  itemBuilder: (context, index) {
                    final alert = _alerts[index];
                    // Calculate the severity level based on confidence
                    final double confidence = alert['confidence'] ?? 0.0;
                    final String severityLevel = confidence > 0.7
                        ? 'Élevé'
                        : (confidence > 0.5 ? 'Moyen' : 'Faible');
                    final Color severityColor = confidence > 0.7
                        ? Colors.red
                        : (confidence > 0.5 ? Colors.orange : Colors.yellow);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: Stack(
                          children: [
                            Icon(Icons.warning, color: severityColor, size: 32),
                            if (isPremiumUser && index < 3)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: const Icon(Icons.star,
                                      color: Colors.amber, size: 12),
                                ),
                              ),
                          ],
                        ),
                        title: Row(
                          children: [
                            Text(alert['object'] ?? 'Unknown'),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: severityColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                severityLevel,
                                style: TextStyle(
                                  color: severityColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${alert['timestamp'] ?? 'No timestamp'}'),
                            Text(
                                'Confiance: ${(confidence).toStringAsFixed(2)}'),
                            if (isPremiumUser && alert['location'] != null)
                              Text('Lieu: ${alert['location']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isPremiumUser)
                              IconButton(
                                icon: const Icon(Icons.share, size: 20),
                                onPressed: () => _shareAlert(alert),
                                tooltip: 'Partager',
                              ),
                            IconButton(
                              icon:
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                              onPressed: () => _navigateToAlertDetails(alert),
                            ),
                          ],
                        ),
                        isThreeLine: isPremiumUser,
                        onTap: () => _navigateToAlertDetails(alert),
                      ),
                    );
                  },
                ),
        ),

        // Free vs Premium limitations notice
        if (!isPremiumUser && _alerts.length > 5)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.lock, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Passez au premium pour débloquer l\'historique complet et les analyses détaillées',
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

        // Bottom action buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: _exportAlerts,
                icon: const Icon(Icons.download),
                label: const Text('Exporter les alertes'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),
              if (isPremiumUser)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ElevatedButton.icon(
                    onPressed: _generateSafetyReport,
                    icon: const Icon(Icons.assessment),
                    label: const Text('Générer un rapport de sécurité'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to build analytic items
  Widget _buildAnalyticItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  // Show subscription options
  void _showSubscriptionOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Text(
                    'Options d\'abonnement',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Débloquez toutes les fonctionnalités avancées',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Free tier
                  _buildSubscriptionOption(
                    'Gratuit',
                    'Sécurité de base',
                    '0,00 €/mois',
                    [
                      'Détection d\'objets dangereux',
                      'Historique limité (5 alertes)',
                      'Notifications de base',
                    ],
                    [
                      'Alertes personnalisables',
                      'Rapports détaillés',
                      'Historique illimité',
                      'Analyses avancées',
                    ],
                    isCurrentPlan: !(prefs?.getBool('isPremiumUser') ?? false),
                    onTap: () {
                      // Keep free plan
                      Navigator.pop(context);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Standard tier
                  _buildSubscriptionOption(
                    'Standard',
                    'Sécurité améliorée',
                    '4,99 €/mois',
                    [
                      'Détection d\'objets dangereux',
                      'Historique illimité',
                      'Alertes personnalisables',
                      'Rapports mensuels',
                    ],
                    [
                      'Analyses en temps réel',
                      'Support prioritaire',
                      'Partage familial',
                    ],
                    isCurrentPlan:
                        (prefs?.getString('subscriptionTier') ?? '') ==
                            'Standard',
                    isRecommended: true,
                    onTap: () => _upgradeToPremium('Standard'),
                  ),

                  const SizedBox(height: 16),

                  // Premium tier
                  _buildSubscriptionOption(
                    'Premium',
                    'Sécurité maximale',
                    '9,99 €/mois',
                    [
                      'Toutes les fonctionnalités Standard',
                      'Analyses en temps réel',
                      'Rapports hebdomadaires',
                      'Support prioritaire 24/7',
                      'Partage familial (jusqu\'à 5 appareils)',
                    ],
                    [],
                    isCurrentPlan:
                        (prefs?.getString('subscriptionTier') ?? '') ==
                            'Premium',
                    onTap: () => _upgradeToPremium('Premium'),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    '✓ Annulez à tout moment ✓ Remboursement sous 7 jours',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build subscription option card
  Widget _buildSubscriptionOption(
    String title,
    String subtitle,
    String price,
    List<String> features,
    List<String> missingFeatures, {
    bool isCurrentPlan = false,
    bool isRecommended = false,
    required VoidCallback onTap,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          elevation: isCurrentPlan ? 4 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isCurrentPlan ? Colors.blue : Colors.grey.shade300,
              width: isCurrentPlan ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (title != 'Gratuit')
                          const Text(
                            'Facturation mensuelle',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                const Divider(height: 24),

                // Features
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(feature)),
                        ],
                      ),
                    )),

                // Missing features
                if (missingFeatures.isNotEmpty) ...[
                  const Divider(height: 16),
                  ...missingFeatures.map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.remove_circle,
                              color: Colors.grey.shade400,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feature,
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],

                const SizedBox(height: 16),

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan ? null : onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isCurrentPlan ? Colors.grey.shade300 : Colors.blue,
                      foregroundColor:
                          isCurrentPlan ? Colors.black : Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.black,
                    ),
                    child: Text(
                      isCurrentPlan ? 'Plan actuel' : 'Choisir ce plan',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Recommended badge
        if (isRecommended)
          Positioned(
            top: -10,
            right: -10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'RECOMMANDÉ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Upgrade to premium
  void _upgradeToPremium(String tier) {
    // In a real app, this would integrate with payment processing
    setState(() {
      // Update local preferences
      prefs?.setBool('isPremiumUser', true);
      prefs?.setString('subscriptionTier', tier);
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Félicitations! Vous avez maintenant accès au plan $tier'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Show alert preferences dialog
  void _showAlertPreferences() {
    // Get saved preferences with defaults
    bool notifyDangerousObjects =
        prefs?.getBool('notifyDangerousObjects') ?? true;
    bool notifyUnknownPeople = prefs?.getBool('notifyUnknownPeople') ?? true;
    bool notifySafetyZoneViolations =
        prefs?.getBool('notifySafetyZoneViolations') ?? true;
    bool enableSoundAlerts = prefs?.getBool('enableSoundAlerts') ?? true;
    bool enableVibration = prefs?.getBool('enableVibration') ?? true;
    String urgencyLevel = prefs?.getString('urgencyLevel') ?? 'medium';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Préférences d\'alertes'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Types d\'alertes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SwitchListTile(
                  title: const Text('Objets dangereux'),
                  subtitle: const Text('Couteaux, ciseaux, etc.'),
                  value: notifyDangerousObjects,
                  onChanged: (value) {
                    setState(() {
                      notifyDangerousObjects = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Personnes inconnues'),
                  subtitle: const Text('Personnes non reconnues'),
                  value: notifyUnknownPeople,
                  onChanged: (prefs?.getBool('isPremiumUser') ?? false)
                      ? (value) {
                          setState(() {
                            notifyUnknownPeople = value;
                          });
                        }
                      : null,
                ),
                SwitchListTile(
                  title: const Text('Zones de sécurité'),
                  subtitle: const Text('Départs/entrées dans les zones'),
                  value: notifySafetyZoneViolations,
                  onChanged: (prefs?.getBool('isPremiumUser') ?? false)
                      ? (value) {
                          setState(() {
                            notifySafetyZoneViolations = value;
                          });
                        }
                      : null,
                ),
                const Divider(),
                const Text(
                  'Options de notification',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SwitchListTile(
                  title: const Text('Son d\'alerte'),
                  value: enableSoundAlerts,
                  onChanged: (value) {
                    setState(() {
                      enableSoundAlerts = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Vibration'),
                  value: enableVibration,
                  onChanged: (value) {
                    setState(() {
                      enableVibration = value;
                    });
                  },
                ),
                const Divider(),
                const Text(
                  'Niveau d\'urgence',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                RadioListTile<String>(
                  title: const Text('Élevé'),
                  subtitle: const Text('Toutes les alertes possibles'),
                  value: 'high',
                  groupValue: urgencyLevel,
                  onChanged: (value) {
                    setState(() {
                      urgencyLevel = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Moyen'),
                  subtitle: const Text('Alertes modérées'),
                  value: 'medium',
                  groupValue: urgencyLevel,
                  onChanged: (value) {
                    setState(() {
                      urgencyLevel = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Faible'),
                  subtitle: const Text('Alertes importantes uniquement'),
                  value: 'low',
                  groupValue: urgencyLevel,
                  onChanged: (value) {
                    setState(() {
                      urgencyLevel = value!;
                    });
                  },
                ),
                if (!((prefs?.getBool('isPremiumUser')) ?? false))
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Certaines options sont réservées aux utilisateurs premium',
                            style: TextStyle(color: Colors.blue, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                // Save preferences
                prefs?.setBool(
                    'notifyDangerousObjects', notifyDangerousObjects);
                prefs?.setBool('notifyUnknownPeople', notifyUnknownPeople);
                prefs?.setBool(
                    'notifySafetyZoneViolations', notifySafetyZoneViolations);
                prefs?.setBool('enableSoundAlerts', enableSoundAlerts);
                prefs?.setBool('enableVibration', enableVibration);
                prefs?.setString('urgencyLevel', urgencyLevel);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Préférences d\'alertes mises à jour')),
                );
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  // Show detailed analytics
  void _showDetailedAnalytics() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Text(
                    'Analyses détaillées',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // This would be implemented with real analytics data
                  // Currently showing a placeholder/mockup
                  const Text(
                    'Tendances des alertes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Text('Graphique des tendances d\'alertes'),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Objets les plus détectés',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Text('Graphique des objets dangereux'),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Heures des alertes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Text('Graphique de distribution horaire'),
                    ),
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    onPressed: _generateSafetyReport,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Générer un rapport PDF'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
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

  // Share alert with others
  void _shareAlert(Map<String, dynamic> alert) {
    // This would use a platform sharing API in a real app
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Partage de l\'alerte...')),
    );
  }

  Future<void> _exportAlerts() async {
    final directory = await getExternalStorageDirectory();
    final file = File('${directory?.path}/alerts_export.csv');

    String csvData = 'Object,Timestamp,Confidence,Location\n';
    for (var alert in _alerts) {
      csvData +=
          '${alert['object']},${alert['timestamp']},${alert['confidence']},${alert['location'] ?? "Unknown"}\n';
    }

    await file.writeAsString(csvData);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alerts exported to ${file.path}')),
    );
  }

  // Generate safety report
  void _generateSafetyReport() {
    // This would generate a PDF report in a real app
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Génération du rapport de sécurité...')),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _navigateToAlertDetails(Map<String, dynamic> alert) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlertDetailsScreen(
          alert: alert,
          database: database,
        ),
      ),
    );
  }
}
