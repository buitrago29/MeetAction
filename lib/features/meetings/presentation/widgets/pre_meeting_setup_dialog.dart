import 'package:flutter/material.dart';
import 'package:meet_action/core/theme/meet_action_theme.dart';

class PreMeetingSetupDialog extends StatefulWidget {
  final ValueChanged<List<String>>? onStart;

  const PreMeetingSetupDialog({
    super.key,
    this.onStart,
  });

  @override
  State<PreMeetingSetupDialog> createState() => _PreMeetingSetupDialogState();
}

class _PreMeetingSetupDialogState extends State<PreMeetingSetupDialog> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final List<String> _emails = [];
  String? _errorMessage;

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim());
  }

  void _addEmail() {
    final text = _emailController.text.trim();
    if (text.isEmpty) return;

    if (!_isValidEmail(text)) {
      setState(() {
        _errorMessage = 'Ingresa un correo electrónico válido (ej. usuario@empresa.com)';
      });
      _emailFocusNode.requestFocus();
      return;
    }

    if (_emails.contains(text.toLowerCase())) {
      setState(() {
        _errorMessage = 'Este correo ya fue agregado a la lista';
      });
      _emailFocusNode.requestFocus();
      return;
    }

    setState(() {
      _emails.add(text.toLowerCase());
      _emailController.clear();
      _errorMessage = null;
    });

    // Zero-Friction: keep focus on the text box for the next email immediately
    _emailFocusNode.requestFocus();
  }

  void _removeEmail(String email) {
    setState(() {
      _emails.remove(email);
      _errorMessage = null;
    });
    _emailFocusNode.requestFocus();
  }

  void _submit() {
    final pendingText = _emailController.text.trim();
    if (pendingText.isNotEmpty) {
      if (!_isValidEmail(pendingText)) {
        setState(() {
          _errorMessage = 'El correo ingresado no es válido. Corrígelo o bórralo antes de continuar.';
        });
        _emailFocusNode.requestFocus();
        return;
      }
      if (!_emails.contains(pendingText.toLowerCase())) {
        _emails.add(pendingText.toLowerCase());
      }
    }

    widget.onStart?.call(_emails);
    Navigator.of(context).pop(_emails);
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
                      Icons.mark_email_read_rounded,
                      color: MeetActionTheme.primaryLight,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Invitados a la Reunión',
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
                'Agrega los correos válidos de los asistentes para sincronizar sus recordatorios:',
                style: TextStyle(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'ejemplo@empresa.com',
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
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
                        if (_errorMessage != null) {
                          setState(() {
                            _errorMessage = null;
                          });
                        }
                      },
                      onSubmitted: (_) => _addEmail(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: MeetActionTheme.primaryColor,
                      padding: const EdgeInsets.all(12),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: _addEmail,
                  ),
                ],
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 14, color: MeetActionTheme.accentColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: MeetActionTheme.accentColor, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              if (_emails.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _emails.map((email) {
                    return Chip(
                      backgroundColor: MeetActionTheme.primaryColor.withValues(alpha: 0.2),
                      side: BorderSide(color: MeetActionTheme.primaryColor.withValues(alpha: 0.4)),
                      avatar: const Icon(Icons.person, size: 16, color: MeetActionTheme.primaryLight),
                      label: Text(
                        email,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white70),
                      onDeleted: () => _removeEmail(email),
                    );
                  }).toList(),
                )
              else
                const Text(
                  'No has agregado invitados aún. (Opcional)',
                  style: TextStyle(fontSize: 12, color: Colors.white38, fontStyle: FontStyle.italic),
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar', style: TextStyle(color: Colors.white60)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MeetActionTheme.accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    onPressed: _submit,
                    child: const Text('Comenzar Grabación', style: TextStyle(fontWeight: FontWeight.bold)),
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
