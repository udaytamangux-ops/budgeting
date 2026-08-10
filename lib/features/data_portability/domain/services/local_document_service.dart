import 'dart:typed_data';

enum DocumentSaveResult { saved, cancelled }

final class SelectedDocument {
  const SelectedDocument({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

abstract interface class LocalDocumentService {
  Future<DocumentSaveResult> save({
    required String suggestedName,
    required String extension,
    required Uint8List bytes,
  });

  Future<SelectedDocument?> openJson({required int maximumBytes});
}
