import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';
import 'package:meet_action/core/errors/failures.dart';
import 'package:meet_action/features/action_items/domain/entities/action_item.dart';
import 'package:meet_action/features/meetings/domain/entities/meeting.dart';
import 'package:meet_action/features/minutes_ai/domain/entities/meeting_minutes.dart';

class FormatWhatsAppSummary {
  Either<Failure, String> call(FormatWhatsAppSummaryParams params) {
    try {
      final buffer = StringBuffer();
      final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(params.meeting.createdAt);
      final durationMinutes = params.meeting.duration.inMinutes;

      buffer.writeln('📋 *ACTA DE REUNIÓN: ${params.meeting.title}*');
      buffer.writeln('🗓️ *Fecha:* $dateStr | ⏱️ *Duración:* $durationMinutes min');
      
      if (params.meeting.participants.isNotEmpty) {
        buffer.writeln('👥 *Participantes:* ${params.meeting.participants.join(', ')}');
      }
      buffer.writeln();

      if (params.minutes != null) {
        buffer.writeln('📌 *RESUMEN EJECUTIVO:*');
        buffer.writeln(params.minutes!.executiveSummary);
        buffer.writeln();

        if (params.minutes!.keyDecisions.isNotEmpty) {
          buffer.writeln('🎯 *DECISIONES CLAVE:*');
          for (final decision in params.minutes!.keyDecisions) {
            buffer.writeln('• $decision');
          }
          buffer.writeln();
        }
      }

      if (params.actionItems.isNotEmpty) {
        buffer.writeln('✅ *COMPROMISOS Y TAREAS:*');
        for (int i = 0; i < params.actionItems.length; i++) {
          final item = params.actionItems[i];
          final priorityText = _getPriorityText(item.priority);
          final dueText = item.dueDate != null
              ? ' | Límite: ${DateFormat('dd/MM').format(item.dueDate!)}'
              : '';
          final statusIcon = item.status == ActionItemStatus.completed ? '☑️' : '⏳';

          buffer.writeln(
            '${i + 1}. $statusIcon 👤 *${item.assigneeName}*: ${item.description} (Prioridad: $priorityText$dueText)',
          );
        }
        buffer.writeln();
      }

      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━');
      buffer.write('_Generado automáticamente por MeetAction IA_ 🚀');

      return Right(buffer.toString());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  String _getPriorityText(PriorityLevel priority) {
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

class FormatWhatsAppSummaryParams extends Equatable {
  final Meeting meeting;
  final MeetingMinutes? minutes;
  final List<ActionItem> actionItems;

  const FormatWhatsAppSummaryParams({
    required this.meeting,
    this.minutes,
    required this.actionItems,
  });

  @override
  List<Object?> get props => [meeting, minutes, actionItems];
}
