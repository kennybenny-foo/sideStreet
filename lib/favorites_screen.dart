import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'place_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Future<List<Map<String, dynamic>>> _getFavoriteSpots() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final favoritesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .get();

    final List<Map<String, dynamic>> spots = [];

    for (final favoriteDoc in favoritesSnapshot.docs) {
      final spotId = favoriteDoc['spotId'];

      final spotDoc = await FirebaseFirestore.instance
          .collection('spots')
          .doc(spotId)
          .get();

      if (spotDoc.exists) {
        final data = spotDoc.data()!;
        data['spotId'] = spotDoc.id;
        spots.add(data);
      }
    }

    return spots;
  }

  Future<void> _unsaveFavorite(String spotId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(spotId)
        .delete();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getFavoriteSpots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final favoriteSpots = snapshot.data ?? [];

          if (favoriteSpots.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'No favorites yet.\nStart saving places you want to revisit.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.comfortaa(
                    fontSize: 18,
                    color: const Color(0xFF2F2A25),
                    height: 1.5,
                  ),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saved for later',
                  style: GoogleFonts.comfortaa(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2F2A25),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Keep track of the places you want to revisit or check out soon.',
                  style: GoogleFonts.comfortaa(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ...favoriteSpots.map(
                      (spot) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: FavoriteSpotCard(
                      spotId: spot['spotId'] ?? '',
                      title: (spot['title'] ?? 'Untitled Spot').toString(),
                      category: (spot['category'] ?? 'Uncategorized').toString(),
                      description:
                      (spot['description'] ?? 'No description').toString(),
                      imageUrl: (spot['imageUrl'] ?? '').toString(),
                      location:
                      (spot['location'] ?? 'Unknown location').toString(),
                      vibe: (spot['vibe'] ?? 'No vibe listed').toString(),
                      onUnsave: () async {
                        await _unsaveFavorite(spot['spotId'] ?? '');
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FavoriteSpotCard extends StatelessWidget {
  final String spotId;
  final String title;
  final String category;
  final String description;
  final String imageUrl;
  final String location;
  final String vibe;
  final VoidCallback onUnsave;

  const FavoriteSpotCard({
    super.key,
    required this.spotId,
    required this.title,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.vibe,
    required this.onUnsave,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imageUrl.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetailsScreen(
              spotId: spotId,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: hasImage
                  ? Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : Container(
                height: 180,
                width: double.infinity,
                color: const Color(0xFFE9E1D3),
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: Color(0xFF5E6F52),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.comfortaa(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2F2A25),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category,
                    style: GoogleFonts.comfortaa(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFC67C4E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: GoogleFonts.comfortaa(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: onUnsave,
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        label: Text(
                          'Unsave',
                          style: GoogleFonts.comfortaa(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}