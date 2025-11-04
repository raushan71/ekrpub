// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:ekray/config/app_constants.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/models/common/blog_details.dart';
import 'package:ekray/utils/context_less_navigation.dart';
import 'package:ekray/utils/global_function.dart';
import 'package:ekray/views/common/blog/componants/social_platform_card.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/theme.dart';
import '../../../../controllers/common/blog_controller.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../routes.dart';
import '../../../eCommerce/home/components/popular_product_card.dart';
import '../componants/blog_card.dart';

class BlogDetailsLayout extends ConsumerWidget {
  final int blogId;
  const BlogDetailsLayout({
    super.key,
    required this.blogId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blogDetailsState = ref.watch(blogDetailsProvder(blogId));
    return Scaffold(
      backgroundColor: colors(context).accentColor,
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Blog Details'),
      ),
      body: blogDetailsState.when(
        data: (data) => SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _BlogDetails(blogDetails: data),
              if (data.data.blog.tags.isNotEmpty) ...[
                Gap(16.h),
                _RelatedKeywordWidget(blogDetails: data),
              ],
              Gap(16.h),
              _SocialNetworkWidget(blogDetails: data),
              if (data.data.relatedBlogs.isNotEmpty) ...[
                Gap(16.h),
                _RelatedBlogsWidget(blogDetails: data),
              ],
              Gap(16.h),
              _RelatedProducts(blogDetails: data),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Text(error.toString()),
      ),
    );
  }
}

class _BlogDetails extends StatelessWidget {
  final BlogDetails blogDetails;
  const _BlogDetails({
    required this.blogDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: GlobalFunction.getContainerColor(),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _categoryCardWidget(context: context),
          Gap(6.h),
          Text(
            blogDetails.data.blog.title,
            style: AppTextStyle(context)
                .title
                .copyWith(fontWeight: FontWeight.w700),
          ),
          Gap(6.h),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 22.r,
              backgroundImage: CachedNetworkImageProvider(
                blogDetails.data.blog.postBy.profilePhoto,
              ),
            ),
            trailing: SizedBox(
              width: 40.w,
              child: Row(
                children: [
                  SvgPicture.asset(Assets.svg.eye),
                  Gap(5.w),
                  Text(
                    blogDetails.data.blog.totalViews.toString(),
                    style: AppTextStyle(context).bodyTextSmall,
                  ),
                ],
              ),
            ),
            title: Text(
              blogDetails.data.blog.postBy.name,
              style: AppTextStyle(context)
                  .bodyText
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              blogDetails.data.blog.createdAt,
              style: AppTextStyle(context).bodyTextSmall,
            ),
          ),
          Gap(16.h),
          _thumbnailWidget(context: context),
          Gap(16.h),
          _flutterHtmlWidget(),
        ],
      ),
    );
  }

  Widget _categoryCardWidget({required BuildContext context}) {
    return IntrinsicWidth(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Center(
          child: Text(
            blogDetails.data.blog.category.name,
            style: AppTextStyle(context)
                .bodyTextSmall
                .copyWith(color: Theme.of(context).primaryColor),
          ),
        ),
      ),
    );
  }

  Widget _thumbnailWidget({required BuildContext context}) {
    return CachedNetworkImage(
      imageUrl: blogDetails.data.blog.thumbnail,
      height: 136.h,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }

  Widget _flutterHtmlWidget() {
    return Html(data: blogDetails.data.blog.description);
  }
}

class _RelatedKeywordWidget extends StatelessWidget {
  final BlogDetails blogDetails;
  const _RelatedKeywordWidget({required this.blogDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(12.r),
      width: double.infinity,
      decoration: BoxDecoration(
        color: GlobalFunction.getContainerColor(),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Related Keywords',
            style: AppTextStyle(context).buttonText,
          ),
          Gap(8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: List.generate(blogDetails.data.blog.tags.length, (index) {
              var tag = blogDetails.data.blog.tags[index];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  color: colors(context).accentColor,
                ),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                child: Text(
                  tag.name,
                  style: AppTextStyle(context)
                      .bodyTextSmall
                      .copyWith(color: colors(context).bodyTextColor),
                ),
              );
            }),
          )
        ],
      ),
    );
  }
}

