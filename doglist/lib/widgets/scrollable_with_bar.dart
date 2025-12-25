import 'package:flutter/material.dart';

class ScrollableWithBar extends StatefulWidget {
  final Widget child;

  const ScrollableWithBar({super.key, required this.child});

  @override
  State<ScrollableWithBar> createState() => _ScrollableWithBarState();
}

class _ScrollableWithBarState extends State<ScrollableWithBar> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      thickness: 8.0,
      radius: const Radius.circular(4.0),
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: widget.child,
      ),
    );
  }
}
