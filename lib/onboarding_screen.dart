import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/routes/routes.dart';
import 'package:myapp/theme/app_pallete.dart';

class OnboardingScreen extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const OnboardingScreen(),
      );

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Commencez à aider',
      'description':
          'Il est plus facile que jamais d’aider les nécessiteux avec Mazal Kayn Elkhir, votre application de confiance.',
      'image': 'assets/images/images2/onboarding1.png',
    },
    {
      'title': 'Répandez l’amour plus facilement',
      'description':
          'Si vous ne savez pas comment aider, vous pouvez le faire en donnant via Mazal Kayn Elkhir.',
      'image': 'assets/images/images2/onboarding2.png',
    },
    {
      'title': 'Aidez les autres',
      'description':
          'Vous pouvez également aider les autres en leur offrant des vêtements, de la nourriture ou d’autres choses dont ils ont besoin.',
      'image': 'assets/images/images2/onboarding3.png',
    },
    {
      'title': 'Faites un don',
      'description':
          'Vous pouvez également faire un don à une organisation caritative de votre choix.',
      'image': 'assets/images/images2/onboarding4.png',
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    Navigator.pushReplacementNamed(context, RouteGenerator.authGate);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightAppPallete.primaryDark,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        _onboardingData[index]['image']!,
                        height: 200,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.favorite,
                          size: 200,
                          color: LightAppPallete.background,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        _onboardingData[index]['title']!,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: LightAppPallete.background,
                              fontSize: 28,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _onboardingData[index]['description']!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: LightAppPallete.backgroundAlt,
                              fontSize: 16,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'Skip',
                        style: Theme.of(context).textButtonTheme.style?.textStyle?.resolve({})?.copyWith(
                              color: LightAppPallete.background,
                            ),
                      ),
                    ),
                    Row(
                      children: List.generate(
                        _onboardingData.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          width: _currentPage == index ? 12.0 : 8.0,
                          height: 8.0,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? LightAppPallete.background
                                : LightAppPallete.backgroundAlt,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _onboardingData.length - 1) {
                          _completeOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        _currentPage == _onboardingData.length - 1 ? 'Démarrer' : 'Suivant',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}