class _SocialNetworkWidget extends StatelessWidget {
  final BlogDetails blogDetails;
  _SocialNetworkWidget({required this.blogDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(12.r),
      width: double.infinity,
      decoration: BoxDecoration(
        color: GlobalFunction.getContainerColor(),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share with your network',
            style: AppTextStyle(context).buttonText,
          ),
          Gap(8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                socialNetworks.length,
                (index) => SocialPlatformCard(
                  icon: socialNetworks[index]['icon'],
                  color: Color(
                    int.parse(socialNetworks[index]['color']!),
                  ),
                  onTap: () => _redirectToPlatform(
                    platform: socialNetworks[index]['name'],
                    slug: blogDetails.data.blog.slug,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Map> socialNetworks = [
    {
      'icon': Assets.svg.facebook,
      'name': 'Facebook',
      'color': '0xFF0D68F1',
    },
    {
      'icon': Assets.svg.linkedIn,
      'name': 'Linkedin',
      'color': '0xFF1275B1',
    },
    {
      'icon': Assets.svg.twitter,
      'name': 'Twitter',
      'color': '0xFF47ACDF',
    },
    {
      'icon': Assets.svg.pinterest,
      'name': 'Pinterest',
      'color': '0xFFBB0F23',
    }
  ];

  Future<void> _redirectToPlatform({
    required String platform,
    required String slug,
  }) async {
    try {
      String contentUrl =
          '${AppConstants.baseUrl.replaceFirst('/api', '/blog')}/$slug';

      if (!Uri.tryParse(contentUrl)!.hasAbsolutePath) {
        throw 'Invalid content URL: $contentUrl';
      }

      String url = '';
      switch (platform.toLowerCase()) {
        case 'facebook':
          url = 'https://www.facebook.com/share/share.php?u=$contentUrl';
          break;
        case 'linkedin':
          url =
              'https://www.linkedin.com/shareArticle?mini=true&url=$contentUrl';
          break;
        case 'twitter':
          url = 'https://www.twitter.com/share?url=$contentUrl';
          break;
        case 'pinterest':
          url = 'https://www.pinterest.com/pin/create/button/?url=$contentUrl';
          break;
        default:
          throw 'Unsupported platform: $platform';
      }

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        print('Could not launch $url');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

class _RelatedProducts extends StatelessWidget {
  final BlogDetails blogDetails;
  const _RelatedProducts({required this.blogDetails});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Related Products',
            style: AppTextStyle(context).subTitle.copyWith(fontSize: 20.sp),
          ),
        ),
        Gap(16.h),
        SizedBox(
          height: 300.h,
          child: ListView.builder(
            padding: EdgeInsets.only(left: 20.w),
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: blogDetails.data.relatedProducts.length,
            itemBuilder: ((context, index) {
              final product = blogDetails.data.relatedProducts[index];
              return PopularProductCard(
                product: product,
                onTap: () {
                  context.nav.popAndPushNamed(
                    Routes.getProductDetailsRouteName(
                        AppConstants.appServiceName),
                    arguments: product.id,
                  );
                },
              );
            }),
          ),
        )
      ],
    );
  }
}

class _RelatedBlogsWidget extends StatelessWidget {
  final BlogDetails blogDetails;
  const _RelatedBlogsWidget({required this.blogDetails});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Related Blogs',
            style: AppTextStyle(context).subTitle.copyWith(fontSize: 20.sp),
          ),
        ),
        Gap(16.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
              blogDetails.data.relatedBlogs.length,
              (index) {
                final blog = blogDetails.data.relatedBlogs[index];
                return SizedBox(
                  width: MediaQuery.of(context).size.width - 40.w,
                  child: BlogCardWidget(blog: blog),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
