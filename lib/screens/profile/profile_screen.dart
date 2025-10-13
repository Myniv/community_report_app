import 'package:community_report_app/custom_theme.dart';
import 'package:community_report_app/models/community_post.dart';
import 'package:community_report_app/models/enum_list.dart';
import 'package:community_report_app/models/profile.dart';
import 'package:community_report_app/provider/community_post_provider.dart';
import 'package:community_report_app/provider/profileProvider.dart';
import 'package:community_report_app/routes.dart';
import 'package:community_report_app/widgets/no_item.dart';
import 'package:community_report_app/widgets/post_section.dart';
import 'package:community_report_app/widgets/tab_bar_delegate.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final String? profileId;
  const ProfileScreen({super.key, this.profileId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? selectStatus;
  String? selectCategory;
  String? selectLocation;
  String? selectUrgency;
  bool isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final profileProvider = context.read<ProfileProvider>();

        if (widget.profileId != null) {
          print("Loading profile other user with id: ${widget.profileId}");
          await profileProvider.loadProfileOtherUser(widget.profileId!);

          await context.read<CommunityPostProvider>().fetchPostsList(
            userId: widget.profileId,
            status: selectStatus,
            category: selectCategory,
            location: selectLocation,
            urgency: selectUrgency,
          );
        } else {
          print("Loading own profile");

          if (profileProvider.profile?.uid != null) {
            await context.read<CommunityPostProvider>().fetchPostsList(
              userId: profileProvider.profile!.uid,
              status: selectStatus,
              category: selectCategory,
              location: selectLocation,
              urgency: selectUrgency,
            );
          }
        }
      });
      isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = widget.profileId == null
        ? profileProvider.profile
        : profileProvider.otherUserProfile;
    final communityPostProvider = context.watch<CommunityPostProvider>();
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: widget.profileId != null
            ? AppBar(
                backgroundColor: Colors.white,
                iconTheme: IconThemeData(color: CustomTheme.green),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Profile ${profile?.username ?? ""}",
                      style: CustomTheme().smallFont(
                        CustomTheme.green,
                        FontWeight.bold,
                        context,
                      ),
                    ),
                    Text(
                      DateFormat('MMMM dd, yyyy').format(DateTime.now()),
                      style: CustomTheme().superSmallFont(
                        CustomTheme.green,
                        FontWeight.bold,
                        context,
                      ),
                    ),
                  ],
                ),
              )
            : null,
        body: Column(
          children: [
            SizedBox(height: 260, child: buildProfileSection(profile, context)),
            const SizedBox(height: 60),
            const TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green,
              tabs: [
                Tab(text: "Posts"),
                Tab(text: "Likes"),
              ],
            ),

            Expanded(
              child: TabBarView(
                children: [
                  Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          children: [
                            CustomTheme().customDropdown2(
                              context: context,
                              hint: "Category",
                              value: selectCategory,
                              items: allCategory,
                              onChanged: (value) {
                                setState(
                                  () => selectCategory = value == 'All'
                                      ? null
                                      : value!,
                                );
                                final profileProvider = context
                                    .read<ProfileProvider>();
                                context
                                    .read<CommunityPostProvider>()
                                    .fetchPostsList(
                                      userId: profileProvider.profile?.uid,
                                      status: selectStatus,
                                      category: selectCategory,
                                      location: selectLocation,
                                      urgency: selectUrgency,
                                    );
                              },
                            ),
                            const SizedBox(width: 12),
                            CustomTheme().customDropdown2(
                              context: context,
                              hint: "Status",
                              value: selectStatus,
                              items: allStatus,
                              onChanged: (value) {
                                setState(
                                  () => selectStatus = value == 'All'
                                      ? null
                                      : value!,
                                );
                                final profileProvider = context
                                    .read<ProfileProvider>();
                                context
                                    .read<CommunityPostProvider>()
                                    .fetchPostsList(
                                      userId: profileProvider.profile?.uid,
                                      status: selectStatus,
                                      category: selectCategory,
                                      location: selectLocation,
                                      urgency: selectUrgency,
                                    );
                              },
                            ),

                            const SizedBox(width: 12),
                            CustomTheme().customDropdown2(
                              context: context,
                              hint: "Urgency",
                              value: selectUrgency,
                              items: allUrgency,
                              onChanged: (value) {
                                setState(
                                  () => selectUrgency = value == 'All'
                                      ? null
                                      : value!,
                                );
                                final profileProvider = context
                                    .read<ProfileProvider>();
                                context
                                    .read<CommunityPostProvider>()
                                    .fetchPostsList(
                                      userId: profileProvider.profile?.uid,
                                      status: selectStatus,
                                      category: selectCategory,
                                      location: selectLocation,
                                      urgency: selectUrgency,
                                    );
                              },
                            ),
                            const SizedBox(width: 12),
                            CustomTheme().customDropdown2(
                              context: context,
                              hint: "Location",
                              value: selectLocation,
                              items: allLocation,
                              onChanged: (value) {
                                setState(
                                  () => selectLocation = value == 'All'
                                      ? null
                                      : value!,
                                );
                                final profileProvider = context
                                    .read<ProfileProvider>();
                                context
                                    .read<CommunityPostProvider>()
                                    .fetchPostsList(
                                      userId: profileProvider.profile?.uid,
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

                      Expanded(
                        child: communityPostProvider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : communityPost.isEmpty
                            ? const NoItem(
                                title: "No Post",
                                subTitle: "You have no post yet",
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 16),
                                itemCount: communityPost.length,
                                itemBuilder: (context, index) {
                                  final post = communityPost[index];
                                  return PostSection(
                                    postId: post.id,
                                    profilePhoto: post.user_photo,
                                    username: post.username ?? "",
                                    role: profile?.role ?? "",
                                    title: post.title ?? "",
                                    description: post.description ?? "",
                                    category: post.category ?? "",
                                    urgency: post.urgency ?? "",
                                    status: post.status ?? "",
                                    location: post.location ?? "",
                                    latitude: post.latitude ?? 0.0,
                                    longitude: post.longitude ?? 0.0,
                                    createdAt:
                                        post.created_at ?? DateTime.now(),
                                    settingPostScreen: false,
                                    postImage: post.photo,
                                    editPost: true,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),

                  ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.favorite, color: Colors.red),
                        title: Text("Liked Post #$index"),
                        subtitle: const Text("This is a liked post"),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileSection(Profile? profile, BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        buildCoverProfile(),
        Positioned(
          top: 130,
          left: 30,
          right: 30,
          child: buildProfileHeader(profile, context),
        ),
      ],
    );
  }

  Widget buildCoverProfile() {
    return Container(height: 195, color: const Color(0xFFD9D9D9));
  }

  Widget buildProfileHeader(Profile? profile, BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  (profile?.photo != null && profile!.photo!.isNotEmpty)
                  ? NetworkImage(profile.photo!)
                  : null,
              child: (profile?.photo == null || profile!.photo!.isEmpty)
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 10),
            Text(
              '${profile?.front_name ?? "-"} ${profile?.last_name ?? "-"}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Roboto',
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              profile?.username ?? "Not specified",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),

        if (widget.profileId == null ||
            context.read<ProfileProvider>().profile?.role == 'admin') ...[
          Positioned(
            right: 0,
            top: 90,
            child: Material(
              color: Colors.transparent,
              child: buildEditProfileButton(context),
            ),
          ),
        ],
      ],
    );
  }

  Widget buildEditProfileButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(
          context,
          AppRoutes.editProfile,
          arguments: {'uid': widget.profileId ?? null},
        );

        if (result == true) {
          // Refresh data setelah balik dari edit
          context.read<CommunityPostProvider>().fetchPostsList(
            userId: context.read<ProfileProvider>().profile?.uid,
            status: selectStatus,
            category: selectCategory,
            location: selectLocation,
            urgency: selectUrgency,
          );
        }
      },

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: ShapeDecoration(
          color: const Color(0xFF249A00),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        child: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildPostTab(
    BuildContext context,
    List<CommunityPost> communityPost,
    CommunityPostProvider provider,
    Profile? profile,
  ) {
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
    return Column(
      children: [
        // filter bar horizontal
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  setState(() => selectStatus = value == 'All' ? null : value!);
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
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : communityPost.isEmpty
              ? const NoItem(title: "No Post", subTitle: "You have no post yet")
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: communityPost.length,
                  itemBuilder: (context, index) {
                    final post = communityPost[index];
                    return PostSection(
                      postId: post.id,
                      profilePhoto: post.user_photo,
                      username: post.username ?? "",
                      role: profile?.role ?? "",
                      title: post.title ?? "",
                      description: post.description ?? "",
                      category: post.category ?? "",
                      urgency: post.urgency ?? "",
                      status: post.status ?? "",
                      location: post.location ?? "",
                      latitude: post.latitude ?? 0.0,
                      longitude: post.longitude ?? 0.0,
                      createdAt: post.created_at ?? DateTime.now(),
                      settingPostScreen: false,
                      postImage: post.photo,
                      editPost: true,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// class _TabBarDelegate extends SliverPersistentHeaderDelegate {
//   final TabBar tabBar;
//   _TabBarDelegate(this.tabBar);

//   @override
//   double get minExtent => tabBar.preferredSize.height;
//   @override
//   double get maxExtent => tabBar.preferredSize.height;

//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     return Container(
//       color: ColorScheme.fromSeed(seedColor: Colors.deepPurple).surface,
//       child: tabBar,
//     );
//   }

//   @override
//   bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
// }
