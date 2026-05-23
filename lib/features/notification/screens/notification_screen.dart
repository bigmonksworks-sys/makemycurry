import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
import 'package:flutter_grocery/features/notification/widgets/notification_item_widget.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/date_converter_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/notification/providers/notification_provider.dart';
import 'package:flutter_grocery/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/common/widgets/footer_web_widget.dart';
import 'package:flutter_grocery/common/widgets/no_data_widget.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  @override
  void initState() {
    Provider.of<NotificationProvider>(context, listen: false).getNotificationList(isUpdate: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);

    return PopScope(
      canPop: ResponsiveHelper.isWeb() ? true : false,
      onPopInvokedWithResult: (bool didPop, _) {
        if(didPop) return;
        if (Navigator.canPop(context) && !ResponsiveHelper.isDesktop(context)) {
          Navigator.pop(context);
        } else if(!didPop && !Navigator.canPop(context)){
          Navigator.of(context).pushNamedAndRemoveUntil(RouteHelper.menu, (route) => false);
          splashProvider.setPageIndex(0);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: (ResponsiveHelper.isDesktop(context) ? const PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: WebAppBarWidget(),
        ) : CustomAppBarWidget(
          title: getTranslated('notification', context),
          isBackButtonExist: true,
          onBackPressed: (){
            if(!Navigator.canPop(context)){
              Navigator.of(context).pushNamedAndRemoveUntil(RouteHelper.menu, (route) => false);
              splashProvider.setPageIndex(0);
            } else{
              Navigator.pop(context);
            }
          },
        )) as PreferredSizeWidget?,
        body: RefreshIndicator(
          onRefresh: () async {
            await Provider.of<NotificationProvider>(context, listen: false).getNotificationList();
          },
          backgroundColor: Theme.of(context).primaryColor,
          color: Colors.white,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    width: Dimensions.webScreenWidth,
                    constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.7),
                    child: Consumer<NotificationProvider>(builder: (context, notificationProvider, child) {
                      List<DateTime> dateTimeList = [];

                      if (notificationProvider.notificationList == null) {
                        return Center(child: CustomLoaderWidget(color: Theme.of(context).primaryColor));
                      }

                      if (notificationProvider.notificationList!.isEmpty) {
                        return NoDataWidget(
                          title: getTranslated('no_notification_found', context),
                          // showFooter: true,
                        );
                      }

                      return ListView.builder(
                        itemCount: notificationProvider.notificationList!.length,
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.isDesktop(context) ? 100 : Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeLarge,
                        ),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          DateTime originalDateTime = DateConverterHelper.isoStringToLocalDate(notificationProvider.notificationList![index].createdAt!);
                          DateTime convertedDate = DateTime(originalDateTime.year, originalDateTime.month, originalDateTime.day);
                          bool addTitle = false;
                          if(!dateTimeList.contains(convertedDate)) {
                            addTitle = true;
                            dateTimeList.add(convertedDate);
                          }
                          return NotificationItemWidget(
                            isTitle: addTitle, 
                            notification: notificationProvider.notificationList![index],
                          );
                        },
                      );
                    }),
                  ),
                ),
              ),
              const FooterWebWidget(footerType: FooterType.sliver),
            ],
          ),
        ),
      ),
    );
  }
}
