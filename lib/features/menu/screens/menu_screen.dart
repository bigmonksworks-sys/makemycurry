import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/custom_asset_image_widget.dart';
import 'package:flutter_grocery/features/menu/domain/models/custom_drawer_controller_model.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/features/address/providers/location_provider.dart';
import 'package:flutter_grocery/features/profile/providers/profile_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:flutter_grocery/features/menu/screens/main_screen.dart';
import 'package:flutter_grocery/features/menu/widgets/sign_out_dialog_widget.dart';
import 'package:flutter_grocery/features/notification/screens/notification_screen.dart';
import 'package:flutter_grocery/features/profile/screens/profile_screen.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatefulWidget {
  final bool isReload;
  const MenuScreen({super.key, this.isReload = true});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final CustomDrawerController _drawerController = CustomDrawerController();

  @override
  void initState() {
    super.initState();
    final bool isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    if(isLoggedIn && widget.isReload) {
      Provider.of<ProfileProvider>(context, listen: false).getUserInfo(true);
      Provider.of<LocationProvider>(context, listen: false).initAddressList();
    } else {
      Provider.of<CartProvider>(context, listen: false).getCartData();
    }
  }

  @override
  Widget build(BuildContext context) {
   return MainScreen(drawerController: _drawerController, isReload: widget.isReload);
  }
}

class MenuWidget extends StatelessWidget {
  const MenuWidget({super.key});

  /// Closes the drawer reliably on both web and mobile.
  ///
  /// Inside a Flutter [Drawer], the widget tree lives in an Overlay, so
  /// [Scaffold.of(context).isDrawerOpen] is unreliable on Flutter web —
  /// it silently returns false, preventing [Navigator.pop] from ever being
  /// called and leaving the drawer stuck open.
  ///
  /// [Navigator.of(context).pop()] is always safe here because the Drawer
  /// itself is pushed as a route on the Navigator stack.
  void _closeDrawer(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final bool isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── Header: Close Button ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black, size: 24),
                    onPressed: () => _closeDrawer(context),
                  ),
                ],
              ),
            ),

            // ── User Profile Section ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Consumer<ProfileProvider>(
                builder: (context, profileProvider, child) => Row(
                  children: [
                    // Avatar
                    InkWell(
                      onTap: () {
                        _closeDrawer(context);
                        Future.microtask(() => Navigator.of(context)
                            .pushNamed(RouteHelper.profile, arguments: const ProfileScreen()));
                      },
                      child: ClipOval(
                        child: isLoggedIn && splashProvider.baseUrls != null
                            ? CustomImageWidget(
                                placeholder: Images.profile,
                                image:
                                    '${splashProvider.baseUrls?.customerImageUrl}/${profileProvider.userInfoModel?.image}',
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(Images.profile, height: 50, width: 50, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 15),

                    // Name / Phone
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _closeDrawer(context);
                          Future.microtask(() => Navigator.of(context)
                              .pushNamed(RouteHelper.profile, arguments: const ProfileScreen()));
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isLoggedIn && profileProvider.userInfoModel != null
                                  ? '${profileProvider.userInfoModel!.fName ?? ''} ${profileProvider.userInfoModel!.lName ?? ''}'
                                  : getTranslated('guest', context),
                              style: poppinsSemiBold.copyWith(fontSize: 16, color: Colors.black),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (isLoggedIn && profileProvider.userInfoModel != null)
                              Text(
                                profileProvider.userInfoModel!.phone ?? '',
                                style: poppinsRegular.copyWith(
                                    fontSize: 12, color: const Color(0xFF666666)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Notification Bell
                    IconButton(
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.notifications_none, color: Colors.black, size: 28),
                          Positioned(
                            top: 2,
                            right: 4,
                            child: Container(
                              height: 8,
                              width: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        _closeDrawer(context);
                        Future.microtask(() => Navigator.pushNamed(
                              context,
                              RouteHelper.notification,
                              arguments: const NotificationScreen(),
                            ));
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Menu Items ────────────────────────────────────────────────
            Expanded(
              child: Consumer<SplashProvider>(
                builder: (context, splash, child) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: splashProvider.screenList.length + 2,
                    itemBuilder: (context, index) {
                      // Screen list items
                      if (index < splashProvider.screenList.length) {
                        final model = splashProvider.screenList[index];
                        final bool isSelected = splash.pageIndex == index;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              splash.setPageIndex(index);
                              _closeDrawer(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 14.0),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFE0F2FE)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  CustomAssetImageWidget(
                                    model.icon,
                                    color: isSelected
                                        ? const Color(0xFF0284C7)
                                        : const Color(0xFF888888),
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 15),
                                  Text(
                                    getTranslated(model.title, context),
                                    style: poppinsMedium.copyWith(
                                      fontSize: 14,
                                      color: isSelected
                                          ? const Color(0xFF0284C7)
                                          : const Color(0xFF555555),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      // Divider
                      if (index == splashProvider.screenList.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Divider(color: Color(0xFFE5E5E5), thickness: 1),
                        );
                      }

                      // Logout / Login row
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, top: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            if (isLoggedIn) {
                              _closeDrawer(context);
                              Future.microtask(() => showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) =>
                                        const SignOutDialogWidget(),
                                  ));
                            } else {
                              _closeDrawer(context);
                              splashProvider.setPageIndex(0);
                              Future.microtask(() =>
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    RouteHelper.getLoginRoute(),
                                    (route) => false,
                                  ));
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 14.0),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                CustomAssetImageWidget(
                                  isLoggedIn ? Images.logOut : Images.logIn,
                                  color: const Color(0xFFFF3B30),
                                  width: 20,
                                  height: 20,
                                ),
                                const SizedBox(width: 15),
                                Text(
                                  getTranslated(
                                      isLoggedIn ? 'log_out' : 'login',
                                      context),
                                  style: poppinsSemiBold.copyWith(
                                    fontSize: 14,
                                    color: const Color(0xFFFF3B30),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}