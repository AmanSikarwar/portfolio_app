import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class IntroWidget extends StatelessWidget {
  const IntroWidget({super.key, this.size = const Size(512, 256)});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height,
      width: size.width,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DefaultTextStyle(
            style:
                Theme.of(context).textTheme.displayMedium!.copyWith(),
            child: AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  "Hello, I'm Aman Sikarwar",
                  textAlign: TextAlign.center,
                ),
              ],
              totalRepeatCount: 1,
              pause: const Duration(milliseconds: 1600),
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: size.height * 0.2,
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.displaySmall!,
              child: AnimatedTextKit(
                animatedTexts: [
                  FadeAnimatedText(
                    "Flutter Developer",
                    textAlign: TextAlign.center,
                  ),
                  FadeAnimatedText(
                    "Android Developer",
                    textAlign: TextAlign.center,
                  ),
                  FadeAnimatedText(
                    "Open Source Contributor",
                    textAlign: TextAlign.center,
                  ),
                  FadeAnimatedText(
                    "Tech Enthusiast",
                    textAlign: TextAlign.center,
                  ),
                  FadeAnimatedText(
                    "Linux Enthusiast",
                    textAlign: TextAlign.center,
                  ),
                ],
                pause: const Duration(milliseconds: 1600),
                displayFullTextOnTap: true,
                stopPauseOnTap: true,
                isRepeatingAnimation: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
