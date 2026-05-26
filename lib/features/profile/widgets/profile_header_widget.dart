import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:flutter_grocery/features/profile/providers/profile_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);

    return Center(
      child: Consumer<ProfileProvider>(builder: (context, profileProvider, _) {
        final user = profileProvider.userInfoModel;
        final String imagePath = '${splashProvider.baseUrls?.customerImageUrl}/${user?.image}';

        return SizedBox(
          width: Dimensions.webScreenWidth,
          child: ResponsiveHelper.isDesktop(context)
              ? Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Desktop banner with premium gradient
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor.withValues(alpha: 0.65),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                        ),
                        // Desktop profile avatar
                        Positioned(
                          left: 40,
                          bottom: -50,
                          child: Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: ClipOval(
                              child: profileProvider.file == null
                                  ? CustomImageWidget(
                                      placeholder: Images.placeHolder,
                                      fit: BoxFit.cover,
                                      image: imagePath,
                                    )
                                  : Image.file(
                                      profileProvider.file!,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                        // Desktop edit button
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: InkWell(
                            onTap: () => Navigator.pushNamed(context, RouteHelper.getProfileEditRoute()),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  Icon(Icons.edit_rounded, size: 16, color: Theme.of(context).primaryColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    getTranslated('edit', context),
                                    style: poppinsMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 60),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    child: Row(
                      children: [
                        // Mobile Avatar with Edit Overlay Icon
                        Stack(
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: ClipOval(
                                child: profileProvider.file == null
                                    ? CustomImageWidget(
                                        placeholder: Images.placeHolder,
                                        fit: BoxFit.cover,
                                        image: imagePath,
                                      )
                                    : Image.file(
                                        profileProvider.file!,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            // Tiny floating edit button overlay on avatar
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () => Navigator.pushNamed(context, RouteHelper.getProfileEditRoute()),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.camera_alt_rounded,
                                    size: 14,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: Dimensions.paddingSizeLarge),
                        // Mobile details overlay inside card
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${user?.fName ?? ''} ${user?.lName ?? ''}',
                                style: poppinsBold.copyWith(
                                  fontSize: Dimensions.fontSizeExtraLarge,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? '',
                                style: poppinsRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Colors.white70,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Sleek Edit Button Icon on the right
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
                          onPressed: () => Navigator.pushNamed(context, RouteHelper.getProfileEditRoute()),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      }),
    );
  }
}
