import 'package:flutter/material.dart';

class Marquee extends StatefulWidget {
  final Widget child;
  final Duration animationDuration, backDuration, pauseDuration;

  Marquee({
    @required this.child,
    this.animationDuration: const Duration(milliseconds: 3000),
    this.backDuration: const Duration(milliseconds: 800),
    this.pauseDuration: const Duration(milliseconds: 1500),
  });

  @override
  _MarqueeState createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> {
  ScrollController scrollController;

  @override
  void initState() {
    scrollController = ScrollController(initialScrollOffset: 0);
    WidgetsBinding.instance.addPostFrameCallback(scroll);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: widget.child,
      scrollDirection: Axis.horizontal,
      controller: scrollController,
      physics: NeverScrollableScrollPhysics(),
    );
  }

  void scroll(_) async {
    while (scrollController.hasClients) {
      await Future.delayed(widget.pauseDuration);
      if (scrollController.hasClients)
        await scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: widget.animationDuration,
          curve: Curves.linear,
        );
      await Future.delayed(widget.pauseDuration);
      if (scrollController.hasClients)
        await scrollController.animateTo(
          0.0,
          duration: widget.backDuration,
          curve: Curves.linear,
        );
    }
  }
}