import 'dart:convert';

import 'package:eventra/core/constants/colors.dart';
import 'package:eventra/data/eventra_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.profile});

  final Map<String, dynamic> profile;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _avatarController;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  List<String> _cities = [];
  String? _selectedLocation;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameController =
        TextEditingController(text: p['name']?.toString() ?? '');
    _usernameController =
        TextEditingController(text: p['username']?.toString() ?? '');
    _bioController =
        TextEditingController(text: p['description']?.toString() ?? '');
    _phoneController =
        TextEditingController(text: p['phone']?.toString() ?? '');
    _emailController =
        TextEditingController(text: p['email']?.toString() ?? '');
    _avatarController =
        TextEditingController(text: p['avatar_url']?.toString() ?? '');
    _selectedLocation = p['location']?.toString();
    _loadCities();
  }

  Future<void> _loadCities() async {
    try {
      final cities = await EventraDatabase.instance.fetchCities();
      if (!mounted) return;
      setState(() {
        _cities = cities;
        // Keep selection valid — if current location isn't in list, add it
        if (_selectedLocation != null &&
            _selectedLocation!.isNotEmpty &&
            !_cities.contains(_selectedLocation)) {
          _cities = [_selectedLocation!, ..._cities];
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _avatarController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isNotEmpty && password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final payload = <String, dynamic>{
        'name': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'description': _bioController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'location': _selectedLocation ?? '',
        'avatar_url': _avatarController.text.trim(),
        if (password.isNotEmpty) 'password': password,
      };

      await EventraDatabase.instance.updateProfile(payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration:
            const BoxDecoration(gradient: AppColors.mainAppBackground),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      _buildAvatarSection(),
                      const SizedBox(height: 30),
                      _buildSectionLabel('PERSONAL INFO'),
                      const SizedBox(height: 14),
                      _buildField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Your display name',
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _usernameController,
                        label: 'Username',
                        hint: '@username',
                        icon: Icons.alternate_email,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _bioController,
                        label: 'Bio',
                        hint: 'Tell the world about yourself...',
                        icon: Icons.info_outline,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 30),
                      _buildSectionLabel('CONTACT INFO'),
                      const SizedBox(height: 14),
                      _buildField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: '+62 xxx xxxx xxxx',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'your@email.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildLocationDropdown(),
                      const SizedBox(height: 30),
                      _buildSectionLabel('CHANGE PASSWORD'),
                      const SizedBox(height: 14),
                      _buildPasswordField(
                        controller: _passwordController,
                        label: 'New Password',
                        hint: 'Leave blank to keep current',
                        obscure: _obscurePassword,
                        onToggle: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        hint: 'Re-enter new password',
                        obscure: _obscureConfirm,
                        onToggle: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      const SizedBox(height: 36),
                      _buildSaveButton(),
                      const SizedBox(height: 40),
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

  // ─────────────────────────── Widgets ───────────────────────────

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Edit Profile',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    final avatarUrl = _avatarController.text;
    ImageProvider? imageProvider;

    try {
      if (avatarUrl.startsWith('http')) {
        imageProvider = NetworkImage(avatarUrl);
      } else if (avatarUrl.startsWith('data:image')) {
        imageProvider =
            MemoryImage(base64Decode(avatarUrl.split(',').last));
      } else if (avatarUrl.startsWith('assets/')) {
        imageProvider = AssetImage(avatarUrl);
      }
    } catch (_) {
      imageProvider = null;
    }

    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 52,
                backgroundColor: Colors.white10,
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? const Icon(Icons.person,
                        size: 60, color: Colors.white24)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showAvatarUrlSheet,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0BCFF),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF1B1526), width: 2.5),
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 17, color: Color(0xFF4D2B6C)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _showAvatarUrlSheet,
          child: Text(
            'Change photo',
            style: GoogleFonts.poppins(
              color: const Color(0xFFD0BCFF),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showAvatarUrlSheet() {
    final controller =
        TextEditingController(text: _avatarController.text);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B1526),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 22,
          right: 22,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Avatar URL',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                  'Paste image URL or leave empty', Icons.link),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _avatarController.text = controller.text.trim();
                  });
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD0BCFF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Apply',
                    style: GoogleFonts.poppins(
                        color: const Color(0xFF4D2B6C),
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        color: Colors.white38,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
      ),
    );
  }

  Widget _buildLocationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: GoogleFonts.poppins(
            color: Colors.white60,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _cities.isEmpty
            ? Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF161124),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: Colors.white38, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _selectedLocation?.isNotEmpty == true
                          ? _selectedLocation!
                          : 'Loading cities...',
                      style: GoogleFonts.poppins(
                          color: Colors.white38, fontSize: 13),
                    ),
                    const Spacer(),
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Color(0xFFD0BCFF),
                        strokeWidth: 2,
                      ),
                    ),
                  ],
                ),
              )
            : DropdownButtonFormField<String>(
                value: (_selectedLocation != null &&
                        _selectedLocation!.isNotEmpty &&
                        _cities.contains(_selectedLocation))
                    ? _selectedLocation
                    : null,
                onChanged: (val) => setState(() => _selectedLocation = val),
                dropdownColor: const Color(0xFF1E1630),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.white38),
                style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Select your city',
                  hintStyle: GoogleFonts.poppins(
                      color: Colors.white24, fontSize: 13),
                  prefixIcon: const Icon(Icons.location_on_outlined,
                      color: Colors.white38, size: 20),
                  filled: true,
                  fillColor: const Color(0xFF161124),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.white10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFFD0BCFF), width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                items: _cities
                    .map((city) => DropdownMenuItem(
                          value: city,
                          child: Text(city,
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 14)),
                        ))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white60,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(
              color: Colors.white, fontSize: 14),
          decoration: _inputDecoration(hint, icon),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white60,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: GoogleFonts.poppins(
              color: Colors.white, fontSize: 14),
          decoration: _inputDecoration(hint, Icons.lock_outline).copyWith(
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white38,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.white24, fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.white38, size: 20),
      filled: true,
      fillColor: const Color(0xFF161124),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD0BCFF), width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD0BCFF),
          disabledBackgroundColor: Colors.white24,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Color(0xFF4D2B6C), strokeWidth: 2.5),
              )
            : Text(
                'Save Changes',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF4D2B6C),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
