import 'package:flutter/material.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;

  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingPage {
  final String imagePath;
  final String title;

  const _OnboardingPage({required this.imagePath, required this.title});
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      imagePath: 'assets/images/AR4.jpeg',
      title: 'SEE IT.\nBEFORE YOU\nBUY IT.',
    ),
    _OnboardingPage(
      imagePath: 'assets/images/AR4.jpeg',
      title: 'MEASURE.\nPERFECT FIT.',
    ),
    _OnboardingPage(
      imagePath: 'assets/images/AR4.jpeg',
      title: 'DESIGN.\nYOUR SPACE.\nYOUR WAY.',
    ),
  ];

  bool get _isLastPage => _currentPage == _pages.length - 1;

  void _onNext() {
    if (_isLastPage) {
      widget.onDone();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _onSkip() => widget.onDone();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-bleed swipeable pages, each with its own image + gradient.
          PageView.builder(
           
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) => _OnboardingPageView(page: _pages[index]),
          ),

          // Skip — top right, hidden on the last page.
          if (!_isLastPage)
            Positioned(
              bottom: 8.h,
              right: 5.w,
              child: SafeArea(
                child: Container(
                  padding: EdgeInsets.all(2.h),
                  decoration: BoxDecoration(
                   shape: BoxShape.circle,color: Colors.white
                  ),
                  child: TextButton(
                    onPressed: _onNext,
                    child:  Text(
                      'Skip',
                      style: TextStyle(color: Colors.black, fontSize: 16.sp),
                    ),
                  ),
                ),
              ),
            ),

          // Dots + button — pinned to the bottom, sits inside the
          // black-faded zone of the gradient so it's always legible.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLastPage) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'GET STARTED',
                            style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildDots(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 8 : 6,
          height: isActive ? 8 : 6,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white30,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;

  const _OnboardingPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Layer 1 — full-bleed photo, untouched, always fills the screen.

        
        Image.asset(page.imagePath, fit: BoxFit.cover),

        // Layer 2 — gradient overlay: opaque black at top/bottom,
        // transparent in the middle, so text sits on solid black
        // while the image still reads clearly in the center band.
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                Colors.transparent,
                Colors.transparent,
                Colors.black,
              ],
              stops: [0.25, 0.51, 0.6, 1.0],
            ),
          ),
        ),

        // Headline — sits in the top black zone.
        SafeArea(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 2.h, vertical: 4.h),
            child: Text(
              page.title,
              style:  TextStyle(
                color: Colors.white,
                fontSize: 50.sp,
                fontWeight: FontWeight.w900,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}