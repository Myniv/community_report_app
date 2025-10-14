import 'package:community_report_app/custom_theme.dart';
import 'package:community_report_app/models/community_post_update.dart';
import 'package:community_report_app/models/discussion.dart';
import 'package:community_report_app/models/enum_list.dart';
import 'package:community_report_app/provider/community_post_provider.dart';
import 'package:community_report_app/provider/community_post_update_provider.dart';
import 'package:community_report_app/provider/discussion_provider.dart';
import 'package:community_report_app/provider/profileProvider.dart';
import 'package:community_report_app/routes.dart';
import 'package:community_report_app/widgets/no_item.dart';
import 'package:community_report_app/widgets/post_section.dart';
import 'package:community_report_app/widgets/tab_bar_delegate.dart';
import 'package:community_report_app/widgets/text_container.dart';
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: CustomTheme.green),
          title: Text(
            "Detail Report",
            style: CustomTheme().smallFont(
              CustomTheme.green,
              FontWeight.bold,
              context,
            ),
          ),
        ),
        body: communityPost == null
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: TabBarDelegate(
                        const TabBar(
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.green,
                          tabs: [
                            Tab(text: "Discussions"),
                            Tab(text: "Progress"),
                          ],
                        ),
                      ),
                    ),
                  ],
                  body: TabBarView(
                    children: [
                      _buildDiscussionTab(
                        context,
                        communityPost.discussions,
                        widget.postId,
                        communityPost,
                      ),
                      _buildPostUpdatesTab(
                        context,
                        communityPost.communityPostUpdates,
                        widget.postId,
                        communityPost.status!,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

Widget _buildDiscussionTab(
  BuildContext context,
  List<Discussion> discussions,
  int postId,
  communityPost,
) {
  final discussionProvider = Provider.of<DiscussionProvider>(context);
  final profile = context.watch<ProfileProvider>().profile;
  return Expanded(
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
          isNavigateDisable: true,
        ),

        const SizedBox(height: 30),
        Padding(
          padding: EdgeInsetsGeometry.fromLTRB(20, 0, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Discussions (${discussions.length})",
                style: CustomTheme().superSmallFont(
                  Colors.black,
                  FontWeight.bold,
                  context,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Divider(thickness: 1, color: Colors.grey, indent: 16, endIndent: 16),
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: discussions.length,
            itemBuilder: (context, index) {
              final comment = discussions[index];
              return ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      (comment.userPhoto != null &&
                          comment.userPhoto!.isNotEmpty)
                      ? NetworkImage(comment.userPhoto!)
                      : null,
                  child:
                      (comment.userPhoto == null || comment.userPhoto!.isEmpty)
                      ? const Icon(Icons.person, size: 20)
                      : null,
                ),
                title: Text(comment.username ?? 'Unknown'),
                subtitle: Text(comment.message ?? ''),
                trailing: (profile?.uid == comment.userId)
                    ? PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            discussionProvider.editMessageController.text =
                                comment.message ?? '';

                            showDialog(
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  title: const Text("Edit Comment"),
                                  content: TextField(
                                    controller: discussionProvider
                                        .editMessageController,
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
                                                discussionId:
                                                    comment.discussionId,
                                                userId: comment.userId,
                                                communityPostId:
                                                    comment.communityPostId,
                                                message: newMessage,
                                              )
                                              .then((_) {
                                                Provider.of<
                                                      CommunityPostProvider
                                                    >(context, listen: false)
                                                    .fetchPost(postId);
                                              });

                                          if (context.mounted) {
                                            Navigator.of(ctx).pop();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Comment updated!",
                                                ),
                                              ),
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
                                .deleteDiscussion(comment.discussionId!)
                                .then((_) {
                                  // Refresh the post to reflect deletion
                                  Provider.of<CommunityPostProvider>(
                                    context,
                                    listen: false,
                                  ).fetchPost(postId);
                                });
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text("Edit"),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text("Delete"),
                          ),
                        ],
                      )
                    : null,
              );
            },
            separatorBuilder: (context, index) => const Divider(
              thickness: 1,
              color: Colors.grey,
              indent: 16,
              endIndent: 16,
            ),
          ),
        ),

        // Input Discussion
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: discussionProvider.messageController,
                  decoration: InputDecoration(
                    hintText: "Write a comment...",
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: () {
                  final message = discussionProvider.messageController.text
                      .trim();
                  if (message.isNotEmpty && profile != null) {
                    discussionProvider
                        .createDiscussion(
                          userId: profile.uid,
                          communityPostId: postId,
                          message: message,
                        )
                        .then((_) {
                          discussionProvider.messageController.clear();
                          Provider.of<CommunityPostProvider>(
                            context,
                            listen: false,
                          ).fetchPost(postId);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Comment posted successfully!"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        });
                  }
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildPostUpdatesTab(
  BuildContext context,
  List<CommunityPostUpdate> communityPostUpdates,
  int postId,
  String communityPostStatus,
) {
  final profile = context.watch<ProfileProvider>().profile;
  return Expanded(
    child: communityPostUpdates.isEmpty
        ? Column(
            children: [
              const NoItem(
                title: "No Progress Yet",
                subTitle: "There are no progress on this post.",
              ),
              if (profile?.role == RoleItem.leader.displayName)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.addCommunityPostUpdate,
                          arguments: {'postId': postId},
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add Progress"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          )
        : Column(
            children: [
              const SizedBox(height: 30),
              Padding(
                padding: EdgeInsetsGeometry.fromLTRB(20, 0, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Progress (${communityPostUpdates.length})",
                      style: CustomTheme().superSmallFont(
                        Colors.black,
                        FontWeight.bold,
                        context,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Divider(
                thickness: 1,
                color: Colors.grey,
                indent: 16,
                endIndent: 16,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: communityPostUpdates.length,
                  itemBuilder: (context, index) {
                    final communityPostUpdate = communityPostUpdates[index];
                    return buildPostUpdateSection(
                      context,
                      communityPostUpdate,
                      communityPostStatus,
                      profile!.role,
                    );
                  },
                ),
              ),
              if (profile!.role == RoleItem.leader.displayName &&
                  communityPostStatus != StatusItem.resolved.displayName)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.addCommunityPostUpdate,
                          arguments: {'postId': postId},
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add Progress"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
  );
}

Widget buildPostUpdateSection(
  BuildContext context,
  CommunityPostUpdate update,
  String communityPostStatus,
  String userRole,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📝 Header: Title or Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  update.title ?? "Progress Update",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextContainer(
                      text: update.isResolved! ? 'Resolved' : 'Not Resolved',
                      // useIcon: update.isResolved! ? true : false,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      CustomTheme().timeAgo(update.createdAt!),
                      style: const TextStyle(
                        color: Color(0xFF249A00),
                        fontSize: 13,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (communityPostStatus !=
                            StatusItem.resolved.displayName &&
                        userRole == RoleItem.leader.displayName)
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.black,
                          size: 24,
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.editCommunityPostUpdate,
                              arguments: {
                                'postId': update.communityPostId,
                                'communityPostUpdateId':
                                    update.communityPostUpdateId,
                              },
                            );
                          } else if (value == 'delete') {
                            CommunityPostUpdateProvider()
                                .deleteCommunityPostUpdate(
                                  update.communityPostUpdateId!,
                                )
                                .then((_) {
                                  Provider.of<CommunityPostProvider>(
                                    context,
                                    listen: false,
                                  ).fetchPost(update.communityPostId);
                                });
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text("Edit"),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text("Delete"),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 📃 Description
            Text(
              update.description ?? "",
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 12),

            // 📸 Image preview (optional)
            if (update.photo != null && update.photo!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _showImagePopup(context, update.photo!);
                  },
                  icon: const Icon(Icons.image_outlined),
                  label: const Text(
                    'Show Image',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

void _showImagePopup(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              // zoom in / out
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    },
  );
}
