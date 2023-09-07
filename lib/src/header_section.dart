import 'package:flutter/material.dart';
import 'package:portfolio_app/src/widgets/avatar_widget.dart';
import 'package:portfolio_app/src/widgets/intro_widget.dart';

class HeaderSectionDesktop extends StatelessWidget {
  const HeaderSectionDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Container(
      height: size.height * 0.6,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AvatarWidget(
              size: Size(size.width * 0.46, size.height * 0.6)),
          IntroWidget(size: Size(size.width * 0.46, size.height * 0.6)),
        ],
      ),
    );
  }
}

class HeaderSectionMobile extends StatelessWidget {
  const HeaderSectionMobile({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AvatarWidget(size: Size(size.width, size.height * 0.48)),
        IntroWidget(size: Size(size.width, size.height * 0.36)),
      ],
    );
  }
}
