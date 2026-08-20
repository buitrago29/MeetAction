import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meet_action/features/recording/presentation/widgets/waveform_visualizer.dart';

void main() {
  Widget createWidgetUnderTest({required bool isRecording}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: WaveformVisualizer(
            isRecording: isRecording,
            barCount: 15,
          ),
        ),
      ),
    );
  }

  testWidgets('should render WaveformVisualizer container and bars', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(isRecording: true));

    expect(find.byType(WaveformVisualizer), findsOneWidget);
    // Find containers rendered for bars
    expect(find.byKey(const Key('waveform_container')), findsOneWidget);
  });

  testWidgets('should animate or display static state when paused/stopped', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(isRecording: false));

    expect(find.byType(WaveformVisualizer), findsOneWidget);
  });
}
