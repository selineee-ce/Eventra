import 'package:eventra/features/auth/controller/input_validator.dart';
import 'package:eventra/features/auth/views/register_page.dart';
import 'package:flutter/material.dart';
import 'package:eventra/core/constants/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eventra/features/home/views/main_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  bool _isObscure = true;

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
            padding: const EdgeInsets.symmetric(horizontal: 30),

            child: Column(
              children: [
                /// LOGIN BOX
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

                      children: [
                        /// LOGO
                        Text(
                          "EVENTRA",

                          style: GoogleFonts.poppins(
                            color: const Color(0xFFD0BCFF),
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -2,
                          ),
                        ),

                        /// SUBTITLE
                        Text(
                          "Unlock the night's best experiences!",

                          textAlign: TextAlign.center,

                          style: GoogleFonts.poppins(
                            color: const Color(0xFFFFFFFF),
                            fontSize: 15,
                            fontWeight: FontWeight.w200,
                          ),
                        ),

                        const SizedBox(height: 40),

                        /// EMAIL INPUT
                        TextFormField(
                          style:
                              const TextStyle(color: Colors.white),

                          decoration: _buildInputDecoration(
                            "Email or Phone",
                            Icons.email_outlined,
                          ),

                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Required field";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        /// PASSWORD INPUT
                        TextFormField(
                          obscureText: _isObscure,

                          style:
                              const TextStyle(color: Colors.white),

                          decoration: _buildInputDecoration(
                            "Password",
                            Icons.lock_outline,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,

                                color: Colors.white54,
                              ),

                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              },
                            ),
                          ),

                          validator:
                              InputValidator.validatePassword,
                        ),

                        const SizedBox(height: 35),

                        /// LOGIN BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 55,

                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!
                                  .validate()) {
                                Navigator.pushAndRemoveUntil(
                                  context,

                                  MaterialPageRoute(
                                    builder: (context) => MainScreen(),
                                  ),

                                  (route) => false,
                                );
                              }
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFD0BCFF),

                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(15),
                              ),
                            ),

                            child: const Text(
                              "Log in",

                              style: TextStyle(
                                color: Color(0xFF4D2B6C),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// SIGN UP
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [
                            const Text(
                              "Don't have an account? ",

                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,

                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterPage(),
                                  ),
                                );
                              },

                              child: const Text(
                                "Sign up",

                                style: TextStyle(
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// INPUT DECORATION
  InputDecoration _buildInputDecoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(
        color: Colors.white38,
        fontSize: 14,
      ),

      prefixIcon: Icon(
        icon,
        color: Colors.white54,
        size: 20,
      ),

      filled: true,
      fillColor: Colors.black26,

      contentPadding:
          const EdgeInsets.symmetric(vertical: 18),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),

        borderSide: const BorderSide(
          color: Colors.white10,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),

        borderSide: const BorderSide(
          color: AppColors.primaryPurple,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),

        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),

        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
    );
  }
}