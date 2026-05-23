import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class DeliveryOptionWidget extends StatelessWidget {
  final String value;
  final String? title;
  const DeliveryOptionWidget({super.key, required this.value, required this.title});

  @override
  Widget build(BuildContext context) {

    return Consumer<OrderProvider>(
      builder: (context, order, child) {
        return InkWell(
          onTap: () => order.setOrderType(value),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: order.orderType == value ? const Color(0xFF4AC2E2) : Colors.black26,
                    width: order.orderType == value ? 5 : 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              Text(title!, style: poppinsMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Colors.black,
              )),
              const SizedBox(width: 15),
            ],
          ),
        );
      },
    );
  }
}
