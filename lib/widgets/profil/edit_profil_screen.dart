import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sae_mobile/models/helper/auth_helper.dart';
import 'package:sae_mobile/models/helper/storage_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilScreen extends StatefulWidget {
  @override
  _EditProfilScreenState createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  File? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  bool _isImageLoading = false;

  Future<void> _pickImage() async {
    setState(() {
      _isImageLoading = true;
    });

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        if (kIsWeb) {
          // Sur Web, on lit directement les bytes
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _selectedImageBytes = bytes;
            _selectedImageFile = null;
          });
        } else {
          // Sur mobile, on garde le File
          setState(() {
            _selectedImageFile = File(pickedFile.path);
            _selectedImageBytes = null;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la sélection de l'image: $e")),
      );
    } finally {
      setState(() {
        _isImageLoading = false;
      });
    }
  }

  Future<String?> _uploadImage(String userId) async {
    try {
      if (_selectedImageFile == null && _selectedImageBytes == null) {
        return null;
      }

      final fileName = '$userId.jpg';
      List<int> bytes;

      if (kIsWeb && _selectedImageBytes != null) {
        bytes = _selectedImageBytes!;
      } else if (_selectedImageFile != null) {
        bytes = await _selectedImageFile!.readAsBytes();
      } else {
        return null;
      }

      var resp = await StorageHelper.uploadBinary("avatars", fileName, bytes,
          fileOptions: const FileOptions(upsert: true));

      resp = resp.substring(resp.indexOf('/') + 1);
      return resp;
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'upload: $error")),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthHelper.getCurrentUser();

    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le profil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'display_name',
                initialValue: AuthHelper.getCurrentUserName() ?? '',
                decoration:
                    const InputDecoration(labelText: "Nom d'utilisateur"),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: FutureBuilder<String?>(
                  future: StorageHelper.getPublicUrl(
                      "avatars", user.userMetadata?['avatar_url']),
                  builder: (context, snapshot) {
                    Widget child;
                    ImageProvider<Object>? imageProvider;

                    if (_isImageLoading) {
                      child = const CircularProgressIndicator();
                    } else if (_selectedImageBytes != null) {
                      imageProvider = MemoryImage(_selectedImageBytes!);
                      child = const SizedBox.shrink();
                    } else if (_selectedImageFile != null) {
                      imageProvider = FileImage(_selectedImageFile!);
                      child = const SizedBox.shrink();
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      child = const Icon(Icons.camera_alt, size: 40);
                    } else if (snapshot.hasData && snapshot.data != null) {
                      imageProvider = NetworkImage(snapshot.data!);
                      child = const SizedBox.shrink();
                    } else {
                      child = const Icon(Icons.camera_alt, size: 40);
                    }

                    return CircleAvatar(
                      radius: 40,
                      backgroundImage: imageProvider,
                      child: child,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    final formData = _formKey.currentState!.value;

                    String? avatarUrl = await _uploadImage(user.id);

                    try {
                      final supabase = Supabase.instance.client;
                      await supabase.auth.updateUser(
                        UserAttributes(
                          data: {
                            'displayName': formData['display_name'],
                            'avatar_url':
                                avatarUrl ?? user.userMetadata?['avatar_url'],
                          },
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Profil mis à jour avec succès!')),
                      );
                      context.go('/profil');
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur: $error')),
                      );
                    }
                  }
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
