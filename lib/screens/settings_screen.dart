import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;
  String _userName = 'Parent';
  String _userEmail = 'parent@example.com';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _telegramBotController = TextEditingController();
  final TextEditingController _telegramChatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('isDarkMode') ?? false;
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _userName = prefs.getString('userName') ?? 'Parent';
      _userEmail = prefs.getString('userEmail') ?? 'parent@example.com';

      _nameController.text = _userName;
      _emailController.text = _userEmail;
      _telegramBotController.text = prefs.getString('telegramBotToken') ?? '';
      _telegramChatController.text = prefs.getString('telegramChatId') ?? '';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _darkMode);
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setBool('vibrationEnabled', _vibrationEnabled);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setString('userName', _userName);
    await prefs.setString('userEmail', _userEmail);

    await prefs.setString('telegramBotToken', _telegramBotController.text);
    await prefs.setString('telegramChatId', _telegramChatController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              _buildSectionHeader('Profile'),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                        child: Text(
                          _userName.isNotEmpty
                              ? _userName[0].toUpperCase()
                              : 'P',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _userName = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _userEmail = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          _saveSettings();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile updated')),
                          );
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Save Profile'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Appearance Settings
              _buildSectionHeader('Appearance'),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Dark Mode'),
                      subtitle: const Text('Enable dark theme for the app'),
                      value: _darkMode,
                      onChanged: (value) {
                        setState(() {
                          _darkMode = value;
                        });
                        _saveSettings();
                      },
                      secondary: Icon(
                        _darkMode ? Icons.dark_mode : Icons.light_mode,
                        color: _darkMode ? Colors.white : Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Notification Settings
              _buildSectionHeader('Notifications'),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Enable Notifications'),
                      subtitle: const Text(
                          'Receive alerts when dangerous objects are detected'),
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                        _saveSettings();
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Sound'),
                      subtitle: const Text('Play sound for alerts'),
                      value: _soundEnabled,
                      onChanged: _notificationsEnabled
                          ? (value) {
                              setState(() {
                                _soundEnabled = value;
                              });
                              _saveSettings();
                            }
                          : null,
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Vibration'),
                      subtitle: const Text('Vibrate for alerts'),
                      value: _vibrationEnabled,
                      onChanged: _notificationsEnabled
                          ? (value) {
                              setState(() {
                                _vibrationEnabled = value;
                              });
                              _saveSettings();
                            }
                          : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Telegram Integration
              _buildSectionHeader('Telegram Notifications'),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _telegramBotController,
                        decoration: const InputDecoration(
                          labelText: 'Telegram Bot Token',
                          border: OutlineInputBorder(),
                          helperText: 'Get token from BotFather',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _telegramChatController,
                        decoration: const InputDecoration(
                          labelText: 'Telegram Chat ID',
                          border: OutlineInputBorder(),
                          helperText: 'ID of chat to send alerts to',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          _saveSettings();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Telegram settings saved')),
                          );
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Save Telegram Settings'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          _showTelegramHelpDialog();
                        },
                        icon: const Icon(Icons.help),
                        label: const Text('How to Set Up Telegram'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Advanced Settings
              _buildSectionHeader('Advanced'),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.storage),
                      title: const Text('Export Data'),
                      subtitle: const Text('Export alerts and settings'),
                      onTap: () {
                        // Implement export functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Export feature coming soon')),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.restart_alt),
                      title: const Text('Reset All Settings'),
                      subtitle: const Text('Restore default settings'),
                      onTap: _showResetConfirmation,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // About Section
              _buildSectionHeader('About'),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('About Child Security'),
                      onTap: () {
                        _showAboutDialog();
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      title: const Text('Privacy Policy'),
                      onTap: () {
                        // Navigate to privacy policy
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.help),
                      title: const Text('Help & Support'),
                      onTap: () {
                        // Navigate to help section
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
            'This will reset all settings to their default values. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              _loadSettings();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All settings have been reset')),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => const AboutDialog(
        applicationName: 'Child Security',
        applicationVersion: '1.0.0',
        applicationIcon: FlutterLogo(size: 48),
        applicationLegalese: '© 2025 Child Security Team',
        children: [
          SizedBox(height: 16),
          Text(
            'Child Security is an AI-powered surveillance application designed to detect potentially dangerous objects around children and provide real-time alerts.',
          ),
          SizedBox(height: 16),
          Text(
            'Made to protect children.',
          ),
        ],
      ),
    );
  }

  void _showTelegramHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setting Up Telegram Notifications'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Create a Telegram bot:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('- Open Telegram and search for @BotFather'),
              Text('- Send /newbot command'),
              Text('- Follow the instructions to create a bot'),
              Text('- BotFather will send you a token - copy this'),
              SizedBox(height: 12),
              Text(
                '2. Get your Chat ID:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('- Start a chat with your new bot'),
              Text('- Send any message to the bot'),
              Text('- Visit this URL in your browser:'),
              Text('  https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates'),
              Text('- Replace <YOUR_TOKEN> with your bot token'),
              Text('- Find the "chat" section and note the "id" value'),
              SizedBox(height: 12),
              Text(
                '3. Enter these values in the app:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('- Bot Token: the token from BotFather'),
              Text('- Chat ID: the id value from the getUpdates API'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _telegramBotController.dispose();
    _telegramChatController.dispose();
    super.dispose();
  }
}
