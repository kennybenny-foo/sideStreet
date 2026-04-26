import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'place_details_screen.dart';

class MySpotsScreen extends StatelessWidget {
  const MySpotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F3EC),
        appBar: AppBar(
          title: Text(
            'My Spots',
            style: GoogleFonts.comfortaa(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2F2A25),
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFFE9E1D3),
          elevation: 0,
        ),
        body: Center(
          child: Text(
            'No user logged in.',
            style: GoogleFonts.comfortaa(
              fontSize: 16,
              color: const Color(0xFF2F2A25),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EC),
      appBar: AppBar(
        title: Text(
          'My Spots',
          style: GoogleFonts.comfortaa(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2F2A25),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFE9E1D3),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFF2F2A25),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('spots')
              .where('createdBy', isEqualTo: user.uid)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Something went wrong loading your spots.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.comfortaa(
                    fontSize: 16,
                    color: const Color(0xFF2F2A25),
                  ),
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'You have not added any spots yet.',
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
                    'Places you have shared',
                    style: GoogleFonts.comfortaa(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2F2A25),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Manage and revisit the hidden gems you have added.',
                    style: GoogleFonts.comfortaa(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final spotId = doc.id;

                    final title = (data['title'] ?? 'Untitled Spot').toString();
                    final category =
                    (data['category'] ?? 'Uncategorized').toString();
                    final description =
                    (data['description'] ?? 'No description').toString();
                    final imageUrl = (data['imageUrl'] ?? '').toString();
                    final location =
                    (data['location'] ?? 'Unknown location').toString();
                    final vibe = (data['vibe'] ?? 'No vibe listed').toString();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: MySpotCard(
                        spotId: spotId,
                        title: title,
                        category: category,
                        description: description,
                        imageUrl: imageUrl,
                        location: location,
                        vibe: vibe,
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class MySpotCard extends StatelessWidget {
  final String spotId;
  final String title;
  final String category;
  final String description;
  final String imageUrl;
  final String location;
  final String vibe;

  const MySpotCard({
    super.key,
    required this.spotId,
    required this.title,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.vibe,
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
                    '$category • $location',
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}