import 'package:flutter/material.dart';

/// Wrapper that constrains the app to mobile viewport size (max 415px)
/// Perfect for developing mobile apps in desktop browser
class MobileViewportWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final bool showFrame;

  const MobileViewportWrapper({
    super.key,
    required this.child,
    this.maxWidth = 415.0,
    this.showFrame = true,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey.shade900,
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          decoration: showFrame
              ? BoxDecoration(
                  border: Border.all(
                    color: Colors.white24,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                )
              : null,
          child: ClipRect(
            child: child,
          ),
        ),
      ),
    );
  }
}

