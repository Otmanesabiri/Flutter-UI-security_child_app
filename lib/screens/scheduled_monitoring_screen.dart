import 'package:flutter/material.dart';

class ScheduledMonitoringScreen extends StatefulWidget {
  const ScheduledMonitoringScreen({Key? key}) : super(key: key);

  @override
  State<ScheduledMonitoringScreen> createState() =>
      _ScheduledMonitoringScreenState();
}

class _ScheduledMonitoringScreenState extends State<ScheduledMonitoringScreen> {
  bool _isMonitoringActive = true;

  // Exemple de plannings de surveillance
  final List<MonitoringSchedule> _schedules = [
    MonitoringSchedule(
      id: 1,
      name: 'École',
      description: 'Surveillance pendant les heures d\'école',
      startTime: const TimeOfDay(hour: 8, minute: 0),
      endTime: const TimeOfDay(hour: 16, minute: 0),
      daysOfWeek: {1, 2, 3, 4, 5}, // Lundi à vendredi
      isActive: true,
      sensitivityLevel: 0.7,
      alertTypes: {'Objets dangereux', 'Personnes inconnues'},
    ),
    MonitoringSchedule(
      id: 2,
      name: 'Activités parascolaires',
      description: 'Surveillance pendant les activités après l\'école',
      startTime: const TimeOfDay(hour: 16, minute: 30),
      endTime: const TimeOfDay(hour: 18, minute: 0),
      daysOfWeek: {2, 4}, // Mardi et jeudi
      isActive: true,
      sensitivityLevel: 0.5,
      alertTypes: {'Objets dangereux', 'Zones interdites'},
    ),
    MonitoringSchedule(
      id: 3,
      name: 'Weekend',
      description: 'Surveillance pendant les weekends',
      startTime: const TimeOfDay(hour: 10, minute: 0),
      endTime: const TimeOfDay(hour: 18, minute: 0),
      daysOfWeek: {6, 7}, // Samedi et dimanche
      isActive: false,
      sensitivityLevel: 0.3,
      alertTypes: {
        'Objets dangereux',
        'Personnes inconnues',
        'Zones interdites'
      },
    ),
  ];

