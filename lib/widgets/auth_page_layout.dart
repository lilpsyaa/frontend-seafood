import 'package:flutter/material.dart';

import '../theme/seafood_theme.dart';

class AuthPageLayout extends StatelessWidget {
  const AuthPageLayout({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.form,
    required this.footer,
  });

  final String eyebrow;
  final String title;
  final String description;
  final Widget form;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 330,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF079B35), Color(0xFF25C64A)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 52,
                          right: -24,
                          child: Text(
                            'FRESH',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.08),
                              fontSize: 74,
                              height: 0.9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -4,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          bottom: 32,
                          child: Icon(
                            Icons.set_meal,
                            size: 174,
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.restaurant,
                                    color: Colors.white,
                                    size: 21,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'SEAFOOD PLANNER',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 13,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: const Text(
                                      'FRESH MENU',
                                      style: TextStyle(
                                        color: SeafoodColors.deepGreen,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                eyebrow.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  height: 0.98,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.4,
                                ),
                              ),
                              const SizedBox(height: 9),
                              SizedBox(
                                width: 240,
                                child: Text(
                                  description,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.94),
                                    fontSize: 13,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -18),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 23, 20, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: SeafoodColors.deepGreen.withValues(
                              alpha: 0.1,
                            ),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [form, const SizedBox(height: 8), footer],
                      ),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Temukan menu seafood favorit dan rencanakan harimu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: SeafoodColors.muted.withValues(alpha: 0.95),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
