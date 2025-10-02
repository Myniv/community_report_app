import 'package:community_report_app/models/profile.dart';
import 'package:community_report_app/provider/profileProvider.dart';
import 'package:community_report_app/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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

            // ✅ Konten tab
            Expanded(
              child: TabBarView(
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return buildPostSection(profile, context);
                    },
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

      Positioned(
        right: 0,
        top: 90,
        child: Material(
          color: Colors.transparent,
          child: buildEditProfileButton(context),
        ),
      ),
    ],
  );
}

Widget buildEditProfileButton(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, AppRoutes.editProfile);
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

Widget buildPostSection(Profile? profile, BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final horizontalPadding = screenWidth * 0.07;

  return Column(
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
                  (profile?.photo != null && profile!.photo!.isNotEmpty)
                  ? NetworkImage(profile.photo!)
                  : null,
              child: (profile?.photo == null || profile!.photo!.isEmpty)
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
            const SizedBox(width: 10),

            Text(
              '${profile?.front_name ?? "-"} ${profile?.last_name ?? "-"}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(width: 10),

            Text(
              '22 hours ago',
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
              child: const Text(
                'Safety',
                style: TextStyle(
                  color: Color(0xFF249A00),
                  fontSize: 13,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
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
          children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                'The pedestrian signal at the main intersection near Mexico Square is not functioning. Cars don’t stop, and people are forced to cross dangerously. This puts children and elderly at high risk. Please fix urgently.',
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
                  image: NetworkImage(
                    "https://dishub.banjarmasinkota.go.id/wp-content/uploads/2024/11/lampu-lalu-lintas-punya-3-warna_169.jpg",
                  ),
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