  final List<String> _availableAlertTypes = [
    'Objets dangereux',
    'Personnes inconnues',
    'Zones interdites',
    'Comportements suspects',
    'Sorties de zones sécurisées',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Programmé'),
        actions: [
          Switch(
            value: _isMonitoringActive,
            onChanged: (value) {
              setState(() {
                _isMonitoringActive = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Monitoring ${value ? 'activé' : 'désactivé'}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            activeColor: Colors.white,
            activeTrackColor: Colors.green,
          ),
        ],
      ),
      body: _isMonitoringActive
          ? _buildActiveMonitoringView()
          : _buildInactiveMonitoringView(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewSchedule,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau planning'),
      ),
    );
  }

  Widget _buildActiveMonitoringView() {
    // Obtenir le planning actif actuel
    final now = TimeOfDay.now();
    final today = DateTime.now().weekday;

    MonitoringSchedule? activeSchedule;
    for (var schedule in _schedules) {
      if (!schedule.isActive) continue;
      if (!schedule.daysOfWeek.contains(today)) continue;

      final start = schedule.startTime;
      final end = schedule.endTime;

      final nowMinutes = now.hour * 60 + now.minute;
      final startMinutes = start.hour * 60 + start.minute;
      final endMinutes = end.hour * 60 + end.minute;

      if (nowMinutes >= startMinutes && nowMinutes < endMinutes) {
        activeSchedule = schedule;
        break;
      }
    }

    return Column(
      children: [
        // État actuel du monitoring
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.timer,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeSchedule != null
                              ? 'Planning actif: ${activeSchedule.name}'
                              : 'Aucun planning actif en ce moment',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (activeSchedule != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Jusqu\'à ${activeSchedule.endTime.format(context)}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (activeSchedule != null) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _calculateScheduleProgress(activeSchedule),
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      activeSchedule.startTime.format(context),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      activeSchedule.endTime.format(context),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Niveau de sensibilité: ${(activeSchedule.sensitivityLevel * 100).toInt()}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: activeSchedule.alertTypes
                      .map((type) => Chip(
                            label: Text(type),
                            backgroundColor: Colors.blue.shade100,
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),

        // Liste des plannings
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'Plannings programmés',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _showScheduleHistory,
                icon: const Icon(Icons.history, size: 16),
                label: const Text('Historique'),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _schedules.length,
            itemBuilder: (context, index) {
              final schedule = _schedules[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () => _editSchedule(schedule),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                schedule.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Switch(
                              value: schedule.isActive,
                              onChanged: (value) {
                                setState(() {
                                  _schedules[index] =
                                      schedule.copyWith(isActive: value);
                                });
                              },
                            ),
                          ],
                        ),
                        Text(schedule.description),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${schedule.startTime.format(context)} - ${schedule.endTime.format(context)}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 4),
                            Text(_formatDaysOfWeek(schedule.daysOfWeek)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Sensibilité: '),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 14,
                                  ),
                                ),
                                child: Slider(
                                  value: schedule.sensitivityLevel,
                                  min: 0.1,
                                  max: 1.0,
                                  onChanged: null,
                                ),
                              ),
                            ),
                            Text(
                                '${(schedule.sensitivityLevel * 100).toInt()}%'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: schedule.alertTypes
                              .map((type) => Chip(
                                    label: Text(type),
                                    backgroundColor: Colors.blue.shade100,
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInactiveMonitoringView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.timer_off,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Monitoring programmé désactivé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Activez le monitoring pour utiliser vos plannings',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isMonitoringActive = true;
              });
            },
            icon: const Icon(Icons.power_settings_new),
            label: const Text('Activer le monitoring'),
          ),
        ],
      ),
    );
  }

  double _calculateScheduleProgress(MonitoringSchedule schedule) {
    final now = TimeOfDay.now();

    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes =
        schedule.startTime.hour * 60 + schedule.startTime.minute;
    final endMinutes = schedule.endTime.hour * 60 + schedule.endTime.minute;

    final totalDuration = endMinutes - startMinutes;
    final elapsedDuration = nowMinutes - startMinutes;

    return elapsedDuration / totalDuration;
  }

  String _formatDaysOfWeek(Set<int> days) {
    final dayNames = {
      1: 'Lun',
      2: 'Mar',
      3: 'Mer',
      4: 'Jeu',
      5: 'Ven',
      6: 'Sam',
      7: 'Dim',
    };

    if (days.length == 7) {
      return 'Tous les jours';
    } else if (days.containsAll({1, 2, 3, 4, 5})) {
      return 'En semaine';
    } else if (days.containsAll({6, 7})) {
      return 'Weekends';
    } else {
      return days.map((day) => dayNames[day]).join(', ');
    }
  }

  void _addNewSchedule() {
    final schedule = MonitoringSchedule(
      id: _schedules.isEmpty
          ? 1
          : _schedules.map((s) => s.id).reduce((a, b) => a > b ? a : b) + 1,
      name: '',
      description: '',
      startTime: const TimeOfDay(hour: 8, minute: 0),
      endTime: const TimeOfDay(hour: 16, minute: 0),
      daysOfWeek: {1, 2, 3, 4, 5},
      isActive: true,
      sensitivityLevel: 0.5,
      alertTypes: {_availableAlertTypes.first},
    );

    _showScheduleDialog(schedule, isNew: true);
  }

  void _editSchedule(MonitoringSchedule schedule) {
    _showScheduleDialog(schedule, isNew: false);
  }

  void _showScheduleDialog(MonitoringSchedule schedule, {required bool isNew}) {
    final nameController = TextEditingController(text: schedule.name);
    final descriptionController =
        TextEditingController(text: schedule.description);

    var editedSchedule = schedule;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('${isNew ? 'Nouveau' : 'Modifier'} planning'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du planning',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Heure de début',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: editedSchedule.startTime,
                              );
                              if (time != null) {
                                setState(() {
                                  editedSchedule =
                                      editedSchedule.copyWith(startTime: time);
                                });
                              }
                            },
                            icon: const Icon(Icons.access_time),
                            label:
                                Text(editedSchedule.startTime.format(context)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Heure de fin',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: editedSchedule.endTime,
                              );
                              if (time != null) {
                                setState(() {
                                  editedSchedule =
                                      editedSchedule.copyWith(endTime: time);
                                });
                              }
                            },
                            icon: const Icon(Icons.access_time),
                            label: Text(editedSchedule.endTime.format(context)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Jours',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildDayChip(1, 'Lun', editedSchedule, setState),
                    _buildDayChip(2, 'Mar', editedSchedule, setState),
                    _buildDayChip(3, 'Mer', editedSchedule, setState),
                    _buildDayChip(4, 'Jeu', editedSchedule, setState),
                    _buildDayChip(5, 'Ven', editedSchedule, setState),
                    _buildDayChip(6, 'Sam', editedSchedule, setState),
                    _buildDayChip(7, 'Dim', editedSchedule, setState),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Niveau de sensibilité',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Text('Faible'),
                    Expanded(
                      child: Slider(
                        value: editedSchedule.sensitivityLevel,
                        min: 0.1,
                        max: 1.0,
                        divisions: 9,
                        label:
                            '${(editedSchedule.sensitivityLevel * 100).toInt()}%',
                        onChanged: (value) {
                          setState(() {
                            editedSchedule = editedSchedule.copyWith(
                                sensitivityLevel: value);
                          });
                        },
                      ),
                    ),
                    const Text('Élevé'),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Types d\'alertes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _availableAlertTypes
                      .map((type) => FilterChip(
                            label: Text(type),
                            selected: editedSchedule.alertTypes.contains(type),
                            onSelected: (selected) {
                              setState(() {
                                final alertTypes =
                                    Set<String>.from(editedSchedule.alertTypes);
                                if (selected) {
                                  alertTypes.add(type);
                                } else {
                                  alertTypes.remove(type);
                                }
                                editedSchedule = editedSchedule.copyWith(
                                    alertTypes: alertTypes);
                              });
                            },
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            if (!isNew)
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteSchedule(schedule);
                },
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('Supprimer',
                    style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final description = descriptionController.text.trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez saisir un nom pour le planning'),
                    ),
                  );
                  return;
                }

                final updatedSchedule = editedSchedule.copyWith(
                  name: name,
                  description: description,
                );

                Navigator.pop(context);

                setState(() {
                  if (isNew) {
                    _schedules.add(updatedSchedule);
                  } else {
                    final index = _schedules
                        .indexWhere((s) => s.id == updatedSchedule.id);
                    if (index != -1) {
                      _schedules[index] = updatedSchedule;
                    }
                  }
                });
              },
              child: Text(isNew ? 'Créer' : 'Mettre à jour'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayChip(int day, String label, MonitoringSchedule schedule,
      StateSetter setState) {
    final isSelected = schedule.daysOfWeek.contains(day);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          final days = Set<int>.from(schedule.daysOfWeek);
          if (selected) {
            days.add(day);
          } else {
            days.remove(day);
          }
          schedule = schedule.copyWith(daysOfWeek: days);
        });
      },
    );
  }

  void _deleteSchedule(MonitoringSchedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le planning'),
        content: Text(
            'Êtes-vous sûr de vouloir supprimer le planning "${schedule.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _schedules.removeWhere((s) => s.id == schedule.id);
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showScheduleHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
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
                    'Historique des activations',
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
                  // Exemple d'historique fictif
                  _buildHistoryItem(
                    'École',
                    'Activé: 08:00 - 16:00',
                    'Aujourd\'hui',
                    Icons.check_circle,
                    Colors.green,
                  ),
                  _buildHistoryItem(
                    'Activités parascolaires',
                    'Activé: 16:30 - 18:00',
                    'Hier',
                    Icons.check_circle,
                    Colors.green,
                  ),
                  _buildHistoryItem(
                    'École',
                    'Désactivé manuellement à 14:30',
                    'Hier',
                    Icons.cancel,
                    Colors.red,
                  ),
                  _buildHistoryItem(
                    'École',
                    'Activé: 08:00 - 14:30',
                    'Hier',
                    Icons.check_circle,
                    Colors.green,
                  ),
                  _buildHistoryItem(
                    'Weekend',
                    'Activé: 10:00 - 18:00',
                    'Dimanche dernier',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
      String title, String subtitle, String date, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            Text(
              date,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MonitoringSchedule {
  final int id;
  final String name;
  final String description;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Set<int> daysOfWeek; // 1-7 pour lundi-dimanche
  final bool isActive;
  final double sensitivityLevel; // 0.0 à 1.0
  final Set<String> alertTypes;

  MonitoringSchedule({
    required this.id,
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
    required this.isActive,
    required this.sensitivityLevel,
    required this.alertTypes,
  });

  MonitoringSchedule copyWith({
    int? id,
    String? name,
    String? description,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    Set<int>? daysOfWeek,
    bool? isActive,
    double? sensitivityLevel,
    Set<String>? alertTypes,
  }) {
    return MonitoringSchedule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isActive: isActive ?? this.isActive,
      sensitivityLevel: sensitivityLevel ?? this.sensitivityLevel,
      alertTypes: alertTypes ?? this.alertTypes,
    );
  }
}
