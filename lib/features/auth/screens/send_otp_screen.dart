import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_button_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_pop_scope_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_text_field_widget.dart';
import 'package:flutter_grocery/common/widgets/footer_web_widget.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_grocery/features/auth/domain/models/user_log_data.dart';
import 'package:flutter_grocery/features/auth/enum/from_page_enum.dart';
import 'package:flutter_grocery/features/auth/enum/verification_type_enum.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/auth/providers/verification_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/auth_helper.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/helper/phone_number_checker_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class SendOtpScreen extends StatefulWidget {
  const SendOtpScreen({super.key});

  @override
  State<SendOtpScreen> createState() => _SendOtpScreenState();
}

class _SendOtpScreenState extends State<SendOtpScreen> {
  String? countryCode;
  TextEditingController? _phoneNumberController;

  @override
  void initState() {
    super.initState();
    _phoneNumberController = TextEditingController();

    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);

    UserLogData? userData = authProvider.getUserData();
    if (userData != null && userData.loginType == FromPage.otp.name) {
      if (userData.phoneNumber != null) {
        _phoneNumberController!.text = PhoneNumberCheckerHelper.getPhoneNumber(userData.phoneNumber ?? '', userData.countryCode ?? '') ?? '';
      }
      countryCode ??= userData.countryCode;
    } else {
      countryCode ??= CountryCode.fromCountryCode(configModel.country!).dialCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;

    return CustomPopScopeWidget(
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: ResponsiveHelper.isDesktop(context)
            ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
            : PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: CustomAppBarWidget(
                  isBackButtonExist: true,
                  title: '',
                  onBackPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    width: Dimensions.webScreenWidth,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),
                        
                        // --- Premium Header ---
                        Image.asset(Images.appLogo, height: 60, fit: BoxFit.contain),
                        const SizedBox(height: 40),
                        
                        Text(
                          getTranslated('welcome_back', context),
                          style: poppinsSemiBold.copyWith(fontSize: 32, height: 1.2, color: Theme.of(context).primaryColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          getTranslated('enter_mobile_number_to_login', context),
                          style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).disabledColor),
                        ),
                        
                        const SizedBox(height: 50),

                        // --- Input Field ---
                        CustomTextFieldWidget(
                          countryDialCode: countryCode,
                          onCountryChanged: (CountryCode value) => countryCode = value.dialCode,
                          hintText: getTranslated('number_hint', context),
                          isShowBorder: true,
                          controller: _phoneNumberController,
                          inputType: TextInputType.phone,
                          title: getTranslated('mobile_number', context),
                          isElevation: false,
                          fillColor: Theme.of(context).primaryColor.withValues(alpha: 0.03),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        // --- Remember Me ---
                        Consumer<AuthProvider>(builder: (context, authProvider, child) {
                          return InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () => authProvider.onChangeRememberMeStatus(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Container(
                                  width: 20, height: 20,
                                  decoration: BoxDecoration(
                                    color: authProvider.isActiveRememberMe ? Theme.of(context).primaryColor : Colors.transparent,
                                    border: Border.all(color: authProvider.isActiveRememberMe ? Colors.transparent : Theme.of(context).primaryColor.withValues(alpha: 0.3)),
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                                  ),
                                  child: authProvider.isActiveRememberMe
                                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                                      : null,
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                Text(
                                  getTranslated('remember_me', context),
                                  style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                                ),
                              ]),
                            ),
                          );
                        }),
                        
                        const SizedBox(height: 40),

                        // --- Action Button ---
                        Consumer<VerificationProvider>(builder: (context, verificationProvider, child) {
                          return SizedBox(
                            width: double.infinity,
                            child: CustomButtonWidget(
                              isLoading: verificationProvider.isLoading,
                              buttonText: getTranslated('get_otp', context),
                              borderRadius: 50, // Pill shape
                              onPressed: () async {
                                if (_phoneNumberController!.text.isEmpty) {
                                  showCustomSnackBarHelper(getTranslated('enter_phone_number', context));
                                } else {
                                  String phoneWithCountryCode = countryCode! + _phoneNumberController!.text.trim();
                                  if (PhoneNumberCheckerHelper.isPhoneValidWithCountryCode(phoneWithCountryCode)) {
                                    if (AuthHelper.isPhoneVerificationEnable(configModel)) {
                                      await verificationProvider.sendVerificationCode(
                                          context, configModel, phoneWithCountryCode,
                                          type: VerificationType.phone.name, fromPage: FromPage.otp.name);
                                    }
                                  } else {
                                    showCustomSnackBarHelper(getTranslated('invalid_phone_number', context));
                                  }
                                }
                              },
                            ),
                          );
                        }),
                        
                        const SizedBox(height: 30),

                        // --- Guest Link ---
                        if (configModel.isGuestCheckout == true && !Navigator.canPop(context))
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, RouteHelper.getMainRoute(), (route) => false),
                              child: RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: '${getTranslated('continue_as_a', context)} ',
                                    style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor),
                                  ),
                                  TextSpan(
                                    text: getTranslated('guest', context),
                                    style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
                                  ),
                                ]),
                              ),
                            ),
                          ),
                          
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ),
              if (ResponsiveHelper.isDesktop(context))
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                    SizedBox(height: Dimensions.paddingSizeLarge),
                    FooterWebWidget(footerType: FooterType.nonSliver),
                  ]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
