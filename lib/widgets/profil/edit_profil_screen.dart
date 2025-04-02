import 'dart:html' as html;
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
  File? _selectedImage;
  html.File? _webImage;

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final input = html.FileUploadInputElement()
        ..accept = 'image/*';
      input.click();
      input.onChange.listen((event) {
        if (input.files!.isNotEmpty) {
          setState(() {
            _webImage = input.files!.first;
          });
        }
      });
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }
  }

  Future<String?> _uploadImage(String userId) async {
    try {
      final fileName = '$userId.jpg';
      final List<int> bytes;
      if (kIsWeb && _webImage != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(_webImage!);
        await reader.onLoad.first;
        bytes = reader.result as List<int>;
      } else if (_selectedImage != null) {
        bytes = await _selectedImage!.readAsBytes();
      } else {
        return null;
      }
      var resp = await StorageHelper.uploadBinary("avatars", fileName, bytes, fileOptions: const FileOptions(upsert: true));
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
                decoration: const InputDecoration(labelText: "Nom d'utilisateur"),
                validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: FutureBuilder<String?>(
                  future: StorageHelper.getPublicUrl("avatars", user.userMetadata?['avatar_url']),
                  builder: (context, snapshot) {
                    ImageProvider<Object>? imageProvider;

                    if (_webImage != null) {
                      imageProvider = null;
                    } else if (_selectedImage != null) {
                      imageProvider = FileImage(_selectedImage!);
                    } else if (snapshot.connectionState == ConnectionState.waiting) {
                      imageProvider = null;
                    } else if (snapshot.hasData && snapshot.data != null) {
                      imageProvider = NetworkImage(snapshot.data!);
                    } else {
                      imageProvider = null;
                    }

                    return CircleAvatar(
                      radius: 40,
                      backgroundImage: imageProvider,
                      child: (_selectedImage == null && _webImage == null && snapshot.connectionState == ConnectionState.waiting)
                          ? const Icon(Icons.camera_alt, size: 40)
                          : null,
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
                            'avatar_url': avatarUrl ?? user.userMetadata?['avatar_url'],
                          },
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profil mis à jour avec succès!')),
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