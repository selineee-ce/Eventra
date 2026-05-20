import 'package:flutter/material.dart';
import 'package:eventra/features/explore/artists/artists_profile.dart';
import 'package:google_fonts/google_fonts.dart';

class TrendingArtistsPage extends StatelessWidget {
  const TrendingArtistsPage({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> artistsData = const [
    {
      "name": "VON DAX",
      "followers": "4.8M Followers",
      "monthlyListeners": "4.8M",
      "eventsCount": "123",
      "genre": "Industrial Techno",
      "description": "Von Dax is a pioneer of the melodic techno movement, seamlessly weaving ethereal vocal textures into driving industrial rhythms. His sound defines the modern underground, capturing the pulse of the digital age with a soul that remains unmistakably human.",
      "imageUrl": "https://images.unsplash.com/photo-1516873240891-4bf014598ab4?w=800&auto=format&fit=crop&q=80",
      "upcomingEvents": [
        {"title": "Echoes of Solace", "lineup": "Von Dax, Anyma, Tale Of Us", "venue": "SKY ARENA", "location": "Marina Bay, Singapore", "date": "MAY 20"},
        {"title": "Neon Eclipse", "lineup": "Von Dax Live Set", "venue": "THE GRAND", "location": "Tokyo, Japan", "date": "JUN 14"}
      ]
    },
    {
      "name": "ELARA VOSS",
      "followers": "1.9M Followers",
      "monthlyListeners": "1.9M",
      "eventsCount": "64",
      "genre": "Melodic Techno",
      "description": "Elara Voss delivers atmospheric and deeply emotional melodic techno. Her cinematic synth swells and hypnotic percussion create an immersive sonic journey designed for massive festival stages and late-night stargazing.",
      "imageUrl": "https://images.unsplash.com/photo-1574169208507-84376144848b?w=800&auto=format&fit=crop&q=80",
      "upcomingEvents": [
        {"title": "Echoes of Solace", "lineup": "Elara Voss, Mind Against", "venue": "SKY ARENA", "location": "Marina Bay, Singapore", "date": "MAY 20"}
      ]
    },
    {
      "name": "MORPHEUS",
      "followers": "3.0M Followers",
      "monthlyListeners": "3.0M",
      "eventsCount": "89",
      "genre": "Acid House",
      "description": "Morpheus bends reality with nostalgic 303 acid basslines fused with modern neonelectro aesthetics. Known for high-energy underground raves, his tracks bridge the gap between 90s warehouse culture and futuristic cyber soundscapes.",
      "imageUrl": "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800&auto=format&fit=crop&q=80",
      "upcomingEvents": [
        {"title": "Acid Awakening", "lineup": "Morpheus, Peggy Gou", "venue": "THE HIVE", "location": "Seoul, South Korea", "date": "MAY 28"}
      ]
    },
    {
      "name": "CYBERIAN",
      "followers": "1.5M Followers",
      "monthlyListeners": "1.5M",
      "eventsCount": "42",
      "genre": "Hard Techno",
      "description": "Fast, aggressive, and uncompromising. Cyberian commands the underground scene with relentless 150 BPM industrial beats and dark, metallic sound designs that push audio systems to their absolute limits.",
      "imageUrl": "https://images.unsplash.com/photo-1598387181032-a3103a2db5b3?w=800&auto=format&fit=crop&q=80",
      "upcomingEvents": [
        {"title": "Subterranean Overdrive", "lineup": "Cyberian, Sara Landry", "venue": "BASEMENT 9", "location": "Berlin, Germany", "date": "JUN 02"}
      ]
    },
    {
      "name": "NOVA RAINE",
      "followers": "1.2M Followers",
      "monthlyListeners": "1.2M",
      "eventsCount": "51",
      "genre": "Melodic House",
      "description": "Nova Raine blends uplifting progressive melodies with deep, organic house grooves. Her music captures the warmth of a beach sunrise, mixed with the sleek production of modern electronic club tracks.",
      "imageUrl": "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800&auto=format&fit=crop&q=80",
      "upcomingEvents": [
        {"title": "Horizon Sunset Sessions", "lineup": "Nova Raine", "venue": "OCEAN DOME", "location": "Bali, Indonesia", "date": "JUL 19"}
      ]
    },
    {
      "name": "VOIDWALKER",
      "followers": "980K Followers",
      "monthlyListeners": "980K",
      "eventsCount": "35",
      "genre": "Dark Techno",
      "description": "Emerging from the deep shadows of the digital subculture, Voidwalker crafts eerie, minimalist techno tracks utilizing heavy sub-bass and haunting ambient layers that test the boundaries of dark electronic art.",
      "imageUrl": "https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=800&auto=format&fit=crop&q=80",
      "upcomingEvents": []
    },
    {
      "name": "LUNA CRYSTAL",
      "followers": "850K Followers",
      "monthlyListeners": "850K",
      "eventsCount": "29",
      "genre": "Ambient Techno",
      "description": "Luna Crystal provides a dreamy, space-like escape with lush soundscapes and soft, drifting rhythmic beats. Perfect for deep focus or late-night decompression under a neon sky.",
      "imageUrl": "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&auto=format&fit=crop&q=80",
      "upcomingEvents": [
        {"title": "Stardust Echoes", "lineup": "Luna Crystal", "venue": "NEBULA LOUNGE", "location": "Kyoto, Japan", "date": "AUG 05"}
      ]
    },
    {
      "name": "VECTOR BLITZ",
      "followers": "720K Followers",
      "monthlyListeners": "720K",
      "eventsCount": "47",
      "genre": "Glitch Tech",
      "description": "A chaotic yet perfectly engineered fusion of digitized glitch effects and rapid techno percussion. Vector Blitz redefines cyberpunk sonics with glitchy modular synthesizer experiments.",
      "imageUrl": "https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=800&auto=format&fit=crop&q=80",
      "upcomingEvents": []
    },
    {
      "name": "OXYGEN 7",
      "followers": "610K Followers",
      "monthlyListeners": "610K",
      "eventsCount": "18",
      "genre": "Deep House",
      "description": "Smooth chord progressions, deep basslines, and soulful vocal chops form the identity of Oxygen 7. A breath of fresh air tailored for intimate lounge spaces and premium rooftop events.",
      "imageUrl": "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800&auto=format&fit=crop&q=80",
      "upcomingEvents": []
    },
    {
      "name": "DEEP STATE",
      "followers": "540K Followers",
      "monthlyListeners": "540K",
      "eventsCount": "22",
      "genre": "Minimal Techno",
      "description": "Deep State practices the art of restraint. Using micro-samples and strict, clinical loop arrangements, they build hypnotic, evolving rhythms that lock dancefloors into deep, long-lasting trances.",
      "imageUrl": "https://images.unsplash.com/photo-1484755560693-a4074577af3a?w=800&auto=format&fit=crop&q=80",
      "upcomingEvents": []
    },
    {
      "name": "KRYPTIC",
      "followers": "430K Followers",
      "monthlyListeners": "430K",
      "eventsCount": "15",
      "genre": "Dubstep / Leftfield",
      "description": "Heavy system music engineered for massive subwoofers. Kryptic drops deep, dark, spacey basslines combined with crisp syncopated garage beats that echo the UK underground rave heritage.",
      "imageUrl": "https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?w=800&auto=format&fit=crop&q=80",
      "upcomingEvents": []
    },
    {
      "name": "ECHO PULSE",
      "followers": "390K Followers",
      "monthlyListeners": "390K",
      "eventsCount": "31",
      "genre": "Synthwave",
      "description": "Nostalgic 1980s retro-futurism re-imagined for 2026. Echo Pulse drives neon-soaked basslines, retro drums, and emotional analog leads straight into the hearts of cyberpunk fans worldwide.",
      "imageUrl": "https://images.unsplash.com/photo-1614850523459-c2f4c699c52e?w=800&auto=format&fit=crop&q=80",
      "upcomingEvents": [
        {"title": "Midnight Drive Tour", "lineup": "Echo Pulse, Kavinsky", "venue": "RETRO DOME", "location": "Los Angeles, USA", "date": "SEP 12"}
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            "Trending Artists",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "The architects of sound currently shaping the global underground landscape",
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
              int rank = index + 1;

              if (rank <= 3) {
                // DESIGN RANK 1, 2, 3 (FOTO DI ATAS, DETAIL DI BAWAH)
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ArtistProfilePage(artistData: artist)),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20, left: 20),
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              artist['imageUrl'],
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) => child,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: const Color(0xFF1E142A),
                                child: const Icon(Icons.person, color: Colors.white24, size: 50),
                              ),
                            ),
                          ),
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      artist['name'],
                                      style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      artist['genre'],
                                      style: const TextStyle(color: Colors.purpleAccent, fontSize: 15, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      artist['followers'],
                                      style: const TextStyle(color: Color(0XFFD0BCFF), fontSize: 18, fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ),
                              // Angka Rank Besar 1, 2, 3
                              Text(
                                "$rank",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.07), 
                                  fontSize: 85, 
                                  fontWeight: FontWeight.w900, 
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios, color: Color(0XFFD0BCFF), size: 25),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // DESIGN RANK 4 - 12 (FOTO DUA KALI LIPAT LEBIH GEDE + DETAIL GEDE + NO ENTER)
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ArtistProfilePage(artistData: artist)),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 46,
                          child: Text(
                            rank < 10 ? "0$rank" : "$rank",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.15), 
                              fontSize: 30, 
                              fontWeight: FontWeight.bold, 
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B1426),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Image.network(
                              artist['imageUrl'],
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) => child,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.white24, size: 30),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                artist['name'],
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                artist['genre'],
                                style: const TextStyle(color: Colors.purpleAccent, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                artist['followers'],
                                style: const TextStyle(color: Colors.white38, fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 25),
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
}