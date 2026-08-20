class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server Exception']);

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache Exception']);

  @override
  String toString() => 'CacheException: $message';
}
