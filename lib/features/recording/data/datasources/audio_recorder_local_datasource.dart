import 'package:record/record.dart';

abstract class AudioRecorderLocalDataSource {
  Future<void> startRecording({required String path});
  Future<void> pauseRecording();
  Future<void> resumeRecording();
  Future<String?> stopRecording();
  Future<bool> isRecording();
  Future<bool> isPaused();
  Future<bool> hasPermission();
}

class AudioRecorderLocalDataSourceImpl implements AudioRecorderLocalDataSource {
  final AudioRecorder _audioRecorder;

  AudioRecorderLocalDataSourceImpl({AudioRecorder? audioRecorder})
      : _audioRecorder = audioRecorder ?? AudioRecorder();

  @override
  Future<bool> hasPermission() async {
    return await _audioRecorder.hasPermission();
  }

  @override
  Future<void> startRecording({required String path}) async {
    final hasPerm = await hasPermission();
    if (!hasPerm) {
      throw Exception('Microphone permission not granted');
    }
    const config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      bitRate: 128000,
      sampleRate: 44100,
    );
    await _audioRecorder.start(config, path: path);
  }

  @override
  Future<void> pauseRecording() async {
    await _audioRecorder.pause();
  }

  @override
  Future<void> resumeRecording() async {
    await _audioRecorder.resume();
  }

  @override
  Future<String?> stopRecording() async {
    return await _audioRecorder.stop();
  }

  @override
  Future<bool> isRecording() async {
    return await _audioRecorder.isRecording();
  }

  @override
  Future<bool> isPaused() async {
    return await _audioRecorder.isPaused();
  }
}
