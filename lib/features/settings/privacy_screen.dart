import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';

/// Plain-language privacy notes. Placeholder until the full policy exists;
/// it only states what is true of this build.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final mq = MediaQuery.of(context);

    Widget section(String title, String body) => Padding(
      padding: const EdgeInsets.only(bottom: GenieSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(header: true, child: Text(title, style: text.titleLarge)),
          const SizedBox(height: GenieSpace.xs),
          Text(body, style: text.bodyLarge),
        ],
      ),
    );

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          GenieSpace.gutter,
          mq.padding.top + GenieSpace.xs,
          GenieSpace.gutter,
          mq.padding.bottom + GenieSpace.xl,
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: const Offset(-4, 0),
              child: IconCircleButton(
                icon: GenieIcons.back,
                semanticLabel: 'Back',
                size: 46,
                onPressed: () => context.pop(),
              ),
            ),
          ),
          const SizedBox(height: GenieSpace.xl),
          Semantics(header: true, child: Text('Privacy', style: text.displayMedium)),
          const SizedBox(height: GenieSpace.xl),
          section('No account', 'Genie works without an account or sign-up.'),
          section(
            'Your camera',
            'Genie uses the camera to see the room you are designing: your floor, walls and light.',
          ),
          section(
            'Saved on this phone',
            'Settings and saved designs are kept on this phone. Clear saved designs removes them.',
          ),
          section('Full policy', 'The complete privacy policy will be published here before Genie is released.'),
          section(
            'Credits',
            'Placeholder 3D models from the Khronos glTF Sample Assets: "SheenChair" (CC0) and "GlamVelvetSofa" '
                'by Eric Chadwick for Wayfair (CC BY 4.0).',
          ),
        ],
      ),
    );
  }
}
