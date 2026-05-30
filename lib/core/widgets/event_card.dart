import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventraEventCard extends StatelessWidget {
  const EventraEventCard({
    super.key,
    required this.image,
    required this.dateLabel,
    required this.title,
    required this.venueLabel,
    this.subtitle,
    this.actionLabel = 'GET TICKETS',
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
    this.onActionTap,
  });

  final String image;
  final String dateLabel;
  final String title;
  final String venueLabel;
  final String? subtitle;
  final String actionLabel;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF23172F),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 116,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(child: _buildImage()),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.24),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.34),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(top: 8, left: 8, child: _buildDatePill()),
                    Positioned(top: 8, right: 8, child: _buildFavoriteButton()),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        bottom: 38,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 15,
                                height: 1.1,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (subtitle != null && subtitle!.isNotEmpty) ...[
                              const SizedBox(height: 1),
                              Text(
                                subtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  height: 1.1,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                venueLabel.toUpperCase(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.white60,
                                  fontSize: 9,
                                  height: 1.15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            _buildActionButton(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (image.isEmpty) {
      return _buildImageFallback();
    }

    if (image.startsWith('http://') || image.startsWith('https://')) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImageFallback(),
      );
    }

    return Image.asset(
      image,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImageFallback(),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      color: const Color(0xFF2A2035),
      child: const Icon(Icons.music_note, color: Colors.white24, size: 40),
    );
  }

  Widget _buildDatePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        dateLabel,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: onFavoriteTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: Container(
          key: ValueKey(isFavorite),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFF3B3157).withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: const Color(0xFFD0BCFF),
            size: 19,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return GestureDetector(
      onTap: onActionTap ?? onTap,
      child: SizedBox(
        height: 28,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFD0BCFF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionLabel,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF4D2B6C),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward,
                  color: Color(0xFF4D2B6C),
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
