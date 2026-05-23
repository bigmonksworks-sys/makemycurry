import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/features/menu/screens/menu_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_grocery/theme/light_theme.dart';

class DetailsAppBarWidget extends StatefulWidget
    implements PreferredSizeWidget {
  final String? title;
  const DetailsAppBarWidget({super.key, this.title});

  @override
  DetailsAppBarWidgetState createState() => DetailsAppBarWidgetState();

  @override
  Size get preferredSize => const Size(double.maxFinite, 50);
}

class DetailsAppBarWidgetState extends State<DetailsAppBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
  }

  void shake() {
    controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> offsetAnimation = Tween(begin: 0.0, end: 15.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        }
      });

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      title: Text(widget.title!,
          style: poppinsMedium.copyWith(fontSize: 20, color: Colors.black)),
      centerTitle: true,
      actions: [
        AnimatedBuilder(
          animation: offsetAnimation,
          builder: (buildContext, child) {
            return Container(
              padding: EdgeInsets.only(
                  left: offsetAnimation.value + 15.0,
                  right: 15.0 - offsetAnimation.value),
              child: IconButton(
                icon: Stack(clipBehavior: Clip.none, children: [
                  const Icon(Icons.shopping_cart_outlined,
                      color: Colors.black87, size: 26),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      height: 20,
                      width: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: pesitoAlert),
                      child: Text(
                          '${Provider.of<CartProvider>(context).cartList.length}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ]),
                onPressed: () {
                  Provider.of<SplashProvider>(context, listen: false)
                      .setPageIndex(2);
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MenuScreen()));
                },
              ),
            );
          },
        )
      ],
    );
  }
}
