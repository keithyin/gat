import 'dart:convert';
import 'dart:io';
import 'package:gat/utils/np.dart';
import 'package:gat/utils/single_msa.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:collection';

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
  final HashMap<String, int> _name2idx = HashMap();

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
      for (int i = 0; i < msaResults.length; i++) {
        _name2idx[msaResults[i].names[1]] = i;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SelectableText(
          "cargo install asts",
          style: GoogleFonts.sourceCodePro(),
        ),
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

        Expanded(
          child: MsaResultsWidget(msaResults: _msaResults, name2idx: _name2idx),
        ),
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
  final List<int> positions;

  MsaResult({
    required this.identity,
    required this.mm,
    required this.ins,
    required this.del,
    required this.msaSeqs,
    required this.names,
    required this.positions,
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
      positions: List<int>.from(json['positions']),
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
      'positions': positions,
    };
  }

  List<MsaResult> partition() {
    if (positions.isEmpty) {
      return [];
    }
    List<MsaResult> results = [];
    MsaResult msaResult = MsaResult(
      identity: identity,
      mm: mm,
      ins: ins,
      del: del,
      msaSeqs: List.empty(growable: true),
      names: names,
      positions: List.empty(growable: true),
    );
    String firstSeq = msaSeqs[0];
    int start = 0;
    int i = 0;
    for (i = 0; i < positions.length; i++) {
      if (firstSeq[i] == "#") {
        for (final seq in msaSeqs) {
          msaResult.msaSeqs.add(seq.substring(start, i));
        }
        msaResult.positions.addAll(positions.sublist(start, i));

        results.add(msaResult);
        msaResult = MsaResult(
          identity: identity,
          mm: mm,
          ins: ins,
          del: del,
          msaSeqs: List.empty(growable: true),
          names: names,
          positions: List.empty(growable: true),
        );

        start = i + 1;
      }
    }
    for (final seq in msaSeqs) {
      msaResult.msaSeqs.add(seq.substring(start, i));
    }
    msaResult.positions.addAll(positions.sublist(start, i));

    results.add(msaResult);

    return results;
  }
}

class MsaResultsWidget extends StatefulWidget {
  List<MsaResult> msaResults = [];
  HashMap<String, int> name2idx;
  MsaResultsWidget({
    super.key,
    required this.msaResults,
    required this.name2idx,
  });

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

  void setIdxCallback(int idx) {
    setState(() {
      _current = idx;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NextPreviousWidget(
          current: _current,
          total: widget.msaResults.length,
          visable: widget.msaResults.isNotEmpty,
          name2idx: widget.name2idx,
          previousCallback: previousCallback,
          nextCallback: nextCallback,
          setIdxCallback: setIdxCallback,
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
