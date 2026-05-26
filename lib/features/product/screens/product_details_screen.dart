import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
import 'package:flutter_grocery/common/models/cart_model.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/common/providers/product_provider.dart';
import 'package:flutter_grocery/common/widgets/custom_button_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_directionality_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_zoom_widget.dart';
import 'package:flutter_grocery/common/widgets/footer_web_widget.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_grocery/common/widgets/wish_button_widget.dart';
import 'package:flutter_grocery/features/product/widgets/details_app_bar_widget.dart';
import 'package:flutter_grocery/features/product/widgets/product_description_widget.dart';
import 'package:flutter_grocery/features/product/widgets/product_image_widget.dart';
import 'package:flutter_grocery/features/product/widgets/product_title_widget.dart';
import 'package:flutter_grocery/features/product/widgets/quantity_button_widget.dart';
import 'package:flutter_grocery/features/product/widgets/selected_product_widget.dart';
import 'package:flutter_grocery/features/product/widgets/variation_widget.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/cart_helper.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/helper/price_converter_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';
import 'package:flutter_grocery/common/models/product_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String? productId;
  final bool? fromSearch;
  const ProductDetailsScreen({super.key, required this.productId, this.fromSearch = false});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>  with TickerProviderStateMixin {
  int _tabIndex = 0;
  bool showSeeMoreButton = true;
  final ScrollController scrollController = ScrollController();
  SubVariant? _selectedSubVariant;

  @override
  void initState() {

    final ProductProvider productProvider = Provider.of(context, listen: false);
    productProvider.getProductDetails('${widget.productId}', searchQuery: widget.fromSearch!);
    Provider.of<CartProvider>(context, listen: false).getCartData();
    Provider.of<CartProvider>(context, listen: false).onSelectProductStatus(0, false);

    productProvider.getProductReviews(id: widget.productId, offset: 1, isUpdate: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBarWidget())  : DetailsAppBarWidget(key: UniqueKey(), title: 'product_details'.tr),

      body: Consumer<CartProvider>(builder: (context, cartProvider, child) {
        return  Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
            double? priceWithQuantity = 0;
            CartModel? cartModel;
            if(productProvider.product != null) {


              cartModel = CartHelper.getCartModel(productProvider.product!, quantity: cartProvider.quantity, variationIndexList: cartProvider.variationIndex, selectedSubVariant: _selectedSubVariant);

              cartProvider.setExistData(cartProvider.isExistInCart(cartModel));

              double? priceWithDiscount = PriceConverterHelper.convertWithDiscount(
                cartModel?.price, productProvider.product?.discount,
                productProvider.product?.discountType,
              );


              if(cartProvider.cartIndex != null) {
                priceWithQuantity = (priceWithDiscount ?? 0) * (cartProvider.cartList[cartProvider.cartIndex!].quantity!);

              }else {
                priceWithQuantity = (priceWithDiscount ?? 0) * cartProvider.quantity;

              }
            }

            return productProvider.product != null ? !ResponsiveHelper.isDesktop(context) ? Column(
              children: [
                Expanded(child: SingleChildScrollView(
                  controller: scrollController,
                  physics: ResponsiveHelper.isMobilePhone() ? const BouncingScrollPhysics() : null,
                  child: Center(
                    child: SizedBox(
                      width: Dimensions.webScreenWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          Column(children: [
                            ProductImageWidget(productModel: productProvider.product, selectedSubVariant: _selectedSubVariant),

                            // SelectedImageWidget has been removed as per the mockup. The ProductImageWidget handles dots.

                            ProductTitleWidget(product: productProvider.product, stock: cartModel?.stock, cartIndex: cartProvider.cartIndex),

                            VariationWidget(product: productProvider.product),
                            _buildSubVariantSelector(productProvider.product!),

                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
                              child: Row(mainAxisAlignment : MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [

                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(getTranslated('total_amount', context), style: poppinsSemiBold.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      color: Colors.black,
                                  )),
                                  const SizedBox(height: Dimensions.paddingSizeSmall),

                                  CustomDirectionalityWidget(child: Text(
                                    PriceConverterHelper.convertPrice(context, priceWithQuantity),
                                    style: poppinsSemiBold.copyWith(
                                      color: Colors.black,
                                      fontSize: 28,
                                    ),
                                  )),
                                ]),
                                SizedBox(height: ResponsiveHelper.isDesktop(context) ? 45 : 0),

                                Builder(
                                    builder: (context) {
                                      return Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(color: Colors.black12, width: 1),
                                          borderRadius: BorderRadius.circular(50),
                                        ),

                                        child: Row(children: [
                                          QuantityButtonWidget(
                                            isIncrement: false, quantity: cartProvider.quantity,
                                            stock: cartModel?.stock, cartIndex: cartProvider.cartIndex,
                                            maxOrderQuantity: productProvider.product!.maximumOrderQuantity,
                                            backgroundColor: Colors.white,
                                            iconColor: Colors.black87,
                                            radius: 50,
                                          ),
                                          const SizedBox(width: 15),

                                          Text(
                                            (cartProvider.cartIndex != null ? cartProvider.cartList[cartProvider.cartIndex!].quantity : cartProvider.quantity).toString().padLeft(2, '0'),
                                            style: poppinsMedium.copyWith(color: Colors.black, fontSize: Dimensions.fontSizeLarge),
                                          ),
                                          const SizedBox(width: 15),

                                          QuantityButtonWidget(
                                            isIncrement: true, quantity: cartProvider.quantity,
                                            stock: cartModel?.stock, cartIndex: cartProvider.cartIndex,
                                            maxOrderQuantity: productProvider.product!.maximumOrderQuantity,
                                            backgroundColor: const Color(0xFF0F1E29),
                                            iconColor: Colors.white,
                                            radius: 50,
                                          ),
                                        ]),
                                      );
                                    }
                                ),

                              ]),
                            ),
                          ]),
                          SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeMaxLarge :  Dimensions.paddingSizeDefault),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                            child: ProductDescriptionWidget(
                              scrollController: scrollController,
                              showSeeMoreButton: showSeeMoreButton,
                              tabIndex: _tabIndex,
                              onTabChange: (int index) {
                                setState(() {
                                  _tabIndex = index;
                                });
                              },
                              onChangeButtonStatus: (bool status) {
                                setState(() {
                                  showSeeMoreButton = status;
                                });
                              },
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                )),

                Center(child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  width: Dimensions.webScreenWidth, 
                  child: CustomButtonWidget(
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    borderColor: Colors.black,
                    borderRadius: 30,
                    margin: Dimensions.paddingSizeSmall,
                    buttonText: getTranslated(
                      cartProvider.cartIndex != null 
                          ? 'already_added' 
                          : (cartModel?.stock ?? 0) <= 0 
                              ? 'out_of_stock' 
                              : 'add_to_card', 
                      context
                    ),
                  onPressed: (cartProvider.cartIndex == null && (cartModel?.stock ?? 0) > 0) ? () {
                    if (cartProvider.cartIndex == null && (cartModel?.stock ?? 0) > 0) {
                      cartProvider.addToCart(cartModel!);


                      showCustomSnackBarHelper(getTranslated('added_to_cart', context), isError: false);

                    } else {
                      showCustomSnackBarHelper(getTranslated('already_added', context));
                    }
                  } : null,
                ))),
              ],
            ) : CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Column(children: [
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Center(
                      child: SizedBox(
                        width: Dimensions.webScreenWidth,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Expanded(flex: 4, child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                                  child: Stack(
                                    children: [
                                      SizedBox(height: 400, width: double.maxFinite, child: CustomZoomWidget(
                                        image: ClipRRect(
                                          borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
                                          child: CustomImageWidget(
                                            image: (_selectedSubVariant != null && _selectedSubVariant!.image != null && _selectedSubVariant!.image!.isNotEmpty)
                                                ? '${splashProvider.baseUrls?.productImageUrl}/${_selectedSubVariant!.image}'
                                                : '${splashProvider.baseUrls?.productImageUrl}/${(productProvider.product?.image?.isNotEmpty ?? false)
                                                    ? productProvider.product!.image![cartProvider.productSelect] : ''}',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )),

                                      Positioned(
                                        top: 10, right: 10,
                                        child: WishButtonWidget(product: productProvider.product, subVariantId: _selectedSubVariant?.id, edgeInset: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall)),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeSmall),

                                SizedBox(
                                  height: 70,
                                  child: productProvider.product!.image != null
                                      ? SelectedImageWidget(productModel: productProvider.product)
                                      : const SizedBox(),
                                ),
                              ],
                            )),
                            const SizedBox(width: 30),

                            Expanded(flex: 6,child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  ProductTitleWidget(product: productProvider.product, stock: cartModel?.stock, cartIndex: cartProvider.cartIndex),

                                  VariationWidget(product: productProvider.product),
                                  _buildSubVariantSelector(productProvider.product!),
                                  SizedBox(height: Dimensions.paddingSizeLarge),

                                  Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                                    Text('${getTranslated('total_amount', context)}:', style: poppinsMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.70),
                                    )),
                                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                    CustomDirectionalityWidget(child: Text(
                                      PriceConverterHelper.convertPrice(context, priceWithQuantity),
                                      style: poppinsBold.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: Dimensions.fontSizeMaxLarge,
                                      ),
                                    )),
                                  ]),
                                  const SizedBox(height: 35),


                                  Row(children: [

                                    Builder(
                                        builder: (context) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).disabledColor.withValues(alpha: 0.05),
                                              borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
                                            ),

                                            child: Row(children: [
                                              QuantityButtonWidget(
                                                isIncrement: false, quantity: cartProvider.quantity,
                                                stock: cartModel?.stock, cartIndex: cartProvider.cartIndex,
                                                maxOrderQuantity: productProvider.product!.maximumOrderQuantity,
                                              ),
                                              const SizedBox(width: 15),

                                              Consumer<CartProvider>(builder: (context, cart, child) {
                                                return Text(cart.cartIndex != null ? cart.cartList[cart.cartIndex!].quantity.toString()
                                                    : cart.quantity.toString(), style: poppinsBold.copyWith(color: Theme.of(context).primaryColor)
                                                );
                                              }),
                                              const SizedBox(width: 15),

                                              QuantityButtonWidget(
                                                isIncrement: true, quantity: cartProvider.quantity,
                                                stock: cartModel?.stock, cartIndex: cartProvider.cartIndex,
                                                maxOrderQuantity: productProvider.product?.maximumOrderQuantity,
                                              ),
                                            ]),
                                          );
                                        }
                                    ),
                                    const SizedBox(width: Dimensions.paddingSizeDefault),

                                    Builder(
                                      builder: (context) => Center(
                                        child: SizedBox(
                                          width: 200,
                                          child: CustomButtonWidget(
                                            icon: Icons.shopping_cart,
                                            buttonText: getTranslated(
                                              cartProvider.cartIndex != null 
                                                  ? 'already_added' 
                                                  : (cartModel?.stock ?? 0) <= 0 
                                                      ? 'out_of_stock' 
                                                      : 'add_to_card', 
                                              context
                                            ),
                                            onPressed: (cartProvider.cartIndex == null && (cartModel?.stock ?? 0) > 0) ? () {
                                              if (cartProvider.cartIndex == null && (cartModel?.stock ?? 0) > 0) {
                                                cartProvider.addToCart(cartModel!);

                                                showCustomSnackBarHelper(getTranslated('added_to_cart', context), isError: false);

                                              } else {
                                                showCustomSnackBarHelper(getTranslated('already_added', context));
                                              }
                                            } : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                                ],
                              ),
                            ))
                          ],
                        ),
                      ),
                    ),
                    //Description
                    const SizedBox(height : Dimensions.paddingSizeExtraLarge),

                    Center(child: SizedBox(width: Dimensions.webScreenWidth, child: ProductDescriptionWidget(
                      scrollController: scrollController,
                      showSeeMoreButton: showSeeMoreButton,
                      tabIndex: _tabIndex,
                      onTabChange: (int index) {
                        setState(() {
                          _tabIndex = index;
                        });
                      },
                      onChangeButtonStatus: (bool status) {
                        setState(() {
                          showSeeMoreButton = status;
                        });
                      },
                    ))),
                    const SizedBox(height: Dimensions.paddingSizeDefault,),
                  ]),
                ),

                const FooterWebWidget(footerType: FooterType.sliver),
              ],
            ) : Center(child: CustomLoaderWidget(color: Theme.of(context).primaryColor));
          },
        );
      }),
    );
  }

  Widget _buildSubVariantSelector(Product product) {
    if (product.subVariants == null || product.subVariants!.isEmpty) {
      return const SizedBox();
    }
    return Padding(
      padding: ResponsiveHelper.isDesktop(context)
          ? const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall)
          : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              getTranslated('select_variant_option', context), 
              style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.black)
            ),
            if (_selectedSubVariant != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedSubVariant = null;
                  });
                },
                child: Text(
                  getTranslated('clear', context),
                  style: poppinsMedium.copyWith(color: Theme.of(context).primaryColor),
                ),
              ),
          ],
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        
        SizedBox(
          height: 245,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: product.subVariants!.length,
            itemBuilder: (context, index) {
              final subVariant = product.subVariants![index];
              bool isSelected = _selectedSubVariant?.id == subVariant.id;
              final String variantImage = (subVariant.image != null && subVariant.image!.isNotEmpty)
                  ? subVariant.image!
                  : ((product.image != null && product.image!.isNotEmpty) ? product.image![0] : '');

              String rating = product.rating != null && product.rating!.isNotEmpty ? product.rating![0].average!.toStringAsFixed(1) : '4.5';

              return Padding(
                padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, bottom: 10),
                child: InkWell(
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedSubVariant = null;
                      } else {
                        _selectedSubVariant = subVariant;
                      }
                    });
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
                                border: Border.all(
                                  color: isSelected ? Theme.of(context).primaryColor : Colors.black.withValues(alpha: 0.08),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected ? [
                                  BoxShadow(
                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  )
                                ] : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: CustomImageWidget(
                                  image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/$variantImage',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            // Selection checkbox/radio indicator overlay in top-left
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                                    width: 2,
                                  ),
                                  color: isSelected ? Theme.of(context).primaryColor : Colors.black.withValues(alpha: 0.3),
                                ),
                                child: isSelected 
                                    ? const Icon(Icons.check, size: 14, color: Colors.white) 
                                    : null,
                              ),
                            ),

                            // Wishlist Button overlay in top-right
                            Positioned(
                              top: 8,
                              right: 8,
                              child: WishButtonWidget(
                                product: product,
                                subVariantId: subVariant.id,
                                edgeInset: const EdgeInsets.all(4),
                                color: Colors.black.withValues(alpha: 0.4),
                              ),
                            ),

                            // Rating Badge overlapping bottom-left (matching home page)
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

                            // Discount Badge in bottom-right (since top-left is occupied by selection circle)
                            if (product.discount != null && product.discount! > 0)
                              Positioned(
                                bottom: 8,
                                right: 8,
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
                                        product.discountType == 'percent' 
                                            ? '${product.discount}% Off' 
                                            : '${PriceConverterHelper.convertPrice(context, product.discount)} Off',
                                        style: poppinsMedium.copyWith(color: Colors.white, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Stock status overlay on center-bottom if out of stock
                            if ((subVariant.stock ?? 0) <= 0)
                              Positioned(
                                top: 0,
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(alpha: 0.8),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        getTranslated('out_of_stock', context),
                                        textAlign: TextAlign.center,
                                        style: poppinsMedium.copyWith(color: Colors.white, fontSize: 10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18), // extra space for rating badge overlapping
                        Text(
                          subVariant.name ?? '',
                          style: poppinsSemiBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subVariant.attributes != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            _getAttributesText(product, subVariant),
                            style: poppinsRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 2),
                        if (subVariant.mrp != null && subVariant.mrp! > (subVariant.price ?? 0)) ...[
                          RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${getTranslated('mrp', context)}: ',
                                  style: poppinsRegular.copyWith(fontSize: 10, color: const Color(0xFF888888)),
                                ),
                                TextSpan(
                                  text: PriceConverterHelper.convertPrice(context, subVariant.mrp),
                                  style: poppinsRegular.copyWith(
                                    fontSize: 11,
                                    color: const Color(0xFF888888),
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ]
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],
                        RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            children: [
                              if (subVariant.mrp != null && subVariant.mrp! > (subVariant.price ?? 0))
                                TextSpan(
                                  text: '${getTranslated('our_price', context)}: ',
                                  style: poppinsMedium.copyWith(fontSize: 10, color: Colors.black54),
                                ),
                              TextSpan(
                                text: PriceConverterHelper.convertPrice(context, subVariant.price),
                                style: poppinsSemiBold.copyWith(fontSize: 14, color: Colors.black),
                              ),
                              TextSpan(
                                text: '/${product.unit}',
                                style: poppinsRegular.copyWith(fontSize: 12, color: const Color(0xFF888888)),
                              ),
                            ]
                          ),
                        ),
                        const SizedBox(height: 2),
                        // if ((subVariant.stock ?? 0) > 0)
                        //   Text(
                        //     '${getTranslated('stock', context)}: ${subVariant.stock}',
                        //     style: poppinsRegular.copyWith(
                        //       fontSize: Dimensions.fontSizeExtraSmall,
                        //       color: Colors.green,
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  String _getAttributesText(Product product, SubVariant subVariant) {
    if (subVariant.attributes == null) {
      return '';
    }
    List<String> list = [];
    if (subVariant.attributes is Map) {
      (subVariant.attributes as Map).forEach((key, value) {
        String choiceName = 'choice_options_$key';
        ChoiceOptions? choice;
        try {
          choice = product.choiceOptions?.firstWhere((element) => element.name == choiceName);
        } catch (_) {}
        if (choice != null && choice.title != null && choice.title!.isNotEmpty) {
          list.add('${choice.title}: $value');
        } else {
          list.add('$value');
        }
      });
    } else if (subVariant.attributes is List) {
      // If it is encoded as a list
      for (var item in subVariant.attributes) {
        if (item is Map) {
          item.forEach((key, value) {
            String choiceName = 'choice_options_$key';
            ChoiceOptions? choice;
            try {
              choice = product.choiceOptions?.firstWhere((element) => element.name == choiceName);
            } catch (_) {}
            if (choice != null && choice.title != null && choice.title!.isNotEmpty) {
              list.add('${choice.title}: $value');
            } else {
              list.add('$value');
            }
          });
        }
      }
    }
    return list.join(', ');
  }
}







