import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/cart_model.dart';
import 'package:flutter_grocery/features/order/domain/models/order_model.dart';
import 'package:flutter_grocery/helper/date_converter_helper.dart';
import 'package:flutter_grocery/helper/order_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/common/providers/product_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/features/order/screens/order_details_screen.dart';
import 'package:flutter_grocery/features/order/widgets/re_order_dialog_widget.dart';
import 'package:flutter_grocery/helper/price_converter_helper.dart';
import 'package:provider/provider.dart';

class OrderItemWidget extends StatelessWidget {
  const OrderItemWidget(
      {super.key, required this.orderList, required this.index});

  final List<OrderModel>? orderList;
  final int index;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      onTap: () {
        Navigator.of(context).pushNamed(
          RouteHelper.getOrderDetailsRoute('${orderList?[index].id}'),
          arguments: OrderDetailsScreen(
              orderId: orderList![index].id, orderModel: orderList![index]),
        );
      },
      child: Container(
        padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context)
            ? 30
            : Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                '${getTranslated('order_id', context)} #${orderList![index].id}',
                style: poppinsSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge),
              ),
              const SizedBox(height: 4),
              Text(
                DateConverterHelper.isoStringToLocalDateOnly(
                    orderList![index].updatedAt!),
                style: poppinsRegular.copyWith(
                    color: Theme.of(context).disabledColor,
                    fontSize: Dimensions.fontSizeSmall),
              ),
            ]),
            _OrderStatusCard(orderList: orderList, index: index),
          ]),
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeSmall),
            child: Divider(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                thickness: 0.5),
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    '${orderList![index].totalQuantity} ${getTranslated(orderList![index].totalQuantity == 1 ? 'item' : 'items', context)}',
                    style: poppinsRegular.copyWith(
                        color: Theme.of(context).disabledColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    PriceConverterHelper.convertPrice(
                        context, orderList![index].orderAmount),
                    style: poppinsSemiBold.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize: Dimensions.fontSizeLarge),
                  ),
                ]),
                orderList![index].orderType != 'pos'
                    ? Consumer<ProductProvider>(
                        builder: (context, productProvider, _) =>
                            Consumer<OrderProvider>(
                                builder: (context, orderProvider, _) {
                              bool isReOrderAvailable =
                                  orderProvider.getReOrderIndex == null ||
                                      (orderProvider.getReOrderIndex != null &&
                                          productProvider.product != null);

                              return (orderProvider.isLoading ||
                                          productProvider.product == null) &&
                                      index == orderProvider.getReOrderIndex &&
                                      !orderProvider.isActiveOrder
                                  ? CustomLoaderWidget(
                                      color: Theme.of(context).primaryColor)
                                  : _TrackOrderView(
                                      orderList: orderList,
                                      index: index,
                                      isReOrderAvailable: isReOrderAvailable);
                            }))
                    : const SizedBox.shrink(),
              ]),
        ]),
      ),
    );
  }
}

class _TrackOrderView extends StatelessWidget {
  const _TrackOrderView(
      {required this.orderList,
      required this.index,
      required this.isReOrderAvailable});

  final List<OrderModel>? orderList;
  final int index;
  final bool isReOrderAvailable;

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(builder: (context, orderProvider, child) {
      return TextButton(
        style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
            )),
        onPressed: () async {
          if (orderProvider.isActiveOrder) {
            Navigator.of(context).pushNamed(
                RouteHelper.getOrderTrackingRoute(orderList![index].id, null));
          } else {
            if (!orderProvider.isLoading && isReOrderAvailable) {
              orderProvider.setReorderIndex = index;
              List<CartModel>? cartList =
                  await orderProvider.reorderProduct('${orderList![index].id}');
              if (cartList != null && cartList.isNotEmpty) {
                showDialog(
                    context: Get.context!,
                    builder: (context) => const ReOrderDialogWidget());
              }
            }
          }
        },
        child: Text(
          getTranslated(
              orderProvider.isActiveOrder ? 'order_track' : 're_order',
              context),
          style: poppinsMedium.copyWith(
            color: Theme.of(context).cardColor,
            fontSize: Dimensions.fontSizeDefault,
          ),
        ),
      );
    });
  }
}

class _OrderStatusCard extends StatelessWidget {
  const _OrderStatusCard({required this.orderList, required this.index});

  final List<OrderModel>? orderList;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall, vertical: 6),
      decoration: BoxDecoration(
        color: OrderStatus.pending.name == orderList![index].orderStatus
            ? ColorResources.colorBlue.withValues(alpha: 0.1)
            : OrderStatus.out_for_delivery.name == orderList![index].orderStatus
                ? ColorResources.ratingColor.withValues(alpha: 0.1)
                : OrderStatus.canceled.name == orderList![index].orderStatus
                    ? ColorResources.redColor.withValues(alpha: 0.1)
                    : ColorResources.colorGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
      ),
      child: Text(
        getTranslated(orderList![index].orderStatus, context),
        style: poppinsMedium.copyWith(
            fontSize: Dimensions.fontSizeExtraSmall,
            color: OrderStatus.pending.name == orderList![index].orderStatus
                ? ColorResources.colorBlue
                : OrderStatus.out_for_delivery.name ==
                        orderList![index].orderStatus
                    ? ColorResources.ratingColor
                    : OrderStatus.canceled.name == orderList![index].orderStatus
                        ? ColorResources.redColor
                        : ColorResources.colorGreen),
      ),
    );
  }
}
