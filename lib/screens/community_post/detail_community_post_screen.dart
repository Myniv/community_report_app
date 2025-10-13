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
    print(communityPost!.status!);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
            : SafeArea(
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(
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
                            createdAt:
                                communityPost.created_at ?? DateTime.now(),
                            settingPostScreen: false,
                            postImage: communityPost.photo,
                            discussionCount: communityPost.discussions.length,
                            isNavigateDisable: true,
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: TabBarDelegate(
                        const TabBar(
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.green,
                          tabs: [
                            Tab(text: "Discussions"),
                            Tab(text: "Post Updates"),
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
) {
  final discussionProvider = Provider.of<DiscussionProvider>(context);
  final profile = context.watch<ProfileProvider>().profile;
  return Expanded(
    child: Column(
      children: [
        const SizedBox(height: 30),
        Text(
          "Discussions (${discussions.length})",
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
                title: "No Post Updates Yet",
                subTitle: "There are no post updates on this post.",
              ),
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
                    label: const Text("Add Post Update"),
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
              Text(
                "Post Updates (${communityPostUpdates.length})",
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
                      label: const Text("Add Post Update"),
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
  CommunityPostUpdate communityPostUpdate,
  String communityPostStatus,
  String role,
) {
  final screenWidth = MediaQuery.of(context).size.width;
  final horizontalPadding = screenWidth * 0.07;

  final imageWidth = screenWidth - (horizontalPadding + 50 + horizontalPadding);
  final imageHeight = imageWidth * 0.6;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // ============================
      // Header (Profile & Status)
      // ============================
      Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          30,
          horizontalPadding,
          0,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage:
                  (communityPostUpdate.userPhoto != null &&
                      communityPostUpdate.userPhoto!.isNotEmpty)
                  ? NetworkImage(communityPostUpdate.userPhoto!)
                  : null,
              child:
                  (communityPostUpdate.userPhoto == null ||
                      communityPostUpdate.userPhoto!.isEmpty)
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              communityPostUpdate.username ?? '',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              CustomTheme().timeAgo(communityPostUpdate.createdAt!),
              style: const TextStyle(
                color: Color(0xFF249A00),
                fontSize: 13,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            TextContainer(
              text: communityPostUpdate.isResolved!
                  ? 'resolved'
                  : 'not resolved',
            ),
          ],
        ),
      ),

      // ============================
      // Title & Description
      // ============================
      Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding + 50,
          0,
          horizontalPadding,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              communityPostUpdate.title ?? '',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Text(
                communityPostUpdate.description ?? '',
                overflow: TextOverflow.ellipsis,
                maxLines: 6,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: MediaQuery.of(context).size.width > 600 ? 16 : 13,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  height: 1.92,
                ),
              ),
            ),
            const SizedBox(height: 7),

            // ============================
            // Gambar + PopupMenu di kanan atas
            // ============================
            Stack(
              children: [
                Container(
                  width: imageWidth,
                  height: imageHeight,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image:
                          (communityPostUpdate.photo != null &&
                              communityPostUpdate.photo!.isNotEmpty)
                          ? NetworkImage(communityPostUpdate.photo!)
                          : const AssetImage('assets/images/no_image.png')
                                as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                if (RoleItem.leader.displayName == role)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 24,
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.editCommunityPostUpdate,
                            arguments: {
                              'postId': communityPostUpdate.communityPostId,
                              'communityPostUpdateId':
                                  communityPostUpdate.communityPostUpdateId,
                            },
                          );
                        } else if (value == 'delete') {
                          CommunityPostUpdateProvider()
                              .deleteCommunityPostUpdate(
                                communityPostUpdate.communityPostUpdateId!,
                              )
                              .then((_) {
                                Provider.of<CommunityPostProvider>(
                                  context,
                                  listen: false,
                                ).fetchPost(
                                  communityPostUpdate.communityPostId,
                                );
                              });
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text("Edit")),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text("Delete"),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}
