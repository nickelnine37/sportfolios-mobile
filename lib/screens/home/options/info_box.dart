import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../utils/numerical/array_operations.dart';

class InfoBox extends StatelessWidget {
  final String title;
  final List<Widget> pages;

  InfoBox({
    required this.title,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) {
    const double padding = 30;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 200,
        height: 400,
        padding: EdgeInsets.only(top: padding, left: padding, right: padding),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(padding),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10.0, offset: const Offset(0.0, 10.0))],
        ),
        child: DefaultTabController(
          length: pages.length,
          child: Center(
            child: Column(children: [
              Text(
                title,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              Container(
                width: 80,
                child: Center(
                  child: TabBar(
                    labelColor: Colors.grey[900],
                    unselectedLabelColor: Colors.grey[400],
                    indicatorColor: Colors.grey[700],
                    indicatorWeight: 0.0001,
                    labelPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: range(pages.length)
                        .map((int i) => Tab(child: Text('•', style: TextStyle(fontSize: 20))))
                        .toList(),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: pages,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // To close the dialog
                  },
                  child: Text('OK'),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}

class MiniInfoPage extends StatelessWidget {
  final String text;
  final Widget icon;
  final Color? iconColor;

  MiniInfoPage(this.text, this.icon, this.iconColor);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
          textAlign: TextAlign.center,
        ),
        Shimmer.fromColors(
          period: Duration(milliseconds: 3000),
          baseColor: iconColor!,
          highlightColor: iconColor!.withAlpha(120),
          child: icon
        )
      ],
    );
  }
}
