import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'app_state.dart';
import 'app_state.dart' show NGColors;

// ────────────────────────────────────────────────────────────────────────────
//  LOGIN SCREEN — Nakshatra Gold & Diamonds
// ────────────────────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  final AppState state;
  const LoginScreen({super.key, required this.state});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, a1, a2) => HomeScreen(state: widget.state),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NGColors.obsidian,
      body: Stack(
        children: [
          // ── Background decorative layers ──────────────────────────────
          _GoldOrbBackground(),

          // ── Scrollable content ────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      const SizedBox(height: 52),

                      // ── Logo & Brand Name ─────────────────────────────
                      _buildBrandHeader(),

                      const SizedBox(height: 52),

                      // ── Login Form Card ───────────────────────────────
                      _buildFormCard(),

                      const SizedBox(height: 32),

                      // ── Footer ────────────────────────────────────────
                      _buildFooter(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Brand Header ───────────────────────────────────────────────────────────
  Widget _buildBrandHeader() {
    return Column(
      children: [
        // Diamond icon with gold ring
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD4AF37), Color(0xFF8B6914)],
            ),
            boxShadow: [
              BoxShadow(
                color: NGColors.gold.withOpacity(0.45),
                blurRadius: 32,
                spreadRadius: 4,
              ),
            ],
          ),
            child: Image.asset(
            'assets/images/logo.png', // Replace with your actual logo asset path
            width: 60,
            height: 60,
            fit: BoxFit.contain,
            ),
        ),

        const SizedBox(height: 22),

        
        const SizedBox(height: 4),
        
      

        const SizedBox(height: 14),

        const Text(
          'Operations Dashboard',
          style: TextStyle(
            color: Color(0xFF888888),
            fontSize: 13,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  // ── Form Card ──────────────────────────────────────────────────────────────
  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: NGColors.gold.withOpacity(0.22),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sign In',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Access your workspace',
            style: TextStyle(color: Color(0xFF666666), fontSize: 13),
          ),

          const SizedBox(height: 28),

          // Email Field
          _GoldTextField(
            controller: _emailCtrl,
            hint: 'Email address',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 16),

          // Password Field
          _GoldTextField(
            controller: _passCtrl,
            hint: 'Password',
            icon: Icons.lock_outline_rounded,
            obscure: _obscure,
            suffix: GestureDetector(
              onTap: () => setState(() => _obscure = !_obscure),
              child: Icon(
                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: NGColors.gold.withOpacity(0.7),
                size: 20,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero, minimumSize: Size.zero),
              child: const Text(
                'Forgot password?',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Sign In Button
          _GoldButton(
            label: 'SIGN IN',
            loading: _loading,
            onTap: _login,
          ),
        ],
      ),
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          '© 2025 Nakshatra Gold & Diamonds',
          style: TextStyle(
            color: Colors.white.withOpacity(0.2),
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'All rights reserved. Authorised personnel only.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.12),
            fontSize: 10,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
//  GOLD TEXT FIELD
// ────────────────────────────────────────────────────────────────────────────
class _GoldTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const _GoldTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
  });

  @override
  State<_GoldTextField> createState() => _GoldTextFieldState();
}

class _GoldTextFieldState extends State<_GoldTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focused
              ? NGColors.gold.withOpacity(0.8)
              : const Color(0xFF2E2E2E),
          width: _focused ? 1.5 : 1,
        ),
        color: const Color(0xFF1C1C1C),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: NGColors.gold.withOpacity(0.12),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: Focus(
        onFocusChange: (f) => setState(() => _focused = f),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.obscure,
          keyboardType: widget.keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          cursorColor: NGColors.gold,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: Color(0xFF505050), fontSize: 14),
            prefixIcon: Icon(widget.icon,
                color: _focused
                    ? NGColors.gold.withOpacity(0.9)
                    : const Color(0xFF505050),
                size: 20),
            suffixIcon: widget.suffix != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: widget.suffix)
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
//  GOLD BUTTON
// ────────────────────────────────────────────────────────────────────────────
class _GoldButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;

  const _GoldButton(
      {required this.label, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD4AF37), Color(0xFF8B6914), Color(0xFFD4AF37)],
            stops: [0, 0.5, 1],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: NGColors.gold.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                  ),
                ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
//  GOLD LINE DIVIDER
// ────────────────────────────────────────────────────────────────────────────
class _GoldLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            NGColors.gold.withOpacity(0),
            NGColors.gold.withOpacity(0.6),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
//  BACKGROUND ORB DECORATION
// ────────────────────────────────────────────────────────────────────────────
class _GoldOrbBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top-right gold glow
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  NGColors.gold.withOpacity(0.14),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Bottom-left subtle glow
        Positioned(
          bottom: -60,
          left: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  NGColors.goldDark.withOpacity(0.10),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Horizontal gold shimmer line
        Positioned(
          top: 200,
          left: 0,
          right: 0,
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  NGColors.gold.withOpacity(0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
