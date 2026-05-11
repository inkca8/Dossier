import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StatsEditor extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final VoidCallback onChanged;

  const StatsEditor({
    super.key,
    required this.controllers,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: controllers.entries.map((e) {
        return SizedBox(
          width: 92,
          child: TextField(
            controller: e.value,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              labelText: e.key,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
        );
      }).toList(),
    );
  }
}
