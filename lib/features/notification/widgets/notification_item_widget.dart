import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:flutter_grocery/features/notification/domain/models/notification_model.dart';
import 'package:flutter_grocery/features/notification/widgets/notification_dialog_widget.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/date_converter_helper.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class NotificationItemWidget extends StatelessWidget {
  const NotificationItemWidget({
    super.key,
    required this.notification,
    required this.isTitle,
  });

  final NotificationModel notification;
  final bool isTitle;

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isTitle) ...[
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 12, left: 4),
            child: Text(
              DateConverterHelper.isoStringToLocalDateOnly(notification.createdAt!).toUpperCase(),
              style: poppinsSemiBold.copyWith(
                fontSize: 10,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
        
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => NotificationDialogWidget(notificationModel: notification),
            );
          },
          splashColor: Theme.of(context).primaryColor.withValues(alpha: 0.05),
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Minimalist Icon/Image Container
                Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomImageWidget(
                      placeholder: Images.placeHolder,
                      image: '${splashProvider.baseUrls?.notificationImageUrl}/${notification.image}',
                      height: 54,
                      width: 54,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Content Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title ?? '',
                        style: poppinsSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.description ?? '',
                        style: poppinsRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Subtle arrow indicator
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Icon(
                    Icons.arrow_forward_ios, 
                    size: 12, 
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Very subtle, partial divider
        Padding(
          padding: const EdgeInsets.only(left: 70),
          child: Divider(
            height: 1,
            thickness: 0.5,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }
}
