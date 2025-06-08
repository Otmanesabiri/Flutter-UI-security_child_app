import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Données simulées des parents à proximité
  final List<Map<String, dynamic>> _nearbyParents = [
    {
      'id': 1,
      'name': 'Ahmed M.',
      'distance': 0.5, // km
      'children': 2,
      'rating': 4.8,
      'isConnected': true,
      'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
    },
    {
      'id': 2,
      'name': 'Fatima R.',
      'distance': 0.8,
      'children': 1,
      'rating': 4.5,
      'isConnected': false,
      'avatar': 'https://randomuser.me/api/portraits/women/2.jpg',
    },
    {
      'id': 3,
      'name': 'Youssef T.',
      'distance': 1.2,
      'children': 3,
      'rating': 4.9,
      'isConnected': true,
      'avatar': 'https://randomuser.me/api/portraits/men/3.jpg',
    },
    {
      'id': 4,
      'name': 'Nadia B.',
      'distance': 1.5,
      'children': 2,
      'rating': 4.7,
      'isConnected': true,
      'avatar': 'https://randomuser.me/api/portraits/women/4.jpg',
    },
    {
      'id': 5,
      'name': 'Karim L.',
      'distance': 2.3,
      'children': 1,
      'rating': 4.6,
      'isConnected': false,
      'avatar': 'https://randomuser.me/api/portraits/men/5.jpg',
    },
  ];

  // Données simulées d'alertes communautaires
  final List<Map<String, dynamic>> _communityAlerts = [
    {
      'id': 1,
      'title': 'Individu suspect près de l\'école',
      'description':
          'Un individu suspect a été aperçu autour de l\'école primaire du quartier.',
      'severity': 'high',
      'reportedBy': 'Ahmed M.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      'location': 'École primaire Ibn Sina',
      'verified': true,
      'comments': 5,
    },
    {
      'id': 2,
      'title': 'Véhicule roulant à grande vitesse',
      'description':
          'Véhicule noir roulant à grande vitesse dans la zone résidentielle.',
      'severity': 'medium',
      'reportedBy': 'Fatima R.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
      'location': 'Rue des Orangers',
      'verified': false,
      'comments': 2,
    },
    {
      'id': 3,
      'title': 'Travaux dangereux non signalés',
      'description':
          'Travaux de construction avec équipement dangereux accessible aux enfants.',
      'severity': 'medium',
      'reportedBy': 'Youssef T.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
      'location': 'Avenue Mohammed V',
      'verified': true,
      'comments': 8,
    },
  ];

  // Données simulées de demandes d'aide
  final List<Map<String, dynamic>> _helpRequests = [
    {
      'id': 1,
      'title': 'Besoin d\'accompagnement pour enfants',
      'description':
          'Urgence médicale, besoin de quelqu\'un pour surveiller mes enfants pendant 2 heures.',
      'requestedBy': 'Nadia B.',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      'status': 'active',
      'urgency': 'high',
      'location': '3 km',
      'avatar': 'https://randomuser.me/api/portraits/women/4.jpg',
      'volunteers': 1,
    },
    {
      'id': 2,
      'title': 'Recherche covoiturage école',
      'description':
          'Recherche parent pour covoiturage vers l\'école Ibn Sina le matin de cette semaine.',
      'requestedBy': 'Karim L.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'active',
      'urgency': 'medium',
      'location': '2.3 km',
      'avatar': 'https://randomuser.me/api/portraits/men/5.jpg',
      'volunteers': 0,
    },
  ];

  // Add new sample data for parenting advice
  final List<Map<String, dynamic>> _parentingAdvice = [
    {
      'id': 1,
      'title': 'Comment gérer les crises de colère',
      'content':
          'Restez calme, donnez un espace à l\'enfant, puis discutez avec lui quand il est plus calme. Établissez des limites claires mais avec bienveillance.',
      'author': 'Ahmed M.',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'category': 'comportement',
      'likes': 24,
      'comments': 7,
      'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
    },
    {
      'id': 2,
      'title': 'Conseils pour une alimentation équilibrée',
      'content':
          'Impliquez vos enfants dans la préparation des repas. Proposez des fruits comme alternative aux sucreries. Variez les couleurs dans l\'assiette pour rendre le repas attractif.',
      'author': 'Fatima R.',
      'timestamp': DateTime.now().subtract(const Duration(days: 5)),
      'category': 'alimentation',
      'likes': 31,
      'comments': 12,
      'avatar': 'https://randomuser.me/api/portraits/women/2.jpg',
    },
    {
      'id': 3,
      'title': 'Établir une routine pour les devoirs',
      'content':
          'Fixez un horaire régulier, créez un espace dédié sans distractions. Divisez les tâches en petites parties et offrez des pauses. Félicitez les efforts, pas seulement les résultats.',
      'author': 'Youssef T.',
      'timestamp': DateTime.now().subtract(const Duration(days: 7)),
      'category': 'éducation',
      'likes': 18,
      'comments': 5,
      'avatar': 'https://randomuser.me/api/portraits/men/3.jpg',
    },
    {
      'id': 4,
      'title': 'Activités pour stimuler la créativité',
      'content':
          'Proposez des jeux de rôle, des activités artistiques sans règles strictes. Posez des questions ouvertes et valorisez les idées originales de votre enfant.',
      'author': 'Nadia B.',
      'timestamp': DateTime.now().subtract(const Duration(days: 10)),
      'category': 'activités',
      'likes': 42,
      'comments': 9,
      'avatar': 'https://randomuser.me/api/portraits/women/4.jpg',
    },
  ];

  // Map for category icons
  final Map<String, IconData> _categoryIcons = {
    'comportement': Icons.psychology,
    'alimentation': Icons.restaurant,
    'éducation': Icons.school,
    'santé': Icons.health_and_safety,
    'sécurité': Icons.security,
    'activités': Icons.sports_soccer,
    'autre': Icons.more_horiz,
  };

  // Map for category colors
  final Map<String, Color> _categoryColors = {
    'comportement': Colors.purple,
    'alimentation': Colors.green,
    'éducation': Colors.blue,
    'santé': Colors.red,
    'sécurité': Colors.orange,
    'activités': Colors.teal,
    'autre': Colors.grey,
  };

  // Track liked advice by current user
  final Set<int> _likedAdvice = {};

  @override
  void initState() {
    super.initState();
    // Update TabController to include the new Advice tab
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communauté & Entraide'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Parents'),
            Tab(icon: Icon(Icons.notifications_active), text: 'Alertes'),
            Tab(icon: Icon(Icons.support), text: 'Entraide'),
            Tab(
                icon: Icon(Icons.lightbulb),
                text: 'Conseils'), // New tab for advice
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildParentsNetworkTab(),
          _buildCommunityAlertsTab(),
          _buildSupportSystemTab(),
          _buildParentingAdviceTab(), // New tab view
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          return _buildFloatingActionButton(_tabController.index);
        },
      ),
    );
  }

  Widget _buildFloatingActionButton(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return FloatingActionButton(
          heroTag: 'search_parents',
          onPressed: _searchNearbyParents,
          tooltip: 'Rechercher des parents',
          child: const Icon(Icons.person_search),
        );
      case 1:
        return FloatingActionButton(
          heroTag: 'add_alert',
          onPressed: _reportCommunityAlert,
          tooltip: 'Signaler une alerte',
          child: const Icon(Icons.add_alert),
        );
      case 2:
        return FloatingActionButton(
          heroTag: 'request_help',
          onPressed: _requestHelp,
          backgroundColor: Colors.orange,
          tooltip: 'Demander de l\'aide',
          child: const Icon(Icons.help_outline),
        );
      case 3: // New case for Advice tab
        return FloatingActionButton(
          heroTag: 'share_advice',
          onPressed: _shareNewAdvice,
          backgroundColor: Colors.purple,
          tooltip: 'Partager un conseil',
          child: const Icon(Icons.lightbulb),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // Onglet Réseau de Parents
  Widget _buildParentsNetworkTab() {
    return Column(
      children: [
        // Carte montrant les stats du réseau
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Parents à proximité',
                    '${_nearbyParents.length}', Icons.people),
                _divider(),
                _buildStatColumn(
                    'Connectés',
                    '${_nearbyParents.where((p) => p['isConnected']).length}',
                    Icons.check_circle),
                _divider(),
                _buildStatColumn(
                    'Mon réseau', '3', Icons.connect_without_contact),
              ],
            ),
          ),
        ),

        // Liste des parents à proximité
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _nearbyParents.length,
            itemBuilder: (context, index) {
              final parent = _nearbyParents[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(parent['avatar']),
                    radius: 24,
                  ),
                  title: Row(
                    children: [
                      Text(parent['name']),
                      const SizedBox(width: 8),
                      if (parent['isConnected'])
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'En ligne',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    '${parent['distance']} km • ${parent['children']} enfant${parent['children'] > 1 ? 's' : ''}',
                  ),
                  trailing: parent['isConnected']
                      ? IconButton(
                          icon: const Icon(Icons.message, color: Colors.blue),
                          onPressed: () => _contactParent(parent),
                        )
                      : ElevatedButton(
                          onPressed: () => _connectWithParent(parent),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: const Text('Connecter'),
                        ),
                  onTap: () => _viewParentProfile(parent),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Onglet Alertes Communautaires
  Widget _buildCommunityAlertsTab() {
    return Column(
      children: [
        // Options de filtre
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('Trier par: ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: 'recent',
                items: const [
                  DropdownMenuItem(value: 'recent', child: Text('Plus récent')),
                  DropdownMenuItem(value: 'urgent', child: Text('Urgence')),
                  DropdownMenuItem(value: 'nearest', child: Text('Proximité')),
                ],
                onChanged: (value) {
                  // Logique de tri
                },
              ),
              const Spacer(),
              FilterChip(
                label: const Text('Vérifiés'),
                selected: true,
                onSelected: (selected) {
                  // Logique de filtre
                },
              ),
            ],
          ),
        ),

        // Liste des alertes
        Expanded(
          child: _communityAlerts.isEmpty
              ? const Center(child: Text('Aucune alerte communautaire'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _communityAlerts.length,
                  itemBuilder: (context, index) {
                    final alert = _communityAlerts[index];
                    final formattedTime =
                        DateFormat('HH:mm').format(alert['timestamp']);

                    Color severityColor;
                    IconData severityIcon;

                    switch (alert['severity']) {
                      case 'high':
                        severityColor = Colors.red;
                        severityIcon = Icons.warning_amber;
                        break;
                      case 'medium':
                        severityColor = Colors.orange;
                        severityIcon = Icons.warning;
                        break;
                      default:
                        severityColor = Colors.yellow;
                        severityIcon = Icons.info;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: severityColor.withOpacity(0.2),
                              child: Icon(severityIcon, color: severityColor),
                            ),
                            title: Text(
                              alert['title'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(alert['description']),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      alert['location'],
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.access_time,
                                        size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      formattedTime,
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: alert['verified']
                                ? const Tooltip(
                                    message: 'Alerte vérifiée',
                                    child: Icon(Icons.verified,
                                        color: Colors.green),
                                  )
                                : null,
                            onTap: () => _viewAlertDetails(alert),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Signalé par ${alert['reportedBy']}',
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 12),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.share, size: 20),
                                      onPressed: () => _shareAlert(alert),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 16),
                                    IconButton(
                                      icon: const Icon(Icons.comment, size: 20),
                                      onPressed: () =>
                                          _viewAlertComments(alert),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${alert['comments']}',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Onglet Système de Support
  Widget _buildSupportSystemTab() {
    return Column(
      children: [
        // En-tête avec info et statistiques
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Système d\'entraide parentale',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connectez-vous avec d\'autres parents de votre communauté pour un soutien mutuel',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('Demandes actives',
                        '${_helpRequests.length}', Icons.help_outline),
                    _divider(),
                    _buildStatColumn(
                        'Aide fournie', '3', Icons.volunteer_activism),
                    _divider(),
                    _buildStatColumn('Points d\'entraide', '120', Icons.star),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Titre des demandes actives
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text(
                'Demandes d\'aide actives',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              TextButton(
                onPressed: _viewPastHelpRequests,
                child: const Text('Voir l\'historique'),
              ),
            ],
          ),
        ),

        // Liste des demandes d'aide
        Expanded(
          child: _helpRequests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.support, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune demande d\'aide active',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _requestHelp,
                        icon: const Icon(Icons.add),
                        label: const Text('Demander de l\'aide'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _helpRequests.length,
                  itemBuilder: (context, index) {
                    final request = _helpRequests[index];
                    final formattedTime = _formatTimeAgo(request['timestamp']);

                    // Définir la couleur selon l'urgence
                    Color urgencyColor;
                    switch (request['urgency']) {
                      case 'high':
                        urgencyColor = Colors.red;
                        break;
                      case 'medium':
                        urgencyColor = Colors.orange;
                        break;
                      default:
                        urgencyColor = Colors.blue;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          // En-tête avec avatar et infos de base
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(request['avatar']),
                            ),
                            title: Row(
                              children: [
                                Text(request['requestedBy']),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: urgencyColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    request['urgency'] == 'high'
                                        ? 'Urgent'
                                        : 'Normal',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                            subtitle:
                                Text('$formattedTime • ${request['location']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () => _showRequestOptions(request),
                            ),
                          ),

                          // Détails de la demande
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request['title'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(request['description']),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),

                          // Actions
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                            child: Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () =>
                                      _contactRequestParent(request),
                                  icon: const Icon(Icons.message, size: 20),
                                  label: const Text('Contacter'),
                                ),
                                const Spacer(),
                                ElevatedButton.icon(
                                  onPressed: () => _offerHelp(request),
                                  icon: const Icon(Icons.handshake, size: 20),
                                  label: Text(
                                    request['volunteers'] > 0
                                        ? 'Rejoindre (${request['volunteers']})'
                                        : 'Offrir de l\'aide',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Nouvel onglet Conseils Parentaux
  Widget _buildParentingAdviceTab() {
    return Column(
      children: [
        // Category filter chips
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 8.0, top: 12),
                  child: Text(
                    'Filtrer:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ..._categoryIcons.entries
                    .map((entry) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            avatar: Icon(
                              entry.value,
                              color: _categoryColors[entry.key],
                              size: 18,
                            ),
                            label: Text(
                              entry.key.substring(0, 1).toUpperCase() +
                                  entry.key.substring(1),
                              style: const TextStyle(fontSize: 12),
                            ),
                            selected:
                                false, // Would be a state variable in real implementation
                            onSelected: (bool selected) {
                              // Filter logic would go here
                            },
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
        ),

        // Search bar for advice
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher des conseils...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade200,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),

        // List of advice
        Expanded(
          child: _parentingAdvice.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lightbulb_outline,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun conseil partagé',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _shareNewAdvice,
                        icon: const Icon(Icons.add),
                        label: const Text('Partager un conseil'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _parentingAdvice.length,
                  itemBuilder: (context, index) {
                    final advice = _parentingAdvice[index];
                    final isLiked = _likedAdvice.contains(advice['id']);
                    final category = advice['category'] as String;
                    final iconData =
                        _categoryIcons[category] ?? Icons.more_horiz;
                    final categoryColor =
                        _categoryColors[category] ?? Colors.grey;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Author info
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(advice['avatar']),
                            ),
                            title: Row(
                              children: [
                                Text(advice['author']),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(iconData,
                                          size: 12, color: categoryColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        category.substring(0, 1).toUpperCase() +
                                            category.substring(1),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: categoryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(_formatTimeAgo(advice['timestamp'])),
                            trailing: IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () => _showAdviceOptions(advice),
                            ),
                          ),

                          // Advice content
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  advice['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(advice['content']),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),

                          // Action buttons
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                            child: Row(
                              children: [
                                // Like button
                                TextButton.icon(
                                  onPressed: () =>
                                      _toggleLikeAdvice(advice['id']),
                                  icon: Icon(
                                    isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isLiked ? Colors.red : Colors.grey,
                                    size: 20,
                                  ),
                                  label: Text(
                                    '${advice['likes']}',
                                    style: TextStyle(
                                      color: isLiked ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                ),
                                // Comment button
                                TextButton.icon(
                                  onPressed: () => _viewAdviceComments(advice),
                                  icon: const Icon(Icons.comment, size: 20),
                                  label: Text('${advice['comments']}'),
                                ),
                                const Spacer(),
                                // Share button
                                IconButton(
                                  icon: const Icon(Icons.share, size: 20),
                                  onPressed: () => _shareAdvice(advice),
                                ),
                                // Save button
                                IconButton(
                                  icon: const Icon(Icons.bookmark_border,
                                      size: 20),
                                  onPressed: () => _saveAdvice(advice),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Méthodes utilitaires
  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.withOpacity(0.3),
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else {
      return 'Il y a ${difference.inDays} j';
    }
  }

  // Actions pour l'onglet Parents
  void _searchNearbyParents() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechercher des parents'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Rayon de recherche (km)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Recherche de parents à proximité...')),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Rechercher'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _connectWithParent(Map<String, dynamic> parent) {
    setState(() {
      parent['isConnected'] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Demande de connexion envoyée à ${parent['name']}')),
    );
  }

  void _contactParent(Map<String, dynamic> parent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contacter ${parent['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Message',
                hintText: 'Écrivez votre message ici...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Message envoyé à ${parent['name']}')),
                    );
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Envoyer'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.call),
                  label: const Text('Appeler'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _viewParentProfile(Map<String, dynamic> parent) {
    // Navigation vers le profil détaillé du parent
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Affichage du profil de ${parent['name']}')),
    );
  }

  // Actions pour l'onglet Alertes
  void _reportCommunityAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signaler une alerte communautaire'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Titre de l\'alerte',
                  hintText: 'Ex: Individu suspect près de l\'école',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Décrivez la situation en détail',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Lieu',
                  hintText: 'Ex: École Ibn Sina, Rue Mohammed V',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Niveau d\'urgence',
                  border: OutlineInputBorder(),
                ),
                value: 'medium',
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Faible')),
                  DropdownMenuItem(value: 'medium', child: Text('Moyen')),
                  DropdownMenuItem(value: 'high', child: Text('Élevé')),
                ],
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: true,
                    onChanged: (value) {},
                  ),
                  const Expanded(
                    child: Text(
                        'Partager cette alerte avec les parents à proximité'),
                  ),
                ],
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Alerte communautaire signalée')),
              );
            },
            child: const Text('Signaler'),
          ),
        ],
      ),
    );
  }

  void _viewAlertDetails(Map<String, dynamic> alert) {
    // Navigation vers les détails de l'alerte
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Affichage des détails de l\'alerte: ${alert['title']}')),
    );
  }

  void _shareAlert(Map<String, dynamic> alert) {
    final String shareText = '''
⚠️ ALERTE COMMUNAUTAIRE ⚠️
${alert['title']}
${alert['description']}
Lieu: ${alert['location']}
Signalé par: ${alert['reportedBy']}

Cette alerte a été partagée via l'application Child Security.
''';

    Share.share(shareText);
  }

  void _viewAlertComments(Map<String, dynamic> alert) {
    // Navigation vers les commentaires de l'alerte
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Affichage des commentaires pour: ${alert['title']}')),
    );
  }

  // Actions pour l'onglet Support
  void _requestHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Demander de l\'aide'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Titre de la demande',
                  hintText: 'Ex: Besoin de surveillance pour mes enfants',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Décrivez votre besoin en détail',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Niveau d\'urgence',
                  border: OutlineInputBorder(),
                ),
                value: 'medium',
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Faible')),
                  DropdownMenuItem(value: 'medium', child: Text('Moyen')),
                  DropdownMenuItem(value: 'high', child: Text('Élevé/Urgent')),
                ],
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: true,
                    onChanged: (value) {},
                  ),
                  const Expanded(
                    child: Text('Notifier tous les parents à proximité'),
                  ),
                ],
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Demande d\'aide publiée')),
              );

              // Ajouter la demande à la liste
              setState(() {
                _helpRequests.insert(0, {
                  'id': _helpRequests.length + 1,
                  'title': 'Nouvelle demande d\'aide',
                  'description': 'Description de votre demande d\'aide...',
                  'requestedBy': 'Vous',
                  'timestamp': DateTime.now(),
                  'status': 'active',
                  'urgency': 'medium',
                  'location': '0 km',
                  'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
                  'volunteers': 0,
                });
              });
            },
            child: const Text('Publier'),
          ),
        ],
      ),
    );
  }

  void _showRequestOptions(Map<String, dynamic> request) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Partager'),
            onTap: () {
              Navigator.pop(context);
              _shareHelpRequest(request);
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Signaler'),
            onTap: () {
              Navigator.pop(context);
              // Logique de signalement
            },
          ),
          if (request['requestedBy'] == 'Vous')
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title:
                  const Text('Supprimer', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteHelpRequest(request);
              },
            ),
        ],
      ),
    );
  }

  void _offerHelp(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Offrir votre aide'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Vous êtes sur le point d\'offrir votre aide à ${request['requestedBy']} pour:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(request['title']),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Message',
                hintText:
                    'Écrivez un message pour expliquer comment vous pouvez aider...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              setState(() {
                request['volunteers'] = request['volunteers'] + 1;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Vous avez proposé votre aide à ${request['requestedBy']}')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Proposer mon aide'),
          ),
        ],
      ),
    );
  }

  void _contactRequestParent(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contacter ${request['requestedBy']}'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Message',
                hintText: 'Écrivez votre message ici...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          // Fix: Use proper ElevatedButton.icon constructor with required parameters
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Message envoyé à ${request['requestedBy']}')),
              );
            },
            icon: const Icon(Icons.send),
            label: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  void _shareHelpRequest(Map<String, dynamic> request) {
    final String shareText = '''
🆘 DEMANDE D'AIDE PARENTALE 🆘
${request['title']}
${request['description']}
Demandé par: ${request['requestedBy']}
Urgence: ${request['urgency'] == 'high' ? 'Élevée' : 'Normale'}

Cette demande d'aide a été partagée via l'application Child Security.
''';

    Share.share(shareText);
  }

  void _deleteHelpRequest(Map<String, dynamic> request) {
    setState(() {
      _helpRequests.removeWhere((item) => item['id'] == request['id']);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Votre demande d\'aide a été supprimée')),
    );
  }

  void _viewPastHelpRequests() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Affichage de l\'historique des demandes d\'aide')),
    );
  }

  // Methods for the Advice tab
  void _shareNewAdvice() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    String selectedCategory = 'comportement'; // Default category

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Partager un conseil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre du conseil',
                    hintText: 'Ex: Comment encourager la lecture',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Votre conseil',
                    hintText: 'Partagez votre expérience et vos astuces...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Catégorie:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _categoryIcons.entries.map((entry) {
                    final isSelected = selectedCategory == entry.key;
                    return ChoiceChip(
                      avatar: Icon(
                        entry.value,
                        color: isSelected
                            ? Colors.white
                            : _categoryColors[entry.key],
                        size: 18,
                      ),
                      label: Text(
                        entry.key.substring(0, 1).toUpperCase() +
                            entry.key.substring(1),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: _categoryColors[entry.key],
                      onSelected: (bool selected) {
                        if (selected) {
                          setState(() {
                            selectedCategory = entry.key;
                          });
                        }
                      },
                    );
                  }).toList(),
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
                if (titleController.text.isEmpty ||
                    contentController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Veuillez remplir tous les champs')),
                  );
                  return;
                }

                // Add the new advice to the list
                final newAdvice = {
                  'id': _parentingAdvice.length + 1,
                  'title': titleController.text,
                  'content': contentController.text,
                  'author': 'Vous',
                  'timestamp': DateTime.now(),
                  'category': selectedCategory,
                  'likes': 0,
                  'comments': 0,
                  'avatar':
                      'https://randomuser.me/api/portraits/men/1.jpg', // Would be the current user's avatar
                };

                setState(() {
                  _parentingAdvice.insert(0, newAdvice);
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Conseil partagé avec la communauté')),
                );
              },
              child: const Text('Partager'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleLikeAdvice(int adviceId) {
    setState(() {
      if (_likedAdvice.contains(adviceId)) {
        _likedAdvice.remove(adviceId);
        // Decrement likes count
        final advice = _parentingAdvice.firstWhere((a) => a['id'] == adviceId);
        advice['likes'] = (advice['likes'] as int) - 1;
      } else {
        _likedAdvice.add(adviceId);
        // Increment likes count
        final advice = _parentingAdvice.firstWhere((a) => a['id'] == adviceId);
        advice['likes'] = (advice['likes'] as int) + 1;
      }
    });
  }

  void _viewAdviceComments(Map<String, dynamic> advice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Header
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
                    'Commentaires',
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

            // Comment list
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Advice summary
                  Text(
                    advice['title'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Sample comments - in a real app this would come from a database
                  _buildCommentItem(
                    'Fatima R.',
                    'https://randomuser.me/api/portraits/women/2.jpg',
                    'Merci pour ce conseil, ça m\'aide beaucoup avec mon fils de 5 ans !',
                    DateTime.now().subtract(const Duration(hours: 2)),
                  ),
                  _buildCommentItem(
                    'Youssef T.',
                    'https://randomuser.me/api/portraits/men/3.jpg',
                    'J\'ai essayé cette méthode et ça fonctionne très bien. Merci du partage.',
                    DateTime.now().subtract(const Duration(hours: 5)),
                  ),
                  _buildCommentItem(
                    'Nadia B.',
                    'https://randomuser.me/api/portraits/women/4.jpg',
                    'Est-ce que cette approche marche aussi pour les adolescents ?',
                    DateTime.now().subtract(const Duration(days: 1)),
                  ),
                ],
              ),
            ),

            // Comment input
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Ajouter un commentaire...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      maxLines: null,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: () {
                      // Send comment logic would go here
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Commentaire ajouté')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(
      String author, String avatar, String content, DateTime timestamp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(avatar),
            radius: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      author,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimeAgo(timestamp),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(content),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAdviceOptions(Map<String, dynamic> advice) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Partager'),
            onTap: () {
              Navigator.pop(context);
              _shareAdvice(advice);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('Enregistrer'),
            onTap: () {
              Navigator.pop(context);
              _saveAdvice(advice);
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Signaler'),
            onTap: () {
              Navigator.pop(context);
              // Reporting logic would go here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contenu signalé')),
              );
            },
          ),
          if (advice['author'] == 'Vous')
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title:
                  const Text('Supprimer', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteAdvice(advice);
              },
            ),
        ],
      ),
    );
  }

  void _shareAdvice(Map<String, dynamic> advice) {
    final String shareText = '''
💡 CONSEIL PARENTAL 💡
${advice['title']}
${advice['content']}
Par: ${advice['author']}
Catégorie: ${advice['category']}

Ce conseil a été partagé via l'application Child Security.
''';

    Share.share(shareText);
  }

  void _saveAdvice(Map<String, dynamic> advice) {
    // In a real app, this would save to a database or preferences
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conseil enregistré dans vos favoris')),
    );
  }

  void _deleteAdvice(Map<String, dynamic> advice) {
    setState(() {
      _parentingAdvice.removeWhere((item) => item['id'] == advice['id']);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Votre conseil a été supprimé')),
    );
  }
}
