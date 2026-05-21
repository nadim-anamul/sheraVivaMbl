import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../providers/auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    
    Future<void>.microtask(
      () => ref.read(authControllerProvider.notifier).restore(),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated && mounted) {
        context.go(AppRoutes.dashboard);
      }
      if (next.status == AuthStatus.failure && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(next.errorMessage!)),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Background custom glowing gradient mesh
          const Positioned.fill(
            child: _MeshBackground(),
          ),
          
          // Main Scrollable Body
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.95, end: 1.0).animate(_fadeAnimation),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  // Logo or App Brand Visual
                                  Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F766E).withOpacity(0.08),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: const Icon(
                                        Icons.school_outlined,
                                        size: 44,
                                        color: Color(0xFF0F766E),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Header Title - EXACTLY matches 'সেরা ভিভা লগইন'
                                  const Center(
                                    child: Text(
                                      'সেরা ভিভা লগইন',
                                      style: TextStyle(
                                        color: Color(0xFF0F766E),
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.25,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Center(
                                    child: Text(
                                      'ক্যাডার মক ভাইভা প্রিপারেশন প্ল্যাটফর্ম',
                                      style: TextStyle(
                                        color: const Color(0xFF0F766E).withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // Email Field
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      labelText: 'ইমেইল',
                                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                                      fillColor: Colors.white.withOpacity(0.6),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'ইমেইল দিন';
                                      }
                                      if (!value.contains('@')) {
                                        return 'সঠিক ইমেইল দিন';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Password Field
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      labelText: 'পাসওয়ার্ড',
                                      prefixIcon: const Icon(Icons.lock_outlined, size: 20),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword 
                                              ? Icons.visibility_outlined 
                                              : Icons.visibility_off_outlined,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                      fillColor: Colors.white.withOpacity(0.6),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.length < 6) {
                                        return 'ন্যূনতম ৬ অক্ষরের পাসওয়ার্ড দিন';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Login Button
                                  FilledButton(
                                    onPressed: state.status == AuthStatus.loading
                                        ? null
                                        : () async {
                                            final isValid =
                                                _formKey.currentState?.validate() ?? false;
                                            if (!isValid) {
                                              return;
                                            }
                                            await ref
                                                .read(authControllerProvider.notifier)
                                                .signIn(
                                                  email: _emailController.text.trim(),
                                                  password: _passwordController.text.trim(),
                                                );
                                          },
                                    child: state.status == AuthStatus.loading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text(
                                            'লগইন',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Premium Divider
                                  Row(
                                    children: [
                                      Expanded(child: Divider(color: const Color(0xFF64748B).withOpacity(0.2))),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(
                                          'সহজ পরীক্ষা',
                                          style: TextStyle(
                                            color: const Color(0xFF64748B).withOpacity(0.6),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Expanded(child: Divider(color: const Color(0xFF64748B).withOpacity(0.2))),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Quick Demo Auto-fill Button
                                  OutlinedButton.icon(
                                    onPressed: state.status == AuthStatus.loading
                                        ? null
                                        : () {
                                            _emailController.text = 'demo@seraviva.com';
                                            _passwordController.text = '123456';
                                          },
                                    icon: const Icon(Icons.bolt_outlined, color: Color(0xFF0F766E)),
                                    label: const Text(
                                      'ডেমো ক্রেডেনশিয়াল দিন',
                                      style: TextStyle(
                                        color: Color(0xFF0F766E),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0F766E).withOpacity(0.03),
                                      side: const BorderSide(color: Color(0xFF0F766E), width: 1.2),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Help text
                                  Center(
                                    child: Text(
                                      'ডেমো লগইন: demo@seraviva.com / 123456',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: const Color(0xFF64748B).withOpacity(0.8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeshBackground extends StatelessWidget {
  const _MeshBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MeshPainter(),
    );
  }
}

class _MeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    
    // Smooth rich sky-like background
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFEFF6FF), // soft sky blue
          Color(0xFFF0FDF4), // soft green
          Color(0xFFECFDF5), // soft emerald
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Glowing organic blobs
    final p1 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF0D9488).withOpacity(0.18), // Teal
          const Color(0xFF0D9488).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.15, size.height * 0.2), radius: size.width * 0.55));
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.2), size.width * 0.55, p1);

    final p2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFD97706).withOpacity(0.12), // Warm Amber
          const Color(0xFFD97706).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.85, size.height * 0.75), radius: size.width * 0.6));
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.75), size.width * 0.6, p2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
