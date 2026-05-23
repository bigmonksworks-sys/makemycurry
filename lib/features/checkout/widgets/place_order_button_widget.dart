import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_grocery/common/models/place_order_model.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/features/address/providers/location_provider.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/features/payment/screens/payment_screen.dart';
import 'package:flutter_grocery/features/profile/providers/profile_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PlaceOrderButtonWidget extends StatefulWidget {
  final double discount;
  final double? couponDiscount;
  final double? tax;
  final ScrollController scrollController;
  final GlobalKey dropdownKey;
  final double weight;

  const PlaceOrderButtonWidget({
    super.key,
    required this.discount,
    required this.couponDiscount,
    required this.tax,
    required this.scrollController,
    required this.dropdownKey,
    required this.weight,
  });

  @override
  State<PlaceOrderButtonWidget> createState() => _PlaceOrderButtonWidgetState();
}

class _PlaceOrderButtonWidgetState extends State<PlaceOrderButtonWidget> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        return Consumer<CartProvider>(
          builder: (context, cartProvider, _) {
            return Consumer<LocationProvider>(
              builder: (context, locationProvider, _) {
                return Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: ElevatedButton(
                        onPressed: _isProcessing
                            ? null
                            : () => _placeOrder(
                                  orderProvider,
                                  cartProvider,
                                  locationProvider,
                                  authProvider,
                                ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isProcessing
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CupertinoActivityIndicator(
                                      color: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    getTranslated('processing', context),
                                    style: poppinsMedium.copyWith(
                                      color: Theme.of(context).cardColor,
                                      fontSize: Dimensions.fontSizeLarge,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                getTranslated('place_order', context),
                                style: poppinsMedium.copyWith(
                                  color: Theme.of(context).cardColor,
                                  fontSize: Dimensions.fontSizeLarge,
                                ),
                              ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _placeOrder(
    OrderProvider orderProvider,
    CartProvider cartProvider,
    LocationProvider locationProvider,
    AuthProvider authProvider,
  ) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Validate order requirements
      if (!_validateOrder(orderProvider, cartProvider, locationProvider)) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      // Prepare order data
      PlaceOrderModel orderBody = _prepareOrderData(
        orderProvider,
        cartProvider,
        locationProvider,
        authProvider,
      );

      // Handle different payment methods
      String paymentMethod =
          orderProvider.selectedPaymentMethod?.getWay ?? 'cash_on_delivery';

      if (paymentMethod == 'razor_pay') {
        // For Razorpay - go to payment first, create order after successful payment
        setState(() {
          _isProcessing = false;
        });

        // Get customer email from profile
        final profileProvider =
            Provider.of<ProfileProvider>(context, listen: false);
        String customerEmail = '';
        String customerPhone = '';

        if (authProvider.isLoggedIn() &&
            profileProvider.userInfoModel != null) {
          customerEmail = profileProvider.userInfoModel!.email ?? '';
          customerPhone = profileProvider.userInfoModel!.phone ?? '';
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RazorpayPaymentScreen(
              orderBody: orderBody,
              totalAmount: orderBody.orderAmount ?? 0,
              customerEmail: customerEmail,
              customerPhone : customerPhone,
              onPaymentSuccess: (paymentId, razorpayOrderId) {
                // Payment successful - now create the actual order
                _createOrderAfterPayment(orderBody, paymentId, razorpayOrderId);
              },
            ),
          ),
        );
      } else {
        // Handle other payment methods (COD, Wallet, etc.) - create order immediately
        orderProvider.placeOrder(orderBody, _handlePaymentCallback);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _createOrderAfterPayment(
      PlaceOrderModel orderBody, String paymentId, String razorpayOrderId) {
    // Update order body with payment information
    final updatedOrderBody = orderBody.copyWith(
      paymentMethod: 'razor_pay',
      transactionReference: paymentId, // Add payment ID to order
    );

    // Now create the order with payment confirmation
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    orderProvider.placeOrder(updatedOrderBody, (isSuccess, message, orderID) {
      if (isSuccess) {
        // Clear cart and navigate to success screen
        Provider.of<CartProvider>(context, listen: false).clearCartList();
        Navigator.pushReplacementNamed(
          context,
          '${RouteHelper.orderSuccessful}/$orderID/success',
        );
      } else {
        // Order creation failed after successful payment - this is a critical error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Payment successful but order creation failed: $message'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
        // You might want to handle this case differently - maybe retry or contact support
      }
    });
  }

  bool _validateOrder(
    OrderProvider orderProvider,
    CartProvider cartProvider,
    LocationProvider locationProvider,
  ) {
    // Validate cart
    if (cartProvider.cartList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(getTranslated('cart_is_empty', context))),
      );
      return false;
    }

    // Validate address for delivery
    if (orderProvider.orderType == 'delivery' &&
        (locationProvider.addressList == null ||
            locationProvider.addressList!.isEmpty ||
            orderProvider.addressIndex == -1)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(getTranslated('please_select_delivery_address', context))),
      );
      return false;
    }

    // Validate payment method
    if (orderProvider.selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(getTranslated('please_select_payment_method', context))),
      );
      return false;
    }

    // Validate time slot
    if (orderProvider.timeSlots == null ||
        orderProvider.selectTimeSlot == -1 ||
        orderProvider.timeSlots!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(getTranslated('please_select_delivery_time', context))),
      );
      return false;
    }

    return true;
  }

  PlaceOrderModel _prepareOrderData(
    OrderProvider orderProvider,
    CartProvider cartProvider,
    LocationProvider locationProvider,
    AuthProvider authProvider,
  ) {
    final checkOutData = orderProvider.getCheckOutData;
    if (checkOutData == null) {
      throw Exception('Checkout data is missing');
    }

    // Selected address for delivery
    final selectedAddress = orderProvider.orderType == 'delivery'
        ? locationProvider.addressList![orderProvider.addressIndex]
        : null;

    // Selected time slot
    final selectedTimeSlot =
        orderProvider.timeSlots![orderProvider.selectTimeSlot];

    // Payment method
    final paymentMethod =
        orderProvider.selectedPaymentMethod?.getWay ?? 'cash_on_delivery';

    // Determine partial payment flag
    int isPartialValue = 0;
    if (paymentMethod != 'cash_on_delivery' &&
        paymentMethod != 'offline_payment') {
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      final userInfo = profileProvider.userInfoModel;
      if (userInfo != null &&
          orderProvider.partialAmount != null &&
          orderProvider.partialAmount! > 0) {
        isPartialValue = 1;
      }
    }

    // Map CartModel -> Cart
    final List<Cart> cartItems = cartProvider.cartList.map((cartModel) {
      return Cart(
        productId: cartModel.id ?? 0,
        price: cartModel.discountedPrice ?? 0,
        quantity: cartModel.quantity ?? 1,
        variant: cartModel.variation?.type,
        variation: cartModel.variation != null
            ? [Variation(type: cartModel.variation!.type)]
            : null,
        subVariantId: cartModel.subVariantId,
      );
    }).toList();

    // Calculate the actual selected date based on the slot index
    DateTime selectedDate;
    switch (orderProvider.selectDateSlot) {
      case 0:
        selectedDate = DateTime.now(); // Today
        break;
      case 1:
        selectedDate = DateTime.now().add(const Duration(days: 1)); // Tomorrow
        break;
      case 2:
        selectedDate =
            DateTime.now().add(const Duration(days: 2)); // Day after tomorrow
        break;
      default:
        selectedDate = DateTime.now(); // fallback
        break;
    }

    // Format delivery date
    String deliveryDateString = DateFormat('yyyy-MM-dd').format(selectedDate);

    // Calculate the complete total amount including all charges
    double subtotalAmount = checkOutData.amount ?? 0;
    double deliveryCharge = orderProvider.deliveryCharge ?? 0;
    double taxAmount = widget.tax ?? 0;
    double weightCharge = widget.weight;
    double couponDiscount = widget.couponDiscount ?? 0;
    double extraDiscount = widget.discount;

    // Calculate the final total amount
    double totalAmount = subtotalAmount +
        deliveryCharge +
        taxAmount +
        weightCharge -
        couponDiscount;
    // - extraDiscount;   // ❌ wrong here

    // Round to 2 decimal places to avoid floating point precision issues
    totalAmount = double.parse(totalAmount.toStringAsFixed(2));

    // Debug prints to verify the calculation
    debugPrint('=== ORDER AMOUNT CALCULATION ===');
    debugPrint('Subtotal Amount: $subtotalAmount');
    debugPrint('Delivery Charge: $deliveryCharge');
    debugPrint('Tax Amount: $taxAmount');
    debugPrint('Weight Charge: $weightCharge');
    debugPrint('Coupon Discount: $couponDiscount');
    debugPrint('Extra Discount: $extraDiscount');
    debugPrint('TOTAL AMOUNT: $totalAmount');
    debugPrint('===============================');

    // Build PlaceOrderModel with the correct total amount
    final orderBody = PlaceOrderModel(
      cart: cartItems,
      orderAmount: totalAmount,
      couponCode: checkOutData.couponCode,
      couponDiscountAmount: couponDiscount,
      couponDiscountTitle: checkOutData.couponCode,
      orderType: orderProvider.orderType ?? 'delivery',
      paymentMethod: paymentMethod,
      orderNote: checkOutData.orderNote ?? '',
      branchId: Provider.of<SplashProvider>(context, listen: false)
          .configModel!
          .branches![orderProvider.branchIndex]
          .id!,
      deliveryAddressId: selectedAddress?.id,
      timeSlotId: selectedTimeSlot.id,
      distance: orderProvider.distance ?? 0,
      selectedDeliveryArea: orderProvider.selectedAreaID,
      bringChangeAmount: orderProvider.bringChangeAmount ?? 0,
      isPartial: isPartialValue,
      deliveryDate: deliveryDateString,
    );

    // Debug log to check final JSON
    debugPrint('PlaceOrder JSON: ${jsonEncode(orderBody.toJson())}');
    debugPrint('Order Amount being sent: ${orderBody.orderAmount}');

    return orderBody;
  }

  void _handlePaymentCallback(bool isSuccess, String message, String orderID) {
    setState(() {
      _isProcessing = false;
    });

    if (isSuccess) {
      // Clear cart and navigate to success screen
      Provider.of<CartProvider>(context, listen: false).clearCartList();
      Navigator.pushReplacementNamed(
        context,
        '${RouteHelper.orderSuccessful}/$orderID/success',
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
