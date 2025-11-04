import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/gen/assets.gen.dart';
import 'package:ekray/models/common/blog.dart';
import 'package:ekray/utils/context_less_navigation.dart';

import '../../../../config/theme.dart';
import '../../../../routes.dart';
import '../../../../utils/global_function.dart';

class BlogCardWidget extends StatelessWidget {
  final Blogs blog;
  const BlogCardWidget({
    super.key,
    required this.blog,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.nav.pushNamed(
        Routes.blogDetails,
        arguments: blog.id,
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        height: 260.h,
        decoration: BoxDecoration(
          color: GlobalFunction.getContainerColor(),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colors(context).accentColor!, width: 2),
        ),
        child: Column(
          children: [
            _BlogImageWidget(
              imageUrl: blog.thumbnail,
              isNew: blog.isNew,
            ),
            Gap(12.h),
            _BlogTextWidget(blog: blog),
          ],
        ),
      ),
    );
  }
}

class _BlogImageWidget extends StatelessWidget {
  final String imageUrl;
  final bool isNew;
  const _BlogImageWidget({
    required this.imageUrl,
    required this.isNew,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.r),
            topRight: Radius.circular(12.r),
          ),
          child: SizedBox(
            height: 146.h,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: MediaQuery.of(context).size.width,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Assets.png.placeholderImage.image(
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              errorWidget: (context, url, error) =>
                  Assets.png.placeholderImage.image(
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
        if (isNew)
          Positioned(
            top: 12.h,
            left: 12.w,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2),
              child: Center(
                child: Text(
                  'New',
                  style: AppTextStyle(context)
                      .bodyText
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BlogTextWidget extends StatelessWidget {
  final Blogs blog;
  const _BlogTextWidget({required this.blog});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                blog.category.name,
                style: AppTextStyle(context)
                    .bodyTextSmall
                    .copyWith(color: Theme.of(context).primaryColor),
              ),
              Gap(6.h),
              Text(
                blog.title,
                style: AppTextStyle(context).buttonText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Gap(4.h),
              Text(
                blog.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle(context).bodyTextSmall,
              ),
              Gap(4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: 'By',
                            style: AppTextStyle(context).bodyTextSmall),
                        TextSpan(
                          text: ' ${blog.postBy.name}',
                          style: AppTextStyle(context).bodyTextSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors(context).bodyTextColor,
                              ),
                        ),
                        TextSpan(
                            text: ' - ',
                            style: AppTextStyle(context).bodyTextSmall),
                        TextSpan(
                            text: blog.createdAt,
                            style: AppTextStyle(context).bodyTextSmall),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      SvgPicture.asset(Assets.svg.eye),
                      Gap(5.w),
                      Text(
                        blog.totalViews.toString(),
                        style: AppTextStyle(context).bodyTextSmall,
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
