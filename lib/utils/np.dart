import 'dart:collection';

import 'package:flutter/material.dart';

class NextPreviousWidget extends StatefulWidget {
  int current;
  int total;
  bool visable;
  HashMap<String, int> name2idx;
  void Function(int idx) setIdxCallback;
  void Function() previousCallback;
  void Function() nextCallback;
  NextPreviousWidget({
    super.key,
    required this.current,
    required this.total,
    required this.visable,
    required this.name2idx,

    required this.previousCallback,
    required this.nextCallback,
    required this.setIdxCallback,
  });

  @override
  State<NextPreviousWidget> createState() => _NextPreviousWidgetState();
}

class _NextPreviousWidgetState extends State<NextPreviousWidget> {
  TextEditingController _controller = TextEditingController();
  String _name = "";

  void _searchAndSetNameIdx() {
    String name = _controller.text;
    print("SearchName:${name}");
    var idx = widget.name2idx[name];
    // print("not found: name=[${name}]");
    if (idx != null) {
      print("found:Idx=${idx}");
      widget.setIdxCallback(idx);
    } else {
      print("NameNotFound: name=${name}. totNames:${widget.name2idx.length}");
      AlertDialog(
        title: Text("Name not Found"),
        content: Text("name=${name}. totNames:${widget.name2idx.length}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Ok"),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.visable,
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: widget.current > 0 ? widget.previousCallback : null,
              child: Text("Previous"),
            ),
            Text("${widget.current}/${widget.total}"),
            ElevatedButton(
              onPressed:
                  (widget.current + 1 < widget.total)
                      ? widget.nextCallback
                      : null,
              child: Text("Next"),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: SizedBox(
                width: 500,
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(hintText: "name"),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _searchAndSetNameIdx,
              child: Text("Search"),
            ),
          ],
        ),
      ),
    );
  }
}
