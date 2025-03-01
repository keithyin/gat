import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gat/utils/align_tile.dart';

// class SingleAlignment extends StatelessWidget {
//   String alignedQuery;
//   String alignedTarget;
//   SingleAlignment({
//     super.key,
//     required this.alignedQuery,
//     required this.alignedTarget,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Wrap(
//       spacing: 8.0,
//       runSpacing: 4.0,
//       children: List.generate(
//         alignedQuery.length,
//         (index) => AlignTile(
//           queryCode: alignedQuery.codeUnitAt(index),
//           targetCode: alignedTarget.codeUnitAt(index),
//         ),
//       ),
//     );
//   }
// }

int numRowElements = 180;

class SingleAlignment extends StatelessWidget {
  String alignedQuery;
  String alignedTarget;
  String targetTag;
  String queryTag;
  SingleAlignment({
    super.key,
    required this.alignedTarget,
    required this.alignedQuery,
    required this.targetTag,
    required this.queryTag,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = List.generate(alignedQuery.length, (index) {
      if (alignedQuery.codeUnitAt(index) == 45 ||
          alignedTarget.codeUnitAt(index) == 45) {
        return "?";
      }
      if (alignedQuery.codeUnitAt(index) == alignedTarget.codeUnitAt(index)) {
        return "|";
      } else {
        return "×";
      }
    });

    final indicatorStr = indicator.join();

    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          Text(
            targetTag,
            style: GoogleFonts.sourceCodePro(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            queryTag,
            style: GoogleFonts.sourceCodePro(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),

          Column(
            children: List.generate(
              ((alignedQuery.length + numRowElements - 1) / numRowElements)
                  .toInt(),
              (index) {
                int start = index * numRowElements;
                int end = start + numRowElements;
                end = end > indicatorStr.length ? indicatorStr.length : end;
                final sbrQuery = alignedQuery.substring(start, end);
                final sbrIndicator = indicatorStr.substring(start, end);
                final sbrTarget = alignedTarget.substring(start, end);

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    children: [
                      buildAlignedText2(sbrQuery),
                      buildAlignedText2(sbrIndicator),
                      buildAlignedText2(sbrTarget),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
                  style: GoogleFonts.sourceCodePro(fontSize: 14),
                ),
              )
              .toList(),
    ),
  );
}

Widget buildAlignedText2(String text) {
  return Text(text, style: GoogleFonts.sourceCodePro(fontSize: 12));
}
