import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../config/app_text_style.dart';
import '../../../../config/theme.dart';
import '../../../../controllers/common/master_controller.dart';
import '../../../../models/common/master_model.dart';

class CurrencyLayout extends ConsumerStatefulWidget {
  const CurrencyLayout({super.key});
  static TextEditingController searchController = TextEditingController();
  @override
  ConsumerState<CurrencyLayout> createState() => _CurrencyLayoutState();
}

class _CurrencyLayoutState extends ConsumerState<CurrencyLayout> {
  List<Currencies> currencyList = [];
  @override
  void initState() {
    initCurrency();

    super.initState();
  }

  void initCurrency() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        currencyList = ref
            .read(masterControllerProvider.notifier)
            .materModel
            .data
            .currencies;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors(context).accentColor,
      appBar: AppBar(
        toolbarHeight: 70.h,
        title: Text('Currency'),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 8.h),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 16.h),
          itemCount: currencyList.length,
          itemBuilder: ((context, index) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _buildCurrencyCard(
                  index,
                  context,
                  currencyList[index],
                  ref.watch(currencyProvider).name == currencyList[index].name,
                ),
              )),
        ),
      ),
    );
  }

  Widget _buildCurrencyCard(
      int index, BuildContext context, Currencies currency, bool isSelected) {
    return Material(
      color: colors(context).accentColor,
      borderRadius: BorderRadius.circular(5.r),
      child: Consumer(builder: (context, ref, _) {
        return InkWell(
          borderRadius: BorderRadius.circular(5.r),
          onTap: () {
            Currency currencyData = Currency(
                name: currency.name,
                symbol: currency.symbol,
                position: ref
                    .read(masterControllerProvider.notifier)
                    .materModel
                    .data
                    .currency
                    .position,
                rate: currency.rate);
            ref.read(currencyProvider.notifier).updateCurrency(currencyData);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  child: Row(
                    children: [
                      Text(
                        currency.symbol,
                        style: AppTextStyle(context).bodyText,
                      ),
                      Gap(20.w),
                      Text(
                        currency.name,
                        style: AppTextStyle(context).bodyText,
                      )
                    ],
                  ),
                ),
                if (isSelected) ...[
                  SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      fillColor:
                          WidgetStateProperty.all(colors(context).primaryColor),
                      visualDensity: VisualDensity.compact,
                      value: true,
                      onChanged: (value) {},
                    ),
                  )
                ]
              ],
            ),
          ),
        );
      }),
    );
  }
}
