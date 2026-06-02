import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
import 'package:flutter_grocery/features/order/domain/models/review_body_model.dart';
import 'package:flutter_grocery/features/order/domain/models/order_model.dart';
import 'package:flutter_grocery/features/review/providers/review_provider.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/common/widgets/custom_button_widget.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/common/widgets/custom_text_field_widget.dart';
import 'package:flutter_grocery/features/order/widgets/delivery_man_widget.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/footer_web_widget.dart';

class DeliveryManReviewWidget extends StatefulWidget {
  final DeliveryMan? deliveryMan;
  final String orderID;
  const DeliveryManReviewWidget({super.key, required this.deliveryMan, required this.orderID});

  @override
  State<DeliveryManReviewWidget> createState() => _DeliveryManReviewWidgetState();
}

class _DeliveryManReviewWidgetState extends State<DeliveryManReviewWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, child) {
        return CustomScrollView(slivers: [
          SliverToBoxAdapter(child: Center(child: SizedBox(
            width: Dimensions.webScreenWidth,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [

              widget.deliveryMan != null ? DeliveryManWidget(deliveryMan: widget.deliveryMan) : const SizedBox(),
              const SizedBox(height: Dimensions.paddingSizeLarge),

               Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ],
                  border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.06), width: 1.5),
                ),
                child: Column(children: [
                  Text(
                    getTranslated('rate_his_service', context),
                    style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  SizedBox(height: 40, child: ListView.builder(
                    itemCount: 5,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, i) {
                      return InkWell(
                        onTap: reviewProvider.deliverymanReviewSubmitted ? null :  () {
                          reviewProvider.setDeliveryManRating(i + 1);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            reviewProvider.deliveryManRating < (i + 1) ? Icons.star_border_rounded : Icons.star_rounded,
                            size: 36,
                            color: reviewProvider.deliveryManRating < (i + 1)
                                ? Theme.of(context).hintColor.withValues(alpha: 0.3)
                                : ColorResources.ratingColor,
                          ),
                        ),
                      );
                    },
                  )),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Text(
                    getTranslated('share_your_opinion', context),
                    style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  CustomTextFieldWidget(
                    maxLines: 4,
                    isEnabled: !reviewProvider.deliverymanReviewSubmitted,
                    capitalization: TextCapitalization.sentences,
                    controller: _controller,
                    hintText: getTranslated('write_your_review_here', context),
                    fillColor: Theme.of(context).cardColor,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // Submit button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    child: Column(children: [
                      CustomButtonWidget(
                        isLoading: reviewProvider.isLoading,
                        buttonText: getTranslated( reviewProvider.deliverymanReviewSubmitted ? 'submitted' : 'submit', context),
                        borderRadius: 30,
                        onPressed: reviewProvider.deliverymanReviewSubmitted ? null : () {
                          if (reviewProvider.deliveryManRating == 0) {
                            showCustomSnackBarHelper(getTranslated('give_a_rating', context));
                          } else if (_controller.text.isEmpty) {
                            showCustomSnackBarHelper(getTranslated('write_a_review', context));
                          } else {
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                            ReviewBodyModel reviewBody = ReviewBodyModel(
                              deliveryManId: widget.deliveryMan!.id.toString(),
                              rating: reviewProvider.deliveryManRating.toString(),
                              comment: _controller.text,
                              orderId: widget.orderID,
                            );
                            reviewProvider.submitDeliveryManReview(reviewBody).then((value) {
                              if (value.isSuccess) {
                                showCustomSnackBarHelper(value.message!, isError: false);
                              } else {
                                showCustomSnackBarHelper(value.message!);
                              }
                            });
                          }
                        },
                      ),

                    ]),
                  ),
                ]),
              ),

            ]),

          ))),

          const FooterWebWidget(footerType: FooterType.sliver),

        ]);
      },
    );
  }
}
