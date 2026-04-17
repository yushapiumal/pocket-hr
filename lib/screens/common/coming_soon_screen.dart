import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:cn_pocket_hr/helpers/hr_colors.dart';

class ComingSoonScreen extends StatelessWidget {
  final String title;

  const ComingSoonScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: HRColors.black),
        title: AutoSizeText(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: HRColors.black),
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 248, 250, 252),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HRColors.black.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(color: HRColors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: HRColors.lightOrangeColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.hourglass_bottom_rounded, color: HRColors.darkOrangeColor, size: 30),
              ),
              const SizedBox(height: 12),
              AutoSizeText(
                '$title is coming soon',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: HRColors.darkFontColor),
              ),
              const SizedBox(height: 6),
              AutoSizeText(
                'We are working on this feature and will release it in a future update.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: HRColors.lightFontColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
