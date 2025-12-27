import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  FirebaseStorageService._private();

  static final FirebaseStorageService _instance = FirebaseStorageService._private();
  static FirebaseStorageService get instance => _instance;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Build a path scoped to current user if available.
  /// e.g. users/{uid}/profile.jpg or users/{uid}/documents/<name>
  String _userScopedPath(String cid, String path) {
    return 'users/$cid/$path';
  }

  /// Upload a profile image file. Returns download URL string.
  /// - [file]: local File to upload
  /// - [fileName]: optional filename (default: profile.jpg)
  /// - [contentType]: optional content-type like 'image/jpeg'
  /// - [metadata]: optional Settable metadata
  Future<String> uploadProfileImage({
    required File file,
    required String cid,
    String fileName = 'profile.jpg',
    String? contentType,
    SettableMetadata? metadata,
    void Function(TaskSnapshot)? onStateChanged,
  }) async {
    final path = _userScopedPath('profile/$fileName',cid);
    final ref = _storage.ref().child(path);

    final uploadTask = ref.putFile(
      file,
      metadata ?? (contentType != null ? SettableMetadata(contentType: contentType) : null),
    );

    if (onStateChanged != null) {
      uploadTask.snapshotEvents.listen(onStateChanged);
    }

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Upload a generic file (pdf, image, etc) from File. Returns download URL.
  /// - [directory] e.g. 'documents', 'images', 'pdfs'
  /// - [fileName] required - include extension
  Future<String> uploadFile({
    required File file,
    required String fileName,
    required String cid,
    String directory = 'files',
    String? contentType,
    SettableMetadata? metadata,
    void Function(TaskSnapshot)? onStateChanged,
  }) async {
    final path = _userScopedPath('$directory/$fileName',cid);
    final ref = _storage.ref().child(path);

    final uploadTask = ref.putFile(
      file,
      metadata ?? (contentType != null ? SettableMetadata(contentType: contentType) : null),
    );

    if (onStateChanged != null) uploadTask.snapshotEvents.listen(onStateChanged);

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Upload bytes directly. Useful when you have Uint8List (picked image bytes / generated PDF bytes)
  Future<String> uploadBytes({
    required Uint8List data,
    required String fileName,
    required String cid,
    String directory = 'files',
    String? contentType,
    SettableMetadata? metadata,
    void Function(TaskSnapshot)? onStateChanged,
  }) async {
    final path = _userScopedPath('$directory/$fileName',cid);
    final ref = _storage.ref().child(path);

    final uploadTask = ref.putData(
      data,
      metadata ?? (contentType != null ? SettableMetadata(contentType: contentType) : null),
    );

    if (onStateChanged != null) uploadTask.snapshotEvents.listen(onStateChanged);

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Delete a file from storage by its full path or user-scoped path.
  /// - Example: deleteFile('profile/profile.jpg') or deleteFile('images/abc.png')
  Future<void> deleteFile(String relativePath, String cid,) async {
    final path = _userScopedPath(relativePath,cid);
    final ref = _storage.ref().child(path);
    await ref.delete();
  }

  /// Get download URL for a file (relative path or absolute storage path)
  Future<String> getDownloadUrl(String relativePath,String cid) async {
    final path = _userScopedPath(relativePath,cid);
    final ref = _storage.ref().child(path);
    return ref.getDownloadURL();
  }

  /// List files in a directory (relative to user scope). Returns list of full paths.
  Future<List<Reference>> listFiles({
    required String cid,
    String directory = '',
    int maxResults = 100,
  }) async {
    final path = directory.isEmpty ? _userScopedPath('',cid) : _userScopedPath(directory,cid);
    final ref = _storage.ref().child(path);
    final res = await ref.list(ListOptions(maxResults: maxResults));
    return res.items;
  }

  /// Helper to extract file name from a Storage Reference
  static String fileNameFromRef(Reference ref) {
    return ref.name; // last segment
  }

  /// Example convenience wrappers for common directories
  Future<String> uploadProfileImageBytes(Uint8List data, {String fileName = 'profile.jpg', required String cid,String? contentType}) =>
      uploadBytes(data: data, fileName: fileName, directory: 'profile', contentType: contentType,cid: cid);

  Future<String> uploadDocument(File file, {required String fileName,required String cid,}) => uploadFile(file: file, fileName: fileName, directory: 'documents',cid: cid);

  Future<String> uploadOtherImage(File file, {required String fileName,required String cid,}) => uploadFile(file: file, fileName: fileName, directory: 'images',cid: cid);
}