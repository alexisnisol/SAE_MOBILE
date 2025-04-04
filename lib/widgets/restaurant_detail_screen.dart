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
import '../models/helper/auth_helper.dart';
import '../models/location_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../models/helper/storage_helper.dart';
import 'dart:html' as html;

class RestaurantDetailPage extends StatefulWidget {
  final int restaurantId;
  static String? CURRENT_USER_ID = AuthHelper.getCurrentUser()?.id;

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
  File? _reviewImage;
  html.File? _webReviewImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  final String _bucketName = 'reviewphotos';

  @override
  void initState() {
    super.initState();
    _checkIfFavorited();
    _locationService.getUserLocation(false);
    _ensureBucketExists();
  }

  Future<void> _ensureBucketExists() async {
    try {
      await StorageHelper.createBucket(_bucketName);
    } catch (e) {
      debugPrint('Bucket already exists or error: $e');
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

    setState(() {
      _isFavorited = !_isFavorited;
    });

    _isFavorited
        ? await DatabaseHelper.addRestaurantFavoris(
        RestaurantDetailPage.CURRENT_USER_ID!, widget.restaurantId)
        : await DatabaseHelper.deleteRestaurantFavoris(
        RestaurantDetailPage.CURRENT_USER_ID!, widget.restaurantId);
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo != null) {
      setState(() {
        _reviewImage = File(photo.path);
        _webReviewImage = null;
      });
    }
  }

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

  Future<String?> _uploadImage() async {
    try {
      final userId = RestaurantDetailPage.CURRENT_USER_ID;
      if (userId == null) return null;

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
        final reader = html.FileReader();
        reader.readAsArrayBuffer(_webReviewImage!);
        await reader.onLoad.first;
        bytes = List<int>.from(reader.result as List);
      } else if (!kIsWeb && _reviewImage != null) {
        bytes = await _reviewImage!.readAsBytes();
      } else {
        return null;
      }

      await StorageHelper.uploadBinary(
          _bucketName, fileName, bytes,
          fileOptions: fileOptions);

      return await StorageHelper.getPublicUrl(_bucketName, fileName);
    } catch (e) {
      debugPrint('Error uploading image: $e');
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

    setState(() => _isUploading = true);

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
      setState(() => _isUploading = false);
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
          _buildCuisineTypes(restaurant),
          const SizedBox(height: 20),
          _buildServicesSection(restaurant),
          const SizedBox(height: 20),
          _buildMapSection(restaurant),
          const SizedBox(height: 20),
          _buildReviewsSection(),
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
          '${restaurant.commune ?? ''}, ${restaurant.departement ?? ''}, ${restaurant.region ?? ''}',
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
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.phone),
            title: Text(restaurant.phone!),
            trailing: IconButton(
              icon: const Icon(Icons.call),
              onPressed: () => launchUrl(Uri.parse('tel:${restaurant.phone}')),
            ),
          ),
        if (restaurant.website?.isNotEmpty ?? false)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.language),
            title: Text(
              restaurant.website!,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
            onTap: () => launchUrl(Uri.parse(restaurant.website!)),
          ),
      ],
    );
  }

  Widget _buildCuisineTypes(Restaurant restaurant) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.getTypeCuisineRestaurant(widget.restaurantId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox();
        }

        final cuisines = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Types de cuisine',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cuisines.map((cuisine) {
                return FutureBuilder<bool>(
                  future: RestaurantDetailPage.CURRENT_USER_ID != null
                      ? DatabaseHelper.estCuisineLike(
                      RestaurantDetailPage.CURRENT_USER_ID!, cuisine["id"])
                      : Future.value(false),
                  builder: (context, snapshot) {
                    final isLiked = snapshot.data ?? false;
                    return InputChip(
                      label: Text(cuisine["cuisine"]),
                      avatar: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                        size: 18,
                      ),
                      onPressed: RestaurantDetailPage.CURRENT_USER_ID != null
                          ? () async {
                        await DatabaseHelper.toggleCuisineLike(
                          RestaurantDetailPage.CURRENT_USER_ID!,
                          cuisine["id"],
                          !isLiked,
                        );
                        setState(() {
                          likedCuisines[cuisine["id"]] = !isLiked;
                        });
                      }
                          : null,
                    );
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildServicesSection(Restaurant restaurant) {
    final services = [
      if (restaurant.wheelchair == true) 'Accès PMR',
      if (restaurant.vegetarian == true) 'Option végétarienne',
      if (restaurant.vegan == true) 'Option végan',
      if (restaurant.delivery == true) 'Livraison',
      if (restaurant.takeaway == true) 'À emporter',
      if (restaurant.internet_access == true) 'Accès internet',
      if (restaurant.drive_through == true) 'Drive-through',
    ];

    if (services.isEmpty) return const SizedBox();

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
            avatar: const Icon(Icons.check, size: 18),
          ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildMapSection(Restaurant restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Carte',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 250,
              child: RestaurantMap(
                restaurant: restaurant,
                locationService: _locationService,
                showUserLocation: true,
                showRouteLine: true,
              ),
            ),
          ),
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

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Avis',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (RestaurantDetailPage.CURRENT_USER_ID != null) _buildReviewForm(),
        const SizedBox(height: 16),
        _buildReviewsList(),
      ],
    );
  }

  Widget _buildReviewForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Laisser un avis',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
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
        Row(
          children: [
            Expanded(
              child: (kIsWeb && _webReviewImage != null) ||
                  (!kIsWeb && _reviewImage != null)
                  ? Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: kIsWeb
                            ? NetworkImage(
                            html.Url.createObjectUrl(_webReviewImage!))
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
              ? const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
      ],
    );
  }

  Widget _buildReviewsList() {
    return FutureBuilder<List<Review>>(
      future: DatabaseHelper.getReviewsRestau(widget.restaurantId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text("Aucun avis pour le moment."),
          );
        }

        final reviews = snapshot.data!;
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          separatorBuilder: (_, __) => const Divider(height: 16),
          itemBuilder: (context, index) {
            final review = reviews[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Utilisateur ${review.userId}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Row(
                        children: List.generate(
                          5,
                              (i) => Icon(
                            i < review.etoiles
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${review.date.day}/${review.date.month}/${review.date.year}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(review.avis),
                  if (review.imageUrl != null && review.imageUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: InteractiveViewer(
                                panEnabled: true,
                                boundaryMargin: const EdgeInsets.all(20),
                                minScale: 0.5,
                                maxScale: 4,
                                child: Image.network(
                                  review.imageUrl!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            review.imageUrl!,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}