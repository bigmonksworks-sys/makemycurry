import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/search/providers/search_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_grocery/features/search/screens/search_result_screen.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int? pageSize;
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<SearchProvider>(context, listen: false).initHistoryList();
    Provider.of<SearchProvider>(context, listen: false).initializeAllSortBy(notify: false);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ResponsiveHelper.isDesktop(context)
          ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(getTranslated('search', context),
                  style: poppinsMedium.copyWith(fontSize: 20, color: Colors.black)),
              centerTitle: true,
            ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: Center(
            child: SizedBox(
              width: Dimensions.webScreenWidth,
              child: Consumer<SearchProvider>(
                builder: (context, searchProvider, child) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 15),
                          const Icon(Icons.search, color: Colors.grey, size: 20),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (text) {
                                if (text.isNotEmpty) {
                                  List<int> encoded = utf8.encode(text);
                                  String data = base64Encode(encoded);
                                  searchProvider.saveSearchAddress(text);
                                  Navigator.pushNamed(context, '${RouteHelper.searchResult}?text=$data', arguments: SearchResultScreen(searchString: text));
                                }
                              },
                              decoration: InputDecoration(
                                hintText: getTranslated('searchItem_here', context),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                hintStyle: poppinsRegular.copyWith(color: Colors.grey, fontSize: Dimensions.fontSizeDefault),
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    if (searchProvider.historyList.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            getTranslated('recent_search', context),
                            style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                          ),
                          TextButton(
                            onPressed: searchProvider.clearSearchAddress,
                            child: Text(
                              getTranslated('remove_all', context),
                              style: poppinsMedium.copyWith(color: Colors.red, fontSize: Dimensions.fontSizeDefault),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: ListView.builder(
                          itemCount: searchProvider.historyList.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.history, size: 18, color: Colors.grey),
                            ),
                            title: Text(
                              searchProvider.historyList[index]!,
                              style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                            ),
                            trailing: const Icon(Icons.north_west, size: 16, color: Colors.grey),
                            onTap: () {
                              List<int> encoded = utf8.encode(searchProvider.historyList[index]!);
                              String data = base64Encode(encoded);
                              searchProvider.getSearchProduct(offset: 1, query: searchProvider.historyList[index]!);
                              Navigator.pushNamed(context, '${RouteHelper.searchResult}?text=$data', arguments: SearchResultScreen(searchString: searchProvider.historyList[index]));
                            },
                          ),
                        ),
                      ),
                    ] else
                      Expanded(
                        child: Center(
                          child: Icon(Icons.search_off, size: 80, color: Colors.grey[200]),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
