import 'package:eventra/data/app_config.dart';
import 'package:eventra/data/eventra_database.dart';
import 'package:eventra/data/eventra_session.dart';
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
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isObscure = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = await EventraDatabase.instance.login(
        identifier: _identifierController.text.trim(),
        password: _passwordController.text,
      );

      EventraSession.instance.setUser(user);

      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
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
                          AppConfig.instance.text('brand.name', 'EVENTRA'),

                          style: GoogleFonts.poppins(
                            color: const Color(0xFFD0BCFF),
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -2,
                          ),
                        ),

                        /// SUBTITLE
                        Text(
                          AppConfig.instance.text(
                            'auth.login.subtitle',
                            "Unlock the night's best experiences!",
                          ),

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
                          controller: _identifierController,
                          style:
                              const TextStyle(color: Colors.white),

                          decoration: _buildInputDecoration(
                            AppConfig.instance.text(
                              'auth.login.identifier_hint',
                              'Email, phone, or username',
                            ),
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
                          controller: _passwordController,
                          obscureText: _isObscure,

                          style:
                              const TextStyle(color: Colors.white),

                          decoration: _buildInputDecoration(
                            AppConfig.instance.text(
                              'auth.login.password_hint',
                              'Password',
                            ),
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
                            onPressed: _isSubmitting ? null : _login,

                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFD0BCFF),

                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(15),
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
                                'auth.login.submit',
                                'Log in',
                              ),
                              style: const TextStyle(
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
                            Text(
                              AppConfig.instance.text(
                                'auth.login.signup_prompt',
                                "Don't have an account? ",
                              ),
                              style: const TextStyle(
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

                              child: Text(
                                AppConfig.instance.text(
                                  'auth.login.signup_action',
                                  'Sign up',
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
