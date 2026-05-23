import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/chat/providers/chat_provider.dart';
import 'package:flutter_grocery/features/profile/providers/profile_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/common/widgets/not_login_widget.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_grocery/features/chat/widgets/message_bubble_widget.dart';
import 'package:flutter_grocery/features/chat/widgets/message_bubble_shimmer_widget.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String orderId;
  final String userName;
  final String senderType;
  final String profileImage;
  final bool isAppBar;
  const ChatScreen(
      {super.key,
      required this.orderId,
      this.isAppBar = false,
      required this.userName,
      required this.senderType,
      required this.profileImage});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputMessageController = TextEditingController();
  late bool _isLoggedIn;
  bool _isFirst = true;

  var androidInitialize =
      const AndroidInitializationSettings('notification_icon');
  var iOSInitialize = const DarwinInitializationSettings();

  @override
  void initState() {
    super.initState();

    final ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: false);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (!kIsWeb) {
        chatProvider.getMessages(1, widget.orderId, false, widget.senderType);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      chatProvider.getMessages(1, widget.orderId, false, widget.senderType);
    });

    _isLoggedIn =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();

    if (_isLoggedIn) {
      if (_isFirst) {
        chatProvider.getMessages(1, widget.orderId, true, widget.senderType);
      } else {
        chatProvider.getMessages(1, widget.orderId, false, widget.senderType);
        _isFirst = false;
      }

      Provider.of<ProfileProvider>(context, listen: false).getUserInfo(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider =
        Provider.of<SplashProvider>(context, listen: false);
    final bool isAdmin = widget.senderType == "admin";

    return PopScope(
      canPop: ResponsiveHelper.isWeb() ? true : false,
      onPopInvokedWithResult: (bool didPop, _) {
        if (didPop) return;

        if (Navigator.canPop(context) && !ResponsiveHelper.isDesktop(context)) {
          Navigator.pop(context);
          return;
        } else if (!didPop && !Navigator.canPop(context)) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(RouteHelper.menu, (route) => false);
          splashProvider.setPageIndex(0);
          return;
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: ResponsiveHelper.isDesktop(context)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
            : ResponsiveHelper.isMobilePhone() && isAdmin && !widget.isAppBar
                ? null
                : AppBar(
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () {
                        if (!Navigator.canPop(context)) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              RouteHelper.menu, (route) => false);
                          splashProvider.setPageIndex(0);
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    title: Text(
                      isAdmin
                          ? '${Provider.of<SplashProvider>(context, listen: false).configModel!.ecommerceName}'
                          : widget.userName,
                      style: poppinsSemiBold.copyWith(
                          color: Colors.white, fontSize: 18),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    centerTitle: false,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Center(
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  width: 1.5,
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: CustomImageWidget(
                                fit: BoxFit.cover,
                                placeholder: isAdmin
                                    ? Images.appLogo
                                    : Images.profilePlaceholder,
                                image: isAdmin
                                    ? ''
                                    : '${splashProvider.baseUrls?.deliveryManImageUrl}/${widget.profileImage}',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
        body: _isLoggedIn
            ? Center(
                child: SizedBox(
                width: ResponsiveHelper.isDesktop(context)
                    ? Dimensions.webScreenWidth
                    : MediaQuery.of(context).size.width,
                child: Column(children: [
                  Consumer<ChatProvider>(
                      builder: (context, chatProvider, child) {
                    return chatProvider.messageList == null
                        ? Expanded(
                            child: ListView.builder(
                            reverse: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: 15,
                            itemBuilder: (context, index) =>
                                MessageBubbleShimmerWidget(isMe: index.isOdd),
                          ))
                        : Expanded(
                            child: ListView.builder(
                              reverse: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: chatProvider.messageList!.length,
                              itemBuilder: (context, index) {
                                return MessageBubbleWidget(
                                    messages: chatProvider.messageList![index],
                                    isAdmin: isAdmin);
                              },
                            ),
                          );
                  }),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.isDesktop(context)
                          ? 0
                          : Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Consumer<ChatProvider>(
                              builder: (context, chatProvider, _) {
                            return (chatProvider.chatImage?.isNotEmpty ?? false)
                                ? Container(
                                    height: 100,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: Dimensions.paddingSizeSmall),
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: chatProvider.chatImage!.length,
                                      itemBuilder:
                                          (BuildContext context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Stack(
                                            children: [
                                              Container(
                                                width: 80,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .cardColor,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  border: Border.all(
                                                      color: Theme.of(context)
                                                          .primaryColor
                                                          .withOpacity(0.2)),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  child: ResponsiveHelper
                                                          .isWeb()
                                                      ? Image.network(
                                                          chatProvider
                                                              .chatImage![index]
                                                              .path,
                                                          fit: BoxFit.cover)
                                                      : Image.file(
                                                          File(chatProvider
                                                              .chatImage![index]
                                                              .path),
                                                          fit: BoxFit.cover),
                                                ),
                                              ),
                                              Positioned(
                                                top: 2,
                                                right: 2,
                                                child: InkWell(
                                                  onTap: () => chatProvider
                                                      .removeImage(index),
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color:
                                                                Colors.black12,
                                                            blurRadius: 4)
                                                      ],
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: const Icon(
                                                        Icons.close,
                                                        color: Colors.red,
                                                        size: 12),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : const SizedBox();
                          }),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.03),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                // Image Picker Button
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => Provider.of<ChatProvider>(
                                            context,
                                            listen: false)
                                        .onPickImage(false),
                                    borderRadius: BorderRadius.circular(50),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Image.asset(Images.image,
                                          width: 22,
                                          height: 22,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.7)),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 4),

                                // Message Input Field
                                Expanded(
                                  child: TextField(
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(
                                          Dimensions.messageInputLength)
                                    ],
                                    controller: _inputMessageController,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    style: poppinsRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault),
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 5,
                                    minLines: 1,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText:
                                          getTranslated('type_here', context),
                                      hintStyle: poppinsRegular.copyWith(
                                          color: Theme.of(context)
                                              .hintColor
                                              .withOpacity(0.6),
                                          fontSize: Dimensions.fontSizeDefault),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 8),
                                    ),
                                    onChanged: (String newText) {
                                      final chatProvider =
                                          Provider.of<ChatProvider>(context,
                                              listen: false);
                                      if (newText.trim().isNotEmpty &&
                                          !chatProvider.isSendButtonActive) {
                                        chatProvider
                                            .onChangeSendButtonActivity();
                                      } else if (newText.trim().isEmpty &&
                                          chatProvider.isSendButtonActive) {
                                        chatProvider
                                            .onChangeSendButtonActivity();
                                      }
                                    },
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Send Button
                                Consumer<ChatProvider>(
                                    builder: (context, chatProvider, _) {
                                  final bool isActive =
                                      chatProvider.isSendButtonActive;
                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () async {
                                        if (isActive) {
                                          chatProvider.sendMessage(
                                            _inputMessageController.text,
                                            context,
                                            Provider.of<AuthProvider>(context,
                                                    listen: false)
                                                .getUserToken(),
                                            widget.orderId,
                                            widget.senderType,
                                          );
                                          _inputMessageController.clear();
                                          chatProvider
                                              .onChangeSendButtonActivity();
                                        } else {
                                          showCustomSnackBarHelper(
                                              getTranslated(
                                                  'write_somethings', context));
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(50),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? Theme.of(context).primaryColor
                                              : Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: chatProvider.isLoading
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2))
                                            : Icon(Icons.send_rounded,
                                                color: isActive
                                                    ? Colors.white
                                                    : Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(0.5),
                                                size: 22),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (ResponsiveHelper.isDesktop(context)) ...[
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ],
                ]),
              ))
            : const NotLoggedInWidget(),
      ),
    );
  }
}
