import 'package:eventra/data/app_config.dart';
import 'package:eventra/data/eventra_database.dart';
import 'package:eventra/core/utils/search_match.dart';
import 'package:eventra/core/widgets/subpage_shell.dart';
import 'package:eventra/features/explore/artists/artists_profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrendingArtistsPage extends StatefulWidget {
  const TrendingArtistsPage({super.key, this.searchQuery = ''});

  final String searchQuery;

  @override
  State<TrendingArtistsPage> createState() => _TrendingArtistsPageState();
}

class _TrendingArtistsPageState extends State<TrendingArtistsPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> artistsData = [];
  bool _isLoading = true;
  String _localSearchQuery = '';

  String get _effectiveSearchQuery =>
      normalizeSearchText(_localSearchQuery).isNotEmpty
      ? _localSearchQuery
      : widget.searchQuery;

  List<Map<String, dynamic>> get _filteredArtists => artistsData
      .where(
        (artist) => matchesSearchQuery(_effectiveSearchQuery, [
          artist['name'],
          artist['followers'],
          artist['location'],
          artist['description'],
          artist['genre'],
          artist['upcomingEvents'],
        ]),
      )
      .toList();

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD0BCFF)),
      );
    }

    final filteredArtists = _filteredArtists;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF16111F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'EVENTRA',
          style: GoogleFonts.poppins(
            color: const Color(0xFFD0BCFF),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppConfig.instance.text('artists.title', 'Trending Artists'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
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

            _buildSearchField(),
            const SizedBox(height: 24),

            if (filteredArtists.isEmpty)
              _buildEmptySearchState()
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredArtists.length,
                itemBuilder: (context, index) {
                  final artist = filteredArtists[index];
                  final rank = index + 1;

                  final String rawImageUrl =
                      artist['imageUrl'] ?? artist['avatar_url'] ?? '';

                  final preparedArtistData = {
                    ...artist,
                    'imageUrl': rawImageUrl,
                    'followers': artist['followers'],
                    'rank': rank,
                    'upcomingEvents': artist['upcomingEvents'] ?? [],
                  };

                  if (rank <= 3) {
                    // TAMPILAN BIG BOX (RANK 1-3)
                    return GestureDetector(
                      onTap: () =>
                          _navigateToProfile(context, preparedArtistData),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1526).withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
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
                                    child: _buildArtistImage(
                                      rawImageUrl,
                                      250,
                                      250,
                                    ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (artist['name'] as String? ??
                                                  'Unknown Artist')
                                              .toUpperCase(),
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
                      onTap: () =>
                          _navigateToProfile(context, preparedArtistData),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
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
                                    (artist['name'] as String? ??
                                            'Unknown Artist')
                                        .toUpperCase(),
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
      ),
    );
  }

  void _navigateToProfile(BuildContext context, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventraSubpageShell(
          currentIndex: 1,
          child: ArtistProfilePage(artistData: data),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _searchController,
        builder: (context, value, _) {
          return TextField(
            controller: _searchController,
            onChanged: (text) => setState(() => _localSearchQuery = text),
            textInputAction: TextInputAction.search,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
            cursorColor: const Color(0xFFD0BCFF),
            decoration: InputDecoration(
              hintText: 'Find your favorite artists here...',
              hintStyle: GoogleFonts.poppins(
                color: Colors.white38,
                fontSize: 13,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.white38,
                size: 18,
              ),
              suffixIcon: value.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white54,
                        size: 18,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _localSearchQuery = '');
                      },
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 34),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1526),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off, color: Color(0xFFD0BCFF), size: 34),
          const SizedBox(height: 12),
          Text(
            'No artists match your search.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholder(width, height),
      );
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholder(width, height),
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
