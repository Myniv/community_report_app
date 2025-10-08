import 'package:community_report_app/custom_theme.dart';
import 'package:community_report_app/models/community_post_update.dart';
import 'package:community_report_app/models/discussion.dart';
import 'package:community_report_app/provider/community_post_provider.dart';
import 'package:community_report_app/provider/discussion_provider.dart';
import 'package:community_report_app/provider/profileProvider.dart';
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
    child: discussions.isEmpty
        ? const NoItem(
            title: "No Discussion Yet",
            subTitle: "There are no discussions on this post.",
          )
        : Column(
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
                            (comment.userPhoto == null ||
                                comment.userPhoto!.isEmpty)
                            ? const Icon(Icons.person, size: 20)
                            : null,
                      ),
                      title: Text(comment.username ?? 'Unknown'),
                      subtitle: Text(comment.message ?? ''),
                      trailing: (profile?.uid == comment.userId)
                          ? PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  discussionProvider
                                          .editMessageController
                                          .text =
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
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(),
                                            child: const Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              final newMessage =
                                                  discussionProvider
                                                      .editMessageController
                                                      .text
                                                      .trim();
                                              if (newMessage.isNotEmpty) {
                                                discussionProvider
                                                    .updateDiscussion(
                                                      discussionId:
                                                          comment.discussionId,
                                                      userId: comment.userId,
                                                      communityPostId: comment
                                                          .communityPostId,
                                                      message: newMessage,
                                                    )
                                                    .then((_) {
                                                      Provider.of<
                                                            CommunityPostProvider
                                                          >(
                                                            context,
                                                            listen: false,
                                                          )
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
            ],
          ),
  );
}

Widget _buildPostUpdatesTab(
  BuildContext context,
  List<CommunityPostUpdate> communityPostUpdates,
  int postId,
) {
  // final discussionProvider = Provider.of<DiscussionProvider>(context);
  // final profile = context.watch<ProfileProvider>().profile;
  return Expanded(
    child: communityPostUpdates.isEmpty
        ? const NoItem(
            title: "No Post Updates Yet",
            subTitle: "There are no post updates on this post.",
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
                    return buildPostUpdateSection(context, communityPostUpdate);
                  },
                ),
              ),
            ],
          ),
  );
}

Widget buildPostUpdateSection(
  BuildContext context,
  CommunityPostUpdate communityPostUpdate,
) {
  final screenWidth = MediaQuery.of(context).size.width;
  final horizontalPadding = screenWidth * 0.07;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
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
              // child: const Icon(Icons.person, size: 20),
              child:
                  (communityPostUpdate.userPhoto == null ||
                      communityPostUpdate.userPhoto!.isEmpty)
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              communityPostUpdate.username!,
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
            SizedBox(width: 10),
            // if (editPost == true) ...[
            //   IconButton(
            //     icon: const Icon(Icons.more_vert),
            //     onPressed: () {
            //       _showOptions(context);
            //     },
            //   ),
            // ],
          ],
        ),
      ),
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
            Text(
              communityPostUpdate.title!,
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
                communityPostUpdate.description!,
                overflow: TextOverflow.ellipsis,
                maxLines: 6,
                style: TextStyle(
                  color: Colors.black /* Black */,
                  fontSize: MediaQuery.of(context).size.width > 600 ? 16 : 13,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  height: 1.92,
                ),
              ),
            ),
            const SizedBox(height: 7),
            Container(
              width:
                  MediaQuery.of(context).size.width -
                  (horizontalPadding + 50 + horizontalPadding),
              height:
                  (MediaQuery.of(context).size.width -
                      (horizontalPadding + 50 + horizontalPadding)) *
                  0.6,
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image:
                      (communityPostUpdate.photo != null &&
                          communityPostUpdate.photo!.isNotEmpty)
                      ? NetworkImage(communityPostUpdate.photo!)
                            as ImageProvider
                      : AssetImage('assets/images/no_image.png'),
                  fit: BoxFit.cover,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
