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
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          Text("Channel:${msaResult.names[0]}", style: TextStyle(fontSize: 14)),
          Text(
            "Identity:${msaResult.identity}",
            style: TextStyle(fontSize: 14),
          ),
          SingleMsaCoreV2(msaSeqs: msaResult.msaSeqs),
        ],
      ),
    );
  }
}

class SingleMsaCoreV1 extends StatelessWidget {
  List<String> msaSeqs;

  SingleMsaCoreV1({super.key, required this.msaSeqs});

  @override
  Widget build(BuildContext context) {
    final totLength = msaSeqs[0].length;
    final numRow = ((totLength + numRowElements - 1) / numRowElements).toInt();
    return Column(
      children: List.generate(numRow, (index) {
        int start = index * numRowElements;
        int end = start + numRowElements;
        end = end > totLength ? totLength : end;
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            children:
                msaSeqs
                    .map((line) => buildAlignedText(line.substring(start, end)))
                    .toList(),
          ),
        );
      }),
    );
  }
}

class SingleMsaCoreV2 extends StatelessWidget {
  List<String> msaSeqs;

  SingleMsaCoreV2({super.key, required this.msaSeqs});

  @override
  Widget build(BuildContext context) {
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

const colorMap = {
  'A': Color(0xFF32CD32),
  'C': Color(0xFF1E90FF), // 蓝色
  'G': Color(0xFFFFA500), // 橙色
  'T': Color(0xFFFF6347), // 红色
  '-': Colors.grey,
  'v': Colors.grey,
  '#': Colors.black,
  " ": Colors.black,
  "×": Colors.black,
};

class SingleMsaColumn extends StatelessWidget {
  List<String> columnsChars;
  SingleMsaColumn({super.key, required this.columnsChars});

  @override
  Widget build(BuildContext context) {
    columnsChars.insert(2, 'v');
    final indicator = columnsChars[0] != columnsChars[1]? "×": " ";
    columnsChars.insert(0, indicator);
    return Column(
      children:
          columnsChars
              .map(
                (char) => Text(
                  char,
                  style: GoogleFonts.sourceCodePro(
                    fontSize: 18,
                    color: colorMap[char],
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
