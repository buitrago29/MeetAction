import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:meet_action/core/theme/meet_action_theme.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';
import 'package:meet_action/features/export_share/domain/usecases/format_whatsapp_summary.dart';
import 'package:meet_action/features/export_share/domain/usecases/generate_meeting_pdf.dart';
import 'package:meet_action/features/meetings/domain/entities/meeting.dart';
import 'package:meet_action/features/meetings/presentation/widgets/meeting_detail_view.dart';
import 'package:meet_action/features/minutes_ai/domain/entities/meeting_minutes.dart';

class MeetingDetailScreen extends StatefulWidget {
  final Meeting meeting;
  final MeetingMinutes? minutes;
  final List<ActionItem> initialActionItems;

  const MeetingDetailScreen({
    super.key,
    required this.meeting,
    this.minutes,
    this.initialActionItems = const [],
  });

  @override
  State<MeetingDetailScreen> createState() => _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends State<MeetingDetailScreen> {
  late List<ActionItem> _actionItems;
  final GenerateMeetingPdf _generateMeetingPdf = GenerateMeetingPdf();
  final FormatWhatsAppSummary _formatWhatsAppSummary = FormatWhatsAppSummary();

  @override
  void initState() {
    super.initState();
    _actionItems = List.from(widget.initialActionItems);
  }

  void _handleStatusChange(ActionItem item, ActionItemStatus newStatus) {
    setState(() {
      final index = _actionItems.indexWhere((ai) => ai.id == item.id);
      if (index != -1) {
        _actionItems[index] = item.copyWith(status: newStatus);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus == ActionItemStatus.completed
              ? '✅ Compromiso completado'
              : 'Compromiso marcado como pendiente',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _exportPdf() async {
    final pdfResult = await _generateMeetingPdf(
      GenerateMeetingPdfParams(
        meeting: widget.meeting,
        minutes: widget.minutes,
        actionItems: _actionItems,
      ),
    );

    pdfResult.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al generar PDF: ${failure.message}'),
            backgroundColor: MeetActionTheme.accentColor,
          ),
        );
      },
      (bytes) async {
        final filename =
            'Acta_${widget.meeting.title.replaceAll(' ', '_')}.pdf';
        await Printing.sharePdf(bytes: bytes, filename: filename);
      },
    );
  }

  Future<void> _shareWhatsApp() async {
    final summaryResult = _formatWhatsAppSummary(
      FormatWhatsAppSummaryParams(
        meeting: widget.meeting,
        minutes: widget.minutes,
        actionItems: _actionItems,
      ),
    );

    summaryResult.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al formatear texto: ${failure.message}'),
            backgroundColor: MeetActionTheme.accentColor,
          ),
        );
      },
      (text) async {
        await SharePlus.instance.share(
          ShareParams(
            text: text,
            subject: 'Acta de Reunión: ${widget.meeting.title}',
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Reunión'),
        actions: [
          IconButton(
            tooltip: 'Exportar PDF',
            icon: const Icon(Icons.picture_as_pdf_rounded),
            onPressed: _exportPdf,
          ),
          IconButton(
            tooltip: 'Compartir en WhatsApp',
            icon: const Icon(Icons.send_rounded),
            onPressed: _shareWhatsApp,
          ),
        ],
      ),
      body: MeetingDetailView(
        meeting: widget.meeting,
        minutes: widget.minutes,
        actionItems: _actionItems,
        onActionItemStatusChanged: _handleStatusChange,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: MeetActionTheme.surfaceDark,
          border: Border(
            top: BorderSide(color: Color(0xFF334155), width: 1),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: MeetActionTheme.primaryLight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.picture_as_pdf_outlined,
                      color: MeetActionTheme.primaryLight),
                  label: const Text(
                    'Exportar PDF',
                    style: TextStyle(
                      color: MeetActionTheme.primaryLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: _exportPdf,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: const Text(
                    'WhatsApp',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onPressed: _shareWhatsApp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
