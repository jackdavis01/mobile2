import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomSpinKitThreeInOut extends StatelessWidget {
  const CustomSpinKitThreeInOut({super.key});

  @override
  Widget build(BuildContext context) {
    return SpinKitThreeInOut(
      size: 36,
      itemBuilder: (BuildContext context, int index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle, // Circle shapes
            color: index.isEven ? Colors.blue : Colors.grey,
          ),
        );
      },
    );
  }

}
