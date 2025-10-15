import 'package:community_report_app/custom_theme.dart';
import 'package:community_report_app/models/enum_list.dart';
import 'package:community_report_app/provider/community_post_provider.dart';
import 'package:community_report_app/provider/profileProvider.dart';
import 'package:community_report_app/routes.dart';
import 'package:community_report_app/widgets/no_item.dart';
import 'package:community_report_app/widgets/text_container.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ListCommunityPostScreen extends StatefulWidget {
  const ListCommunityPostScreen({super.key});

  @override
  State<ListCommunityPostScreen> createState() =>
      _ListCommunityPostScreenState();
}

class _ListCommunityPostScreenState extends State<ListCommunityPostScreen> {
  String? selectLocation;
  String? selectCategory;
  String? selectUrgency;
  String? selectStatus;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    final postProvider = context.read<CommunityPostProvider>();
    final isMember = profile?.role == RoleItem.member.displayName;
    final isLeader = profile?.role == RoleItem.leader.displayName;
    selectLocation = profile?.location;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (isMember || isLeader) {
        postProvider.fetchPostsList(
          location: isMember ? selectLocation : profile?.location,
          category: selectCategory,
          status: selectStatus,
          urgency: selectUrgency,
          userId: isMember ? profile?.uid : null,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = CustomTheme();
    final communityPostProvider = context.watch<CommunityPostProvider>();
    final profile = context.watch<ProfileProvider>().profile;

    final communityPost = communityPostProvider.postListProfile;

    final allCategory = [
      'All',
      ...CategoryItem.values.map((e) => e.displayName).toList(),
    ];
    final allStatus = [
      'All',
      ...StatusItem.values.map((e) => e.displayName).toList(),
    ];
    final allUrgency = [
      'All',
      ...UrgencyItem.values.map((e) => e.displayName).toList(),
    ];
    final allLocation = [
      'All',
      ...LocationItem.values.map((e) => e.displayName).toList(),
    ];

    final roleItem = RoleItem.values.map((e) => e.displayName).toList();
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTheme().customDropdown2(
                      context: context,
                      hint: "Category",
                      value: selectCategory,
                      items: allCategory,
                      onChanged: (value) async {
                        setState(
                          () => selectCategory = value == 'All' ? null : value!,
                        );
                        context.read<CommunityPostProvider>().fetchPostsList(
                          status: selectStatus,
                          category: selectCategory,
                          location: selectLocation,
                          urgency: selectUrgency,
                        );
                      },
                    ),
                    SizedBox(width: 10),
                    CustomTheme().customDropdown2(
                      context: context,
                      hint: "Status",
                      value: selectStatus,
                      items: allStatus,
                      onChanged: (value) async {
                        setState(
                          () => selectStatus = value == 'All' ? null : value!,
                        );
                        context.read<CommunityPostProvider>().fetchPostsList(
                          status: selectStatus,
                          category: selectCategory,
                          location: selectLocation,
                          urgency: selectUrgency,
                        );
                      },
                    ),
                    SizedBox(width: 10),
                    CustomTheme().customDropdown2(
                      context: context,
                      hint: "Urgency",
                      value: selectUrgency,
                      items: allUrgency,
                      onChanged: (value) async {
                        setState(
                          () => selectUrgency = value == 'All' ? null : value!,
                        );
                        context.read<CommunityPostProvider>().fetchPostsList(
                          status: selectStatus,
                          category: selectCategory,
                          location: selectLocation,
                          urgency: selectUrgency,
                        );
                      },
                    ),
                    SizedBox(width: 10),
                    CustomTheme().customDropdown2(
                      context: context,
                      hint: "Location",
                      value: selectLocation,
                      items: allLocation,
                      enabled: profile?.role != RoleItem.leader.displayName,
                      onChanged: (value) async {
                        setState(
                          () => selectLocation = value == 'All' ? null : value!,
                        );
                        context.read<CommunityPostProvider>().fetchPostsList(
                          status: selectStatus,
                          category: selectCategory,
                          location: selectLocation,
                          urgency: selectUrgency,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // const SizedBox(height: 8),
            communityPostProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : communityPost.isEmpty
                ? Center(
                    child: NoItem(
                      title: "No Post",
                      subTitle: "You have no history yet",
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: communityPost.length,
                    itemBuilder: (context, index) {
                      final post = communityPost[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPostCard(context, customTheme, post),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'waste':
        return Icons.delete_outline;
      case 'water':
        return Icons.water_drop_outlined;
      case 'electricity':
        return Icons.electrical_services_outlined;
      case 'gas':
        return Icons.local_fire_department_outlined;
      case 'other':
      default:
        return Icons.category_outlined;
    }
  }

  Widget _buildPostCard(
    BuildContext context,
    CustomTheme customTheme,
    dynamic post,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: CustomTheme.borderRadius,
        boxShadow: [
          BoxShadow(
            color: CustomTheme.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: CustomTheme.borderRadius,
        child: InkWell(
          borderRadius: CustomTheme.borderRadius,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.discussionDetail,
              arguments: post.id,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: CustomTheme.green, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: CustomTheme.green.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  // child: CircleAvatar(
                  //   radius: 28,
                  //   backgroundImage:
                  //       (post.photo != null && post.photo!.isNotEmpty)
                  //       ? NetworkImage(post.photo!)
                  //       : const AssetImage('assets/images/default_profile.png')
                  //             as ImageProvider,
                  //   backgroundColor: CustomTheme.whiteKindaGreen.withOpacity(
                  //     0.3,
                  //   ),
                  //   child: (post.photo == null || post.photo!.isEmpty)
                  //       ? Icon(
                  //           Icons.person,
                  //           size: 32,
                  //           color: CustomTheme.whiteKindaGreen,
                  //         )
                  //       : null,
                  // ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: CustomTheme.green,
                    child: Icon(
                      _getCategoryIcon(post.category),
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title ?? '',
                        style: customTheme.mediumFont(
                          CustomTheme.green,
                          FontWeight.w700,
                          context,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextContainer(
                            text: post.category ?? '',
                            category: true,
                            useIcon: false,
                          ),
                          const SizedBox(width: 8),
                          TextContainer(text: post.status ?? ''),
                          const SizedBox(width: 8),
                          Text(
                            post.created_at != null
                                ? '• ${DateFormat('d MMM').format(post.created_at!)}'
                                : '',
                            style: customTheme.smallFont(
                              CustomTheme.green,
                              FontWeight.w500,
                              context,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CustomTheme.lightGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: CustomTheme.lightGreen,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
