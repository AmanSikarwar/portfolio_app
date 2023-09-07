import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    Key? key,
    this.size = const Size(256, 256),
    this.blurColor = Colors.black,
  }) : super(key: key);

  final Size size;
  final Color blurColor;

  @override
  Widget build(BuildContext context) {
    final blurColor = Theme.of(context).scaffoldBackgroundColor;
    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.all(16),
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              blurColor.withOpacity(0.5),
              blurColor,
            ],
            stops: const [0.8, 0.9, 1.0],
          ),
        ),
        child: const Image(
          image: AssetImage("assets/images/avatar.png"),
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }
}
