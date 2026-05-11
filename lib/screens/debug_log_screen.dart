import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/logger.dart';

class DebugLogScreen extends StatelessWidget {
  const DebugLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = AppLogger.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug log'),
        actions: [
          IconButton(
            tooltip: 'Copy all',
            icon: const Icon(Icons.copy_all_outlined),
            onPressed: () {
              final text = logger.entries.value
                  .map((e) => e.formatFull())
                  .join('\n');
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Log copied to clipboard.')),
              );
            },
          ),
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: logger.clear,
          ),
        ],
      ),
      body: ValueListenableBuilder<List<LogEntry>>(
        valueListenable: logger.entries,
        builder: (context, entries, _) {
          if (entries.isEmpty) {
            return const Center(child: Text('No log entries yet.'));
          }
          return ListView.separated(
            reverse: false,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final e = entries[entries.length - 1 - i];
              final color = switch (e.level) {
                LogLevel.error => Theme.of(context).colorScheme.error,
                LogLevel.warn => Colors.orange,
                LogLevel.info => Theme.of(context).colorScheme.onSurfaceVariant,
              };
              return ListTile(
                dense: true,
                leading: Icon(
                  switch (e.level) {
                    LogLevel.error => Icons.error_outline,
                    LogLevel.warn => Icons.warning_amber_outlined,
                    LogLevel.info => Icons.info_outline,
                  },
                  color: color,
                  size: 18,
                ),
                title: SelectableText(
                  e.message,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
                subtitle: Text(
                  e.time.toIso8601String().substring(11, 23),
                  style: const TextStyle(fontSize: 10),
                ),
                onTap: e.error == null && e.stack == null
                    ? null
                    : () => _showDetail(context, e),
              );
            },
          );
        },
      ),
    );
  }

  void _showDetail(BuildContext context, LogEntry e) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log entry'),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: SelectableText(
              e.formatFull(),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Clipboard.setData(ClipboardData(text: e.formatFull())),
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
