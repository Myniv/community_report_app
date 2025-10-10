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
    selectLocation = profile?.location;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<CommunityPostProvider>().fetchPostsList(
        location: selectLocation,
        category: selectCategory,
        status: selectStatus,
        urgency: selectUrgency,
        userId: profile!.uid,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 30),

            communityPostProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : communityPost.isEmpty
                ? const NoItem(
                    title: "No Post",
                    subTitle: "You have no post yet",
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: communityPost.length,
                    itemBuilder: (context, index) {
                      final post = communityPost[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 10,
                        ),
                        leading: ClipOval(
                          child: Image.network(
                            post.photo ?? '',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/default_profile.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                        title: Text(
                          post.title!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 7),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TextContainer(
                                  text: post.category ?? '',
                                  category: true,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  post.status ?? '',
                                  style: TextStyle(
                                    color: post.status == 'pending'
                                        ? Colors.red
                                        : post.status == 'in_progress'
                                        ? Colors.orange
                                        : Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  post.created_at != null
                                      ? ' • ${DateFormat('d MMM').format(post.created_at!)}'
                                      : '',
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.arrow_forward_ios),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.discussionDetail,
                              arguments: post.id,
                            );
                          },
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Padding(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 25),
                        child: Divider(thickness: 1, color: Colors.grey),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
