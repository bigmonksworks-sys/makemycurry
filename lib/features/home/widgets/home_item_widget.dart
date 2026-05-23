import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/product_model.dart';
import 'package:flutter_grocery/common/widgets/custom_slider_list_widget.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/features/home/providers/flash_deal_provider.dart';
import 'package:flutter_grocery/common/providers/product_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/common/widgets/web_product_shimmer_widget.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:flutter_grocery/helper/price_converter_helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_grocery/common/models/cart_model.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/common/widgets/wish_button_widget.dart';
class HomeItemWidget extends StatefulWidget {
  final List<Product>? productList;
  final bool isFlashDeal;
  final bool isFeaturedItem;
  final bool isMostReviewed;

  const HomeItemWidget({super.key, this.productList, this.isFlashDeal = false, this.isFeaturedItem = false, this.isMostReviewed = false});

  @override
  State<HomeItemWidget> createState() => _HomeItemWidgetState();
}

class _HomeItemWidgetState extends State<HomeItemWidget> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer<FlashDealProvider>(builder: (context, flashDealProvider, child) {
        return Consumer<ProductProvider>(builder: (context, productProvider, child) {
          return widget.productList != null ? Column(children: [
              widget.isFlashDeal ? SizedBox(
              height: 250,
              child: CarouselSlider.builder(
                itemCount: widget.productList!.length,
                options: CarouselOptions(
                  height: 250,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  viewportFraction: ResponsiveHelper.isDesktop(context) ? 0.2 : 0.6,
                  enlargeFactor: 0.2,
                  onPageChanged: (index, reason) {
                    flashDealProvider.setCurrentIndex(index);
                  },
                ),
                itemBuilder: (context, index, realIndex) {
                  return _CustomProductCard(
                    product: widget.productList![index],
                  );
                },
              )) :
               SizedBox(
                height: (widget.isFeaturedItem || widget.isMostReviewed) ? 260 : 220,
                child: CustomSliderListWidget(
                  controller: scrollController,
                  verticalPosition: (widget.isFeaturedItem || widget.isMostReviewed) ? 50 : 60,
                  isShowForwardButton: (widget.productList?.length ?? 0) > 3,
                  child: ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeSmall),
                    itemCount: widget.productList?.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      double itemWidth = 164.0;
                      if (widget.isFeaturedItem) {
                        itemWidth = ResponsiveHelper.isDesktop(context) ?  370 : MediaQuery.of(context).size.width * 0.90;
                      } else if (widget.isMostReviewed) {
                        itemWidth = ResponsiveHelper.isDesktop(context) ? 300 : MediaQuery.of(context).size.width * 0.70;
                      }

                      return Container(
                        width: itemWidth,
                        padding: const EdgeInsets.all(5),
                        child: widget.isFeaturedItem 
                          ? _FeaturedProductCard(
                              product: widget.productList![index],
                            )
                          : widget.isMostReviewed 
                              ? _MostReviewedProductCard(product: widget.productList![index])
                              : _CustomProductCard(
                                  product: widget.productList![index],
                                ),
                      );
                      },
                  ),
                ),
              ),
          ]) : SizedBox(
            height: 200,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              itemCount: 10,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                  width: 195,
                  padding: const EdgeInsets.all(5),
                  child: const WebProductShimmerWidget(isEnabled: true),
                );
              },
            ),
          );
        });
      }
    );
  }
}

class _CustomProductCard extends StatelessWidget {
  final Product product;
  const _CustomProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
    double priceWithDiscount = PriceConverterHelper.convertWithDiscount(product.price, product.discount, product.discountType) ?? (product.price ?? 0);
    double categoryDiscountAmount = 0;
    if(product.categoryDiscount != null) {
      categoryDiscountAmount = PriceConverterHelper.convertWithDiscount(
        product.price, product.categoryDiscount?.discountAmount, product.categoryDiscount?.discountType,
        maxDiscount: product.categoryDiscount?.maximumAmount,
      ) ?? 0;
    }
    if(categoryDiscountAmount > 0 && categoryDiscountAmount < priceWithDiscount) {
      priceWithDiscount = categoryDiscountAmount;
    }

