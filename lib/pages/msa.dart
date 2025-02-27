import 'package:flutter/material.dart';
import 'package:toolkits_of_roc_yin/utils/file_selector.dart';

class MSA extends StatefulWidget {
  MSA({super.key});

  @override
  State<MSA> createState() => _MSAState();
}

class _MSAState extends State<MSA> {
  final SelectedFilename _refFile = SelectedFilename(filename: "");
  final SelectedFilename _sbrBam = SelectedFilename(filename: "");
  final SelectedFilename _csBam = SelectedFilename(filename: "");

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FSWideget(tag: "ReferenceFile:", selectedFilename: _refFile),
        FSWideget(tag: "SubreadsBam  :", selectedFilename: _sbrBam),
        FSWideget(tag: "CsBam        :", selectedFilename: _csBam),

        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ElevatedButton(
            onPressed: () {
              print("ref:" + this._refFile.filename);
              print("sbr:" + this._sbrBam.filename);
              print("cs:" + this._csBam.filename);

            },
            child: Text("Analyse"),
          ),
        ),
      ],
    );
  }
}
