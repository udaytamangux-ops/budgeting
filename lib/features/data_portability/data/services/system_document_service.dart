import 'dart:typed_data';

import 'package:budgeting_app/features/data_portability/domain/services/backup_exceptions.dart';
import 'package:budgeting_app/features/data_portability/domain/services/local_document_service.dart';
import 'package:file_picker/file_picker.dart';

final class SystemDocumentService implements LocalDocumentService {
  const SystemDocumentService();

  @override
  Future<DocumentSaveResult> save({
    required String suggestedName,
    required String extension,
    required Uint8List bytes,
  }) async {
    final String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save $extension file',
      fileName: suggestedName,
      type: FileType.custom,
      allowedExtensions: <String>[extension],
      bytes: bytes,
    );
    return path == null
        ? DocumentSaveResult.cancelled
        : DocumentSaveResult.saved;
  }

  @override
  Future<SelectedDocument?> openJson({required int maximumBytes}) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Choose a backup file',
      type: FileType.custom,
      allowedExtensions: const <String>['json'],
      allowMultiple: false,
      withData: true,
    );
    if (result == null) return null;
    final PlatformFile file = result.files.single;
    if (file.size > maximumBytes) {
      throw const BackupValidationException(
        BackupValidationIssue.oversized,
        'This backup file is larger than the supported 10 MB limit.',
      );
    }
    final Uint8List? bytes = file.bytes;
    if (bytes == null) {
      throw const BackupValidationException(
        BackupValidationIssue.malformed,
        'This backup file could not be read.',
      );
    }
    return SelectedDocument(name: file.name, bytes: bytes);
  }
}
