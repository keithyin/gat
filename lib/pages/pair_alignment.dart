import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gat/utils/single_alignment.dart';

List<List<String>> convertDynamicToList(dynamic input) {
  if (input is! List) throw Exception("非列表类型");

  return input.map((outerItem) {
    if (outerItem is! List) throw Exception("外层元素非列表");

    return outerItem.map((innerItem) {
      if (innerItem is String) return innerItem;
      throw Exception("内部元素非字符串");
    }).toList();
  }).toList();
}

class PairAlignment extends StatefulWidget {
  PairAlignment({super.key});

  @override
  State<PairAlignment> createState() => _PairAlignmentState();
}

class _PairAlignmentState extends State<PairAlignment> {
  final _queryController = TextEditingController();

  final _targetController = TextEditingController();

  List<List<String>> _alignRes = [];

  void doAlign() async {
    // 设置请求头
    Map<String, String> headers = {'Content-Type': 'application/json'};

    final query = _queryController.text;
    final target = _targetController.text;
    Map<String, String> params = {'query': query, 'target': target};

    final url = Uri.http('127.0.0.1:40724', 'pair_align');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(params),
    );

    Map<String, dynamic> res = jsonDecode(response.body);
    final align_res = convertDynamicToList(res['result']);
    setState(() {
      _alignRes = align_res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              top: 10.0,
            ),
            child: TextField(
              controller: _targetController,
              decoration: InputDecoration(hintText: 'target'),
            ),
          ),
        ),
        SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              top: 10.0,
            ),
            child: TextField(
              controller: _queryController,
              decoration: InputDecoration(hintText: 'query'),
            ),
          ),
        ),

        Center(
          child: ElevatedButton(
            onPressed: () => doAlign(),
            child: Text("Align"),
          ),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: _alignRes.length,
            itemBuilder:
                (context, index) => SingleAlignment(
                  alignedTarget: _alignRes[index][0],
                  alignedQuery: _alignRes[index][1],
                  targetTag: _alignRes[index][2],
                  queryTag: _alignRes[index][3],
                ),
          ),
        ),
      ],
    );
  }
}
