import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/footer_web_widget.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_grocery/features/product/widgets/details_app_bar_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ResponsiveHelper.isDesktop(context)
          ? const PreferredSize(
              preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
          : const DetailsAppBarWidget(),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
            child: Center(
                child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    child: SizedBox(
                      width: width > 700 ? 700 : width,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                height: 250,
                                width: width * 0.85,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned(
                                      top: -10,
                                      right: -10,
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.08),
                                      ),
                                    ),
                                    Image.asset(Images.support,
                                        height: 180, fit: BoxFit.contain),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            Text(
                              getTranslated('how_can_we_help_you', context) ??
                                  'How can we help you?',
                              style: poppinsSemiBold.copyWith(
                                  fontSize: 24,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.color),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              getTranslated('support_description', context) ??
                                  'Our team is here to support you with any questions or concerns.',
                              style: poppinsRegular.copyWith(
                                  color: Theme.of(context).hintColor),
                            ),
                            const SizedBox(height: 30),

                            // Contact Cards
                            _buildContactCard(
                              context,
                              icon: Icons.location_on_rounded,
                              title: getTranslated('store_address', context),
                              content: Provider.of<SplashProvider>(context,
                                          listen: false)
                                      .configModel!
                                      .ecommerceAddress ??
                                  'no address',
                              onTap: () {},
                            ),
                            const SizedBox(height: 16),

                            _buildContactCard(
                              context,
                              icon: Icons.phone_in_talk_rounded,
                              title: getTranslated('call_now', context),
                              content: Provider.of<SplashProvider>(context,
                                          listen: false)
                                      .configModel!
                                      .ecommercePhone ??
                                  '',
                              onTap: () => launchUrlString(
                                  'tel:${Provider.of<SplashProvider>(context, listen: false).configModel!.ecommercePhone}'),
                              actionLabel:
                                  getTranslated('call', context) ?? 'Call',
                            ),
                            const SizedBox(height: 16),

                            _buildContactCard(
                              context,
                              icon: Icons.chat_bubble_rounded,
                              title: getTranslated('send_a_message', context),
                              content: getTranslated(
                                      'chat_with_our_team', context) ??
                                  'Chat with our support team',
                              onTap: () {
                                Navigator.pushNamed(
                                    context,
                                    RouteHelper.getChatRoute(
                                        orderId: "",
                                        senderType: "admin",
                                        userName: "",
                                        profileImage: ""));
                              },
                              actionLabel:
                                  getTranslated('chat', context) ?? 'Chat',
                            ),
                            const SizedBox(height: 16),

                            // WhatsApp Card
                            _buildContactCard(
                              context,
                              imageIcon: Images.whatsapp,
                              title: 'WhatsApp Support',
                              content: 'Instant support on WhatsApp',
                              onTap: () => launchUrlString(
                                  'https://wa.me/${Provider.of<SplashProvider>(context, listen: false).configModel!.ecommercePhone}',
                                  mode: LaunchMode.externalApplication),
                              actionLabel: 'Open',
                            ),

                            const SizedBox(height: 40),
                          ]),
                    )))),
        const FooterWebWidget(footerType: FooterType.sliver),
      ]),
    );
  }

  Widget _buildContactCard(BuildContext context,
      {IconData? icon,
      String? imageIcon,
      required String title,
      required String content,
      required VoidCallback onTap,
      String? actionLabel}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: imageIcon != null
                  ? Image.asset(imageIcon, width: 24, height: 24)
                  : Icon(icon, color: Theme.of(context).primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: poppinsMedium.copyWith(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(content,
                      style: poppinsRegular.copyWith(
                          fontSize: 14, color: Theme.of(context).hintColor)),
                ],
              ),
            ),
            if (actionLabel != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  actionLabel,
                  style:
                      poppinsMedium.copyWith(color: Colors.white, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
