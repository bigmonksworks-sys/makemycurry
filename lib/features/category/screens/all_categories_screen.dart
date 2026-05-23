import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/common/widgets/main_app_bar_widget.dart';
import 'package:flutter_grocery/common/widgets/no_data_widget.dart';
import 'package:flutter_grocery/features/category/domain/models/category_model.dart';
import 'package:flutter_grocery/features/category/providers/category_provider.dart';
import 'package:flutter_grocery/features/category/widgets/category_item_widget.dart';
import 'package:flutter_grocery/features/category/widgets/sub_category_shimmer_widget.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {

  @override
  void initState() {
    super.initState();
    if(Provider.of<CategoryProvider>(context, listen: false).categoryList != null
        && Provider.of<CategoryProvider>(context, listen: false).categoryList!.isNotEmpty
    ) {
      _load();
    }else{
      Provider.of<CategoryProvider>(context, listen: false).getCategoryList(context,true).then((list) {
        if(list != null){
          _load();
        }

      });
    }

  }
  _load() async {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    categoryProvider.onChangeCategoryIndex(0, notify: false);

    if(categoryProvider.categoryList?.isNotEmpty ?? false) {
      categoryProvider.getSubCategoryList(context, categoryProvider.categoryList![0].id.toString());
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ?  const MainAppBarWidget(): null,
      body: Center(child: SizedBox(
        width: Dimensions.webScreenWidth,
        child: Consumer<CategoryProvider>(
          builder: (context, categoryProvider, child) {
            return categoryProvider.categoryList == null ? Center(
              child: CustomLoaderWidget(color: Theme.of(context).primaryColor),
            ) : categoryProvider.categoryList?.isNotEmpty ?? false ? Row(children: [
              Container(
                width: 120,
                margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                height: double.maxFinite,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(2, 0),
                    )
                  ],
                ),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: categoryProvider.categoryList!.length,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: Dimensions.paddingSizeSmall),
                  itemBuilder: (context, index) {
                    CategoryModel category = categoryProvider.categoryList![index];
                    return InkWell(
                      onTap: () {
                        categoryProvider.onChangeCategoryIndex(index);
                        categoryProvider.getSubCategoryList(context, category.id.toString());
                      },
                      child: CategoryItemWidget(
                        title: category.name,
                        icon: category.image,
                        isSelected: categoryProvider.categoryIndex == index,
                      ),
                    );
                  },
                ),
              ),

              categoryProvider.subCategoryList != null ? Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  itemCount: categoryProvider.subCategoryList!.length + 1,
                  itemBuilder: (context, index) {

                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12, top: 4),
                        child: Text(
                          getTranslated('sub_categories', context),
                          style: poppinsSemiBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      );
                    }
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: ListTile(
                        onTap: () {
                          categoryProvider.onChangeSelectIndex(index - 1);
                          categoryProvider.initCategoryProductList(
                            categoryProvider.subCategoryList![index - 1].id.toString(),
                          );

                          Navigator.of(context).pushNamed(
                            RouteHelper.getCategoryProductsRoute(
                              categoryId: '${categoryProvider.categoryList![categoryProvider.categoryIndex].id}',
                              subCategory: categoryProvider.subCategoryList![index - 1].name,
                            ),
                          );
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        title: Text(
                          categoryProvider.subCategoryList![index - 1].name!,
                          style: poppinsMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.9),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Theme.of(context).primaryColor.withValues(alpha: 0.5)),
                      ),
                    );
                  },
                ),
              ) : const Expanded(child: SubCategoriesShimmerWidget()),

            ]) :  NoDataWidget(title: getTranslated('category_not_found', context),);
          },
        ),
      )),
    );
  }
}


