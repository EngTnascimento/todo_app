import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  final Widget? leading;
  final TextStyle? titleStyle;
  final Gradient? backgroundGradient;
  final double elevation;
  final EdgeInsets actionPadding;
  final EdgeInsets leadingPadding;

  const MyAppBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.leading,
    this.titleStyle = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
    this.backgroundGradient,
    this.elevation = 6.0,
    this.actionPadding = const EdgeInsets.all(8.0),
    this.leadingPadding = const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundGradient == null
          ? Colors.blueAccent
          : null, // Fallback to solid color
      flexibleSpace: backgroundGradient != null
          ? Container(
              decoration: BoxDecoration(
                gradient: backgroundGradient,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
            )
          : null,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(
        title,
        style: titleStyle ??
            const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: Colors.white,
            ),
      ),
      leading: leading != null
          ? Padding(
              padding: leadingPadding,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {},
                  child: leading,
                ),
              ),
            )
          : null,
      actions: actions
          .map((action) => Padding(
                padding: actionPadding,
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {},
                    child: action,
                  ),
                ),
              ))
          .toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
