import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'labels.dart';
import 'sparkle_icon.dart';

/// A titled white group of rows, separated by full-width hairlines.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children, this.title});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) rows.add(const Divider());
      rows.add(children[i]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(GenieSpace.xs + 2, 0, GenieSpace.xs, GenieSpace.sm - 2),
            child: Eyebrow(title!),
          ),
        DecoratedBox(
          decoration: const BoxDecoration(
            color: GenieColors.card,
            borderRadius: GenieRadii.groupAll,
            boxShadow: GenieShadows.card,
          ),
          child: ClipRRect(
            borderRadius: GenieRadii.groupAll,
            child: Column(mainAxisSize: MainAxisSize.min, children: rows),
          ),
        ),
      ],
    );
  }
}

enum SettingsTone { neutral, accent, danger }

/// One row: icon well, title (and optional subtitle), trailing control.
///
/// If [onTap] is set the whole row is the target and it darkens slightly on
/// press. Rows don't scale: a scaling row inside a card reads as a glitch.
/// For a toggle row, pass the toggle as [trailing] with no `onChanged`,
/// and toggle from [onTap] so the full row is the hit area.
class SettingsRow extends StatefulWidget {
  const SettingsRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.trailing,
    this.onTap,
    this.tone = SettingsTone.neutral,
    this.toggled,
    this.chevron = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;

  /// Custom glyph for the icon well (e.g. the AI sparkle).
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final SettingsTone tone;

  /// Set for toggle rows so screen readers announce on/off.
  final bool? toggled;
  final bool chevron;

  @override
  State<SettingsRow> createState() => _SettingsRowState();
}

class _SettingsRowState extends State<SettingsRow> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final (wellBg, wellFg, titleColor) = switch (widget.tone) {
      SettingsTone.neutral => (GenieColors.tileBg, GenieColors.ink, GenieColors.ink),
      SettingsTone.accent => (GenieColors.tealSoft, GenieColors.teal, GenieColors.ink),
      SettingsTone.danger => (GenieColors.dangerSoft, GenieColors.danger, GenieColors.danger),
    };

    final glyph = widget.leading ?? (widget.icon != null ? Icon(widget.icon, size: 19, color: wellFg) : null);

    final row = AnimatedContainer(
      duration: GenieMotion.fast,
      curve: GenieMotion.easeOut,
      color: _pressed ? GenieColors.bg : GenieColors.card,
      constraints: const BoxConstraints(minHeight: 54),
      padding: const EdgeInsets.symmetric(horizontal: GenieSpace.md, vertical: 7),
      child: Row(
        children: [
          if (glyph != null) ...[
            Container(
              width: GenieSizes.iconWell,
              height: GenieSizes.iconWell,
              decoration: BoxDecoration(color: wellBg, borderRadius: GenieRadii.iconWellAll),
              child: Center(child: glyph),
            ),
            const SizedBox(width: GenieSpace.md - 2),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.title, style: text.titleMedium!.copyWith(color: titleColor, height: 1.25)),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(widget.subtitle!, style: text.bodyMedium!.copyWith(fontSize: 13, height: 1.3)),
                ],
              ],
            ),
          ),
          if (widget.trailing != null) ...[const SizedBox(width: GenieSpace.sm), widget.trailing!],
          if (widget.chevron) ...[
            const SizedBox(width: GenieSpace.xs),
            const Icon(GenieIcons.chevron, size: 20, color: GenieColors.ink3),
          ],
        ],
      ),
    );

    // A row with its own interactive trailing control (e.g. units) keeps that
    // control's semantics separate.
    if (widget.onTap == null) return row;

    return Semantics(
      button: widget.toggled == null,
      toggled: widget.toggled,
      child: MergeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: widget.onTap,
          child: row,
        ),
      ),
    );
  }
}

/// The AI sparkle sized for a settings icon well.
class SparkleWellGlyph extends StatelessWidget {
  const SparkleWellGlyph({super.key});

  @override
  Widget build(BuildContext context) => const SparkleIcon(size: 17);
}
