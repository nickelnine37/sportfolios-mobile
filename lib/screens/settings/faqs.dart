import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/utils/numerical/array_operations.dart';

class FAQs extends StatefulWidget {
  FAQs({Key? key}) : super(key: key);

  @override
  _FAQsState createState() => _FAQsState();
}

class _FAQsState extends State<FAQs> {
  List<bool> isExpanded = [false, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'FAQs',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ExpansionPanelList(
            expansionCallback: (int index, bool itemIsExpanded) {
              setState(() {
                isExpanded[index] = !itemIsExpanded;
              });
            },
            children: range(5)
                .map<ExpansionPanel>(
                  (int i) => ExpansionPanel(
                    isExpanded: isExpanded[i],
                    headerBuilder: (context, expnded) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('item ${i}'),
                      );
                    },
                    body: Container(
                      child: Text('hey'),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
