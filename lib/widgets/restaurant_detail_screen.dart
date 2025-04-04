import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sae_mobile/models/review.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/Restaurant/RestaurantMap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/restaurant.dart';
import '../models/database/database_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/helper/auth_helper.dart';
import '../models/location_service.dart';
import '../models/restaurant.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../models/helper/storage_helper.dart';

// Pour le Web, on importe dart:html
// Cette importation sera ignorée sur mobile grâce à kIsWeb
// (Attention : cette importation peut nécessiter une configuration de build multi-plateforme.)
import 'dart:html' as html;
class RestaurantDetailPage extends StatefulWidget {
  final int restaurantId;
  static String? CURRENT_USER_ID = AuthHelper.getCurrentUser().id;

  const RestaurantDetailPage({Key? key, required this.restaurantId})
      : super(key: key);

  @override
  _RestaurantDetailPageState createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  final LocationService _locationService = LocationService();
  final TextEditingController _avisController = TextEditingController();
  Map<int, bool> likedCuisines = {};
  int _selectedRating = 3;
  bool _isFavorited = false;
  // Pour mobile
  File? _reviewImage;
  // Pour le web
  html.File? _webReviewImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // Nom du bucket Supabase où stocker les images
  final String _bucketName = 'reviewphotos';

  @override
  void initState() {
    super.initState();
    _checkIfFavorited();
    _locationService.getUserLocation(false);
    _ensureBucketExists();
  }

  // S'assure que le bucket existe
  Future<void> _ensureBucketExists() async {
    try {
      await StorageHelper.createBucket(_bucketName);
    } catch (e) {
    }
  }

  Future<void> _checkIfFavorited() async {
    if (RestaurantDetailPage.CURRENT_USER_ID != null) {
      bool favorited = await DatabaseHelper.isRestaurantFavorited(
          RestaurantDetailPage.CURRENT_USER_ID!, widget.restaurantId);
      setState(() => _isFavorited = favorited);
    }
  }

  Future<void> _toggleFavorite() async {
    if (RestaurantDetailPage.CURRENT_USER_ID == null) return;

    _isFavorited
        ? await DatabaseHelper.deleteRestaurantFavoris(
        RestaurantDetailPage.CURRENT_USER_ID!, widget.restaurantId)
        : await DatabaseHelper.addRestaurantFavoris(
        RestaurantDetailPage.CURRENT_USER_ID!, widget.restaurantId);
    _checkIfFavorited();
  }

