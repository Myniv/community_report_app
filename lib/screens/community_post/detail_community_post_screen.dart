import 'package:community_report_app/custom_theme.dart';
import 'package:community_report_app/provider/community_post_provider.dart';
import 'package:community_report_app/widgets/post_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailCommunityPostScreen extends StatefulWidget {
  final int postId;

  const DetailCommunityPostScreen({super.key, required this.postId});

  @override
  State<DetailCommunityPostScreen> createState() =>
      _DetailCommunityPostScreenState();
}

class _DetailCommunityPostScreenState extends State<DetailCommunityPostScreen> {
  @override
  void initState() {
    super.initState();

    final communityPostProvider = Provider.of<CommunityPostProvider>(
      context,
      listen: false,
    );
    communityPostProvider.fetchPost(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    final communityPost = context.watch<CommunityPostProvider>().currentPost;
    final TextEditingController commentController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: CustomTheme.green),
        title: Text(
          "Detail Post",
          style: CustomTheme().smallFont(
            CustomTheme.green,
            FontWeight.bold,
            context,
          ),
        ),
      ),
      body: communityPost == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  PostSection(
                    postId: communityPost.id,
                    profilePhoto: communityPost.user_photo,
                    username: communityPost.username ?? "",
                    title: communityPost.title ?? "",
                    description: communityPost.description ?? "",
                    category: communityPost.category ?? "",
                    urgency: communityPost.urgency ?? "",
                    status: communityPost.status ?? "",
                    location: communityPost.location ?? "",
                    latitude: communityPost.latitude ?? 0.0,
                    longitude: communityPost.longitude ?? 0.0,
                    createdAt: communityPost.created_at ?? DateTime.now(),
                    settingPostScreen: false,
                    postImage: communityPost.photo,
                    discussionCount: communityPost.discussions.length,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Comments (${communityPost.discussions.length})",
                    style: CustomTheme().smallFont(
                      Colors.black,
                      FontWeight.bold,
                      context,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(
                    thickness: 1,
                    color: Colors.grey,
                    indent: 16,
                    endIndent: 16,
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: communityPost.discussions.length,
                    itemBuilder: (context, index) {
                      final comment = communityPost.discussions[index];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              (comment.userPhoto != null &&
                                  comment.userPhoto!.isNotEmpty)
                              ? NetworkImage(comment.userPhoto!)
                              : null,
                          child:
                              (comment.userPhoto == null ||
                                  comment.userPhoto!.isEmpty)
                              ? const Icon(Icons.person, size: 20)
                              : null,
                        ),
                        title: Text(comment.username ?? 'Unknown'),
                        subtitle: Text(comment.message ?? ''),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(
                      thickness: 1,
                      color: Colors.grey,
                      indent: 16,
                      endIndent: 16,
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: "Write a comment...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: CustomTheme.green),
                onPressed: () {
                  final text = commentController.text.trim();
                  if (text.isNotEmpty) {
                    print("Send comment: $text");
                    commentController.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
