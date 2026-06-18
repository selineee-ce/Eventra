import 'dart:convert';
import 'package:eventra/data/app_config.dart';
import 'package:eventra/data/eventra_database.dart';
import 'package:eventra/data/eventra_session.dart';
import 'package:eventra/core/widgets/subpage_shell.dart';
import 'package:eventra/features/auth/views/login_page.dart';
import 'package:eventra/features/home/views/notification_page.dart';
import 'package:eventra/features/home/views/main_screen.dart';
import 'package:eventra/data/promotor_api.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PromotorProfilePage extends StatefulWidget {
  const PromotorProfilePage({super.key});

  @override
  State<PromotorProfilePage> createState() => _PromotorProfilePageState();
}

class _PromotorProfilePageState extends State<PromotorProfilePage> {
  Map<String, dynamic> _profile = {};
  bool _isLoading = true;
  int _draftCount = 0;
  int _liveCount = 0;
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = EventraSession.instance.userId;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final results = await Future.wait([
        EventraDatabase.instance.fetchProfile(),
        PromotorApi.instance.fetchEvents(userId),
      ]);

      if (!mounted) return;

      final profile = results[0] as Map<String, dynamic>;
      final events = results[1] as List<Map<String, dynamic>>;

      setState(() {
        _profile = profile;
        _draftCount = events.where((e) => e['status'] == 'draft').length;
        _liveCount = events.where((e) => e['status'] == 'live').length;
        _completedCount = events.where((e) => e['status'] == 'completed').length;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _profile = EventraSession.instance.currentUser ?? {};
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0717),
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

                      _buildAvatar(_profile['avatar_url'] as String?),
                      const SizedBox(height: 15),

                      Text(
                        _profile['name']?.toString() ?? '',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),

                      Text(
                        (_profile['description']?.toString().isNotEmpty == true)
                            ? _profile['description'].toString()
                            : 'No bio yet.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white60,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 18),

                      SizedBox(
                        width: 160,
                        child: ElevatedButton.icon(
                          onPressed: () => _showEditProfileModal(context),
                          icon: const Icon(Icons.edit, size: 18, color: Color(0xFF4D2B6C)),
                          label: Text(
                            'EDIT PROFILE',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF4D2B6C),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD0BCFF),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      Row(
                        children: [
                          _buildStatCard(_draftCount.toString(), 'DRAFT'),
                          const SizedBox(width: 10),
                          _buildStatCard(_liveCount.toString(), 'LIVE'),
                          const SizedBox(width: 10),
                          _buildStatCard(_completedCount.toString(), 'COMPLETED'),
                        ],
                      ),
                      const SizedBox(height: 25),
                      
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'ACCOUNT SETTINGS',
                          style: GoogleFonts.poppins(
                            color: Colors.white60,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const MainScreen()),
                            (route) => false,
                          );
                        },
                        child: _buildSettingsItem(
                          icon: Icons.swap_horiz,
                          title: 'Customer View',
                          statusText: '• SWITCH BACK',
                          statusColor: const Color(0xFF4FA7FF),
                          trailingWidget: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'SWITCH',
                                style: GoogleFonts.poppins(
                                  color: Colors.white38,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.loop, color: Colors.white38, size: 14),
                            ],
                          ),
                          showChevron: false,
                        ),
                      ),

                      GestureDetector(
                        onTap: () => _showCompanyDialog(context),
                        child: _buildSettingsItem(
                          icon: Icons.business_outlined,
                          title: 'Company',
                          statusText: _profile['company']?.toString().isNotEmpty == true
                              ? _profile['company'] as String
                              : 'Not set',
                          isLast: true,
                        ),
                      ),

                      const SizedBox(height: 25),

                      GestureDetector(
                        onTap: () async {
                          await EventraSession.instance.clear();
                          if (!mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
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
                builder: (_) => const EventraSubpageShell(
                  currentIndex: 4,
                  child: NotificationPage(),
                ),
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

    try {
      ImageProvider imageProvider;
      if (avatarUrl.startsWith('http')) {
        imageProvider = NetworkImage(avatarUrl);
      } else if (avatarUrl.startsWith('data:image')) {
        final base64Str = avatarUrl.split(',').last;
        imageProvider = MemoryImage(base64Decode(base64Str));
      } else if (avatarUrl.startsWith('assets/')) {
        imageProvider = AssetImage(avatarUrl);
      } else {
        return const CircleAvatar(
          radius: 55,
          backgroundColor: Colors.white10,
          child: Icon(Icons.person, size: 75, color: Colors.white24),
        );
      }
      return CircleAvatar(
        radius: 55,
        backgroundColor: Colors.white10,
        backgroundImage: imageProvider,
      );
    } catch (_) {
      return const CircleAvatar(
        radius: 55,
        backgroundColor: Colors.white10,
        child: Icon(Icons.person, size: 75, color: Colors.white24),
      );
    }
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
                color: const Color(0xFFD0BCFF),
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white38,
                fontSize: 11,
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
          if (trailingWidget != null) trailingWidget,
          if (showChevron) ...[
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
          ],
        ],
      ),
    );
  }
  
  Future<void> _showEditProfileModal(BuildContext context) async {
    final nameCtrl = TextEditingController(text: _profile['name'] as String? ?? '');
    final aboutCtrl = TextEditingController(text: _profile['description'] as String? ?? '');
    final avatarCtrl = TextEditingController(text: _profile['avatar_url'] as String? ?? '');

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B1526),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(controller: nameCtrl, label: 'Name', hint: 'Enter your name'),
              const SizedBox(height: 16),
              _buildTextField(controller: aboutCtrl, label: 'About', hint: 'Enter your bio', maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField(controller: avatarCtrl, label: 'Avatar URL', hint: 'Enter image URL'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCEL', style: GoogleFonts.poppins(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('SAVE', style: GoogleFonts.poppins(color: const Color(0xFFD0BCFF), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (saved == true) {
      try {
        await EventraDatabase.instance.updateProfile({
          'name': nameCtrl.text.trim(),
          'description': aboutCtrl.text.trim(),
          'avatar_url': avatarCtrl.text.trim(),
        });
        await _loadData();
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
  
  Future<void> _showCompanyDialog(BuildContext context) async {
    final companyCtrl = TextEditingController(text: _profile['company'] as String? ?? '');

    final String? newCompany = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B1526),
        title: Text(
          'Company Name',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: companyCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your organization or company name',
            hintStyle: const TextStyle(color: Colors.white38),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white10),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD0BCFF)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: GoogleFonts.poppins(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, companyCtrl.text.trim()),
            child: Text('SAVE', style: GoogleFonts.poppins(color: const Color(0xFFD0BCFF), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (newCompany != null && newCompany.isNotEmpty) {
      try {
        await EventraDatabase.instance.updateProfile({'company': newCompany});
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Company updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update company: $e')),
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
        Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
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
}