import 'package:eventra/data/app_config.dart';
import 'package:eventra/data/eventra_database.dart';
import 'package:eventra/data/eventra_session.dart';
import 'package:eventra/features/auth/views/login_page.dart';
import 'package:eventra/features/home/views/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:eventra/core/constants/colors.dart';
import 'package:eventra/features/auth/controller/input_validator.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _selectedLocation;
  List<String> _cities = [];

  bool _isObscure = true;
  bool _isObscureConfirm = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    try {
      final cities = await EventraDatabase.instance.fetchCities();
      if (mounted) {
        setState(() {
          _cities = cities;
        });
      }
    } catch (_) {
      // Ignore city loading errors
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = await EventraDatabase.instance.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        location: _selectedLocation,
      );

      await EventraSession.instance.setUser(user);

      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.mainAppBackground),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
            child: Column(
              children: [
                // BOX CONTAINER TRANSPARAN (Glassmorphism)
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: const Color(0x4D1E1E2E),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Text(
                                AppConfig.instance.text(
                                  'brand.name',
                                  'EVENTRA',
                                ),
                                style: const TextStyle(
                                  color: Color(0xFFD0BCFF),
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              Text(
                                AppConfig.instance.text(
                                  'auth.register.title',
                                  'Create Account',
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                AppConfig.instance.text(
                                  'auth.register.subtitle',
                                  'Explore the best upcoming events!',
                                ),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),

                        // Input Fields
                        _buildLabel(
                          AppConfig.instance.text(
                            'auth.register.username',
                            'Username',
                          ),
                        ),
                        _buildTextField(
                          hint: AppConfig.instance.text(
                            'auth.register.username',
                            'Username',
                          ),
                          icon: Icons.person_outline,
                          controller: _usernameController,
                          validator: InputValidator.validateUsername,
                        ),
                        const SizedBox(height: 15),

                        _buildLabel(
                          AppConfig.instance.text(
                            'auth.register.phone',
                            'Phone Number',
                          ),
                        ),
                        _buildTextField(
                          hint: AppConfig.instance.text(
                            'auth.register.phone',
                            'Phone Number',
                          ),
                          icon: Icons.phone_outlined,
                          controller: _phoneController,
                          keyboardType: TextInputType.number,
                          validator: InputValidator.validatePhone,
                        ),
                        const SizedBox(height: 15),

                        _buildLabel('City'),
                        _buildTextField(
                          hint: 'Jakarta, Bandung, Surabaya...',
                          icon: Icons.location_on_outlined,
                          controller: _locationController,
                          textInputAction: TextInputAction.next,
                          validator: (val) {
                            final value = val?.trim() ?? '';
                            if (value.isEmpty) return 'City is required';
                            if (value.length < 3) return 'Enter a valid city';
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        _buildLabel(
                          AppConfig.instance.text(
                            'auth.register.email',
                            'Email',
                          ),
                        ),
                        _buildTextField(
                          hint: AppConfig.instance.text(
                            'auth.register.email',
                            'Email',
                          ),
                          icon: Icons.email_outlined,
                          controller: _emailController,
                          validator: InputValidator.validateEmail,
                        ),
                        const SizedBox(height: 15),

                        _buildLabel(
                          AppConfig.instance.text(
                            'auth.register.password',
                            'Password',
                          ),
                        ),
                        _buildTextField(
                          hint: AppConfig.instance.text(
                            'auth.register.password',
                            'Password',
                          ),
                          icon: Icons.lock_outline,
                          controller: _passwordController,
                          obscureText: _isObscure,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white54,
                            ),
                            onPressed: () =>
                                setState(() => _isObscure = !_isObscure),
                          ),
                          validator: InputValidator.validatePassword,
                        ),
                        const SizedBox(height: 15),

                        _buildLabel(
                          AppConfig.instance.text(
                            'auth.register.confirm_password',
                            'Confirm Password',
                          ),
                        ),
                        _buildTextField(
                          hint: AppConfig.instance.text(
                            'auth.register.confirm_password',
                            'Confirm Password',
                          ),
                          icon: Icons.lock_outline,
                          controller: _confirmPasswordController,
                          obscureText: _isObscureConfirm,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white54,
                            ),
                            onPressed: () => setState(
                              () => _isObscureConfirm = !_isObscureConfirm,
                            ),
                          ),
                          validator: (val) =>
                              InputValidator.validateConfirmPassword(
                                val,
                                _passwordController.text,
                              ),
                        ),
                        const SizedBox(height: 15),

                        _buildLabel(AppConfig.instance.text('auth.register.location', 'Location')),
                        _buildDropdownField(
                          hint: AppConfig.instance.text('auth.register.location', 'Select Location'),
                          icon: Icons.location_on_outlined,
                          value: _selectedLocation,
                          items: _cities,
                          onChanged: (val) => setState(() => _selectedLocation = val),
                          validator: (val) => val == null || val.isEmpty ? 'Please select a location' : null,
                        ),
                        const SizedBox(height: 35),

                        // REGISTER BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD0BCFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF4D2B6C),
                                    ),
                                  )
                                : Text(
                                    AppConfig.instance.text(
                                      'auth.register.submit',
                                      'Register',
                                    ),
                                    style: const TextStyle(
                                      color: Color(0xFF4D2B6C),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // LOGIN LINK
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppConfig.instance.text(
                                'auth.register.login_prompt',
                                'Already have an account? ',
                              ),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              ),
                              child: Text(
                                AppConfig.instance.text(
                                  'auth.register.login_action',
                                  'Log in',
                                ),
                                style: const TextStyle(
                                  color: Color(0xFFD0BCFF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    "Privacy Policy • Terms of Service",
                    style: TextStyle(color: Color(0x66FFFFFF), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Color(0x33000000),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFD0BCFF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((city) {
        return DropdownMenuItem(
          value: city,
          child: Text(city, style: const TextStyle(color: Colors.white, fontSize: 14)),
        );
      }).toList(),
      onChanged: onChanged,
      dropdownColor: const Color(0xFF1B1526),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        filled: true,
        fillColor: const Color(0x33000000),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFD0BCFF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
      validator: validator,
    );
  }
}
