import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';

class OnboardContent extends StatelessWidget {
  const OnboardContent({
    Key? key,
    required this.illustration,
    required this.title,
    required this.text,
  }) : super(key: key);

  final String? illustration, title, text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.asset(illustration!),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title!,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(fontWeight: FontWeight.w900, fontSize: 35),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        Text(
          text!,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
