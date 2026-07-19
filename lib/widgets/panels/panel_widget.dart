import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PanelWidget extends StatelessWidget {
  final String? title;
  final Widget child;
  final Widget? trailing;

  const PanelWidget({
    Key? key,
    this.title,
    required this.child,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.panelBg,
        border: Border.all(color: AppTheme.mapStroke),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title!,
                  style: const TextStyle(
                    fontFamily: 'Fraunces',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}
