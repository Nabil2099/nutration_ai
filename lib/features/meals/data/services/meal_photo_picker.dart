import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Where a meal photo comes from: a fresh camera shot or the gallery.
enum MealPhotoSource { camera, gallery }

class MealPhotoPickerException implements Exception {
  const MealPhotoPickerException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Captures or selects a meal photo and returns its compressed bytes.
/// Matches the [AddMealScreen] injection shape (`null` = user cancelled).
typedef MealPhotoPickerFn = Future<Uint8List?> Function(MealPhotoSource source);

class MealPhotoPicker {
  const MealPhotoPicker();

  /// Picks a photo from [source], resized to at most 1024 px on the longest
  /// side and re-encoded as JPEG (~85 quality) to keep the Gemini payload
  /// small. Returns `null` when the user cancels.
  Future<Uint8List?> pick(MealPhotoSource source) async {
    try {
      final file = await ImagePicker().pickImage(
        source: source == MealPhotoSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null) return null;
      return await file.readAsBytes();
    } on MealPhotoPickerException {
      rethrow;
    } on MissingPluginException {
      throw const MealPhotoPickerException(
        'Photo capture is not supported on this device yet.',
      );
    } on PlatformException {
      throw const MealPhotoPickerException(
        'Could not open the camera or gallery. Please try again.',
      );
    } catch (_) {
      throw const MealPhotoPickerException(
        'Could not open the camera or gallery. Please try again.',
      );
    }
  }
}
