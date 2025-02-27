import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectedFilename {
  String filename;
  SelectedFilename({required this.filename});
}

class FSWideget extends StatefulWidget {
  String tag;
  SelectedFilename selectedFilename;

  FSWideget({super.key, required this.tag, required this.selectedFilename});

  @override
  State<FSWideget> createState() => _FSWidegetState();
}

class _FSWidegetState extends State<FSWideget> {
  String fname = "filename";

  void _pickFile(String which) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final p = result.files.first.path;
      if (p != null) {
        setState(() {
          fname = p;
        });
      }

      widget.selectedFilename.filename = fname;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.tag, style: GoogleFonts.sourceCodePro(fontSize: 18)),
          Text(fname),
          ElevatedButton(
            onPressed: () => _pickFile("ref"),
            child: Text("Select a File"),
          ),
        ],
      ),
    );
  }
}
