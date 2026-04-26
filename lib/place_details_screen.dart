import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_spot_screen.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final String spotId;

  const PlaceDetailsScreen({
    super.key,
    required this.spotId,
  });

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isReporting = false;

  Future<void> _toggleFavorite(bool isAlreadyFavorited) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to manage favorites.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final favoriteRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.spotId);

      if (isAlreadyFavorited) {
        await favoriteRef.delete();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from favorites.')),
        );
      } else {
        await favoriteRef.set({
          'spotId': widget.spotId,
          'savedAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved to favorites!')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update favorite: $e')),
      );
    }

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });
  }

  Future<void> _reportSpot(String title) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to report a spot.'),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Report Spot',
            style: GoogleFonts.comfortaa(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Report this spot for inappropriate content?',
            style: GoogleFonts.comfortaa(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.comfortaa(),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Report',
                style: GoogleFonts.comfortaa(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _isReporting = true;
    });

    try {
      final reportId = '${user.uid}_${widget.spotId}';

      await FirebaseFirestore.instance.collection('reports').doc(reportId).set({
        'spotId': widget.spotId,
        'reportedBy': user.uid,
        'title': title,
        'reason': 'Inappropriate content',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Spot reported. Thank you.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to report spot: $e')),
      );
    }

    if (!mounted) return;

    setState(() {
      _isReporting = false;
    });
  }

  Future<bool> _isOwner(String createdBy) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    return createdBy == user.uid;
  }

  Future<void> _deleteSpot(String imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Delete Spot',
            style: GoogleFonts.comfortaa(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this spot?',
            style: GoogleFonts.comfortaa(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.comfortaa(),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Delete',
                style: GoogleFonts.comfortaa(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      if (imageUrl.isNotEmpty) {
        try {
          final imageRef = FirebaseStorage.instance.refFromURL(imageUrl);
          await imageRef.delete();
        } catch (_) {}
      }

      await FirebaseFirestore.instance
          .collection('spots')
          .doc(widget.spotId)
          .delete();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.spotId)
          .delete()
          .catchError((_) {});

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Spot deleted.')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete spot: $e')),
      );
    }

    if (!mounted) return;

    setState(() {
      _isDeleting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('spots')
          .doc(widget.spotId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F3EC),
            appBar: AppBar(
              title: Text(
                'Spot Details',
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
            body: Center(
              child: Text(
                'Something went wrong loading this spot.',
                style: GoogleFonts.comfortaa(
                  fontSize: 16,
                  color: const Color(0xFF2F2A25),
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7F3EC),
            appBar: AppBar(
              title: Text(
                'Spot Details',
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
            body: Center(
              child: Text(
                'This spot no longer exists.',
                style: GoogleFonts.comfortaa(
                  fontSize: 16,
                  color: const Color(0xFF2F2A25),
                ),
              ),
            ),
          );
        }

        final data = snapshot.data!.data()!;
        final title = (data['title'] ?? 'Untitled Spot').toString();
        final category = (data['category'] ?? 'Uncategorized').toString();
        final description = (data['description'] ?? 'No description').toString();
        final imageUrl = (data['imageUrl'] ?? '').toString();
        final location = (data['location'] ?? 'Unknown location').toString();
        final vibe = (data['vibe'] ?? 'No vibe listed').toString();
        final createdBy = (data['createdBy'] ?? '').toString();

        return Scaffold(
          backgroundColor: const Color(0xFFF7F3EC),
          appBar: AppBar(
            title: Text(
              'Spot Details',
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
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  height: 260,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                    : Container(
                  height: 260,
                  width: double.infinity,
                  color: const Color(0xFFE9E1D3),
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 60,
                      color: Color(0xFF5E6F52),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.comfortaa(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2F2A25),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$category • $location',
                        style: GoogleFonts.comfortaa(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFC67C4E),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.landscape_outlined,
                              color: Color(0xFF5E6F52),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Vibe: $vibe',
                                style: GoogleFonts.comfortaa(
                                  fontSize: 14,
                                  color: const Color(0xFF2F2A25),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Why visit?',
                        style: GoogleFonts.comfortaa(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2F2A25),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        description,
                        style: GoogleFonts.comfortaa(
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 28),

                      if (currentUser != null)
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser.uid)
                              .collection('favorites')
                              .doc(widget.spotId)
                              .snapshots(),
                          builder: (context, favoriteSnapshot) {
                            final isCheckingFavorite =
                                favoriteSnapshot.connectionState ==
                                    ConnectionState.waiting;
                            final isAlreadyFavorited =
                                favoriteSnapshot.data?.exists ?? false;

                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: (_isSaving || isCheckingFavorite)
                                    ? null
                                    : () => _toggleFavorite(isAlreadyFavorited),
                                icon: isCheckingFavorite
                                    ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : _isSaving
                                    ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : Icon(
                                  isAlreadyFavorited
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                ),
                                label: Text(
                                  isCheckingFavorite
                                      ? 'Checking...'
                                      : _isSaving
                                      ? (isAlreadyFavorited
                                      ? 'Removing...'
                                      : 'Saving...')
                                      : (isAlreadyFavorited
                                      ? 'Unsave'
                                      : 'Save to Favorites'),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isAlreadyFavorited
                                      ? const Color(0xFF8B5E3C)
                                      : const Color(0xFF5E6F52),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                  const Color(0xFF9BA892),
                                  disabledForegroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  textStyle: GoogleFonts.comfortaa(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                      if (currentUser == null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: null,
                            icon: const Icon(Icons.favorite_border),
                            label: const Text('Log in to use favorites'),
                            style: ElevatedButton.styleFrom(
                              disabledBackgroundColor:
                              const Color(0xFF9BA892),
                              disabledForegroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: GoogleFonts.comfortaa(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 12),

                      if (currentUser != null)
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('reports')
                              .doc('${currentUser.uid}_${widget.spotId}')
                              .snapshots(),
                          builder: (context, reportSnapshot) {
                            final isReported = reportSnapshot.data?.exists ?? false;

                            return SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: (_isReporting || isReported)
                                    ? null
                                    : () => _reportSpot(title),
                                icon: _isReporting
                                    ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                    : Icon(
                                  isReported
                                      ? Icons.flag
                                      : Icons.outlined_flag,
                                ),
                                label: Text(
                                  _isReporting
                                      ? 'Reporting...'
                                      : isReported
                                      ? 'Reported'
                                      : 'Report Spot',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.orange.shade800,
                                  side: BorderSide(
                                    color: Colors.orange.shade800,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  textStyle: GoogleFonts.comfortaa(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 12),

                      FutureBuilder<bool>(
                        future: _isOwner(createdBy),
                        builder: (context, ownerSnapshot) {
                          if (ownerSnapshot.data != true) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditSpotScreen(
                                          spotId: widget.spotId,
                                          title: title,
                                          category: category,
                                          description: description,
                                          location: location,
                                          vibe: vibe,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit_outlined),
                                  label: const Text('Edit Spot'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF5E6F52),
                                    side: const BorderSide(
                                      color: Color(0xFF5E6F52),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    textStyle: GoogleFonts.comfortaa(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _isDeleting
                                      ? null
                                      : () => _deleteSpot(imageUrl),
                                  icon: _isDeleting
                                      ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                      : const Icon(Icons.delete_outline),
                                  label: Text(
                                    _isDeleting
                                        ? 'Deleting...'
                                        : 'Delete Spot',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    textStyle: GoogleFonts.comfortaa(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
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
}