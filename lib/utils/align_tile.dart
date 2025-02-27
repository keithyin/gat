import 'package:flutter/material.dart';

const Map<int, Color> colorMap = {
  65: Colors.red,
  67: Colors.blue,
  71: Colors.yellow,
  84: Colors.green,
  45: Colors.grey,
};

// A 65 C 67 G 71 T 84
class AlignTile extends StatelessWidget {
  int queryCode;
  int targetCode;

  AlignTile({super.key, required this.queryCode, required this.targetCode});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          String.fromCharCode(queryCode),
          style: TextStyle(color: colorMap[queryCode]),
        ),
        Text(
          String.fromCharCode(targetCode),
          style: TextStyle(color: colorMap[targetCode]),
        ),
      ],
    );
  }
}
