import 'package:flutter/material.dart';
import 'package:meet_action/core/theme/meet_action_theme.dart';
import 'package:meet_action/features/meetings/domain/entities/participant.dart';

class AssigneeMappingDialog extends StatefulWidget {
  final List<String> detectedNames;
  final ValueChanged<Map<String, Participant>> onConfirm;

  const AssigneeMappingDialog({
    super.key,
    required this.detectedNames,
    required this.onConfirm,
  });

  @override
  State<AssigneeMappingDialog> createState() => _AssigneeMappingDialogState();
}

class _AssigneeMappingDialogState extends State<AssigneeMappingDialog> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _errors = {};

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  void initState() {
    super.initState();
    for (final name in widget.detectedNames) {
      _controllers[name] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim());
  }

  void _submit() {
    final mapping = <String, Participant>{};
    bool hasError = false;
    final newErrors = <String, String?>{};

    for (final entry in _controllers.entries) {
      final email = entry.value.text.trim();
      if (email.isNotEmpty) {
        if (!_isValidEmail(email)) {
          newErrors[entry.key] = 'Correo no válido (ej. nombre@empresa.com)';
          hasError = true;
        } else {
          mapping[entry.key] = Participant(
            id: 'user-${entry.key.toLowerCase().replaceAll(' ', '_')}',
            name: entry.key,
            email: email.toLowerCase(),
          );
        }
      }
    }

    setState(() {
      _errors.clear();
      _errors.addAll(newErrors);
    });

    if (hasError) return;

    widget.onConfirm(mapping);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: MeetActionTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Colors.white12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: MeetActionTheme.primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.people_alt_rounded,
                      color: MeetActionTheme.primaryLight,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Asignar Correos a Participantes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Gemini detectó los siguientes nombres en el audio. Asigna sus correos válidos para sincronizar sus recordatorios:',
                style: TextStyle(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ...widget.detectedNames.map((name) {
                final error = _errors[name];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 18, color: MeetActionTheme.primaryLight),
                          const SizedBox(width: 6),
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _controllers[name],
                        autofocus: widget.detectedNames.indexOf(name) == 0,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Correo (ej. ${name.toLowerCase()}@empresa.com)',
                          hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                          errorText: error,
                          errorStyle: const TextStyle(color: MeetActionTheme.accentColor, fontSize: 11),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: MeetActionTheme.primaryColor),
                          ),
                        ),
                        onChanged: (_) {
                          if (_errors[name] != null) {
                            setState(() {
                              _errors.remove(name);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Omitir', style: TextStyle(color: Colors.white60)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MeetActionTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: _submit,
                    child: const Text('Confirmar Asignaciones', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
