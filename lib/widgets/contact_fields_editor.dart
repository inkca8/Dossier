import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContactFieldsEditor extends StatelessWidget {
  final TextEditingController name;
  final TextEditingController race;
  final TextEditingController charClass;
  final TextEditingController level;
  final VoidCallback onChanged;

  const ContactFieldsEditor({
    super.key,
    required this.name,
    required this.race,
    required this.charClass,
    required this.level,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: name,
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: race,
                onChanged: (_) => onChanged(),
                decoration: const InputDecoration(
                  labelText: 'Race',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: charClass,
                onChanged: (_) => onChanged(),
                decoration: const InputDecoration(
                  labelText: 'Class',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 88,
              child: TextField(
                controller: level,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => onChanged(),
                decoration: const InputDecoration(
                  labelText: 'Level',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
