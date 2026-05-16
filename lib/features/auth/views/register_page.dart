import 'package:eventra/features/auth/views/login_page.dart';
import 'package:eventra/features/home/views/home_page.dart';
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
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isObscure = true;
  bool _isObscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.mainAppBackground,
        ),
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
                              const Text(
                                "EVENTRA",
                                style: TextStyle(
                                  color: Color(0xFFD0BCFF),
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              const Text(
                                "Create Account",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Text(
                                "Explore the best upcoming events!",
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),

                        // Input Fields
                        _buildLabel("Username"),
                        _buildTextField(
                          hint: "Username",
                          icon: Icons.person_outline,
                          validator: InputValidator.validateUsername,
                        ),
                        const SizedBox(height: 15),

                        _buildLabel("Phone Number"),
                        _buildTextField(
                          hint: "Phone Number",
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.number,
                          validator: InputValidator.validatePhone,
                        ),
                        const SizedBox(height: 15),

                        _buildLabel("Email"),
                        _buildTextField(
                          hint: "Email",
                          icon: Icons.email_outlined,
                          validator: InputValidator.validateEmail,
                        ),
                        const SizedBox(height: 15),

                        _buildLabel("Password"),
                        _buildTextField(
                          hint: "Password",
                          icon: Icons.lock_outline,
                          controller: _passwordController,
                          obscureText: _isObscure,
                          suffixIcon: IconButton(
                            icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
                            onPressed: () => setState(() => _isObscure = !_isObscure),
                          ),
                          validator: InputValidator.validatePassword,
                        ),
                        const SizedBox(height: 15),

                        _buildLabel("Confirm Password"),
                        _buildTextField(
                          hint: "Confirm Password",
                          icon: Icons.lock_outline,
                          controller: _confirmPasswordController,
                          obscureText: _isObscureConfirm,
                          suffixIcon: IconButton(
                            icon: Icon(_isObscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
                            onPressed: () => setState(() => _isObscureConfirm = !_isObscureConfirm),
                          ),
                          validator: (val) => InputValidator.validateConfirmPassword(val, _passwordController.text),
                        ),
                        const SizedBox(height: 35),

                        // REGISTER BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Navigasi langsung ke HomePage dan hapus semua halaman di belakangnya
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EventraHomePage(),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD0BCFF),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: const Text(
                              "Register",
                              style: TextStyle(
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
                            const Text("Already have an account? ", style: TextStyle(color: Colors.white70, fontSize: 15)),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginPage()),
                              ),
                              child: const Text(
                                "Log in",
                                style: TextStyle(
                                  color: Color(0xFFD0BCFF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
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
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField({required String hint, required IconData icon, TextEditingController? controller, bool obscureText = false, Widget? suffixIcon, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Color(0x33000000),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFD0BCFF), width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.redAccent)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
      validator: validator,
    );
  }
}