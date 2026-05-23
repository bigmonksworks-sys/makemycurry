import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/enums/data_source_enum.dart';
import 'package:flutter_grocery/common/models/api_response_model.dart';
import 'package:flutter_grocery/common/models/product_model.dart';
import 'package:flutter_grocery/features/wishlist/domain/reposotories/wishlist_repo.dart';
import 'package:flutter_grocery/helper/api_checker_helper.dart';
import 'package:flutter_grocery/helper/data_sync_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';


class WishListProvider extends ChangeNotifier {
  final WishListRepo? wishListRepo;

  WishListProvider({required this.wishListRepo}) {
    _wishList = [];
    _wishIdList = [];
  }

  List<Product>? _wishList;
  List<Product>? get wishList => _wishList;
  Product? _product;
  Product? get product => _product;
  List<int?> _wishIdList = [];
  List<int?> get wishIdList => _wishIdList;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool isWishlist(int? productId, {int? subVariantId}) {
    if (productId == null) return false;
    return _wishList?.any((element) => element.id == productId && element.selectedSubVariantId == subVariantId) ?? false;
  }

  void addToWishList(Product product, BuildContext context, {int? subVariantId}) async {
    Product wishProduct = Product.fromJson(product.toJson());
    wishProduct.selectedSubVariantId = subVariantId;
    if (subVariantId != null && product.subVariants != null) {
      try {
        wishProduct.selectedSubVariant = product.subVariants!.firstWhere((element) => element.id == subVariantId);
      } catch (e) {
        wishProduct.selectedSubVariant = null;
      }
    } else {
      wishProduct.selectedSubVariant = null;
    }

    _wishList!.add(wishProduct);
    _wishIdList.add(product.id);
    notifyListeners();
    ApiResponseModel apiResponse = await wishListRepo!.addWishList(
      [product.id], 
      subVariantIDs: subVariantId != null ? [subVariantId] : null
    );
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      showCustomSnackBarHelper('item_added_to'.tr, isError: false);
    } else {
      _wishList!.removeWhere((element) => element.id == product.id && element.selectedSubVariantId == subVariantId);
      _wishIdList.remove(product.id);
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
  }

  void removeFromWishList(Product product, BuildContext context, {int? subVariantId}) async {
    Product? toRemove;
    try {
      toRemove = _wishList!.firstWhere((element) => element.id == product.id && element.selectedSubVariantId == subVariantId);
    } catch (e) {
      // not found
    }
    if (toRemove != null) {
      _wishList!.remove(toRemove);
    }
    _wishIdList.remove(product.id);
    notifyListeners();
    ApiResponseModel apiResponse = await wishListRepo!.removeWishList(
      [product.id], 
      subVariantIDs: subVariantId != null ? [subVariantId] : null
    );
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      showCustomSnackBarHelper('item_removed_from'.tr, isError: false);
    } else {
      if (toRemove != null) {
        _wishList!.add(toRemove);
      }
      _wishIdList.add(product.id);
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
  }

  Future<void> getWishListProduct() async {
    _isLoading = true;
    await DataSyncHelper.fetchAndSyncData(
      fetchFromLocal: () => wishListRepo!.getWishList(source: DataSourceEnum.local),
      fetchFromClient: () => wishListRepo!.getWishList(source: DataSourceEnum.client),
      onResponse: (data, _) {
        // debugPrint('WishList Response: $data');
        _wishList = [];
        _wishIdList = [];
        if (data != null) {
          if (data is List) {
            for (var v in data) {
              try {
                _wishList!.add(Product.fromJson(v));
              } catch (e) {
                debugPrint('Error parsing product in wishlist: $e');
              }
            }
          } else if (data is Map && data['products'] != null) {
            for (var v in data['products']) {
              try {
                _wishList!.add(Product.fromJson(v));
              } catch (e) {
                debugPrint('Error parsing product in wishlist: $e');
              }
            }
          }
          
          for(int i = 0; i< _wishList!.length; i++){
            _wishIdList.add(_wishList![i].id);
          }
        }
        notifyListeners();
      },
    );
    _isLoading = false;
    notifyListeners();
  }

  void clearWishList(){
    _wishIdList = [];
    _wishIdList = [];
  }
}
