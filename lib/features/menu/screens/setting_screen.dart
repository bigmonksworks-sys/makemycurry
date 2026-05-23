import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/app_bar_base_widget.dart';
import 'package:flutter_grocery/helper/dialog_helper.dart';
import 'package:flutter_grocery/common/widgets/main_app_bar_widget.dart';
import 'package:flutter_grocery/features/menu/widgets/currency_dialog_widget.dart';
import 'package:provider/provider.dart';

import 'package:flutter_grocery/helper/route_helper.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/acount_delete_dialog_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<SplashProvider>(context, listen: false).setFromSetting(true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: ResponsiveHelper.isMobilePhone()
          ? null
          : (ResponsiveHelper.isDesktop(context)
              ? const MainAppBarWidget()
              : const AppBarBaseWidget()) as PreferredSizeWidget?,
      body: Center(
        child: SizedBox(
          width: 1170,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeExtraSmall),
            children: [
              _TitleButton(
                icon: Icons.language,
                title: getTranslated('choose_language', context),
                onTap: () =>
                    showDialogHelper(context, const CurrencyDialogWidget()),
              ),
              _TitleButton(
                icon: Icons.description,
                title: getTranslated('terms_and_condition', context),
                onTap: () =>
                    Navigator.pushNamed(context, RouteHelper.getTermsRoute()),
              ),
              _TitleButton(
                icon: Icons.privacy_tip,
                title: getTranslated('privacy_policy', context),
                onTap: () =>
                    Navigator.pushNamed(context, RouteHelper.getPolicyRoute()),
              ),
              if (Provider.of<SplashProvider>(context, listen: false)
                      .configModel
                      ?.refundPolicyStatus ??
                  false)
                _TitleButton(
                  icon: Icons.assignment_return,
                  title: getTranslated('refund_policy', context),
                  onTap: () => Navigator.pushNamed(
                      context, RouteHelper.getRefundPolicyRoute()),
                ),
              if (Provider.of<SplashProvider>(context, listen: false)
                      .configModel
                      ?.cancellationPolicyStatus ??
                  false)
                _TitleButton(
                  icon: Icons.cancel_presentation,
                  title: getTranslated('cancellation_policy', context),
                  onTap: () => Navigator.pushNamed(
                      context, RouteHelper.getCancellationPolicyRoute()),
                ),
              _TitleButton(
                icon: Icons.info_outline,
                title: getTranslated('about_us', context),
                onTap: () =>
                    Navigator.pushNamed(context, RouteHelper.getAboutUsRoute()),
              ),
              if (Provider.of<SplashProvider>(context, listen: false)
                      .configModel
                      ?.returnPolicyStatus ??
                  false)
                _TitleButton(
                  icon: Icons.assignment_return_outlined,
                  title: getTranslated('return_policy', context),
                  onTap: () => Navigator.pushNamed(
                      context, RouteHelper.getReturnPolicyRoute()),
                ),
              _TitleButton(
                icon: Icons.question_answer,
                title: getTranslated('faq', context),
                onTap: () =>
                    Navigator.pushNamed(context, RouteHelper.getFaqRoute()),
              ),
              authProvider.isLoggedIn()
                  ? ListTile(
                      onTap: () {
                        showDialogHelper(
                            context,
                            AccountDeleteDialogWidget(
                              icon: Icons.question_mark_sharp,
                              title: getTranslated(
                                  'are_you_sure_to_delete_account', context),
                              description: getTranslated(
                                  'it_will_remove_your_all_information',
                                  context),
                              onTapFalseText: getTranslated('no', context),
                              onTapTrueText: getTranslated('yes', context),
                              isFailed: true,
                              onTapFalse: () => Navigator.of(context).pop(),
                              onTapTrue: () => authProvider.deleteUser(context),
                            ),
                            dismissible: false,
                            isFlip: true);
                      },
                      leading: Icon(Icons.delete,
                          size: 25, color: Theme.of(context).colorScheme.error),
                      title: Text(
                        getTranslated('delete_account', context),
                        style: poppinsRegular.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleButton extends StatelessWidget {
  final IconData icon;
  final String? title;
  final Function onTap;
  const _TitleButton(
      {required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title!,
          style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
      onTap: onTap as void Function()?,
    );
  }
}
