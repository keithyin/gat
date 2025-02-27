import 'package:flutter/material.dart';
import 'package:toolkits_of_roc_yin/pages/msa.dart';
import 'package:toolkits_of_roc_yin/pages/pair_alignment.dart';
import 'package:toolkits_of_roc_yin/pages/pair_alignment_with_ref_genome.dart';

class MainPage extends StatefulWidget {
  MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _toolkits = ["PairAlignment", "PairAlignWithRefGenome", "MSA"];

  int _pageIdx = 0;
  final _pages = [Container(), PairAlignment(), PairAlignmentWithRefGenome() ,MSA()];

  void setPageIdx(int index) {
    setState(() {
      _pageIdx = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("(G)eneus (A)lgorithm (T)oolkits")),
        automaticallyImplyLeading: true,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: Text("Toolkits", style: TextStyle(fontSize: 25)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _toolkits.length,
                itemBuilder:
                    (context, index) => Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          setPageIdx(index + 1);
                          },

                        child: Container(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            _toolkits[index],
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
      body: _pages[_pageIdx],
    );
  }
}
