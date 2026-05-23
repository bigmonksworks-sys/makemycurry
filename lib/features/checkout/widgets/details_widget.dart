import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/checkout/domain/models/check_out_model.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/features/checkout/widgets/image_note_upload_widget.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/custom_shadow_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_text_field_widget.dart';
import 'package:flutter_grocery/features/checkout/widgets/payment_section_widget.dart';
import 'package:provider/provider.dart';

class DetailsWidget extends StatefulWidget {
  const DetailsWidget({
    super.key,
    required this.paymentList,
    required this.noteController,
  });

  final List<PaymentMethod> paymentList;
  final TextEditingController noteController;

  @override
  State<DetailsWidget> createState() => _DetailsWidgetState();
}

class _DetailsWidgetState extends State<DetailsWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final FocusNode _noteFocusNode = FocusNode();
  bool _isNoteExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _noteFocusNode.addListener(() {
      setState(() {
        _isNoteExpanded = _noteFocusNode.hasFocus;
      });
    });
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CheckOutModel? checkOutData = Provider.of<OrderProvider>(context, listen: false).getCheckOutData;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment Method Section
          _PaymentSectionWrapper(
            total: (checkOutData?.amount ?? 0) + (checkOutData?.deliveryCharge ?? 0),
          ),

          // Image Note Upload Section
          _ImageNoteSection(),

          // Delivery Note Section
          _DeliveryNoteSection(
            noteController: widget.noteController,
            focusNode: _noteFocusNode,
            isExpanded: _isNoteExpanded,
          ),
        ],
      ),
    );
  }
}

class _PaymentSectionWrapper extends StatelessWidget {
  final double total;
  
  const _PaymentSectionWrapper({required this.total});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: PaymentMethodSelectionWidget(total: total),
    );
  }
}

class _ImageNoteSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: const ImageNoteUploadWidget(),
    );
  }
}

class _DeliveryNoteSection extends StatefulWidget {
  final TextEditingController noteController;
  final FocusNode focusNode;
  final bool isExpanded;
  
  const _DeliveryNoteSection({
    required this.noteController,
    required this.focusNode,
    required this.isExpanded,
  });

  @override
  State<_DeliveryNoteSection> createState() => _DeliveryNoteSectionState();
}

class _DeliveryNoteSectionState extends State<_DeliveryNoteSection> with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeInOut),
    );
    
    widget.noteController.addListener(() {
      setState(() {
        _characterCount = widget.noteController.text.length;
      });
    });
    
    _characterCount = widget.noteController.text.length;
  }

  @override
  void didUpdateWidget(_DeliveryNoteSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomShadowWidget(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault, 
        vertical: Dimensions.paddingSizeSmall
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit_note,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated('add_delivery_note', context),
                      style: poppinsMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                   
                  ],
                ),
              ),
             
            ],
          ),
          
          const SizedBox(height: Dimensions.paddingSizeDefault),
          
          // Text Field Section
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: widget.isExpanded 
                  ? Theme.of(context).primaryColor.withOpacity(0.02)
                  : Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
              border: Border.all(
                color: widget.isExpanded
                    ? Theme.of(context).primaryColor.withOpacity(0.3)
                    : Theme.of(context).dividerColor,
                width: widget.isExpanded ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                CustomTextFieldWidget(
                  fillColor: Colors.transparent,
                  isShowBorder: false,
                  controller: widget.noteController,
                  focusNode: widget.focusNode,
                  hintText: getTranslated('', context) ?? 'Type your delivery instructions here...',
                  // hintStyle: poppinsRegular.copyWith(
                  //   color: Theme.of(context).hintColor.withOpacity(0.8),
                  //   fontSize: Dimensions.fontSizeDefault,
                  // ),
                  maxLines: widget.isExpanded ? 6 : 3,
                  // maxLength: 500,
                  inputType: TextInputType.multiline,
                  inputAction: TextInputAction.newline,
                  capitalization: TextCapitalization.sentences,
                  // contentPadding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                ),
                
                // Character Counter and Helper Text
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: widget.isExpanded ? Container(
                    padding: const EdgeInsets.fromLTRB(
                      Dimensions.paddingSizeDefault,
                      0,
                      Dimensions.paddingSizeDefault,
                      Dimensions.paddingSizeSmall,
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 1,
                          color: Theme.of(context).dividerColor.withOpacity(0.3),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _SuggestionChips(),
                            ),
                            Text(
                              '$_characterCount/500',
                              style: poppinsRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: _characterCount > 450 
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ) : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final suggestions = [
      getTranslated('ring_doorbell', context) ?? 'Ring doorbell',
      getTranslated('leave_at_door', context) ?? 'Leave at door',
      getTranslated('call_on_arrival', context) ?? 'Call on arrival',
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: suggestions.map((suggestion) => _SuggestionChip(
        label: suggestion,
        onTap: () => _addSuggestion(context, suggestion),
      )).toList(),
    );
  }

  void _addSuggestion(BuildContext context, String suggestion) {
    // This would need to be passed down or accessed via Provider
    // For now, just showing the UI structure
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  
  const _SuggestionChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                size: 12,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: poppinsRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}