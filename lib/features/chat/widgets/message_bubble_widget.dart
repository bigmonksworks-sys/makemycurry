import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:flutter_grocery/features/chat/domain/models/chat_model.dart';
import 'package:flutter_grocery/helper/date_converter_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/features/profile/providers/profile_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/features/chat/widgets/image_dialog_widget.dart';
import 'package:provider/provider.dart';

class MessageBubbleWidget extends StatelessWidget {
  final Messages? messages;
  final bool? isAdmin;
  const MessageBubbleWidget({super.key, this.messages, this.isAdmin});
  @override
  Widget build(BuildContext context) {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final bool isMe = isAdmin!
        ? (messages!.isReply == null || !messages!.isReply!)
        : (messages!.deliverymanId == null);

    final String? displayMessage =
        (messages!.message != null && messages!.message!.isNotEmpty)
            ? messages!.message
            : messages!.reply;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault, vertical: 8),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) _buildAvatar(context, messages!, isAdmin!),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (displayMessage != null && displayMessage.isNotEmpty)
                      _buildMessageContainer(context, displayMessage, isMe),
                    if (messages!.attachment != null ||
                        (messages!.image != null &&
                            messages!.image!.isNotEmpty))
                      _buildAttachments(context, messages!),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isMe) _buildUserAvatar(context, profileProvider),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(
              left: isMe ? 0 : 50,
              right: isMe ? 50 : 0,
            ),
            child: Text(
              DateConverterHelper.localDateToIsoStringAMPM(
                  DateTime.parse(messages!.createdAt!), context),
              style: poppinsRegular.copyWith(
                color: Theme.of(context).hintColor.withOpacity(0.6),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, Messages messages, bool isAdmin) {
    final String imageUrl = isAdmin
        ? '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.ecommerceImageUrl}/${Provider.of<SplashProvider>(context, listen: false).configModel!.ecommerceLogo}'
        : '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.deliveryManImageUrl}/${messages.deliverymanId?.image ?? ''}';

    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.1), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: CustomImageWidget(
          image: imageUrl,
          placeholder: isAdmin ? Images.appLogo : Images.profilePlaceholder,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildUserAvatar(
      BuildContext context, ProfileProvider profileProvider) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.1), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: CustomImageWidget(
          image:
              '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.customerImageUrl}/${profileProvider.userInfoModel?.image}',
          placeholder: Images.profilePlaceholder,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildMessageContainer(
      BuildContext context, String message, bool isMe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? Theme.of(context).primaryColor : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isMe ? 20 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message,
        style: poppinsRegular.copyWith(
          color: isMe
              ? Colors.white
              : Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: Dimensions.fontSizeDefault,
        ),
      ),
    );
  }

  Widget _buildAttachments(BuildContext context, Messages messages) {
    final List<String> attachments =
        messages.attachment ?? messages.image ?? [];
    if (attachments.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1,
          crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8 : 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: attachments.length,
        itemBuilder: (context, index) {
          final String imageUrl = attachments[index].contains('http')
              ? attachments[index]
              : '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.chatImageUrl}/${attachments[index]}';

          return InkWell(
            onTap: () => showDialog(
                context: context,
                builder: (ctx) => ImageDialogWidget(imageUrl: imageUrl)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomImageWidget(
                image: imageUrl,
                placeholder: Images.placeHolder,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}
