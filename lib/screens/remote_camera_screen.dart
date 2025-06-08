import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/camera_manager.dart';

class RemoteCameraScreen extends StatefulWidget {
  final CameraManager cameraManager;

  const RemoteCameraScreen({
    Key? key,
    required this.cameraManager,
  }) : super(key: key);

  @override
  State<RemoteCameraScreen> createState() => _RemoteCameraScreenState();
}

class _RemoteCameraScreenState extends State<RemoteCameraScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _refreshRateController = TextEditingController(text: '500');

  bool _isConnecting = false;
  bool _isConnected = false;
  bool _useAuthentication = false;
  Uint8List? _currentFrame;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Check if already connected to a remote camera
    if (widget.cameraManager.isRemoteCamera) {
      _isConnected = true;
      _urlController.text = widget.cameraManager.remoteCameraUrl ?? '';

      // Setup stream listener
      widget.cameraManager.remoteFrameStream?.listen((frameData) {
        if (mounted) {
          setState(() {
            _currentFrame = frameData;
          });
        }
      });
    }

    // Listen for camera errors
    widget.cameraManager.errorStream.listen((error) {
      if (mounted) {
        setState(() {
          _errorMessage = error;
          _isConnecting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _refreshRateController.dispose();
    super.dispose();
  }

  Future<void> _connectToCamera() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.cameraManager.connectToRemoteCamera(
        url: _urlController.text,
        username: _useAuthentication ? _usernameController.text : null,
        password: _useAuthentication ? _passwordController.text : null,
        refreshRateMs: int.tryParse(_refreshRateController.text) ?? 500,
      );

      if (success) {
        setState(() {
          _isConnected = true;
          _isConnecting = false;
        });

        // Setup stream listener
        widget.cameraManager.remoteFrameStream?.listen((frameData) {
          if (mounted) {
            setState(() {
              _currentFrame = frameData;
            });
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connecté à la caméra distante')),
        );
      } else {
        setState(() {
          _isConnecting = false;
          _errorMessage = 'Échec de la connexion à la caméra';
        });
      }
    } catch (e) {
      setState(() {
        _isConnecting = false;
        _errorMessage = 'Erreur: $e';
      });
    }
  }

  void _disconnectCamera() async {
    await widget.cameraManager.stopCamera();

    if (mounted) {
      setState(() {
        _isConnected = false;
        _currentFrame = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Déconnecté de la caméra distante')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caméra Distante'),
        actions: [
          if (_isConnected)
            IconButton(
              icon: const Icon(Icons.link_off), // Changed to a valid icon
              onPressed: _disconnectCamera,
              tooltip: 'Déconnecter',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Camera preview if connected
            if (_isConnected && _currentFrame != null)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Image.memory(
                          _currentFrame!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Connecté à: ${_urlController.text}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('Actualiser'),
                            onPressed: () =>
                                widget.cameraManager.fetchRemoteFrame(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            if (!_isConnected)
              Form(
                key: _formKey,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Connexion à une caméra distante',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _urlController,
                          decoration: const InputDecoration(
                            labelText: 'URL de la caméra',
                            hintText: 'http://192.168.1.100:8080/video',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.link),
                          ),
                          keyboardType: TextInputType.url,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer l\'URL de la caméra';
                            }
                            if (!value.startsWith('http')) {
                              return 'L\'URL doit commencer par http:// ou https://';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Utiliser l\'authentification'),
                          subtitle: const Text(
                              'Activer si la caméra nécessite un nom d\'utilisateur et mot de passe'),
                          value: _useAuthentication,
                          onChanged: (value) {
                            setState(() {
                              _useAuthentication = value;
                            });
                          },
                        ),
                        if (_useAuthentication) ...[
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Nom d\'utilisateur',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (_useAuthentication &&
                                  (value == null || value.isEmpty)) {
                                return 'Veuillez entrer le nom d\'utilisateur';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Mot de passe',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.password),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (_useAuthentication &&
                                  (value == null || value.isEmpty)) {
                                return 'Veuillez entrer le mot de passe';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _refreshRateController,
                          decoration: const InputDecoration(
                            labelText: 'Taux de rafraîchissement (ms)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.timer),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un taux de rafraîchissement';
                            }
                            final rate = int.tryParse(value);
                            if (rate == null || rate < 100 || rate > 5000) {
                              return 'Le taux doit être entre 100 et 5000 ms';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isConnecting ? null : _connectToCamera,
                            icon: _isConnecting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.videocam),
                            label: Text(_isConnecting
                                ? 'Connexion en cours...'
                                : 'Se connecter'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            const Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comment se connecter à une caméra IP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Assurez-vous que votre caméra IP est connectée au même réseau que cet appareil.',
                    ),
                    SizedBox(height: 4),
                    Text(
                      '2. Entrez l\'URL complète du flux vidéo de votre caméra IP.',
                    ),
                    SizedBox(height: 4),
                    Text(
                      '3. Si votre caméra nécessite une authentification, activez l\'option et entrez vos identifiants.',
                    ),
                    SizedBox(height: 4),
                    Text(
                      '4. Ajustez le taux de rafraîchissement en fonction de la qualité de votre connexion.',
                    ),
                    SizedBox(height: 12),
                    Text(
                      'URLs courantes pour les caméras IP:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                        '• Caméras IP générique: http://adresse-ip:port/video'),
                    Text('• Caméras RTSP: rtsp://adresse-ip:port/stream'),
                    Text('• ESPCam: http://adresse-ip/capture'),
                    Text(
                        '• Appareils Android avec IP Webcam: http://adresse-ip:8080/video'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
