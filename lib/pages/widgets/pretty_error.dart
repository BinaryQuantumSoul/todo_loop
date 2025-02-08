import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PrettyError extends StatefulWidget {
  final Object error;
  final StackTrace stackTrace;

  const PrettyError(this.error, this.stackTrace, {super.key});

  @override
  State<PrettyError> createState() => _PrettyErrorState();
}

class _PrettyErrorState extends State<PrettyError> {
  bool _open = false;

  @override
  void initState() {
    super.initState();

    if (kDebugMode) {
      print(widget.error);
      print(widget.stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return GestureDetector(
      onTap: () => setState(() {
        _open = !_open;
      }),
      child: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 35,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: _open
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10))
                    : BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 18, color: theme.colorScheme.onPrimary),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      widget.error.toString(),
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 15,
                          overflow: TextOverflow.ellipsis,
                          color: theme.colorScheme.onPrimary),
                    ),
                  ),
                ],
              ),
            ),
            if (_open)
              Container(
                height: 100,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  border:
                      Border.all(color: theme.colorScheme.primary, width: 2),
                ),
                child: SingleChildScrollView(
                  child: Text(widget.stackTrace.toString(),
                      style: TextStyle(
                          fontSize: 12, color: theme.colorScheme.onSecondary)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
