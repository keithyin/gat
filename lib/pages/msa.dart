
import 'package:flutter/material.dart';

class MSA extends StatelessWidget {
  MSA({super.key});

  final _queryController = TextEditingController();
  final _targetController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Column(
      
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("query:"),
            Expanded(child: TextField(controller: _queryController, decoration: InputDecoration(hintText: 'query'),)),
          ],
          
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("target:"),
            Expanded(child: TextField(controller: _targetController, decoration: InputDecoration(hintText: 'target'),)),
          ],
        ),
      ],
    );
  }
}