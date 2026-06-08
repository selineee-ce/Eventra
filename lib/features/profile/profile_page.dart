import 'package:eventra/data/app_config.dart';
import 'package:eventra/data/eventra_database.dart';
import 'package:eventra/data/eventra_session.dart';
import 'package:eventra/features/auth/views/login_page.dart';
import 'package:eventra/features/home/views/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventraProfilePage extends StatefulWidget {
  const EventraProfilePage({super.key});

  @override
  State<EventraProfilePage> createState() => _EventraProfilePageState();
}

class _EventraProfilePageState extends State<EventraProfilePage> {
  Map<String, dynamic> profile = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final loadedProfile = await EventraDatabase.instance.fetchProfile();

      if (!mounted) {
        return;
      }

      setState(() {
        profile = loadedProfile;
        _isLoading = false;
      });

      // Update session with fresh data from database
      await EventraSession.instance.setUser(loadedProfile);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        profile = EventraSession.instance.currentUser ?? {};
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFD0BCFF)),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                const SizedBox(height: 6),

                _buildHeader(context),

                const SizedBox(height: 26),

                //PROFILE HEADER
                _buildAvatar(profile['avatar_url'] as String?),
                const SizedBox(height: 15),
                Text(
                  profile['name'] as String? ?? '',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  (profile['description']?.toString().isNotEmpty == true)
                      ? profile['description'] as String
                      : 'No bio yet.',
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 18),

                //EDIT PROFILE BUTTON
                SizedBox(
                  width: 160,
                  child: ElevatedButton.icon(
                    onPressed: () => _showEditProfileModal(context),
                    icon: const Icon(Icons.edit, size: 18, color: Color(0xFF4D2B6C)),
                    label: Text(
                      AppConfig.instance.text('profile.edit', 'EDIT PROFILE'),
                      style: GoogleFonts.poppins(color: Color(0xFF4D2B6C), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD0BCFF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                //STATS CARDS
                Row(
                  children: [
                    _buildStatCard(
                      _displayCount(profile['upcoming_events_count']),
                      AppConfig.instance.text(
                        'profile.stats.upcoming',
                        'UPCOMING EVENTS',
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      _displayCount(profile['followers_count']),
                      AppConfig.instance.text(
                        'profile.stats.followers',
                        'FOLLOWERS',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                //ACCOUNT SETTINGS LABEL
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppConfig.instance.text(
                      'profile.settings.title',
                      'ACCOUNT SETTINGS',
                    ),
                    style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                //ACCOUNT SETTINGS LIST
                _buildSettingsItem(
                  icon: Icons.campaign_outlined,
                  title: "Promoter Roles",
                  statusText: "• PENDING APPROVAL",
                  statusColor: const Color(0xFF4FA7FF),
                  trailingWidget: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "SWITCH",
                        style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.loop, color: Colors.white38, size: 14),
                    ],
                  ),
                  showChevron: false,
                ),
                GestureDetector(
                  onTap: () => _showLocationDialog(context),
                  child: _buildSettingsItem(
                    icon: Icons.location_on_outlined,
                    title: "Location",
                    statusText: profile['location'] as String? ?? 'Not set',
                    isLast: true,
                  ),
                ),

                const SizedBox(height: 25),

                // --- LOGOUT BUTTON ---
                GestureDetector(
                  onTap: () async {
                    await EventraSession.instance.clear();
                    if (!mounted) {
                      return;
                    }
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (route) => false,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout, color: Color(0xFFF47A7A), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          AppConfig.instance.text('profile.logout', 'LOG OUT'),
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFF47A7A),
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _showEditProfileModal(BuildContext context) async {
    final TextEditingController nameController = TextEditingController(
      text: profile['name'] as String? ?? '',
    );
    final TextEditingController aboutController = TextEditingController(
      text: profile['description'] as String? ?? '',
    );
    final TextEditingController avatarController = TextEditingController(
      text: profile['avatar_url'] as String? ?? '',
    );

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B1526),
          title: Text(
            'Edit Profile',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  controller: nameController,
                  label: 'Name',
                  hint: 'Enter your name',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: aboutController,
                  label: 'About',
                  hint: 'Enter your about info',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: avatarController,
                  label: 'Avatar URL',
                  hint: 'Enter image URL',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('CANCEL', style: GoogleFonts.poppins(color: Colors.white38)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('SAVE', style: GoogleFonts.poppins(color: Color(0xFFD0BCFF), fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );

    if (saved == true) {
      try {
        await EventraDatabase.instance.updateProfile({
          'name': nameController.text.trim(),
          'description': aboutController.text.trim(),
          'avatar_url': avatarController.text.trim(),
        });
        await _loadProfile();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $e')),
          );
        }
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF231A34),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _showLocationDialog(BuildContext context) async {
    final TextEditingController locationController = TextEditingController(
      text: profile['location'] as String? ?? '',
    );

    final String? newLocation = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B1526),
          title: Text(
            'Change Location',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: locationController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter your city (e.g. Jakarta, Bali)',
                  hintStyle: const TextStyle(color: Colors.white38),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white10),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD0BCFF)),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 8,
                children: ['Jakarta', 'Tangerang', 'Bali'].map((city) {
                  return ActionChip(
                    label: Text(city),
                    onPressed: () => locationController.text = city,
                    backgroundColor: const Color(0xFF231A34),
                    labelStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL', style: GoogleFonts.poppins(color: Colors.white38)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, locationController.text.trim()),
              child: Text('SAVE', style: GoogleFonts.poppins(color: Color(0xFFD0BCFF), fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );

    if (newLocation != null && newLocation.isNotEmpty) {
      try {
        await EventraDatabase.instance.updateProfile({'location': newLocation});
        await _loadProfile();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update location: $e')),
          );
        }
      }
    }
  }

  // Widget Helper untuk Kartu Statistik
  String _displayCount(dynamic value) {
    if (value == null) {
      return '0';
    }

    if (value is num) {
      return value.toString();
    }

    final parsed = int.tryParse(value.toString());
    return parsed?.toString() ?? value.toString();
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        const SizedBox(width: 48),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationPage(),
              ),
            );
          },
          icon: const Icon(Icons.notifications_none, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildAvatar(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return const CircleAvatar(
        radius: 55,
        backgroundColor: Colors.white10,
        child: Icon(Icons.person, size: 75, color: Colors.white24),
      );
    }

    ImageProvider imageProvider;
    if (avatarUrl.startsWith('http')) {
      imageProvider = NetworkImage(avatarUrl);
    } else {
      imageProvider = AssetImage(avatarUrl);
    }

    return CircleAvatar(
      radius: 55,
      backgroundColor: Colors.white10,
      backgroundImage: imageProvider,
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF161124),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                color: Color(0xFFD0BCFF),
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white38, 
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? statusText,
    Color? statusColor,
    Widget? trailingWidget,
    bool showChevron = true,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161124),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF231A34),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFB197FC), size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white, 
                    fontWeight: FontWeight.w500,
                    fontSize: 19,
                  ),
                ),
                if (statusText != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    statusText,
                    style: GoogleFonts.poppins(
                      color: statusColor ?? Colors.white38, 
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailingWidget != null) ...[
            trailingWidget,
          ],
          // Panah chevron ini hanya dirender jika showChevron bernilai true
          if (showChevron) ...[
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
          ],
        ],
      ),
    );
  }
}
