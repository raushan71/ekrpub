import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ekray/components/ecommerce/custom_search_field.dart';
import 'package:ekray/config/app_text_style.dart';

class CountryModelBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic> country) onChangeCountry;
  const CountryModelBottomSheet({
    super.key,
    required this.onChangeCountry,
  });

  @override
  State<CountryModelBottomSheet> createState() =>
      _CountryModelBottomSheetState();
}

class _CountryModelBottomSheetState extends State<CountryModelBottomSheet> {
  final controller = TextEditingController();
  List<Map<String, dynamic>> filteredList = [];
  List<Map<String, dynamic>> countryList = [];

  @override
  initState() {
    loadJson();
    super.initState();
  }

  // load json from assets
  void loadJson() async {
    String jsonString =
        await rootBundle.loadString('assets/json/countries.json');
    List json = jsonDecode(jsonString);
    List<Map<String, dynamic>> convertedList =
        json.map((item) => Map<String, dynamic>.from(item)).toList();
    setState(() {
      countryList = convertedList;
      filteredList = convertedList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          padding: EdgeInsets.only(top: 46.h),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                  filteredList[index]['emoji'] +
                      '  ' +
                      filteredList[index]['name'],
                  style: AppTextStyle(context).bodyText),
              trailing: Text(filteredList[index]['phone_code'],
                  style: AppTextStyle(context).bodyText),
              onTap: () {
                widget.onChangeCountry(filteredList[index]);
                Navigator.pop(context);
              },
            );
          },
        ),
        Positioned(
            top: 8.h,
            left: 16.w,
            right: 16.w,
            child: CustomSearchField(
              name: 'Country',
              hintText: 'Search Country',
              textInputType: TextInputType.text,
              controller: controller,
              widget: null,
              onChanged: (value) {
                filterCountries(value.toString());
              },
            )),
      ],
    );
  }

  void filterCountries(String query) {
    setState(() {
      filteredList = countryList
          .where((country) =>
              country['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
}

// final List<Map<String, dynamic>> countryList = [
//   {"name": "India", "code": "+91", "flag": "🇮🇳"},
//   {"name": "United States", "code": "+1", "flag": "🇺🇸"},
//   {"name": "United Kingdom", "code": "+44", "flag": "🇬🇧"},
//   {"name": "Germany", "code": "+49", "flag": "🇩🇪"},
//   {"name": "France", "code": "+33", "flag": "🇫🇷"},
//   {"name": "Spain", "code": "+34", "flag": "🇪🇸"},
//   {"name": "Italy", "code": "+39", "flag": "🇮🇹"},
//   {"name": "Brazil", "code": "+55", "flag": "🇧🇷"},
//   {"name": "Argentina", "code": "+54", "flag": "🇦🇷"},
//   {"name": "Mexico", "code": "+52", "flag": "🇲🇽"},
//   {"name": "Canada", "code": "+1", "flag": "🇨🇦"},
//   {"name": "Australia", "code": "+61", "flag": "🇦🇺"},
//   {"name": "New Zealand", "code": "+64", "flag": "🇳🇿"},
//   {"name": "South Africa", "code": "+27", "flag": "🇿🇦"},
//   {"name": "Nigeria", "code": "+234", "flag": "🇳🇬"},
//   {"name": "Ghana", "code": "+233", "flag": "🇬🇭"},
//   {"name": "Kenya", "code": "+254", "flag": "🇰🇪"},
//   {"name": "Tanzania", "code": "+255", "flag": "🇹🇿"},
//   {"name": "Uganda", "code": "+256", "flag": "🇺🇬"},
//   {"name": "Rwanda", "code": "+250", "flag": "🇷🇼"},
//   {"name": "Burundi", "code": "+257", "flag": "🇧🇮"},
//   {"name": "South Sudan", "code": "+211", "flag": "🇸🇸"},
// ];
