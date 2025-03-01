import 'package:flutter/material.dart';

class NextPreviousWidget extends StatelessWidget {
  int current;
  int total;
  bool visable;
  void Function()? previousCallback;
  void Function()? nextCallback;
  NextPreviousWidget({
    super.key,
    required this.current,
    required this.total,
    required this.visable,
    required this.previousCallback,
    required this.nextCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visable,
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: current > 0 ? previousCallback : null,
              child: Text("Previous"),
            ),
            Text("$current/$total"),
            ElevatedButton(
              onPressed: (current + 1 < total) ? nextCallback : null,
              child: Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
