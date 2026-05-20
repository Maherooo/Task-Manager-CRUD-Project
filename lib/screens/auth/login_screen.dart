import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_router.dart';
import '../../services/auth_service.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;
  bool _obscure = true;
  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _loading = true;
    });

    try {
      await _authService.signIn(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.home);
      }
    } on AuthException catch (e) {
      if (mounted) {
        _showError(e.message);
      }
    } catch (e) {
      if (mounted) {
        _showError('Something went wrong');
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const SizedBox(height: 60),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: const Icon(
                    Icons.checklist_rounded,
                    color: Color(0xFF6C63FF),

                    size: 30,
                  ),
                ),

                const SizedBox(height: 28),
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 28,

                    fontWeight: FontWeight.w800,

                    color: Color(0xFF1A1A2E),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Sign in to continue',

                  style: TextStyle(fontSize: 15, color: Colors.grey[500]),
                ),

                const SizedBox(height: 40),
                AppTextField(
                  controller: _emailCtrl,
                  label: 'Email address',
                  hint: 'you@example.com',

                  keyboardType: TextInputType.emailAddress,

                  prefixIcon: Icons.mail_outline_rounded,

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }

                    bool isValid = RegExp(
                      r'^[^@]+@[^@]+\.[^@]+',
                    ).hasMatch(value);

                    if (!isValid) {
                      return 'Enter valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),
                AppTextField(
                  controller: _passCtrl,
                  label: 'Password',

                  hint: '••••••••',
                  obscureText: _obscure,

                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscure = !_obscure;
                      });
                    },
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }

                    if (value.length < 6) {
                      return 'Minimum 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Sign In',

                  loading: _loading,

                  onPressed: _login,
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey[500]),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRouter.register);
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color(0xFF6C63FF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
