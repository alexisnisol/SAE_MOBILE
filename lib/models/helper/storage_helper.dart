import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/database_helper.dart';

class StorageHelper {
  static final _storage = DatabaseHelper.getStorage();

  static Future<void> createBucket(String bucketName) async {
    try {
      final response = await _storage.createBucket(bucketName);
      if (response.error != null) {
        throw Exception('Failed to create bucket: ${response.error!.message}');
      }
    } catch (e) {
      throw Exception('Failed to create bucket: $e');
    }
  }

  static Future<String> uploadFile(
      String bucketName, File file, String fileName, dynamic options) async {
    try {
      final fullPath = await _storage.from(bucketName).upload(fileName, file,
          fileOptions: options); //upsert = overwrite if exists
      if (fullPath.error != null) {
        throw Exception('Failed to upload file: ${fullPath.error!.message}');
      }
      return fullPath;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  static Future<String> uploadBinary(
      String bucketName, String fileName, List<int> bytes,
      {FileOptions? fileOptions}) async {
    try {
      return await _storage
          .from(bucketName)
          .uploadBinary(fileName, bytes, fileOptions: fileOptions);
    } catch (e) {
      throw Exception('Failed to upload binary: $e');
    }
  }

  static Future<String> getPublicUrl(
      String bucketName, String? fileName) async {
    try {
      if (fileName == null) {
        throw Exception('File name cannot be null');
      }
      final resp = await _storage.from(bucketName).getPublicUrl(fileName);
      return resp;
    } catch (e) {
      throw Exception('Failed to get public URL: $e');
    }
  }
}
