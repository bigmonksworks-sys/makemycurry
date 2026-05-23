import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/features/order/domain/models/offline_payment_model.dart';
import 'package:flutter_grocery/helper/price_converter_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/features/profile/providers/profile_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class PaymentMethodSelectionWidget extends StatefulWidget {
  final double total;
  final double? weight;
  final String? orderId;
  final bool isAlreadyPartialApplied;

  const PaymentMethodSelectionWidget({
    super.key,
    required this.total,
    this.weight,
    this.orderId,
    this.isAlreadyPartialApplied = false,
  });

  @override
  State<PaymentMethodSelectionWidget> createState() =>
      _PaymentMethodSelectionWidgetState();
}

class _PaymentMethodSelectionWidgetState
    extends State<PaymentMethodSelectionWidget> with TickerProviderStateMixin {
  TextEditingController? _bringAmountController;
  List<PaymentMethod> paymentList = [];
  int? _paymentMethodIndex;
  double? _partialAmount;
  PaymentMethod? _paymentMethod;
  OfflinePaymentModel? _selectedOfflineMethod;
  List<Map<String, String>>? _selectedOfflineValue;
  String _selectedPaymentType = '';

  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _bringAmountController = TextEditingController();

    // Initialize animations
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    final splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final configModel = splashProvider.configModel!;
    splashProvider.getOfflinePaymentMethod(false);

    paymentList.addAll(configModel.activePaymentMethodList ?? []);
    if (configModel.isOfflinePayment!) {
      paymentList.add(PaymentMethod(
        getWay: 'offline',
        getWayTitle: getTranslated('offline', context),
        type: 'offline',
        getWayImage: Images.offlinePayment,
      ));
    }
    _initializeData();

    // Start animations
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _initializeData() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    _paymentMethodIndex = orderProvider.paymentMethodIndex;
    _partialAmount = orderProvider.partialAmount;
    _paymentMethod = orderProvider.paymentMethod;
    _selectedOfflineMethod = orderProvider.selectedOfflineMethod;
    _selectedOfflineValue = orderProvider.selectedOfflineValue;

    if (_paymentMethodIndex == 0) {
      _selectedPaymentType = 'wallet';
    } else if (_paymentMethodIndex == 1)
      _selectedPaymentType = 'cod';
    else if (_paymentMethod != null) _selectedPaymentType = 'online';

    if (_paymentMethodIndex != 1) {
      orderProvider.setBringChangeAmount(isUpdate: false);
      orderProvider.updateBringChangeInputOptionStatus(false, isUpdate: false);
    } else {
      _bringAmountController?.text =
          "${orderProvider.bringChangeAmount?.floor() ?? ""}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final walletBalance = profileProvider.userInfoModel?.walletBalance ?? 0;

    final availableMethods = [
      if (walletBalance > 0 && !widget.isAlreadyPartialApplied)
        PaymentOption(
          type: 'wallet',
          label: 'Wallet',
          subtitle: 'Available Balance',
          icon: Icons.account_balance_wallet_rounded,
          color: Theme.of(context).primaryColor,
          badge: PriceConverterHelper.convertPrice(context, walletBalance),
        ),
      PaymentOption(
        type: 'cod',
        label: 'Cash on Delivery',
        subtitle: 'Pay when delivered',
        icon: Icons.payments_rounded,
        color: Theme.of(context).primaryColor,
        badge: null,
      ),
      if (paymentList.isNotEmpty)
        PaymentOption(
          type: 'online',
          label: 'Online Payment',
          subtitle: 'Cards, UPI & More',
          icon: Icons.credit_card_rounded,
          color: Theme.of(context).primaryColor,
          badge: null,
        ),
    ];

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with total amount

              // Balance Overview Cards
              // _buildBalanceOverview(context, walletBalance),
              // const SizedBox(height: 32),

              // Payment Methods Title
              Text(
                'Select Payment Method',
                style: poppinsSemiBold.copyWith(
                  fontSize: 18,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 16),

              // Payment Method List (Radio Button Style)
              _buildPaymentMethodList(availableMethods, walletBalance),
              _buildHeader(context),

              // COD bring-change input
              // if (_selectedPaymentType == 'cod') ...[
              //   const SizedBox(height: 24),
              //   _buildCODInput(),
              // ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.shopping_cart_checkout_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Amount',
                  style: poppinsRegular.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  PriceConverterHelper.convertPrice(context, widget.total),
                  style: poppinsBold.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceOverview(BuildContext context, double walletBalance) {
    return SizedBox(
      width: double.infinity,
      child: _buildInfoCard(
        icon: Icons.account_balance_wallet_rounded,
        title: 'Wallet Balance',
        amount: PriceConverterHelper.convertPrice(context, walletBalance),
        color: Colors.green.shade600,
        gradient: [Colors.green.shade400, Colors.green.shade600],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String amount,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.trending_up, color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: poppinsRegular.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: poppinsBold.copyWith(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodList(
      List<PaymentOption> availableMethods, double walletBalance) {
    return Column(
      children: availableMethods.map((option) {
        final isSelected = _selectedPaymentType == option.type;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _selectPaymentMethod(
              option.type,
              Provider.of<OrderProvider>(context, listen: false),
              walletBalance,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? option.color.withOpacity(0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? option.color : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: option.color.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Row(
                children: [
                  // Radio button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? option.color : Colors.grey.shade400,
                        width: 2,
                      ),
                      color: isSelected ? option.color : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),

                  const SizedBox(width: 16),

                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? option.color.withOpacity(0.15)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      option.icon,
                      color: isSelected ? option.color : Colors.grey.shade600,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Label and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.label,
                          style: poppinsSemiBold.copyWith(
                            fontSize: 16,
                            color: isSelected
                                ? option.color
                                : Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          option.subtitle,
                          style: poppinsRegular.copyWith(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Badge if available
                  if (option.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6), // increased padding
                      decoration: BoxDecoration(
                        color: option.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                            16), // more rounded for larger badge
                        border: Border.all(
                          color: option.color.withOpacity(0.3),
                          width: 1.2, // slightly thicker border
                        ),
                      ),
                      child: Text(
                        option.badge!,
                        style: poppinsRegular.copyWith(
                          fontSize: 14, // increased font size
                          color: option.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Widget _buildCODInput() {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Colors.orange.shade50,
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(
  //         color: Colors.orange.shade200,
  //         width: 1,
  //       ),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.all(8),
  //               decoration: BoxDecoration(
  //                 color: Colors.orange.shade100,
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: Icon(
  //                 Icons.info_outline,
  //                 color: Colors.orange.shade700,
  //                 size: 20,
  //               ),
  //             ),
  //             const SizedBox(width: 12),
  //             Expanded(
  //               child: Text(
  //                 'Cash on Delivery Options',
  //                 style: poppinsSemiBold.copyWith(
  //                   fontSize: 16,
  //                   color: Colors.orange.shade700,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
  //         BringChangeInputWidget(
  //           amountController: _bringAmountController,
  //           hidePaymentMethod: false,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _selectPaymentMethod(
      String type, OrderProvider orderProvider, double walletBalance) {
    setState(() {
      _selectedPaymentType = type;
      switch (type) {
        case 'wallet':
          _paymentMethodIndex = 0;
          _partialAmount = widget.total > walletBalance ? walletBalance : null;
          _paymentMethod = null;
          _bringAmountController?.clear();
          break;
        case 'cod':
          _paymentMethodIndex = 1;
          _partialAmount = null;
          break;
        case 'online':
          _paymentMethod = paymentList.isNotEmpty ? paymentList.first : null;
          _partialAmount = null;
          break;
      }
    });

    orderProvider.savePaymentMethod(
      index: _paymentMethodIndex,
      method: _paymentMethod,
      partialAmount: _partialAmount,
      selectedOfflineValue: _selectedOfflineValue,
      selectedOfflineMethod: _selectedOfflineMethod,
    );
  }
}

class PaymentOption {
  final String type;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? badge;

  PaymentOption({
    required this.type,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.badge,
  });
}
