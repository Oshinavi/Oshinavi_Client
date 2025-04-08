import 'package:flutter/material.dart';

/*
User BIO Box
*/

class BioBox extends StatelessWidget {
  final String text;

  const BioBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "바이오" 라벨
          const Padding(
            padding: EdgeInsets.only(left: 4.0, bottom: 6.0),
            child: Text(
              "바이오",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // BIO 박스
          Container(
            constraints: const BoxConstraints(minHeight: 120), // ✅ 최소 높이 지정
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}