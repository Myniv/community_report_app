import 'package:community_report_app/custom_theme.dart';
import 'package:community_report_app/models/enum_list.dart';
import 'package:community_report_app/provider/community_post_provider.dart';
import 'package:community_report_app/provider/profileProvider.dart';
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

                        trailing: Icon(Icons.arrow_forward_ios),
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

// ListView.separated(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: communityPost.length,
//                     itemBuilder: (context, index) {
//                       return ListTile(
//                         title: Text(
//                           items[index]['date']!,
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(items[index]['clock_out_info']!),
//                             SizedBox(height: 4),
//                             Text(
//                               items[index]['is_approved']!,
//                               style: TextStyle(
//                                 color: items[index]['is_approved'] == 'Approved'
//                                     ? Colors.green
//                                     : items[index]['is_approved'] == 'Pending'
//                                     ? Colors.orange
//                                     : Colors.red,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),

//                         trailing: Icon(Icons.arrow_forward_ios),
//                       );
//                     },
//                     separatorBuilder: (context, index) {
//                       return const Divider(
//                         thickness: 1,
//                         color: Colors.grey,
//                         height: 20, // jarak vertikal
//                       );
//                     },
//                   ),

// ListView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     padding: const EdgeInsets.only(bottom: 16),
//                     itemCount: communityPost.length,
//                     itemBuilder: (context, index) {
//                       final post = communityPost[index];
//                       return PostSection(
//                         postId: post.id,
//                         profilePhoto: post.user_photo,
//                         username: post.username ?? "",
//                         title: post.title ?? "",
//                         description: post.description ?? "",
//                         category: post.category ?? "",
//                         urgency: post.urgency ?? "",
//                         status: post.status ?? "",
//                         location: post.location ?? "",
//                         latitude: post.latitude ?? 0.0,
//                         longitude: post.longitude ?? 0.0,
//                         createdAt: post.created_at ?? DateTime.now(),
//                         settingPostScreen: false,
//                         postImage: post.photo,
//                       );
//                     },
//                   ),
