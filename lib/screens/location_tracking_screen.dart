import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationTrackingScreen extends StatefulWidget {
  const LocationTrackingScreen({Key? key}) : super(key: key);

  @override
  State<LocationTrackingScreen> createState() => _LocationTrackingScreenState();
}

class _LocationTrackingScreenState extends State<LocationTrackingScreen> {
  // Exemple de positions pour simulation
  final List<LatLng> _childrenPositions = [
    const LatLng(33.5731, -7.5898), // Casablanca
  ];

  final List<SafeZone> _safeZones = [
    SafeZone(
      name: 'Maison',
      center: const LatLng(33.5731, -7.5898),
      radius: 500.0,
      color: Colors.green.withOpacity(0.3),
    ),
    SafeZone(
      name: 'École',
      center: const LatLng(33.5933, -7.6164),
      radius: 300.0,
      color: Colors.blue.withOpacity(0.3),
    ),
    SafeZone(
      name: 'Parc',
      center: const LatLng(33.5830, -7.6270),
      radius: 200.0,
      color: Colors.amber.withOpacity(0.3),
    ),
  ];

  final MapController _mapController = MapController();
  SafeZone? _selectedZone;
  bool _isAddingZone = false;
  final TextEditingController _zoneNameController = TextEditingController();

  @override
  void dispose() {
    _zoneNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi de Localisation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showLocationHistory,
            tooltip: 'Historique de localisation',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showLocationSettings,
            tooltip: 'Paramètres',
          ),
        ],
      ),
      body: Column(
        children: [
          // Carte principale avec les positions et zones
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _childrenPositions.first,
                    initialZoom: 13.0,
                    onTap: _isAddingZone ? _handleMapTap : null,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.child_security',
                    ),
                    // Dessiner les zones de sécurité
                    CircleLayer(
                      circles: _safeZones
                          .map((zone) => CircleMarker(
                                point: zone.center,
                                radius: zone.radius,
                                useRadiusInMeter: true,
                                color: zone == _selectedZone
                                    ? zone.color.withOpacity(0.7)
                                    : zone.color,
                                borderColor: zone == _selectedZone
                                    ? Colors.white
                                    : zone.color.withOpacity(0.7),
                                borderStrokeWidth: 2.0,
                              ))
                          .toList(),
                    ),
                    // Marqueurs pour les noms des zones
                    MarkerLayer(
                      markers: _safeZones
                          .map((zone) => Marker(
                                width: 180.0,
                                height: 30.0,
                                point: zone.center,
                                child: GestureDetector(
                                  onTap: () => _selectZone(zone),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      zone.name,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: zone.color.withOpacity(1.0),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    // Position de l'enfant
                    MarkerLayer(
                      markers: _childrenPositions
                          .map((pos) => Marker(
                                width: 60.0,
                                height: 60.0,
                                point: pos,
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.location_pin,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                    Text(
                                      'Enfant',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
                // Contrôles de la carte
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'zoomIn',
                        mini: true,
                        onPressed: () {
                          final currentZoom = _mapController.camera.zoom;
                          final currentCenter = _mapController.camera.center;
                          _mapController.move(currentCenter, currentZoom + 1);
                        },
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: 'zoomOut',
                        mini: true,
                        onPressed: () {
                          final currentZoom = _mapController.camera.zoom;
                          final currentCenter = _mapController.camera.center;
                          _mapController.move(currentCenter, currentZoom - 1);
                        },
                        child: const Icon(Icons.remove),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: 'centerOnChild',
                        onPressed: () {
                          // Fix: Center the map on the child's position
                          _mapController.move(_childrenPositions.first,
                              _mapController.camera.zoom);
                        },
                        child: const Icon(Icons.my_location),
                      ),
                    ],
                  ),
                ),
                // Panel d'informations sur la zone sélectionnée
                if (_selectedZone != null)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedZone!.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () =>
                                      setState(() => _selectedZone = null),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                                'Rayon: ${(_selectedZone!.radius).toStringAsFixed(0)} m'),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _editZone(_selectedZone!),
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Modifier'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => _deleteZone(_selectedZone!),
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  label: const Text('Supprimer',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Panneau d'état et historique récent
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'État actuel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text('Dans une zone sécurisée (Maison)'),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: _refreshLocation,
                      child: const Text('Actualiser'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Dernière mise à jour: 2 min',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewSafeZone,
        icon: const Icon(Icons.add_location),
        label: const Text('Nouvelle zone'),
      ),
    );
  }

  void _handleMapTap(TapPosition tapPosition, LatLng point) {
    if (_isAddingZone) {
      _showAddZoneDialog(point);
    }
  }

  void _selectZone(SafeZone zone) {
    setState(() {
      _selectedZone = zone;
    });
  }

  void _addNewSafeZone() {
    setState(() {
      _isAddingZone = true;
      _selectedZone = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Touchez la carte pour placer une nouvelle zone sécurisée'),
      ),
    );
  }

  void _showAddZoneDialog(LatLng point) {
    _zoneNameController.text = 'Zone ${_safeZones.length + 1}';
    double radius = 300.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nouvelle zone sécurisée'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _zoneNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la zone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Rayon de la zone'),
              Slider(
                value: radius,
                min: 50.0,
                max: 1000.0,
                divisions: 19,
                label: '${radius.toStringAsFixed(0)} m',
                onChanged: (value) {
                  setState(() {
                    radius = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                this.setState(() {
                  _isAddingZone = false;
                });
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                this.setState(() {
                  _safeZones.add(
                    SafeZone(
                      name: _zoneNameController.text,
                      center: point,
                      radius: radius,
                      color: Colors.primaries[
                              _safeZones.length % Colors.primaries.length]
                          .withOpacity(0.3),
                    ),
                  );
                  _isAddingZone = false;
                });
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  void _editZone(SafeZone zone) {
    _zoneNameController.text = zone.name;
    double radius = zone.radius;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Modifier zone sécurisée'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _zoneNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la zone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Rayon de la zone'),
              Slider(
                value: radius,
                min: 50.0,
                max: 1000.0,
                divisions: 19,
                label: '${radius.toStringAsFixed(0)} m',
                onChanged: (value) {
                  setState(() {
                    radius = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                this.setState(() {
                  final index = _safeZones.indexOf(zone);
                  _safeZones[index] = SafeZone(
                    name: _zoneNameController.text,
                    center: zone.center,
                    radius: radius,
                    color: zone.color,
                  );
                  _selectedZone = _safeZones[index];
                });
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteZone(SafeZone zone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer zone'),
        content:
            Text('Êtes-vous sûr de vouloir supprimer la zone "${zone.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _safeZones.remove(zone);
                _selectedZone = null;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showLocationHistory() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historique de localisation',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            // Liste fictive d'historique de localisation
            Expanded(
              child: ListView(
                children: [
                  _buildHistoryItem(
                      'Maison', 'Aujourd\'hui, 15:30', Icons.home),
                  _buildHistoryItem(
                      'École', 'Aujourd\'hui, 14:00', Icons.school),
                  _buildHistoryItem('Parc', 'Aujourd\'hui, 13:15', Icons.park),
                  _buildHistoryItem(
                      'École', 'Aujourd\'hui, 08:30', Icons.school),
                  _buildHistoryItem(
                      'Maison', 'Aujourd\'hui, 07:45', Icons.home),
                  _buildHistoryItem('Maison', 'Hier, 20:00', Icons.home),
                  _buildHistoryItem(
                      'Supermarché', 'Hier, 18:30', Icons.shopping_cart),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Widget _buildHistoryItem(String location, String time, IconData icon) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(location),
      subtitle: Text(time),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Afficher les détails
      },
    );
  }

  void _showLocationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paramètres de localisation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Suivi en temps réel'),
              subtitle:
                  const Text('Actualiser la position toutes les 5 minutes'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Alertes de zone'),
              subtitle: const Text(
                  'Notification lorsque l\'enfant entre/sort d\'une zone'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Historique'),
              subtitle:
                  const Text('Sauvegarder l\'historique des déplacements'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _refreshLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Actualisation de la position...'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

class SafeZone {
  final String name;
  final LatLng center;
  final double radius;
  final Color color;

  SafeZone({
    required this.name,
    required this.center,
    required this.radius,
    required this.color,
  });
}
