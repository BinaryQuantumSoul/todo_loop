import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      height: 200,
      child: Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
            color: color ?? theme.colorScheme.primary, size: 50),
      ),
    );
  }
}
