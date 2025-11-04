import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ekray/components/ecommerce/custom_search_field.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/generated/l10n.dart';
import 'package:ekray/services/common/hive_service_provider.dart';

class LanguageLayout extends ConsumerStatefulWidget {
  const LanguageLayout({super.key});
  static TextEditingController searchController = TextEditingController();
  @override
  ConsumerState<LanguageLayout> createState() => _LanguageLayoutState();
}

class _LanguageLayoutState extends ConsumerState<LanguageLayout> {
  List<Map<String, dynamic>> filteredLanguageList = [];
  @override
  void initState() {
    filteredLanguageList = languageList;
    initLanguage();
    super.initState();
  }

  void initLanguage() async {
    ref.read(hiveServiceProvider).getAppLocal().then((appLocal) {
      if (appLocal == null) {
        ref.read(hiveServiceProvider).saveAppLocal(local: 'en').whenComplete(
            () => debugPrint('Initial app local is save on local'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors(context).accentColor,
      appBar: AppBar(
        toolbarHeight: 70.h,
        title: CustomSearchField(
          name: 'Search',
          hintText: S.of(context).searchCountryName,
          textInputType: TextInputType.text,
          controller: LanguageLayout.searchController,
          widget: const SizedBox(),
          onChanged: (value) {
            filterCountries(value.toString());
          },
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 8.h),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 16.h),
          itemCount: filteredLanguageList.length,
          itemBuilder: ((context, index) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _buildLanguageCard(
                  index,
                  context,
                  filteredLanguageList[index]['languageCode'],
                ),
              )),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(int index, BuildContext context, String appLocal) {
    return ValueListenableBuilder(
        valueListenable: Hive.box(AppConstants.appSettingsBox).listenable(),
        builder: (context, box, _) {
          final appLocalHive = box.get(AppConstants.appLocal);
          return Material(
            color: colors(context).accentColor,
            borderRadius: BorderRadius.circular(5.r),
            child: Consumer(builder: (context, ref, _) {
              return InkWell(
                borderRadius: BorderRadius.circular(5.r),
                onTap: () {
                  ref.read(hiveServiceProvider).saveAppLocal(local: appLocal);
                },
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3.r),
                              child: CachedNetworkImage(
                                imageUrl: filteredLanguageList[index]['flag'],
                                width: 40.w,
                              ),
                            ),
                            Gap(20.w),
                            Text(
                              filteredLanguageList[index]['name'],
                              style: AppTextStyle(context).bodyText,
                            )
                          ],
                        ),
                      ),
                      if (appLocalHive != null && appLocalHive == appLocal) ...[
                        SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: Checkbox(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              fillColor: WidgetStateProperty.all(
                                  colors(context).primaryColor),
                              visualDensity: VisualDensity.compact,
                              value: true,
                              onChanged: (value) {}),
                        )
                      ]
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }

  void filterCountries(String query) {
    setState(() {
      filteredLanguageList = languageList
          .where((country) =>
              country['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  static List<Map<String, dynamic>> languageList = [
    {
      "name": "United States",
      "flag":
          "https://flagdownload.com/wp-content/uploads/Flag_of_United_States-1024x539.png",
      "languageCode": "en",
    },
    {
      "name": "Saudi Arabia",
      "flag":
          "https://flagdownload.com/wp-content/uploads/Flag_of_Saudi_Arabia-1024x683.png",
      "languageCode": "ar",
    },
    {
      "name": "Bangladesh",
      "flag":
          "https://flagdownload.com/wp-content/uploads/Flag_of_Bangladesh-1024x613.png",
      "languageCode": "bn",
    },
  ];
}
