import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:btk_byte_benders/screens/login_screen.dart';
import 'package:btk_byte_benders/screens/signup_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openLink() async {
  final Uri url = Uri.parse(
    "https://github.com/MehmetEmreAksu/BTK-Academy-2026-Hackaton",
  );

  await launchUrl(url, mode: LaunchMode.platformDefault);
}

Future<void> main() async {
  // Supabase Setup
  await Supabase.initialize(
    url: 'https://your-supabase-url.supabase.co',
    anonKey: 'your-supabase-anon-key',
  );

  runApp(const RiskRadarLandingPage());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class RiskRadarLandingPage extends StatelessWidget {
  const RiskRadarLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Aizanoi ',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF060A14),
        useMaterial3: true,
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w800,
            letterSpacing: -2,
          ),
          headlineLarge: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
          ),
        ),
      ),
      home: const LandingScreen(),
    );
  }
}

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _pulseController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedGradientBackground(controller: _backgroundController),
          FloatingParticles(controller: _floatController),
          SingleChildScrollView(
            child: Column(
              children: [
                const ModernNavbar(),
                ModernHeroSection(pulseController: _pulseController),
                const SizedBox(height: 80),
                const StatsSection(),
                const SizedBox(height: 80),
                const ModernFeaturesSection(),
                const SizedBox(height: 80),
                const HowItWorksSection(),
                const SizedBox(height: 80),
                const TechStackSection(),
                const SizedBox(height: 80),
                const CTASection(),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FloatingParticles extends StatelessWidget {
  final AnimationController controller;

  const FloatingParticles({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlesPainter(controller.value),
          child: Container(),
        );
      },
    );
  }
}

class ParticlesPainter extends CustomPainter {
  final double animation;

  ParticlesPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B5CF6).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final x = (size.width / 20) * i;
      final y = size.height * 0.3 + math.sin(animation * 2 * math.pi + i) * 50;
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AnimatedGradientBackground extends StatelessWidget {
  final AnimationController controller;

  const AnimatedGradientBackground({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                math.sin(controller.value * 2 * math.pi) * 0.3,
                math.cos(controller.value * 2 * math.pi) * 0.3,
              ),
              radius: 1.5,
              colors: [
                const Color(0xFF6B46C1).withOpacity(0.2),
                const Color(0xFF1E40AF).withOpacity(0.1),
                const Color(0xFF060A14),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ModernNavbar extends StatefulWidget {
  const ModernNavbar({super.key});

  @override
  State<ModernNavbar> createState() => _ModernNavbarState();
}

class _ModernNavbarState extends State<ModernNavbar> {
  String? hoveredItem;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 900;

    return Container(
      margin: EdgeInsets.all(size.width < 600 ? 12 : 20),
      padding: EdgeInsets.symmetric(
        horizontal: size.width < 600 ? 16 : (isSmall ? 24 : 40),
        vertical: size.width < 600 ? 12 : 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(isSmall ? 16 : 24),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: isSmall
          ? Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6B46C1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_graph_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Aizanoi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Log In',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignUpScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Get Started'),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6B46C1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_graph_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Aizanoi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                /*if (size.width > 1100)
                  ...[
                    ('Features', Icons.grid_view_rounded),
                    ('Demo', Icons.play_circle_outline_rounded),
                    ('Docs', Icons.description_outlined),
                  ].map(
                    (item) => _NavItem(
                      title: item.$1,
                      icon: item.$2,
                      isHovered: hoveredItem == item.$1,
                      onHover: (hovered) {
                        setState(() => hoveredItem = hovered ? item.$1 : null);
                      },
                    ),
                  ),*/
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width < 1100 ? 16 : 24,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6B46C1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width < 1100 ? 16 : 28,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isHovered;
  final Function(bool) onHover;

  const _NavItem({
    required this.title,
    required this.icon,
    required this.isHovered,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isHovered
              ? Colors.white.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isHovered ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isHovered ? Colors.white : Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ModernHeroSection extends StatelessWidget {
  final AnimationController pulseController;

  const ModernHeroSection({super.key, required this.pulseController});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1200;
    final isTablet = size.width > 800;
    final padding = size.width < 600 ? 20.0 : (isTablet ? 60.0 : 40.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 60),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _buildHeroContent(context)),
                const SizedBox(width: 60),
                Expanded(child: _buildHeroDashboard()),
              ],
            )
          : Column(
              children: [
                _buildHeroContent(context),
                const SizedBox(height: 40),
                _buildHeroDashboard(),
              ],
            ),
    );
  }

  Widget _buildHeroContent(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final titleSize = size.width < 600
        ? 36.0
        : (size.width < 900 ? 48.0 : (size.width < 1200 ? 56.0 : 72.0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width < 600 ? 16 : 20,
            vertical: size.width < 600 ? 10 : 12,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF8B5CF6).withOpacity(0.2),
                const Color(0xFF6B46C1).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF8B5CF6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF8B5CF6),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  '🚀 Hackathon 2026 Project',
                  style: TextStyle(
                    color: const Color(0xFFB794F6),
                    fontSize: size.width < 600 ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: size.width < 600 ? 24 : 40),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFFB794F6)],
          ).createShader(bounds),
          child: Text(
            'AI-Powered\nFinancial Intelligence',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: -2,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: size.width < 600 ? 16 : 28),
        Text(
          'Real-time market analysis, risk detection, and automated\ninvestment insights powered by advanced AI agents.',
          style: TextStyle(
            color: const Color(0xFF94A3B8),
            fontSize: size.width < 600 ? 14 : (size.width < 900 ? 16 : 20),
            height: 1.7,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: size.width < 600 ? 24 : 48),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _GradientButton(
              text: 'Try Live Demo',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                );
              },
              icon: Icons.play_arrow_rounded,
            ),
            _OutlineButton(
              text: 'View GitHub',
              onPressed: openLink,
              icon: Icons.code_rounded,
            ),
          ],
        ),
        SizedBox(height: size.width < 600 ? 24 : 40),
        Wrap(
          spacing: size.width < 600 ? 12 : 32,
          runSpacing: 12,
          children: [
            _TrustBadge(icon: Icons.bolt_rounded, text: 'Real-time'),
            _TrustBadge(icon: Icons.security_rounded, text: 'Secure'),
            _TrustBadge(icon: Icons.auto_awesome, text: 'AI-Powered'),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroDashboard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size;
        final padding = size.width < 600 ? 16.0 : 32.0;

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size.width < 600 ? 20 : 32),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.02),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(size.width < 600 ? 10 : 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6B46C1)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.dashboard_rounded,
                      color: Colors.white,
                      size: size.width < 600 ? 18 : 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Live AI Dashboard',
                      style: TextStyle(
                        fontSize: size.width < 600 ? 16 : 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: pulseController,
                    builder: (context, child) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width < 600 ? 12 : 16,
                          vertical: size.width < 600 ? 6 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(
                              0xFF10B981,
                            ).withOpacity(0.3 + pulseController.value * 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withOpacity(pulseController.value),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '3 Active',
                              style: TextStyle(
                                color: const Color(0xFF10B981),
                                fontSize: size.width < 600 ? 11 : 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: size.width < 600 ? 20 : 32),
              _DashboardAlertCard(
                title: 'Market Risk Alert',
                description:
                    'Unusual volatility detected in semiconductor sector.',
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFF59E0B),
                value: '+12.5%',
              ),
              const SizedBox(height: 16),
              _DashboardAlertCard(
                title: 'News Analysis',
                description: 'Fed interest rate expectations updated by AI.',
                icon: Icons.newspaper_rounded,
                color: const Color(0xFF3B82F6),
                value: '8 sources',
              ),
              const SizedBox(height: 16),
              _DashboardAlertCard(
                title: 'Portfolio Insight',
                description:
                    'AI recommends defensive positioning for next 48h.',
                icon: Icons.auto_awesome,
                color: const Color(0xFF8B5CF6),
                value: '94% conf.',
              ),
              SizedBox(height: size.width < 600 ? 16 : 24),
              Container(
                height: size.width < 600 ? 120 : 180,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CustomPaint(
                    painter: MiniChartPainter(),
                    child: Container(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData icon;

  const _GradientButton({
    required this.text,
    required this.onPressed,
    required this.icon,
  });

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0.0, isHovered ? -2.0 : 0.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isHovered
                ? [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)]
                : [const Color(0xFF6B46C1), const Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withOpacity(isHovered ? 0.5 : 0.3),
              blurRadius: isHovered ? 20 : 12,
              offset: Offset(0, isHovered ? 8 : 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.symmetric(
              horizontal: size.width < 600 ? 20 : 32,
              vertical: size.width < 600 ? 14 : 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: size.width < 600 ? 18 : 20),
              const SizedBox(width: 8),
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: size.width < 600 ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData icon;

  const _OutlineButton({
    required this.text,
    required this.onPressed,
    required this.icon,
  });

  @override
  State<_OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<_OutlineButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isHovered
              ? Colors.white.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isHovered
                ? Colors.white.withOpacity(0.3)
                : Colors.white.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: TextButton(
          onPressed: widget.onPressed,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: size.width < 600 ? 20 : 32,
              vertical: size.width < 600 ? 14 : 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: size.width < 600 ? 18 : 20,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: size.width < 600 ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TrustBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: size.width < 600 ? 14 : 16,
          color: const Color(0xFF8B5CF6),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: const Color(0xFF94A3B8),
            fontSize: size.width < 600 ? 12 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DashboardAlertCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String value;

  const _DashboardAlertCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.all(size.width < 600 ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(size.width < 600 ? 10 : 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: size.width < 600 ? 18 : 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: size.width < 600 ? 13 : 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: size.width < 600 ? 11 : 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: size.width < 600 ? 11 : 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class MiniChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF8B5CF6).withOpacity(0.3),
          const Color(0xFF8B5CF6).withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final points = [0.2, 0.5, 0.3, 0.7, 0.4, 0.6, 0.8, 0.5, 0.9, 0.3];

    path.moveTo(0, size.height);
    for (var i = 0; i < points.length; i++) {
      final x = (size.width / (points.length - 1)) * i;
      final y = size.height * points[i];
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);

    final linePaint = Paint()
      ..color = const Color(0xFF8B5CF6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final linePath = Path();
    for (var i = 0; i < points.length; i++) {
      final x = (size.width / (points.length - 1)) * i;
      final y = size.height * points[i];
      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }

    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width < 600 ? 20.0 : (size.width < 900 ? 40.0 : 60.0);

    return Container(
      padding: EdgeInsets.symmetric(vertical: padding, horizontal: padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.02), Colors.transparent],
        ),
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: size.width < 800
          ? Column(
              children: [
                _StatItem(
                  value: '3',
                  label: 'AI Agents',
                  icon: Icons.smart_toy_rounded,
                ),
                const SizedBox(height: 32),
                _StatItem(
                  value: '50M+',
                  label: 'Data Points',
                  icon: Icons.analytics_rounded,
                ),
                const SizedBox(height: 32),
                _StatItem(
                  value: '<100ms',
                  label: 'Response Time',
                  icon: Icons.speed_rounded,
                ),
                const SizedBox(height: 32),
                _StatItem(
                  value: '24/7',
                  label: 'Monitoring',
                  icon: Icons.update_rounded,
                ),
              ],
            )
          : Wrap(
              spacing: 40,
              runSpacing: 32,
              alignment: WrapAlignment.spaceAround,
              children: [
                _StatItem(
                  value: '3',
                  label: 'AI Agents',
                  icon: Icons.smart_toy_rounded,
                ),
                _StatItem(
                  value: '50M+',
                  label: 'Data Points',
                  icon: Icons.analytics_rounded,
                ),
                _StatItem(
                  value: '<100ms',
                  label: 'Response Time',
                  icon: Icons.speed_rounded,
                ),
                _StatItem(
                  value: '24/7',
                  label: 'Monitoring',
                  icon: Icons.update_rounded,
                ),
              ],
            ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF8B5CF6),
          size: size.width < 600 ? 24 : 32,
        ),
        const SizedBox(height: 16),
        Text(
          value,
          style: TextStyle(
            fontSize: size.width < 600 ? 32 : 48,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: size.width < 600 ? 14 : 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class ModernFeaturesSection extends StatelessWidget {
  const ModernFeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width < 600 ? 20.0 : (size.width < 900 ? 40.0 : 60.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        children: [
          Text(
            'Core Features',
            style: TextStyle(
              fontSize: size.width < 600 ? 32 : (size.width < 900 ? 42 : 56),
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Everything you need for intelligent market monitoring',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: size.width < 600 ? 14 : 20,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = size.width < 700
                  ? 1
                  : (size.width < 1100 ? 2 : 3);

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: size.width < 700 ? 1.3 : 1.1,
                children: [
                  _ModernFeatureCard(
                    icon: Icons.smart_toy_rounded,
                    title: 'AI Agents',
                    description:
                        'Autonomous agents monitoring markets 24/7 with real-time analysis.',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6B46C1)],
                    ),
                  ),
                  _ModernFeatureCard(
                    icon: Icons.notifications_active_rounded,
                    title: 'Smart Alerts',
                    description:
                        'Get instant notifications on critical risks and opportunities.',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                    ),
                  ),
                  _ModernFeatureCard(
                    icon: Icons.auto_graph_rounded,
                    title: 'Analytics',
                    description:
                        'Advanced AI-powered market analysis and predictive insights.',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                  ),
                  _ModernFeatureCard(
                    icon: Icons.newspaper_rounded,
                    title: 'News Analysis',
                    description:
                        'AI scans thousands of sources to extract market-moving news.',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                  ),
                  _ModernFeatureCard(
                    icon: Icons.psychology_rounded,
                    title: 'Sentiment',
                    description:
                        'Real-time market sentiment analysis from social and news.',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
                    ),
                  ),
                  _ModernFeatureCard(
                    icon: Icons.security_rounded,
                    title: 'Risk Monitor',
                    description:
                        'Continuous portfolio risk assessment with AI recommendations.',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ModernFeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Gradient gradient;

  const _ModernFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });

  @override
  State<_ModernFeatureCard> createState() => _ModernFeatureCardState();
}

class _ModernFeatureCardState extends State<_ModernFeatureCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()..translate(0.0, isHovered ? -8.0 : 0.0),
        padding: EdgeInsets.all(size.width < 600 ? 20 : 32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isHovered ? 0.05 : 0.03),
          borderRadius: BorderRadius.circular(size.width < 600 ? 20 : 28),
          border: Border.all(
            color: Colors.white.withOpacity(isHovered ? 0.15 : 0.08),
            width: 1,
          ),
          boxShadow: isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(size.width < 600 ? 12 : 16),
              decoration: BoxDecoration(
                gradient: widget.gradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradient.colors.first.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: Colors.white,
                size: size.width < 600 ? 24 : 32,
              ),
            ),
            SizedBox(height: size.width < 600 ? 16 : 24),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: size.width < 600 ? 18 : 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: size.width < 600 ? 8 : 12),
            Text(
              widget.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: size.width < 600 ? 13 : 15,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width < 600 ? 20.0 : (size.width < 900 ? 40.0 : 60.0);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        children: [
          Text(
            'How It Works',
            style: TextStyle(
              fontSize: size.width < 600 ? 32 : (size.width < 900 ? 42 : 56),
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Simple, automated, and intelligent',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: size.width < 600 ? 14 : 20,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          size.width < 900
              ? Column(
                  children: [
                    _ProcessStep(
                      number: '01',
                      title: 'Connect Your Data',
                      description:
                          'Link your portfolio and select markets to monitor. Our AI starts learning your preferences.',
                      icon: Icons.link_rounded,
                      color: const Color(0xFF8B5CF6),
                    ),
                    const SizedBox(height: 24),
                    _ProcessStep(
                      number: '02',
                      title: 'AI Analyzes 24/7',
                      description:
                          'Autonomous agents monitor news, sentiment, and market data in real-time with machine learning.',
                      icon: Icons.psychology_rounded,
                      color: const Color(0xFF3B82F6),
                    ),
                    const SizedBox(height: 24),
                    _ProcessStep(
                      number: '03',
                      title: 'Get Insights',
                      description:
                          'Receive intelligent alerts, risk assessments, and actionable recommendations instantly.',
                      icon: Icons.notifications_active_rounded,
                      color: const Color(0xFF10B981),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _ProcessStep(
                        number: '01',
                        title: 'Connect Your Data',
                        description:
                            'Link your portfolio and select markets to monitor. Our AI starts learning your preferences.',
                        icon: Icons.link_rounded,
                        color: const Color(0xFF8B5CF6),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _ProcessStep(
                        number: '02',
                        title: 'AI Analyzes 24/7',
                        description:
                            'Autonomous agents monitor news, sentiment, and market data in real-time with machine learning.',
                        icon: Icons.psychology_rounded,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _ProcessStep(
                        number: '03',
                        title: 'Get Insights',
                        description:
                            'Receive intelligent alerts, risk assessments, and actionable recommendations instantly.',
                        icon: Icons.notifications_active_rounded,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

class _ProcessStep extends StatefulWidget {
  final String number;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _ProcessStep({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  State<_ProcessStep> createState() => _ProcessStepState();
}

class _ProcessStepState extends State<_ProcessStep> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()..translate(0.0, isHovered ? -8.0 : 0.0),
        padding: EdgeInsets.all(size.width < 600 ? 24 : 40),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isHovered ? 0.05 : 0.03),
          borderRadius: BorderRadius.circular(size.width < 600 ? 20 : 32),
          border: Border.all(
            color: Colors.white.withOpacity(isHovered ? 0.15 : 0.08),
          ),
          boxShadow: isHovered
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(size.width < 600 ? 14 : 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [widget.color, widget.color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: size.width < 600 ? 24 : 32,
                  ),
                ),
                const Spacer(),
                Text(
                  widget.number,
                  style: TextStyle(
                    fontSize: size.width < 600 ? 32 : 48,
                    fontWeight: FontWeight.w900,
                    color: widget.color.withOpacity(0.2),
                    letterSpacing: -2,
                  ),
                ),
              ],
            ),
            SizedBox(height: size.width < 600 ? 20 : 32),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: size.width < 600 ? 20 : 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: size.width < 600 ? 12 : 16),
            Text(
              widget.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: size.width < 600 ? 14 : 16,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TechStackSection extends StatelessWidget {
  const TechStackSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width < 600 ? 20.0 : (size.width < 900 ? 40.0 : 60.0);

    return Container(
      padding: EdgeInsets.symmetric(vertical: padding, horizontal: padding),
      child: Column(
        children: [
          Text(
            'Built With Modern Tech',
            style: TextStyle(
              fontSize: size.width < 600 ? 28 : 42,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _TechBadge('Flutter', Icons.phone_android_rounded),
              _TechBadge('Gemini', Icons.smart_toy_rounded),
              _TechBadge('Python', Icons.code_rounded),
              _TechBadge('FastAPI', Icons.bolt_rounded),
              _TechBadge('PostgreSQL', Icons.storage_rounded),
              _TechBadge('WebSockets', Icons.wifi_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _TechBadge extends StatefulWidget {
  final String text;
  final IconData icon;

  const _TechBadge(this.text, this.icon);

  @override
  State<_TechBadge> createState() => _TechBadgeState();
}

class _TechBadgeState extends State<_TechBadge> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: size.width < 600 ? 20 : 32,
          vertical: size.width < 600 ? 14 : 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isHovered ? 0.05 : 0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(isHovered ? 0.2 : 0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              color: const Color(0xFF8B5CF6),
              size: size.width < 600 ? 20 : 24,
            ),
            const SizedBox(width: 10),
            Text(
              widget.text,
              style: TextStyle(
                fontSize: size.width < 600 ? 14 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CTASection extends StatelessWidget {
  const CTASection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width < 600 ? 20.0 : (size.width < 900 ? 40.0 : 60.0);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: padding),
      padding: EdgeInsets.all(size.width < 600 ? 40 : 80),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5CF6), Color(0xFF6B46C1)],
        ),
        borderRadius: BorderRadius.circular(size.width < 600 ? 24 : 40),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Ready to Experience AI-Powered Trading?',
            style: TextStyle(
              fontSize: size.width < 600 ? 24 : (size.width < 900 ? 32 : 48),
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.width < 600 ? 12 : 20),
          Text(
            'Try our live demo and see how AI agents monitor your markets in real-time',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: size.width < 600 ? 14 : 20,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.width < 600 ? 24 : 40),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6B46C1),
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width < 600 ? 24 : 40,
                      vertical: size.width < 600 ? 16 : 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        size: size.width < 600 ? 20 : 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Try Live Demo',
                        style: TextStyle(
                          fontSize: size.width < 600 ? 14 : 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width < 600 ? 24 : 40,
                    vertical: size.width < 600 ? 16 : 24,
                  ),
                  side: const BorderSide(color: Colors.white, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.login_rounded,
                      color: Colors.white,
                      size: size.width < 600 ? 20 : 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width < 600 ? 14 : 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
