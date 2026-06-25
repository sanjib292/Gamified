import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Splash screen shown on app launch.
///
/// Enforces a 2-second minimum display while determining where to route the
/// user:
///   - No session        → /auth
///   - Session, not onboarded → /onboarding
///   - Session, onboarded    → /home
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _logoController;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _navigate();
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    // Enforce 2-second minimum display.
    final minimumDisplay = Future<void>.delayed(const Duration(seconds: 2));

    // Determine routing intent.
    final routeTarget = await _resolveRoute();

    // Wait for whichever finishes last.
    await minimumDisplay;

    if (!mounted) return;
    context.go(routeTarget);
  }

  Future<String> _resolveRoute() async {
    final authClient = ref.read(authClientProvider);
    final session = authClient.currentSession;

    if (session == null) {
      return RouteNames.auth;
    }

    // Session exists — check if the user has completed onboarding.
    try {
      final supabase = ref.read(supabaseClientProvider);
      final userId = session.user.id;
      final row = await supabase
          .from('profiles')
          .select('is_onboarded')
          .eq('id', userId)
          .maybeSingle();

      final isOnboarded = (row?['is_onboarded'] as bool?) ?? false;
      return isOnboarded ? RouteNames.home : RouteNames.onboarding;
    } catch (_) {
      // If the DB call fails, fall back to home — the user is authenticated.
      return RouteNames.home;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: _SplashBody(logoController: _logoController),
    );
  }
}

class _SplashBody extends StatelessWidget {
  const _SplashBody({required this.logoController});

  final AnimationController logoController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background radial glow
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.85,
                colors: [
                  AppColors.primary.withOpacity(0.18),
                  AppColors.darkBackground,
                ],
              ),
            ),
          ),
        ),

        // Centre content
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo mark — Lottie placeholder using animated container
              _LogoMark(controller: logoController),

              const SizedBox(height: 24),

              // App name
              Text(
                'MindQuest',
                style: AppTextStyles.displaySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              )
                  .animate(controller: logoController)
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 500.ms),

              const SizedBox(height: 8),

              Text(
                'Learn. Level up. Repeat.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.darkTextSecondary,
                  letterSpacing: 0.6,
                ),
              )
                  .animate(controller: logoController)
                  .fadeIn(delay: 700.ms, duration: 600.ms),
            ],
          ),
        ),

        // Bottom loading indicator
        Positioned(
          bottom: 56,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary.withOpacity(0.7),
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 1200.ms, duration: 400.ms),
          ),
        ),
      ],
    );
  }
}

/// Animated logo mark — replace inner SizedBox with Lottie.asset() when the
/// animation file is available at assets/animations/logo_pulse.json.
class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.45),
              blurRadius: 32,
              spreadRadius: 4,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '🧠',
            style: TextStyle(fontSize: 44),
          ),
        ),
      ),
    )
        .animate(controller: controller)
        .scaleXY(
          begin: 0.6,
          end: 1.0,
          duration: 700.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 400.ms);
  }
}
