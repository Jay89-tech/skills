// lib/services/file_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../utils/constants.dart';

class FileService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  FileService._internal();

  final ImagePicker _imagePicker = ImagePicker();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile(String filename) async {
    final path = await _localPath;
    return File('$path/$filename');
  }

  Future<String?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        // Check file size
        final fileSize = await image.length();
        if (fileSize > AppConstants.maxFileSize) {
          throw Exception('File size too large. Maximum size is ${AppConstants.maxFileSize / (1024 * 1024)}MB');
        }

        // Check file type
        final extension = image.path.split('.').last.toLowerCase();
        if (!AppConstants.allowedImageTypes.contains(extension)) {
          throw Exception('Invalid file type. Allowed types: ${AppConstants.allowedImageTypes.join(', ')}');
        }

        // Copy to app directory
        final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.$extension';
        final savedFile = await _localFile(fileName);
        await savedFile.writeAsBytes(await image.readAsBytes());

        return savedFile.path;
      }
    } catch (e) {
      print('Error picking image: $e');
      rethrow;
    }
    return null;
  }

  Future<String?> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.allowedDocumentTypes,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        
        // Check file size
        final fileSize = await file.length();
        if (fileSize > AppConstants.maxFileSize) {
          throw Exception('File size too large. Maximum size is ${AppConstants.maxFileSize / (1024 * 1024)}MB');
        }

        // Copy to app directory
        final fileName = 'doc_${DateTime.now().millisecondsSinceEpoch}.${result.files.single.extension}';
        final savedFile = await _localFile(fileName);
        await savedFile.writeAsBytes(await file.readAsBytes());

        return savedFile.path;
      }
    } catch (e) {
      print('Error picking document: $e');
      rethrow;
    }
    return null;
  }

  Future<bool> saveFile(String filename, Uint8List data) async {
    try {
      final file = await _localFile(filename);
      await file.writeAsBytes(data);
      return true;
    } catch (e) {
      print('Error saving file: $e');
      return false;
    }
  }

  Future<Uint8List?> readFile(String filename) async {
    try {
      final file = await _localFile(filename);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    } catch (e) {
      print('Error reading file: $e');
    }
    return null;
  }

  Future<bool> deleteFile(String filename) async {
    try {
      final file = await _localFile(filename);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
    return false;
  }

  Future<List<String>> getLocalFiles() async {
    try {
      final directory = Directory(await _localPath);
      final files = await directory.list().toList();
      return files
          .where((entity) => entity is File)
          .map((file) => file.path.split('/').last)
          .toList();
    } catch (e) {
      print('Error getting local files: $e');
      return [];
    }
  }
}