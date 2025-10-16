import 'package:community_report_app/custom_theme.dart';
import 'package:community_report_app/models/discussion.dart';
import 'package:community_report_app/provider/discussion_provider.dart';
import 'package:community_report_app/provider/profileProvider.dart';
import 'package:community_report_app/widgets/post_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailDiscussionScreen extends StatefulWidget {
  final int discussionId;
  const DetailDiscussionScreen({super.key, required this.discussionId});

  @override
  State<DetailDiscussionScreen> createState() => _DetailDiscussionScreenState();
}

class _DetailDiscussionScreenState extends State<DetailDiscussionScreen> {
  @override
  void initState() {
    super.initState();
    final discussionProvider = Provider.of<DiscussionProvider>(
      context,
      listen: false,
    );
    discussionProvider.fetchDiscussionWithCommunityPost(widget.discussionId);
  }

  @override
  Widget build(BuildContext context) {
    final discussionProvider = context.watch<DiscussionProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: CustomTheme.green),
        title: Text(
          "Detail Discussion",
          style: CustomTheme().smallFont(
            CustomTheme.green,
            FontWeight.bold,
            context,
          ),
        ),
      ),
      body: discussionProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDetailDiscussion(
              context,
              discussionProvider.currentDiscussion!,
            ),
    );
  }
}

Widget _buildDetailDiscussion(BuildContext context, Discussion discussion) {
  final profile = context.watch<ProfileProvider>().profile;
  final discussionProvider = Provider.of<DiscussionProvider>(context);
  return Expanded(
    child: Column(
      children: [
        // Bagian Post
        PostSection(
          postId: discussion.communityPost!.id,
          profilePhoto: discussion.communityPost!.user_photo,
          username: discussion.communityPost!.username ?? "",
          title: discussion.communityPost!.title ?? "",
          description: discussion.communityPost!.description ?? "",
          category: discussion.communityPost!.category ?? "",
          urgency: discussion.communityPost!.urgency ?? "",
          status: discussion.communityPost!.status ?? "",
          location: discussion.communityPost!.location ?? "",
          latitude: discussion.communityPost!.latitude ?? 0.0,
          longitude: discussion.communityPost!.longitude ?? 0.0,
          createdAt: discussion.communityPost!.created_at ?? DateTime.now(),
          settingPostScreen: false,
          postImage: discussion.communityPost!.photo,
        ),

        const SizedBox(height: 30),
        const Divider(
          thickness: 1,
          color: Colors.grey,
          indent: 16,
          endIndent: 16,
        ),

        // Bagian Komentar Detail
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 24,
              backgroundImage:
                  (profile?.photo != null && profile!.photo!.isNotEmpty)
                  ? NetworkImage(profile.photo!)
                  : null,
              child: (profile?.photo == null || profile!.photo!.isEmpty)
                  ? const Icon(Icons.person, size: 22)
                  : null,
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    profile?.username ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  CustomTheme().timeAgo(discussion!.createdAt!),
                  style: const TextStyle(
                    color: Color(0xFF249A00),
                    fontSize: 13,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) {
                    if (value == 'edit') {
                      discussionProvider.editMessageController.text =
                          discussion.message ?? '';

                      showDialog(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            title: const Text("Edit Comment"),
                            content: TextField(
                              controller:
                                  discussionProvider.editMessageController,
                              decoration: const InputDecoration(
                                hintText: "Update your comment...",
                              ),
                              maxLines: null,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final newMessage = discussionProvider
                                      .editMessageController
                                      .text
                                      .trim();
                                  if (newMessage.isNotEmpty) {
                                    discussionProvider
                                        .updateDiscussion(
                                          discussionId: discussion.discussionId,
                                          userId: discussion.userId,
                                          communityPostId:
                                              discussion.communityPostId,
                                          message: newMessage,
                                        )
                                        .then((_) {
                                          Provider.of<DiscussionProvider>(
                                            context,
                                            listen: false,
                                          ).fetchDiscussionWithCommunityPost(
                                            discussion.discussionId,
                                          );
                                        });

                                    if (context.mounted) {
                                      Navigator.of(ctx).pop();
                                      CustomTheme().customScaffoldMessage(
                                        context: context,
                                        message:
                                            "Discussion editted successfully!",
                                        backgroundColor: Colors.green,
                                      );
                                    }
                                  }
                                },
                                child: const Text("Save"),
                              ),
                            ],
                          );
                        },
                      );
                    } else if (value == 'delete') {
                      discussionProvider
                          .deleteDiscussion(discussion.discussionId!)
                          .then((_) {
                            Provider.of<DiscussionProvider>(
                              context,
                              listen: false,
                            ).fetchDiscussionsList(userId: discussion.userId);
                            Navigator.of(context).pop();
                            CustomTheme().customScaffoldMessage(
                              context: context,
                              message: "Discussion deleted successfully!",
                              backgroundColor: Colors.green,
                            );
                          });
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text("Edit")),
                    const PopupMenuItem(value: 'delete', child: Text("Delete")),
                  ],
                ),
              ],
            ),
            subtitle: Text(
              discussion.message ?? '',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    ),
  );
}
