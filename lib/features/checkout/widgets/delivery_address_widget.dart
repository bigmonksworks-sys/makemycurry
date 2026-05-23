import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/address/domain/models/address_model.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/features/order/enums/delivery_charge_type.dart';
import 'package:flutter_grocery/helper/checkout_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/address/providers/location_provider.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/custom_shadow_widget.dart';
import 'package:flutter_grocery/features/checkout/widgets/add_address_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class DeliveryAddressWidget extends StatelessWidget {
  final bool selfPickup;

  const DeliveryAddressWidget({
    super.key, required this.selfPickup,
  });

  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;

    return !selfPickup ? CustomShadowWidget(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Consumer<LocationProvider>(
        builder: (context, locationProvider, _) => Consumer<OrderProvider>(builder: (context, orderProvider, _) {

          bool isAvailable = false;

          AddressModel? deliveryAddress = CheckOutHelper.getDeliveryAddress(
            addressList: locationProvider.addressList,
            selectedAddress: orderProvider.addressIndex == -1 ? null : locationProvider.addressList?[orderProvider.addressIndex],
            lastOrderAddress: null,
          );
          if(deliveryAddress != null &&
              (configModel.googleMapStatus ?? false) &&
              CheckOutHelper.getDeliveryChargeType() == DeliveryChargeType.distance.name
              && ((deliveryAddress.latitude != null && deliveryAddress.latitude!.isNotEmpty) && (deliveryAddress.longitude != null && deliveryAddress.longitude!.isNotEmpty))
          ){
            isAvailable = CheckOutHelper.isBranchAvailable(
              branches: configModel.branches ?? [],
              selectedBranch: configModel.branches![orderProvider.branchIndex],
              selectedAddress: deliveryAddress,
            );

            if(!isAvailable) {
              deliveryAddress = null;
            }
          }

          return locationProvider.addressList == null ? const _DeliverySectionShimmer() : Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: Text(
                        '${getTranslated('delivery_to', context)} -', 
                        style: poppinsMedium.copyWith(
                          fontSize: Dimensions.fontSizeExtraLarge,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => showDialog(context: context, builder: (_) => const AddAddressDialogWidget()),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                              vertical: Dimensions.paddingSizeSmall,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  deliveryAddress == null || orderProvider.addressIndex == -1 
                                      ? Icons.add 
                                      : Icons.edit,
                                  color: Theme.of(context).primaryColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  getTranslated(deliveryAddress == null || orderProvider.addressIndex == -1 ? 'add' : 'change', context), 
                                  style: poppinsSemiBold.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: Dimensions.fontSizeDefault,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Address Content
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: deliveryAddress == null || orderProvider.addressIndex == -1 
                    ? _NoAddressWidget(key: const ValueKey('no_address'))
                    : _AddressDetailsWidget(
                        key: const ValueKey('address_details'),
                        deliveryAddress: deliveryAddress,
                      ),
              ),
            ],
          );
        }),
      ),
    ) : const SizedBox();
  }
}

class _NoAddressWidget extends StatelessWidget {
  const _NoAddressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.05),

        borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.info_outline_rounded, 
                    color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getTranslated('no_contact_info_added', context),
                  style: poppinsMedium.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
              
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressDetailsWidget extends StatelessWidget {
  final AddressModel deliveryAddress;
  
  const _AddressDetailsWidget({
    super.key, 
    required this.deliveryAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact Information
          _ContactInfoRow(
            icon: Icons.person_outline,
            text: deliveryAddress.contactPersonName ?? '',
            isName: true,
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          
          _ContactInfoRow(
            icon: Icons.phone_outlined,
            text: deliveryAddress.contactPersonNumber ?? '',
            isPhone: true,
          ),
          
          Container(
            margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Theme.of(context).dividerColor,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          // Address Information
          _AddressSection(deliveryAddress: deliveryAddress),
        ],
      ),
    );
  }
}

class _ContactInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isName;
  final bool isPhone;
  
  const _ContactInfoRow({
    required this.icon,
    required this.text,
    this.isName = false,
    this.isPhone = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon, 
            color: Theme.of(context).primaryColor,
            size: 16,
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeDefault),
        Expanded(
          child: Text(
            text,
            style: poppinsMedium.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            maxLines: isName ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isPhone) ...[
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.call,
              color: Theme.of(context).primaryColor,
              size: 12,
            ),
          ),
        ],
      ],
    );
  }
}

class _AddressSection extends StatelessWidget {
  final AddressModel deliveryAddress;
  
  const _AddressSection({required this.deliveryAddress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.home_outlined,
                color: Theme.of(context).primaryColor,
                size: 16,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deliveryAddress.address ?? '',
                    style: poppinsMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  _AddressDetailsRow(deliveryAddress: deliveryAddress),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AddressDetailsRow extends StatelessWidget {
  final AddressModel deliveryAddress;
  
  const _AddressDetailsRow({required this.deliveryAddress});

  @override
  Widget build(BuildContext context) {
    final List<Widget> details = [];
    
    if (deliveryAddress.houseNumber != null && deliveryAddress.houseNumber!.isNotEmpty) {
      details.add(_AddressDetailChip(
        label: getTranslated('house', context) ?? 'House',
        value: deliveryAddress.houseNumber!,
      ));
    }
    
    if (deliveryAddress.floorNumber != null && deliveryAddress.floorNumber!.isNotEmpty) {
      details.add(_AddressDetailChip(
        label: getTranslated('floor', context) ?? 'Floor',
        value: deliveryAddress.floorNumber!,
      ));
    }
    
    return details.isEmpty 
        ? const SizedBox.shrink()
        : Wrap(
            spacing: Dimensions.paddingSizeSmall,
            runSpacing: 4,
            children: details,
          );
  }
}

class _AddressDetailChip extends StatelessWidget {
  final String label;
  final String value;
  
  const _AddressDetailChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
      ),
      child: Text(
        '$label: $value',
        style: poppinsRegular.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }
}

class _DeliverySectionShimmer extends StatelessWidget {
  const _DeliverySectionShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header shimmer
            Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).shadowColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Container(
                  height: 32,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            
            // Content shimmer
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _ShimmerRow(),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  _ShimmerRow(),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  Container(
                    height: 1,
                    color: Theme.of(context).shadowColor.withOpacity(0.3),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  _ShimmerRow(),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Row(
                    children: [
                      Container(
                        height: 24,
                        width: 24,
                        decoration: BoxDecoration(
                          color: Theme.of(context).shadowColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              height: 14,
                              decoration: BoxDecoration(
                                color: Theme.of(context).shadowColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  height: 20,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).shadowColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  height: 20,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).shadowColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 24,
          width: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).shadowColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeDefault),
        Expanded(
          child: Container(
            height: 14,
            decoration: BoxDecoration(
              color: Theme.of(context).shadowColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }
}