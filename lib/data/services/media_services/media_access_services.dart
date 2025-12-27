// media_service.dart
// A single service file to handle media access: permissions, picking images (camera/gallery),
// picking multiple images, picking files (pdf/doc/others), and some helpers.
//
// Packages required (add to pubspec.yaml):
//   permission_handler: ^10.4.0
//   image_picker: ^0.8.7+4
//   file_picker: ^5.2.5
//   path_provider: ^2.0.15
//   flutter_image_compress: ^1.1.0  // optional, only if you want compression
//
// Platform setup notes:
// Android (android/app/src/main/AndroidManifest.xml):
//  - <uses-permission android:name="android.permission.INTERNET" />
//  - <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
//  - <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
//  - <uses-permission android:name="android.permission.CAMERA" />
//
// iOS (ios/Runner/Info.plist):
//  - NSCameraUsageDescription
//  - NSPhotoLibraryUsageDescription
//  - NSPhotoLibraryAddUsageDescription
//  - NSSpeechRecognitionUsageDescription (if needed)
//
// NOTE: From Android 13+ you may need more granular media permissions (READ_MEDIA_IMAGES, READ_MEDIA_VIDEO).
// permission_handler version and Android SDK must be configured accordingly.

import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as Math;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../firebase_service/firebase_storage_service.dart';

/// MediaType enum
enum MediaType { image, video, any }

/// Result wrapper for picked media
class PickedMedia {
  final File file;
  final String name;
  final String extension;
  final int sizeBytes;

  PickedMedia({required this.file})
      : name = p.basename(file.path),
        extension = p.extension(file.path),
        sizeBytes = file.lengthSync();
}

/// MediaService - centralized media/file access + permissions
class MediaService {
  MediaService._private();
  static final MediaService instance = MediaService._private();

  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorageService _firebaseStorageService = FirebaseStorageService.instance;

  /// Request necessary permissions for gallery and camera
  Future<bool> requestPermissions({bool camera = true, bool photos = true}) async {
    final statuses = <Permission, PermissionStatus>{};

    if (camera) {
      statuses[Permission.camera] = await Permission.camera.status;
      if (!statuses[Permission.camera]!.isGranted) {
        statuses[Permission.camera] = await Permission.camera.request();
      }
    }

    // For Android 13+ or newer APIs, permission_handler manages READ_MEDIA_* automatically
    if (photos) {
      // On Android use storage or image/media permission depending on OS.
      if (Platform.isAndroid) {
        // Try the more specific permissions first (Android 13+)
        final pImg = Permission.photos; // permission_handler maps to platform-specific
        statuses[pImg] = await pImg.status;
        if (!statuses[pImg]!.isGranted) {
          statuses[pImg] = await pImg.request();
        }
      } else if (Platform.isIOS) {
        statuses[Permission.photos] = await Permission.photos.status;
        if (!statuses[Permission.photos]!.isGranted) {
          statuses[Permission.photos] = await Permission.photos.request();
        }
      }
    }

    // Check results
    final allGranted = statuses.values.every((s) => s.isGranted);
    return allGranted;
  }

  /// Check permission and open camera to take a photo. Returns PickedMedia or null.
  Future<PickedMedia?> pickImageFromCamera({int imageQuality = 85, bool saveToGallery = false}) async {
    final perm = await Permission.camera.status;
    if (!perm.isGranted) {
      final granted = await Permission.camera.request();
      if (!granted.isGranted) return null;
    }

    final XFile? picked = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: imageQuality);
    if (picked == null) return null;

    // Optionally save to gallery (platform-specific handling required)
    final file = File(picked.path);

    // if (saveToGallery) { ... }

