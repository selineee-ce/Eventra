import 'package:eventra/data/app_config.dart';
import 'package:eventra/data/eventra_database.dart';
import 'package:eventra/features/explore/artists/artists_profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrendingArtistsPage extends StatefulWidget {
  const TrendingArtistsPage({super.key});

  @override
  State<TrendingArtistsPage> createState() => _TrendingArtistsPageState();
}

class _TrendingArtistsPageState extends State<TrendingArtistsPage> {
  List<Map<String, dynamic>> artistsData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArtists();
  }

  Future<void> _loadArtists() async {
    final artists = await EventraDatabase.instance.fetchTrendingArtists();

    if (!mounted) {
      return;
    }

    setState(() {
      artistsData = artists;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD0BCFF)),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            AppConfig.instance.text('artists.title', 'Trending Artists'),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppConfig.instance.text(
              'artists.subtitle',
              'The architects of sound currently shaping the global underground landscape',
            ),
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.54),
              fontSize: 16,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: artistsData.length,
            itemBuilder: (context, index) {
              final artist = artistsData[index];
              final rank = index + 1;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArtistProfilePage(artistData: artist),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 54,
                        child: Text(
                          rank < 10 ? '0$rank' : '$rank',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.18),
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          artist['imageUrl'] as String,
                          width: 82,
                          height: 82,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 82,
                            height: 82,
                            color: const Color(0xFF1E142A),
                            child: const Icon(Icons.person, color: Colors.white24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              artist['name'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              artist['followers'] as String,
                              style: const TextStyle(
                                color: Color(0xFFD0BCFF),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 18),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
