import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorMessage extends StatelessWidget {
  final String message;
  final bool? onPrimary;

  const ErrorMessage(this.message, {super.key, this.onPrimary});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          '$message >_<',
          style: GoogleFonts.silkscreen(
            fontSize: 18,
            color: (onPrimary ?? false)
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
