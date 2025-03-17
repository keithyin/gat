import 'package:flutter/material.dart';
import 'package:gat/pages/msa.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gat/utils/align_tile.dart';

int numRowElements = 180;

class SingleMsa extends StatelessWidget {
  MsaResult msaResult;
  SingleMsa({super.key, required this.msaResult});

  @override
  Widget build(BuildContext context) {
    String positionStr = "";
    if (msaResult.msaSeqs.isNotEmpty && msaResult.positions.isNotEmpty) {
      final firstSeq = msaResult.msaSeqs[0];
      
      int end = 0;
      int start = 0;
      for (end = 0; end < firstSeq.length; end++) {
        if (firstSeq[end] == "#") {
          positionStr += "${msaResult.positions[start]}-${msaResult.positions[end-1] + 1}, ";
          start = end + 1;
        }
      }
      positionStr += "${msaResult.positions[start]}-${msaResult.positions.last + 1}";
    }
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          Text("Channel:${msaResult.names[1]}", style: TextStyle(fontSize: 14)),
          Text(
            "Identity:${msaResult.identity}",
            style: TextStyle(fontSize: 14),
          ),
          Text(positionStr, style: TextStyle(fontSize: 14)),
          SingleMsaCoreV2(msaResult: msaResult),
        ],
      ),
    );
  }
}

class SingleMsaCoreV2 extends StatelessWidget {
  MsaResult msaResult;

  SingleMsaCoreV2({super.key, required this.msaResult});

  @override
  Widget build(BuildContext context) {
    final msaSeqs = msaResult.msaSeqs;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 20.0,
            children: List.generate(msaSeqs[0].length, (idx) {
              final singleColumn =
                  msaSeqs.map((seq) => seq.substring(idx, idx + 1)).toList();
              return SingleMsaColumn(columnsChars: singleColumn);
            }),
          ),
        ),
      ),
    );
  }
}

class SingleMsaCoreV3 extends StatelessWidget {
  MsaResult msaResult;

  SingleMsaCoreV3({super.key, required this.msaResult});

  @override
  Widget build(BuildContext context) {
    final partitioned = msaResult.partition();
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 0.0, // 每个 SingleMsaRegion 之间的水平间距
            runSpacing: 0.0, // 每行之间的垂直间距
            children: List.generate(
              partitioned.length,
              (idx) => SingleMsaRegion(
                msaSeqs: partitioned[idx].msaSeqs,
                positions: partitioned[idx].positions,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SingleMsaRegion extends StatelessWidget {
  List<String> msaSeqs;
  List<int> positions;
  SingleMsaRegion({super.key, required this.msaSeqs, required this.positions});

  @override
  Widget build(BuildContext context) {
    return Container( // 用 Container 包装，避免尺寸溢出
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              "position(0-based):[${positions[0]}, ${positions.last + 1})",
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 10.0,
              spacing: 10.0,
              children: List.generate(msaSeqs[0].length, (idx) {
                final singleColumn = msaSeqs
                    .map((seq) => seq.substring(idx, idx + 1))
                    .toList();
                return SingleMsaColumn(columnsChars: singleColumn);
              }),
            ),
          ),
        ],
      ),
    );
  }
}

const colorMap = {
  'A': Color(0xFF32CD32),
  'C': Color(0xFF1E90FF), // 蓝色
  'G': Color(0xFFFFA500), // 橙色
  'T': Color(0xFFFF6347), // 红色
  '-': Colors.grey,
  '·': Colors.black,
  '#': Colors.black,
  " ": Colors.black,
  "×": Colors.black,
  "0": Colors.red,
  "1": Colors.red,
  "2": Colors.red,
  "3": Colors.red,
  "4": Colors.black,
  "5": Colors.black,
  "6": Colors.black,
  "7": Colors.black,
  "8": Colors.black,
  "9": Colors.black,
};

class SingleMsaColumn extends StatelessWidget {
  List<String> columnsChars;
  SingleMsaColumn({super.key, required this.columnsChars});

  @override
  Widget build(BuildContext context) {
    columnsChars.insert(3, '·');
    final indicator = columnsChars[1] != columnsChars[2] ? "×" : " ";
    columnsChars.insert(0, indicator);
    return Column(
      children:
          columnsChars
              .map(
                (char) => Text(
                  char,
                  style: GoogleFonts.sourceCodePro(
                    fontSize: char == '·' ? 12 : 18,
                    color: colorMap[char],
                    fontWeight:
                        char == '·' ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              )
              .toList(),
    );
  }
}

Widget buildAlignedText(String text) {
  return RichText(
    text: TextSpan(
      children:
          text
              .split('')
              .map(
                (char) => TextSpan(
                  text: char,
                  style: GoogleFonts.sourceCodePro(
                    fontSize: 18,
                    color: colorMap[char],
                    fontWeight:
                        char == "#" ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              )
              .toList(),
    ),
  );
}

Widget buildAlignedText2(String text) {
  return Text(text, style: GoogleFonts.sourceCodePro(fontSize: 12));
}
