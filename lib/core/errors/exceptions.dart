class DatabaseException implements Exception {
  final String message;
  const DatabaseException(this.message);
  
  @override
  String toString() => 'DatabaseException: $message';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
  
  @override
  String toString() => 'ValidationException: $message';
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException(this.message);
  
  @override
  String toString() => 'NotFoundException: $message';
}
