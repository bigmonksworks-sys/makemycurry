import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/common/enums/app_mode_enum.dart';
import 'package:flutter_grocery/features/auth/domain/models/user_log_data.dart';
import 'package:flutter_grocery/features/auth/enum/from_page_enum.dart';
import 'package:flutter_grocery/features/auth/enum/verification_type_enum.dart';
import 'package:flutter_grocery/features/auth/providers/verification_provider.dart';
import 'package:flutter_grocery/helper/auth_helper.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/helper/email_checker_helper.dart';
import 'package:flutter_grocery/helper/phone_number_checker_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_button_widget.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/footer_web_widget.dart';
import '../../../common/widgets/web_app_bar_widget.dart';

class VerificationScreen extends StatefulWidget {
  final String userInput;
  final String fromPage;
  final String? session;
  const VerificationScreen({super.key, this.session, required this.userInput, required this.fromPage});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController inputPinTextController = TextEditingController();

  @override
  void initState() {
    final VerificationProvider verificationProvider = Provider.of<VerificationProvider>(context, listen: false);
    verificationProvider.startVerifyTimer();
    verificationProvider.updateVerificationCode('', 6, isUpdate: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = EmailCheckerHelper.isNotValid(widget.userInput);
    final ConfigModel? config = Provider.of<SplashProvider>(context, listen: false).configModel;
    final bool isFirebaseOTP = AuthHelper.isCustomerVerificationEnable(config) && AuthHelper.isFirebaseVerificationEnable(config);
    String userInput = widget.userInput;
    if (!userInput.contains('+') && isPhone) {
      userInput = '+${widget.userInput.replaceAll(' ', '')}';
    }

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: (ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBarWidget()) : CustomAppBarWidget(
        title: '',
      )) as PreferredSizeWidget?,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: Container(
                  width: Dimensions.webScreenWidth,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
                  child: Consumer<VerificationProvider>(
                    builder: (context, verificationProvider, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60),
                          Text(
                            getTranslated('otp_verification', context),
                            style: poppinsSemiBold.copyWith(fontSize: 32, height: 1.2, color: Theme.of(context).primaryColor),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: '${getTranslated('we_have_sent_verification_code', context)} ',
                                style: poppinsRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeLarge),
                              ),
                              TextSpan(
                                text: widget.userInput,
                                style: poppinsSemiBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeLarge),
                              ),
                            ]),
                          ),
                          const SizedBox(height: 50),
                          if (AppMode.demo == AppConstants.appMode && !isFirebaseOTP)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                                border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, size: 18, color: Theme.of(context).primaryColor),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      getTranslated('for_demo_purpose_use', context),
                                      style: poppinsRegular.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          PinCodeTextField(
                            controller: inputPinTextController,
                            length: 6,
                            appContext: context,
                            obscureText: false,
                            enabled: true,
                            keyboardType: TextInputType.number,
                            animationType: AnimationType.fade,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              fieldHeight: 55,
                              fieldWidth: 45,
                              borderWidth: 1,
                              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                              selectedColor: Theme.of(context).primaryColor,
                              selectedFillColor: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                              inactiveFillColor: Theme.of(context).cardColor,
                              inactiveColor: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                              activeColor: Theme.of(context).primaryColor,
                              activeFillColor: Theme.of(context).cardColor,
                            ),
                            animationDuration: const Duration(milliseconds: 300),
                            backgroundColor: Colors.transparent,
                            enableActiveFill: true,
                            onChanged: (query) => verificationProvider.updateVerificationCode(query, 6),
                          ),
                          const SizedBox(height: 40),
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              int? minutes, seconds;
                              Duration duration = Duration(seconds: verificationProvider.currentTime ?? 0);
                              minutes = duration.inMinutes % 60;
                              seconds = duration.inSeconds % 60;
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        getTranslated('did_not_receive_the_code', context),
                                        style: poppinsRegular.copyWith(color: Theme.of(context).disabledColor),
                                      ),
                                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                      verificationProvider.resendLoadingStatus ? const SizedBox(
                                        width: 15, height: 15,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ) : TextButton(
                                        onPressed: verificationProvider.currentTime! > 0 ? null : () async {
                                          if (widget.fromPage != FromPage.forget.name) {
                                            await verificationProvider.sendVerificationCode(
                                              context, config!, userInput,
                                              type: isPhone ? VerificationType.phone.name : VerificationType.email.name,
                                              fromPage: widget.fromPage
                                            );
                                          } else {
                                            bool isNumber = EmailCheckerHelper.isNotValid(userInput);
                                            if (isNumber && isFirebaseOTP) {
                                              verificationProvider.firebaseVerifyPhoneNumber(context, userInput, widget.fromPage, isForgetPassword: true);
                                            } else {
                                              await authProvider.forgetPassword(userInput, isNumber ? VerificationType.phone.name : VerificationType.email.name).then((value) {
                                                verificationProvider.startVerifyTimer();
                                                if (value.isSuccess) {
                                                  showCustomSnackBarHelper(getTranslated('resend_code_successful', Get.context!), isError: false);
                                                } else {
                                                  showCustomSnackBarHelper(value.message!);
                                                }
                                              });
                                            }
                                          }
                                        },
                                        child: Text(
                                          (verificationProvider.currentTime != null && verificationProvider.currentTime! > 0)
                                              ? '$minutes:${seconds.toString().padLeft(2, '0')}'
                                              : getTranslated('resend_it', context),
                                          style: poppinsSemiBold.copyWith(
                                            color: verificationProvider.currentTime! > 0 ? Theme.of(context).disabledColor : Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30),
                                  (verificationProvider.isEnableVerificationCode && !verificationProvider.resendLoadingStatus) ? SizedBox(
                                    width: double.infinity,
                                    child: CustomButtonWidget(
                                      isLoading: verificationProvider.isLoading || (isFirebaseOTP && authProvider.isLoading),
                                      buttonText: getTranslated('verify', context),
                                      borderRadius: 50,
                                      onPressed: () {
                                        if (widget.fromPage == FromPage.otp.name) {
                                          if (isPhone && AuthHelper.isFirebaseVerificationEnable(config)) {
                                            authProvider.firebaseOtpLogin(
                                              phoneNumber: widget.userInput,
                                              session: '${widget.session}',
                                              otp: verificationProvider.verificationCode,
                                            );
                                          } else if (isPhone && AuthHelper.isPhoneVerificationEnable(config)) {
                                            verificationProvider.verifyPhoneForOtp(userInput).then((value) {
                                              final (responseModel, tempToken) = value;
                                              if ((responseModel != null && responseModel.isSuccess) && tempToken == null) {
                                                if (authProvider.isActiveRememberMe) {
                                                  String userCountryCode = PhoneNumberCheckerHelper.getCountryCode(userInput)!;
                                                  authProvider.saveUserNumberAndPassword(UserLogData(
                                                    countryCode: userCountryCode,
                                                    phoneNumber: PhoneNumberCheckerHelper.getPhoneNumber(userInput, userCountryCode),
                                                    email: null,
                                                    password: null,
                                                    loginType: FromPage.otp.name,
                                                  ));
                                                } else {
                                                  authProvider.clearUserLogData();
                                                }
                                                Navigator.pushNamedAndRemoveUntil(Get.context!, RouteHelper.getMainRoute(), (route) => false);
                                              } else if ((responseModel != null && responseModel.isSuccess) && tempToken != null) {
                                                Navigator.pushReplacementNamed(Get.context!, RouteHelper.getOtpRegistration(tempToken, userInput));
                                              }
                                            });
                                          }
                                        } else if (widget.fromPage == FromPage.login.name) {
                                          if (AuthHelper.isCustomerVerificationEnable(config)) {
                                            if (isPhone && isFirebaseOTP) {
                                              authProvider.firebaseOtpLogin(
                                                phoneNumber: userInput,
                                                session: '${widget.session}',
                                                otp: verificationProvider.verificationCode,
                                              );
                                            } else if (isPhone && AuthHelper.isPhoneVerificationEnable(config)) {
                                              verificationProvider.verifyPhone(userInput.trim()).then((value) {
                                                if (value.isSuccess) {
                                                  if (authProvider.isActiveRememberMe) {
                                                    String userCountryCode = PhoneNumberCheckerHelper.getCountryCode(userInput)!;
                                                    authProvider.saveUserNumberAndPassword(UserLogData(
                                                      countryCode: userCountryCode,
                                                      phoneNumber: PhoneNumberCheckerHelper.getPhoneNumber(userInput, userCountryCode),
                                                      email: null,
                                                      password: null,
                                                      loginType: FromPage.login.name,
                                                    ));
                                                  } else {
                                                    authProvider.clearUserLogData();
                                                  }
                                                  Navigator.pushNamedAndRemoveUntil(Get.context!, RouteHelper.getMainRoute(), (route) => false);
                                                }
                                              });
                                            } else if (!isPhone && AuthHelper.isEmailVerificationEnable(config)) {
                                              verificationProvider.verifyEmail(userInput).then((value) {
                                                if (value.isSuccess) {
                                                  if (authProvider.isActiveRememberMe) {
                                                    authProvider.saveUserNumberAndPassword(UserLogData(
                                                      countryCode: null,
                                                      phoneNumber: null,
                                                      email: userInput,
                                                      password: null,
                                                      loginType: FromPage.login.name,
                                                    ));
                                                  }
                                                  Navigator.pushNamedAndRemoveUntil(Get.context!, RouteHelper.getMainRoute(), (route) => false);
                                                }
                                              });
                                            }
                                          }
                                        } else if (widget.fromPage == FromPage.profile.name) {
                                          String type = isPhone ? 'phone' : 'email';
                                          verificationProvider.verifyProfileInfo(userInput, type, widget.session).then((value) {
                                            if (value.isSuccess) {
                                              Navigator.pushReplacementNamed(Get.context!, RouteHelper.getProfileEditRoute());
                                            }
                                          });
                                        } else {
                                          if (isFirebaseOTP && isPhone) {
                                            authProvider.firebaseOtpLogin(
                                              phoneNumber: userInput,
                                              session: '${widget.session}',
                                              otp: verificationProvider.verificationCode,
                                              isForgetPassword: true,
                                            );
                                          } else {
                                            verificationProvider.verifyToken(widget.userInput).then((value) {
                                              if (value.isSuccess) {
                                                Navigator.of(Get.context!).pushReplacementNamed(RouteHelper.getNewPassRoute(widget.userInput, verificationProvider.verificationCode));
                                              } else {
                                                showCustomSnackBarHelper(value.message!);
                                              }
                                            });
                                          }
                                        }
                                      },
                                    ),
                                  ) : const SizedBox.shrink(),
                                  const SizedBox(height: 48),
                                ],
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const FooterWebWidget(footerType: FooterType.sliver),
          ],
        ),
      ),
    );
  }
}
