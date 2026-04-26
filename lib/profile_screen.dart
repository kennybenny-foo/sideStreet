import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'my_spots_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream() {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _spotsStream() {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('spots')
        .where('createdBy', isEqualTo: user!.uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _favoritesStream() {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('favorites')
        .snapshots();
  }

  Future<void> _logOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return Center(
        child: Text(
          'No user logged in.',
          style: GoogleFonts.comfortaa(
            fontSize: 18,
            color: const Color(0xFF2F2A25),
          ),
        ),
      );
    }

    return SafeArea(
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _userStream(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final userData = userSnapshot.data?.data() ?? {};
          final username = userData['username'] ?? 'Explorer';
          final email = userData['email'] ?? firebaseUser.email ?? '';
          final bio =
              userData['bio'] ?? 'Finding places off the main path.';

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _spotsStream(),
            builder: (context, spotsSnapshot) {
              if (spotsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final spotsAdded = spotsSnapshot.data?.docs.length ?? 0;

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _favoritesStream(),
                builder: (context, favoritesSnapshot) {
                  if (favoritesSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final favoritesCount =
                      favoritesSnapshot.data?.docs.length ?? 0;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        const CircleAvatar(
                          radius: 45,
                          backgroundColor: Color(0xFFE9E1D3),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Color(0xFF5E6F52),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          username,
                          style: GoogleFonts.comfortaa(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2F2A25),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          email,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.comfortaa(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          bio,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.comfortaa(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: ProfileStatCard(
                                title: 'Spots Added',
                                value: spotsAdded.toString(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ProfileStatCard(
                                title: 'Favorites',
                                value: favoritesCount.toString(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        ProfileOptionTile(
                          icon: Icons.place_outlined,
                          title: 'My Spots',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MySpotsScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        ProfileOptionTile(
                          icon: Icons.settings_outlined,
                          title: 'Settings',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        ProfileOptionTile(
                          icon: Icons.info_outline,
                          title: 'About',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AboutScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        ProfileOptionTile(
                          icon: Icons.logout,
                          title: 'Log Out',
                          onTap: () async {
                            await _logOut();
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ProfileStatCard extends StatelessWidget {
  final String title;
  final String value;

  const ProfileStatCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
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
        children: [
          Text(
            value,
            style: GoogleFonts.comfortaa(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5E6F52),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.comfortaa(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2F2A25),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.04),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF5E6F52),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.comfortaa(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2F2A25),
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}