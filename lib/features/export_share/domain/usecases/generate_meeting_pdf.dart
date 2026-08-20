import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/core/usecases/usecase.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';
import 'package:meet_action/features/meetings/domain/entities/meeting.dart';
import 'package:meet_action/features/minutes_ai/domain/entities/meeting_minutes.dart';

class GenerateMeetingPdf
    implements UseCase<Uint8List, GenerateMeetingPdfParams> {
  @override
  Future<Either<Failure, Uint8List>> call(
      GenerateMeetingPdfParams params) async {
    try {
      final doc = pw.Document();
      final dateStr =
          DateFormat('dd/MM/yyyy HH:mm').format(params.meeting.createdAt);
      final durationMinutes = params.meeting.duration.inMinutes;

      final primaryColor = PdfColor.fromHex('#5B4DFF');
      final secondaryColor = PdfColor.fromHex('#06B6D4');
      final darkColor = PdfColor.fromHex('#1E293B');
      final lightGray = PdfColor.fromHex('#F1F5F9');

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          header: (pw.Context context) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 20),
              padding: const pw.EdgeInsets.only(bottom: 10),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'MeetAction',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  pw.Text(
                    'Acta Oficial de Reunion',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            );
          },
          footer: (pw.Context context) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(top: 20),
              padding: const pw.EdgeInsets.only(top: 10),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: PdfColors.grey300, width: 1),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Generado con IA por MeetAction',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Text(
                    'Pagina ${context.pageNumber} de ${context.pagesCount}',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            );
          },
          build: (pw.Context context) => [
            // Meeting Title & Metadata Banner
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: lightGray,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    params.meeting.title,
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: darkColor,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    children: [
                      pw.Text(
                        'Fecha: $dateStr',
                        style: const pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.SizedBox(width: 20),
                      pw.Text(
                        'Duracion: $durationMinutes min',
                        style: const pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey800,
                        ),
                      ),
                    ],
                  ),
                  if (params.meeting.participants.isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Participantes: ${params.meeting.participants.join(', ')}',
                      style: const pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.grey800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Executive Summary
            if (params.minutes != null) ...[
              pw.Text(
                'Resumen Ejecutivo',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                params.minutes!.executiveSummary,
                style: const pw.TextStyle(
                  fontSize: 11,
                  lineSpacing: 2,
                  color: PdfColors.grey900,
                ),
              ),
              pw.SizedBox(height: 16),

              // Topics Discussed
              if (params.minutes!.topics.isNotEmpty) ...[
                pw.Text(
                  'Temas Tratados',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(height: 6),
                ...params.minutes!.topics.map(
                  (topic) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 6),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '- ${topic.title}: ',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                        pw.Text(
                          topic.keyPoints,
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(height: 16),
              ],

              // Key Decisions
              if (params.minutes!.keyDecisions.isNotEmpty) ...[
                pw.Text(
                  'Decisiones Clave',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(height: 6),
                ...params.minutes!.keyDecisions.map(
                  (decision) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          width: 4,
                          height: 4,
                          margin: const pw.EdgeInsets.only(top: 4, right: 6),
                          decoration: pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            color: primaryColor,
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            decision,
                            style: const pw.TextStyle(
                              fontSize: 11,
                              color: PdfColors.grey900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(height: 16),
              ],
            ],

            // Action Items Table
            if (params.actionItems.isNotEmpty) ...[
              pw.Text(
                'Compromisos y Tareas Asignadas',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerStyle: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: pw.BoxDecoration(color: primaryColor),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellPadding: const pw.EdgeInsets.all(6),
                headers: [
                  '#',
                  'Responsable',
                  'Descripcion',
                  'Prioridad',
                  'Fecha Limite',
                  'Estado'
                ],
                data: List<List<String>>.generate(
                  params.actionItems.length,
                  (index) {
                    final item = params.actionItems[index];
                    return [
                      '${index + 1}',
                      item.assigneeName,
                      item.description,
                      _getPriorityName(item.priority),
                      item.dueDate != null
                          ? DateFormat('dd/MM/yyyy').format(item.dueDate!)
                          : 'N/A',
                      item.status == ActionItemStatus.completed
                          ? 'Completado'
                          : 'Pendiente',
                    ];
                  },
                ),
              ),
            ],
          ],
        ),
      );

      final pdfBytes = await doc.save();
      return Right(pdfBytes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  static String _getPriorityName(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.low:
        return 'Baja';
      case PriorityLevel.medium:
        return 'Media';
      case PriorityLevel.high:
        return 'Alta';
      case PriorityLevel.urgent:
        return 'Urgente';
    }
  }
}

class GenerateMeetingPdfParams extends Equatable {
  final Meeting meeting;
  final MeetingMinutes? minutes;
  final List<ActionItem> actionItems;

  const GenerateMeetingPdfParams({
    required this.meeting,
    this.minutes,
    required this.actionItems,
  });

  @override
  List<Object?> get props => [meeting, minutes, actionItems];
}
