import 'dart:convert';
import 'dart:io';
import 'package:gat/utils/np.dart';
import 'package:gat/utils/single_msa.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:gat/utils/file_selector.dart';

class MSA extends StatefulWidget {
  MSA({super.key});

  @override
  State<MSA> createState() => _MSAState();
}

class _MSAState extends State<MSA> {
  final SelectedFilename _asrtcFile = SelectedFilename(filename: "");

  List<MsaResult> _msaResults = [];

  void _doAnalysis() async {
    final asrtcFile = _asrtcFile.filename;
    File file = File(asrtcFile);

    List<String> lines = await file.readAsLines();
    List<MsaResult> msaResults =
        lines
            .map((line) => MsaResult.fromJson(jsonDecode(line.trim())))
            .toList();

    setState(() {
      _msaResults = msaResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SelectableText("cargo install asts", style: GoogleFonts.sourceCodePro()),
        SelectableText(
          "asrtc --ref-fa reffa_file -q sbr.bam -t smc.bam -p oup_prefix --np-range 7:7",
          style: GoogleFonts.sourceCodePro(),
        ),

        FSWideget(tag: "AsrtcFile:", selectedFilename: _asrtcFile),

        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ElevatedButton(
            onPressed: () => _doAnalysis(),
            child: Text("Analyse"),
          ),
        ),

        Expanded(child: MsaResultsWidget(msaResults: _msaResults)),
      ],
    );
  }
}

class MsaResult {
  final double identity;
  final int mm;
  final int ins;
  final int del;
  final List<String> msaSeqs;
  final List<String> names;

  MsaResult({
    required this.identity,
    required this.mm,
    required this.ins,
    required this.del,
    required this.msaSeqs,
    required this.names,
  });

  // JSON 解析
  factory MsaResult.fromJson(Map<String, dynamic> json) {
    return MsaResult(
      identity: (json['identity'] as num).toDouble(),
      mm: json['mm'] as int,
      ins: json['ins'] as int,
      del: json['del'] as int,
      msaSeqs: List<String>.from(json['msa_seqs']),
      names: List<String>.from(json['names']),
    );
  }

  // 转换回 JSON
  Map<String, dynamic> toJson() {
    return {
      'identity': identity,
      'mm': mm,
      'ins': ins,
      'del': del,
      'msa_seqs': msaSeqs,
      'names': names,
    };
  }
}

class MsaResultsWidget extends StatefulWidget {
  List<MsaResult> msaResults = [];
  MsaResultsWidget({super.key, required this.msaResults});

  @override
  State<MsaResultsWidget> createState() => _MsaResultsWidgetState();
}

class _MsaResultsWidgetState extends State<MsaResultsWidget> {
  int _current = 0;
  void previousCallback() {
    if (_current > 0) {
      setState(() {
        _current--;
      });
    }
  }

  void nextCallback() {
    if ((_current + 1) < widget.msaResults.length) {
      setState(() {
        _current++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NextPreviousWidget(
          current: _current,
          total: widget.msaResults.length,
          visable: widget.msaResults.isNotEmpty,
          previousCallback: previousCallback,
          nextCallback: nextCallback,
        ),
        Expanded(
          child:
              widget.msaResults.length > _current
                  ? SingleMsa(msaResult: widget.msaResults[_current])
                  : Container(),
        ),
      ],
    );
  }
}
