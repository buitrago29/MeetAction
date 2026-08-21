import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:meet_action/core/theme/meet_action_theme.dart';

class MeetingQrDialog extends StatelessWidget {
  final String joinCode;
  final String meetingTitle;

  const MeetingQrDialog({
    super.key,
    required this.joinCode,
    required this.meetingTitle,
  });

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
            children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MeetActionTheme.primaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.qr_code_2_rounded,
                color: MeetActionTheme.primaryColor,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Código de la Sala',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              meetingTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),

            // QR Code Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: joinCode,
                version: QrVersions.auto,
                size: 160.0,
              ),
            ),
            const SizedBox(height: 20),

            // Big PIN Code Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: MeetActionTheme.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: MeetActionTheme.primaryColor.withValues(alpha: 0.3)),
              ),
              child: SelectableText(
                joinCode,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: MeetActionTheme.primaryLight,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pide a los asistentes que escaneen el QR o ingresen el código desde su app MeetAction.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.white54),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MeetActionTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Listo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}
