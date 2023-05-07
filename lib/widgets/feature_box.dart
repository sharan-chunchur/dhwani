import 'package:dhwani/utils/pallets.dart';
import 'package:flutter/material.dart';

class FeatureBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  const FeatureBox({Key? key, required this.title, required this.color, required this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 40),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: color,
            borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: 'Cera Pro',
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontFamily: 'Cera Pro',
              ),
            ),
          ],
        ));
  }
}
