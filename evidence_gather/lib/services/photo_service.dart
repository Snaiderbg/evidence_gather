import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for handling photo capture and management
class PhotoService {
  final ImagePicker _picker = ImagePicker();
  final List<File> _tempFiles = [];

  /// Take a photo using the device camera
  Future<File?> takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      
      if (pickedFile == null) {
        return null;
      }
      
      // Create a temporary file that will be cleaned up later
      final file = File(pickedFile.path);
      _tempFiles.add(file);
      
      return file;
    } catch (e) {
      throw Exception('Failed to take photo: $e');
    }
  }

  /// Pick a photo from the device gallery
  Future<File?> pickPhotoFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      
      if (pickedFile == null) {
        return null;
      }
      
      // Create a temporary file that will be cleaned up later
      final file = File(pickedFile.path);
      _tempFiles.add(file);
      
      return file;
    } catch (e) {
      throw Exception('Failed to pick photo: $e');
    }
  }

  /// Pick multiple photos from the device gallery
  Future<List<File>> pickMultiplePhotos() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      
      if (pickedFiles.isEmpty) {
        return [];
      }
      
      // Create temporary files that will be cleaned up later
      final files = pickedFiles.map((xFile) => File(xFile.path)).toList();
      _tempFiles.addAll(files);
      
      return files;
    } catch (e) {
      throw Exception('Failed to pick multiple photos: $e');
    }
  }

  /// Clean up temporary files
  Future<void> cleanupTempFiles() async {
    for (final file in _tempFiles) {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignore errors when cleaning up
      }
    }
    _tempFiles.clear();
  }
} 