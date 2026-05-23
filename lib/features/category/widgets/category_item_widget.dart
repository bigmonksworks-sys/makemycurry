import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class CategoryItemWidget extends StatelessWidget {
  final String? title;
  final String? icon;
  final bool isSelected;

  const CategoryItemWidget({super.key, required this.title, required this.icon, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
        color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.08) : Colors.transparent,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 65,
            width: 65,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 1.5) : null,
              color: isSelected ? Colors.transparent : Theme.of(context).cardColor,
              boxShadow: isSelected ? [] : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CustomImageWidget(
                image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.categoryImageUrl}/$icon',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: poppinsMedium.copyWith(
              fontSize: 11,
              height: 1.2,
              color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
