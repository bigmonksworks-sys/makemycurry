import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:provider/provider.dart';

class SignOutDialogWidget extends StatelessWidget {
  const SignOutDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault)),
        elevation: 10,
        backgroundColor: Theme.of(context).cardColor,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.logout_rounded, size: 40, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Text(
              getTranslated('want_to_sign_out', context),
              style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            !auth.isLoading ? Column(children: [
              
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () async {
                    auth.signOut().then((value) {
                      if(context.mounted) {
                        showCustomSnackBarHelper(getTranslated('logout_successful', context), isError: false);
                        if(ResponsiveHelper.isWeb()) {
                          Navigator.pushNamedAndRemoveUntil(context, RouteHelper.getMainRoute(), (route) => false);
                        } else {
                          Navigator.pushNamedAndRemoveUntil(context, RouteHelper.getLoginRoute(), (route) => false);
                        }
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault)),
                    elevation: 0,
                  ),
                  child: Text(getTranslated('yes', context), style: poppinsSemiBold.copyWith(color: Colors.white)),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              SizedBox(
                width: double.infinity,
                height: 45,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                      side: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
                    ),
                  ),
                  child: Text(getTranslated('no', context), style: poppinsSemiBold.copyWith(color: Theme.of(context).primaryColor)),
                ),
              ),

            ]) : Center(child: CustomLoaderWidget(color: Theme.of(context).primaryColor)),
          ]),
        ),
      ),
    );
  }
}
