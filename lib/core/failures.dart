sealed class Failure implements Exception {
  final String message;
  Failure(this.message);

  @override
  String toString() => message;
}

class FileNotFoundFailure extends Failure {
  FileNotFoundFailure({required String filename}) :
    super('File not found: $filename');
}

class DataIsEmptyFailure extends Failure {
  DataIsEmptyFailure(super.message);
}

