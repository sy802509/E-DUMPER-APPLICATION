import 'package:flutter/material.dart';

import '../theme/colors.dart';

class AppPanel extends StatelessWidget {
  final Widget child;
  final bool showGrid;
  final Widget? bottomNavigationBar;

  const AppPanel({
    super.key,
    required this.child,
    this.showGrid = false,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > 1080
                ? 1080.0
                : constraints.maxWidth;

            return Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  constraints.maxWidth < 600 ? 28 : 80,
                ),
                child: Container(
                  width: width,
                  height: constraints.maxHeight,
                  decoration: BoxDecoration(
                    color: AppColors.panelBackground,
                    border: Border.all(color: AppColors.panelBorder),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.accentShadow,
                        blurRadius: 50,
                        spreadRadius: -30,
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