    return PickedMedia(file: file);
  }

  /// Pick single image from gallery (returns PickedMedia)
  Future<PickedMedia?> pickImageFromGallery({int imageQuality = 85}) async {
    // request permission where necessary
    if (Platform.isAndroid) {
      // On Android, external storage or photos permission
      final pStatus = await Permission.photos.status;
      if (!pStatus.isGranted) {
        final req = await Permission.photos.request();
        if (!req.isGranted) return null;
      }
    } else if (Platform.isIOS) {
      final pStatus = await Permission.photos.status;
      if (!pStatus.isGranted) {
        final req = await Permission.photos.request();
        if (!req.isGranted) return null;
      }
    }

    final XFile? picked = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: imageQuality);
    if (picked == null) return null;

    return PickedMedia(file: File(picked.path));
  }

  /// Pick multiple images using ImagePicker (if supported) or FilePicker fallback
  Future<List<PickedMedia>> pickMultipleImages({int imageQuality = 85}) async {
    try {
      // image_picker has pickMultiImage
      final List<XFile>? pickedFiles = await _imagePicker.pickMultiImage(imageQuality: imageQuality);
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        return pickedFiles.map((x) => PickedMedia(file: File(x.path))).toList();
      }
    } catch (_) {
      // ignore and fallback to FilePicker
    }

    // Fallback: use FilePicker for images
    final result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.image);
    if (result == null || result.files.isEmpty) return [];
    return result.files.map((f) => PickedMedia(file: File(f.path!))).toList();
  }

  /// Pick generic files (pdf, doc, etc). Provide allowedExtensions for filtering.
  Future<List<PickedMedia>> pickFiles({
    List<String>? allowedExtensions,
    bool allowMultiple = true,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      type: allowedExtensions == null ? FileType.any : FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (result == null || result.files.isEmpty) return [];
    return result.files
        .where((pf) => pf.path != null)
        .map((pf) => PickedMedia(file: File(pf.path!)))
        .toList();
  }

  /// Pick either images or files depending on MediaType
  Future<List<PickedMedia>> pickMedia({
    required MediaType mediaType,
    bool allowMultiple = true,
  }) async {
    switch (mediaType) {
      case MediaType.image:
        return await pickMultipleImages();
      case MediaType.video:
      // For simplicity, use FilePicker for videos
        final res = await FilePicker.platform.pickFiles(allowMultiple: allowMultiple, type: FileType.video);
        if (res == null || res.files.isEmpty) return [];
        return res.files.where((pf) => pf.path != null).map((pf) => PickedMedia(file: File(pf.path!))).toList();
      case MediaType.any:
      return await pickFiles(allowMultiple: allowMultiple);
    }
  }

  /// Save bytes to temporary file and return PickedMedia
  Future<PickedMedia> saveBytesToTemp(Uint8List bytes, {String? fileName}) async {
    final dir = await getTemporaryDirectory();
    final name = fileName ?? 'tmp_${DateTime.now().millisecondsSinceEpoch}';
    final path = p.join(dir.path, name);
    final file = await File(path).writeAsBytes(bytes);
    return PickedMedia(file: file);
  }

  // compress file to bytes
  Future<Uint8List?> compressImageFile(File file, {
    int quality = 75,       // adjust 50-85 for balance
    int maxWidth = 800,     // resize main image
    int maxHeight = 800,
    String format = 'webp'  // 'jpeg' or 'webp' (webp smaller)
  }) async {
    final targetExt = format == 'webp' ? CompressFormat.webp : CompressFormat.jpeg;
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: quality,
      minWidth: maxWidth,
      minHeight: maxHeight,
      format: targetExt,
    );
    return result != null ? Uint8List.fromList(result) : null;
  }

  Future<String?> uploadCompressedProfileImage(String cid,File imageFile) async {
    try {
      // STEP 1 — Compress image
      final Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        quality: 80,      // reduce if you want smaller file
        minWidth: 600,
        minHeight: 600,
        format: CompressFormat.webp, // webp gives best size
      );

      if (compressedBytes == null) {
        throw Exception("Image compression failed");
      }

      // STEP 2 — Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = "profile_$timestamp.webp";

      // STEP 3 — Upload to Firebase using your FirebaseStorageService
      final String downloadUrl = await _firebaseStorageService.uploadBytes(
        data: compressedBytes,
        fileName: fileName,
        directory: "profile",
        cid: cid,
        metadata: SettableMetadata(
          contentType: "image/webp",
          cacheControl: "public,max-age=31536000", // cache 1 year
        ),
      );

      return downloadUrl;
    } catch (e) {
      print("Upload Error: $e");
      return null;
    }
  }

  /// Optional: compress image and return new File (requires flutter_image_compress)
  /*
  Future<File?> compressImage(File file, {int quality = 80, int minWidth = 800}) async {
    final targetPath = (await getTemporaryDirectory()).path + '/cmp_${p.basename(file.path)}';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
      minWidth: minWidth,
    );

    return result;
  }
  */

  /// Utility: get size in KB/MB
  static String humanFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    final i = (Math.log(bytes) / Math.log(1024)).floor();
    final size = bytes / Math.pow(1024, i);
    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }
}



/*
Usage examples:

// 1) Request permissions first
final ok = await MediaService.instance.requestPermissions();
if (!ok) {
  // show dialog: please grant permissions
}

// 2) Pick single image from gallery
final picked = await MediaService.instance.pickImageFromGallery();
if (picked != null) {
  print(picked.file.path);
}

// 3) Pick multiple images
final images = await MediaService.instance.pickMultipleImages();

// 4) Pick PDFs
final pdfs = await MediaService.instance.pickFiles(allowedExtensions: ['pdf'], allowMultiple: true);

// 5) Pick any files
final files = await MediaService.instance.pickFiles();

// 6) Save bytes to temp
final tmp = await MediaService.instance.saveBytesToTemp(bytes, fileName: 'report.pdf');

Notes:
- Always check for null and handle user cancellation.
- On Android 13+ you may need to request READ_MEDIA_IMAGES / READ_MEDIA_VIDEO instead of general storage permission.
- FilePicker returns platform-native bytes and path; on web `path` may be null — handle accordingly.
*/
