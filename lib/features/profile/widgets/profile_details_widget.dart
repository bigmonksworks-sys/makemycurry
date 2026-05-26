import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/features/profile/providers/profile_provider.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class ProfileDetailsWidget extends StatelessWidget {
  const ProfileDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(builder: (context, profileProvider, _) {
      if (profileProvider.isLoading) {
        return CustomLoaderWidget(color: Theme.of(context).primaryColor);
      }
      final user = profileProvider.userInfoModel;
      if (user == null) return const SizedBox.shrink();

      return Center(
        child: Container(
          width: ResponsiveHelper.isDesktop(context) 
              ? Dimensions.webScreenWidth * 0.7 
              : double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeLarge,
            vertical: Dimensions.paddingSizeSmall,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Title
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: Dimensions.paddingSizeSmall),
                child: Text(
                  getTranslated('personal_info', context) ?? 'Personal Information',
                  style: poppinsSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoTile(
                      context,
                      icon: Icons.person_outline_rounded,
                      label: getTranslated('name', context),
                      value: '${user.fName ?? ''} ${user.lName ?? ''}',
                    ),
                    _buildDivider(context),
                    _buildInfoTile(
                      context,
                      icon: Icons.phone_android_rounded,
                      label: getTranslated('mobile_number', context),
                      value: user.phone ?? '',
                    ),
                    _buildDivider(context),
                    _buildInfoTile(
                      context,
                      icon: Icons.email_outlined,
                      label: getTranslated('email', context),
                      value: user.email ?? '',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoTile(BuildContext context, {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: poppinsRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).hintColor.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: poppinsMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 70,
      endIndent: 20,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
    );
  }
}
