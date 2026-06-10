import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

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
    this.compact = false,
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
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : (compact ? 320.0 : 350.0);
        final scale = (width / 330).clamp(0.84, 1.08).toDouble();
        final isTight = width < 285;
        final padding = (compact ? 12.0 : 14.0) * scale;
        final cardHeight = compact ? 286.0 : 340.0;

        return GestureDetector(
          onTap: onTap,
          child: SizedBox(
            height: cardHeight,
            child: Container(
              constraints: BoxConstraints(maxWidth: compact ? 350 : 380),
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
                      height: (compact ? 132 : 170) * scale,
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
                          Positioned(
                            top: 8,
                            left: 8,
                            child: _buildDatePill(scale),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: _buildFavoriteButton(scale),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          padding,
                          padding * 0.85,
                          padding,
                          padding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: isTight ? 2 : 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: (compact ? 17 : 20) * scale,
                                height: 1.12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (subtitle != null && subtitle!.isNotEmpty) ...[
                              SizedBox(height: 5 * scale),
                              Text(
                                subtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: (compact ? 12 : 14) * scale,
                                  height: 1.2,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            const Spacer(),
                            if (isTight)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildVenueText(scale, maxLines: 2),
                                  SizedBox(height: 8 * scale),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: _buildActionButton(scale),
                                  ),
                                ],
                              )
                            else
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(child: _buildVenueText(scale)),
                                  SizedBox(width: 8 * scale),
                                  _buildActionButton(scale),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

    if (image.startsWith('data:image')) {
      try {
        final base64Str = image.split(',').last;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildImageFallback(),
        );
      } catch (_) {
        return _buildImageFallback();
      }
    }

    final cleanPath = image.startsWith('assets/') ? image.substring(7) : image;

    return Image.asset(
      cleanPath,
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

  Widget _buildVenueText(double scale, {int maxLines = 3}) {
    return Text(
      venueLabel.toUpperCase(),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.poppins(
        color: Colors.white70,
        fontSize: (compact ? 11 : 13) * scale,
        height: 1.18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildDatePill(double scale) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 6 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        dateLabel,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: (compact ? 11 : 12) * scale,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(double scale) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onFavoriteTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: Container(
          key: ValueKey(isFavorite),
          width: (compact ? 34 : 38) * scale,
          height: (compact ? 34 : 38) * scale,
          decoration: BoxDecoration(
            color: const Color(0xFF3B3157).withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: const Color(0xFFD0BCFF),
            size: (compact ? 20 : 22) * scale,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(double scale) {
    return GestureDetector(
      onTap: onActionTap ?? onTap,
      child: SizedBox(
        height: (compact ? 34 : 38) * scale,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFD0BCFF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: (compact ? 10 : 13) * scale,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionLabel,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF4D2B6C),
                    fontSize: (compact ? 10 : 12) * scale,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 5 * scale),
                Icon(
                  Icons.arrow_forward,
                  color: const Color(0xFF4D2B6C),
                  size: (compact ? 13 : 15) * scale,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
