import 'package:flutter/material.dart';

import 'layouts/blog_details_layout.dart';

class BlogDetailsView extends StatelessWidget {
  final int blogId;
  const BlogDetailsView({
    super.key,
    required this.blogId,
  });

  @override
  Widget build(BuildContext context) {
    return BlogDetailsLayout(
      blogId: blogId,
    );
  }
}
