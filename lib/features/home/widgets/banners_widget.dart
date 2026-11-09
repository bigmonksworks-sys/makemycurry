import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/category/domain/models/category_model.dart';
import 'package:flutter_grocery/common/models/product_model.dart';
import 'package:flutter_grocery/features/home/domain/models/banner_model.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/home/providers/banner_provider.dart';
import 'package:flutter_grocery/features/category/providers/category_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class BannersWidget extends StatefulWidget {
  final bool isSecondary;
  final bool isReverse;
  const BannersWidget({super.key, this.isSecondary = false, this.isReverse = false});

  @override
  State<BannersWidget> createState() => _BannersWidgetState();
}

class _BannersWidgetState extends State<BannersWidget> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return Consumer<BannerProvider>(
      builder: (context, bannerProvider, child) {
        final rawBanners = bannerProvider.bannerList;
        if (rawBanners == null || rawBanners.isEmpty) {
          return const SizedBox();
        }

        // If secondary banner section and there are fewer than 2 banners, don't show duplicate
        if ((widget.isSecondary || widget.isReverse) && rawBanners.length < 2) {
          return const SizedBox();
        }

        List<BannerModel> bannerList = rawBanners;
        if ((widget.isSecondary || widget.isReverse) && rawBanners.length >= 2) {
          // Shift the list by half its length so the two banner sections never play the same banner at the same time
          final int shift = (rawBanners.length / 2).ceil();
          bannerList = [
            ...rawBanners.sublist(shift),
            ...rawBanners.sublist(0, shift),
          ];
        }

        return Column(
          children: [
            Container(
              width: Dimensions.webScreenWidth,
              height: ResponsiveHelper.isDesktop(context) ? 210 : size.width * 0.49,
              padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.only(top: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeSmall) : null,
              child: bannerList.isNotEmpty ? Stack(
                fit: StackFit.expand,
                children: [
                  CarouselSlider.builder(
                    options: CarouselOptions(
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: ResponsiveHelper.isDesktop(context) ? 0.33 : 1,
                      enlargeFactor: 0,
                      disableCenter: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                    itemCount: bannerList.length,
                    itemBuilder: (context, index, _) {
                      return InkWell(
                        hoverColor: Colors.transparent,
                        onTap: () {
                          if(bannerList[index].productId != null) {
                            Product? product;
                            for(Product prod in bannerProvider.productList) {
                              if(prod.id == bannerList[index].productId) {
                                product = prod;
                                break;
                              }
                            }
                            if(product != null) {
                              Navigator.pushNamed(
                                context, RouteHelper.getProductDetailsRoute(productId: product.id),
                              );
                            }

                          }else if(bannerList[index].categoryId != null) {
                            CategoryModel? category;
                            for(CategoryModel categoryModel in Provider.of<CategoryProvider>(context, listen: false).categoryList!) {
                              if(categoryModel.id == bannerList[index].categoryId) {
                                category = categoryModel;
                                break;
                              }
                            }
                            if(category != null) {
                              Navigator.of(context).pushNamed(RouteHelper.getCategoryProductsRoute(categoryId: '${category.id}'));
                            }
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CustomImageWidget(
                              height: ResponsiveHelper.isDesktop(context) ? 210 : size.width * 0.5,
                              width: ResponsiveHelper.isDesktop(context) ? 400 : size.width,
                              placeholder: Images.placeHolder,
                              image: '${Provider.of<SplashProvider>(context,listen: false).baseUrls!.bannerImageUrl}'
                                  '/${bannerList[index].image}',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                 if(!ResponsiveHelper.isDesktop(context)) Positioned(
                    bottom: 5, left: 0, right: 0,
                    child: BannerIndicatorView(bannerList: bannerList, currentIndex: _currentIndex),
                  ),
                ]) : Center(child: Text(getTranslated('no_banner_available', context))),
            ),

            if(ResponsiveHelper.isDesktop(context)) Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: BannerIndicatorView(bannerList: bannerList, currentIndex: _currentIndex),
            ),
          ],
        );
      },
    );
  }
}

class BannerShimmer extends StatelessWidget {
  const BannerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      enabled: true,
      child: Container(margin: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).shadowColor,
      )),
    );
  }
}

class BannerIndicatorView extends StatelessWidget {
  final List<BannerModel> bannerList;
  final int currentIndex;
  const BannerIndicatorView({super.key, required this.bannerList, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(bannerList.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 5, width: 10,
          decoration: BoxDecoration(
            color: index == currentIndex
                ? Theme.of(context).primaryColor
                : Theme.of(context).primaryColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault)
          ),
        );
      }),
    );
  }
}
