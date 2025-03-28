import 'package:flutter/material.dart';

class ErrorComponent extends StatelessWidget {
  final String ErrorText;
  const ErrorComponent({super.key, required this.ErrorText});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/images/ErrorImage.png'),
        Text(ErrorText,style: const TextStyle(fontSize: 20),),
      ],
    );
  }
}
