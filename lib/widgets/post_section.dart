import 'package:community_report_app/custom_theme.dart';
import 'package:community_report_app/routes.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PostSection extends StatelessWidget {
  int? postId;
  String? profilePhoto;
  String username;
  String title;
  String description;
  String category;
  String urgency;
  String status;
  String location;
  double latitude;
  double longitude;
  String? postImage;
  DateTime createdAt;
  String? role;
  bool? settingPostScreen = false;
  int? discussionCount;

  PostSection({
    Key? key,
    this.postId,
    this.profilePhoto,
    required this.username,
    required this.title,
    required this.description,
    required this.category,
    required this.urgency,
    required this.status,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.postImage,
    required this.createdAt,
    this.role,
    this.settingPostScreen,
    this.discussionCount,
  }) : super(key: key);

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.star_border),
              title: const Text('Interested'),
              onTap: () {
                Navigator.pop(context);
                // handle interested action
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Not interested'),
              onTap: () {
                Navigator.pop(context);
                // handle not interested action
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Save post'),
              onTap: () {
                Navigator.pop(context);
                // handle save action
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility_off),
              title: const Text('Hide post'),
              onTap: () {
                Navigator.pop(context);
                // handle hide action
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report post'),
              onTap: () {
                Navigator.pop(context);
                // handle report action
              },
            ),
          ],
        );
      },
    );
  }

  void _openMap(double lat, double lng) async {
    final Uri url = Uri.parse("https://www.google.com/maps?q=$lat,$lng");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open the map.';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    (profilePhoto != null && profilePhoto!.isNotEmpty)
                    ? NetworkImage(profilePhoto!)
                    : null,
                // child: const Icon(Icons.person, size: 20),
                child: (profilePhoto == null || profilePhoto!.isEmpty)
                    ? const Icon(Icons.person, size: 20)
                    : null,
              ),
              const SizedBox(width: 10),

              Text(
                username,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(width: 10),

              Text(
                CustomTheme().timeAgo(createdAt),
                style: const TextStyle(
                  color: Color(0xFF249A00),
                  fontSize: 13,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              Container(
                width: 57,
                height: 25,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0FFDE),
                  borderRadius: BorderRadius.circular(5),
                ),
                alignment: Alignment.center,
                child: Text(
                  category,
                  style: TextStyle(
                    color: Color(0xFF249A00),
                    fontSize: 13,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Container(
                width: 57,
                height: 25,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0FFDE),
                  borderRadius: BorderRadius.circular(5),
                ),
                alignment: Alignment.center,
                child: Text(
                  status,
                  style: TextStyle(
                    color: Color(0xFF249A00),
                    fontSize: 13,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),

              if (settingPostScreen == true &&
                  (role == 'admin' || role == 'leader')) ...[
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    _showOptions(context);
                  },
                ),
              ],
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
                title,
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
                  description,
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
                    image: (postImage != null && postImage!.isNotEmpty)
                        ? NetworkImage(postImage!) as ImageProvider
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
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding + 50,
            0,
            horizontalPadding,
            0,
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.discussionDetail,
                    arguments: postId,
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.comment, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      "${discussionCount ?? ''}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

              // IconButton(
              //   onPressed: () {
              //     Navigator.pushNamed(
              //       context,
              //       AppRoutes.discussionDetail,
              //       arguments: postId,
              //     );
              //   },
              //   icon: const Icon(Icons.comment, size: 20),
              // ),
              SizedBox(width: 10),
              InkWell(
                onTap: () {
                  _openMap(latitude, longitude);
                },
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 20, color: Color(0xFF249A00)),
                    Text(
                      location,
                      style: TextStyle(
                        color: Color(0xFF249A00),
                        fontSize: 13,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