    String rating = product.rating != null && product.rating!.isNotEmpty ? product.rating![0].average!.toStringAsFixed(1) : '4.5';

    return InkWell(
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        Navigator.of(context).pushNamed(RouteHelper.getProductDetailsRoute(
          productId: product.id, formSearch: false,
        ));
      },
      child: SizedBox(
        width: 154,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context).cardColor,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CustomImageWidget(
                      image: '${splashProvider.baseUrls?.productImageUrl}/${product.image?.isNotEmpty == true ? product.image![0] : ''}',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (product.discount != null && product.discount! > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF05C33), // Orange color from design
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.stars, color: Colors.white, size: 10),
                          const SizedBox(width: 3),
                          Text(
                            product.discountType == 'percent' ? '${product.discount}% Off' : '${PriceConverterHelper.convertPrice(context, product.discount)} Off',
                            style: poppinsMedium.copyWith(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  bottom: -10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00A250), // Green rating badge
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          rating,
                          style: poppinsSemiBold.copyWith(color: Colors.white, fontSize: 10),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.star, color: Colors.white, size: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18), // extra space for rating badge overlapping
            _buildTitle(product.name ?? ''),
            const SizedBox(height: 2),
            RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: PriceConverterHelper.convertPrice(context, priceWithDiscount),
                    style: poppinsSemiBold.copyWith(fontSize: 14, color: Colors.black),
                  ),
                  TextSpan(
                    text: '/${product.unit}',
                    style: poppinsRegular.copyWith(fontSize: 12, color: const Color(0xFF888888)),
                  ),
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String name) {
    int startIndex = name.indexOf('(');
    if (startIndex != -1) {
      String englishName = name.substring(0, startIndex).trim();
      String localName = name.substring(startIndex).trim();
      return RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          text: englishName,
          style: poppinsSemiBold.copyWith(fontSize: 14, color: Colors.black),
          children: [
            TextSpan(
              text: ' $localName',
              style: poppinsMedium.copyWith(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
      );
    } else {
      return Text(
        name,
        style: poppinsSemiBold.copyWith(fontSize: 14, color: Colors.black),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
  }
}

class _FeaturedProductCard extends StatelessWidget {
  final Product product;
  const _FeaturedProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
    double priceWithDiscount = PriceConverterHelper.convertWithDiscount(product.price, product.discount, product.discountType) ?? (product.price ?? 0);
    double categoryDiscountAmount = 0;
    if(product.categoryDiscount != null) {
      categoryDiscountAmount = PriceConverterHelper.convertWithDiscount(
        product.price, product.categoryDiscount?.discountAmount, product.categoryDiscount?.discountType,
        maxDiscount: product.categoryDiscount?.maximumAmount,
      ) ?? 0;
    }
    if(categoryDiscountAmount > 0 && categoryDiscountAmount < priceWithDiscount) {
      priceWithDiscount = categoryDiscountAmount;
    }

    String rating = product.rating != null && product.rating!.isNotEmpty ? product.rating![0].average!.toStringAsFixed(1) : '4.5';

    return InkWell(
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        Navigator.of(context).pushNamed(RouteHelper.getProductDetailsRoute(
          productId: product.id, formSearch: false,
        ));
      },
      child: SizedBox(
        width: ResponsiveHelper.isDesktop(context) ? 370 : MediaQuery.of(context).size.width * 0.90,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context).cardColor,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CustomImageWidget(
                      image: '${splashProvider.baseUrls?.productImageUrl}/${product.image?.isNotEmpty == true ? product.image![0] : ''}',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (product.discount != null && product.discount! > 0)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF05C33), // Orange color from design
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.stars, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            product.discountType == 'percent' ? '${product.discount}% Off' : '${PriceConverterHelper.convertPrice(context, product.discount)} Off',
                            style: poppinsMedium.copyWith(color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: WishButtonWidget(
                    product: product, 
                    edgeInset: const EdgeInsets.all(5),
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle(product.name ?? ''),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            PriceConverterHelper.convertPrice(context, priceWithDiscount),
                            style: poppinsSemiBold.copyWith(fontSize: 16, color: Colors.black),
                          ),
                          Text(
                            '/${product.unit}',
                            style: poppinsRegular.copyWith(fontSize: 12, color: const Color(0xFF888888)),
                          ),
                          const SizedBox(width: 8),
                          if (product.discount != null && product.discount! > 0)
                            Text(
                              PriceConverterHelper.convertPrice(context, product.price),
                              style: poppinsRegular.copyWith(fontSize: 12, color: const Color(0xFF888888), decoration: TextDecoration.lineThrough),
                            ),
                          if (product.discount != null && product.discount! > 0)
                            Text(
                              '/${product.unit}',
                              style: poppinsRegular.copyWith(fontSize: 12, color: const Color(0xFF888888), decoration: TextDecoration.lineThrough),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star_border, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            rating,
                            style: poppinsRegular.copyWith(color: const Color(0xFF888888), fontSize: 12),
                          ),
                          const SizedBox(width: 5),
                          const Text('|', style: TextStyle(color: Color(0xFF888888), fontSize: 12)),
                          const SizedBox(width: 5),
                          const Icon(Icons.timer_outlined, color: Colors.green, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            '15min',
                            style: poppinsRegular.copyWith(color: const Color(0xFF888888), fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                InkWell(
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    double price = product.price ?? 0;
                    if(product.variations != null && product.variations!.isNotEmpty) {
                      price = product.variations![0].price ?? price;
                    }
                    CartModel cartModel = CartModel(
                      product.id, (product.image?.isNotEmpty ?? false) ?  product.image![0] : '',
                      product.name, price,
                      PriceConverterHelper.convertWithDiscount(price, product.discount, product.discountType),
                      1, (product.variations != null && product.variations!.isNotEmpty) ? product.variations![0] : null,
                      (price - PriceConverterHelper.convertWithDiscount(price, product.discount, product.discountType)!),
                      (price - PriceConverterHelper.convertWithDiscount(price, product.tax, product.taxType)!),
                      product.capacity,
                      product.unit,
                      product.totalStock, product,
                    );
                    
                    CartProvider cartProvider = Provider.of<CartProvider>(context, listen: false);
                    bool isExistInCart = cartProvider.isExistInCart(cartModel) != null;
                    
                    if (isExistInCart) {
                      showCustomSnackBarHelper(getTranslated('already_added', context));
                    } else if (product.totalStock != null && product.totalStock! < 1) {
                      showCustomSnackBarHelper(getTranslated('out_of_stock', context));
                    } else {
                      cartProvider.addToCart(cartModel);
                      showCustomSnackBarHelper(getTranslated('added_to_cart', context), isError: false);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF42C6E8), // Cyan button
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String name) {
    int startIndex = name.indexOf('(');
    if (startIndex != -1) {
      String englishName = name.substring(0, startIndex).trim();
      String localName = name.substring(startIndex).trim();
      return RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          text: englishName,
          style: poppinsSemiBold.copyWith(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(
              text: ' $localName',
              style: poppinsMedium.copyWith(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      );
    } else {
      return Text(
        name,
        style: poppinsSemiBold.copyWith(fontSize: 16, color: Colors.black),
        maxLines: 1,
      );
    }
  }
}

class _MostReviewedProductCard extends StatelessWidget {
  final Product product;
  const _MostReviewedProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
    double priceWithDiscount = PriceConverterHelper.convertWithDiscount(product.price, product.discount, product.discountType) ?? (product.price ?? 0);
    double categoryDiscountAmount = 0;
    if(product.categoryDiscount != null) {
      categoryDiscountAmount = PriceConverterHelper.convertWithDiscount(
        product.price, product.categoryDiscount?.discountAmount, product.categoryDiscount?.discountType,
        maxDiscount: product.categoryDiscount?.maximumAmount,
      ) ?? 0;
    }
    if(categoryDiscountAmount > 0 && categoryDiscountAmount < priceWithDiscount) {
      priceWithDiscount = categoryDiscountAmount;
    }

    String rating = product.rating != null && product.rating!.isNotEmpty ? product.rating![0].average!.toStringAsFixed(1) : '4.5';

    return InkWell(
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        Navigator.of(context).pushNamed(RouteHelper.getProductDetailsRoute(
          productId: product.id, formSearch: false,
        ));
      },
      child: SizedBox(
        width: ResponsiveHelper.isDesktop(context) ? 300 : MediaQuery.of(context).size.width * 0.70,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context).cardColor,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CustomImageWidget(
                      image: '${splashProvider.baseUrls?.productImageUrl}/${product.image?.isNotEmpty == true ? product.image![0] : ''}',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (product.discount != null && product.discount! > 0)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF05C33), // Orange color from design
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.stars, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            product.discountType == 'percent' ? '${product.discount}% Off' : '${PriceConverterHelper.convertPrice(context, product.discount)} Off',
                            style: poppinsMedium.copyWith(color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: WishButtonWidget(
                    product: product, 
                    edgeInset: const EdgeInsets.all(5),
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle(product.name ?? ''),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            PriceConverterHelper.convertPrice(context, priceWithDiscount),
                            style: poppinsSemiBold.copyWith(fontSize: 14, color: Colors.black),
                          ),
                          Text(
                            '/${product.unit}',
                            style: poppinsRegular.copyWith(fontSize: 10, color: const Color(0xFF888888)),
                          ),
                          const SizedBox(width: 4),
                          if (product.discount != null && product.discount! > 0)
                            Text(
                              PriceConverterHelper.convertPrice(context, product.price),
                              style: poppinsRegular.copyWith(fontSize: 10, color: const Color(0xFF888888), decoration: TextDecoration.lineThrough),
                            ),
                          if (product.discount != null && product.discount! > 0)
                            Text(
                              '/${product.unit}',
                              style: poppinsRegular.copyWith(fontSize: 10, color: const Color(0xFF888888), decoration: TextDecoration.lineThrough),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star_border, color: Colors.amber, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            rating,
                            style: poppinsRegular.copyWith(color: const Color(0xFF888888), fontSize: 10),
                          ),
                          const SizedBox(width: 5),
                          const Text('|', style: TextStyle(color: Color(0xFF888888), fontSize: 10)),
                          const SizedBox(width: 5),
                          const Icon(Icons.timer_outlined, color: Colors.green, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            '15min',
                            style: poppinsRegular.copyWith(color: const Color(0xFF888888), fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                InkWell(
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    double price = product.price ?? 0;
                    if(product.variations != null && product.variations!.isNotEmpty) {
                      price = product.variations![0].price ?? price;
                    }
                    CartModel cartModel = CartModel(
                      product.id, (product.image?.isNotEmpty ?? false) ?  product.image![0] : '',
                      product.name, price,
                      PriceConverterHelper.convertWithDiscount(price, product.discount, product.discountType),
                      1, (product.variations != null && product.variations!.isNotEmpty) ? product.variations![0] : null,
                      (price - PriceConverterHelper.convertWithDiscount(price, product.discount, product.discountType)!),
                      (price - PriceConverterHelper.convertWithDiscount(price, product.tax, product.taxType)!),
                      product.capacity,
                      product.unit,
                      product.totalStock, product,
                    );
                    
                    CartProvider cartProvider = Provider.of<CartProvider>(context, listen: false);
                    bool isExistInCart = cartProvider.isExistInCart(cartModel) != null;
                    
                    if (isExistInCart) {
                      showCustomSnackBarHelper(getTranslated('already_added', context));
                    } else if (product.totalStock != null && product.totalStock! < 1) {
                      showCustomSnackBarHelper(getTranslated('out_of_stock', context));
                    } else {
                      cartProvider.addToCart(cartModel);
                      showCustomSnackBarHelper(getTranslated('added_to_cart', context), isError: false);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10), // slight size reduction for smaller card
                    decoration: const BoxDecoration(
                      color: Color(0xFF42C6E8), // Cyan button
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String name) {
    int startIndex = name.indexOf('(');
    if (startIndex != -1) {
      String englishName = name.substring(0, startIndex).trim();
      String localName = name.substring(startIndex).trim();
      return RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          text: englishName,
          style: poppinsSemiBold.copyWith(fontSize: 14, color: Colors.black),
          children: [
            TextSpan(
              text: ' $localName',
              style: poppinsMedium.copyWith(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
      );
    } else {
      return Text(
        name,
        style: poppinsSemiBold.copyWith(fontSize: 14, color: Colors.black),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
  }
}
