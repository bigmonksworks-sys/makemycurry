import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/custom_button_widget.dart';
import 'package:provider/provider.dart';

import 'footer_web_widget.dart';

class NoDataWidget extends StatelessWidget {
  final bool isShowButton;
  final bool isFooter;
  final String? title;
  final String? subTitle;
  final String? image;
  const NoDataWidget({super.key,  this.isShowButton = true, required this.title, this.image, this.subTitle, this.isFooter = true});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return ResponsiveHelper.isDesktop(context) ? SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: height * 0.7, width: double.infinity, child: NoDataView(
            image: image, title: title, subTitle: subTitle, isShowButton: isShowButton,
          )),
          isFooter ? const FooterWebWidget(footerType: FooterType.nonSliver) : const SizedBox(),
        ],
      ),
    ) : NoDataView(image: image, title: title, subTitle: subTitle, isShowButton: isShowButton);


  }
}

class NoDataView extends StatelessWidget {
  const NoDataView({
    super.key,
    this.image,
    this.title,
    this.subTitle,
    this.isShowButton = true,
  });

  final String? image;
  final String? title;
  final String? subTitle;
  final bool isShowButton;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;

    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              image ?? Images.notFound,
              width: height * 0.12, height: height * 0.12,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
            ),
          ),
          SizedBox(height: height * 0.04),

          Text(
            title ?? getTranslated('no_result_found', context) ,
            style: poppinsSemiBold.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
              fontSize: Dimensions.fontSizeExtraLarge,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          if(subTitle != null) Text(
            subTitle!,
            style: poppinsRegular.copyWith(
              color: Theme.of(context).disabledColor,
              fontSize: Dimensions.fontSizeDefault,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: height * 0.04),

          if(isShowButton) Container(
            constraints: const BoxConstraints(maxWidth: 200),
            child: CustomButtonWidget(
              buttonText: 'lets_shop'.tr,
              onPressed: () {
                Provider.of<SplashProvider>(context, listen: false).setPageIndex(0);
                Navigator.pushNamed(context, RouteHelper.getMainRoute());
              },
              borderRadius: Dimensions.radiusSizeDefault,
            ),
          ),

        ]),
      ),
    );
  }
}
