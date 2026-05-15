import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:btk_byte_benders/screens/login_screen.dart';
import 'package:btk_byte_benders/screens/signup_screen.dart';

void main() {
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
          // Animated background
          AnimatedGradientBackground(controller: _backgroundController),
          // Floating particles
          FloatingParticles(controller: _floatController),
          // Content
          SingleChildScrollView(
            child: Column(
              children: [
                ModernNavbar(),
                ModernHeroSection(pulseController: _pulseController),
                const SizedBox(height: 120),
                const StatsSection(),
                const SizedBox(height: 120),
                const ModernFeaturesSection(),
                const SizedBox(height: 120),
                const HowItWorksSection(),
                const SizedBox(height: 120),
                const TechStackSection(),
                const SizedBox(height: 120),
                const CTASection(),
                const SizedBox(height: 80),
                const ModernFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Floating Particles Effect
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

// Animated Gradient Background
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

// Modern Navbar with Glassmorphism
class ModernNavbar extends StatefulWidget {
  const ModernNavbar({super.key});

  @override
  State<ModernNavbar> createState() => _ModernNavbarState();
}

class _ModernNavbarState extends State<ModernNavbar> {
  String? hoveredItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo
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
            'Aizanoi ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
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
          ),
          const SizedBox(width: 24),
          // Login Button
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Log In',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Get Started Button
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6B46C1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
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
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
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
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isHovered
              ? Colors.white.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isHovered ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isHovered ? Colors.white : Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modern Hero Section
class ModernHeroSection extends StatelessWidget {
  final AnimationController pulseController;

  const ModernHeroSection({super.key, required this.pulseController});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1200;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 100 : 40,
        vertical: 80,
      ),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _buildHeroContent(context)),
                const SizedBox(width: 80),
                Expanded(child: _buildHeroDashboard()),
              ],
            )
          : Column(
              children: [
                _buildHeroContent(context),
                const SizedBox(height: 60),
                _buildHeroDashboard(),
              ],
            ),
    );
  }

  Widget _buildHeroContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
              const Text(
                '🚀 Hackathon 2026 Project',
                style: TextStyle(
                  color: Color(0xFFB794F6),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        // Main Headline
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFFB794F6)],
          ).createShader(bounds),
          child: const Text(
            'AI-Powered\nFinancial Intelligence',
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: -2,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 28),
        // Subtitle
        const Text(
          'Real-time market analysis, risk detection, and automated\ninvestment insights powered by advanced AI agents.',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 20,
            height: 1.7,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 48),
        // CTA Buttons
        Row(
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
            const SizedBox(width: 20),
            _OutlineButton(
              text: 'View GitHub',
              onPressed: () {},
              icon: Icons.code_rounded,
            ),
          ],
        ),
        const SizedBox(height: 40),
        // Trust Indicators
        Row(
          children: [
            _TrustBadge(icon: Icons.bolt_rounded, text: 'Real-time Processing'),
            const SizedBox(width: 32),
            _TrustBadge(icon: Icons.security_rounded, text: 'Secure & Private'),
            const SizedBox(width: 32),
            _TrustBadge(icon: Icons.auto_awesome, text: 'AI-Powered'),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroDashboard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
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
          // Dashboard Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6B46C1)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.dashboard_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Live AI Dashboard',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: pulseController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
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
                        const Text(
                          '3 Agents Active',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 13,
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
          const SizedBox(height: 32),
          // Alert Cards
          _DashboardAlertCard(
            title: 'Market Risk Alert',
            description: 'Unusual volatility detected in semiconductor sector.',
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
            description: 'AI recommends defensive positioning for next 48h.',
            icon: Icons.auto_awesome,
            color: const Color(0xFF8B5CF6),
            value: '94% conf.',
          ),
          const SizedBox(height: 24),
          // Chart Placeholder
          Container(
            height: 180,
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
          borderRadius: BorderRadius.circular(16),
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
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 20),
              const SizedBox(width: 10),
              Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 16,
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
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isHovered
              ? Colors.white.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
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
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 20, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 16,
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
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF8B5CF6)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// Mini Chart Painter
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

    // Draw line
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

// Stats Section
class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 100),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.02), Colors.transparent],
        ),
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF8B5CF6), size: 32),
        const SizedBox(height: 16),
        Text(
          value,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Modern Features Section
class ModernFeaturesSection extends StatelessWidget {
  const ModernFeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100),
      child: Column(
        children: [
          const Text(
            'Core Features',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Everything you need for intelligent market monitoring',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 80),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: 1.1,
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
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()..translate(0.0, isHovered ? -8.0 : 0.0),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isHovered ? 0.05 : 0.03),
          borderRadius: BorderRadius.circular(28),
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
          children: [
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Icon(widget.icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 24),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              widget.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// How It Works Section
class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 100),
      child: Column(
        children: [
          const Text(
            'How It Works',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Simple, automated, and intelligent',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 80),
          Row(
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
              const SizedBox(width: 40),
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
              const SizedBox(width: 40),
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
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()..translate(0.0, isHovered ? -8.0 : 0.0),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isHovered ? 0.05 : 0.03),
          borderRadius: BorderRadius.circular(32),
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
                  padding: const EdgeInsets.all(20),
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
                  child: Icon(widget.icon, color: Colors.white, size: 32),
                ),
                const Spacer(),
                Text(
                  widget.number,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: widget.color.withOpacity(0.2),
                    letterSpacing: -2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Text(
              widget.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 16,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tech Stack Section
class TechStackSection extends StatelessWidget {
  const TechStackSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 100),
      child: Column(
        children: [
          const Text(
            'Built With Modern Tech',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 60),
          Wrap(
            spacing: 24,
            runSpacing: 24,
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
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
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
            Icon(widget.icon, color: const Color(0xFF8B5CF6), size: 24),
            const SizedBox(width: 12),
            Text(
              widget.text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// CTA Section
class CTASection extends StatelessWidget {
  const CTASection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 100),
      padding: const EdgeInsets.all(80),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5CF6), Color(0xFF6B46C1)],
        ),
        borderRadius: BorderRadius.circular(40),
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
          const Text(
            'Ready to Experience AI-Powered Trading?',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Try our live demo and see how AI agents monitor your markets in real-time',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.play_arrow_rounded, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Try Live Demo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 24,
                  ),
                  side: const BorderSide(color: Colors.white, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.login_rounded, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
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

// Modern Footer
class ModernFooter extends StatelessWidget {
  const ModernFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 60),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF6B46C1)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.auto_graph_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Aizanoi ',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'AI-powered financial intelligence\nfor smarter investment decisions.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF8B5CF6).withOpacity(0.3),
                        ),
                      ),
                      child: const Text(
                        '🏆 Hackathon 2026 Project',
                        style: TextStyle(
                          color: Color(0xFFB794F6),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _FooterColumn(
                  title: 'Product',
                  links: ['Features', 'Demo', 'Docs', 'API'],
                ),
              ),
              Expanded(
                child: _FooterColumn(
                  title: 'Resources',
                  links: ['GitHub', 'Documentation', 'Support', 'Status'],
                ),
              ),
              Expanded(
                child: _FooterColumn(
                  title: 'Team',
                  links: ['About', 'Contact', 'Hackathon', 'Credits'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2026 Aizanoi  • Built for Hackathon',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
              Row(
                children: [
                  _SocialIcon(Icons.code_rounded, 'GitHub'),
                  _SocialIcon(Icons.article_rounded, 'Docs'),
                  _SocialIcon(Icons.email_rounded, 'Contact'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> links;

  const _FooterColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 20),
        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                link,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialIcon extends StatefulWidget {
  final IconData icon;
  final String label;

  const _SocialIcon(this.icon, this.label);

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(left: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isHovered ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(isHovered ? 0.2 : 0.1),
          ),
        ),
        child: Icon(
          widget.icon,
          size: 20,
          color: Colors.white.withOpacity(isHovered ? 0.9 : 0.6),
        ),
      ),
    );
  }
}
