import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sae_mobile/models/helper/auth_helper.dart';
import 'package:sae_mobile/models/helper/storage_helper.dart';

class ProfilScreen extends StatelessWidget {

  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Empêche une erreur lorsqu'on se déconnecte volontairement.
    if (!AuthHelper.isSignedIn()) {
      return const Center(child: Text("Utilisateur non trouvé"));
    }
    final user = AuthHelper.getCurrentUser();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<String?>(
              future: StorageHelper.getPublicUrl("avatars", user.userMetadata?['avatar_url']),
              builder: (context, snapshot) {
                ImageProvider<Object>? imageProvider;

                if (snapshot.connectionState == ConnectionState.waiting) {
                  imageProvider = null;
                } else if (snapshot.hasData && snapshot.data != null) {
                  imageProvider = NetworkImage(snapshot.data!);
                } else {
                  imageProvider = null;
                }

                return CircleAvatar(
                  radius: 40,
                  backgroundImage: imageProvider,
                  child: (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null)
                      ? const Icon(Icons.person, size: 40)
                      : null,
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              AuthHelper.getCurrentUserName() ?? "Utilisateur inconnu",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => {
                context.go('/edit_profil'),
              },
              icon: const Icon(Icons.edit),
              label: const Text("Modifier le profil"),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => {
                context.go('/preferences'),
              },
              icon: const Icon(Icons.settings),
              label: const Text("Gérer les préférences"),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                context.go('/logout');
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text("Se déconnecter", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}