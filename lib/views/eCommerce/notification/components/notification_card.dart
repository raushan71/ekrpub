import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ekray/config/app_text_style.dart';
import 'package:ekray/config/theme.dart';
import 'package:ekray/models/eCommerce/notification/notification.dart';
import 'package:ekray/utils/global_function.dart';

class NotificationCard extends StatefulWidget {
  final NotificationModel notification;

  const NotificationCard({super.key, required this.notification});

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  bool isMultiline = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: _buildBorder(context),
      tileColor: _getTileColor(context),
      leading: _buildLeading(),
      title: _buildTitle(context),
      subtitle: _buildSubtitle(context),
    );
  }

  Border? _buildBorder(BuildContext context) {
    return Border.all(
      color: isMultiline ? colors(context).primaryColor! : Colors.transparent,
    );
  }

  Color _getTileColor(BuildContext context) {
    return widget.notification.isRead
        ? GlobalFunction.getContainerColor()
        : colors(context).primaryColor!.withOpacity(0.3);
  }

  Widget _buildLeading() {
    return SizedBox(
      width: 47.w,
      child: Row(
        children: [
          _buildReadIndicator(),
          Gap(3.w),
          _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildReadIndicator() {
    return SizedBox(
      width: 5,
      child: widget.notification.isRead
          ? Container()
          : CircleAvatar(
              radius: 3.r,
              backgroundColor: colors(context).primaryColor,
            ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 38.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors(context).accentColor!),
        image: const DecorationImage(
          image: CachedNetworkImageProvider(
            'https://ekray.com/assets/favicon.png',
            maxWidth: 30,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.notification.title,
            maxLines: isMultiline ? 5 : 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle(context).bodyText,
          ),
        ),
        Gap(5.w),
        _buildExpandIcon(),
      ],
    );
  }

  Widget _buildExpandIcon() {
    return InkWell(
      onTap: () => setState(() => isMultiline = !isMultiline),
      child: Icon(
        isMultiline ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.notification.createdAt,
              style: AppTextStyle(context).bodyTextSmall,
            ),
            Gap(8.w),
            CircleAvatar(
              radius: 2,
              backgroundColor: colors(context).bodyTextSmallColor!,
            ),
            Gap(8.w),
            Text(
              '10 days ago',
              style: AppTextStyle(context).bodyTextSmall,
            ),
          ],
        ),
      ],
    );
  }
}
