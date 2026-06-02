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
    if (!mounted) return;

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
          const SizedBox(height: 20),
          
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF1B1526),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Find your favorites artists here...',
                    style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13),
                  ),
                ),
                const Icon(Icons.search, color: Colors.white38, size: 18),
              ],
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
              
              final String rawImageUrl = artist['imageUrl'] ?? artist['avatar_url'] ?? '';

              final preparedArtistData = {
                ...artist,
                'imageUrl': rawImageUrl,
                'followers': artist['followers'],
                'rank': rank,
                'upcomingEvents': artist['upcomingEvents']?? []
              };

              if (rank <= 3) {
                // TAMPILAN BIG BOX (RANK 1-3)
                return GestureDetector(
                  onTap: () => _navigateToProfile(context, preparedArtistData),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1526).withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: _buildArtistImage(rawImageUrl, 250, 250),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 10,
                              child: Text(
                                '$rank',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  fontSize: 84,
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.italic,
                                  height: 0.9,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (artist['name'] as String? ?? 'Unknown Artist').toUpperCase(),
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${artist['followers'] ?? '0'} Followers',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFFD0BCFF),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward,
                                color: Color(0xFFD0BCFF),
                                size: 26,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // TAMPILAN LIST BIASA (RANK 4+)
                return GestureDetector(
                  onTap: () => _navigateToProfile(context, preparedArtistData),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 54,
                          child: Text(
                            rank < 10 ? '0$rank' : '$rank',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.18),
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: _buildArtistImage(rawImageUrl, 82, 82),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (artist['name'] as String? ?? 'Unknown Artist').toUpperCase(),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${artist['followers'] ?? '0'} Followers',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFD0BCFF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white24,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _navigateToProfile(BuildContext context, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArtistProfilePage(artistData: data),
      ),
    );
  }

  Widget _buildArtistImage(String path, double width, double height) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path, 
        width: width, 
        height: height, 
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(width, height),
      );
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path, 
        width: width, 
        height: height, 
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(width, height),
      );
    }
    return _buildPlaceholder(width, height);
  }

  Widget _buildPlaceholder(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF1E142A),
      child: const Icon(Icons.person, color: Colors.white24),
    );
  }
}