  // Prendre une photo avec la caméra (uniquement mobile)
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80, // Réduire la qualité pour optimiser la taille
    );
    if (photo != null) {
      setState(() {
        _reviewImage = File(photo.path);
        // Réinitialiser l'image web si présente
        _webReviewImage = null;
      });
    }
  }

  // Choisir une photo depuis la galerie (uniquement mobile)
  Future<void> _pickPhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _reviewImage = File(image.path);
        _webReviewImage = null;
      });
    }
  }

  // Afficher les options de capture/sélection de photo en fonction de la plateforme
  void _showPhotoOptions() {
    if (kIsWeb) {
      final input = html.FileUploadInputElement()..accept = 'image/*';
      input.click();
      input.onChange.listen((event) {
        if (input.files != null && input.files!.isNotEmpty) {
          setState(() {
            _webReviewImage = input.files!.first;
            _reviewImage = null;
          });
        }
      });
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto();
              },
            ),
          ],
        ),
      );
    }
  }

  // Télécharger l'image sur Supabase en utilisant uploadBinary
  Future<String?> _uploadImage() async {
    try {
      final userId = RestaurantDetailPage.CURRENT_USER_ID;
      if (userId == null) return null;

      // Générer un nom de fichier unique
      final extension = kIsWeb
          ? '.jpg'
          : path.extension((_reviewImage ?? File('')).path);
      final fileName =
          'review_${userId}_${widget.restaurantId}_${DateTime.now().millisecondsSinceEpoch}$extension';

      final fileOptions = FileOptions(
        upsert: true,
        contentType: 'image/jpeg',
      );

      List<int> bytes;
      if (kIsWeb && _webReviewImage != null) {
        // Lire les octets pour le Web
        final reader = html.FileReader();
        reader.readAsArrayBuffer(_webReviewImage!);
        await reader.onLoad.first;
        // Le résultat est un ByteBuffer que l'on convertit en List<int>
        bytes = List<int>.from(reader.result as List);
      } else if (!kIsWeb && _reviewImage != null) {
        bytes = await _reviewImage!.readAsBytes();
      } else {
        return null;
      }

      await StorageHelper.uploadBinary(_bucketName, fileName, bytes,
          fileOptions: fileOptions);

      // Obtenir l'URL publique
      final publicUrl = await StorageHelper.getPublicUrl(_bucketName, fileName);
      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors du téléchargement de l'image")),
      );
      return null;
    }
  }

  Future<void> _submitReview() async {
    if (_avisController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez écrire un avis avant d'envoyer.")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String? imageUrl;
      if ((kIsWeb && _webReviewImage != null) || (!kIsWeb && _reviewImage != null)) {
        imageUrl = await _uploadImage();
      }

      await DatabaseHelper.addReviewWithImage(
        RestaurantDetailPage.CURRENT_USER_ID!,
        widget.restaurantId,
        _avisController.text,
        _selectedRating,
        DateTime.now(),
        imageUrl,
      );

      _avisController.clear();
      setState(() {
        _selectedRating = 3;
        _reviewImage = null;
        _webReviewImage = null;
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Avis ajouté avec succès !")),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'envoi de l'avis: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Restaurant>(
      future: DatabaseHelper.getRestaurantById(widget.restaurantId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text("Restaurant introuvable.")),
          );
        }

        final restaurant = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/carte'),
            ),
            title: Text(restaurant.name),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildRestaurantImage(restaurant),
                _buildRestaurantInfo(restaurant),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRestaurantImage(Restaurant restaurant) {
    return FutureBuilder<String>(
      future: DatabaseHelper.imageLink(restaurant.name),
      builder: (context, snapshot) {
        final imageUrl = snapshot.data ?? DatabaseHelper.DEFAULT_IMAGE;
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.restaurant, size: 50),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRestaurantInfo(Restaurant restaurant) {
                // Image du restaurant
                FutureBuilder<String>(
                  future: DatabaseHelper.imageLink(restaurant.name),
                  builder: (context, snapshot) {
                    final imageUrl =
                        snapshot.data ?? DatabaseHelper.DEFAULT_IMAGE;
                    return Container(
                      width: double.infinity,
                      height: 200,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey.shade300,
                          child: Icon(Icons.restaurant,
                              size: 50, color: Colors.grey.shade700),
                        ),
                      ),
                    );
                  },
                ),
                // Informations du restaurant
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 40),
                      ),
                      _buildInfoWithData(
                        label: "Lieu : ",
                        value:
                        "${restaurant.region ?? ''}, ${restaurant.departement ?? ''}, ${restaurant.commune ?? ''}",
                      ),
                      if (restaurant.brand != null && restaurant.brand!.isNotEmpty)
                        _buildInfoWithData(
                            label: "Marque : ", value: restaurant.brand!),
                      if (restaurant.opening_hours != null &&
                          restaurant.opening_hours!.isNotEmpty)
                        _buildInfoWithData(
                            label: "Horaires : ", value: restaurant.opening_hours!),
                      if (restaurant.phone != null && restaurant.phone!.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Tel : ", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("📞 ${restaurant.phone!}"),
                            IconButton(
                              icon: const Icon(Icons.call, size: 18),
                              onPressed: () async {
                                final Uri launchUri = Uri(
                                  scheme: 'tel',
                                  path: restaurant.phone,
                                );
                                if (await canLaunchUrl(launchUri)) {
                                  await launchUrl(launchUri);
                                }
                              },
                            ),
                          ],
                        ),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: DatabaseHelper.getTypeCuisineRestaurant(widget.restaurantId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text("Chargement des types de cuisine...");
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          final cuisines = snapshot.data!;
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("Type de cuisine : ", style: TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  children: cuisines.map((cuisine) {
                                    if (RestaurantDetailPage.CURRENT_USER_ID != null) {
                                      return FutureBuilder<bool>(
                                        future: DatabaseHelper.estCuisineLike(RestaurantDetailPage.CURRENT_USER_ID!, cuisine["id"]),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const SizedBox(width: 24, height: 24);
                                          }
                                          bool isLiked = snapshot.data ?? false;
                                          return Chip(
                                            label: GestureDetector(
                                              onTap: () async {
                                                bool newLikeStatus = !isLiked;
                                                DatabaseHelper.toggleCuisineLike(
                                                    RestaurantDetailPage.CURRENT_USER_ID!,
                                                    cuisine["id"],
                                                    newLikeStatus);
                                                setState(() {
                                                  likedCuisines[cuisine["id"]] = newLikeStatus;
                                                });
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    isLiked ? Icons.favorite : Icons.favorite_border,
                                                    size: 16,
                                                    color: Colors.red,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(cuisine["cuisine"]),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    } else {
                                      return Chip(
                                        label: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.restaurant, size: 16, color: Colors.grey),
                                            SizedBox(width: 4),
                                            Text("Cuisine"),
                                          ],
                                        ),
                                      );
                                    }
                                  }).toList(),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      if (restaurant.wheelchair == true ||
                          restaurant.vegetarian == true ||
                          restaurant.vegan == true ||
                          restaurant.delivery == true ||
                          restaurant.takeaway == true ||
                          restaurant.internet_access == true ||
                          restaurant.drive_through == true)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildServicesList(restaurant),
                          ],
                        ),
                      const SizedBox(height: 8),
                      if (restaurant.website != null && restaurant.website!.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Site web : ", style: TextStyle(fontWeight: FontWeight.bold)),
                            Expanded(
                              child: InkWell(
                                child: Text(
                                  restaurant.website!,
                                  style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                ),
                                onTap: () async {
                                  final Uri url = Uri.parse(restaurant.website!);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      const Divider(),
                      if (RestaurantDetailPage.CURRENT_USER_ID != null) ...[
                        const SizedBox(height: 16),
                        const Text('Laisser un avis :',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Note : ", style: TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: List.generate(
                                5,
                                    (index) => IconButton(
                                  icon: Icon(
                                    index < _selectedRating ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedRating = index + 1;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _avisController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Votre avis...",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Section pour la photo dans l'avis
                        Row(
                          children: [
                            Expanded(
                              child: (kIsWeb && _webReviewImage != null) || (!kIsWeb && _reviewImage != null)
                                  ? Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: kIsWeb
                                            ? NetworkImage(html.Url.createObjectUrl(_webReviewImage!))
                                            : FileImage(_reviewImage!) as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cancel, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _reviewImage = null;
                                        _webReviewImage = null;
                                      });
                                    },
                                  ),
                                ],
                              )
                                  : OutlinedButton.icon(
                                icon: const Icon(Icons.camera_alt),
                                label: const Text("Ajouter une photo"),
                                onPressed: _showPhotoOptions,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _isUploading ? null : _submitReview,
                          child: _isUploading
                              ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text("Envoi en cours..."),
                            ],
                          )
                              : const Text("Envoyer l'avis"),

                        ),
                      ] else
                        Center(
                          child: Text(
                            "Veuillez vous connecter pour laisser un avis...",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      const Text('Les avis :',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      FutureBuilder<List<Review>>(
                        future: DatabaseHelper.getReviewsRestau(widget.restaurantId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text("Chargement des avis...");
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text("${restaurant.name} n'a pas d'avis pour le moment."),
                            );
                          }
                          final lesAvis = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: lesAvis.map((avis) {
                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Utilisateur ${avis.userId}",
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const Spacer(),
                                        Row(
                                          children: List.generate(
                                            5,
                                                (index) => Icon(
                                              index < avis.etoiles ? Icons.star : Icons.star_border,
                                              color: Colors.amber,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${avis.date.day}/${avis.date.month}/${avis.date.year}",
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(avis.avis),
                                    if (avis.imageUrl != null && avis.imageUrl!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Scaffold(
                                                  appBar: AppBar(
                                                    title: const Text('Photo de l\'avis'),
                                                  ),
                                                  body: Center(
                                                    child: InteractiveViewer(
                                                      panEnabled: true,
                                                      boundaryMargin: const EdgeInsets.all(20),
                                                      minScale: 0.5,
                                                      maxScale: 4,
                                                      child: Image.network(
                                                        avis.imageUrl!,
                                                        fit: BoxFit.contain,
                                                        loadingBuilder: (context, child, loadingProgress) {
                                                          if (loadingProgress == null) return child;
                                                          return Center(
                                                            child: CircularProgressIndicator(
                                                              value: loadingProgress.expectedTotalBytes != null
                                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                                  loadingProgress.expectedTotalBytes!
                                                                  : null,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Hero(
                                            tag: 'review_image_${avis.id}',
                                            child: Container(
                                              height: 120,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                                image: DecorationImage(
                                                  image: NetworkImage(avis.imageUrl!),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const Text('Localisation :',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map, size: 50, color: Colors.grey.shade600),
                              const SizedBox(height: 8),
                              const Text('Carte - Intégrer Google Maps ici'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoWithData({required String label, required String value}) {
    if (value.trim().isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            restaurant.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 20),
          _buildLocationInfo(restaurant),
          const SizedBox(height: 20),
          _buildContactInfo(restaurant),
          const SizedBox(height: 20),
          _buildMapSection(restaurant),
          const SizedBox(height: 20),
          _buildServicesSection(restaurant),
          const SizedBox(height: 20),
          _buildReviewsSection(restaurant),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(Restaurant restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Localisation',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '${restaurant.commune}, ${restaurant.departement}, ${restaurant.region}',
          style: const TextStyle(fontSize: 16),
        ),
        if (restaurant.opening_hours?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Horaires : ${restaurant.opening_hours}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
      ],
    );
  }

  Widget _buildContactInfo(Restaurant restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (restaurant.phone?.isNotEmpty ?? false)
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(restaurant.phone!),
            onTap: () => launchUrl(Uri.parse('tel:${restaurant.phone}')),
          ),
        if (restaurant.website?.isNotEmpty ?? false)
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(restaurant.website!),
            onTap: () => launchUrl(Uri.parse(restaurant.website!)),
          ),
      ],
    );
  }

  Widget _buildMapSection(Restaurant restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sur la carte',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        const Text("Services : ", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: services.map((service) {
            return Chip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Text(service),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        RestaurantMap(
          restaurant: restaurant,
          locationService: _locationService,
          height: 250,
        ),
        if (_locationService.hasValidPosition)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'À ${_locationService.calculateDistanceTo(restaurant.latitude, restaurant.longitude)?.toStringAsFixed(1)} km',
              style: const TextStyle(fontSize: 16),
            ),
          ),
      ],
    );
  }

  Widget _buildServicesSection(Restaurant restaurant) {
    final services = [
      if (restaurant.wheelchair) 'Accès PMR',
      if (restaurant.vegetarian) 'Végétarien',
      if (restaurant.vegan) 'Végan',
      if (restaurant.delivery) 'Livraison',
      if (restaurant.takeaway) 'À emporter',
      if (restaurant.drive_through) 'Drive-through',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: services
              .map((service) => Chip(
            label: Text(service),
            avatar: const Icon(Icons.check_circle, size: 18),
          ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(Restaurant restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Avis',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (RestaurantDetailPage.CURRENT_USER_ID != null)
          _buildReviewInputSection(),
        const SizedBox(height: 20),
        FutureBuilder<List<Review>>(
          future: DatabaseHelper.getReviewsRestau(widget.restaurantId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildReviewList(snapshot.data!);
          },
        ),
      ],
    );
  }

  Widget _buildReviewInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Laisser un avis',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(
            5,
                (index) => IconButton(
              icon: Icon(
                index < _selectedRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 30,
              ),
              onPressed: () => setState(() => _selectedRating = index + 1),
            ),
          ),
        ),
        TextField(
          controller: _avisController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Écrivez votre avis...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _submitReview,
            child: const Text('Publier'),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewList(List<Review> reviews) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      separatorBuilder: (_, __) => const Divider(height: 30),
      itemBuilder: (context, index) {
        final review = reviews[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Utilisateur ${review.userId}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text(review.avis),
              const SizedBox(height: 5),
              Text(
                '${review.date.day}/${review.date.month}/${review.date.year}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
                  (i) => Icon(
                i < review.etoiles ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitReview() async {
    if (_avisController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez écrire un avis')),
      );
      return;
    }

    await DatabaseHelper.addReview(
      RestaurantDetailPage.CURRENT_USER_ID!,
      widget.restaurantId,
      _avisController.text,
      _selectedRating,
      DateTime.now(),
    );

    setState(() {
      _avisController.clear();
      _selectedRating = 3;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avis publié avec succès !')),
    );
  }
}
}
