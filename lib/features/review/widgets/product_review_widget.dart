import 'dart:io';

import 'package:dotted_border/dotted_border.dart' show BorderType, DottedBorder;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
import 'package:flutter_grocery/common/widgets/custom_button_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_single_child_list_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_text_field_widget.dart';
import 'package:flutter_grocery/features/order/domain/models/order_details_model.dart';
import 'package:flutter_grocery/features/order/domain/models/review_body_model.dart';
import 'package:flutter_grocery/features/order/widgets/ordered_product_list_widget.dart';
import 'package:flutter_grocery/features/review/providers/review_provider.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:provider/provider.dart';
import '../../../common/widgets/footer_web_widget.dart';

class ProductReviewWidget extends StatelessWidget {
  final List<OrderDetailsModel> orderDetailsList;
  const ProductReviewWidget({super.key, required this.orderDetailsList});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, child) {
        return CustomScrollView(slivers: [
          SliverToBoxAdapter(child: Center(child: SizedBox(
            width: Dimensions.webScreenWidth,
            child: ListView.builder(
              itemCount: orderDetailsList.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      )
                    ],
                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.06), width: 1.5),
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(children: [

                    /// Product details
                    OrderedProductItem(orderDetailsModel:  orderDetailsList[index], fromReview: true),
                    const Divider(height: Dimensions.paddingSizeLarge),

                    /// Rate
                    Text(
                      getTranslated('rate_the_order', context),
                      style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        itemCount: 5,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, i) {
                          final int rating = reviewProvider.ratingList.length > index ? reviewProvider.ratingList[index] : 0;
                          return InkWell(
                            onTap: () {
                              if(reviewProvider.submitList.length > index && !reviewProvider.submitList[index]) {
                                reviewProvider.setRating(index, i + 1);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(
                                rating < (i + 1) ? Icons.star_border_rounded : Icons.star_rounded,
                                size: 36,
                                color: rating < (i + 1)
                                    ? Theme.of(context).hintColor.withValues(alpha: 0.3)
                                    : ColorResources.ratingColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Text(
                      getTranslated('share_your_opinion', context),
                      style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    /// Review Text
                    CustomTextFieldWidget(
                      maxLines: 4,
                      capitalization: TextCapitalization.sentences,
                      isEnabled: reviewProvider.submitList.length > index ? !reviewProvider.submitList[index] : true,
                      hintText: getTranslated('write_your_review_here', context),
                      fillColor: Theme.of(context).cardColor,
                      onChanged: (text) {
                        reviewProvider.setReview(index, text);
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    /// Product review image
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomSingleChildListWidget(
                        mainAxisAlignment: MainAxisAlignment.start,
                        scrollDirection: Axis.horizontal,
                        itemCount: _getProductWiseReviewImageCount(reviewProvider, index),
                        itemBuilder: (ind) {
                          final bool isSubmitted = reviewProvider.submitList.length > index && reviewProvider.submitList[index];
                          return _canPickImage(ind, reviewProvider, index) ? Container(
                              width: 70, height: 70, margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall), child: InkWell(
                            onTap: isSubmitted ? null : () {
                              if (reviewProvider.reviewImageList.length > index) {
                                reviewProvider.pickImage(false, reviewProvider.reviewImageList[index].productId);
                              }
                            },
                            child: Opacity(
                              opacity: isSubmitted ? 0.5 : 1,
                              child: DottedBorder(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                radius: const Radius.circular(Dimensions.radiusSizeSmall),
                                borderType: BorderType.RRect,
                                dashPattern: const [6, 6],
                                color: Theme.of(context).primaryColor.withValues(alpha:0.4),
                                strokeWidth: 1.5,
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.camera_alt_outlined, color: Theme.of(context).primaryColor, size: Dimensions.paddingSizeDefault),

                                  Text(getTranslated('upload_image', context), textAlign: TextAlign.center, style: poppinsRegular.copyWith(
                                    color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall,
                                  )),
                                ]),
                              ),
                            ),
                          )) : Container(margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall), child: Stack(children: [

                            Container(width: 70, height: 70,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusSizeSmall)),
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSizeSmall)),
                                child: kIsWeb ? Image.network(
                                  (reviewProvider.reviewImageList.length > index && reviewProvider.reviewImageList[index].image != null && reviewProvider.reviewImageList[index].image!.length > ind)
                                      ? reviewProvider.reviewImageList[index].image![ind].path
                                      : '',
                                  width: 70, height: 70, fit: BoxFit.cover,
                                ) : Image.file(
                                  File((reviewProvider.reviewImageList.length > index && reviewProvider.reviewImageList[index].image != null && reviewProvider.reviewImageList[index].image!.length > ind)
                                      ? reviewProvider.reviewImageList[index].image![ind].path
                                      : ''),
                                  width: 70, height: 70, fit: BoxFit.cover,
                                ),
                              ) ,
                            ),

                            Positioned(top:2, right:2, child: InkWell(
                              onTap: () => isSubmitted ? null : (reviewProvider.reviewImageList.length > index ? reviewProvider.removeImage(ind, reviewProvider.reviewImageList[index].productId) : null),
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault))
                                  ),
                                child: isSubmitted ? SizedBox() : Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Icon(Icons.clear, color: Theme.of(context).primaryColor, size: Dimensions.paddingSizeDefault),
                                ),
                              ),
                            )),

                          ]));

                        },
                      ),
                    ),

                    SizedBox(height: Dimensions.paddingSizeSmall),

                    Row(mainAxisAlignment: MainAxisAlignment.start,children: [
                      Text('*', style: poppinsRegular.copyWith(color: Theme.of(context).colorScheme.error)),

                      Text(getTranslated('upload_up_to_4_image', context), style: poppinsRegular.copyWith(color: Theme.of(context).hintColor)),
                    ]),
                    SizedBox(height: Dimensions.paddingSizeExtraLarge),

                    // Submit button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                      child: Column(
                        children: [
                          !(reviewProvider.loadingList.length > index && reviewProvider.loadingList[index]) ? CustomButtonWidget(
                            buttonText: getTranslated((reviewProvider.submitList.length > index && reviewProvider.submitList[index]) ? 'submitted' : 'submit', context),
                            borderRadius: 30,
                            onPressed: (reviewProvider.submitList.length > index && reviewProvider.submitList[index]) ? null : () {
                              if(reviewProvider.submitList.length > index && !reviewProvider.submitList[index]) {
                                final int r = reviewProvider.ratingList.length > index ? reviewProvider.ratingList[index] : 0;
                                final String comment = reviewProvider.reviewList.length > index ? reviewProvider.reviewList[index] : '';
                                if (r == 0) {
                                  showCustomSnackBarHelper(getTranslated('give_a_rating', context));
                                } else if (comment.isEmpty) {
                                  showCustomSnackBarHelper(getTranslated('write_a_review', context));
                                } else {
                                  FocusScopeNode currentFocus = FocusScope.of(context);
                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }
                                  ReviewBodyModel reviewBody = ReviewBodyModel(
                                    productId: orderDetailsList[index].productId.toString(),
                                    rating: r.toString(),
                                    comment: comment,
                                    orderId: orderDetailsList[index].orderId.toString(),
                                  );
                                  reviewProvider.submitReview(index, reviewBody).then((value) {
                                    if (value.isSuccess) {
                                      showCustomSnackBarHelper(value.message!, isError: false);
                                      reviewProvider.setReview(index, '');
                                    } else {
                                      showCustomSnackBarHelper(value.message!);
                                    }
                                  });
                                }
                              }
                            },
                          ) : Center(child: CustomLoaderWidget(color: Theme.of(context).primaryColor)),
                        ],
                      ),
                    ),
                  ]),
                );
              },
            ),
          ))),

          const FooterWebWidget(footerType: FooterType.sliver),

        ]);
      },
    );
  }

  bool _canPickImage(int ind, ReviewProvider reviewProvider, int index) {
    if (reviewProvider.reviewImageList.length <= index || reviewProvider.reviewImageList[index].image == null) {
      return true;
    }
    return ind == reviewProvider.reviewImageList[index].image!.length
        && reviewProvider.reviewImageList[index].image!.length < 4
        || reviewProvider.reviewImageList[index].image!.isEmpty;
  }

  int _getProductWiseReviewImageCount(ReviewProvider reviewProvider, int index) {
    if (reviewProvider.reviewImageList.length <= index || reviewProvider.reviewImageList[index].image == null) {
      return 1;
    }
    return reviewProvider.reviewImageList[index].image!.length < 4 ?
    reviewProvider.reviewImageList[index].image!.length + 1
        : 4;
  }
}
