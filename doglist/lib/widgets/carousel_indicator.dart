import 'package:flutter/material.dart';

class CarouselIndicator extends StatelessWidget {
  final int totalPages;
  final int currentPage;

  const CarouselIndicator({super.key, required this.totalPages, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 10,
          width: currentPage == index ? 24 : 10,
          decoration: BoxDecoration(
            color: currentPage == index ? Theme.of(context).primaryColor : Colors.grey.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }
}
