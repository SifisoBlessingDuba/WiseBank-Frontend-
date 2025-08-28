import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _newsAndPromotionsEnabled = true;
  bool _myUpdatesEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to Inbox Hub
            Navigator.pop(context);
          },
        ),
        title: const Text('Message Centre'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            _buildToggleRow(
              title: 'News and Promotions',
              value: _newsAndPromotionsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _newsAndPromotionsEnabled = value;
                  // TODO: Persist this setting
                });
              },
            ),
            const Divider(),
            _buildToggleRow(
              title: 'MyUpdates',
              value: _myUpdatesEnabled,
              onChanged: (bool value) {
                setState(() {
                  _myUpdatesEnabled = value;
                  // TODO: Persist this setting
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  children: <TextSpan>[
                    const TextSpan(
                        text:
                        'If you switch off MyUpdates notifications in the app, we will send them to your email address or cellphone number via SMS. '),
                    TextSpan(
                      text: 'Standard rates may apply. ',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      // TODO: Implement navigation to pricing guide
                      // recognizer: TapGestureRecognizer()..onTap = () { print('Navigate to pricing guide'); },
                    ),
                    const TextSpan(
                        text:
                        'Please see our pricing guide for more information.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
