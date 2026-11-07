import 'package:ezsports/core/storage/app_store.dart';
import 'package:flutter/material.dart';

class NotificationPrefsSheet extends StatefulWidget {
  const NotificationPrefsSheet({
    super.key,
    required this.role,
    required this.accent,
    required this.ink,
    this.includeFees = false,
  });

  final String role;
  final Color accent;
  final Color ink;
  final bool includeFees;

  @override
  State<NotificationPrefsSheet> createState() => _NotificationPrefsSheetState();
}

class _NotificationPrefsSheetState extends State<NotificationPrefsSheet> {
  late bool _sessions;
  late bool _fixtures;
  late bool _fees;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _sessions = AppStore.notifySessions(widget.role);
    _fixtures = AppStore.notifyFixtures(widget.role);
    _fees = AppStore.notifyFees(widget.role);
  }

  Future<void> _done() async {
    if (_saving) {
      return;
    }
    setState(() => _saving = true);
    await AppStore.saveNotifications(
      role: widget.role,
      sessions: _sessions,
      fixtures: _fixtures,
      fees: widget.includeFees ? _fees : null,
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Notifications', style: TextStyle(fontSize: 22, color: widget.ink, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          activeThumbColor: widget.accent,
          title: Text('Session reminders', style: TextStyle(color: widget.ink, fontWeight: FontWeight.w700)),
          value: _sessions,
          onChanged: _saving ? null : (bool value) => setState(() => _sessions = value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          activeThumbColor: widget.accent,
          title: Text('Fixture updates', style: TextStyle(color: widget.ink, fontWeight: FontWeight.w700)),
          value: _fixtures,
          onChanged: _saving ? null : (bool value) => setState(() => _fixtures = value),
        ),
        if (widget.includeFees)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: widget.accent,
            title: Text('Fee reminders', style: TextStyle(color: widget.ink, fontWeight: FontWeight.w700)),
            value: _fees,
            onChanged: _saving ? null : (bool value) => setState(() => _fees = value),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _saving ? null : _done,
            child: Text(_saving ? 'Saving' : 'Done', style: TextStyle(color: widget.accent, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}
