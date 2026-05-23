import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/app_bar_base_widget.dart';
import 'package:flutter_grocery/common/widgets/not_login_widget.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_grocery/features/order/widgets/order_widget.dart';
import 'package:provider/provider.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    final bool isLoggedIn =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    Provider.of<OrderProvider>(context, listen: false)
        .changeActiveOrderStatus(true, isUpdate: false);

    if (isLoggedIn) {
      _tabController = TabController(
          length: 2,
          initialIndex: 0,
          vsync: this,
          animationDuration: const Duration(milliseconds: 100));
      Provider.of<OrderProvider>(context, listen: false).getOrderList(context);
    }

    _tabController?.addListener(() {
      setState(() {
        final OrderProvider orderProvider =
            Provider.of<OrderProvider>(context, listen: false);
        orderProvider.changeActiveOrderStatus(_tabController?.index == 0);
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();

    return Scaffold(
      appBar: ResponsiveHelper.isMobilePhone()
          ? null
          : (ResponsiveHelper.isDesktop(context)
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
              : const AppBarBaseWidget()) as PreferredSizeWidget?,
      body: isLoggedIn
          ? Consumer<OrderProvider>(builder: (context, orderProvider, child) {
              return Column(
                children: [
                  ResponsiveHelper.isDesktop(context)
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeExtraLarge),
                          child: Text("my_orders".tr,
                              style: poppinsSemiBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge)),
                        )
                      : const SizedBox(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: ResponsiveHelper.isDesktop(context) ? 400 : MediaQuery.sizeOf(context).width - 60,
                        height: 45,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                        ),
                        child: TabBar(
                          onTap: (int? index)=> orderProvider.changeActiveOrderStatus(index == 0),
                          controller: _tabController,
                          labelColor: Colors.white,
                          unselectedLabelColor: Theme.of(context).primaryColor.withValues(alpha: 0.6),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault - 4),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          labelStyle: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                          unselectedLabelStyle: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                          tabs: [
                            Tab(text: getTranslated('ongoing', context)),
                            Tab(text: getTranslated('history', context)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      child: TabBarView(
                    controller: _tabController,
                    children: const [
                      OrderWidget(isRunning: true),
                      OrderWidget(isRunning: false),
                    ],
                  )),
                ],
              );
            })
          : const NotLoggedInWidget(),
    );
  }
}
