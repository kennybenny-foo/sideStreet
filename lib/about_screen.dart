import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EC),
      appBar: AppBar(
        title: Text(
          'About',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE9E1D3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.explore,
                    size: 45,
                    color: Color(0xFF5E6F52),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Side Street',
                  style: GoogleFonts.comfortaa(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2F2A25),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Version 1.0.1',
                  style: GoogleFonts.comfortaa(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildInfoCard(
                title: 'Purpose',
                text:
                'Side Street helps people discover underrated local spots beyond the usual tourist destinations. Users can share hidden gems, save favorites, and explore places that feel more personal and authentic.',
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Features',
                text:
                'The app allows users to create an account, add spots with photos, browse shared locations, search by keywords and location, filter by category, save favorites, and manage the places they have posted.',
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Inspiration',
                text:
                'This app was inspired by the idea that some of the best places are not always the ones that show up first in a search. Side Street was created to help people find interesting local spots that feel less crowded and more unique. Maybe explore those gate kept places.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildInfoCard({
    required String title,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
          Text(
            title,
            style: GoogleFonts.comfortaa(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5E6F52),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: GoogleFonts.comfortaa(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}