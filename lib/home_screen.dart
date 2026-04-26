import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'place_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(Map<String, dynamic> data) {
    final title = (data['title'] ?? '').toString().toLowerCase();
    final category = (data['category'] ?? '').toString().toLowerCase();
    final description = (data['description'] ?? '').toString().toLowerCase();
    final location = (data['location'] ?? '').toString().toLowerCase();
    final vibe = (data['vibe'] ?? '').toString().toLowerCase();

    final query = _searchText.toLowerCase().trim();

    if (query.isEmpty) return true;

    return title.contains(query) ||
        category.contains(query) ||
        description.contains(query) ||
        location.contains(query) ||
        vibe.contains(query);
  }

  bool _matchesCategory(Map<String, dynamic> data) {
    if (_selectedCategory == 'All') return true;

    final category = (data['category'] ?? '').toString().toLowerCase();
    return category == _selectedCategory.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find places off the main path',
                    style: GoogleFonts.comfortaa(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2F2A25),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Discover underrated cafes, views, parks, and local favorites.',
                    style: GoogleFonts.comfortaa(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by name, category, or location...',
                      hintStyle: GoogleFonts.comfortaa(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchText.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchText = '';
                          });
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChipWidget(
                          label: 'All',
                          isSelected: _selectedCategory == 'All',
                          onTap: () {
                            setState(() {
                              _selectedCategory = 'All';
                            });
                          },
                        ),
                        FilterChipWidget(
                          label: 'Coffee',
                          isSelected: _selectedCategory == 'Coffee',
                          onTap: () {
                            setState(() {
                              _selectedCategory = 'Coffee';
                            });
                          },
                        ),
                        FilterChipWidget(
                          label: 'Food',
                          isSelected: _selectedCategory == 'Food',
                          onTap: () {
                            setState(() {
                              _selectedCategory = 'Food';
                            });
                          },
                        ),
                        FilterChipWidget(
                          label: 'Nature',
                          isSelected: _selectedCategory == 'Nature',
                          onTap: () {
                            setState(() {
                              _selectedCategory = 'Nature';
                            });
                          },
                        ),
                        FilterChipWidget(
                          label: 'Views',
                          isSelected: _selectedCategory == 'Views',
                          onTap: () {
                            setState(() {
                              _selectedCategory = 'Views';
                            });
                          },
                        ),
                        FilterChipWidget(
                          label: 'Shops',
                          isSelected: _selectedCategory == 'Shops',
                          onTap: () {
                            setState(() {
                              _selectedCategory = 'Shops';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Featured Spots',
                    style: GoogleFonts.comfortaa(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2F2A25),
                    ),
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('spots')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Something went wrong loading spots.',
                            style: GoogleFonts.comfortaa(
                              fontSize: 16,
                              color: const Color(0xFF2F2A25),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];

                      final filteredDocs = docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return _matchesSearch(data) && _matchesCategory(data);
                      }).toList();

                      if (docs.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
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
                          child: Text(
                            'No spots yet.\nBe the first to add one.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.comfortaa(
                              fontSize: 16,
                              color: const Color(0xFF2F2A25),
                              height: 1.5,
                            ),
                          ),
                        );
                      }

                      if (filteredDocs.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
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
                          child: Text(
                            'No spots match your search.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.comfortaa(
                              fontSize: 16,
                              color: const Color(0xFF2F2A25),
                              height: 1.5,
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: filteredDocs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final spotId = doc.id;

                          final title =
                          (data['title'] ?? 'Untitled Spot').toString();
                          final category =
                          (data['category'] ?? 'Uncategorized').toString();
                          final description =
                          (data['description'] ?? 'No description')
                              .toString();
                          final imageUrl = (data['imageUrl'] ?? '').toString();
                          final location =
                          (data['location'] ?? 'Unknown location')
                              .toString();
                          final vibe =
                          (data['vibe'] ?? 'No vibe listed').toString();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: SpotCard(
                              spotId: spotId,
                              title: title,
                              category: category,
                              description: description,
                              imageUrl: imageUrl,
                              location: location,
                              vibe: vibe,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(
          label,
          style: GoogleFonts.comfortaa(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF2F2A25),
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: const Color(0xFF5E6F52),
        backgroundColor: const Color(0xFFE9E1D3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),
    );
  }
}

class SpotCard extends StatelessWidget {
  final String spotId;
  final String title;
  final String category;
  final String description;
  final String imageUrl;
  final String location;
  final String vibe;

  const SpotCard({
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